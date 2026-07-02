# Q2 2026 French Tech Funding — Data Analysis

> Raw analysis for the Q2 2026 (April–June 2026) French Tech Funding Report.
> Source: Navigator unified database (`funding_rounds`), project `oxqpmtttgicvxmesrjzy`.
> Primary comparison: Q2 2025. **Extended comparisons:** sequential Q1→Q2 2026 (§1A), every Q2
> from 2021–2026 (§1B), and mid-year H1 run-rate 2021–2026 (§1C).
> All euro amounts are in **€ millions** unless stated. Generated 2026-07-01.

---

## 0. The theme: **"Top-Heavy"**

**The tension:** Q2 2026 looks like a comeback — €2.09B raised, up 16% year-on-year (though still
23% below Q1's €2.73B). But almost all of that year-on-year growth is a single deal. Strip out Alan's €480M round and the quarter *contracted*
~11% YoY. Underneath the headline, the market is thinning: 17% fewer deals and seed rounds down a
third. AI remains the dominant sector by far (€1.21B across all its tags, ~58% of the quarter, a
six-year high) — but that too is one deal wide: Alan is tagged AI, HealthTech, FinTech *and*
InsurTech, so its €480M inflates four sector headlines at once (strip it and AI is down ~21%). What
grew was the top of the market: the average check rose 53% and the median 43%. Capital is
concentrating into fewer, larger, more multi-tagged rounds while the base erodes.

**One-line framing for the report intro:** *"French tech funding rose 16% year-on-year in Q2 2026.
It took exactly one deal to get there."*

**The five-year view sharpens it.** Q2 2026's €2.09B is a rebound off the 2025 low, but it sits
34% below the Q2 2022 peak (€4.58B) — and the market has been quietly restructuring the whole
time. Deal count has fallen in *every* Q2 since 2022 (315 → 271 → 244 → 167 → 139). Early-stage
(seed/pre-seed) rounds have more than halved (196 → 71). SaaS, the 2021–22 engine (€2.1B peak), has
collapsed to €356M. AI, by contrast, is at a six-year high (€1.21B all-tags) — still the sector that
eats everything, just increasingly through a handful of giant multi-tagged rounds. "Top-Heavy"
isn't a one-quarter blip — it's the shape of a five-year consolidation, and Q2 2026 is its clearest
expression yet: the single most concentrated top (one deal = 23% of the quarter) sitting on the
thinnest base on record.

---

## 1. Headline stats

| Metric | Q2 2026 | Q2 2025 | YoY |
|---|---|---|---|
| Total raised | **€2,094M (€2.09B)** | €1,810M (€1.81B) | **+15.7%** |
| Total rounds | **139** | 167 | **−16.8%** |
| Disclosed rounds | 127 | 167 | — |
| Average round (disclosed) | **€16.5M** | €10.8M | **+52.8%** |
| Median round (disclosed) | **€5.0M** | €3.5M | **+42.9%** |
| Rounds ≥ €100M | **4** | 1 | +3 |
| Rounds ≥ €50M | 9 | 11 | −2 |

**Read:** More money, fewer deals, bigger checks — the "Great Concentration" of Q1 2026
deepens. The rise in *both* average and median (not just the mean) means the concentration
isn't only at the very top; the middle of the market is writing larger checks too, even as the
count of deals falls.

---

## 1A. Q1 → Q2 2026 (sequential, quarter-over-quarter)

The two quarters of 2026 so far, side by side:

| Metric | Q1 2026 | Q2 2026 | QoQ |
|---|---|---|---|
| Total raised | €2,733M | €2,094M | **−23.4%** |
| Rounds | 139 | 139 | **flat** |
| Disclosed rounds | 134 | 127 | — |
| Average (disclosed) | €20.4M | €16.5M | −19% |
| Median (disclosed) | €4.6M | **€5.0M** | **+9%** |
| Rounds ≥ €100M | 5 | 4 | −1 |
| Top deal | **AMI €890M** | **Alan €480M** | — |
| Paris share of value | €908M (33%) | €1,508M (72%) | — |
| Total **ex top-deal** | €1,843M | €1,614M | **−12.4%** |

**Read:**
- **Identical deal count (139), but Q2 raised 23% less.** Q1 was front-loaded by AMI's €890M round —
  the single largest French deal of the year — so the sequential "drop" is mostly the absence of a
  Q1-sized mega-round. Even stripping each quarter's top deal, Q2 was still down ~12% QoQ.
- **The median rose (€4.6M → €5.0M) even as the total fell** — the middle of the market kept getting
  bigger while the top thinned. Consistent with "Top-Heavy."
- **Paris's share swung from 33% to 72%** purely because of where the mega-deal sat: Q1's €890M
  leader (AMI) is outside Paris; Q2's €480M leader (Alan) is Parisian. A caution against reading too
  much into single-quarter geographic shares — one deal moves them 40 points.

---

## 1B. Six-year Q2 context (2021–2026)

The single most important addition to this report: every metric now has a five-year runway behind it.

### Q2 headline series, 2021–2026

| Q2 | Rounds | Total €M | Avg €M | Median €M | Rounds ≥€100M | Top deal | Top deal % of Q | Paris % of value |
|---|---|---|---|---|---|---|---|---|
| 2021 | 254 | 3,171 | 15.9 | 2.2 | 6 | Contentsquare €425M | 13.4% | 83% |
| **2022** | **315** | **4,583** | 17.3 | 4.0 | **10** | EcoVadis €475M | 10.4% | 73% |
| 2023 | 271 | 1,845 | 7.7 | 2.0 | 2 | Ynsect €161M | 8.7% | 54% |
| 2024 | 244 | 2,303 | 10.6 | 2.0 | 5 | Mistral AI €468M | 20.3% | 59% |
| 2025 | 167 | 1,810 | 10.8 | 3.5 | 1 | Knave €100M | 5.5% | 59% |
| **2026** | **139** | **2,094** | **16.5** | **5.0** | 4 | **Alan €480M** | **22.9%** | **72%** |

**What the long series shows:**
1. **The 2022 peak has not returned.** Q2 2026 (€2.09B) is 54% below Q2 2022 (€4.58B). The 2021–22
   boom was an outlier era, not a baseline.
2. **Deal count is in a secular decline** — down every year since 2022 (315 → 139, −56% over four
   years). This is the clearest single trend in the dataset.
3. **The median has climbed to a six-year high (€5.0M)** while deal count fell — the market is doing
   fewer, larger deals. In 2023–24 the median sat at €2.0M; it has now more than doubled.
4. **The recurring mega-deal.** Every Q2 has a flagship round — Contentsquare, EcoVadis, Ynsect,
   Mistral AI, Knave, Alan. What's new in 2026 is *dependence*: Alan is **22.9% of the quarter**,
   the highest single-deal share in six years (vs Mistral's 20.3% in 2024, and just 5.5% in 2025).
5. **Paris re-concentrated.** Paris's share of value fell to 54% in the 2023 trough but is back to
   72% — its highest since the 2021 boom.

### Full-year context (all quarters)

| Year | Rounds | Total €M | Notes |
|---|---|---|---|
| 2021 | 988 | 11,761 | Boom begins |
| **2022** | **1,248** | **14,708** | All-time peak |
| 2023 | 1,024 | 8,132 | Correction (−45%) |
| 2024 | 849 | 7,175 | Trough |
| 2025 | 642 | 7,882 | Flat |
| 2026 (H1) | 278 | 4,826 | Partial year (Jan–Jun) |

*Disclosure caveat: 2021–2024 have material undisclosed-amount rounds (e.g. 200/254 disclosed in
Q2 2021); 2025–2026 are fully disclosed. Totals for older years are therefore **conservative** —
the real gap to peak may be understated. Deal-count and share-of-total trends are unaffected.*

### Sector value by Q2, 2021–2026 (all sector tags, €M)

*Every deal counts under **all** its sector tags (see §5). Totals overlap; a deal tagged
AI + HealthTech + FinTech + InsurTech adds its full amount to each.*

| Sector | 2021 | 2022 | 2023 | 2024 | 2025 | 2026 | Arc |
|---|---|---|---|---|---|---|---|
| **Artificial Intelligence** | 973 | 391 | 760 | 1,052 | 928 | **1,210** | Dominant throughout; six-year high in '26 |
| **SaaS** | 1,576 | **2,109** | 362 | 350 | 639 | 356 | 2021–22 giant, then collapsed |
| **FinTech** | 858 | 528 | 156 | 84 | 442 | 780* | *Alan + Morpho lift '26 |
| **Health cluster** (Bio+Health+Med) | 548 | 717 | 598 | 218 | 505 | **960**† | †€480M is Alan; ex-Alan €480M |
| **CleanTech** | 92 | **877** | 119 | 529 | 383 | 170 | Volatile, cooling |
| **DeepTech** | 48 | 62 | 126 | 25 | 148 | **379** | Rising (quantum/Quobly) |
| **Cybersecurity** | 350 | 99 | 77 | 29 | 164 | 54 | Spiky; low again in '26 |

**Read:** On an all-tags basis the picture is the opposite of a "rotation away from AI." **AI has
been the largest or near-largest sector in every Q2, and 2026 (€1.21B) is its six-year high** — but
that headline is one deal wide: Alan (tagged AI, HealthTech, FinTech *and* InsurTech) adds €480M to
four sector lines at once, and strip it out and Q2 AI is €730M (below both 2024 and 2025). The one
unambiguous structural change is **SaaS**, the 2021–22 engine (€2.1B peak) now down to €356M. What
*genuinely* rose in 2026, outside the mega-deals, is **deeptech/quantum** (€379M, a six-year high).

### Stage structure by Q2, 2021–2026

| Stage | 2021 | 2022 | 2023 | 2024 | 2025 | 2026 |
|---|---|---|---|---|---|---|
| Seed/pre-seed — **deals** | 165 | **196** | 195 | 152 | 101 | **71** |
| Seed/pre-seed — €M | 282 | 447 | 480 | 549 | 316 | 232 |
| Series A — €M | 462 | 1,229 | 494 | 674 | 374 | 673 |
| Series B — €M | 493 | 820 | 296 | 526 | 284 | 151 |
| Growth — €M | 189 | 1,059 | 70 | — | 648 | 992 |

**The thinning base, quantified.** Seed/pre-seed deal count has fallen from a Q2 2022 peak of 196
to just 71 — a **−64% collapse in the number of early-stage rounds**. This is the structural core
of the "Top-Heavy" thesis: the funnel that feeds future Series A/B is contracting fast, even as
late-stage (Growth €992M) hits its second-highest level in six years.

---

## 1C. Mid-year run-rate: H1 2026 vs 2021–2025

With six months of 2026 in hand, the cleaner year-level question is how the **first half** (Jan–Jun)
compares across years — and whether 2026 is on pace to beat 2025.

### H1 (Jan–Jun) series, 2021–2026

| H1 | Rounds | Total €M | Avg €M | Median €M | ≥€100M | H1 as % of full year |
|---|---|---|---|---|---|---|
| 2021 | 506 | 5,242 | 14.1 | 2.5 | 10 | 45% |
| **2022** | **693** | **10,120** | 17.8 | 3.3 | **25** | 69% |
| 2023 | 549 | 3,769 | 8.0 | 2.6 | 5 | 46% |
| 2024 | 456 | 4,175 | 10.7 | 2.5 | 6 | 58% |
| 2025 | 343 | 3,316 | 9.7 | 3.0 | 3 | 42% |
| **2026** | **278** | **4,826** | **18.5** | **4.7** | 9 | — (year in progress) |

**H1 2026 vs H1 2025: +45.5% in euros (€3,316M → €4,826M) on 19% fewer deals (343 → 278).**

### Is 2026 on track to pass 2025? Yes — comfortably.

- 2025's **full year** was €7,882M. 2026 has already raised **€4,826M by June — 61% of the entire
  2025 total in half the time.**
- **Run-rate projections for full-year 2026:**
  - Even split (H1 = 50% of year): **~€9.7B**
  - Historical average H1 share (~52%, 2021–2025): **~€9.3B**
  - 2025's own H1 share (42%): **~€11.5B**
- Any of these clears 2025 (€7.9B) and 2024 (€7.2B), and would make 2026 the **strongest year since
  the 2022 peak (€14.7B)**. The €100M+ round count (9 in H1) already triples all of H1 2025 (3).

### The caveat (and it's the theme again)

The rebound is **outlier-driven**. Two deals — **AMI €890M (Q1) and Alan €480M (Q2) — are €1,370M,
or 28% of H1 2026's total.** They account for **~91% of the entire €1.5B year-on-year increase** over
H1 2025. Strip both out and H1 2026 (€3,456M) is only **~4% ahead** of H1 2025 (€3,316M) — essentially
flat. So: 2026 will very likely post a much bigger *headline* than 2025, but the underlying,
ex-mega-deal market is roughly flat, on **the fewest H1 deals in the six-year series**. Bigger
numbers, thinner base — the same story at every altitude.

### What's driving H1 2026 (sector value, all-tags, H1 2025 → H1 2026, €M)

| Sector | H1 2025 | H1 2026 | Note |
|---|---|---|---|
| Artificial Intelligence | 1,248 | **3,101** | +148% — but €1.37B is AMI + Alan; dominant sector |
| HealthTech | 298 | 1,190 | +299% — €480M is Alan; ex-Alan still +138% |
| FinTech | 704 | 1,179 | +68% — Alan + Morpho |
| SaaS | 997 | 839 | −16% |
| DeepTech | 420 | 704 | +68% — quantum/deeptech genuine |
| InsurTech | 60 | 619 | ~all Alan |
| BioTech | 435 | 558 | +28% |
| ClimateTech | 219 | 486 | +122% |
| CleanTech | 622 | 376 | −40% |
| Energy | 375 | 349 | −7% |
| Robotics | 84 | 305 | +265% |
| MedTech | 112 | 227 | +103% |

**Important cross-check with the Q2 view:** on all-tags, AI is not "cooling" at either altitude —
it is France's dominant sector and near record highs (Q2 2026 €1.21B is a six-year high; H1 2026
€3.10B). The Q2-only softness only appears **ex-Alan** (Q2 AI €730M, −21% YoY). Over the half-year,
even stripping *both* mega-rounds (AMI €890M + Alan €480M), AI (~€1.73B) is still **+39% on H1 2025**.
So the accurate statement is: **AI's headline is bigger than ever and increasingly concentrated in a
few giant, multi-tagged rounds** — not that capital rotated out of it. HealthTech's apparent surge
(+299% H1) is likewise heavily Alan; the genuine, non-mega risers are **deeptech/quantum** and
**health ex-Alan** (still up), which is what makes the health/biotech deep-dive worthwhile.

---

## 2. The outlier: Alan (€480M) and the "with / without" analysis

Alan — the Paris health-insurance unicorn — raised a **€480M growth round** (Index Ventures,
Prosus, Dara Holdings, Teachers' Venture Growth) announced in June. At **22.9% of the entire
quarter's disclosed total**, it is a textbook outlier (threshold: >25% of quarter; this sits
just under, but dominates every aggregate it touches).

| Metric | With Alan | Without Alan |
|---|---|---|
| Q2 2026 total | €2,094M | **€1,614M** |
| YoY vs Q2 2025 (€1,810M) | **+15.7%** | **−10.8%** |
| Q2 2026 average (disclosed) | €16.5M | €12.5M |

**The core finding:** the entire year-on-year *gain* is Alan. Without it, French tech funding
**fell ~11%** against Q2 2025. This is the single most important sentence in the report.

---

## 3. Monthly breakdown

| Month | Q2 2026 rounds | Q2 2026 €M | Q2 2025 rounds | Q2 2025 €M |
|---|---|---|---|---|
| April | 43 | €305M | 60 | €591M |
| May | 43 | €494M | 34 | €275M |
| June | **53** | **€1,295M** | 73 | €944M |
| **Total** | **139** | **€2,094M** | 167 | €1,810M |

**Read:** June carried the quarter — **€1,295M, or 62% of the total** — powered by Alan (€480M),
Morpho Labs (€151M) and Bionyra Pharma (€140M) landing in the same month. Even stripping Alan,
June (€815M) was still the strongest month. April was the weak point: €305M is roughly half of
April 2025's €591M, and the fewest euros of any month in the quarter.

---

## 4. Top 15 deals — Q2 2026

| # | Company | €M | Stage | Month | City |
|---|---|---|---|---|---|
| 1 | **Alan** | 480.0 | Growth | Jun | Paris |
| 2 | **Morpho Labs** | 151.1 | Growth | Jun | Paris |
| 3 | **Bionyra Pharma** | 140.0 | Series A | Jun | Paris |
| 4 | **Quobly** | 115.0 | Series A | Jun | Grenoble |
| 5 | LegalPlace | 70.0 | Growth | May | Paris |
| 6 | UROMEMS | 55.0 | Growth | May | Grenoble |
| 7 | Innovafeed | 51.0 | Growth | Jun | Paris |
| 8 | AURA AERO | 50.0 | Series B | Apr | Cugnaux |
| 9 | Alta Ares | 50.0 | Series A | Jun | Romainville |
| 10 | EVA | 35.0 | Growth | Apr | Montreuil |
| 11 | Dust | 34.6 | Series B | May | Paris |
| 12 | Pivot | 34.6 | Series B | May | Paris |
| 13 | Comand AI | 32.0 | Series A | Jun | Paris |
| 14 | Mantle8 | 31.0 | Series A | May | Grenoble |
| 15 | Tsuga | 30.0 | Series A | Jun | Paris |

Notable: **four rounds ≥ €100M** (Alan, Morpho, Bionyra, Quobly) vs just one a year ago (Knave,
€100M). Two of the top four (Bionyra, Quobly) are Series A — unusually large for the stage,
another sign of top-heavy capital.

### Top 15 deals — Q2 2025 (comparison)

| # | Company | €M | Stage | Month | City |
|---|---|---|---|---|---|
| 1 | Knave | 100.0 | Growth | Jun | Paris |
| 2 | Solveo Energie | 98.0 | Growth | Jun | Fenouillet |
| 3 | Animaj | 75.0 | Series C | Jun | Paris |
| 4 | Pennylane | 75.0 | Growth | Apr | Paris |
| 5 | Didomi | 72.0 | Growth | Apr | Paris |
| 6 | Intact | 70.0 | Growth | Apr | Olivet |
| 7 | Wandercraft | 65.6 | Growth | Jun | Paris |
| 8 | Nabla | 63.6 | Series C | Jun | Paris |
| 9 | Zama | 51.8 | Series B | Jun | Paris |
| 10 | Look Up Space | 50.0 | Series A | Jun | Toulouse |
| 11 | Groupe Archipel | 50.0 | Growth | Apr | Paris |
| 12 | Tinubu Square | 40.9 | Growth | May | Issy-les-Moulineaux |
| 13 | Pelico | 40.0 | Series B | Jun | Paris |
| 14 | Veesion | 38.0 | Series B | May | Paris |
| 15 | VSORA | 36.4 | Growth | May | Vélizy-Villacoublay |

**Read:** Q2 2025's top end was flatter — the biggest deal was €100M and the top 15 clustered
between €36M and €100M. Q2 2026's top is spikier: one €480M deal, then a steep drop.

---

## 5. Sector analysis (all sector tags)

> **Methodology (changed from the earlier draft):** every deal is counted under **all** of its
> sector tags, not one "primary" sector. A round tagged AI + HealthTech + FinTech + InsurTech
> (e.g. Alan) adds its full €480M to each of those four lines. Sector totals therefore **overlap and
> sum to more than the quarter's €2.09B** — they measure how much capital *touched* each sector, not
> a partition of the total. The earlier primary-sector-only version understated cross-cutting sectors
> (above all AI) and produced a misleading "AI −54%."

### Q2 2026 (all-tags)

| Sector | Deals | €M |
|---|---|---|
| **Artificial Intelligence** | 70 | **1,210** |
| HealthTech | 22 | 843 |
| FinTech | 14 | 780 |
| InsurTech | 5 | 495 |
| DeepTech | 26 | 379 |
| SaaS | 43 | 356 |
| ClimateTech | 27 | 305 |
| BioTech | 14 | 289 |
| Hardware | 9 | 267 |
| CleanTech | 15 | 170 |
| MedTech | 11 | 166 |
| DefenseTech | 8 | 164 |
| Quantum Computing | 2 | 115 |

*AI touches €1.21B — ~58% of the quarter's €2.09B. Of that, €480M is Alan alone (also counted in
HealthTech, FinTech and InsurTech).*

