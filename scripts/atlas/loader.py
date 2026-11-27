"""Review decisions and SQL loader for entity runs.

    python3 -m atlas review --run DIR   # writes/updates DIR/decisions.json and DIR/review.md
    python3 -m atlas load --run DIR     # writes DIR/load.sql from accepted findings

decisions.json maps finding_id -> {"decision": accept|pending|reject|skip, "reason": ...}.
Editors change "pending" to "accept" or "reject". Decisions are kept when review is rerun,
so a refresh only asks about new findings.

load.sql is idempotent: every row carries legacy_source 'atlas:entity:<key>' and
legacy_id = finding_id (or a NOT EXISTS guard where the table has no legacy columns), so
running it twice changes nothing. Nothing is written to the database by this module.
"""
import json
import os

NOT_LOADABLE = {
    "navigator_record": "already stored",
    "financials": "no table for annual accounts yet",
    "officer": "people records are created by hand",
    "funding_acknowledgement": "kept as research evidence only",
    "hal_structure": "goes into the entity file, not the database",
    "related_entity_candidate": "decide by hand whether it belongs to the entity",
}


def default_decision(f):
    if f.get("in_navigator"):
        return "skip", "already in Navigator"
    if f["type"] in NOT_LOADABLE:
        return "skip", NOT_LOADABLE[f["type"]]
    if f["type"] == "establishment" and f["title"].lower().endswith("site in abroad"):
        return "reject", "registered office outside France, not a French site"
    if f["type"] == "capital_increase":
        return "accept", "unexplained share issue: goes to the Radar review queue as a pending lead"
    if f["type"] == "legal_notice" and f["facts"].get("family") == "dpc":
        return "reject", "routine filing of annual accounts"
    if f["type"] == "eu_project" and not f["facts"].get("has_focus_partner"):
        return "pending", "no partner in the focus country"
    if f["match"]["needs_review"]:
        return "pending", f"{f['match']['level']} match on {f['match']['on']}"
    return "accept", "identifier match"


NOTICE_CHANGES = [  # (text in the BODACC notice, plain-English label), in display order
    ("capital (augmentation)", "capital increase"),
    ("capital (réduction)", "capital reduction"),
    ("capital (diminution)", "capital reduction"),
    ("dénomination", "name change"),
    ("adresse du siège", "head office move"),
    ("transfert de l'établissement principal", "head office move"),
    ("forme juridique", "change of legal form"),
    ("administration", "management change"),
    ("représentant", "management change"),
]


def notice_title(f):
    """A readable event title for a BODACC notice, e.g. "Capital increase (Iktos)"."""
    s = (f.get("summary") or "").lower()
    fam = (f.get("facts") or {}).get("family")
    name = f["title"].split(": ", 1)[-1].strip().replace(" LTD", " Ltd")
    if fam == "override":
        return f["title"]
    if fam in ("creation", "immatriculation"):
        what = "Registered after moving its head office" if "transfert" in s else "Company registered"
    elif fam == "collective":
        what = ("Receivership opened" if "redressement" in s else "Liquidation" if "liquidation" in s
                else "Safeguard procedure" if "sauvegarde" in s else "Insolvency proceedings")
    elif fam == "radiation":
        what = "Removed from the trade register"
    elif fam == "vente":
        what = "Sale or transfer of a business"
    else:
        labels = []
        for needle, label in NOTICE_CHANGES:
            if needle in s and label not in labels:
                labels.append(label)
        if not labels:
            return f["title"]
        what = labels[0] if len(labels) == 1 else ", ".join(labels[:-1]) + " and " + labels[-1]
        what = what[0].upper() + what[1:]
    return f"{what} ({name})"


