"""French public procurement (DECP, consolidated tabular file by Colmo, data.gouv.fr).

Findings: public_contract.
Matching, in order:
  high    the contract holder's SIRET starts with one of the entity's SIRENs
  medium  the contract holder's name matches the entity's names
  low     the entity's name or one of its `product_terms` appears in the contract subject
          (e.g. a DGX server bought through a reseller). Product terms are ambiguous
          ("DGX" is also a customs code), so these always need review.
Note: many records give only the holder's SIRET, not its name, so the SIREN check matters.
"""
import csv
import datetime as dt
import gzip
import re

from ..core import download, finding, norm_siren, NameMatcher, SourceUnavailable

NAME = "DECP (données essentielles de la commande publique), consolidated by Colmo"
FILE_URL = "https://www.data.gouv.fr/fr/datasets/r/22847056-61df-452d-837d-8b8ceadbfc52"
DATASET = "https://www.data.gouv.fr/fr/datasets/608c055b35eb4e6ee20eb325/"

csv.field_size_limit(10**8)


def _num(x):
    try:
        return float(x)
    except (TypeError, ValueError):
        return None


def enrich(entity, ctx):
    try:
        path = download(FILE_URL, f"decp_{dt.date.today().strftime('%Y-%m')}.csv.gz", timeout=3600)
    except SourceUnavailable as e:
        ctx.status("procurement", "unavailable", errors=[str(e)])
        return []
    sirens = {norm_siren(s) for s in entity.get("sirens", []) if norm_siren(s)}
    names = NameMatcher(entity.get("names", []), entity.get("name_exclusions", []))
    terms = [(t, re.compile(r"(?<![\w])" + re.escape(t) + r"(?![\w])")) for t in entity.get("product_terms", [])]  # case-sensitive
    needles = [n.lower() for n in entity.get("names", [])] + [t.lower() for t in entity.get("product_terms", [])] + list(sirens)
    out, seen, rows = [], set(), 0
    with gzip.open(path, "rt", encoding="utf-8", errors="replace") as f:
        header = next(csv.reader([f.readline()]))
        for line in f:
            rows += 1
            low = line.lower()
            if not any(n in low for n in needles):
                continue
            r = dict(zip(header, next(csv.reader([line]))))
            holder_siren = norm_siren(r.get("titulaire_id"))
            how = None
            if holder_siren in sirens:
                how, on, level = "identifier", f"siret:{r.get('titulaire_id')}", "high"
            elif names.matches(r.get("titulaire_nom")):
                how, on, level = "name", names.matches(r.get("titulaire_nom")), "medium"
            else:
                subj = r.get("objet") or ""
                hit = names.matches(subj) or next((t for t, rx in terms if rx.search(subj)), None)
                if hit:
                    how, on, level = "subject", hit, "low"
            if not how:
                continue
            key = (r.get("id"), r.get("acheteur_id"), r.get("titulaire_id"))
            if key in seen:
                continue
            seen.add(key)
            ext = f"{r.get('acheteur_id')}:{r.get('id')}:{r.get('titulaire_id')}"
            ctx.save_raw("procurement", ext, DATASET, r)
            amt = _num(r.get("montant"))
            out.append(finding(ctx, connector="procurement", type="public_contract", ext_id=ext,
                               title=f"{r.get('acheteur_nom') or 'Public buyer'} → {r.get('titulaire_nom') or r.get('titulaire_id')}",
                               summary=(r.get("objet") or "")[:300], date=(r.get("dateNotification") or "")[:10] or None,
                               amount_eur=amt, amount_basis="contract value" if amt else None,
                               subject={"name": r.get("titulaire_nom"), "siren": holder_siren},
                               counterparts=[{"name": r.get("acheteur_nom"), "siren": norm_siren(r.get("acheteur_id")), "role": "buyer"}],
                               facts={"procedure": r.get("procedure"), "cpv": r.get("codeCPV"), "nature": r.get("nature"),
                                      "duration_months": r.get("dureeMois"), "contract_id": r.get("id")},
                               source_name=NAME, url=DATASET, match_method=how, match_on=on, level=level,
                               suggested_target="organization_events"))
    ctx.status("procurement", "ok", file=path.rsplit("/", 1)[-1], rows_scanned=rows, contracts=len(out))
    return out
