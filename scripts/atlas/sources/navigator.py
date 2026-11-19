"""What the Navigator database already holds about the entity.

Findings: navigator_record (one per stored fact: legal entity, funding round as investor,
relationship, event, grant, project link, programme membership, linked articles).
The run also uses this to mark every other finding that Navigator already holds
(`in_navigator: true`), so the review and the loader skip it.

Input: a JSON export produced by scripts/atlas/sql/navigator_entity_export.sql for the
entity's slug, saved as data/atlas_runs/entity-<key>/navigator_export.json (or the path in
ATLAS_NAVIGATOR_EXPORT). Direct database access will replace the file once the Atlas
runner has a Supabase key in its environment.
"""
import json
import os
import re

from ..core import finding

NAME = "France Navigator database"
REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))


def export_path(entity):
    return os.environ.get("ATLAS_NAVIGATOR_EXPORT") or os.path.join(
        REPO, "data", "atlas_runs", f"entity-{entity['key']}", "navigator_export.json")


def load(entity):
    p = export_path(entity)
    if not os.path.exists(p):
        return None
    with open(p) as f:
        return json.load(f)


def enrich(entity, ctx):
    data = load(entity)
    if data is None:
        ctx.status("navigator", "unavailable", errors=[f"no export at {export_path(entity)}; run sql/navigator_entity_export.sql"])
        return []
    out = []
    org = data.get("organization") or {}
    base = f"navigator:{entity.get('navigator_slug')}"
    def add(kind, ext, title, summary="", date=None, amount=None, target=None, facts=None):
        out.append(finding(ctx, connector="navigator", type="navigator_record", ext_id=f"{kind}:{ext}", title=title,
                           summary=summary, date=date, amount_eur=amount, amount_basis="as stored" if amount else None,
                           subject={"name": org.get("name")}, facts={"kind": kind, **(facts or {})},
                           source_name=NAME, url=None, match_on=base, suggested_target=target or "already stored"))
    for le in data.get("legal_entities") or []:
        add("legal_entity", le["siren"], le["legal_name"], f"SIREN {le['siren']}", le.get("incorporation_date"))
    for r in data.get("investments") or []:
        add("investment", r["round_id"], f"Investor in {r['company']} ({r.get('stage')})",
            f"Round of €{r['amount_eur_m']}M" if r.get("amount_eur_m") else "Amount undisclosed", r.get("date"),
            facts={"company": r["company"], "lead": r.get("is_lead")})
    for r in data.get("relationships") or []:
        add("relationship", r["id"], f"{r['direction']} {r['type']} {r['other']}", r.get("description") or "", r.get("start_date"))
    for e in data.get("events") or []:
        add("event", e["id"], e["title"], e.get("description") or "", e.get("date"), facts={"url": e.get("source_url")})
    for g in data.get("grants") or []:
        add("grant", g["id"], g["grant_name"], g.get("granting_body") or "", g.get("awarded_date"), g.get("amount_eur"),
            facts={"url": g.get("source_url")})
    for p in data.get("projects") or []:
        add("project", p["slug"], p["name"], f"Role: {p.get('role')}", p.get("start_date"), facts={"url": p.get("website_url")})
    for pt in data.get("patents") or []:
        add("patent", pt.get("number") or pt["title"][:40], pt["title"], f"Patent {pt.get('number') or ''}".strip())
    for p in data.get("programs") or []:
        add("program", p["edition_id"], f"Member of {p['program']}", p.get("role") or "", None)
    if data.get("articles_count"):
        add("articles", "count", f"{data['articles_count']} linked articles", "Papers and articles linked to the organisation")
    ctx.status("navigator", "ok", export=os.path.basename(export_path(entity)), exported_at=data.get("exported_at"),
               records=len(out))
    return out


def annotate(findings, data):
    """Mark findings Navigator already holds. Matching is by SIREN for legal entities, by patent number or title for patents, and by
    source URL for projects, grants, papers and events."""
    if not data:
        return 0
    sirens = {le["siren"] for le in data.get("legal_entities") or []}
    urls = {_url_key(u) for u in data.get("known_urls") or []}
    titles = {_norm(p["title"]) for p in data.get("patents") or []} | {_norm(e["title"]) for e in data.get("events") or []}
    prefixes = {t[:40] for t in titles if t}  # titles are truncated in some exports
    numbers = [re.sub(r"[^A-Z0-9]", "", (p.get("number") or "").upper()) for p in data.get("patents") or []]
    numbers = [x for x in numbers if x]
    for x in (data.get("events") or []):
        if x.get("source_url"):
            urls.add(_url_key(x["source_url"]))
    n = 0
    for f in findings:
        if f["source"]["connector"] == "navigator":
            continue
        known = False
        if f["type"] == "legal_entity" and f["subject"].get("siren") in sirens:
            known = True
        elif f["source"].get("url") and _url_key(f["source"]["url"]) in urls:
            known = True
        elif f["type"] == "patent" and any(
                nb.startswith(re.sub(r"[^A-Z0-9]", "", i.upper())) for i in f["facts"].get("numbers") or [] for nb in numbers if i):
            known = True
        elif f["type"] == "patent" and ({_norm(f["title"])[:40], _norm(f["facts"].get("title_fr"))[:40]} - {""}) & prefixes:
            known = True
        f["in_navigator"] = known
        n += known
    return n


def _norm(t):
    import re
    import unicodedata
    if not t:
        return ""
    t = unicodedata.normalize("NFKD", t).encode("ascii", "ignore").decode().lower()
    return re.sub(r"[^a-z0-9]+", " ", t).strip()


def _url_key(u):
    """Compare URLs loosely: BODACC notices have had two URL formats
    (/annonce/detail-annonce/A/20260203/4982 and ...?q.id=id:A202602034982)."""
    if not u:
        return u
    m = re.search(r"detail-annonce/([ABC])/(\d{8})/(\d+)", u) or re.search(r"id:([ABC])(\d{8})(\d+)", u)
    if m:
        return "bodacc:" + "".join(m.groups())
    return u.rstrip("/").replace("http://", "https://")
