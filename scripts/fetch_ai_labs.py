#!/usr/bin/env python3
"""
Identify France's AI research laboratories from the MESR Open Data API.

Queries the "Structures de recherche publiques actives" dataset (RNSR) and
cross-references with known AI lab identifiers to produce a comprehensive
list of laboratories conducting AI research in France.

Strategy:
  1. Fetch all lab-level structures (niveau >= 2) in the STIC domain
     (Sciences et technologies de l'information et de la communication).
  2. Fetch structures whose name contains AI-related keywords.
  3. Fetch structures in the Mathematics domain with informatics ERC panels.
  4. Deduplicate and merge results.
  5. Rank by relevance (name match, known lab, ERC panel PE6, etc.).
  6. Output a JSON file and a human-readable summary.

Creates:
  data/ai_labs_france.json  -- full structured data
  data/ai_labs_france.csv   -- summary table

Usage:
  python3 scripts/fetch_ai_labs.py                    # fetch from MESR API
  python3 scripts/fetch_ai_labs.py --local FILE.json  # process local RNSR dump
"""

import json
import csv
import re
import sys
import urllib.request
import urllib.parse
import time
from pathlib import Path

API_BASE = "https://data.enseignementsup-recherche.gouv.fr/api/explore/v2.1"
DATASET = "fr-esr-structures-recherche-publiques-actives"
PAGE_SIZE = 100

DATA_DIR = Path(__file__).parent.parent / "data"

# ── AI-related keywords to search in lab names ──────────────────────────
AI_NAME_KEYWORDS = [
    "intelligence artificielle", "artificial intelligence",
    "apprentissage automatique", "machine learning",
    "deep learning", "apprentissage profond",
    "vision par ordinateur", "computer vision",
    "traitement automatique des langues", "natural language",
    "robotique", "robotics",
    "data science", "science des donnees", "sciences du numerique",
]

CS_NAME_KEYWORDS = [
    "informatique", "numerique", "computer", "donnees", "data",
    "signal", "image", "traitement", "logiciel", "software",
    "algorithme", "optimisation", "calcul", "apprentissage",
]

# ── Known major French AI/CS labs by acronym ────────────────────────────
# These labs have significant AI research teams. Used to flag expected matches.
KNOWN_AI_LABS = {
    # CNRS INS2I major UMRs
    "IRISA", "IRIT", "LIP6", "LIRMM", "CRIStAL", "LIG", "LIRIS",
    "LORIA", "LaBRI", "LS2N", "LISN", "I3S", "LIP", "LAAS", "GREYC",
    "Lab-STICC", "LIMOS", "LIPN", "ISIR", "LIX", "CRAN", "LAMIH",
    "L2S", "GIPSA-lab", "DI ENS", "IRIF", "CMAP", "LMF", "LTCI",
    "LIGM", "LITIS", "LAMSADE", "CEDRIC", "LISIC", "LIA", "LATTICE",
    "XLIM", "ICube", "ETIS", "SAMOVAR", "DAVID", "IBISC", "LIASD",
    "CIAD", "CHArt", "ImViA", "LIFO", "Heudiasyc", "LJK", "VERIMAG",
    # Inria project-teams with AI focus
    "SIERRA", "MAASAI", "ACENTAURI", "REGALIA", "MLIA", "VALDA",
    "ARTISHAU",
}

