"""Research projects from the scanR projects dump (EU Horizon/CORDIS data and others).

Findings: eu_project (one per project the entity takes part in), with the entity's own
funding and every French partner's funding in `facts`.
Matching: scanR structure id, ROR id or SIREN of a participant (high); otherwise the
participant name (medium, needs review).
Lab sub-entries share their parent's participant id and amount: merged before summing.

The dump (~370 MB) is downloaded once into the cache. Set ATLAS_SCANR_PROJECTS to use
a local copy instead.
"""
import gzip
import json
import os
import re

from ..core import download, finding, norm_siren, NameMatcher, SourceUnavailable

NAME = "scanR (Ministry of Higher Education and Research), CORDIS data"
DUMP_URL = "https://scanr-data.s3.gra.io.cloud.ovh.net/production/projects_denormalized.jsonl.gz"


def _label(p):
    lab = (p.get("label") or {})
    lab = lab.get("default") or lab.get("fr") or lab.get("en") or "" if isinstance(lab, dict) else str(lab)
    return lab.split("__-__")[0]


def _num(x):
    """Funding values are sometimes strings in the dump."""
    try:
        return float(x) if x not in (None, "") else 0.0
    except (TypeError, ValueError):
        return 0.0


def _ids(p):
    st = p.get("structure") if isinstance(p.get("structure"), dict) else {}
    ids = {("scanr", str(p.get("participant_id") or "")), ("scanr", str(st.get("id") or ""))}
    for raw in (p.get("participant_id"), st.get("id")):  # French bodies are often keyed by their SIREN
        if raw and re.fullmatch(r"\d{9}", str(raw)):
            ids.add(("siren", str(raw)))
    for e in st.get("externalIds") or []:
        t, v = e.get("type"), str(e.get("id") or "")
        if t in ("siren", "siret"):
            ids.add(("siren", norm_siren(v)))
        elif t in ("ror", "grid"):
            ids.add((t, v))
    return ids


def _acronym(r):
    a = r.get("acronym")
    if isinstance(a, dict):
        a = a.get("default") or a.get("en") or a.get("fr")
    return a or str(r.get("id"))


def _title(r):
    t = r.get("label")
    if isinstance(t, dict):
        t = t.get("en") or t.get("default") or t.get("fr")
    return t or ""


def enrich(entity, ctx):
    path = os.environ.get("ATLAS_SCANR_PROJECTS")
    try:
        if not path:
            ctx.log("scanr_projects: fetching dump (cached after first run)")
            path = download(DUMP_URL, "scanr_projects_denormalized.jsonl.gz")
    except SourceUnavailable as e:
        ctx.status("scanr_projects", "unavailable", errors=[str(e)])
        return []
    want = {("scanr", i) for i in entity.get("scanr_ids", [])}
    want |= {("ror", i) for i in entity.get("ror_ids", [])}
    want |= {("siren", norm_siren(s)) for s in entity.get("sirens", []) if norm_siren(s)}
    matcher = NameMatcher(entity.get("names", []), entity.get("name_exclusions", []))
    focus = entity.get("focus_country", "FR")
    iso3 = {"FR": "FRA"}.get(focus, focus)
    # cheap text pre-filter before parsing each JSON line
    needles = [n.lower() for n in entity.get("names", [])] + [i[1].lower() for i in want if i[1]]
    out, scanned = [], 0
    with gzip.open(path, "rt") as f:
        for line in f:
            scanned += 1
            low = line.lower()
            if not any(n in low for n in needles):
                continue
            r = json.loads(line)
            parts = [p for p in r.get("participants") or [] if isinstance(p, dict)]
            mine, how = [], set()
            for p in parts:
                hit_ids = _ids(p) & want
                if hit_ids:
                    mine.append(p); how.add(("identifier", sorted(f"{a}:{b}" for a, b in hit_ids)[0]))
                    continue
                nm = matcher.matches(_label(p))
                if nm:
                    mine.append(p); how.add(("name", nm))
            if not mine:
                continue
            # merge sub-entries sharing a participant id; prefer the non-lab label
            def merged(plist):
                byid = {}
                for p in plist:
                    k = p.get("id") or _label(p)
                    if k not in byid or byid[k]["_lab"].startswith("labo "):
                        byid[k] = {"_lab": _label(p), "eur": _num(p.get("funding")), "role": p.get("role"),
                                   "as": p.get("participates_as"),
                                   "country": (p.get("address") or {}).get("country_code")}
                return list(byid.values())
            mine_ids = {id(p) for p in mine}
            own = merged(mine)
            fr = merged([p for p in parts if id(p) not in mine_ids
                         and (p.get("address") or {}).get("country_code") == iso3])
            own_eur = round(sum(x["eur"] for x in own), 2)
            fr_eur = round(sum(x["eur"] for x in fr), 2)
            level = "high" if any(m == "identifier" for m, _ in how) else "medium"
            acr, pid = _acronym(r), r.get("id")
            url = r.get("url") or f"https://cordis.europa.eu/project/id/{pid}"
            start = (r.get("startDate") or "")[:10] or (str(int(r["year"])) if r.get("year") else None)
            ctx.save_raw("scanr_projects", pid, url, r)
            own_txt = (f"{entity['display_name']} received €{own_eur:,.0f}" if own_eur
                       else f"{entity['display_name']} took part with no EU funding recorded")
            out.append(finding(
                ctx, connector="scanr_projects", type="eu_project", ext_id=pid,
                title=f"{acr}: {_title(r)}",
                summary=f"{r.get('type') or 'Project'}; {own_txt}; "
                        + (f"{len(fr)} {focus} partner(s) received €{fr_eur:,.0f}." if fr else f"no {focus} partner."),
                date=start, amount_eur=own_eur or None, amount_basis="EU contribution" if own_eur else None,
                subject={"name": "; ".join(sorted({x["_lab"] for x in own}))},
                counterparts=[{"name": x["_lab"], "country": focus, "role": x["role"], "amount_eur": x["eur"] or None,
                               "participates_as": x["as"]} for x in sorted(fr, key=lambda x: -(x["eur"] or 0))],
                facts={"acronym": acr, "programme": r.get("type"),
                       "action": (r.get("action") or {}).get("id") if isinstance(r.get("action"), dict) else r.get("action"),
                       "start": r.get("startDate"), "end": r.get("endDate"), "eu_contribution_total": r.get("budgetFinanced"),
                       "budget_total": r.get("budgetTotal"), "entity_participants": [
                           {"name": x["_lab"], "eur": x["eur"], "role": x["role"], "participates_as": x["as"], "country": x["country"]} for x in own],
                       "entity_eur": own_eur, "focus_partners_eur": fr_eur, "has_focus_partner": bool(fr)},
                source_name=NAME, url=url, match_method=sorted(how)[0][0], match_on=sorted(how)[0][1],
                level=level, suggested_target="projects, project_links, grants"))
    ctx.status("scanr_projects", "ok", dump=os.path.basename(path), records_scanned=scanned, projects_found=len(out))
    return out
