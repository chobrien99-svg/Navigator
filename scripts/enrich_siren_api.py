#!/usr/bin/env python3
"""
Enrich organizations with SIREN via the French government
recherche-entreprises API (fuzzy name search).

API: https://recherche-entreprises.api.gouv.fr
Free, no auth, no rate limits.

Usage:
  python3 scripts/enrich_siren_api.py <input.json>

Input format:
  [{"name": "...", "website": "...", "slug": "..."}]

Output:
  data/siren_api_results.json       — all results with candidates
  data/siren_api_update.sql         — SQL for high-confidence matches
  data/siren_api_review.csv         — ambiguous cases needing review
"""

import csv
import json
import re
import sys
import time
import urllib.parse
import urllib.request
import urllib.error
from pathlib import Path

API_BASE = "https://recherche-entreprises.api.gouv.fr/search"
RATE_LIMIT_DELAY = 0.15  # ~6 req/sec, well under their limits

# Scoring thresholds
HIGH_CONFIDENCE = 0.85  # auto-accept
REVIEW_THRESHOLD = 0.60  # needs manual review
# below REVIEW_THRESHOLD = rejected


def luhn_check(siren: str) -> bool:
    if len(siren) != 9 or not siren.isdigit():
        return False
    total = 0
    for i, ch in enumerate(siren):
        d = int(ch)
        if i % 2 == 1:
            d *= 2
            if d > 9:
                d -= 9
        total += d
    return total % 10 == 0


def normalize_name(name: str) -> str:
    """Normalize name for comparison."""
    s = name.lower()
    # Remove common suffixes/prefixes
    suffixes = [
        ' sa', ' sas', ' sasu', ' sarl', ' eurl', ' sci', ' gie', ' scs',
        ' technologies', ' technology', ' labs', ' lab', ' group', ' groupe',
        ' inc', ' llc', ' ltd', ' corp', ' corporation', ' co',
    ]
    for suf in suffixes:
        if s.endswith(suf):
            s = s[:-len(suf)]
    # Remove punctuation and extra spaces
    s = re.sub(r'[^a-z0-9]+', '', s)
    return s


def score_match(query_name: str, api_name: str) -> float:
    """Score how well an API result matches the query name (0-1)."""
    q = normalize_name(query_name)
    a = normalize_name(api_name)

    if not q or not a:
        return 0.0

    # Exact match
    if q == a:
        return 1.0

    # One is substring of the other
    if q in a or a in q:
        shorter = min(len(q), len(a))
        longer = max(len(q), len(a))
        return shorter / longer

    # Shared character overlap (simple Jaccard-like)
    q_set = set(q[i:i+3] for i in range(max(0, len(q)-2)))
    a_set = set(a[i:i+3] for i in range(max(0, len(a)-2)))
    if not q_set or not a_set:
        return 0.0
    overlap = len(q_set & a_set) / len(q_set | a_set)
    return overlap


def search_company(name: str, limit: int = 5) -> list[dict]:
    """Search the recherche-entreprises API for a company name."""
    params = urllib.parse.urlencode({
        "q": name,
        "page": 1,
        "per_page": limit,
    })
    url = f"{API_BASE}?{params}"

    for attempt in range(4):
        try:
            req = urllib.request.Request(url, headers={
                "User-Agent": "NavigatorBot/1.0 (SIREN enrichment)",
                "Accept": "application/json",
            })
            with urllib.request.urlopen(req, timeout=10) as resp:
                data = json.loads(resp.read().decode("utf-8"))
                return data.get("results", [])
        except urllib.error.HTTPError as e:
            if e.code == 429:  # rate limit — exponential backoff
                wait = 2 ** attempt
                print(f"    rate limited, waiting {wait}s...", end=" ", flush=True)
                time.sleep(wait)
                continue
            print(f"    HTTP {e.code}")
            return []
        except Exception as e:
            print(f"    error: {e}")
            return []
    return []


def pick_best_match(name: str, candidates: list[dict]) -> tuple[dict | None, float]:
    """Pick the best candidate and return (result, score)."""
    if not candidates:
        return None, 0.0

    scored = []
    for c in candidates:
        api_name = c.get("nom_complet") or c.get("nom_raison_sociale") or ""
        score = score_match(name, api_name)
        # Bonus for active businesses (etat_administratif = A)
        siege = c.get("siege") or {}
        if siege.get("etat_administratif") == "A":
            score += 0.05
        # Bonus for startups/tech sectors
        activity = siege.get("activite_principale", "")
        if activity.startswith(("62.", "63.", "72.", "70.", "71.")):
            score += 0.05
        scored.append((c, min(1.0, score)))

    scored.sort(key=lambda x: -x[1])
    return scored[0]


