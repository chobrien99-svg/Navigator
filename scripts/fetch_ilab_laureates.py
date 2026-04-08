#!/usr/bin/env python3
"""
Fetch all i-Lab laureates from the MESR API and generate a SQL migration.

Creates:
  1. A 'i-Lab' program + yearly editions in program_editions
  2. Organizations for each laureate company
  3. Legal entities where SIREN/SIRET available
  4. People for each laureate (founder/candidate)
  5. Organization-people links (founder role)
  6. Program_organizations linking companies to yearly editions

Usage:
  python3 scripts/fetch_ilab_laureates.py
"""

import json
import re
import urllib.request
import time
from pathlib import Path

API_BASE = "https://data.enseignementsup-recherche.gouv.fr/api/explore/v2.1"
DATASET = "fr-esr-laureats-concours-national-i-lab"
PAGE_SIZE = 100

OUTPUT_DIR = Path(__file__).parent.parent / "supabase" / "migrations" / "phase9"
OUTPUT_FILE = OUTPUT_DIR / "01_import_ilab_laureates.sql"


def fetch_all_records():
    """Fetch all records from the MESR API with pagination."""
    records = []
    offset = 0

    while True:
        url = (
            f"{API_BASE}/catalog/datasets/{DATASET}/records"
            f"?limit={PAGE_SIZE}&offset={offset}"
            f"&order_by=annee_de_concours%20DESC"
        )
        print(f"  Fetching offset={offset}...")
        req = urllib.request.Request(url)
        with urllib.request.urlopen(req, timeout=30) as resp:
            data = json.loads(resp.read().decode("utf-8"))

        batch = data.get("results", [])
        records.extend(batch)

        total = data.get("total_count", 0)
        offset += PAGE_SIZE

        if offset >= total or len(batch) == 0:
            break
        time.sleep(0.3)  # be polite to the API

    print(f"  Fetched {len(records)} total records (API reports {total})")
    return records


def slugify(name):
    """Generate a URL-safe slug."""
    accent_map = {
        'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
        'à': 'a', 'â': 'a', 'ä': 'a', 'á': 'a',
        'ù': 'u', 'û': 'u', 'ü': 'u',
        'î': 'i', 'ï': 'i',
        'ô': 'o', 'ö': 'o',
        'ç': 'c', 'ñ': 'n',
        'É': 'E', 'È': 'E', 'Ê': 'E',
        'À': 'A', 'Â': 'A',
        'Ç': 'C', 'Ü': 'U', 'Ö': 'O',
    }
    s = name
    for k, v in accent_map.items():
        s = s.replace(k, v)
    s = re.sub(r'[^a-zA-Z0-9\s-]', '', s)
    s = re.sub(r'\s+', '-', s)
    return s.lower().strip('-')


def person_slug(first_name, last_name):
    """Generate slug for a person."""
    parts = []
    if first_name:
        parts.append(first_name.strip())
    if last_name:
        parts.append(last_name.strip())
    return slugify(" ".join(parts)) if parts else None


def clean_website(url):
    """Clean up website URL."""
    if not url:
        return None
    url = url.strip()
    if not url.startswith("http"):
        url = "https://" + url
    return url


