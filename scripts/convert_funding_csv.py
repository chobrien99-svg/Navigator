#!/usr/bin/env python3
"""
Convert 2024 funding deals CSV to SQL migration.
Creates organizations, legal_entities, funding_rounds, and funding_round_investors.
"""

import csv
import json
import re
import sys
from pathlib import Path

# EUR/USD rate for 2024
EUR_USD_RATE = 0.92
EUR_CHF_RATE = 1.06  # approximate
EUR_MAD_RATE = 0.092  # approximate

# DB stores amounts in millions
AMOUNT_DIVISOR = 1_000_000

def slugify(name):
    """Match the SQL slug generation logic."""
    # Remove accents (simplified - handle common French chars)
    accent_map = {
        'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
        'à': 'a', 'â': 'a', 'ä': 'a',
        'ù': 'u', 'û': 'u', 'ü': 'u',
        'î': 'i', 'ï': 'i',
        'ô': 'o', 'ö': 'o',
        'ç': 'c', 'ñ': 'n',
        'É': 'E', 'È': 'E', 'Ê': 'E',
        'À': 'A', 'Â': 'A',
        'Ç': 'C',
    }
    s = name
    for k, v in accent_map.items():
        s = s.replace(k, v)
    # Remove non-alphanumeric except spaces and hyphens
    s = re.sub(r'[^a-zA-Z0-9\s-]', '', s)
    # Replace spaces with hyphens
    s = re.sub(r'\s+', '-', s)
    return s.lower()

def escape_sql(s):
    """Escape single quotes for SQL."""
    if s is None:
        return None
    return s.replace("'", "''")

def map_funding_stage(funding_type):
    """Map spreadsheet funding type to DB enum."""
    mapping = {
        'Pre-Seed': 'pre_seed',
        'Seed': 'seed',
        'Series A': 'series_a',
        'Series B': 'series_b',
        'Series C': 'series_c',
        'Series D': 'series_d',
        'Business Angel': 'pre_seed',
    }
    return mapping.get(funding_type, 'other')

def convert_to_eur(amount_str, currency):
    """Convert amount to EUR. Returns amount in raw EUR (not millions)."""
    if not amount_str or not amount_str.strip():
        return None
    try:
        amount = float(amount_str)
    except ValueError:
        return None

    if currency == 'EUR' or not currency:
        return amount
    elif currency == 'USD':
        return amount * EUR_USD_RATE
    elif currency == 'CHF':
        return amount * EUR_CHF_RATE
    elif currency == 'MAD':
        return amount * EUR_MAD_RATE
    else:
        return amount * EUR_USD_RATE  # default to USD rate