def enrich_company(name: str, website: str = "", slug: str = "") -> dict:
    """Enrich a single company via the API."""
    result = {
        "name": name,
        "website": website,
        "slug": slug,
        "siren": None,
        "confidence": None,
        "matched_name": None,
        "activity": None,
        "city": None,
        "creation_date": None,
        "candidates": [],
    }

    # Try the name as-is first
    candidates = search_company(name)

    # If nothing good, try just the first word (sometimes brand name)
    if not candidates or all(
        score_match(name, c.get("nom_complet", "")) < 0.3 for c in candidates
    ):
        first_word = name.split()[0] if name.split() else name
        if len(first_word) >= 4 and first_word.lower() != name.lower():
            more = search_company(first_word)
            candidates.extend(more)

    best, score = pick_best_match(name, candidates)

    # Save top 3 candidates for review
    for c in candidates[:3]:
        siege = c.get("siege") or {}
        result["candidates"].append({
            "name": c.get("nom_complet"),
            "siren": c.get("siren"),
            "city": siege.get("libelle_commune"),
            "activity": siege.get("activite_principale"),
            "creation_date": siege.get("date_creation"),
        })

    if best and score >= REVIEW_THRESHOLD:
        siege = best.get("siege") or {}
        result["siren"] = best.get("siren")
        result["confidence"] = round(score, 2)
        result["matched_name"] = best.get("nom_complet")
        result["activity"] = siege.get("activite_principale")
        result["city"] = siege.get("libelle_commune")
        result["creation_date"] = siege.get("date_creation")

    return result


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 scripts/enrich_siren_api.py <input.json>")
        sys.exit(1)

    input_file = sys.argv[1]
    with open(input_file) as f:
        companies = json.load(f)

    print(f"Enriching {len(companies)} companies via recherche-entreprises API...")
    print()

    output_dir = Path(__file__).parent.parent / "data"
    results_path = output_dir / "siren_api_results.json"

    # Resume support
    existing = {}
    if results_path.exists():
        try:
            with open(results_path) as f:
                prev = json.load(f)
                for r in prev:
                    existing[r.get("slug") or r.get("name")] = r
            print(f"Resumed: {len(existing)} already processed.")
        except Exception:
            pass

    results = list(existing.values())
    high = sum(1 for r in results if r.get("siren") and (r.get("confidence") or 0) >= HIGH_CONFIDENCE)
    review = sum(1 for r in results if r.get("siren") and (r.get("confidence") or 0) < HIGH_CONFIDENCE)

    for i, company in enumerate(companies):
        name = company["name"]
        website = company.get("website", "")
        slug = company.get("slug", "")
        key = slug or name

        if key in existing:
            continue

        print(f"[{i+1}/{len(companies)}] {name}...", end=" ", flush=True)

        try:
            result = enrich_company(name, website, slug)
        except Exception as e:
            print(f"error: {e}")
            continue

        results.append(result)

        if result["siren"]:
            conf = result["confidence"]
            if conf >= HIGH_CONFIDENCE:
                high += 1
                print(f"HIGH ({conf}): {result['matched_name']} → {result['siren']}")
            else:
                review += 1
                print(f"review ({conf}): {result['matched_name']} → {result['siren']}")
        else:
            print("no match")

        # Save progress every 10
        if (i + 1) % 10 == 0:
            with open(results_path, "w", encoding="utf-8") as f:
                json.dump(results, f, ensure_ascii=False, indent=2)

        time.sleep(RATE_LIMIT_DELAY)

    # Final save
    with open(results_path, "w", encoding="utf-8") as f:
        json.dump(results, f, ensure_ascii=False, indent=2)

    # Generate SQL for high-confidence matches
    high_matches = [r for r in results if r.get("siren") and (r.get("confidence") or 0) >= HIGH_CONFIDENCE]
    if high_matches:
        sql_path = output_dir / "siren_api_update.sql"
        with open(sql_path, "w", encoding="utf-8") as f:
            f.write("-- SIREN updates from recherche-entreprises API\n")
            f.write(f"-- {len(high_matches)} high-confidence matches (confidence >= {HIGH_CONFIDENCE})\n\n")
            for r in high_matches:
                name_safe = r["name"].replace("'", "''")
                f.write(f"-- {r['name']} → {r['matched_name']} (confidence: {r['confidence']})\n")
                f.write(f"INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)\n")
                f.write(f"SELECT uuid_generate_v4(), o.id, '{name_safe}', '{r['siren']}', 'France', TRUE, NOW(), NOW()\n")
                f.write(f"FROM organizations o WHERE o.slug = '{r['slug']}'\n")
                f.write(f"AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = '{r['siren']}');\n\n")

    # Generate review CSV for medium-confidence matches
    review_matches = [r for r in results if r.get("siren") and (r.get("confidence") or 0) < HIGH_CONFIDENCE]
    if review_matches:
        csv_path = output_dir / "siren_api_review.csv"
        with open(csv_path, "w", encoding="utf-8", newline="") as f:
            w = csv.writer(f)
            w.writerow(["name", "website", "siren", "matched_name", "confidence", "city", "activity", "creation_date"])
            for r in review_matches:
                w.writerow([
                    r["name"], r.get("website", ""), r["siren"],
                    r.get("matched_name"), r.get("confidence"),
                    r.get("city"), r.get("activity"), r.get("creation_date"),
                ])

    total_found = high + review
    no_match = len([r for r in results if not r.get("siren")])
    print(f"\n{'='*60}")
    print(f"Results: {total_found}/{len(results)} matched ({total_found*100//len(results)}%)")
    print(f"  High confidence (≥{HIGH_CONFIDENCE}): {high}")
    print(f"  Needs review ({REVIEW_THRESHOLD}-{HIGH_CONFIDENCE}): {review}")
    print(f"  No match: {no_match}")
    print(f"Results: {results_path}")
    if high_matches:
        print(f"SQL updates: {output_dir / 'siren_api_update.sql'}")
    if review_matches:
        print(f"Review CSV: {output_dir / 'siren_api_review.csv'}")


if __name__ == "__main__":
    main()