# ── Private AI R&D labs in France (not in RNSR) ────────────────────────
# These are corporate research labs operating in France with AI focus.
# Source: JDN 2017 cartography + subsequent openings.
PRIVATE_AI_LABS = [
    # ── Original JDN 9 (2017) ───────────────────────────────────────────
    {"acronym": "Criteo AI Lab",    "name": "Criteo AI Lab",                                "parent_company": "Criteo",               "hq_country": "France",      "city": "Paris",           "year_opened": 2015},
    {"acronym": "CSL Sony",         "name": "Laboratoire scientifique Sony Computer",        "parent_company": "Sony",                 "hq_country": "Japon",       "city": "Paris",           "year_opened": 2006},
    {"acronym": "Factolab",         "name": "Factolab",                                     "parent_company": "Michelin",             "hq_country": "France",      "city": "Clermont-Ferrand", "year_opened": 2017},
    {"acronym": "FAIR Paris",       "name": "Facebook AI Research Paris",                    "parent_company": "Meta",                 "hq_country": "Etats-Unis",  "city": "Paris",           "year_opened": 2015},
    {"acronym": "Huawei MASL",      "name": "Mathematical and Algorithmic Sciences Lab",     "parent_company": "Huawei Technologies",  "hq_country": "Chine",       "city": "Boulogne-Billancourt", "year_opened": 2016},
    {"acronym": "MSFT-Inria",       "name": "Centre Microsoft Recherche-Inria",              "parent_company": "Microsoft",            "hq_country": "Etats-Unis",  "city": "Saclay",          "year_opened": 2006},
    {"acronym": "Orange Labs",      "name": "Orange Labs",                                   "parent_company": "Orange",               "hq_country": "France",      "city": "Chatillon",       "year_opened": 2007},
    {"acronym": "RIT Paris",        "name": "Rakuten Institute of Technology Paris",          "parent_company": "Rakuten",              "hq_country": "Japon",       "city": "Paris",           "year_opened": 2014},
    {"acronym": "XRCE",             "name": "Centre de Recherche Europe de Xerox (now Naver)","parent_company": "Naver Labs Europe",    "hq_country": "Corée du Sud","city": "Meylan",          "year_opened": 2017},
    # ── Post-2017 openings ──────────────────────────────────────────────
    {"acronym": "Google Brain Paris","name": "Google Brain / DeepMind Paris",                 "parent_company": "Alphabet (Google)",    "hq_country": "Etats-Unis",  "city": "Paris",           "year_opened": 2018},
    {"acronym": "Samsung AI Paris", "name": "Samsung AI Center Paris",                       "parent_company": "Samsung",              "hq_country": "Corée du Sud","city": "Paris",           "year_opened": 2018},
    {"acronym": "Fujitsu AI Lab",   "name": "Fujitsu AI Research Center",                    "parent_company": "Fujitsu",              "hq_country": "Japon",       "city": "Paris",           "year_opened": 2019},
    {"acronym": "Uber AI Paris",    "name": "Uber AI Labs Paris",                            "parent_company": "Uber",                 "hq_country": "Etats-Unis",  "city": "Paris",           "year_opened": 2019},
    {"acronym": "Kyutai",           "name": "Kyutai",                                        "parent_company": "Kyutai (Niel/Saadé/Schmidt)", "hq_country": "France", "city": "Paris",          "year_opened": 2023},
    {"acronym": "Mistral AI Lab",   "name": "Mistral AI Research",                           "parent_company": "Mistral AI",           "hq_country": "France",      "city": "Paris",           "year_opened": 2023},
]


def normalize(s):
    """Lowercase + strip accents for comparison."""
    if not s:
        return ""
    s = s.lower()
    for old, new in {
        '\xe9': 'e', '\xe8': 'e', '\xea': 'e', '\xeb': 'e',
        '\xe0': 'a', '\xe2': 'a', '\xe4': 'a', '\xe1': 'a',
        '\xf9': 'u', '\xfb': 'u', '\xfc': 'u',
        '\xee': 'i', '\xef': 'i',
        '\xf4': 'o', '\xf6': 'o',
        '\xe7': 'c', '\xf1': 'n',
    }.items():
        s = s.replace(old, new)
    return s


# ─────────────────────────────────────────────────────────────────────────
# Scoring
# ─────────────────────────────────────────────────────────────────────────

