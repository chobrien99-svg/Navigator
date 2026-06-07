#!/usr/bin/env python3
"""
Convert a Crunchbase per-year funding CSV to a split SQL migration.

Usage (defaults to 2022 = the original target):
  python3 scripts/convert_crunchbase.py                 # 2022
  python3 scripts/convert_crunchbase.py --year 2021
  python3 scripts/convert_crunchbase.py --year 2020 --usd-eur 0.88 --gbp-eur 1.13

Per-year FX defaults below — pass --usd-eur / --gbp-eur / --mad-eur /
--aud-eur to override. Input/output paths default to
data/funding_<year>_crunchbase.csv → supabase/migrations/phase<N>/ where
N is derived from year (2022→13, 2021→15, 2020→16, 2019→17 — adjust
with --phase if needed).

Sector mapping: data/crunchbase_sector_mapping.tsv (shared across years).
Column name auto-detection: handles both "Description" / "Organization
Description" and "Sectors" / "Organization Industries".

Cleanup rules applied:
  * Drop description text (Crunchbase copyrighted)
  * Drop rows passed via --drop-row "Name:Funding Type"
  * Convert non-EUR amounts using per-year averages
  * Map Crunchbase sectors → Navigator canonical sectors via TSV
    (unmapped sectors silently dropped)
  * If Funding Type is blank, derive from amount:
      > €100M → growth, > €50M → series_c, > €20M → series_b,
      > €8M → series_a, > €2M → seed, ≤ €2M → pre_seed,
      blank amount → undisclosed
  * Within-batch dedup on (org_slug, announced_date, amount_eur)
"""

import argparse
import csv
import json
import re
import unicodedata
from pathlib import Path

MAPPING = Path('data/crunchbase_sector_mapping.tsv')

# Per-year FX defaults (1 unit foreign currency → EUR), annual averages.
# Sources: ECB / oanda / IRS yearly averages for historical years.
YEAR_DEFAULTS = {
    2000: {'usd': 1.085, 'gbp': 1.640, 'mad': 0.107, 'aud': 0.629},
    2001: {'usd': 1.117, 'gbp': 1.608, 'mad': 0.109, 'aud': 0.578},
    2002: {'usd': 1.061, 'gbp': 1.591, 'mad': 0.105, 'aud': 0.578},
    2003: {'usd': 0.884, 'gbp': 1.445, 'mad': 0.091, 'aud': 0.577},
    2004: {'usd': 0.805, 'gbp': 1.474, 'mad': 0.090, 'aud': 0.593},
    2005: {'usd': 0.804, 'gbp': 1.463, 'mad': 0.090, 'aud': 0.613},
    2006: {'usd': 0.797, 'gbp': 1.467, 'mad': 0.090, 'aud': 0.600},
    2007: {'usd': 0.731, 'gbp': 1.462, 'mad': 0.089, 'aud': 0.613},
    2008: {'usd': 0.683, 'gbp': 1.258, 'mad': 0.088, 'aud': 0.580},
    2009: {'usd': 0.719, 'gbp': 1.123, 'mad': 0.089, 'aud': 0.567},
    2010: {'usd': 0.755, 'gbp': 1.166, 'mad': 0.090, 'aud': 0.694},
    2011: {'usd': 0.719, 'gbp': 1.152, 'mad': 0.089, 'aud': 0.742},
    2012: {'usd': 0.778, 'gbp': 1.234, 'mad': 0.092, 'aud': 0.806},
    2013: {'usd': 0.753, 'gbp': 1.178, 'mad': 0.090, 'aud': 0.728},
    2014: {'usd': 0.754, 'gbp': 1.241, 'mad': 0.090, 'aud': 0.680},
    2015: {'usd': 0.901, 'gbp': 1.378, 'mad': 0.092, 'aud': 0.678},
    2016: {'usd': 0.904, 'gbp': 1.224, 'mad': 0.092, 'aud': 0.672},
    2017: {'usd': 0.886, 'gbp': 1.142, 'mad': 0.090, 'aud': 0.679},
    2018: {'usd': 0.847, 'gbp': 1.130, 'mad': 0.090, 'aud': 0.633},
    2019: {'usd': 0.893, 'gbp': 1.140, 'mad': 0.093, 'aud': 0.621},
    2020: {'usd': 0.876, 'gbp': 1.125, 'mad': 0.093, 'aud': 0.604},
    2021: {'usd': 0.845, 'gbp': 1.163, 'mad': 0.094, 'aud': 0.636},
    2022: {'usd': 0.951, 'gbp': 1.174, 'mad': 0.091, 'aud': 0.660},
    2023: {'usd': 0.924, 'gbp': 1.150, 'mad': 0.092, 'aud': 0.614},
}

