# Entity search pilot: NVIDIA

**Date:** 17 November 2026. **Command:**

```bash
cd scripts && python3 -m atlas entity --entity atlas/entities/nvidia.json
```

**Output:** `data/atlas_runs/entity-nvidia/2026-11-17/` (`report.md`, `findings.json`, `manifest.json`, `raw/`).
**Baseline:** the manual NVIDIA investigation of 12–13 November 2026 (`data/nvidia_france_2026/`).

## Result

All three v0.1 modules ran without errors and produced **86 findings** in about a minute (15 seconds on a rerun, thanks to the cache).

| Module | Findings | Compared with the manual run |
|---|---|---|
| `registry` | 2 companies, 1 set of accounts, 8 officers, 9 sites, 1 related-company candidate | **Matches and adds.** Same companies, same 2024 accounts (revenue €27,090,409, net income €2,117,867). Adds two managing directors and both auditors, and the full site history. |
| `bodacc` | 41 legal notices | **Adds 29.** The manual run got the 12 notices for NVIDIA Ltd's branch but could not retrieve the research company's notices (connection resets). The module's retries got all 29. |
| `scanr_projects` | 24 EU projects | **Exact match.** Same 24 projects; same 14 with French partners; same totals to the cent: €5,581,439 to NVIDIA overall, €2,376,951 in projects with French partners, €12,005,168 to those French partners. |

## New facts the pilot found

1. **NVIDIA's French research company was Icera's French subsidiary.** BODACC shows SIREN 479 973 455 filing accounts as **Icera SARL** from 2007. In **October 2011**, after NVIDIA bought Icera, its name, legal form (SARL to SAS), address and manager all changed: it became NVIDIA Développement France.
2. **It never closed.** The register shows sites in Mougins (Dec 2004–May 2005), Valbonne (2005–2016) and Biot (from 25 March 2016, the day the Valbonne site closed). It filed accounts every year through the 2015 modem shutdown. The published article's line "a second start in Biot" was wrong and has been corrected.
3. **NVIDIA has had a French sales presence since July 2000**, in Levallois-Perret, then Courbevoie (La Défense) from January 2009.
4. **A third registered entity**, NVIDIA Singapore Pte. Ltd. (registered August 2026), was flagged for review, as designed.

## What needs review (8 items)

- **7 EU-project participations matched by name only.** NVIDIA Denmark ApS (six projects) and NVIDIA Développement France in STARS have no identifier in scanR that matches the entity file. All seven are real NVIDIA entities, so the reviewer should **add their scanR participant IDs to `entities/nvidia.json`**, after which they will match on identifier.
- **1 related company:** NVIDIA Singapore Pte. Ltd. Confirm and add its SIREN to the entity file.

No false matches got through. The exclusion list kept out INVIDIA Concept, Invidia Productions and Envidia Systems, which the manual run had to remove by hand.

## Lessons for v0.2

- **Register sites:** the API lists a company's sites only when the search text matches them, so a search by SIREN returns none. The module now makes a second search by the registered name. (Found during the pilot.)
- **Text-valued amounts:** some scanR funding values are strings. Handled; the module would otherwise have failed (and the run correctly reported it as failed rather than empty).
- **Personal data:** dates and years of birth are stripped from register records before anything is saved.
- **BODACC** worked this time; the retry logic is what made the difference.

## Next steps

1. Add the reviewed IDs to the entity file and rerun (should give 0 items needing review for EU projects).
2. Build the next modules in the order that adds the most: `navigator` (what we already hold), `procurement`, `hal`, `lobbying`, `patents`.
3. Build the loader: approved findings to an idempotent SQL migration (`legacy_source = 'atlas:entity:<key>'`).
4. Pilot a second, smaller entity (a French start-up) to check the modules aren't NVIDIA-shaped.
