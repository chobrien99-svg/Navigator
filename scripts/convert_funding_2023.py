#!/usr/bin/env python3
"""
Convert the 2023 funding CSV to a Phase 11 split SQL migration.

Input: data/funding_2023.csv
Columns: Startup, Website, Round, SIREN, Money Raised Euros, Date,
         Description, City, Investor Names, Assigned Sectors

Output: supabase/migrations/phase12/
  01a_cities.sql
  01b_sectors.sql
  01c_organizations.sql
  01d_legal_entities.sql
  01e_org_cities.sql
  01f_org_sectors.sql
  01g_funding_rounds.sql
  01h_investor_orgs.sql
  01i_round_investors.sql

Mirrors the phase10 split-file pattern. source_name = 'funding_deals_2023'.
"""

import csv
import json
import re
from pathlib import Path

INPUT = Path('data/funding_2023.csv')
OUT_DIR = Path('supabase/migrations/phase12')
SOURCE_NAME = 'funding_deals_2023'
AMOUNT_DIVISOR = 1_000_000  # DB stores amount_eur in millions


def slugify(name: str) -> str:
    """Match the SQL slug generation logic (unaccent + lower + dashes)."""
    accent_map = {
        'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
        'à': 'a', 'â': 'a', 'ä': 'a', 'á': 'a',
        'ù': 'u', 'û': 'u', 'ü': 'u',
        'î': 'i', 'ï': 'i', 'ô': 'o', 'ö': 'o',
        'ç': 'c', 'ñ': 'n',
        'É': 'E', 'È': 'E', 'Ê': 'E',
        'À': 'A', 'Â': 'A', 'Ç': 'C',
        '’': '',
    }
    s = name
    for k, v in accent_map.items():
        s = s.replace(k, v)
    s = re.sub(r'[^a-zA-Z0-9\s-]', '', s)
    s = re.sub(r'\s+', '-', s)
    return s.lower().strip('-')


def map_stage(round_str: str) -> str:
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
        'growth equity': 'growth',
        'bridge': 'bridge',
        'debt': 'debt',
        'grant': 'grant',
        'ipo': 'ipo',
        'secondary': 'secondary',
        'business angel': 'pre_seed',
        'angel': 'pre_seed',
    }
    return mapping.get(r, 'other')


def parse_amount(val: str):
    if not val:
        return None
    try:
        return float(str(val).replace(',', '').replace(' ', '').strip())
    except (ValueError, TypeError):
        return None


def to_millions(amount_raw):
    if amount_raw is None:
        return None
    return round(amount_raw / AMOUNT_DIVISOR, 2)


def parse_csv_list(val: str) -> list[str]:
    if not val:
        return []
    return [i.strip() for i in val.split(',') if i.strip()]


def normalize_city(raw: str) -> str | None:
    """Extract the actual city from values like
    'Palaiseau, Ile-de-France, France, Europe' -> 'Palaiseau'.
    Plain 'Paris' stays 'Paris'."""
    if not raw:
        return None
    head = raw.split(',', 1)[0].strip()
    return head or None


def write_sql(path: Path, body: str) -> None:
    path.write_text(body, encoding='utf-8')
    print(f"  wrote {path} ({path.stat().st_size:,} bytes)")