def score_ai_relevance(rec):
    """Score how likely a structure is an AI research lab (0-100)."""
    score = 0
    name = normalize(rec.get("libelle", ""))
    sigle = (rec.get("sigle") or "").strip()
    domain_codes = (rec.get("code_domaine_scientifique") or "").split(",")
    panel = rec.get("panel_erc") or ""
    label = rec.get("label_numero") or ""
    tutelles = rec.get("sigles_des_tutelles") or ""

    # Known lab bonus (also check partial matches for variants like LAAS-CNRS)
    if sigle in KNOWN_AI_LABS:
        score += 40
    elif any(known in sigle for known in KNOWN_AI_LABS if len(known) >= 3):
        score += 40
    # Also check if a known acronym appears in the lab name
    elif any(f" {known} " in f" {name} " or name.startswith(f"{known} ")
             for known in [k.lower() for k in KNOWN_AI_LABS]):
        score += 35

    # Name contains AI keywords
    for kw in AI_NAME_KEYWORDS:
        if kw in name:
            score += 30
            break

    # Name contains broader CS keywords
    for kw in CS_NAME_KEYWORDS:
        if kw in name:
            score += 10
            break

    # Domain: STIC (code 9)
    if "9" in domain_codes:
        score += 15

    # Domain: Mathematics (code 1) -- many AI labs straddle math/CS
    if "1" in domain_codes:
        score += 5

    # ERC panel PE6 = Computer science and informatics
    if "PE6" in panel:
        score += 15
    if "PE7" in panel:
        score += 5

    # UMR = serious joint research unit
    if "UMR" in label:
        score += 10

    # Has CNRS or Inria as tutelle
    if "CNRS" in tutelles or "INRIA" in tutelles:
        score += 5

    return min(score, 100)


# ─────────────────────────────────────────────────────────────────────────
# API fetching
# ─────────────────────────────────────────────────────────────────────────

def fetch_records(where_clause=None):
    """Fetch all records from MESR API matching a where clause."""
    records = []
    offset = 0

    while True:
        params = {"limit": PAGE_SIZE, "offset": offset, "order_by": "libelle ASC"}
        if where_clause:
            params["where"] = where_clause

        url = (
            f"{API_BASE}/catalog/datasets/{DATASET}/records"
            f"?{urllib.parse.urlencode(params)}"
        )
        req = urllib.request.Request(url)
        try:
            with urllib.request.urlopen(req, timeout=30) as resp:
                data = json.loads(resp.read().decode("utf-8"))
        except Exception as e:
            print(f"  [error] Failed at offset={offset}: {e}")
            break

        batch = data.get("results", [])
        records.extend(batch)
        total = data.get("total_count", 0)
        offset += PAGE_SIZE

        if offset >= total or len(batch) == 0:
            break
        time.sleep(0.3)

    return records


def fetch_from_api():
    """Fetch candidate structures from the MESR API (multiple passes)."""
    all_records = {}

    # Pass 1: STIC domain
    print("\n[1/4] Fetching STIC domain structures...")
    stic = fetch_records('code_domaine_scientifique = "9"')
    print(f"  Found {len(stic)} structures")
    for r in stic:
        all_records[r.get("numero_national_de_structure")] = r

    # Pass 2: AI keywords in name
    print("\n[2/4] Fetching structures with AI keywords in name...")
    for kw in ["intelligence artificielle", "machine learning",
               "apprentissage", "robotique", "donnees", "numerique"]:
        batch = fetch_records(f'search(libelle, "{kw}")')
        print(f"  '{kw}': {len(batch)} matches")
        for r in batch:
            all_records.setdefault(r.get("numero_national_de_structure"), r)
        time.sleep(0.2)

    # Pass 3: Math domain with PE6 panel
    print("\n[3/4] Fetching math domain structures...")
    math = fetch_records('code_domaine_scientifique = "1"')
    print(f"  Found {len(math)} in math domain")
    for r in math:
        if "PE6" in (r.get("panel_erc") or ""):
            all_records.setdefault(r.get("numero_national_de_structure"), r)

    # Pass 4: Engineering domain with PE6 panel
    print("\n[4/4] Fetching engineering domain structures...")
    eng = fetch_records('code_domaine_scientifique = "8"')
    print(f"  Found {len(eng)} in engineering domain")
    for r in eng:
        if "PE6" in (r.get("panel_erc") or ""):
            all_records.setdefault(r.get("numero_national_de_structure"), r)

    return list(all_records.values())


