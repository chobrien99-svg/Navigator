#!/usr/bin/env python3
"""
Convert the Crunchbase 2022 funding CSV to a Phase 13 split SQL migration.

Input:
  data/funding_2022_crunchbase.csv
    columns: Organization Name, Organization Location, Funding Type,
             Money Raised, Money Raised Currency, Announced Date,
             Organization Website, Description, Investor Names,
             Sectors, SIREN
  data/crunchbase_sector_mapping.tsv
    columns: count, crunchbase_term, canonical_sector

Output: supabase/migrations/phase13/
  01a_cities.sql
  01b_sectors.sql
  01c_organizations.sql
  01d_legal_entities.sql
  01e_org_cities.sql
  01f_org_sectors.sql
  01g_funding_rounds.sql
  01h_investor_orgs.sql
  01i_round_investors.sql

Cleanup rules applied:
  * Drop the Institut Mérieux row (uploaded by mistake)
  * Drop description text (Crunchbase copyrighted)
  * Convert USD/GBP amounts to EUR using 2022 annual averages
  * Map Crunchbase sectors → Navigator canonical sectors via TSV
    (unmapped sectors are silently dropped per user instruction)
  * If Funding Type is blank, derive from amount:
      > €100M       → growth
      > €50M ≤ 100M → series_c
      > €20M ≤ 50M  → series_b
      > €8M  ≤ 20M  → series_a
      > €2M  ≤ 8M   → seed
      ≤ €2M         → pre_seed
      amount blank  → undisclosed

source_name = 'funding_deals_2022_crunchbase'
"""

import csv
import json
import re
import unicodedata
from pathlib import Path

INPUT = Path('data/funding_2022_crunchbase.csv')
MAPPING = Path('data/crunchbase_sector_mapping.tsv')
OUT_DIR = Path('supabase/migrations/phase13')
SOURCE_NAME = 'funding_deals_2022_crunchbase'

# 2022 annual average FX rates (ECB / oanda)
USD_TO_EUR = 0.95
GBP_TO_EUR = 1.17

# Stage thresholds (amount in millions of EUR)
STAGE_THRESHOLDS = [
    (100.0, 'growth'),
    (50.0,  'series_c'),
    (20.0,  'series_b'),
    (8.0,   'series_a'),
    (2.0,   'seed'),
]
DEFAULT_SMALL_STAGE = 'pre_seed'  # ≤ €2M
DEFAULT_NO_AMOUNT_STAGE = 'undisclosed'

# Explicit Crunchbase Funding Type → our funding_stage enum
FT_MAP = {
    'pre-seed': 'pre_seed',
    'seed': 'seed',
    'series a': 'series_a',
    'series b': 'series_b',
    'series c': 'series_c',
    'series d': 'series_d',
    'series e': 'series_e',
    'series f': 'series_f',
    'growth equity': 'growth',
    'private equity': 'growth',
    'angel': 'pre_seed',
    'debt financing': 'debt',
    'convertible note': 'bridge',
    'post-ipo equity': 'ipo',
    'post-ipo debt': 'debt',
    'secondary market': 'secondary',
    'grant': 'grant',
    'corporate round': 'other',
    'product crowdfunding': 'other',
    'equity crowdfunding': 'other',
    'non-equity assistance': 'grant',
}


def slugify(name: str) -> str:
    s = unicodedata.normalize('NFKD', name)
    s = ''.join(c for c in s if not unicodedata.combining(c))
    s = re.sub(r'[^a-zA-Z0-9\s-]', '', s)
    s = re.sub(r'\s+', '-', s)
    return s.lower().strip('-')


def normalize_city(raw: str) -> str | None:
    if not raw:
        return None
    head = raw.split(',', 1)[0].strip()
    return head or None


_LEGAL_SUFFIXES = {
    'llc', 'l.l.c.', 'inc', 'inc.', 'incorporated',
    'ltd', 'ltd.', 'limited',
    'lp', 'l.p.', 'llp', 'l.l.p.',
    'corp', 'corp.', 'corporation', 'co', 'co.', 'company',
    'gmbh', 'ag', 'bv', 'b.v.', 'nv', 'n.v.',
    'sa', 's.a.', 'sas', 's.a.s.', 'sarl', 's.a.r.l.', 'plc',
}


