#!/usr/bin/env python3
"""
Fetch i-Nov and i-PhD laureates from the MESR API and generate SQL migrations.

Usage:
  python3 scripts/fetch_inov_iphd.py
"""

import json
import re
import urllib.request
import time
from pathlib import Path

API_BASE = "https://data.enseignementsup-recherche.gouv.fr/api/explore/v2.1"
PAGE_SIZE = 100

OUTPUT_DIR = Path(__file__).parent.parent / "supabase" / "migrations" / "phase9"


def fetch_all(dataset_id):
    records = []
    offset = 0
    while True:
        url = f"{API_BASE}/catalog/datasets/{dataset_id}/records?limit={PAGE_SIZE}&offset={offset}"
        print(f"  Fetching {dataset_id} offset={offset}...")
        req = urllib.request.Request(url)
        with urllib.request.urlopen(req, timeout=30) as resp:
            data = json.loads(resp.read().decode("utf-8"))
        batch = data.get("results", [])
        records.extend(batch)
        total = data.get("total_count", 0)
        offset += PAGE_SIZE
        if offset >= total or len(batch) == 0:
            break
        time.sleep(0.3)
    print(f"  Total: {len(records)} (API reports {total})")
    return records


def slugify(name):
    accent_map = {
        'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
        'à': 'a', 'â': 'a', 'ä': 'a', 'á': 'a',
        'ù': 'u', 'û': 'u', 'ü': 'u',
        'î': 'i', 'ï': 'i', 'ô': 'o', 'ö': 'o',
        'ç': 'c', 'ñ': 'n',
        'É': 'E', 'È': 'E', 'Ê': 'E',
        'À': 'A', 'Â': 'A', 'Ç': 'C',
    }
    s = name
    for k, v in accent_map.items():
        s = s.replace(k, v)
    s = re.sub(r'[^a-zA-Z0-9\s-]', '', s)
    s = re.sub(r'\s+', '-', s)
    return s.lower().strip('-')


def person_slug(first_name, last_name):
    parts = [p.strip() for p in [first_name, last_name] if p and p.strip()]
    return slugify(" ".join(parts)) if parts else None


def clean_website(url):
    if not url:
        return None
    url = url.strip()
    if not url.startswith("http"):
        url = "https://" + url
    return url


