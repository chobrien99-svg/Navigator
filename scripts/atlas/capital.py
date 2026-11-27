"""Capital check: compare BODACC share-capital increases with the funding rounds and deals
Navigator already holds.

BODACC notices state a company's share capital (the face value of its shares, not the money
raised). A jump in share capital means new shares were issued: a funding round, shares used to
pay for an acquisition, a conversion of convertible notes, or employees exercising options.

For each SIREN, notices are put in date order and every increase is measured against the last
known capital. Increases below MIN_PCT are treated as option exercises and ignored.
Each larger increase becomes a `capital_increase` finding, matched one-to-one:
  1. to a Navigator funding round (equity stages only) announced up to ROUND_BEFORE days before
     or ROUND_AFTER days after the notice; the earliest unmatched notice after a round wins;
  2. otherwise to a Navigator acquisition or merger event within EVENT_WINDOW days;
  3. otherwise it is "unexplained": a lead for the Radar review queue (signal_candidates).
Matched increases are marked in_navigator (nothing to load).
"""
import datetime as dt

from .core import finding

MIN_PCT = 5.0
ROUND_BEFORE = 30      # a notice can precede the press announcement by a few weeks
ROUND_AFTER = 300      # notices are usually published weeks or months after closing
EVENT_WINDOW = 120
NON_EQUITY = {"debt", "grant", "loan", "subsidy", "ico", "crowdfunding_debt"}
DETAIL = "https://www.bodacc.fr/pages/annonces-commerciales-detail/?q.id=id:{}"


def _d(s):
    try:
        return dt.date.fromisoformat(str(s)[:10])
    except (TypeError, ValueError):
        return None


def increases(findings):
    """Share-capital increases of at least MIN_PCT, per SIREN, in date order."""
    by = {}
    for f in findings:
        if f["type"] == "legal_notice" and f["facts"].get("capital_eur"):
            by.setdefault(f["subject"].get("siren"), []).append(f)
    out = []
    for siren, rows in by.items():
        rows.sort(key=lambda f: (f["date"] or "", f["finding_id"]))
        prev = None
        for f in rows:
            cap = f["facts"]["capital_eur"]
            if prev and cap > prev:
                pct = (cap - prev) / prev * 100
                if pct >= MIN_PCT:
                    out.append({"notice": f, "siren": siren, "before": prev, "after": cap, "pct": pct})
            prev = cap
    return out


def check(findings, data, ctx):
    """Return capital_increase findings and record a status line for the run."""
    if data is None or "rounds" not in data:
        ctx.status("capital_check", "skipped", reason="Navigator export has no funding rounds (re-run sql/navigator_entity_export.sql)")
        return []
    ups = increases(findings)
    rounds = sorted([r for r in data.get("rounds") or [] if _d(r.get("date")) and (r.get("stage") or "") not in NON_EQUITY],
                    key=lambda r: r["date"])
    deals = [e for e in data.get("events") or [] if e.get("type") in ("acquisition", "merger") and _d(e.get("date"))]
    # 1. rounds: each round takes the earliest unmatched increase in its window
    for r in rounds:
        rd = _d(r["date"])
        for u in ups:
            nd = _d(u["notice"]["date"])
            if "match" not in u and nd and -ROUND_BEFORE <= (nd - rd).days <= ROUND_AFTER:
                u["match"] = ("funding_round", r)
                break
    # 2. acquisitions and mergers
    for u in ups:
        if "match" in u:
            continue
        nd = _d(u["notice"]["date"])
        near = [e for e in deals if abs((nd - _d(e["date"])).days) <= EVENT_WINDOW]
        if near:
            u["match"] = ("event", min(near, key=lambda e: abs((nd - _d(e["date"])).days)))
    out = []
    for u in ups:
        n = u["notice"]
        nid = n["source"]["external_id"]
        name = n["subject"].get("name") or ctx.entity["display_name"]
        kind, what = u.get("match", (None, None))
        if kind == "funding_round":
            expl = f"matches the {what.get('stage') or 'funding'} round dated {what['date']} in Navigator"
        elif kind == "event":
            expl = f"matches \"{what['title']}\" ({what['date']}) in Navigator"
        else:
            expl = "no funding round or deal in Navigator explains it"
        f = finding(ctx, connector="capital_check", type="capital_increase", ext_id=nid,
                    title=f"{name}: share capital up {u['pct']:.0f}% (€{u['before']:,.0f} → €{u['after']:,.0f})",
                    summary=f"BODACC notice of {n['date']}; {expl}.",
                    date=n["date"], subject=n["subject"],
                    facts={"capital_before_eur": u["before"], "capital_after_eur": u["after"], "pct": round(u["pct"], 1),
                           "notice_id": nid, "notice_summary": n["summary"],
                           "explained_by": kind, "explained_by_id": (what or {}).get("id"),
                           "explained_by_label": (what or {}).get("title") or (what or {}).get("stage")},
                    source_name="BODACC share capital, compared with Navigator", url=DETAIL.format(nid),
                    match_on=f"siren:{u['siren']}", level="high",
                    suggested_target=None if kind else "signal_candidates")
        f["in_navigator"] = bool(kind)
        out.append(f)
    unexplained = sum(1 for f in out if not f["in_navigator"])
    ctx.status("capital_check", "ok", increases_checked=len(ups), matched_round=sum(1 for u in ups if u.get("match", ("",))[0] == "funding_round"),
               matched_deal=sum(1 for u in ups if u.get("match", ("",))[0] == "event"), unexplained=unexplained,
               threshold_pct=MIN_PCT)
    return out