def main():
    print("Fetching i-Lab laureates from MESR API...")
    records = fetch_all_records()

    # Save raw data for reference
    raw_path = Path(__file__).parent.parent / "data" / "ilab_laureates.json"
    raw_path.parent.mkdir(parents=True, exist_ok=True)
    with open(raw_path, "w", encoding="utf-8") as f:
        json.dump(records, f, ensure_ascii=False, indent=2)
    print(f"Saved raw data to {raw_path}")

    # Collect unique years
    years = set()
    for r in records:
        year = r.get("annee_de_concours")
        if year:
            try:
                years.add(int(year))
            except (ValueError, TypeError):
                pass
    years = sorted(years)
    print(f"Years: {min(years)}–{max(years)} ({len(years)} editions)")

    # Deduplicate organizations by SIREN first, then by slug
    orgs = {}  # slug -> org data
    siren_to_slug = {}  # siren -> slug (for dedup)
    for r in records:
        company = (r.get("libelle_entreprise") or "").strip()
        if not company:
            continue
        siren = (r.get("ndeg_siren") or "").strip() or None
        slug = slugify(company)
        if not slug:
            continue

        # Dedup by SIREN if available
        if siren and siren in siren_to_slug:
            continue
        if slug in orgs:
            # Update with richer data if available
            if siren and not orgs[slug].get("siren"):
                orgs[slug]["siren"] = siren
                orgs[slug]["siret"] = (r.get("ndeg_siret") or "").strip() or None
            if not orgs[slug].get("website"):
                orgs[slug]["website"] = clean_website(r.get("site_web_entreprise"))
            if not orgs[slug].get("description") and r.get("moto"):
                orgs[slug]["description"] = r["moto"]
            continue

        org = {
            "name": company,
            "slug": slug,
            "siren": siren,
            "siret": (r.get("ndeg_siret") or "").strip() or None,
            "website": clean_website(r.get("site_web_entreprise")),
            "description": r.get("moto") or None,
            "region": (r.get("region") or "").strip() or None,
        }
        orgs[slug] = org
        if siren:
            siren_to_slug[siren] = slug

    print(f"Unique organizations: {len(orgs)}")

    # Deduplicate people
    people = {}  # slug -> person data
    for r in records:
        last_name = (r.get("nom_du_laureat") or "").strip()
        first_name = (r.get("prenom_du_candidat") or "").strip()
        if not last_name:
            continue
        slug = person_slug(first_name, last_name)
        if not slug or slug in people:
            continue
        people[slug] = {
            "full_name": f"{first_name} {last_name}".strip(),
            "slug": slug,
            "first_name": first_name or None,
            "last_name": last_name or None,
        }

    print(f"Unique people: {len(people)}")

    # Build program_organizations entries
    program_entries = []  # (company_slug, year, grand_prix, domain)
    for r in records:
        company = (r.get("libelle_entreprise") or "").strip()
        year = r.get("annee_de_concours")
        if not company or not year:
            continue
        try:
            year = int(year)
        except (ValueError, TypeError):
            continue
        slug = slugify(company)
        siren = (r.get("ndeg_siren") or "").strip() or None
        # Use SIREN dedup
        if siren and siren in siren_to_slug:
            slug = siren_to_slug[siren]
        grand_prix = r.get("grand_prix") or None
        domain = (r.get("domaine_technologique") or "").strip() or None
        program_entries.append((slug, year, grand_prix, domain))

    # Build org-people links
    org_people_links = []  # (company_slug, person_slug, year)
    for r in records:
        company = (r.get("libelle_entreprise") or "").strip()
        last_name = (r.get("nom_du_laureat") or "").strip()
        first_name = (r.get("prenom_du_candidat") or "").strip()
        year = r.get("annee_de_concours")
        if not company or not last_name:
            continue
        c_slug = slugify(company)
        siren = (r.get("ndeg_siren") or "").strip() or None
        if siren and siren in siren_to_slug:
            c_slug = siren_to_slug[siren]
        p_slug = person_slug(first_name, last_name)
        if c_slug and p_slug:
            org_people_links.append((c_slug, p_slug))

    # Deduplicate links
    org_people_links = list(set(org_people_links))
    print(f"Org-people links: {len(org_people_links)}")
    print(f"Program entries: {len(program_entries)}")

    # Generate SQL
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    sql_parts = []

    sql_parts.append("""-- =============================================================================
-- i-Lab Laureates Import (from MESR API)
-- =============================================================================
-- Fetched from: data.enseignementsup-recherche.gouv.fr
-- Dataset: fr-esr-laureats-concours-national-i-lab
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "unaccent";
""")

    # Step 1: Create program + editions
    edition_values = ",\n  ".join(
        f"('i-Lab — {y}', 'i-lab-{y}', {y}, '{y}')"
        for y in years
    )
    sql_parts.append(f"""
-- Step 1: Create i-Lab program and yearly editions
INSERT INTO programs (
  id, name, slug, program_type, description, country, source_url,
  created_at, updated_at
)
VALUES (
  uuid_generate_v4(),
  'i-Lab',
  'i-lab',
  'competition',
  'Concours national d''aide à la création d''entreprises de technologies innovantes. Deep-tech startup competition run by Bpifrance since 1999.',
  'France',
  'https://www.bpifrance.fr/catalogue-offres/soutien-a-linnovation/concours-dinnovation-i-lab',
  NOW(), NOW()
)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO program_editions (
  id, program_id, name, slug, year, cohort_label,
  created_at, updated_at
)
SELECT
  uuid_generate_v4(),
  p.id,
  e.name,
  e.slug,
  e.year,
  e.cohort_label,
  NOW(), NOW()
FROM programs p
CROSS JOIN (VALUES
  {edition_values}
) AS e(name, slug, year, cohort_label)
WHERE p.slug = 'i-lab'
ON CONFLICT DO NOTHING;
""")

    # Step 2: Organizations
    org_json = [
        {
            "name": o["name"],
            "website": o["website"],
            "description": o["description"],
            "siren": o["siren"],
        }
        for o in orgs.values()
    ]
    sql_parts.append(f"""
-- Step 2: Create organizations ({len(org_json)} companies)
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
  'ilab',
  s.siren,
  NOW(), NOW()
FROM source s
ON CONFLICT (slug) DO UPDATE SET
  website = COALESCE(organizations.website, EXCLUDED.website),
  description = COALESCE(organizations.description, EXCLUDED.description),
  updated_at = NOW();
""")

    # Step 3: Legal entities
    legal_json = [
        {"name": o["name"], "siren": o["siren"], "siret": o["siret"]}
        for o in orgs.values()
        if o["siren"]
    ]
    if legal_json:
        sql_parts.append(f"""
-- Step 3: Create legal_entities ({len(legal_json)} with SIREN)
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
  NOW(), NOW()
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

    # Step 4: People
    people_json = list(people.values())
    sql_parts.append(f"""
-- Step 4: Create people ({len(people_json)} laureates)
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json${json.dumps(people_json, ensure_ascii=False)}$json$
  ) AS (full_name TEXT, slug TEXT, first_name TEXT, last_name TEXT)
)
INSERT INTO people (
  id, full_name, slug, first_name, last_name,
  created_at, updated_at
)
SELECT
  uuid_generate_v4(),
  s.full_name,
  s.slug,
  s.first_name,
  s.last_name,
  NOW(), NOW()