def generate_inov(records):
    """Generate i-Nov migration."""
    # Collect years from 'datepublication' or 'vague'
    years = set()
    for r in records:
        dp = r.get("datepublication", "")
        if dp:
            try:
                years.add(int(dp[:4]))
            except (ValueError, TypeError):
                pass
    years = sorted(years)
    if not years:
        years = list(range(2018, 2026))
    print(f"  i-Nov years: {min(years)}–{max(years)}")

    # Deduplicate orgs
    orgs = {}
    for r in records:
        company = (r.get("entreprise") or "").strip()
        if not company:
            continue
        slug = slugify(company)
        if not slug or slug in orgs:
            if slug in orgs and r.get("siren") and not orgs[slug].get("siren"):
                orgs[slug]["siren"] = (r.get("siren") or "").strip()
            continue
        orgs[slug] = {
            "name": company,
            "siren": (r.get("siren") or "").strip() or None,
            "description": (r.get("entrepriseresume") or r.get("moto") or "").strip() or None,
            "region": (r.get("reg_nom") or "").strip() or None,
        }

    print(f"  Unique orgs: {len(orgs)}")

    # Program entries
    program_entries = []
    for r in records:
        company = (r.get("entreprise") or "").strip()
        if not company:
            continue
        slug = slugify(company)
        dp = r.get("datepublication", "")
        year = None
        if dp:
            try:
                year = int(dp[:4])
            except (ValueError, TypeError):
                pass
        if not year:
            continue
        thematique = (r.get("thematique") or "").strip() or None
        subvention = r.get("subvention")
        montant = r.get("montantprojet")
        notes_parts = []
        if montant:
            notes_parts.append(f"Project: €{montant:,.0f}")
        if subvention:
            notes_parts.append(f"Subsidy: €{subvention:,.0f}")
        notes = "; ".join(notes_parts) if notes_parts else None
        program_entries.append((slug, year, thematique, notes))

    # Legal entities
    legal_json = [
        {"name": o["name"], "siren": o["siren"]}
        for o in orgs.values() if o["siren"]
    ]

    # Build SQL
    sql = []
    sql.append("""-- =============================================================================
-- i-Nov Laureates Import (from MESR API)
-- =============================================================================
CREATE EXTENSION IF NOT EXISTS "unaccent";
""")

    # Program + editions
    edition_values = ",\n  ".join(
        f"('i-Nov — {y}', 'i-nov-{y}', {y}, '{y}')" for y in years
    )
    sql.append(f"""
-- Step 1: Create i-Nov program and editions
INSERT INTO programs (
  id, name, slug, program_type, description, country, source_url,
  created_at, updated_at
) VALUES (
  uuid_generate_v4(), 'i-Nov', 'i-nov', 'competition',
  'Concours d''innovation i-Nov, soutenu par Bpifrance et l''ADEME. Finances des projets innovants à fort potentiel pour l''économie française.',
  'France',
  'https://www.bpifrance.fr/catalogue-offres/soutien-a-linnovation/concours-dinnovation-i-nov',
  NOW(), NOW()
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO program_editions (id, program_id, name, slug, year, cohort_label, created_at, updated_at)
SELECT uuid_generate_v4(), p.id, e.name, e.slug, e.year, e.cohort_label, NOW(), NOW()
FROM programs p
CROSS JOIN (VALUES {edition_values}) AS e(name, slug, year, cohort_label)
WHERE p.slug = 'i-nov'
ON CONFLICT DO NOTHING;
""")

    # Organizations
    org_json = [{"name": o["name"], "description": o["description"], "siren": o["siren"]} for o in orgs.values()]
    sql.append(f"""
-- Step 2: Create organizations ({len(org_json)})
WITH source AS (
  SELECT * FROM json_populate_recordset(NULL::record,
    $json${json.dumps(org_json, ensure_ascii=False)}$json$
  ) AS (name TEXT, description TEXT, siren TEXT)
)
INSERT INTO organizations (id, name, slug, organization_type, description, status, country, legacy_source, legacy_id, created_at, updated_at)
SELECT uuid_generate_v4(), s.name,
  lower(regexp_replace(regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\\s-]', '', 'g'), '\\s+', '-', 'g')),
  'startup'::organization_type, s.description, 'active'::organization_status, 'France', 'inov', s.siren, NOW(), NOW()
FROM source s
ON CONFLICT (slug) DO UPDATE SET
  description = COALESCE(organizations.description, EXCLUDED.description),
  updated_at = NOW();
""")

    # Legal entities
    if legal_json:
        sql.append(f"""
-- Step 3: Legal entities ({len(legal_json)})
WITH source AS (
  SELECT * FROM json_populate_recordset(NULL::record,
    $json${json.dumps(legal_json, ensure_ascii=False)}$json$
  ) AS (name TEXT, siren TEXT)
)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, s.name, s.siren, 'France', TRUE, NOW(), NOW()
FROM source s
JOIN organizations o ON o.slug = lower(regexp_replace(regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\\s-]', '', 'g'), '\\s+', '-', 'g'))
WHERE NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = s.siren);
""")

    # Program organizations
    pe_json = [{"org_slug": s, "year": y, "thematique": t, "notes": n} for s, y, t, n in program_entries]
    sql.append(f"""
-- Step 4: Program memberships ({len(pe_json)})
WITH source AS (
  SELECT * FROM json_populate_recordset(NULL::record,
    $json${json.dumps(pe_json, ensure_ascii=False)}$json$
  ) AS (org_slug TEXT, year INT, thematique TEXT, notes TEXT)
)
INSERT INTO program_organizations (id, program_edition_id, organization_id, group_label, membership_role, notes, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), pe.id, o.id, s.thematique, 'Laureate', s.notes, 'inov', NOW(), NOW()
FROM source s
JOIN organizations o ON o.slug = s.org_slug
JOIN program_editions pe ON pe.slug = 'i-nov-' || s.year::TEXT
ON CONFLICT (program_edition_id, organization_id) DO NOTHING;
""")

    return "\n".join(sql)