def main() -> None:
    with open(INPUT) as f:
        rows = list(csv.DictReader(f))
    print(f"Read {len(rows)} rows from {INPUT}")

    orgs: dict[str, dict] = {}
    cities_set: set[str] = set()
    sectors_set: set[str] = set()
    investor_names_set: set[str] = set()

    for row in rows:
        name = (row.get('Startup') or '').strip()
        if not name:
            continue
        slug = slugify(name)
        if not slug:
            continue

        siren = (row.get('SIREN') or '').strip() or None
        if siren and not siren.isdigit():
            siren = None

        website = (row.get('Website') or '').strip() or None
        description = (row.get('Description') or '').strip() or None
        city = normalize_city(row.get('City') or '')

        if slug not in orgs:
            orgs[slug] = {
                'name': name, 'slug': slug, 'siren': siren,
                'website': website, 'description': description, 'city': city,
            }
        else:
            cur = orgs[slug]
            if siren and not cur.get('siren'):
                cur['siren'] = siren
            if website and not cur.get('website'):
                cur['website'] = website
            if description and not cur.get('description'):
                cur['description'] = description
            if city and not cur.get('city'):
                cur['city'] = city

        if city:
            cities_set.add(city)
        for sec in parse_csv_list(row.get('Assigned Sectors') or ''):
            sectors_set.add(sec)
        for inv in parse_csv_list(row.get('Investor Names') or ''):
            investor_names_set.add(inv)

    cities_list = sorted(cities_set)
    sectors_list = sorted(sectors_set)
    investors_list = sorted(investor_names_set)

    print(f"Unique orgs: {len(orgs)}")
    print(f"Unique cities: {len(cities_list)}")
    print(f"Unique sectors: {len(sectors_list)}")
    print(f"Unique investors: {len(investors_list)}")

    # Payloads
    orgs_json = [
        {'name': o['name'], 'website': o['website'], 'description': o['description'],
         'siren': o['siren'], 'city': o['city']}
        for o in orgs.values()
    ]
    legal_json = [
        {'name': o['name'], 'siren': o['siren']}
        for o in orgs.values() if o['siren']
    ]
    cities_json = [{'name': c} for c in cities_list]
    sectors_json = [{'name': s} for s in sectors_list]
    investors_json = [{'name': i} for i in investors_list]
    org_city_json = [
        {'org_slug': o['slug'], 'city': o['city']}
        for o in orgs.values() if o['city']
    ]

    # Sector links: first listed = primary
    sector_links = []
    for row in rows:
        name = (row.get('Startup') or '').strip()
        if not name:
            continue
        slug = slugify(name)
        if not slug:
            continue
        sectors = parse_csv_list(row.get('Assigned Sectors') or '')
        for i, sec in enumerate(sectors):
            sector_links.append({
                'org_slug': slug, 'sector': sec, 'is_primary': i == 0,
            })

    # Dedup; respect "one primary sector per org" constraint
    seen_pairs = set()
    seen_primary_for_org = set()
    sector_links_dedup = []
    for link in sector_links:
        key = (link['org_slug'], link['sector'])
        if key in seen_pairs:
            continue
        seen_pairs.add(key)
        if link['is_primary']:
            if link['org_slug'] in seen_primary_for_org:
                link = {**link, 'is_primary': False}
            else:
                seen_primary_for_org.add(link['org_slug'])
        sector_links_dedup.append(link)

    # Funding rounds
    rounds_json = []
    for row in rows:
        name = (row.get('Startup') or '').strip()
        if not name:
            continue
        slug = slugify(name)
        amount_raw = parse_amount(row.get('Money Raised Euros') or '')
        amount_millions = to_millions(amount_raw)
        stage = map_stage(row.get('Round') or '')
        date = (row.get('Date') or '').strip() or None
        rounds_json.append({
            'org_slug': slug, 'stage': stage,
            'amount_eur': amount_millions, 'announced_date': date,
        })

    # Round investors (first listed = lead)
    round_investors_json = []
    seen_round_invs = set()
    for row in rows:
        name = (row.get('Startup') or '').strip()
        investors_str = (row.get('Investor Names') or '').strip()
        if not name or not investors_str:
            continue
        slug = slugify(name)
        date = (row.get('Date') or '').strip() or None
        amount_raw = parse_amount(row.get('Money Raised Euros') or '')
        amount_millions = to_millions(amount_raw)
        for i, inv in enumerate(parse_csv_list(investors_str)):
            # Dedup on the same key the SQL JOIN uses to find a funding_round
            # plus the investor name. Two source rows that map to the same
            # funding_round with the same investor would otherwise produce
            # duplicate (funding_round_id, investor_id) inserts.
            key = (slug, date, amount_millions, inv)
            if key in seen_round_invs:
                continue
            seen_round_invs.add(key)
            round_investors_json.append({
                'org_slug': slug, 'announced_date': date,
                'amount_eur': amount_millions, 'investor_name': inv,
                'is_lead': i == 0,
            })

    print(f"Sector links: {len(sector_links_dedup)}")
    print(f"Rounds: {len(rounds_json)}")
    print(f"Investor participations: {len(round_investors_json)}")

    OUT_DIR.mkdir(parents=True, exist_ok=True)

    def jdump(payload):
        return json.dumps(payload, ensure_ascii=False)

    print(f"\nWriting to {OUT_DIR}/")

    # 01a_cities.sql
    write_sql(OUT_DIR / '01a_cities.sql', f"""CREATE EXTENSION IF NOT EXISTS "unaccent";
-- Step 1: Create cities that don't exist yet ({len(cities_list)})
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json${jdump(cities_json)}$json$
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

    # 01b_sectors.sql
    write_sql(OUT_DIR / '01b_sectors.sql', f"""CREATE EXTENSION IF NOT EXISTS "unaccent";
-- Step 2: Create sectors that don't exist yet ({len(sectors_list)})
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json${jdump(sectors_json)}$json$
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

    # 01c_organizations.sql
    write_sql(OUT_DIR / '01c_organizations.sql', f"""CREATE EXTENSION IF NOT EXISTS "unaccent";
-- Step 3: Create organizations (upsert by slug; enrich missing fields)
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json${jdump(orgs_json)}$json$
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

    # 01d_legal_entities.sql
    write_sql(OUT_DIR / '01d_legal_entities.sql', f"""CREATE EXTENSION IF NOT EXISTS "unaccent";
-- Step 4: Create legal_entities for orgs with SIREN ({len(legal_json)})
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json${jdump(legal_json)}$json$
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

    # 01e_org_cities.sql
    write_sql(OUT_DIR / '01e_org_cities.sql', f"""CREATE EXTENSION IF NOT EXISTS "unaccent";
-- Step 5: Link organizations to cities ({len(org_city_json)})
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json${jdump(org_city_json)}$json$
  ) AS (org_slug TEXT, city TEXT)
)
UPDATE organizations o
SET city_id = c.id, updated_at = NOW()
FROM source s
JOIN cities c ON c.slug = lower(regexp_replace(regexp_replace(unaccent(s.city), '[^a-zA-Z0-9\\s-]', '', 'g'), '\\s+', '-', 'g'))
WHERE o.slug = s.org_slug AND o.city_id IS NULL;
""")

    # 01f_org_sectors.sql
    write_sql(OUT_DIR / '01f_org_sectors.sql', f"""CREATE EXTENSION IF NOT EXISTS "unaccent";
-- Step 6: Link organizations to sectors ({len(sector_links_dedup)})
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json${jdump(sector_links_dedup)}$json$
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

    # 01g_funding_rounds.sql
    write_sql(OUT_DIR / '01g_funding_rounds.sql', f"""CREATE EXTENSION IF NOT EXISTS "unaccent";
-- Step 7: Create funding_rounds ({len(rounds_json)})
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json${jdump(rounds_json)}$json$
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

    # 01h_investor_orgs.sql
    write_sql(OUT_DIR / '01h_investor_orgs.sql', f"""CREATE EXTENSION IF NOT EXISTS "unaccent";
-- Step 8: Create investor organizations ({len(investors_list)})
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json${jdump(investors_json)}$json$
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

    # 01i_round_investors.sql
    write_sql(OUT_DIR / '01i_round_investors.sql', f"""CREATE EXTENSION IF NOT EXISTS "unaccent";
-- Step 9: Link investors to funding rounds ({len(round_investors_json)})
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json${jdump(round_investors_json)}$json$
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
ON CONFLICT (funding_round_id, investor_id) DO NOTHING;
""")

    print()
    print(f"Done. Wrote 9 SQL files to {OUT_DIR}/")


if __name__ == '__main__':
    main()
