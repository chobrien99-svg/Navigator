#!/usr/bin/env python3
"""
Generate a migration that backfills 40 SIRENs for French Tech Next 40/120
companies that were missing them, and renames 7 orgs whose names have
changed since the original cohort entry (e.g. blade → Shadow, lunchr → Swile).

Input CSV columns: name, slug, website, cohorts, groups, SIREN, note
Output: supabase/migrations/phase12/03_backfill_french_tech_sirens.sql
"""

import csv
import json
from pathlib import Path

CSV = Path('/root/.claude/uploads/e8f5df9c-1bb5-48e2-b92b-3fa824db714a/6d3acadc-Supabase_Snippet_French_Tech_Next_40_120_Without_SIREN__Supabase_Snippet_French_Tech_Next_40_120_Without_SIREN.csv')
OUT = Path('supabase/migrations/phase12/03_backfill_french_tech_sirens.sql')


def main() -> None:
    with open(CSV) as f:
        rows = list(csv.DictReader(f))

    payload = []
    for r in rows:
        siren = (r.get('SIREN') or '').strip()
        slug = (r.get('slug') or '').strip()
        if not siren or not slug:
            continue
        if not siren.isdigit():
            continue
        website = (r.get('website') or '').strip()
        # CSV uses literal 'null' for missing websites
        if website.lower() == 'null':
            website = None
        payload.append({
            'slug': slug,
            'name': (r.get('name') or '').strip(),
            'website': website,
            'siren': siren,
        })

    print(f"Records: {len(payload)}")
    j = json.dumps(payload, ensure_ascii=False)

    sql = f"""-- =============================================================================
-- French Tech Next 40/120 — SIREN backfill ({len(payload)} records)
-- =============================================================================
-- For each company already in `organizations` (matched by slug):
--   1. Update name if the CSV name differs (handles 7 known renames)
--   2. Fill website if currently null
--   3. Mirror SIREN to organizations.legacy_id when null (breadcrumb)
--   4. Insert a legal_entities row with the SIREN (one per org)
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "unaccent";

-- ---- Source payload (used by all four steps below) --------------------------
-- (No CREATE TEMP TABLE — keep this re-runnable as a single statement block)

-- Step 1: Update organizations.name where the CSV's name differs
WITH src AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json${j}$json$
  ) AS (slug TEXT, name TEXT, website TEXT, siren TEXT)
)
UPDATE organizations o
SET name = src.name, updated_at = NOW()
FROM src
WHERE o.slug = src.slug
  AND o.name IS DISTINCT FROM src.name;

-- Step 2: Fill website where currently null
WITH src AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json${j}$json$
  ) AS (slug TEXT, name TEXT, website TEXT, siren TEXT)
)
UPDATE organizations o
SET website = src.website, updated_at = NOW()
FROM src
WHERE o.slug = src.slug
  AND o.website IS NULL
  AND src.website IS NOT NULL
  AND src.website <> '';

-- Step 3: Mirror SIREN to organizations.legacy_id when null
WITH src AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json${j}$json$
  ) AS (slug TEXT, name TEXT, website TEXT, siren TEXT)
)
UPDATE organizations o
SET legacy_id = src.siren, updated_at = NOW()
FROM src
WHERE o.slug = src.slug
  AND o.legacy_id IS NULL;

-- Step 4: Insert legal_entities rows (idempotent per org+siren)
WITH src AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json${j}$json$
  ) AS (slug TEXT, name TEXT, website TEXT, siren TEXT)
)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT
  uuid_generate_v4(),
  o.id,
  src.name,
  src.siren,
  'France',
  TRUE,
  NOW(), NOW()
FROM src
JOIN organizations o ON o.slug = src.slug
WHERE NOT EXISTS (
  SELECT 1 FROM legal_entities le
  WHERE le.organization_id = o.id AND le.siren = src.siren
);
"""

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(sql, encoding='utf-8')
    print(f"Wrote {OUT} ({OUT.stat().st_size:,} bytes)")


if __name__ == '__main__':
    main()
