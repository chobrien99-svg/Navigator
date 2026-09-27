"""Build SAMPLE API responses from the 2026 CSVs in data/ so the Funding Hub
renderer can be previewed without network access:

    python3 scripts/ftj-funding-hub/fixtures/build_fixtures.py

These are approximations of the live API (non-EUR amounts use a flat rate,
no publish_status filtering). Never publish from fixtures.
"""
import csv, glob, json, os, re

HERE = os.path.dirname(os.path.abspath(__file__))
DATA = os.path.join(HERE, "..", "..", "..", "data")
USD_TO_EUR = 0.86  # sample only
STAGES = {"pre-seed": "Pre-seed", "seed": "Seed", "series a": "Series A", "series b": "Series B",
          "series c": "Series C", "series d": "Series D", "series e": "Series E",
          "growth": "Growth", "growth equity": "Growth", "bridge": "Bridge", "debt": "Debt", "grant": "Grant", "ipo": "IPO"}

def slug(s):
    return re.sub(r"[^a-z0-9]+", "-", s.lower()).strip("-")

rounds = []
for path in sorted(glob.glob(os.path.join(DATA, "funding_*2026*.csv"))):
    for i, row in enumerate(csv.DictReader(open(path, encoding="utf-8"))):
        name = (row.get("name") or "").strip()
        date = (row.get("Announced Date") or "").strip()
        if not name or not date.startswith("2026"):
            continue
        amount = float(row["Amount"]) if (row.get("Amount") or "").strip() else None
        cur = (row.get("Currency") or "EUR").strip() or "EUR"
        eur = None if amount is None else round(amount if cur == "EUR" else amount * USD_TO_EUR)
        investors = [x.strip() for x in (row.get("Investors") or "").split(",") if x.strip()]
        stage = (row.get("Round") or row.get("Funding Type") or "").strip()
        rounds.append({
            "id": f"sample_{os.path.basename(path)[:-4]}_{i}",
            "announcement_date": date,
            "company_name": name,
            "company_slug": slug(name),
            "sectors": [x.strip() for x in (row.get("Sectors") or "").split(",") if x.strip()],
            "round_label": STAGES.get(stage.lower(), "Undisclosed"),
            "amount_original": amount,
            "currency_original": cur if amount is not None else None,
            "amount_eur": eur,
            "lead_investors": investors[:1],
            "investors": investors,
            "hq_city": (row.get("City") or "").strip() or None,
            "hq_country": "France",
            "french_founded_abroad": False,
            "company_url": (row.get("website") or "").strip() or None,
            "primary_source_url": None,
            "ftj_url": None,
            "updated_at": date + "T07:00:00+02:00",
        })

latest = sorted(rounds, key=lambda r: r["announcement_date"], reverse=True)
largest = sorted(rounds, key=lambda r: r["amount_eur"] or -1, reverse=True)
quarters = [{"quarter": f"Q{q}", "total_disclosed_eur": 0, "round_count": 0} for q in range(1, 5)]
for r in rounds:
    q = quarters[(int(r["announcement_date"][5:7]) - 1) // 3]
    q["round_count"] += 1
    q["total_disclosed_eur"] += r["amount_eur"] or 0
top = largest[0]
updated = max(r["updated_at"] for r in rounds)
summary = {
    "year": 2026, "currency": "EUR",
    "total_disclosed_eur": sum(r["amount_eur"] or 0 for r in rounds),
    "round_count": len(rounds),
    "disclosed_round_count": sum(1 for r in rounds if r["amount_eur"] is not None),
    "largest_round": {k: top[k] for k in ("company_name", "company_slug", "amount_eur", "round_label", "announcement_date")},
    "quarters": quarters,
    "updated_at": updated,
}

def meta(data, sort, limit):
    return {"count": len(data), "limit": limit, "sort": sort, "year": 2026, "updated_at": updated}

out = {
    "summary.json": summary,
    "latest.json": {"data": latest[:50], "meta": meta(latest[:50], "announcement_date:desc", 50)},
    "largest.json": {"data": largest[:20], "meta": meta(largest[:20], "amount_eur:desc", 20)},
}
for name, payload in out.items():
    with open(os.path.join(HERE, name), "w", encoding="utf-8") as f:
        json.dump(payload, f, ensure_ascii=False, indent=2)
print(f"{len(rounds)} sample rounds -> {', '.join(out)}")