def review(run):
    findings = json.load(open(os.path.join(run, "findings.json")))
    path = os.path.join(run, "decisions.json")
    old = json.load(open(path)) if os.path.exists(path) else {}
    dec, new = {}, 0
    for f in findings:
        if f["finding_id"] in old:
            dec[f["finding_id"]] = old[f["finding_id"]]
            continue
        d, why = default_decision(f)
        dec[f["finding_id"]] = {"decision": d, "reason": why, "type": f["type"], "title": f["title"][:120]}
        new += 1
    json.dump(dec, open(path, "w"), ensure_ascii=False, indent=1)
    counts = {}
    for v in dec.values():
        counts[v["decision"]] = counts.get(v["decision"], 0) + 1
    L = ["# Review decisions", "", f"{len(dec)} findings ({new} new since the last review): "
         + ", ".join(f"{k} {v}" for k, v in sorted(counts.items())) + ".", "",
         "Edit `decisions.json`: change `pending` to `accept` or `reject` (and add `title_override` to reword a title). Then run `python3 -m atlas load --run <this folder>`.", ""]
    byid = {f["finding_id"]: f for f in findings}
    for want in ("pending", "accept"):
        rows = [(k, v) for k, v in dec.items() if v["decision"] == want]
        if not rows:
            continue
        L += [f"## {want.capitalize()} ({len(rows)})", "", "| Type | Date | Finding | Why |", "|---|---|---|---|"]
        for k, v in sorted(rows, key=lambda kv: (kv[1]["type"], byid.get(kv[0], {}).get("date") or "")):
            f = byid.get(k, {})
            L.append(f"| {v['type']} | {f.get('date') or ''} | {v['title']} | {v['reason']} |")
        L.append("")
    open(os.path.join(run, "review.md"), "w").write("\n".join(L))
    return counts


# ---------------------------------------------------------------- SQL

def q(x):
    if x is None:
        return "NULL"
    if isinstance(x, (int, float)):
        return repr(x)
    return "'" + str(x).replace("'", "''") + "'"


def _org(slug):
    return f"(SELECT id FROM organizations WHERE slug = {q(slug)})"


def _event(slug, key, fid, etype, date, title, desc, url, source_type, source_name, level):
    return (f"INSERT INTO organization_events (id, organization_id, event_type, event_date, title, description, source_url, "
            f"source_type, source_name, verification_status, legacy_source, legacy_id, created_at, updated_at)\n"
            f"SELECT uuid_generate_v4(), {_org(slug)}, {q(etype)}::event_type, {q(date)}::date, {q(title[:300])}, {q(desc)}, {q(url)}, "
            f"{q(source_type)}, {q(source_name)}, {q(level)}, {q('atlas:entity:' + key)}, {q(fid)}, NOW(), NOW()\n"
            f"WHERE {_org(slug)} IS NOT NULL AND NOT EXISTS (SELECT 1 FROM organization_events WHERE legacy_id = {q(fid)});")


def _date(d):
    if not d:
        return None
    return d if len(d) == 10 else (d + "-01" if len(d) == 7 else d + "-01-01")


