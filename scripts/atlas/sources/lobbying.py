"""French lobbying register (HATVP répertoire des représentants d'intérêts), open data.

Findings:
  lobbying_registration  the entity is itself a registered lobbyist (SIREN or name)
  lobbying_client        a registered lobbyist (consultancy, association) lists the entity as a
                         client or member
  lobbying_action        declared lobbying actions carried out on the entity's behalf, grouped by
                         lobbyist, subject and reporting period
Matching: SIREN of the registrant or client (high); names (medium, needs review).
Spending brackets in the register belong to the lobbyist, not the client: never attributed to the entity.
"""
import csv
import datetime as dt
import gzip
import io

from ..core import download, finding, norm_siren, NameMatcher, SourceUnavailable

NAME = "HATVP lobbying register (répertoire des représentants d'intérêts)"
DATASET = "https://www.data.gouv.fr/fr/datasets/5d13692f634f41364f8929b8/"
INFO_URL = "https://www.data.gouv.fr/fr/datasets/r/971cae4b-7dbb-476a-bbb0-a346e32023de"
ACTIONS_URL = "https://www.data.gouv.fr/fr/datasets/r/e82814e6-d28a-43f2-86ef-ffbd0654b34f"
FICHE = "https://www.hatvp.fr/fiche-organisation/?organisation={}"

csv.field_size_limit(10**8)


def _rows(path):
    with gzip.open(path, "rt", encoding="utf-8", errors="replace") as f:
        yield from csv.DictReader(f)


def enrich(entity, ctx):
    month = dt.date.today().strftime("%Y-%m")
    try:
        info = download(INFO_URL, f"hatvp_info_{month}.csv.gz")
        actions = download(ACTIONS_URL, f"hatvp_actions_{month}.csv.gz")
    except SourceUnavailable as e:
        ctx.status("lobbying", "unavailable", errors=[str(e)])
        return []
    sirens = {norm_siren(s) for s in entity.get("sirens", []) if norm_siren(s)}
    m = NameMatcher(entity.get("names", []), entity.get("name_exclusions", []))
    out, seen = [], set()

    for r in _rows(info):
        rid, reg = r.get("representants_id"), r.get("denomination") or ""
        reg_id = norm_siren(r.get("identifiant_national"))
        url = FICHE.format(r.get("identifiant_national") or "")
        # entity registered in its own name
        hit = (reg_id in sirens and "identifier") or (m.matches(reg) and "name")
        if hit and ("reg", rid) not in seen:
            seen.add(("reg", rid))
            ctx.save_raw("lobbying", f"reg:{rid}", url, r)
            out.append(finding(ctx, connector="lobbying", type="lobbying_registration", ext_id=f"reg:{rid}",
                               title=f"{reg} is a registered lobbyist",
                               summary=f"First published {r.get('date_premiere_publication')}; category {r.get('label_categorie_organisation')}.",
                               date=_iso(r.get("date_premiere_publication")),
                               subject={"name": reg, "siren": reg_id}, source_name=NAME, url=url,
                               match_method=hit, match_on=reg_id if hit == "identifier" else reg,
                               level="high" if hit == "identifier" else "medium", suggested_target="organization_events"))
        # entity listed as a client or member of another registrant
        client = r.get("denomination_client") or ""
        cid = norm_siren(r.get("identifiant_national_client"))
        hit = (cid in sirens and "identifier") or (m.matches(client) and "name")
        if hit and ("client", rid, client) not in seen:
            seen.add(("client", rid, client))
            ctx.save_raw("lobbying", f"client:{rid}:{client}", url, {k: r.get(k) for k in (
                "representants_id", "denomination", "identifiant_national", "label_categorie_organisation",
                "denomination_client", "identifiant_national_client", "dateAjout", "dateCessation_y", "ancienClient")})
            added, ended = r.get("dateAjout"), r.get("dateCessation_y")
            out.append(finding(ctx, connector="lobbying", type="lobbying_client", ext_id=f"client:{rid}:{cid or client}",
                               title=f"{reg} lists {client} as a client or member",
                               summary=f"{r.get('label_categorie_organisation') or 'Registrant'}; added {added or 'n/a'}"
                                       + (f", ended {ended}" if ended else "") + ".",
                               date=_iso(added), subject={"name": client, "siren": cid},
                               counterparts=[{"name": reg, "siren": reg_id, "role": "lobbyist"}],
                               facts={"lobbyist_category": r.get("label_categorie_organisation"), "added": added, "ended": ended},
                               source_name=NAME, url=url, match_method=hit, match_on=cid if hit == "identifier" else client,
                               level="high" if hit == "identifier" else "medium", suggested_target="organization_relationships"))

    groups = {}
    for r in _rows(actions):
        ben = r.get("beneficiaire_action_menee") or ""
        own = norm_siren(r.get("identifiant_national")) in sirens
        hit = m.matches(ben)
        if not (hit or own):
            continue
        key = (r.get("representants_id"), r.get("objet_activite"), r.get("annee_debut"), r.get("annee_fin"))
        g = groups.setdefault(key, {"lobbyist": r.get("denomination"), "lobbyist_id": r.get("identifiant_national"),
                                    "beneficiary": ben, "subject": r.get("objet_activite"),
                                    "domains": set(), "targets": set(), "ministries": set(), "actions": set(),
                                    "period": (r.get("date_debut"), r.get("date_fin")), "how": "identifier" if own else "name",
                                    "on": r.get("identifiant_national") if own else hit})
        for k, col in (("domains", "domaines_intervention_actions_menees"), ("targets", "responsable_public"),
                       ("ministries", "departement_ministeriel"), ("actions", "action_menee")):
            if r.get(col):
                g[k].add(r[col])
    for key, g in groups.items():
        ext = "action:" + ":".join(str(k) for k in key)
        ctx.save_raw("lobbying", ext, FICHE.format(g["lobbyist_id"] or ""), {k: sorted(v) if isinstance(v, set) else v for k, v in g.items()})
        out.append(finding(ctx, connector="lobbying", type="lobbying_action", ext_id=ext,
                           title=f"{g['lobbyist']} lobbying for {g['beneficiary']}",
                           summary=f"{g['subject']} — targets: {'; '.join(sorted(g['targets']))[:200]}"
                                   + (f"; ministries: {', '.join(sorted(g['ministries']))}" if g["ministries"] else ""),
                           date=g["period"][0], subject={"name": g["beneficiary"]},
                           counterparts=[{"name": g["lobbyist"], "siren": norm_siren(g["lobbyist_id"]), "role": "lobbyist"}],
                           facts={"subject": g["subject"], "period": g["period"], "domains": sorted(g["domains"]),
                                  "targets": sorted(g["targets"]), "ministries": sorted(g["ministries"]),
                                  "actions": sorted(g["actions"])},
                           source_name=NAME, url=FICHE.format(g["lobbyist_id"] or ""), match_method=g["how"], match_on=g["on"],
                           level="high" if g["how"] == "identifier" else "medium", suggested_target="organization_events"))
    ctx.status("lobbying", "ok", files=[info.rsplit("/", 1)[-1], actions.rsplit("/", 1)[-1]], findings=len(out))
    return out


def _iso(d):
    """'22-01-2021 16:36' or '22/01/2021' -> '2021-01-22'."""
    if not d:
        return None
    d = d.split(" ")[0].replace("/", "-")
    p = d.split("-")
    if len(p) == 3 and len(p[2]) == 4:
        return f"{p[2]}-{p[1]}-{p[0]}"
    return d[:10]
