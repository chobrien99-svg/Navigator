# Entity search pilot 2: Iktos

**Date:** 18 November 2026. **Why Iktos:** a small French start-up (AI drug discovery, Paris), to check the tool isn't shaped around NVIDIA. **Baseline:** the TechBio research already in Navigator (EU grants, receivership, patents).

```bash
cd scripts && python3 -m atlas entity --entity atlas/entities/iktos.json
python3 -m atlas review --run ../data/atlas_runs/entity-iktos/2026-11-18
python3 -m atlas load   --run ../data/atlas_runs/entity-iktos/2026-11-18
```

The entity file has just one name and one SIREN: no hand-tuning.

## Result

All eight sources ran `ok` in about two minutes: **73 findings**, **6 already in Navigator**, **11 to review**.

| Source | Findings | Against what Navigator holds |
|---|---|---|
| registry | 1 company, 2022 accounts, 6 officers, 5 sites | Company already held. **New:** site history (Paris 15e → Paris 17e in 2019; Villebon-sur-Yvette 2022–Aug 2026; Évry 2024; Longjumeau from Aug 2026) |
| bodacc | 30 notices | Receivership notice (22 Oct 2026) already held. **New:** registration (Oct 2016), 13 capital increases 2017–2024, governance changes, and accounts filings to 2025 |
| scanr_projects | 4 EU entries | CARE, MELLODDY and AIR-3D (€2,499,616) all already held. One extra AIR-3D entry with no funding, left for review |
| patents | 1 | Already held (matched by patent number). Navigator has 2 more that aren't in the scanR dump yet (2025 filings) |
| hal | 7 papers, 3 HAL structures | **New:** 7 co-written papers (Institut Curie, Mines Paris, Inserm…), all name matches, so left for review |
| lobbying, procurement | 0 | Correct: Iktos isn't on the lobbying register or in public contracts |

## Fixes the pilot forced

1. **Patents in another language.** Navigator stores Iktos's patents under French titles; scanR has English ones. The matcher now also compares patent numbers.
2. **Two BODACC link formats.** Navigator stored the receivership under the old BODACC URL. The matcher now treats both formats as the same notice. (Checked: no change to the NVIDIA run.)
3. **Flaky BODACC again.** The first attempt failed after six tries; the report said `unavailable` rather than showing zero notices, and a rerun succeeded.

## Loader

`review` decided: accept 25, pending 8, skip 31, reject 9 (accounts filings). `load.sql` has 27 inserts: 5 site openings + 2 closures, 20 BODACC notices. A sample (opening, closure, two notices with apostrophes) was dry-run against the database and rolled back without errors; the NVIDIA file (34 inserts) was dry-run in the same way earlier.

## What to improve next

- **Notice titles.** "Modifications diverses: Iktos" ×15 would clutter the timeline. Better: title capital increases "Capital increase" and consider grouping them, or use them as hints of funding rounds to check against Navigator's rounds.
- **HAL papers** with Iktos as an organisation name only: allow the reviewer to confirm a HAL structure ID (as done for NVIDIA) so future runs match on identifier.

## Loaded (22 November 2026)

Notice titles were rewritten into plain English (e.g. "Capital increase (Iktos)", "Management change (NVIDIA Ltd)"), and the loader now accepts an editor's `title_override` in `decisions.json`. Two NVIDIA "sites" that were really foreign head offices (UK and Hong Kong, listed by the register as "abroad") are now rejected by default.

Applied as `supabase/migrations/phase38/30_atlas_entity_nvidia.sql` (29 events, NVIDIA Singapore's French registration, 1 paper) and `31_atlas_entity_iktos.sql` (27 events). Checked after loading: the rows in the database hash-match the migration files.

## Capital check (27 November 2026)

Comparing the share capital in Iktos's BODACC notices with its funding rounds in Navigator:

| Notice | Share capital | Change | Explained by |
|---|---|---|---|
| Aug 2017 | €12,870 → €14,449 | +12% | Seed, June 2017 |
| Jan 2018 | → €16,352 | +13% | **Nothing**: added to the Radar queue as a pending lead |
| Aug 2019 | → €19,849 | +21% | Seed, 2019 |
| 2021–2022 (7 notices), Jul 2023 | small steps | under 0.3% each | Not rounds (option exercises) |
| May 2023 | → €56,291 | +181% | Series A, March 2023 (€15.5M) |
| Jun 2024 | → €64,913 | +15% | **Synsight acquisition** (8 July 2024), which Navigator lacked: now added (`phase38/32`) |

The Synsight deal is confirmed by Debiopharm's press release. The register also shows Iktos opening a site in Évry (where Synsight was based) on 28 June 2024. For January 2018, note that Navigator records Iktos joining the Agoranov incubator in February 2018. The tool now runs this check automatically; on the rerun (`2026-11-27`) it reproduced the table above exactly.