FROM source s
ON CONFLICT (slug) DO NOTHING;
""")

    # Step 5: Organization-people links
    op_json = [
        {"org_slug": cs, "person_slug": ps}
        for cs, ps in org_people_links
    ]
    sql_parts.append(f"""
-- Step 5: Link people to organizations ({len(op_json)} links)
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json${json.dumps(op_json, ensure_ascii=False)}$json$
  ) AS (org_slug TEXT, person_slug TEXT)
)
INSERT INTO organization_people (
  id, organization_id, person_id, role, is_founder, is_current,
  created_at, updated_at
)
SELECT
  uuid_generate_v4(),
  o.id,
  p.id,
  'founder',
  TRUE,
  TRUE,
  NOW(), NOW()
FROM source s
JOIN organizations o ON o.slug = s.org_slug
JOIN people p ON p.slug = s.person_slug
ON CONFLICT DO NOTHING;
""")

    # Step 6: Program organizations
    pe_json = [
        {
            "org_slug": slug,
            "year": year,
            "grand_prix": gp,
            "domain": dom,
        }
        for slug, year, gp, dom in program_entries
    ]
    sql_parts.append(f"""
-- Step 6: Link organizations to i-Lab editions ({len(pe_json)} entries)
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json${json.dumps(pe_json, ensure_ascii=False)}$json$
  ) AS (org_slug TEXT, year INT, grand_prix TEXT, domain TEXT)
)
INSERT INTO program_organizations (
  id, program_edition_id, organization_id, group_label,
  membership_role, notes, legacy_source,
  created_at, updated_at
)
SELECT
  uuid_generate_v4(),
  pe.id,
  o.id,
  s.domain,
  CASE WHEN s.grand_prix IS NOT NULL THEN 'Grand Prix' ELSE 'Laureate' END,
  s.grand_prix,
  'ilab',
  NOW(), NOW()
FROM source s
JOIN organizations o ON o.slug = s.org_slug
JOIN program_editions pe ON pe.slug = 'i-lab-' || s.year::TEXT
ON CONFLICT (program_edition_id, organization_id) DO NOTHING;
""")

    # Write output
    full_sql = "\n".join(sql_parts)
    OUTPUT_FILE.write_text(full_sql, encoding="utf-8")

    print(f"\nWritten migration to {OUTPUT_FILE}")
    print(f"  Years: {min(years)}–{max(years)}")
    print(f"  Organizations: {len(orgs)}")
    print(f"  Legal entities: {len(legal_json)}")
    print(f"  People: {len(people)}")
    print(f"  Org-people links: {len(org_people_links)}")
    print(f"  Program entries: {len(program_entries)}")


if __name__ == "__main__":
    main()