### Q2 2025 (all-tags)

| Sector | Deals | €M |
|---|---|---|
| Artificial Intelligence | 67 | 928 |
| SaaS | 36 | 639 |
| FinTech | 25 | 442 |
| CleanTech | 20 | 383 |
| Hardware | 16 | 315 |
| BioTech | 19 | 304 |
| Energy | 13 | 245 |
| HealthTech | 21 | 201 |
| Cybersecurity | 7 | 164 |
| DeepTech | 10 | 148 |

### Key sector YoY moves (all-tags)

| Sector | Q2'25 €M | Q2'26 €M | Δ value | Note |
|---|---|---|---|---|
| **Artificial Intelligence** | 928 | **1,210** | **+30%** | ex-Alan €730M (−21%); six-year-high headline |
| **HealthTech** | 201 | 843 | +319% | €480M is Alan; ex-Alan €363M (+80%) |
| **FinTech** | 442 | 780 | +76% | Alan €480M + Morpho €151M |
| **InsurTech** | 37 | 495 | +1,238% | ~all Alan |
| **DeepTech** | 148 | 379 | +156% | quantum/Quobly — genuine |
| **SaaS** | 639 | 356 | −44% | genuine decline |
| **CleanTech** | 383 | 170 | −56% | |
| **Cybersecurity** | 164 | 54 | −67% | Q1 deep-dive sector, faded |

