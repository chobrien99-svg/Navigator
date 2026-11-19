"""Atlas engine command line.

    python3 -m atlas entity --entity atlas/entities/nvidia.json [--sources registry,bodacc] [--out DIR]

Single-entity mode (docs/entity-search/SPEC.md). List and topic modes
(docs/atlas_engine_design.md) will be added as further subcommands.
"""
import argparse
import datetime as dt
import importlib
import json
import os
import sys

from .core import RunContext
from .report import write_report

SOURCES = ["navigator", "registry", "bodacc", "scanr_projects", "patents", "hal", "lobbying", "procurement"]
REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))


def cmd_entity(args):
    with open(args.entity) as f:
        entity = json.load(f)
    day = dt.date.today().isoformat()
    out = args.out or os.path.join(REPO, "data", "atlas_runs", f"entity-{entity['key']}", day)
    ctx = RunContext(entity, out)
    findings = []
    for name in (args.sources.split(",") if args.sources else SOURCES):
        mod = importlib.import_module(f".sources.{name}", __package__)
        ctx.log(f"{name}: start")
        try:
            got = mod.enrich(entity, ctx)
        except Exception as e:  # a broken module must not sink the run
            ctx.status(name, "failed", errors=[f"{type(e).__name__}: {e}"])
            ctx.log(f"{name}: FAILED {e}")
            continue
        findings += got
        ctx.log(f"{name}: {len(got)} findings ({ctx.sources.get(name, {}).get('status')})")
    from .sources import navigator
    known = navigator.annotate(findings, navigator.load(entity))
    ctx.log(f"already in Navigator: {known} findings")
    findings.sort(key=lambda x: (x["type"], x["date"] or "", x["finding_id"]))
    manifest = ctx.write(findings)
    write_report(out, entity, manifest, findings)
    ctx.log(f"done: {len(findings)} findings -> {out}")
    return 0 if all(s["status"] == "ok" for s in manifest["sources"].values()) else 2


def cmd_review(args):
    from .loader import review
    counts = review(args.run)
    print("decisions:", counts, "->", os.path.join(args.run, "decisions.json"), "and review.md")
    return 0


def cmd_load(args):
    from .loader import load
    path, used = load(args.run, args.out)
    print("accepted findings by type:", used, "->", path)
    return 0


def main(argv=None):
    ap = argparse.ArgumentParser(prog="atlas")
    sub = ap.add_subparsers(dest="cmd", required=True)
    e = sub.add_parser("entity", help="search every source for one organisation")
    e.add_argument("--entity", required=True, help="entity JSON file")
    e.add_argument("--sources", help="comma-separated subset of: " + ",".join(SOURCES))
    e.add_argument("--out", help="output folder")
    r = sub.add_parser("review", help="write or update the review decisions for a run")
    r.add_argument("--run", required=True, help="run folder")
    ld = sub.add_parser("load", help="write load.sql from accepted findings (does not touch the database)")
    ld.add_argument("--run", required=True, help="run folder")
    ld.add_argument("--out", help="output SQL file (default: <run>/load.sql)")
    args = ap.parse_args(argv)
    return {"entity": cmd_entity, "review": cmd_review, "load": cmd_load}[args.cmd](args)


if __name__ == "__main__":
    sys.exit(main())
