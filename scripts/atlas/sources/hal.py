"""HAL, France's open archive of research papers (api.archives-ouvertes.fr).

Findings:
  research_paper          a paper with a French affiliation that also lists one of the entity's
                          structures as an affiliation (co-authorship)
  funding_acknowledgement a French-affiliated paper whose funding field names the entity
  hal_structure           an entity structure found in HAL's structure register (for review:
                          confirmed IDs go into the entity file as `hal_struct_ids`)
Matching: HAL structure IDs listed in the entity file (high); structure names (medium);
names in the funding field (medium).
"""
from ..core import http_json, finding, NameMatcher, SourceUnavailable

NAME = "HAL open archive (CCSD)"
API = "https://api.archives-ouvertes.fr/search/"
REF = "https://api.archives-ouvertes.fr/ref/structure/"
FIELDS = "halId_s,uri_s,title_s,docType_s,producedDate_s,producedDateY_i,authFullName_s,structId_i,structName_s,structCountry_s,funding_s"
DOC_TYPES = {"ART": "journal article", "COMM": "conference paper", "THESE": "PhD thesis", "REPORT": "report",
             "UNDEFINED": "preprint", "POSTER": "poster", "COUV": "book chapter", "OUV": "book", "PROCEEDINGS": "proceedings",
             "SOFTWARE": "software", "PRESCONF": "conference presentation", "ISSUE": "journal issue", "DOUV": "edited book"}


def _search(q, fq):
    docs, cursor = [], "*"
    while True:
        d = http_json(API, {"q": q, "fq": fq, "fl": FIELDS, "rows": 500, "sort": "docid asc", "cursorMark": cursor, "wt": "json"})
        docs += d["response"]["docs"]
        nxt = d.get("nextCursorMark")
        if not nxt or nxt == cursor:
            return docs
        cursor = nxt


def _structures(entity, matcher):
    found = {}
    for nm in entity.get("names", []):
        d = http_json(REF, {"q": f'name_t:"{nm}"', "fl": "docid,name_s,country_s,valid_s,type_s", "rows": 200, "wt": "json"})
        for s in d["response"]["docs"]:
            if matcher.matches(s.get("name_s")):
                found[int(s["docid"])] = s
    return found


def enrich(entity, ctx):
    m = NameMatcher(entity.get("names", []), entity.get("name_exclusions", []))
    country = entity.get("focus_country", "FR").lower()
    confirmed = {int(x) for x in entity.get("hal_struct_ids", [])}
    out = []
    try:
        structs = _structures(entity, m)
        q = " OR ".join(f'structName_t:"{n}"' for n in entity.get("names", []))
        papers = _search(q, f"structCountry_s:{country}")
        fq_fund = " OR ".join(f'funding_t:"{n}"' for n in entity.get("names", []))
        funded = _search(fq_fund, f"structCountry_s:{country}")
    except SourceUnavailable as e:
        ctx.status("hal", "unavailable", errors=[str(e)])
        return []
    for sid, s in sorted(structs.items()):
        url = f"https://aurehal.archives-ouvertes.fr/structure/read/id/{sid}"
        ctx.save_raw("hal", f"struct:{sid}", url, s)
        out.append(finding(ctx, connector="hal", type="hal_structure", ext_id=sid, title=s.get("name_s"),
                           summary=f"HAL structure {sid} ({s.get('type_s')}, {s.get('country_s') or 'no country'}, {s.get('valid_s')}).",
                           subject={"name": s.get("name_s")}, facts={"hal_struct_id": sid, "country": s.get("country_s")},
                           source_name=NAME, url=url, match_method="identifier" if sid in confirmed else "name",
                           match_on=str(sid) if sid in confirmed else s.get("name_s"),
                           level="high" if sid in confirmed else "medium", suggested_target="entity file (hal_struct_ids)"))
    entity_sids = set(structs)
    for d in papers:
        names = d.get("structName_s") or []
        own = sorted({n for n in names if m.matches(n)})
        if not own:
            continue  # matched on another field: skip
        ids = set(d.get("structId_i") or [])
        level, how, on = ("high", "identifier", str(sorted(ids & confirmed)[0])) if ids & confirmed else ("medium", "name", own[0])
        fr = sorted({n for n in names if not m.matches(n)})
        ctx.save_raw("hal", d["halId_s"], d.get("uri_s"), d)
        au = d.get("authFullName_s") or []
        out.append(finding(ctx, connector="hal", type="research_paper", ext_id=d["halId_s"], title=(d.get("title_s") or [""])[0],
                           summary=f"{DOC_TYPES.get(d.get('docType_s'), d.get('docType_s'))} by {', '.join(au[:4])}"
                                   + (f" and {len(au) - 4} others" if len(au) > 4 else "") + f". With: {'; '.join(own)}.",
                           date=d.get("producedDate_s") or (str(d.get("producedDateY_i")) if d.get("producedDateY_i") else None),
                           subject={"name": "; ".join(own)},
                           counterparts=[{"name": n, "role": "affiliation"} for n in fr[:40]],
                           facts={"doc_type": d.get("docType_s"), "authors": au, "entity_structures": own,
                                  "hal_struct_ids": sorted(ids & (entity_sids | confirmed))},
                           source_name=NAME, url=d.get("uri_s"), match_method=how, match_on=on, level=level,
                           suggested_target="articles, article_organizations"))
    for d in funded:
        fund = [f for f in (d.get("funding_s") or []) if m.matches(f)]
        if not fund:
            continue
        ctx.save_raw("hal", f"fund:{d['halId_s']}", d.get("uri_s"), d)
        out.append(finding(ctx, connector="hal", type="funding_acknowledgement", ext_id=d["halId_s"],
                           title=(d.get("title_s") or [""])[0], summary=f"Funding field: {'; '.join(fund)[:250]}",
                           date=d.get("producedDate_s"), subject={"name": entity["display_name"]},
                           counterparts=[{"name": n, "role": "affiliation"} for n in sorted(set(d.get("structName_s") or []))[:20]],
                           facts={"funding": fund}, source_name=NAME, url=d.get("uri_s"), match_method="name",
                           match_on=m.matches(fund[0]), level="medium", suggested_target="review"))
    ctx.status("hal", "ok", structures=len(structs), papers=sum(1 for x in out if x["type"] == "research_paper"),
               funding_mentions=sum(1 for x in out if x["type"] == "funding_acknowledgement"))
    return out