**The big sector story (restated): AI still eats everything.** On an all-tags basis AI is the
quarter's dominant sector by a wide margin — **€1.21B, ~58% of all value, a six-year high, up 30%
YoY** — with deal count (70) flat-to-up. The "AI −54%" in the earlier draft was purely an artifact of
counting each deal under one primary sector, which pushed Alan (and other AI-plus companies) out of
the AI line. **The real story is concentration, not rotation:** Alan's €480M is tagged AI, HealthTech,
FinTech *and* InsurTech, so a single deal lifts four sector headlines at once. Strip Alan and AI is
€730M — **down ~21% YoY** — so the *underlying* AI market did soften, but the sector is so large and
cross-cutting that "AI declined" is the wrong headline. The **genuine, non-mega risers** are
deeptech/quantum (Quobly €115M, €379M sector total, a six-year high) and health ex-Alan (+80%);
**SaaS (−44%), CleanTech (−56%) and cybersecurity (−67%) genuinely fell.**

---

## 6. Stage analysis

| Stage | Q2'26 deals | Q2'26 €M | Q2'25 deals | Q2'25 €M | Δ value |
|---|---|---|---|---|---|
| Growth | 27 | **992** | 22 | 648 | +53% |
| Series A | 29 | **673** | 29 | 374 | +80% |
| Seed | **57** | 202 | **91** | 294 | −31% |
| Series B | 6 | 151 | 10 | 284 | −47% |
| Series C | 1 | — | 3 | 145 | — |
| Series D | 1 | 30 | — | — | — |
| Pre-seed | 14 | 30 | 10 | 22 | +36% |