def parse_investor_list(val: str) -> list[str]:
    if not val:
        return []
    out: list[str] = []
    for tok in (t.strip() for t in val.split(',')):
        if not tok:
            continue
        if out and tok.lower() in _LEGAL_SUFFIXES:
            out[-1] = f"{out[-1]}, {tok}"
        else:
            out.append(tok)
    return out


def parse_amount(val: str) -> float | None:
    if not val:
        return None
    try:
        return float(str(val).replace(',', '').replace(' ', '').strip())
    except (ValueError, TypeError):
        return None


def to_eur(amount_raw: float | None, currency: str) -> float | None:
    """Convert raw currency amount to EUR. Returns None if amount is None
    or currency is unknown/missing."""
    if amount_raw is None:
        return None
    c = (currency or '').strip().upper()
    if c == 'EUR':
        return amount_raw
    if c == 'USD':
        return amount_raw * USD_TO_EUR
    if c == 'GBP':
        return amount_raw * GBP_TO_EUR
    return None  # unknown currency: skip the amount rather than guess


def to_millions(eur: float | None) -> float | None:
    if eur is None:
        return None
    return round(eur / 1_000_000, 2)


def derive_stage(funding_type: str, amount_millions: float | None) -> str:
    """Return our funding_stage enum value."""
    ft = (funding_type or '').strip().lower()
    if ft in FT_MAP:
        return FT_MAP[ft]
    if ft:
        return 'other'  # unknown non-empty value
    # Blank Funding Type — apply amount thresholds
    if amount_millions is None:
        return DEFAULT_NO_AMOUNT_STAGE
    for threshold, stage in STAGE_THRESHOLDS:
        if amount_millions > threshold:
            return stage
    return DEFAULT_SMALL_STAGE


def load_sector_mapping() -> dict[str, str]:
    """Returns {crunchbase_term_lower: canonical_sector}."""
    out = {}
    with open(MAPPING) as f:
        reader = csv.DictReader(f, delimiter='\t')
        for r in reader:
            term = (r.get('crunchbase_term') or '').strip()
            mapped = (r.get('canonical_sector') or '').strip()
            if term and mapped:
                out[term.lower()] = mapped
    return out


def map_sectors(raw: str, mapping: dict[str, str]) -> list[str]:
    """Return de-duplicated canonical sectors, preserving order
    (first occurrence wins → that becomes primary downstream)."""
    out = []
    seen = set()
    for s in (raw or '').split(','):
        s = s.strip()
        if not s:
            continue
        canonical = mapping.get(s.lower())
        if canonical and canonical not in seen:
            out.append(canonical)
            seen.add(canonical)
    return out