def generate_iphd(records):
    """Generate i-PhD migration."""
    years = set()
    for r in records:
        m = r.get("millesime", "")
        if m:
            try:
                years.add(int(m))
            except (ValueError, TypeError):
                pass
    years = sorted(years)
    print(f"  i-PhD years: {min(years)}–{max(years)}")

    # People (i-PhD is academic — laureates are PhD candidates, not companies)
    people = {}
    program_entries = []
    for r in records:
        first = (r.get("prenom") or "").strip()
        last = (r.get("nom") or "").strip()
        if not last:
            continue
        slug = person_slug(first, last)
        if not slug:
            continue
        if slug not in people:
            people[slug] = {
                "full_name": f"{first} {last}".strip(),
                "slug": slug,
                "first_name": first or None,
                "last_name": last or None,
            }
        year = None
        try:
            year = int(r.get("millesime", ""))
        except (ValueError, TypeError):
            pass
        if not year:
            continue
        secteur = (r.get("secteur") or "").strip() or None
        resultat = (r.get("resultat") or "Laureate").strip()
        project = (r.get("acronyme_du_projet") or "").strip() or None
        program_entries.append((slug, year, secteur, resultat, project))

    print(f"  Unique people: {len(people)}")

    sql = []
    sql.append("""-- =============================================================================
-- i-PhD Laureates Import (from MESR API)
-- =============================================================================
CREATE EXTENSION IF NOT EXISTS "unaccent";
""")

    edition_values = ",\n  ".join(
        f"('i-PhD — {y}', 'i-phd-{y}', {y}, '{y}')" for y in years
    )
    sql.append(f"""
-- Step 1: Create i-PhD program and editions
INSERT INTO programs (id, name, slug, program_type, description, country, source_url, created_at, updated_at)
VALUES (
  uuid_generate_v4(), 'i-PhD', 'i-phd', 'competition',
  'Concours d''innovation i-PhD. Soutient des projets de recherche doctorale à fort potentiel de valorisation économique.',
  'France',
  'https://www.bpifrance.fr/catalogue-offres/soutien-a-linnovation/concours-dinnovation-i-phd',
  NOW(), NOW()
) ON CONFLICT (slug) DO NOTHING;

INSERT INTO program_editions (id, program_id, name, slug, year, cohort_label, created_at, updated_at)
SELECT uuid_generate_v4(), p.id, e.name, e.slug, e.year, e.cohort_label, NOW(), NOW()
FROM programs p
CROSS JOIN (VALUES {edition_values}) AS e(name, slug, year, cohort_label)
WHERE p.slug = 'i-phd'
ON CONFLICT DO NOTHING;
""")

    # People
    people_json = list(people.values())
    sql.append(f"""
-- Step 2: Create people ({len(people_json)})
WITH source AS (
  SELECT * FROM json_populate_recordset(NULL::record,
    $json${json.dumps(people_json, ensure_ascii=False)}$json$
  ) AS (full_name TEXT, slug TEXT, first_name TEXT, last_name TEXT)
)
INSERT INTO people (id, full_name, slug, first_name, last_name, has_phd, created_at, updated_at)
SELECT uuid_generate_v4(), s.full_name, s.slug, s.first_name, s.last_name, TRUE, NOW(), NOW()
FROM source s
ON CONFLICT (slug) DO UPDATE SET has_phd = TRUE;
""")

    # Note: i-PhD doesn't have companies, so we skip organization creation.
    # We store the program entries linked to a placeholder or skip org linkage.
    # For now, we'll just store the people and note the program participation in notes.

    return "\n".join(sql)


def main():
    print("=== i-Nov ===")
    inov_records = fetch_all("fr-esr-laureats-concours-i-nov")

    raw_path = Path(__file__).parent.parent / "data" / "inov_laureates.json"
    raw_path.parent.mkdir(parents=True, exist_ok=True)
    with open(raw_path, "w", encoding="utf-8") as f:
        json.dump(inov_records, f, ensure_ascii=False, indent=2)

    inov_sql = generate_inov(inov_records)
    inov_path = OUTPUT_DIR / "02_import_inov_laureates.sql"
    inov_path.write_text(inov_sql, encoding="utf-8")
    print(f"  Written to {inov_path}")

    print("\n=== i-PhD ===")
    iphd_records = fetch_all("fr-esr-laureats-concours-i-phd")

    raw_path2 = Path(__file__).parent.parent / "data" / "iphd_laureates.json"
    with open(raw_path2, "w", encoding="utf-8") as f:
        json.dump(iphd_records, f, ensure_ascii=False, indent=2)

    iphd_sql = generate_iphd(iphd_records)
    iphd_path = OUTPUT_DIR / "03_import_iphd_laureates.sql"
    iphd_path.write_text(iphd_sql, encoding="utf-8")
    print(f"  Written to {iphd_path}")


if __name__ == "__main__":
    main()