**The structural story: the base is thinning, the top is swelling.**
- **Seed collapsed**: 91 → 57 deals (−37%), €294M → €202M (−31%). The classic French seed engine
  slowed markedly.
- **Series A swelled**: same deal count (29) but +80% in value — Series A checks are getting much
  bigger (Bionyra €140M and Quobly €115M are Series A rounds).
- **Growth up 53%** — the top end is where the money went.

---

## 7. Geographic analysis

### Paris vs Regions

| | Q2 2026 deals | Q2 2026 €M | Q2 2025 deals | Q2 2025 €M |
|---|---|---|---|---|
| **Paris** | 75 (54%) | **€1,508M (72%)** | 83 (50%) | €1,076M (59%) |
| **Regions** | 64 (46%) | €586M (28%) | 84 (50%) | €734M (41%) |

**Read:** Paris's share of *value* jumped from 59% to 72% — largely Alan (Paris). But even
ex-Alan, Paris held €1,028M / 64% of value. Regional funding **fell 20%** in absolute terms
(€734M → €586M). Concentration is geographic too.

### Top regional hubs, Q2 2026

| City | Deals | €M | Driven by |
|---|---|---|---|
| **Grenoble** | 5 | **238** | Quobly €115M, UROMEMS €55M, Mantle8 €31M, ROSI €20M |
| Cugnaux | 1 | 50 | AURA AERO €50M |
| Romainville | 1 | 50 | Alta Ares €50M |
| Montreuil | 1 | 35 | EVA €35M |
| Lyon | 7 | 25 | (spread) |
| Bordeaux | 5 | 23 | (spread) |

