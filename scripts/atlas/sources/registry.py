"""Company register (recherche-entreprises.api.gouv.fr, INSEE/INPI data).

Findings: legal_entity, financials, officer, establishment, related_entity_candidate.
Matching: SIREN exact (high). Name search finds other entities using the entity's
names; those are review-only candidates (low).
"""
from ..core import http_json, finding, norm_siren, NameMatcher, SourceUnavailable

NAME = "Recherche d'entreprises (INSEE/INPI)"
API = "https://recherche-entreprises.api.gouv.fr/search"
PAGE = "https://annuaire-entreprises.data.gouv.fr/entreprise/{}"

HEADCOUNT = {"NN": None, "00": "0", "01": "1–2", "02": "3–5", "03": "6–9", "11": "10–19", "12": "20–49",
             "21": "50–99", "22": "100–199", "31": "200–249", "32": "250–499", "41": "500–999",
             "42": "1,000–1,999", "51": "2,000–4,999", "52": "5,000–9,999", "53": "10,000+"}
PRIVATE_KEYS = {"date_de_naissance", "annee_de_naissance"}  # never stored


def _strip_private(obj):
    if isinstance(obj, dict):
        return {k: _strip_private(v) for k, v in obj.items() if k not in PRIVATE_KEYS}
    if isinstance(obj, list):
        return [_strip_private(v) for v in obj]
    return obj


def _lookup(siren):
    data = http_json(API, {"q": siren, "per_page": 5})
    for r in data.get("results", []):
        if r.get("siren") == siren:
            return _strip_private(r)
    return None


def _sites(siren, name):
    """The API only lists sites that match the query text, so search by the registered name."""
    if not name:
        return []
    data = http_json(API, {"q": name, "per_page": 25, "limite_matching_etablissements": 100})
    for r in data.get("results", []):
        if r.get("siren") == siren:
            return _strip_private(r.get("matching_etablissements") or [])
    return []


def enrich(entity, ctx):
    out = []
    sirens = [norm_siren(s) for s in entity.get("sirens", []) if norm_siren(s)]
    errors, found = [], 0
    for siren in sirens:
        try:
            r = _lookup(siren)
        except SourceUnavailable as e:
            errors.append(str(e))
            continue
        if not r:
            errors.append(f"SIREN {siren} not found")
            continue
        found += 1
        url = PAGE.format(siren)
        ctx.save_raw("registry", siren, url, r)
        siege = r.get("siege") or {}
        name = r.get("nom_complet") or r.get("nom_raison_sociale")
        band = HEADCOUNT.get(r.get("tranche_effectif_salarie"))
        band_year = r.get("annee_tranche_effectif_salarie")
        city = siege.get("libelle_commune") or siege.get("libelle_commune_etranger")
        subj = {"name": name, "siren": siren, "country": "FR" if not siege.get("code_pays_etranger") else "foreign"}
        summary = ", ".join(x for x in [
            f"activity {r.get('activite_principale')}" if r.get("activite_principale") else None,
            f"seat: {city}" if city else None,
            f"{band} staff ({band_year})" if band else None,
            "closed" if r.get("etat_administratif") == "C" else "active"] if x)
        out.append(finding(ctx, connector="registry", type="legal_entity", ext_id=siren, title=name,
                           summary=summary, date=r.get("date_creation"), subject=subj, source_name=NAME,
                           url=url, match_on=f"siren:{siren}", suggested_target="legal_entities",
                           facts={"legal_form_code": r.get("nature_juridique"), "naf": r.get("activite_principale"),
                                  "headcount_band": band, "headcount_year": band_year,
                                  "seat_address": siege.get("adresse"), "status": r.get("etat_administratif"),
                                  "establishments_open": r.get("nombre_etablissements_ouverts")}))
        for year, fin in sorted((r.get("finances") or {}).items()):
            out.append(finding(ctx, connector="registry", type="financials", ext_id=f"{siren}:{year}",
                               title=f"{name}: {year} accounts",
                               summary=f"Revenue €{fin.get('ca'):,}; net income €{fin.get('resultat_net'):,}" if fin.get("ca") is not None and fin.get("resultat_net") is not None else "Accounts filed",
                               date=str(year), amount_eur=fin.get("ca"), amount_basis="revenue", subject=subj,
                               facts=fin, source_name=NAME, url=url, match_on=f"siren:{siren}",
                               suggested_target="organization profile"))
        for d in r.get("dirigeants") or []:
            who = d.get("denomination") or " ".join(x for x in [d.get("prenoms"), d.get("nom")] if x)
            if not who:
                continue
            out.append(finding(ctx, connector="registry", type="officer", ext_id=f"{siren}:{who}:{d.get('qualite')}",
                               title=who, summary=f"{d.get('qualite') or 'officer'} of {name}",
                               subject=subj, facts={"role": d.get("qualite"), "kind": d.get("type_dirigeant")},
                               source_name=NAME, url=url, match_on=f"siren:{siren}",
                               suggested_target="organization_people"))
        try:
            sites = _sites(siren, r.get("nom_raison_sociale") or name)
        except SourceUnavailable as e:
            errors.append(f"sites for {siren}: {e}")
            sites = []
        for e in sites:
            siret = e.get("siret") or f"{siren}?{e.get('date_creation')}"
            where = e.get("libelle_commune") or e.get("libelle_commune_etranger") or "abroad"
            closed = e.get("date_fermeture")
            out.append(finding(ctx, connector="registry", type="establishment", ext_id=siret,
                               title=f"{name}: site in {where}",
                               summary=f"Opened {e.get('date_creation')}" + (f", closed {closed}" if closed else (", open" if e.get("etat_administratif") == "A" else ", closed")),
                               date=e.get("date_creation"), subject=subj,
                               facts={"siret": e.get("siret"), "address": e.get("adresse"), "naf": e.get("activite_principale"),
                                      "status": e.get("etat_administratif"), "closed": closed},
                               source_name=NAME, url=url, match_on=f"siren:{siren}",
                               suggested_target="organization_events"))

    # Related entities: same names, other SIRENs (review only)
    matcher = NameMatcher(entity.get("names", []), entity.get("name_exclusions", []))
    seen = set(sirens)
    for nm in entity.get("names", []):
        for page in (1, 2):
            try:
                data = http_json(API, {"q": nm, "per_page": 25, "page": page})
            except SourceUnavailable as e:
                errors.append(str(e))
                break
            for r in data.get("results", []):
                s = r.get("siren")
                label = r.get("nom_complet") or ""
                hit = matcher.matches(label)
                if not hit or s in seen:
                    continue
                seen.add(s)
                r = _strip_private(r)
                ctx.save_raw("registry", s, PAGE.format(s), r)
                out.append(finding(ctx, connector="registry", type="related_entity_candidate", ext_id=s, title=label,
                                   summary=f"Another registered company whose name contains '{hit}'. Check whether it belongs to {entity['display_name']}.",
                                   date=r.get("date_creation"), subject={"name": label, "siren": s},
                                   facts={"naf": r.get("activite_principale"), "status": r.get("etat_administratif"),
                                          "seat": (r.get("siege") or {}).get("adresse")},
                                   source_name=NAME, url=PAGE.format(s), match_method="name", match_on=hit,
                                   level="low", suggested_target="review"))
            if len(data.get("results", [])) < 25:
                break
    state = "ok" if not errors else ("partial" if found else "unavailable")
    ctx.status("registry", state, sirens_requested=len(sirens), sirens_found=found, errors=errors)
    return out