def main() -> None:
    with open(INPUT) as f:
        rows = list(csv.DictReader(f))

    # Drop the Institut Mérieux PE row (uploaded by mistake)
    rows = [r for r in rows
            if not (r['Organization Name'].strip() == 'Institut Merieux'
                    and r['Funding Type'].strip() == 'Private Equity')]

    sector_mapping = load_sector_mapping()

    print(f"Read {len(rows)} rows from {INPUT}")
    print(f"Sector mapping: {len(sector_mapping)} terms")

    orgs: dict[str, dict] = {}
    cities_set: set[str] = set()
    sectors_set: set[str] = set()
    investor_names_set: set[str] = set()

    # Pre-walk to gather entities
    for row in rows:
        name = (row.get('Organization Name') or '').strip()
        if not name:
            continue
        slug = slugify(name)
        if not slug:
            continue

        siren = (row.get('SIREN') or '').strip() or None
        if siren and not siren.isdigit():
            siren = None

        website = (row.get('Organization Website') or '').strip() or None
        city = normalize_city(row.get('Organization Location') or '')
        # description intentionally NOT carried over (Crunchbase copyrighted)

        if slug not in orgs:
            orgs[slug] = {
                'name': name, 'slug': slug, 'siren': siren,
                'website': website, 'city': city,
            }
        else:
            cur = orgs[slug]
            if siren and not cur.get('siren'):
                cur['siren'] = siren
            if website and not cur.get('website'):
                cur['website'] = website
            if city and not cur.get('city'):
                cur['city'] = city

        if city:
            cities_set.add(city)
        for sec in map_sectors(row.get('Sectors') or '', sector_mapping):
            sectors_set.add(sec)
        for inv in parse_investor_list(row.get('Investor Names') or ''):
            investor_names_set.add(inv)

    cities_list = sorted(cities_set)
    sectors_list = sorted(sectors_set)
    investors_list = sorted(investor_names_set)

    print(f"Unique orgs: {len(orgs)}")
    print(f"Unique cities: {len(cities_list)}")
    print(f"Unique sectors: {len(sectors_list)}")
    print(f"Unique investors: {len(investors_list)}")

    # Build payloads
    orgs_json = [
        {'name': o['name'], 'website': o['website'],
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

    # Sector links — first canonical sector for an org is primary
    sector_links = []
    for row in rows:
        name = (row.get('Organization Name') or '').strip()
        if not name:
            continue
        slug = slugify(name)
        canon = map_sectors(row.get('Sectors') or '', sector_mapping)
        for i, s in enumerate(canon):
            sector_links.append({
                'org_slug': slug, 'sector': s, 'is_primary': i == 0,
            })

    # Dedup sector links + respect one-primary-per-org constraint
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

    # Funding rounds (one per row)
    rounds_json = []
    # Bookkeeping for stage source
    stage_explicit = 0
    stage_derived = 0
    stage_undisclosed = 0
    for row in rows:
        name = (row.get('Organization Name') or '').strip()
        if not name:
            continue
        slug = slugify(name)
        amount_raw = parse_amount(row.get('Money Raised') or '')
        amount_eur = to_eur(amount_raw, row.get('Money Raised Currency') or '')
        amount_millions = to_millions(amount_eur)
        funding_type = (row.get('Funding Type') or '').strip()
        stage = derive_stage(funding_type, amount_millions)
        if funding_type:
            stage_explicit += 1
        elif stage == 'undisclosed':
            stage_undisclosed += 1
        else:
            stage_derived += 1
        date = (row.get('Announced Date') or '').strip() or None
        rounds_json.append({
            'org_slug': slug, 'stage': stage,
            'amount_eur': amount_millions, 'announced_date': date,
        })

    print(f"Stages: explicit={stage_explicit}  derived-from-amount={stage_derived}  undisclosed={stage_undisclosed}")

    # Round-investor links (dedup on (slug, date, amount, inv_slug-equivalent name))
    round_invs = []
    seen_round_invs = set()
    for row in rows:
        name = (row.get('Organization Name') or '').strip()
        investors_str = (row.get('Investor Names') or '').strip()
        if not name or not investors_str:
            continue
        slug = slugify(name)
        date = (row.get('Announced Date') or '').strip() or None
        amount_raw = parse_amount(row.get('Money Raised') or '')
        amount_eur = to_eur(amount_raw, row.get('Money Raised Currency') or '')
        amount_millions = to_millions(amount_eur)
        for i, inv in enumerate(parse_investor_list(investors_str)):
            key = (slug, date, amount_millions, inv)
            if key in seen_round_invs:
                continue
            seen_round_invs.add(key)
            round_invs.append({
                'org_slug': slug, 'announced_date': date,
                'amount_eur': amount_millions, 'investor_name': inv,
                'is_lead': i == 0,
            })

    print(f"Sector links: {len(sector_links_dedup)}")
    print(f"Rounds: {len(rounds_json)}")
    print(f"Investor participations: {len(round_invs)}")

    def write_sql(path: Path, body: str) -> None:
        path.write_text(body, encoding='utf-8')
        print(f"  wrote {path} ({path.stat().st_size:,} bytes)")

    def j(p):
        return json.dumps(p, ensure_ascii=False)

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    print(f"\nWriting to {OUT_DIR}/")

    # 01a_cities.sql
    write_sql(OUT_DIR / '01a_cities.sql', f"""CREATE EXTENSION IF NOT EXISTS "unaccent";
-- Step 1: Create cities that don't exist yet ({len(cities_list)})
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json${j(cities_json)}$json$
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

    # 01b_sectors.sql (includes EdTech if any rows mapped to it)
    write_sql(OUT_DIR / '01b_sectors.sql', f"""CREATE EXTENSION IF NOT EXISTS "unaccent";
-- Step 2: Create sectors that don't exist yet ({len(sectors_list)})
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json${j(sectors_json)}$json$
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

    # 01c_organizations.sql (no description — Crunchbase copyrighted)
    write_sql(OUT_DIR / '01c_organizations.sql', f"""CREATE EXTENSION IF NOT EXISTS "unaccent";
-- Step 3: Create organizations (upsert by slug; enrich missing fields)
-- Note: description intentionally NOT inserted (Crunchbase copyrighted)
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json${j(orgs_json)}$json$
  ) AS (name TEXT, website TEXT, siren TEXT, city TEXT)
)
INSERT INTO organizations (
  id, name, slug, organization_type, website, status, country,
  legacy_source, legacy_id, created_at, updated_at
)
SELECT
  uuid_generate_v4(),
  s.name,
  lower(regexp_replace(regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\\s-]', '', 'g'), '\\s+', '-', 'g')),
  'startup'::organization_type,
  s.website,
  'active'::organization_status,
  'France',
  '{SOURCE_NAME}',
  s.siren,
  NOW(), NOW()
FROM source s
ON CONFLICT (slug) DO UPDATE SET
  website = COALESCE(organizations.website, EXCLUDED.website),
  legacy_id = COALESCE(organizations.legacy_id, EXCLUDED.legacy_id),
  updated_at = NOW();
""")

    # 01d_legal_entities.sql
    write_sql(OUT_DIR / '01d_legal_entities.sql', f"""CREATE EXTENSION IF NOT EXISTS "unaccent";
-- Step 4: Create legal_entities for orgs with SIREN ({len(legal_json)})
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json${j(legal_json)}$json$
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
    $json${j(org_city_json)}$json$
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
    $json${j(sector_links_dedup)}$json$
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
    $json${j(rounds_json)}$json$
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
    $json${j(investors_json)}$json$
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

    # 01i_round_investors.sql (DISTINCT ON guard)
    write_sql(OUT_DIR / '01i_round_investors.sql', f"""CREATE EXTENSION IF NOT EXISTS "unaccent";
-- Step 9: Link investors to funding rounds ({len(round_invs)})
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json${j(round_invs)}$json$
  ) AS (org_slug TEXT, announced_date TEXT, amount_eur NUMERIC, investor_name TEXT, is_lead BOOLEAN)
),
joined AS (
  SELECT DISTINCT ON (fr.id, inv_org.id)
    fr.id          AS funding_round_id,
    inv_org.id     AS investor_id,
    s.is_lead,
    s.investor_name
  FROM source s
  JOIN organizations o ON o.slug = s.org_slug
  JOIN organizations inv_org ON inv_org.slug = lower(regexp_replace(regexp_replace(unaccent(s.investor_name), '[^a-zA-Z0-9\\s-]', '', 'g'), '\\s+', '-', 'g'))
  JOIN funding_rounds fr ON fr.organization_id = o.id
    AND fr.source_name = '{SOURCE_NAME}'
    AND fr.announced_date IS NOT DISTINCT FROM NULLIF(s.announced_date, '')::DATE
    AND fr.amount_eur IS NOT DISTINCT FROM s.amount_eur
  ORDER BY fr.id, inv_org.id, s.is_lead DESC
)
INSERT INTO funding_round_investors (
  id, funding_round_id, investor_id, is_lead, investor_name, created_at
)
SELECT
  uuid_generate_v4(),
  funding_round_id,
  investor_id,
  is_lead,
  investor_name,
  NOW()
FROM joined
ON CONFLICT (funding_round_id, investor_id) DO NOTHING;
""")

    print()
    print(f"Done. Wrote 9 SQL files to {OUT_DIR}/")


if __name__ == '__main__':
    main()