**Grenoble is the region's standout** — a genuine deeptech/quantum/medtech cluster (€238M across
five deals), second only to Paris this quarter.

---

## 8. Investor activity (Q2 2026, by deal count)

| Investor | Deals |
|---|---|
| **Bpifrance** | **22** |
| Business Angels (aggregate) | 8 |
| daphni | 5 |
| Kima Ventures | 5 |
| Y Combinator | 4 |
| Blast Club | 4 |
| Lita | 4 |
| Banque des Territoires | 4 |
| SWEN Capital Partners | 3 |
| European Innovation Council | 3 |
| Partech · Singular · Eurazeo · Founders Future · France 2030 | 3 each |

**Read:** Public capital anchors the ecosystem — **Bpifrance touched 22 of 139 deals (16%)**,
more than 4× any private fund. The public backbone (Bpifrance, Banque des Territoires, EIC,
France 2030, Banque des Territoires) is disproportionately present in the thinning early stage,
where private money pulled back.

---

## 9. Sector deep-dive candidate: Health cluster (BioTech + HealthTech + MedTech)

*(Chosen for the Q2 deep-dive. Full profiled write-up to follow the template in section 9 of the
guide.)*

| | Q2 2026 | Q2 2025 |
|---|---|---|
| Deals | 32 | 39 |
| Disclosed | 29 | 39 |
| Total (incl. Alan*) | €960M | €505M |
| **Total ex-Alan** | **€480M** | €505M |
| Average (disclosed) | €33.1M | €12.9M |