def sql_for(f, slug, key):
    t, fid, fx, src = f["type"], f["finding_id"], f["facts"], f["source"]
    lvl = f["match"]["level"]
    out = []
    if t == "legal_entity":
        s = f["subject"]
        out.append(f"INSERT INTO legal_entities (id, organization_id, legal_name, siren, incorporation_date, naf_code, country, is_primary, "
                   f"verification_status, legacy_source, legacy_id, created_at, updated_at)\n"
                   f"SELECT uuid_generate_v4(), {_org(slug)}, {q(s.get('name'))}, {q(s.get('siren'))}, {q(_date(f['date']))}::date, {q(fx.get('naf'))}, "
                   f"'France', FALSE, 'high', {q('atlas:entity:' + key)}, {q(fid)}, NOW(), NOW()\n"  # French register; seat may be abroad
                   f"WHERE {_org(slug)} IS NOT NULL AND NOT EXISTS (SELECT 1 FROM legal_entities WHERE siren = {q(s.get('siren'))});")
    elif t == "establishment":
        town = f["title"].split("site in ", 1)[-1]
        opens = f["title"] if fx.get("family") == "override" else f"Opens a site in {town.title()}"
        out.append(_event(slug, key, fid, "expansion", _date(f["date"]), opens,
                          f"{f['subject'].get('name')}: {f['summary']}. Address: {fx.get('address')}", src["url"], "registry", src["name"], lvl))
        if fx.get("closed"):
            out.append(_event(slug, key, fid + ":closed", "other", _date(fx["closed"]), f"Closes its site in {town.title()}",
                              f"{f['subject'].get('name')}: site opened {f['date']}, closed {fx['closed']}.", src["url"], "registry", src["name"], lvl))
    elif t == "capital_increase":
        # an unexplained share issue: a lead for the Radar review queue, never a confirmed round
        org = _org(slug)
        out.append(f"INSERT INTO signal_candidates (id, organization_id, source, source_url, source_name, source_published_at, raw_title, raw_excerpt, "
                   f"signal_type, title, description, signal_date, strength, confidence, ai_reasoning, status, created_at)\n"
                   f"SELECT uuid_generate_v4(), {org}, 'bodacc', {q(src['url'])}, 'BODACC', {q(_date(f['date']))}::timestamptz, "
                   f"{q('BODACC: Modifications diverses – ' + str(f['subject'].get('name')))}, "
                   f"{q(fx.get('notice_summary', '') + '; capital €' + format(fx['capital_before_eur'], ',.0f') + ' → €' + format(fx['capital_after_eur'], ',.0f'))}, "
                   f"'fundraising'::signal_type, {q('Possible unannounced share issue: ' + f['title'])}, "
                   f"{q('BODACC shows new shares were issued (share capital +' + format(fx['pct'], '.0f') + '%), but Navigator has no funding round or deal that explains it. Could be an unannounced round, shares used to pay for a deal, or a note conversion. The amount raised is unknown: BODACC gives only the nominal capital.')}, "
                   f"{q(_date(f['date']))}::date, {2 if fx['pct'] < 15 else 3}, 0.4, "
                   f"{q('Atlas capital check: increases of 5% or more are compared one-to-one with recorded rounds (up to 30 days before to 300 days after the notice) and with acquisitions or mergers (120 days).')}, "
                   f"'pending', NOW()\n"
                   f"WHERE {org} IS NOT NULL AND NOT EXISTS (SELECT 1 FROM signal_candidates WHERE source_url = {q(src['url'])} AND organization_id = {org});")
    elif t == "legal_notice":
        s = f["summary"].lower()
        et = "rebrand" if "dénomination" in s else ("shutdown" if "liquidation" in s else "other")
        out.append(_event(slug, key, fid, et, _date(f["date"]), notice_title(f), f"BODACC notice: {f['summary']}", src["url"], "official_gazette", src["name"], lvl))
    elif t == "eu_project":
        pslug = "eu-" + str(fx["acronym"]).lower().replace(" ", "-")
        out.append(f"INSERT INTO projects (id, name, slug, summary, sector, commercialization_status, first_evidence_date, is_public, website_url, created_at, updated_at)\n"
                   f"SELECT uuid_generate_v4(), {q(fx['acronym'])}, {q(pslug)}, {q(f['title'] + '. ' + f['summary'])}, 'EU research', 'research', "
                   f"{q(_date(f['date']))}::date, FALSE, {q(src['url'])}, NOW(), NOW()\n"
                   f"WHERE NOT EXISTS (SELECT 1 FROM projects WHERE slug = {q(pslug)});")
        out.append(f"INSERT INTO project_links (id, project_id, organization_id, role, start_date, end_date, status, created_at)\n"
                   f"SELECT uuid_generate_v4(), p.id, {_org(slug)}, {q('coordinator' if any(x.get('role') == 'coordinator' for x in fx['entity_participants']) else 'partner')}, "
                   f"{q((fx.get('start') or '')[:10] or None)}::date, {q((fx.get('end') or '')[:10] or None)}::date, 'verified', NOW()\n"
                   f"FROM projects p WHERE p.slug = {q(pslug)} AND {_org(slug)} IS NOT NULL\n"
                   f"  AND NOT EXISTS (SELECT 1 FROM project_links l WHERE l.project_id = p.id AND l.organization_id = {_org(slug)});")
        if fx.get("entity_eur"):
            out.append(f"INSERT INTO grants (id, organization_id, grant_name, granting_body, amount_eur, awarded_date, program, description, source_url, created_at, updated_at)\n"
                       f"SELECT uuid_generate_v4(), {_org(slug)}, {q(str(fx.get('programme') or 'EU') + ' – ' + str(fx['acronym']))}, 'European Commission', "
                       f"{q(fx['entity_eur'])}, {q(_date(f['date']))}::date, {q(fx.get('programme'))}, {q('EU contribution, from scanR/CORDIS. ' + f['summary'])}, {q(src['url'])}, NOW(), NOW()\n"
                       f"WHERE {_org(slug)} IS NOT NULL AND NOT EXISTS (SELECT 1 FROM grants WHERE organization_id = {_org(slug)} AND source_url = {q(src['url'])});")
    elif t == "research_paper":
        out.append(f"INSERT INTO articles (id, title, url, source_name, published_date, summary, language, created_at, updated_at)\n"
                   f"SELECT uuid_generate_v4(), {q(f['title'][:500])}, {q(src['url'])}, 'HAL (research paper)', {q(_date(f['date']))}::date, {q(f['summary'])}, 'en', NOW(), NOW()\n"
                   f"WHERE NOT EXISTS (SELECT 1 FROM articles WHERE url = {q(src['url'])});")
        out.append(f"INSERT INTO article_organizations (id, article_id, organization_id, created_at)\n"
                   f"SELECT uuid_generate_v4(), a.id, {_org(slug)}, NOW() FROM articles a WHERE a.url = {q(src['url'])} AND {_org(slug)} IS NOT NULL\n"
                   f"  AND NOT EXISTS (SELECT 1 FROM article_organizations x WHERE x.article_id = a.id AND x.organization_id = {_org(slug)});")
    elif t == "patent":
        out.append(f"INSERT INTO patents (id, organization_id, patent_number, title, abstract, filing_date, grant_date, patent_office, status, url, created_at, updated_at)\n"
                   f"SELECT uuid_generate_v4(), {_org(slug)}, {q(fx.get('family') or src['external_id'])}, {q(f['title'][:500])}, {q(f['summary'])}, "
                   f"{q(_date(f['date']))}::date, {q((fx.get('granted') or '')[:10] or None)}::date, 'scanR (INPI/EPO)', {q('granted' if fx.get('granted') else 'filed')}, {q(src['url'])}, NOW(), NOW()\n"
                   f"WHERE {_org(slug)} IS NOT NULL AND NOT EXISTS (SELECT 1 FROM patents WHERE organization_id = {_org(slug)} AND url = {q(src['url'])});")
    elif t in ("lobbying_registration", "lobbying_client", "lobbying_action"):
        out.append(_event(slug, key, fid, "other", _date(f["date"]), f["title"], f["summary"], src["url"], "registry", src["name"], lvl))
    elif t == "public_contract":
        amt = f" Value €{f['amount_eur']:,.0f}." if f.get("amount_eur") else ""
        out.append(_event(slug, key, fid, "other", _date(f["date"]), f"Public contract: {f['title']}"[:300], f["summary"] + amt,
                          src["url"], "registry", src["name"], lvl))
    return out


