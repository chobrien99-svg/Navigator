"""Patents from the scanR patents dump (INPI/EPO data via the research ministry).

Findings: patent (one per patent family where the entity is an applicant), with the
number of inventors resident in the focus country.
Matching: applicant SIREN (high); applicant organisation name (medium). Patents that only
mention the entity in their text are ignored.
The dump (~560 MB) is downloaded once; ATLAS_SCANR_PATENTS can point to a local copy.
"""
import gzip
import json
import os

from ..core import download, finding, norm_siren, NameMatcher, SourceUnavailable

NAME = "scanR patents (INPI/EPO data)"
DUMP_URL = "https://scanr-data.s3.gra.io.cloud.ovh.net/production/patents_denormalized.jsonl.gz"
PAGE = "https://scanr.enseignementsup-recherche.gouv.fr/patents/{}"


def _title(r):
    t = r.get("title")
    if isinstance(t, dict):
        t = t.get("en") or t.get("default") or t.get("fr")
    return t or ""


def enrich(entity, ctx):
    path = os.environ.get("ATLAS_SCANR_PATENTS")
    try:
        if not path:
            path = download(DUMP_URL, "scanr_patents_denormalized.jsonl.gz")
    except SourceUnavailable as e:
        ctx.status("patents", "unavailable", errors=[str(e)])
        return []
    sirens = {norm_siren(s) for s in entity.get("sirens", []) if norm_siren(s)}
    m = NameMatcher(entity.get("names", []), entity.get("name_exclusions", []))
    needles = [n.lower() for n in entity.get("names", [])] + list(sirens)
    focus = entity.get("focus_country", "FR")
    out, scanned = [], 0
    with gzip.open(path, "rt") as f:
        for line in f:
            scanned += 1
            low = line.lower()
            if not any(n in low for n in needles):
                continue
            r = json.loads(line)
            how = None
            own = []
            for a in r.get("applicants") or []:
                ids = {norm_siren(i.get("id")) for i in (a.get("ids") or []) if i.get("type") in ("siren", "siret")}
                if ids & sirens:
                    how = how or ("identifier", f"siren:{sorted(ids & sirens)[0]}")
                    own.append(a.get("name"))
                elif a.get("type") == "organisation" and m.matches(a.get("name")):
                    how = how or ("name", m.matches(a.get("name")))
                    own.append(a.get("name"))
            if not how:
                continue
            inv = r.get("inventors") or []
            local = [i.get("name") for i in inv if i.get("country") == focus]
            others = [a.get("name") for a in r.get("applicants") or [] if a.get("name") not in own and a.get("type") == "organisation"]
            pid = r.get("id")
            ctx.save_raw("patents", pid, PAGE.format(pid), r)
            out.append(finding(ctx, connector="patents", type="patent", ext_id=pid, title=_title(r),
                               summary=f"Applicant(s): {'; '.join(own)}. {len(local)} of {len(inv)} inventors in {focus}"
                                       + (f": {', '.join(local[:5])}" if local else "") + ".",
                               date=(r.get("applicationDate") or r.get("publicationDate") or "")[:10] or (str(r.get("year")) if r.get("year") else None),
                               subject={"name": "; ".join(own)},
                               counterparts=[{"name": n, "role": "co-applicant"} for n in others],
                               facts={"family": r.get("inpadocFamily"), "inventors": [i.get("name") for i in inv],
                                      "inventors_in_focus_country": local, "granted": r.get("grantedDate"),
                                      "european": r.get("isOeb"), "international": r.get("isInternational")},
                               source_name=NAME, url=PAGE.format(pid), match_method=how[0], match_on=how[1],
                               level="high" if how[0] == "identifier" else "medium", suggested_target="patents"))
    ctx.status("patents", "ok", dump=os.path.basename(path), records_scanned=scanned, patents=len(out))
    return out