\* Alan carries a HealthTech tag as well as FinTech, so it appears in the health-cluster query.
For the deep-dive, treat Alan separately: **core** health/biotech raised **€480M across 31 deals**,
roughly flat vs €505M / 39 deals a year ago — again, **fewer deals, bigger checks**.

**Standout health/biotech deals, Q2 2026:**
- **Bionyra Pharma** — €140M Series A (Sanofi Ventures, Jeito, Sofinnova, Apollo Health) — the
  pure-biotech headline of the quarter, one of the largest French biotech Series A rounds on record.
- **UROMEMS** — €55M growth (Ajax Health Fund), Grenoble — smart implantable for urinary incontinence.
- **Tissium** — €30M Series D, Paris — programmable biomorphic polymers for tissue repair.
- **Sêmeia** (€21M), **Sonomind** (€20M, ultrasound-guided AI), **Lucis** (€17.2M, YC/General
  Catalyst), **SQUAREMIND** (€15.3M, skin imaging), **Crossject** (€15M needle-free injection).

**Deep-dive angle:** France's health/biotech is maturing into large, later, strategically-backed
rounds (Sanofi Ventures, Ajax Health). Ex-Alan, the health cluster (€480M) is the quarter's most
credible non-mega growth story — genuine breadth (Bionyra, UROMEMS, Tissium) rather than one giant
cross-tagged round. It doesn't come at AI's expense — AI is at a six-year high — but it is the
clearest sign of a second engine forming alongside it.

