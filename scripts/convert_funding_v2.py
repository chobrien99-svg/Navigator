#!/usr/bin/env python3
"""
Convert the enriched 2024 funding CSV (v2) to SQL migration.

Input: data/funding_2024_v2_enriched.csv
Columns: company, amount_raised (EUR), round, investors_participated,
         date_announced, website, description, city, official_sector,
         secondary_sector, tertiary_sector, SIREN

Output: supabase/migrations/phase10/01_import_funding_2024_v2.sql

Creates:
  1. Cities (new ones only)
  2. Sectors (new ones only)
  3. Organizations (upsert by slug; enrich missing fields)
  4. Legal entities (where SIREN available)
  5. Organization-city links
  6. Organization-sector links (primary, secondary, tertiary)
  7. Funding rounds (with NOT EXISTS dedup)
  8. Investor organizations (type='investor', upsert)
  9. Funding round investors (first listed = lead)

source_name = 'funding_deals_2024_v2'
"""

import csv
import json
import re
from pathlib import Path

INPUT = Path('data/funding_2024_v2_enriched.csv')
OUT_DIR = Path('supabase/migrations/phase10')
OUTPUT = OUT_DIR / '01_import_funding_2024_v2.sql'
SOURCE_NAME = 'funding_deals_2024_v2'
AMOUNT_DIVISOR = 1_000_000  # amounts stored in millions in DB


def slugify(name: str) -> str:
    """Match the SQL slug generation logic."""
    accent_map = {
        'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
        'à': 'a', 'â': 'a', 'ä': 'a', 'á': 'a',
        'ù': 'u', 'û': 'u', 'ü': 'u',
        'î': 'i', 'ï': 'i', 'ô': 'o', 'ö': 'o',
        'ç': 'c', 'ñ': 'n',
        'É': 'E', 'È': 'E', 'Ê': 'E',
        'À': 'A', 'Â': 'A', 'Ç': 'C',
        '\u2019': '',
    }
    s = name
    for k, v in accent_map.items():
        s = s.replace(k, v)
    s = re.sub(r'[^a-zA-Z0-9\s-]', '', s)
    s = re.sub(r'\s+', '-', s)
    return s.lower().strip('-')


def map_stage(round_str: str) -> str:
    """Map round string to funding_stage enum value."""
    if not round_str:
        return 'undisclosed'
    r = round_str.strip().lower()
    mapping = {
        'pre-seed': 'pre_seed', 'preseed': 'pre_seed',
        'seed': 'seed',
        'series a': 'series_a', 'series-a': 'series_a',
        'series b': 'series_b', 'series-b': 'series_b',
        'series c': 'series_c', 'series-c': 'series_c',
        'series d': 'series_d', 'series-d': 'series_d',
        'series e': 'series_e', 'series-e': 'series_e',
        'series f': 'series_f',
        'growth': 'growth',
        'bridge': 'bridge',
        'debt': 'debt',
        'grant': 'grant',
        'ipo': 'ipo',
        'secondary': 'secondary',
        'business angel': 'pre_seed',
        'angel': 'pre_seed',
    }
    return mapping.get(r, 'other')


def parse_amount(val: str) -> float | None:
    if not val:
        return None
    try:
        return float(str(val).replace(',', '').replace(' ', '').strip())
    except (ValueError, TypeError):
        return None


def parse_investors(val: str) -> list[str]:
    if not val:
        return []
    return [i.strip() for i in val.split(',') if i.strip()]