def fetch_from_local(filepath):
    """Load structures from a local JSON dump of the RNSR dataset."""
    print(f"\n  Loading local file: {filepath}")
    with open(filepath, "r", encoding="utf-8") as f:
        records = json.load(f)
    print(f"  Loaded {len(records)} structures from local file")
    return records


# ─────────────────────────────────────────────────────────────────────────
# Output
# ─────────────────────────────────────────────────────────────────────────

def format_lab(r):
    """Extract a clean output record from a raw structure."""
    return {
        "rnsr_id": r.get("numero_national_de_structure"),
        "name": r.get("libelle"),
        "acronym": (r.get("sigle") or "").strip() or None,
        "umr_label": (r.get("label_numero") or "").split(",")[0].strip() or None,
        "type": r.get("type_de_structure"),
        "sector": r.get("_sector", "public"),
        "year_created": r.get("annee_de_creation"),
        "city": r.get("commune"),
        "postal_code": r.get("code_postal"),
        "website": r.get("site_web"),
        "director_last": r.get("nom_du_responsable"),
        "director_first": r.get("prenom_du_responsable"),
        "tutelles": r.get("sigles_des_tutelles"),
        "parent_company": r.get("_parent_company"),
        "domain": r.get("domaine_scientifique"),
        "erc_panel": r.get("panel_erc"),
        "ai_score": r.get("_ai_score", 0),
        "rnsr_url": r.get("fiche_rnsr"),
    }