def main():
    csv_path = Path(__file__).parent.parent / 'data' / 'funding_2024.csv'
    output_path = Path(__file__).parent.parent / 'supabase' / 'migrations' / 'phase8' / '01_import_2024_funding_deals.sql'
    output_path.parent.mkdir(parents=True, exist_ok=True)

    rows = []
    with open(csv_path, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            name = row.get('name', '').strip()
            if not name:
                continue
            rows.append(row)

    print(f"Read {len(rows)} rows from CSV")

    # Deduplicate orgs by slug
    orgs = {}  # slug -> org data
    for row in rows:
        name = row['name'].strip()
        slug = slugify(name)
        if slug not in orgs:
            orgs[slug] = {
                'name': name,
                'slug': slug,
                'city': row.get('City', '').strip(),
                'sectors': row.get('Sectors', '').strip(),
                'website': row.get('website', '').strip(),
                'description': row.get('description', '').strip(),
                'siren': row.get('SIREN', '').strip(),
                'siret': row.get('SIRET', '').strip(),
            }

    print(f"Unique organizations: {len(orgs)}")

    # Build SQL
    sql_parts = []
    sql_parts.append("""-- =============================================================================
-- 2024 Funding Deals Import
-- =============================================================================
-- Imports ~650 funding deals from the 2024 spreadsheet.
-- Creates organizations, legal_entities, funding_rounds, and investors.
-- Currency conversion: USD->EUR at 0.92 fixed rate.
-- Amounts stored in millions (DB convention).
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "unaccent";
""")

    # Step 1: Organizations
    org_json = []
    for slug, org in orgs.items():
        obj = {
            'name': org['name'],
            'website': org['website'] or None,
            'description': org['description'] or None,
            'siren': org['siren'] or None,
        }
        org_json.append(obj)

    sql_parts.append(f"""
-- Step 1: Create organizations
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json${json.dumps(org_json, ensure_ascii=False)}$json$
  ) AS (name TEXT, website TEXT, description TEXT, siren TEXT)
)
INSERT INTO organizations (
  id, name, slug, organization_type, description, website, status, country,
  legacy_source, legacy_id, created_at, updated_at
)
SELECT
  uuid_generate_v4(),
  s.name,
  lower(regexp_replace(
    regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\\s-]', '', 'g'),
    '\\s+', '-', 'g'
  )),
  'startup'::organization_type,
  s.description,
  s.website,
  'active'::organization_status,
  'France',
  'funding_deals_2024',
  s.siren,
  NOW(),
  NOW()
FROM source s
ON CONFLICT (slug) DO UPDATE SET
  website = COALESCE(organizations.website, EXCLUDED.website),
  description = COALESCE(organizations.description, EXCLUDED.description),
  updated_at = NOW();
""")

    # Step 2: Legal entities
    legal_json = []
    for slug, org in orgs.items():
        if org['siren']:
            legal_json.append({
                'name': org['name'],
                'siren': org['siren'],
                'siret': org['siret'] or None,
            })

    if legal_json:
        sql_parts.append(f"""
-- Step 2: Create legal_entities where SIREN data exists
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json${json.dumps(legal_json, ensure_ascii=False)}$json$
  ) AS (name TEXT, siren TEXT, siret TEXT)
)
INSERT INTO legal_entities (
  id, organization_id, legal_name, siren, siret, country, is_primary,
  created_at, updated_at
)
SELECT
  uuid_generate_v4(),
  o.id,
  s.name,
  s.siren,
  s.siret,
  'France',
  TRUE,
  NOW(),
  NOW()
FROM source s
JOIN organizations o ON o.slug = lower(regexp_replace(
  regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\\s-]', '', 'g'),
  '\\s+', '-', 'g'
))
WHERE NOT EXISTS (
  SELECT 1 FROM legal_entities le
  WHERE le.organization_id = o.id AND le.siren = s.siren
);
""")

    # Step 3: Funding rounds
    round_json = []
    for i, row in enumerate(rows):
        name = row['name'].strip()
        amount_raw = convert_to_eur(row.get('Amount', ''), row.get('Currency', '').strip())
        amount_millions = round(amount_raw / AMOUNT_DIVISOR, 6) if amount_raw else None
        stage = map_funding_stage(row.get('Funding Type', '').strip())
        announced = row.get('Announced Date', '').strip() or None
        currency = row.get('Currency', '').strip() or None
        original_amount = None
        try:
            original_amount = float(row.get('Amount', ''))
        except (ValueError, TypeError):
            pass

        round_json.append({
            'idx': i,
            'name': name,
            'stage': stage,
            'amount_eur': amount_millions,
            'currency_original': currency,
            'amount_original': original_amount,
            'announced_date': announced,
            'investors': row.get('Investors', '').strip() or None,
        })

    sql_parts.append(f"""
-- Step 3: Create funding rounds
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json${json.dumps(round_json, ensure_ascii=False)}$json$
  ) AS (idx INT, name TEXT, stage TEXT, amount_eur NUMERIC, currency_original TEXT,
        amount_original NUMERIC, announced_date TEXT, investors TEXT)
)
INSERT INTO funding_rounds (
  id, organization_id, stage, amount_eur, currency_original, amount_original,
  announced_date, is_estimated, is_verified, source_name, notes,
  created_at
)
SELECT
  uuid_generate_v4(),
  o.id,
  s.stage::funding_stage,
  s.amount_eur,
  s.currency_original,
  s.amount_original,
  s.announced_date::DATE,
  CASE WHEN s.currency_original != 'EUR' AND s.amount_eur IS NOT NULL THEN TRUE ELSE FALSE END,
  FALSE,
  'funding_deals_2024',
  CASE WHEN s.currency_original = 'USD' THEN 'Converted from USD at 0.92 EUR/USD'
       WHEN s.currency_original = 'CHF' THEN 'Converted from CHF at 1.06 EUR/CHF'
       WHEN s.currency_original = 'MAD' THEN 'Converted from MAD at 0.092 EUR/MAD'
       ELSE NULL END,
  NOW()
FROM source s
JOIN organizations o ON o.slug = lower(regexp_replace(
  regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\\s-]', '', 'g'),
  '\\s+', '-', 'g'
));
""")

    # Step 4: Collect unique investor names and create them as organizations
    all_investor_names = set()
    for row in rows:
        investors_str = row.get('Investors', '').strip()
        if not investors_str:
            continue
        for inv in investors_str.split(','):
            inv = inv.strip()
            if inv:
                all_investor_names.add(inv)

    investor_org_json = [{'name': name} for name in sorted(all_investor_names)]

    sql_parts.append(f"""
-- Step 4a: Create investor organizations
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json${json.dumps(investor_org_json, ensure_ascii=False)}$json$
  ) AS (name TEXT)
)
INSERT INTO organizations (
  id, name, slug, organization_type, status, country,
  legacy_source, created_at, updated_at
)
SELECT
  uuid_generate_v4(),
  s.name,
  lower(regexp_replace(
    regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\\s-]', '', 'g'),
    '\\s+', '-', 'g'
  )),
  'investor'::organization_type,
  'active'::organization_status,
  'France',
  'funding_deals_2024',
  NOW(),
  NOW()
FROM source s
ON CONFLICT (slug) DO NOTHING;
""")

    # Step 4b: Funding round investors
    sql_parts.append("""
-- Step 4b: Create funding round investors
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$""")

    investor_json = []
    for row in rows:
        investors_str = row.get('Investors', '').strip()
        if not investors_str:
            continue
        name = row['name'].strip()
        announced = row.get('Announced Date', '').strip() or None
        amount_raw = convert_to_eur(row.get('Amount', ''), row.get('Currency', '').strip())
        amount_millions = round(amount_raw / AMOUNT_DIVISOR, 6) if amount_raw else None

        # Split investors
        investors = [inv.strip() for inv in investors_str.split(',') if inv.strip()]
        for j, inv in enumerate(investors):
            investor_json.append({
                'org_name': name,
                'announced_date': announced,
                'amount_eur': amount_millions,
                'investor_name': inv,
                'is_lead': j == 0,  # first listed investor assumed lead
            })

    sql_parts.append(json.dumps(investor_json, ensure_ascii=False))
    sql_parts.append("""$json$
  ) AS (org_name TEXT, announced_date TEXT, amount_eur NUMERIC, investor_name TEXT, is_lead BOOLEAN)
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
JOIN organizations o ON o.slug = lower(regexp_replace(
  regexp_replace(unaccent(s.org_name), '[^a-zA-Z0-9\\s-]', '', 'g'),
  '\\s+', '-', 'g'
))
JOIN organizations inv_org ON inv_org.slug = lower(regexp_replace(
  regexp_replace(unaccent(s.investor_name), '[^a-zA-Z0-9\\s-]', '', 'g'),
  '\\s+', '-', 'g'
))
JOIN funding_rounds fr ON fr.organization_id = o.id
  AND fr.source_name = 'funding_deals_2024'
  AND (
    (fr.announced_date::TEXT = s.announced_date OR (fr.announced_date IS NULL AND s.announced_date IS NULL))
    AND (fr.amount_eur = s.amount_eur OR (fr.amount_eur IS NULL AND s.amount_eur IS NULL))
  );
""")

    full_sql = '\n'.join(sql_parts)
    output_path.write_text(full_sql, encoding='utf-8')
    print(f"Written migration to {output_path}")
    print(f"  Organizations: {len(orgs)}")
    print(f"  Legal entities: {len(legal_json)}")
    print(f"  Funding rounds: {len(round_json)}")
    print(f"  Investor entries: {len(investor_json)}")

if __name__ == '__main__':
    main()