def main():
    with open(INPUT) as f:
        reader = csv.DictReader(f)
        rows = list(reader)

    print(f"Read {len(rows)} rows from {INPUT}")

    # Collect unique entities
    orgs = {}  # slug -> dict
    siren_to_slug = {}  # siren -> slug
    cities_set = set()
    sectors_set = set()
    investor_names_set = set()

    for row in rows:
        name = (row.get('company') or '').strip()
        if not name:
            continue
        slug = slugify(name)
        if not slug:
            continue

        siren = (row.get('SIREN') or '').strip() or None
        if siren and not siren.isdigit():
            siren = None  # skip malformed SIRENs

        website = (row.get('website') or '').strip() or None
        description = (row.get('description') or '').strip() or None
        city = (row.get('city') or '').strip() or None

        # Dedup orgs (prefer first occurrence for primary fields, SIREN trumps)
        if slug not in orgs:
            orgs[slug] = {
                'name': name,
                'slug': slug,
                'siren': siren,
                'website': website,
                'description': description,
                'city': city,
            }
        else:
            # Enrich missing fields
            if siren and not orgs[slug].get('siren'):
                orgs[slug]['siren'] = siren
            if website and not orgs[slug].get('website'):
                orgs[slug]['website'] = website
            if description and not orgs[slug].get('description'):
                orgs[slug]['description'] = description
            if city and not orgs[slug].get('city'):
                orgs[slug]['city'] = city

        if siren:
            siren_to_slug[siren] = slug
        if city:
            cities_set.add(city)

        for sec_key in ('official_sector', 'secondary_sector', 'tertiary_sector'):
            sec = (row.get(sec_key) or '').strip()
            if sec:
                sectors_set.add(sec)

        for inv in parse_investors(row.get('investors_participated', '')):
            investor_names_set.add(inv)

    # Build sector list (deduplicated)
    sectors_list = sorted(sectors_set)
    cities_list = sorted(cities_set)
    investors_list = sorted(investor_names_set)

    print(f"Unique orgs: {len(orgs)}")
    print(f"Unique cities: {len(cities_list)}")
    print(f"Unique sectors: {len(sectors_list)}")
    print(f"Unique investors: {len(investors_list)}")

    # Build JSON payloads
    orgs_json = [
        {
            'name': o['name'],
            'website': o['website'],
            'description': o['description'],
            'siren': o['siren'],
            'city': o['city'],
        }
        for o in orgs.values()
    ]

    legal_json = [
        {'name': o['name'], 'siren': o['siren']}
        for o in orgs.values() if o['siren']
    ]

    cities_json = [{'name': c} for c in cities_list]
    sectors_json = [{'name': s} for s in sectors_list]
    investors_json = [{'name': i} for i in investors_list]

    # Sector links (primary, secondary, tertiary)
    sector_links = []
    for row in rows:
        name = (row.get('company') or '').strip()
        if not name:
            continue
        slug = slugify(name)
        if not slug:
            continue
        primary = (row.get('official_sector') or '').strip() or None
        secondary = (row.get('secondary_sector') or '').strip() or None
        tertiary = (row.get('tertiary_sector') or '').strip() or None
        for sector, is_primary in [(primary, True), (secondary, False), (tertiary, False)]:
            if sector:
                sector_links.append({
                    'org_slug': slug,
                    'sector': sector,
                    'is_primary': is_primary,
                })

    # Deduplicate sector_links (slug + sector)
    # Also: ensure each org has at most ONE is_primary=TRUE to respect
    # the idx_one_primary_sector_per_org unique constraint in the DB.
    seen_pairs = set()
    seen_primary_for_org = set()
    sector_links_dedup = []
    for link in sector_links:
        key = (link['org_slug'], link['sector'])
        if key in seen_pairs:
            continue
        seen_pairs.add(key)
        # If this link is primary but the org already has a primary, demote it
        if link['is_primary']:
            if link['org_slug'] in seen_primary_for_org:
                link = {**link, 'is_primary': False}
            else:
                seen_primary_for_org.add(link['org_slug'])
        sector_links_dedup.append(link)

    # Funding rounds
    rounds_json = []
    for row in rows:
        name = (row.get('company') or '').strip()
        if not name:
            continue
        slug = slugify(name)
        amount_raw = parse_amount(row.get('amount_raised', ''))
        amount_millions = round(amount_raw / AMOUNT_DIVISOR, 6) if amount_raw else None
        stage = map_stage(row.get('round', ''))
        date = (row.get('date_announced') or '').strip() or None
        rounds_json.append({
            'org_slug': slug,
            'stage': stage,
            'amount_eur': amount_millions,
            'announced_date': date,
        })

    # Funding round investors
    round_investors_json = []
    for row in rows:
        name = (row.get('company') or '').strip()
        investors_str = (row.get('investors_participated') or '').strip()
        if not name or not investors_str:
            continue
        slug = slugify(name)
        date = (row.get('date_announced') or '').strip() or None
        amount_raw = parse_amount(row.get('amount_raised', ''))
        amount_millions = round(amount_raw / AMOUNT_DIVISOR, 6) if amount_raw else None
        investors = parse_investors(investors_str)
        for i, inv in enumerate(investors):
            round_investors_json.append({
                'org_slug': slug,
                'announced_date': date,
                'amount_eur': amount_millions,
                'investor_name': inv,
                'is_lead': i == 0,
            })

    print(f"Sector links: {len(sector_links_dedup)}")
    print(f"Rounds: {len(rounds_json)}")
    print(f"Investor participations: {len(round_investors_json)}")

    # Build SQL
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    sql = []
    sql.append(f"""-- =============================================================================
-- 2024 Funding Deals v2 Import
-- =============================================================================
-- Source: data/funding_2024_v2_enriched.csv (user-cleaned, sectors auto-enriched)
-- Amounts already in EUR (no currency conversion needed)
-- source_name: '{SOURCE_NAME}'
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "unaccent";
""")

    # Step 1: Cities
    sql.append(f"""
-- Step 1: Create cities that don't exist yet ({len(cities_list)})
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json${json.dumps(cities_json, ensure_ascii=False)}$json$
  ) AS (name TEXT)
)
INSERT INTO cities (id, name, slug, country, created_at, updated_at)
SELECT
  uuid_generate_v4(),
  s.name,
  lower(regexp_replace(regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\\s-]', '', 'g'), '\\s+', '-', 'g')),
  'France',
  NOW(), NOW()
FROM source s
ON CONFLICT (slug) DO NOTHING;
""")

    # Step 2: Sectors
    sql.append(f"""
-- Step 2: Create sectors that don't exist yet ({len(sectors_list)})
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json${json.dumps(sectors_json, ensure_ascii=False)}$json$
  ) AS (name TEXT)
)
INSERT INTO sectors (id, name, slug, created_at, updated_at)
SELECT
  uuid_generate_v4(),
  s.name,
  lower(regexp_replace(regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\\s-]', '', 'g'), '\\s+', '-', 'g')),
  NOW(), NOW()
FROM source s
ON CONFLICT (slug) DO NOTHING;
""")

    # Step 3: Organizations
    sql.append(f"""
-- Step 3: Create organizations (upsert by slug; enrich missing fields)
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json${json.dumps(orgs_json, ensure_ascii=False)}$json$
  ) AS (name TEXT, website TEXT, description TEXT, siren TEXT, city TEXT)
)
INSERT INTO organizations (
  id, name, slug, organization_type, description, website, status, country,
  legacy_source, legacy_id, created_at, updated_at
)
SELECT
  uuid_generate_v4(),
  s.name,
  lower(regexp_replace(regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\\s-]', '', 'g'), '\\s+', '-', 'g')),
  'startup'::organization_type,
  s.description,
  s.website,
  'active'::organization_status,
  'France',
  '{SOURCE_NAME}',
  s.siren,
  NOW(), NOW()
FROM source s
ON CONFLICT (slug) DO UPDATE SET
  website = COALESCE(organizations.website, EXCLUDED.website),
  description = COALESCE(organizations.description, EXCLUDED.description),
  updated_at = NOW();
""")

    # Step 4: Legal entities (for orgs with SIREN)
    sql.append(f"""
-- Step 4: Create legal_entities for orgs with SIREN ({len(legal_json)})
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json${json.dumps(legal_json, ensure_ascii=False)}$json$
  ) AS (name TEXT, siren TEXT)
)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT
  uuid_generate_v4(),
  o.id,
  s.name,
  s.siren,
  'France',
  TRUE,
  NOW(), NOW()
FROM source s
JOIN organizations o ON o.slug = lower(regexp_replace(regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\\s-]', '', 'g'), '\\s+', '-', 'g'))
WHERE NOT EXISTS (
  SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = s.siren
);
""")

    # Step 5: Update organizations.city_id
    org_city_json = [
        {'org_slug': o['slug'], 'city': o['city']}
        for o in orgs.values() if o['city']
    ]
    sql.append(f"""
-- Step 5: Link organizations to cities ({len(org_city_json)})
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json${json.dumps(org_city_json, ensure_ascii=False)}$json$
  ) AS (org_slug TEXT, city TEXT)
)
UPDATE organizations o
SET city_id = c.id, updated_at = NOW()
FROM source s
JOIN cities c ON c.slug = lower(regexp_replace(regexp_replace(unaccent(s.city), '[^a-zA-Z0-9\\s-]', '', 'g'), '\\s+', '-', 'g'))
WHERE o.slug = s.org_slug AND o.city_id IS NULL;
""")

    # Step 6: Organization-sector links
    sql.append(f"""
-- Step 6: Link organizations to sectors ({len(sector_links_dedup)})
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json${json.dumps(sector_links_dedup, ensure_ascii=False)}$json$
  ) AS (org_slug TEXT, sector TEXT, is_primary BOOLEAN)
)
INSERT INTO organization_sectors (id, organization_id, sector_id, is_primary, created_at)
SELECT
  uuid_generate_v4(),
  o.id,
  sec.id,
  CASE WHEN s.is_primary AND NOT EXISTS (SELECT 1 FROM organization_sectors os2 WHERE os2.organization_id = o.id AND os2.is_primary = TRUE) THEN TRUE ELSE FALSE END,
  NOW()
FROM source s
JOIN organizations o ON o.slug = s.org_slug
JOIN sectors sec ON sec.slug = lower(regexp_replace(regexp_replace(unaccent(s.sector), '[^a-zA-Z0-9\\s-]', '', 'g'), '\\s+', '-', 'g'))
WHERE NOT EXISTS (
  SELECT 1 FROM organization_sectors os
  WHERE os.organization_id = o.id AND os.sector_id = sec.id
);
""")

    # Step 7: Funding rounds
    sql.append(f"""
-- Step 7: Create funding_rounds ({len(rounds_json)})
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json${json.dumps(rounds_json, ensure_ascii=False)}$json$
  ) AS (org_slug TEXT, stage TEXT, amount_eur NUMERIC, announced_date TEXT)
)
INSERT INTO funding_rounds (
  id, organization_id, stage, amount_eur, currency_original, amount_original,
  announced_date, is_estimated, is_verified, source_name, created_at
)
SELECT
  uuid_generate_v4(),
  o.id,
  s.stage::funding_stage,
  s.amount_eur,
  'EUR',
  s.amount_eur * 1000000,
  NULLIF(s.announced_date, '')::DATE,
  FALSE,
  FALSE,
  '{SOURCE_NAME}',
  NOW()
FROM source s
JOIN organizations o ON o.slug = s.org_slug
WHERE NOT EXISTS (
  SELECT 1 FROM funding_rounds fr
  WHERE fr.organization_id = o.id
  AND fr.source_name = '{SOURCE_NAME}'
  AND fr.announced_date IS NOT DISTINCT FROM NULLIF(s.announced_date, '')::DATE
  AND fr.amount_eur IS NOT DISTINCT FROM s.amount_eur
);
""")

    # Step 8: Investor organizations
    sql.append(f"""
-- Step 8: Create investor organizations ({len(investors_list)})
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json${json.dumps(investors_json, ensure_ascii=False)}$json$
  ) AS (name TEXT)
)
INSERT INTO organizations (
  id, name, slug, organization_type, status, country,
  legacy_source, created_at, updated_at
)
SELECT
  uuid_generate_v4(),
  s.name,
  lower(regexp_replace(regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\\s-]', '', 'g'), '\\s+', '-', 'g')),
  'investor'::organization_type,
  'active'::organization_status,
  'France',
  '{SOURCE_NAME}',
  NOW(), NOW()
FROM source s
ON CONFLICT (slug) DO NOTHING;
""")

    # Step 9: Funding round investors
    sql.append(f"""
-- Step 9: Link investors to funding rounds ({len(round_investors_json)})
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json${json.dumps(round_investors_json, ensure_ascii=False)}$json$
  ) AS (org_slug TEXT, announced_date TEXT, amount_eur NUMERIC, investor_name TEXT, is_lead BOOLEAN)
)
INSERT INTO funding_round_investors (
  id, funding_round_id, investor_id, is_lead, investor_name, created_at
)
SELECT
  uuid_generate_v4(),
  fr.id,
  inv_org.id,
  s.is_lead,
  s.investor_name,
  NOW()
FROM source s
JOIN organizations o ON o.slug = s.org_slug
JOIN organizations inv_org ON inv_org.slug = lower(regexp_replace(regexp_replace(unaccent(s.investor_name), '[^a-zA-Z0-9\\s-]', '', 'g'), '\\s+', '-', 'g'))
JOIN funding_rounds fr ON fr.organization_id = o.id
  AND fr.source_name = '{SOURCE_NAME}'
  AND fr.announced_date IS NOT DISTINCT FROM NULLIF(s.announced_date, '')::DATE
  AND fr.amount_eur IS NOT DISTINCT FROM s.amount_eur
WHERE NOT EXISTS (
  SELECT 1 FROM funding_round_investors fri
  WHERE fri.funding_round_id = fr.id AND fri.investor_id = inv_org.id
);
""")

    OUTPUT.write_text('\n'.join(sql), encoding='utf-8')
    print()
    print(f"Written: {OUTPUT}")


if __name__ == '__main__':
    main()
