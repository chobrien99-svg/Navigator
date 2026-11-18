"""Compare an atlas entity run for NVIDIA with the manual investigation (12-13 Nov 2026).

    python3 -I scripts/atlas/pilot/compare_nvidia.py data/atlas_runs/entity-nvidia/<date>
"""
import json
import sys

run = sys.argv[1].rstrip("/")
F = json.load(open(run + "/findings.json"))
M = json.load(open(run + "/manifest.json"))
base = "data/nvidia_france_2026/sources/"
by = {}
for f in F:
    by.setdefault(f["type"], []).append(f)


def line(label, auto, manual, note=""):
    ok = "OK " if auto == manual else "DIFF"
    print(f"{ok:4} {label:52} auto={auto!s:>14}  manual={manual!s:>14}  {note}")


print("sources:", {k: v["status"] for k, v in M["sources"].items()})
print("findings by type:", M["findings_by_type"])
print("already in Navigator:", M.get("already_in_navigator"), "| new needing review:", M["needs_review"], "\n")

eu = by.get("eu_project", [])
fr = [f for f in eu if f["facts"]["has_focus_partner"]]
line("EU projects", len(eu), 24)
line("EU projects with French partners", len(fr), 14)
line("EU money to NVIDIA (all)", round(sum(f["facts"]["entity_eur"] for f in eu), 2), 5581439.32)
line("EU money to NVIDIA (French-partner projects)", round(sum(f["facts"]["entity_eur"] for f in fr), 2), 2376950.58)
line("EU money to French partners", round(sum(f["facts"]["focus_partners_eur"] for f in fr), 2), 12005167.78)
line("EU projects matched by name only", sum(1 for f in eu if f["match"]["level"] != "high"), 0, "(was 7 before step 1)")

papers = by.get("research_paper", [])
manual_hal = {d["uri_s"] for d in json.load(open(base + "hal_coauth.json"))}
auto_hal = {f["source"]["url"] for f in papers}
line("HAL co-written papers", len(papers), len(manual_hal),
     f"only auto {len(auto_hal - manual_hal)}, only manual {len(manual_hal - auto_hal)}")
line("HAL funding-field mentions", len(by.get("funding_acknowledgement", [])), len(json.load(open(base + "hal_funding.json"))))

pat = by.get("patent", [])
line("Patents with NVIDIA/Icera as applicant", len(pat), "11 (NVIDIA only)")
line("  of which with French-resident inventors", sum(1 for f in pat if f["facts"]["inventors_in_focus_country"]), "10")

lob = by.get("lobbying_action", []) + by.get("lobbying_client", []) + by.get("lobbying_registration", [])
print("\nlobbying:")
for f in lob:
    print("   ", f["type"], "|", f["title"][:70], "|", f["date"], "|", f["match"]["level"])
print("public contracts:")
for f in by.get("public_contract", []):
    print("   ", f["date"], "|", f["title"][:60], "|", f["amount_eur"], "|", f["match"]["level"], f["match"]["on"], "|", f["summary"][:70])
print("HAL structures:", [(f["facts"]["hal_struct_id"], f["title"]) for f in by.get("hal_structure", [])])