def load(run, out_path=None):
    findings = json.load(open(os.path.join(run, "findings.json")))
    manifest = json.load(open(os.path.join(run, "manifest.json")))
    entity = manifest["entity"]
    path = os.path.join(run, "decisions.json")
    if not os.path.exists(path):
        raise SystemExit("No decisions.json: run `python3 -m atlas review --run DIR` first.")
    dec = json.load(open(path))
    slug, key = entity["navigator_slug"], entity["key"]
    stmts, used = [], {}
    for f in findings:
        if dec.get(f["finding_id"], {}).get("decision") != "accept":
            continue
        d = dec[f["finding_id"]]
        if d.get("title_override"):  # an editor's wording wins over the generated title
            f = {**f, "title": d["title_override"], "facts": {**f["facts"], "family": "override"}}
        s = sql_for(f, slug, key)
        if s:
            stmts.append(f"-- {f['finding_id']}\n" + "\n".join(s))
            used[f["type"]] = used.get(f["type"], 0) + 1
    head = (f"-- Atlas entity load: {entity['display_name']} ({slug})\n-- Run: {os.path.basename(run.rstrip('/'))}; "
            f"accepted findings by type: {json.dumps(used)}\n-- Idempotent: legacy_source 'atlas:entity:{key}' / NOT EXISTS guards.\n")
    sql = head + "BEGIN;\n\n" + "\n\n".join(stmts) + "\n\nCOMMIT;\n"
    out_path = out_path or os.path.join(run, "load.sql")
    open(out_path, "w").write(sql)
    return out_path, used