# Phase folder convention so we don't trample existing migrations
YEAR_TO_PHASE = {
    2022: 13, 2021: 15, 2020: 16, 2019: 17, 2023: 18,
    2018: 19, 2017: 20, 2016: 21, 2015: 22, 2014: 23,
    2013: 24, 2012: 25, 2011: 26, 2010: 27,
    # earlier years: --phase flag to override
}

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
    'series g': 'growth',   # very late stage, no enum past F
    'series h': 'growth',
    'series i': 'growth',
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

# Crunchbase Funding Types that mean "unknown stage" — treat as blank and let
# the amount-based thresholds derive a stage instead of falling through to
# 'other'. Add new Crunchbase quirks here as we encounter them.
UNSPECIFIED_FT = {
    'venture round',
    'venture',
    'undisclosed',
    'funding round',
    'crowdfunding',  # often stage-agnostic
}

# Crunchbase column name aliases (older exports vs. newer exports)
DESCRIPTION_COLUMNS = ('Description', 'Organization Description')
SECTOR_COLUMNS = ('Sectors', 'Organization Industries')


def _first_col(row: dict, candidates: tuple[str, ...]) -> str | None:
    for col in candidates:
        if col in row:
            return col
    return None


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


def to_eur(amount_raw: float | None, currency: str, fx: dict) -> float | None:
    """Convert raw currency amount to EUR using `fx` rate dict
    (keys: 'usd','gbp','mad','aud'). Returns None if amount is None or
    currency is unknown/missing."""
    if amount_raw is None:
        return None
    c = (currency or '').strip().upper()
    if c == 'EUR':
        return amount_raw
    rate = fx.get(c.lower())
    if rate is None:
        return None  # unknown currency: skip the amount rather than guess
    return amount_raw * rate


def to_millions(eur: float | None) -> float | None:
    if eur is None:
        return None
    return round(eur / 1_000_000, 2)


def derive_stage(funding_type: str, amount_millions: float | None) -> str:
    """Return our funding_stage enum value."""
    ft = (funding_type or '').strip().lower()
    if ft in FT_MAP:
        return FT_MAP[ft]
    # "Venture Round", "Funding Round", etc. — Crunchbase placeholders.
    # Treat the same as blank: derive from amount.
    if ft and ft not in UNSPECIFIED_FT:
        return 'other'  # unknown non-empty value
    # Blank or unspecified Funding Type — apply amount thresholds
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


