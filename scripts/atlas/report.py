"""Human-readable review report (report.md) for an entity run."""
import os

TYPE_TITLES = {
    "legal_entity": "Registered companies", "financials": "Filed accounts", "officer": "Officers",
    "establishment": "Sites (openings and closures)", "legal_notice": "Legal notices (BODACC)",
    "eu_project": "Research projects", "patent": "Patents", "research_paper": "Co-written research papers (HAL)",
    "funding_acknowledgement": "Papers naming the entity as a funder (HAL)", "hal_structure": "HAL structures (to confirm)",
    "lobbying_registration": "Lobbying register: own registration", "lobbying_client": "Lobbying register: listed as client or member",
    "lobbying_action": "Lobbying register: actions on its behalf", "public_contract": "Public contracts",
    "related_entity_candidate": "Other companies with a matching name (to check)",
    "navigator_record": "Already in Navigator",
}
ORDER = list(TYPE_TITLES)


def _eur(x):
    return f"€{x:,.0f}" if isinstance(x, (int, float)) and x else ""


def write_report(out, entity, manifest, findings):
    L = [f"# {entity['display_name']}: entity search", "",
         f"Run {manifest['started_at']} to {manifest['finished_at']}. "
         f"{manifest['findings']} findings; {manifest.get('already_in_navigator', 0)} already in Navigator "
         f"(marked ✓); {manifest['needs_review']} new findings need review.", "",
         "## Sources", "", "| Source | Status | Detail |", "|---|---|---|"]
    for name, s in manifest["sources"].items():
        detail = ", ".join(f"{k}: {v}" for k, v in s.items() if k not in ("status", "errors"))
        if s.get("errors"):
            detail += f" · errors: {len(s['errors'])} (first: {s['errors'][0][:120]})"
        L.append(f"| {name} | **{s['status']}** | {detail} |")
    by = {}
    for f_ in findings:
        by.setdefault(f_["type"], []).append(f_)
    for t in ORDER + sorted(set(by) - set(ORDER)):
        items = by.get(t)
        if not items:
            continue
        L += ["", f"## {TYPE_TITLES.get(t, t)} ({len(items)})", ""]
        if t == "eu_project":
            fr = [i for i in items if i["facts"].get("has_focus_partner")]
            L.append(f"{len(fr)} of {len(items)} projects include a partner in {entity.get('focus_country', 'FR')}. "
                     f"EU money to {entity['display_name']}: {_eur(sum(i['facts']['entity_eur'] for i in items))} in all, "
                     f"{_eur(sum(i['facts']['entity_eur'] for i in fr))} in projects with such a partner; "
                     f"those partners received {_eur(sum(i['facts']['focus_partners_eur'] for i in fr))}.")
            L += ["", "| Start | Project | To entity | Partners | To partners | Match |", "|---|---|---|---|---|---|"]
            for i in items:
                parts = "; ".join(c["name"] for c in i["counterparts"]) or "none"
                known = " ✓" if i.get("in_navigator") else ""
                L.append(f"| {(i['date'] or '')[:7]} | [{i['facts']['acronym']}]({i['source']['url']}){known} | {_eur(i['facts']['entity_eur'])} | "
                         f"{parts} | {_eur(i['facts']['focus_partners_eur'])} | {i['match']['level']} ({i['match']['on']}) |")
            continue
        L += ["| Date | Finding | Detail | Match |", "|---|---|---|---|"]
        for i in items:
            title = f"[{i['title']}]({i['source']['url']})" if i["source"].get("url") else i["title"]
            flag = " ✓ in Navigator" if i.get("in_navigator") else (" ⚠ review" if i["match"]["needs_review"] else "")
            L.append(f"| {i['date'] or ''} | {title} | {i['summary']} | {i['match']['level']}{flag} |")
    with open(os.path.join(out, "report.md"), "w") as f:
        f.write("\n".join(L) + "\n")
