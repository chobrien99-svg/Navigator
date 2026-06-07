#!/usr/bin/env python3
"""
Generate a SIREN-based backfill that adds program_organizations rows for
i-Lab and i-Nov laureates whose SIREN matches an existing org in the DB
(via legal_entities), but who weren't linked at original import time.

iPhD laureates are skipped — the dataset has no SIRENs.

Output: supabase/migrations/phase12/05_backfill_program_memberships_by_siren.sql

For each laureate (siren, year, project, group_label):
  • Resolve the program_edition by slug: 'i-lab-YYYY' or 'i-nov-YYYY'
  • Join to legal_entities by SIREN → organization
  • INSERT program_organizations
      ON CONFLICT (program_edition_id, organization_id) DO NOTHING

One org with multiple SIRENs (e.g. after a name change) will still match
because the join goes through legal_entities, not organizations.legacy_id.
Multiple orgs with the same SIREN will all get the program link (these
are duplicates and should be merged separately).
"""

import json
from pathlib import Path

ILAB = Path('data/ilab_laureates.json')
INOV = Path('data/inov_laureates.json')
OUT = Path('supabase/migrations/phase12/05_backfill_program_memberships_by_siren.sql')


def _norm_siren(v) -> str | None:
    if not v:
        return None
    s = str(v).strip()
    return s if s.isdigit() and len(s) == 9 else None


def main() -> None:
    ilab = json.load(open(ILAB))
    inov = json.load(open(INOV))

    # ── i-Lab payload ────────────────────────────────────────────────────────
    # Source fields: ndeg_siren, annee_de_concours, projet, grand_prix
    seen = set()
    ilab_rows = []
    for r in ilab:
        siren = _norm_siren(r.get('ndeg_siren'))
        year_str = (r.get('annee_de_concours') or '').strip()
        if not siren or not year_str.isdigit():
            continue
        year = int(year_str)
        key = (siren, year)
        if key in seen:
            continue
        seen.add(key)
        ilab_rows.append({
            'siren': siren,
            'edition_slug': f'i-lab-{year}',
            'group_label': 'Grand prix' if r.get('grand_prix') == 'Grand prix' else None,
            'notes': (r.get('projet') or '').strip() or None,
        })

    # ── i-Nov payload ────────────────────────────────────────────────────────
    # Source fields: siren, datepublication (YYYY-MM-DD), projet, vague
    seen = set()
    inov_rows = []
    for r in inov:
        siren = _norm_siren(r.get('siren'))
        date = (r.get('datepublication') or '').strip()
        year = int(date[:4]) if date[:4].isdigit() else None
        if not siren or not year:
            continue
        key = (siren, year)
        if key in seen:
            continue
        seen.add(key)
        inov_rows.append({
            'siren': siren,
            'edition_slug': f'i-nov-{year}',
            'group_label': (r.get('vague') or '').strip() or None,
            'notes': (r.get('projet') or '').strip() or None,
        })

    print(f"i-Lab tuples: {len(ilab_rows)}")
    print(f"i-Nov tuples: {len(inov_rows)}")

    payload = ilab_rows + inov_rows

    def j(p):
        return json.dumps(p, ensure_ascii=False)

    sql = f"""-- =============================================================================
-- Backfill program_organizations by SIREN match (i-Lab + i-Nov)
-- =============================================================================
-- For each (laureate SIREN, edition year) tuple, find every organization in
-- our DB whose legal_entities row carries that SIREN, and ensure there's a
-- program_organizations row linking that org to the i-Lab / i-Nov edition
-- for that year. Idempotent via ON CONFLICT.
--
-- iPhD is omitted (dataset has no SIRENs).
--
-- Source files:
--   data/ilab_laureates.json  → {len(ilab_rows)} tuples
--   data/inov_laureates.json  → {len(inov_rows)} tuples
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "unaccent";

WITH src AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json${j(payload)}$json$
  ) AS (siren TEXT, edition_slug TEXT, group_label TEXT, notes TEXT)
),
joined AS (
  SELECT DISTINCT ON (pe.id, le.organization_id)
    pe.id                AS program_edition_id,
    le.organization_id   AS organization_id,
    src.group_label      AS group_label,
    src.notes            AS notes
  FROM src
  JOIN program_editions pe ON pe.slug = src.edition_slug
  JOIN legal_entities   le ON le.siren = src.siren
  ORDER BY pe.id, le.organization_id, (src.group_label IS NOT NULL) DESC
)
INSERT INTO program_organizations (
  id, program_edition_id, organization_id, group_label, notes,
  legacy_source, created_at, updated_at
)
SELECT
  uuid_generate_v4(),
  program_edition_id,
  organization_id,
  group_label,
  notes,
  'siren_backfill',
  NOW(), NOW()
FROM joined
ON CONFLICT (program_edition_id, organization_id) DO NOTHING;
"""

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(sql, encoding='utf-8')
    print(f"Wrote {OUT} ({OUT.stat().st_size:,} bytes)")


if __name__ == '__main__':
    main()