---

## 10. Data notes & reproducibility

- **Schema note:** the live Navigator DB uses `organizations` / `funding_rounds` /
  `organization_sectors` / `cities` with `announced_date` (a DATE), **not** the
  `companies` / `announced_month` / `hq_city_name` fields shown in the guide's illustrative
  pseudo-code. Queries in this analysis reflect the real schema.
- **Amount units:** `funding_rounds.amount_eur` is stored in **€ millions**.
- **Quarter windows:** Q2 = `announced_date BETWEEN 'YYYY-04-01' AND 'YYYY-06-30'`.
- **Historical scope:** the six-year series (section 1B) covers every Q2 from 2021–2026 from the
  same `funding_rounds` table. **Disclosure improves over time** — 2021–2024 have material
  undisclosed-amount rounds (≈20% in 2021), while 2025–2026 are fully disclosed. Euro totals for
  older years are therefore conservative; count-based and share-based trends are robust.
- **Sector aggregation (all-tags):** each funding round is attributed to **every** sector its org is
  tagged with, via `funding_rounds ⋈ organization_sectors ⋈ sectors`, summing `amount_eur` per
  sector. A round's full amount lands in each of its tags, so **sector totals overlap and exceed the
  quarter total** — e.g. Alan (AI, HealthTech, FinTech, InsurTech) contributes €480M to all four.
  This replaces the earlier "one primary sector per org" method, which understated cross-cutting
  sectors (AI most of all). "Deals" per sector = `COUNT(DISTINCT funding_round_id)` carrying that tag.
  The health-cluster deep-dive (§9) de-duplicates rounds across Health/Bio/Med tags (distinct union).