def _parse_args():
    p = argparse.ArgumentParser(description=__doc__,
                                formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument('--year', type=int, default=2022)
    p.add_argument('--input', type=Path, default=None)
    p.add_argument('--output', type=Path, default=None,
                   help='Output dir (default: supabase/migrations/phaseN/)')
    p.add_argument('--phase', type=int, default=None,
                   help='Phase folder number; default looked up by year')
    p.add_argument('--source-name', default=None,
                   help='funding_rounds.source_name (default: funding_deals_<year>_crunchbase)')
    p.add_argument('--usd-eur', type=float, default=None)
    p.add_argument('--gbp-eur', type=float, default=None)
    p.add_argument('--mad-eur', type=float, default=None)
    p.add_argument('--aud-eur', type=float, default=None)
    p.add_argument('--drop-row', action='append', default=[],
                   help='Skip a row by "Org Name:Funding Type" (repeatable)')
    return p.parse_args()


def main() -> None:
    args = _parse_args()
    year = args.year
    defaults = YEAR_DEFAULTS.get(year, YEAR_DEFAULTS[2022])
    fx = {
        'usd': args.usd_eur if args.usd_eur is not None else defaults['usd'],
        'gbp': args.gbp_eur if args.gbp_eur is not None else defaults['gbp'],
        'mad': args.mad_eur if args.mad_eur is not None else defaults['mad'],
        'aud': args.aud_eur if args.aud_eur is not None else defaults['aud'],
    }
    input_path = args.input or Path(f'data/funding_{year}_crunchbase.csv')
    phase = args.phase or YEAR_TO_PHASE.get(year, 13)
    out_dir = args.output or Path(f'supabase/migrations/phase{phase}')
    source_name = args.source_name or f'funding_deals_{year}_crunchbase'

    print(f"Year: {year}  FX: {fx}")
    print(f"Input: {input_path}  Output: {out_dir}  source_name: {source_name!r}")

    with open(input_path) as f:
        rows = list(csv.DictReader(f))

    if rows:
        sector_col = _first_col(rows[0], SECTOR_COLUMNS)
        if not sector_col:
            raise SystemExit(f"No sector column found; expected one of {SECTOR_COLUMNS}")
        print(f"Sector column: {sector_col!r}")
    else:
        raise SystemExit(f"No rows in {input_path}")

    # Apply --drop-row filters (e.g. "Institut Merieux:Private Equity")
    drop_pairs = {
        tuple(s.split(':', 1)) for s in args.drop_row if ':' in s
    }
    if drop_pairs:
        before = len(rows)
        rows = [r for r in rows
                if (r['Organization Name'].strip(), r['Funding Type'].strip()) not in drop_pairs]
        print(f"Dropped {before - len(rows)} rows via --drop-row")

    sector_mapping = load_sector_mapping()

    print(f"Read {len(rows)} rows from {input_path}")
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
        for sec in map_sectors(row.get(sector_col) or '', sector_mapping):
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
        canon = map_sectors(row.get(sector_col) or '', sector_mapping)
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

    # Funding rounds (one per row, deduped on the same key the SQL join uses:
    # (org_slug, announced_date, amount_eur). The Crunchbase export contains
    # rows duplicated on that key — collapsing them here keeps 01g from
    # inserting within-batch duplicates the NOT EXISTS guard can't catch.)
    rounds_json = []
    seen_rounds = set()
    # Bookkeeping for stage source
    stage_explicit = 0
    stage_derived = 0
    stage_undisclosed = 0
    dropped_dupe_rounds = 0
    for row in rows:
        name = (row.get('Organization Name') or '').strip()
        if not name:
            continue
        slug = slugify(name)
        amount_raw = parse_amount(row.get('Money Raised') or '')
        amount_eur = to_eur(amount_raw, row.get('Money Raised Currency') or '', fx)
        amount_millions = to_millions(amount_eur)
        date = (row.get('Announced Date') or '').strip() or None
        round_key = (slug, date, amount_millions)
        if round_key in seen_rounds:
            dropped_dupe_rounds += 1
            continue
        seen_rounds.add(round_key)
        funding_type = (row.get('Funding Type') or '').strip()
        stage = derive_stage(funding_type, amount_millions)
        if funding_type:
            stage_explicit += 1
        elif stage == 'undisclosed':
            stage_undisclosed += 1
        else:
            stage_derived += 1
        rounds_json.append({
            'org_slug': slug, 'stage': stage,
            'amount_eur': amount_millions, 'announced_date': date,
        })
    if dropped_dupe_rounds:
        print(f"Dropped {dropped_dupe_rounds} within-batch duplicate rounds "
              f"(same org+date+amount)")

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
        amount_eur = to_eur(amount_raw, row.get('Money Raised Currency') or '', fx)
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

    out_dir.mkdir(parents=True, exist_ok=True)
    print(f"\nWriting to {out_dir}/")

    # 01a_cities.sql
    write_sql(out_dir / '01a_cities.sql', f"""CREATE EXTENSION IF NOT EXISTS "unaccent";
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
    write_sql(out_dir / '01b_sectors.sql', f"""CREATE EXTENSION IF NOT EXISTS "unaccent";
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
    write_sql(out_dir / '01c_organizations.sql', f"""CREATE EXTENSION IF NOT EXISTS "unaccent";
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
  '{source_name}',
  s.siren,
  NOW(), NOW()
FROM source s
ON CONFLICT (slug) DO UPDATE SET
  website = COALESCE(organizations.website, EXCLUDED.website),
  legacy_id = COALESCE(organizations.legacy_id, EXCLUDED.legacy_id),
  updated_at = NOW();
""")

    # 01d_legal_entities.sql
    write_sql(out_dir / '01d_legal_entities.sql', f"""CREATE EXTENSION IF NOT EXISTS "unaccent";
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
    write_sql(out_dir / '01e_org_cities.sql', f"""CREATE EXTENSION IF NOT EXISTS "unaccent";
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
    write_sql(out_dir / '01f_org_sectors.sql', f"""CREATE EXTENSION IF NOT EXISTS "unaccent";
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
    write_sql(out_dir / '01g_funding_rounds.sql', f"""CREATE EXTENSION IF NOT EXISTS "unaccent";
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
  '{source_name}',
  NOW()
FROM source s
JOIN organizations o ON o.slug = s.org_slug
WHERE NOT EXISTS (
  SELECT 1 FROM funding_rounds fr
  WHERE fr.organization_id = o.id
  AND fr.source_name = '{source_name}'
  AND fr.announced_date IS NOT DISTINCT FROM NULLIF(s.announced_date, '')::DATE
  AND fr.amount_eur IS NOT DISTINCT FROM s.amount_eur
);
""")

    # 01h_investor_orgs.sql
    write_sql(out_dir / '01h_investor_orgs.sql', f"""CREATE EXTENSION IF NOT EXISTS "unaccent";
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
  '{source_name}',
  NOW(), NOW()
FROM source s
ON CONFLICT (slug) DO NOTHING;
""")

    # 01i_round_investors.sql (DISTINCT ON guard)
    write_sql(out_dir / '01i_round_investors.sql', f"""CREATE EXTENSION IF NOT EXISTS "unaccent";
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
    AND fr.source_name = '{source_name}'
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
    print(f"Done. Wrote 9 SQL files to {out_dir}/")


if __name__ == '__main__':
    main()
