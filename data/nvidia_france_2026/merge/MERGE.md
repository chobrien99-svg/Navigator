# Merge: NVIDIA public-records run × FTJ Ghost archive run

**Date:** 12 November 2026
**Run A (this branch, `claude/practical-mendel-jhvnio`):** public records. The company register, BODACC, scanR/CORDIS, HAL, the HATVP lobbying register, public-procurement data (DECP), ANR and research-ministry data, the Navigator database, and press search results. Files are in `data/nvidia_france_2026/`.
**Run B (`claude/beautiful-einstein-7j80lm`):** FTJ's own published posts in Ghost: 136 of 1,040 posts mention "nvidia". Its files were copied unchanged into `docs/handoffs/nvidia-ghost-coverage-2026-11-12/`.

## 1. How the handoff's merge steps apply

The handoff assumes both runs are Ghost queries joined on `ghost_id`. They aren't: run A holds no Ghost posts at all. So the article-level reconciliation gives an expected, harmless result:

| Handoff step | Result |
|---|---|
| 1. Join on `ghost_id` | Run A has no Ghost records, so nothing to join. Posts in both: 0. Only in B: 136. Only in A: 0. |
| 2. Snapshot date | Both runs are dated 12 Nov 2026. B's newest post is from 12 Nov 2026 (La Machine #100). |
| 3. Scope | A uses no Ghost data. B covers published posts only. Every label below says which run it came from. |
| 4. Counts | See above. No "only here" posts exist, because the runs measure different things. |
| 5. Deduplicate stories | Applied to B's posts when matching findings (§2). Counts are posts, not unique stories. |
| 6. Keep both sets of labels | Run A's categories (investment, compute, research and so on) are kept. B's phases and themes are left untouched in `analysis.md`. |

The useful merge sits at the level of **findings**. For each finding in run A, `build_merge.py` searches B's text snippets for matching FTJ posts. The output is `coverage_matrix.csv`, with post counts, first and last dates, an example URL and every matching `ghost_id`. B's snippets only cover about 440 characters around each "nvidia" mention, so these counts understate FTJ's real coverage. They measure coverage that mentions NVIDIA, not all coverage of a topic.

## 2. Coverage matrix: highlights (run A findings checked against FTJ posts)

**Well covered by FTJ:** Mistral AI rounds (23 posts), Macron and the Élysée (9), the Hugging Face acquisition (7), quantum partnerships (7), Nemotron (7), Scaleway (6), the AI campus (6), Scintil and Pigment (5 each), and Wandercraft (5).

**Found in public records but never covered by FTJ in connection with NVIDIA (11), as possible story leads:**
- NVIDIA's own French R&D company at Sophia Antipolis: 2024 revenue €27.1M, 50–99 staff. This answers part of B's gap 4, "how many people does Nvidia employ in France".
- Brunswick's lobbying for NVIDIA over the Arm takeover in 2020–21 (HATVP register).
- 14 EU research projects pairing NVIDIA with French partners: €2.38M of EU money to NVIDIA and €12.0M to the French partners (10 further projects had no French partner).
- About 295 French papers thanking NVIDIA for donated GPUs.
- The Moon Surgical Series B, co-led by NVentures in 2023. This is NVIDIA's earliest French venture deal on record, and FTJ's investment table misses it.
- Public compute purchases: Ifremer's DGX A100 (€274k), GENCI's Dalia system, and TotalEnergies' Pangea 5.
- Sofinnova's DGX Cloud credits, the L'Oréal partnership, and Owkin.

## 3. Checking B's investment list against Navigator (B's open item)

Every company in B's Phase 3 table now has a matching record in Navigator. The two runs agree on Mistral (×3), Scintil, Alice & Bob, Gradium, AMI Labs, Doctolib, Pigment, Genesis AI and Entalpic.

| Item | Run B (FTJ) | Run A / Navigator | Resolution |
|---|---|---|---|
| Moon Surgical | Not listed | NVentures co-led a $55.4M Series B, May 2023 | Add to the FTJ list |
| Hugging Face Series D | Covered Sep–Oct 2023, but not in the Phase 3 table | $235M Series D, Aug 2023, NVIDIA a participant | Add to the list |
| Poolside | Reported "up-to-$1bn commitment" (Bloomberg, Nov 2025) | Series B Oct 2024, NVIDIA a participant. The $1bn is noted but unconfirmed. | Both are right. Present the $1bn as reported, not closed. |
| Hugging Face deal status | `analysis.md` says "followed through to the closed deal (Sept 4)" | Agreement announced 3 Sep 2026, closing expected H1 2027 | **Correct B's analysis.** FTJ's own posts say "agreed to buy" and "by next year, it will be part of Nvidia". The deal is agreed, not closed. |
| Hugging Face price | $12.93bn. A 2 Sep La Machine also cites a Bloomberg report of $14bn. | About $12.9bn | Consistent. Use $12.93bn as announced. |
| AI campus (MGX/Bpifrance/Mistral) | €50bn (Nov 2025), €35bn (May 2026) | Reported ~€8.5bn, 1.4 GW | **Conflict.** The figures probably measure different things (first phase versus full build-out). Check before quoting any of them. |
| Mistral × NVIDIA model | Co-developing the Nemotron 4 base model | Founding member of the Nemotron Coalition (Mar 2026) | Consistent. B is more specific. |

## 4. Found by run B only (now added to the report)

- **Antitrust:** France's competition authority raided NVIDIA's Paris office in late September 2023. Its president confirmed the probe in 2024. In July 2026 the regulator said the investigation was "nearing its end", with no statement of objections (*notification de griefs*) announced (The Next Web, AFP). No decision was found as of 12 Nov 2026. Run A didn't catch this because the regulator's decisions aren't in the datasets it searched.
- Sesterce's H100 supercomputer in Marseille (Nov 2024); OVHcloud's H100 instances (2023); the HPE × NVIDIA "AI factory" in Grenoble (Dec 2025); Weytop's technology alliance with NVIDIA; and Pollen Robotics, which will come to NVIDIA with Hugging Face.
- Criticism: NVIDIA's emissions (James Martin's column), bubble risk, and the Megaspeed chip-diversion and espionage story around Alice Huang (La Machine #100). That story is the background to Jensen Huang's resignation on 12 Nov 2026.

## 5. Database

Loaded into Navigator on 12 Nov 2026 (migration phase38/26): the antitrust raid (2023) and "nearing its end" update (2026) as NVIDIA events; the Sesterce Marseille supercomputer; the HPE × NVIDIA Grenoble AI Factory Lab; and Hugging Face's April 2025 acquisition of Pollen Robotics.