def write_outputs(labs):
    """Write JSON and CSV output files."""
    output = [format_lab(r) for r in labs]

    # JSON
    json_path = DATA_DIR / "ai_labs_france.json"
    json_path.write_text(json.dumps(output, indent=2, ensure_ascii=False))
    print(f"\n  Wrote {len(output)} labs to {json_path}")

    # CSV
    csv_path = DATA_DIR / "ai_labs_france.csv"
    with open(csv_path, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow([
            "ai_score", "sector", "acronym", "name", "umr_label", "type",
            "city", "parent_company", "tutelles", "domain",
            "year_created", "website",
        ])
        for r in output:
            writer.writerow([
                r["ai_score"], r.get("sector", "public"),
                r["acronym"] or "", r["name"],
                r["umr_label"] or "", r["type"] or "",
                r["city"] or "", r.get("parent_company") or "",
                r["tutelles"] or "", (r["domain"] or "")[:80],
                r["year_created"] or "", r["website"] or "",
            ])
    print(f"  Wrote CSV summary to {csv_path}")

    return json_path, csv_path


def print_summary(labs):
    """Print a human-readable summary to stdout."""
    tier1 = [l for l in labs if l["_ai_score"] >= 50]
    tier2 = [l for l in labs if 35 <= l["_ai_score"] < 50]
    tier3 = [l for l in labs if 20 <= l["_ai_score"] < 35]

    print(f"\n{'=' * 72}")
    print(f"RESULTS: {len(labs)} AI-related research laboratories identified")
    print(f"{'=' * 72}")

    def print_tier(title, items):
        print(f"\n--- {title} --- [{len(items)} labs]")
        for r in items:
            sigle = (r.get("sigle") or "").strip()
            label = (r.get("label_numero") or "").split(",")[0].strip()
            city = r.get("commune") or "?"
            tag = f"[{label}]" if label else ""
            name = (r.get("libelle") or "")[:50]
            print(f"  {r['_ai_score']:3d}  {sigle:14s} {tag:14s} {name:52s} {city}")

    print_tier("TIER 1: Core AI Labs (score >= 50)", tier1)
    print_tier("TIER 2: Strong AI Presence (score 35-49)", tier2)
    print_tier("TIER 3: AI-Adjacent (score 20-34)", tier3)

    # Region breakdown
    cities = {}
    for r in labs:
        city = r.get("commune") or "Unknown"
        cities[city] = cities.get(city, 0) + 1

    print(f"\n--- Geographic distribution (top 20) ---")
    for city, count in sorted(cities.items(), key=lambda x: -x[1])[:20]:
        print(f"  {city}: {count}")

    # Type breakdown
    types = {}
    for r in labs:
        t = r.get("type_de_structure") or "Unknown"
        types[t] = types.get(t, 0) + 1
    print(f"\n--- By structure type ---")
    for t, count in sorted(types.items(), key=lambda x: -x[1]):
        print(f"  {t}: {count}")

    # Check for known labs we expected
    found_sigles = {(r.get("sigle") or "").strip() for r in labs}
    missing = KNOWN_AI_LABS - found_sigles - {""}
    if missing:
        print(f"\n--- Known labs not found (may use variant names) ---")
        for m in sorted(missing):
            print(f"  - {m}")

    # Sector breakdown
    public = [l for l in labs if l.get("_sector") != "private"]
    private = [l for l in labs if l.get("_sector") == "private"]

    print(f"\n  Total labs identified: {len(labs)}")
    print(f"    Public (RNSR): {len(public)}  (Tier 1: {len([l for l in public if l['_ai_score'] >= 50])}, Tier 2: {len([l for l in public if 35 <= l['_ai_score'] < 50])})")
    print(f"    Private (corporate R&D): {len(private)}")
    print(f"\n  Reconciliation with government's '81 laboratoires de l'IA':")
    core_public = len([l for l in public if l["_ai_score"] >= 35])
    print(f"    Core public labs (Tiers 1+2):  {core_public}")
    print(f"    Private labs:                  {len(private)}")
    print(f"    Subtotal:                      {core_public + len(private)}")
    gap = 81 - (core_public + len(private))
    if gap > 0:
        print(f"    Gap to 81:                     {gap} (likely labs in other RNSR domains,")
        print(f"                                    3IA institutes, or different vintage)")
    else:
        print(f"    Surplus over 81:               {abs(gap)} (post-2017 labs added)")


# ─────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────

def main():
    print("=" * 72)
    print("Identifying French AI Research Laboratories")
    print("Source: MESR RNSR (Structures de recherche publiques actives)")
    print("=" * 72)

    # Parse args
    local_file = None
    if "--local" in sys.argv:
        idx = sys.argv.index("--local")
        if idx + 1 < len(sys.argv):
            local_file = sys.argv[idx + 1]

    # Fetch or load data
    if local_file:
        all_records = fetch_from_local(local_file)
    else:
        all_records = fetch_from_api()

    if not all_records:
        print("\n  No records found. If the API is unreachable, try:")
        print("    python3 scripts/fetch_ai_labs.py --local data/rnsr_structures.json")
        print("\n  You can download the RNSR data from:")
        print("    https://data.gouv.fr/datasets/structures-de-recherche-publiques-actives-1")
        return

    print(f"\n  Total candidate structures: {len(all_records)}")

    # Score all records
    print("  Scoring AI relevance...")
    for rec in all_records:
        rec["_ai_score"] = score_ai_relevance(rec)

    # Filter: lab-level only (niveau >= 2), score >= 20
    labs = [
        r for r in all_records
        if r.get("code_de_niveau_de_structure")
        and int(r.get("code_de_niveau_de_structure", 0)) >= 2
        and r["_ai_score"] >= 20
    ]

    # Sort by score descending, then name
    labs.sort(key=lambda r: (-r["_ai_score"], r.get("libelle", "")))

    print(f"  Lab-level structures with AI score >= 20: {len(labs)}")

    # Inject private AI labs (not in RNSR)
    print(f"\n  Adding {len(PRIVATE_AI_LABS)} private AI R&D labs...")
    for plab in PRIVATE_AI_LABS:
        labs.append({
            "libelle": plab["name"],
            "sigle": plab["acronym"],
            "commune": plab["city"],
            "annee_de_creation": str(plab.get("year_opened", "")),
            "type_de_structure": "Private R&D Lab",
            "code_de_niveau_de_structure": "2",
            "sigles_des_tutelles": plab["parent_company"],
            "_ai_score": 90,
            "_sector": "private",
            "_parent_company": plab["parent_company"],
        })

    # Re-sort
    labs.sort(key=lambda r: (-r["_ai_score"], r.get("libelle", "")))

    # Write outputs
    write_outputs(labs)

    # Print summary
    print_summary(labs)


if __name__ == "__main__":
    main()
