"""BODACC legal notices (Opendatasoft mirror of the official bulletin).

Findings: legal_notice (one per notice), with the share capital and legal form stated in
the notice (used by the capital check, capital.py). Matching: SIREN in the notice's register field (high).
The service often resets connections: http_json retries; failures are reported as 'unavailable'.
"""
import json

from ..core import http_json, finding, norm_siren, SourceUnavailable

NAME = "BODACC (Bulletin officiel des annonces civiles et commerciales)"
API = "https://bodacc-datadila.opendatasoft.com/api/explore/v2.1/catalog/datasets/annonces-commerciales/records"
DETAIL = "https://www.bodacc.fr/pages/annonces-commerciales-detail/?q.id=id:{}"


def _parse(v):
    if isinstance(v, str) and v[:1] in "{[":
        try:
            return json.loads(v)
        except ValueError:
            return v
    return v


def _describe(r):
    """Short plain-language detail from the notice's structured blocks."""
    bits = []
    j = _parse(r.get("jugement"))
    if isinstance(j, dict):
        bits.append(" ".join(x for x in [j.get("famille"), j.get("nature"), j.get("complementJugement")] if x))
    m = _parse(r.get("modificationsgenerales"))
    if isinstance(m, dict) and m.get("descriptif"):
        bits.append(m["descriptif"])
    a = _parse(r.get("acte"))
    if isinstance(a, dict):
        d = a.get("descriptif")
        if not d and isinstance(a.get("creation"), dict):
            d = a["creation"].get("categorieCreation")
        if d:
            bits.append(str(d))
    dep = _parse(r.get("depot"))
    if isinstance(dep, dict):
        bits.append(" ".join(x for x in ["Accounts filed", dep.get("typeDepot"), f"for year ending {dep.get('dateCloture')}" if dep.get("dateCloture") else None] if x))
    return "; ".join(b for b in bits if b)[:400]


def _capital(r):
    """Share capital and legal form from the notice's company block, if stated."""
    lp = _parse(r.get("listepersonnes"))
    per = lp.get("personne") if isinstance(lp, dict) else None
    if isinstance(per, list):
        per = per[0] if per else None
    if not isinstance(per, dict):
        return None, None, None
    cap = per.get("capital") if isinstance(per.get("capital"), dict) else {}
    try:
        amount = float(str(cap.get("montantCapital")).replace(" ", "").replace(",", "."))
    except (TypeError, ValueError):
        amount = None
    return amount, cap.get("devise"), per.get("formeJuridique")


def _fetch(siren):
    rows, offset = [], 0
    while True:
        data = http_json(API, {"where": f'registre like "{siren}%"', "limit": 100, "offset": offset,
                               "order_by": "dateparution desc"})
        res = data.get("results", [])
        rows += res
        offset += len(res)
        if not res or offset >= data.get("total_count", 0):
            return rows


def enrich(entity, ctx):
    out, errors, ok = [], [], 0
    for siren in [norm_siren(s) for s in entity.get("sirens", []) if norm_siren(s)]:
        try:
            rows = _fetch(siren)
        except SourceUnavailable as e:
            errors.append(f"{siren}: {e}")
            ctx.log(f"bodacc: {siren} unavailable")
            continue
        ok += 1
        for r in rows:
            nid = r.get("id")
            url = DETAIL.format(nid)
            ctx.save_raw("bodacc", nid, url, r)
            fam = r.get("familleavis_lib") or r.get("familleavis") or "Notice"
            cap, cur, form = _capital(r)
            out.append(finding(ctx, connector="bodacc", type="legal_notice", ext_id=nid,
                               title=f"{fam}: {r.get('commercant')}",
                               summary=_describe(r) or fam, date=r.get("dateparution"),
                               subject={"name": r.get("commercant"), "siren": siren},
                               facts={"family": r.get("familleavis"), "court": r.get("tribunal"),
                                      "town": r.get("ville"), "notice_type": r.get("typeavis_lib"),
                                      "capital_eur": cap if cur in (None, "EUR") else None,
                                      "capital": cap, "currency": cur, "legal_form": form},
                               source_name=NAME, url=url, match_on=f"siren:{siren}",
                               suggested_target="organization_events"))
    n = len([s for s in entity.get("sirens", []) if norm_siren(s)])
    ctx.status("bodacc", "ok" if not errors else ("partial" if ok else "unavailable"),
               sirens_requested=n, sirens_fetched=ok, notices=len(out), errors=errors)
    return out