- **Undisclosed rounds:** Q2 2026 had 12 rounds with no disclosed amount (139 total, 127 disclosed);
  averages/medians use disclosed rounds only.
- **Investor names:** taken from `funding_round_investors` (joined to `organizations`, falling back
  to the free-text `investor_name`); "Business Angels" is an aggregate label, not a single fund.

---

## Checklist status (from the guide)

- [x] Query Navigator DB for Q2 2026 (Apr–Jun) funding rounds
- [x] Query same DB for Q2 2025 comparison
- [x] Headline stats: total, deals, average, median, mega-rounds
- [x] Monthly breakdown (April, May, June)
- [x] Top 15 deals
- [x] Sector analysis with YoY
- [x] Stage analysis with YoY
- [x] Geographic analysis (cities, Paris vs regions)
- [x] Outlier "with/without" analysis (Alan €480M)
- [x] Sequential Q1 → Q2 2026 comparison (§1A)
- [x] Six-year Q2 historical series (2021–2026): headline, sector, stage, geography (§1B)
- [x] Mid-year H1 run-rate 2021–2026 + full-year 2026 projection (§1C)
- [x] Theme identified ("Top-Heavy")
- [x] Write Q2-2026-ANALYSIS.md
- [ ] Q2-2026-CONTENT-PLAN.md
- [ ] q2-2026-full-report.html
- [ ] Newsletter article
- [ ] Cover image
- [ ] Health-cluster deep-dive (sector chosen)
