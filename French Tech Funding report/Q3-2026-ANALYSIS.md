# Q3 2026 French Tech Funding — Data Analysis

> Raw analysis for the Q3 2026 (July–September 2026) French Tech Funding Report.
> Source: Navigator unified database (`funding_rounds`), project `oxqpmtttgicvxmesrjzy`.
> Primary comparison: Q3 2025. **Extended comparisons:** sequential Q2→Q3 2026 (§1A), every Q3
> from 2021–2026 (§1B), and **full-year context — 2026 YTD vs the past five complete years (§1C)**.
> All euro amounts are in **€ millions** unless stated. **Sectors use the all-tags method** (each
> deal counted under every sector it carries — see §10). Generated 2026-10-04.

---

## 0. The theme: **"The Mistral Singularity"**

**The tension:** Q3 2026 is, at the same time, **the biggest third quarter on record and the
thinnest.** French startups raised **€4.41B** — the highest Q3 in six years — on just **108 deals,
a six-year low.** The reconciliation is a single round: **Mistral AI's €3.0B Series D in September,
which is 68% of everything raised all quarter.** Strip it out and the quarter is €1.41B. If Q1's
"Great Concentration" and Q2's "Top-Heavy" (Alan at 23%) traced a market leaning ever harder on one
deal, Q3 is the limit case: **one company, two-thirds of the quarter.**

**One-line framing for the report intro:** *"French tech just raised its biggest quarter in years.
One company raised two-thirds of it."*

**The longer view sharpens it.** Q3 2026's €4.41B tops even the 2021 boom-era Q3 (€3.96B), yet deal
count has fallen every year since 2022 (237 → 191 → 187 → 125 → 108, −54%). Mistral has now been the
quarter's defining round **two years running** (€1.82B in Q3 2025, €3.0B in Q3 2026) — its single-deal
share climbing from 60% to 68%. Record money, record-low breadth, one name: the five-year
consolidation at its sharpest expression yet.

---

## 1. Headline stats

| Metric | Q3 2026 | Q3 2025 | YoY |
|---|---|---|---|
| Total raised | **€4,405M (€4.41B)** | €3,013M (€3.01B) | **+46.2%** |
| Total rounds | **108** | 125 | **−13.6%** |
| Disclosed rounds | 100 | 125 | — |
| Average round (disclosed) | **€44.0M** | €24.1M | **+82.6%** |
| Median round (disclosed) | **€4.4M** | €3.0M | **+46.7%** |
| Rounds ≥ €100M | 3 | 3 | — |
| Rounds ≥ €50M | 4 | 6 | −2 |

**Read:** More money on fewer, far bigger cheques. But both the average and the ≥€100M count are
carried by one round — Mistral's €3.0B. Only **three** deals cleared €100M (Mistral €3,000M, The
Exploration Company €387M, Skello €150M), and only one more cleared €50M. Beneath the top, the
market is narrow and quiet.

---

## 1A. Q2 → Q3 2026 (sequential, quarter-over-quarter)

| Metric | Q2 2026 | Q3 2026 | QoQ |
|---|---|---|---|
| Total raised | €2,107M | €4,405M | **+109%** |
| Rounds | 141 | 108 | **−23.4%** |
| Average (disclosed) | €16.5M | €44.0M | +167% |
| Median (disclosed) | €5.0M | €4.4M | −12% |
| Top deal | Alan €480M | **Mistral €3,000M** | — |
| Total **ex top-deal** | €1,627M | **€1,405M** | **−13.7%** |
| Paris share of value | 72% | **82%** | — |

**Read:** The headline doubled, but entirely on Mistral. Setting each quarter's top deal aside, Q3
was actually **down ~14% on Q2** — and the deal count fell another 23%. The median *slipped*. The
sequential story is the same as the annual one: a giant round on top of a thinning base.

---

## 1B. Six-year Q3 context (2021–2026)

### Q3 headline series

| Q3 | Rounds | Total €M | Avg €M | Median €M | ≥€100M | Top deal | Top % of Q |
|---|---|---|---|---|---|---|---|
| 2021 | 208 | 3,957 | 23.6 | 2.6 | 12 | Sorare €578M | 14.6% |
| 2022 | **237** | 2,280 | 11.4 | 2.3 | 5 | Contentsquare €380M | 16.7% |
| 2023 | 191 | 2,168 | 12.2 | 2.0 | 3 | Verkor €835M | 38.5% |
| 2024 | 187 | 1,539 | 10.2 | 2.3 | 4 | HR Path €250M | 16.2% |
| 2025 | 125 | 3,013 | 24.1 | 3.0 | 3 | **Mistral €1,818M** | 60.3% |
| **2026** | **108** | **4,405** | **44.0** | **4.4** | 3 | **Mistral €3,000M** | **68.1%** |

**What the series shows:**
1. **Highest Q3 ever (€4.41B), lowest deal count ever (108).** The two records belong to the same
   quarter — the "fewer, bigger" shape at its most extreme.
2. **Deal count has fallen every year since the 2022 peak** (237 → 108, −54%).
3. **The recurring giant is now a fixture.** Mistral topped Q3 in both 2025 and 2026, its share
   rising 60% → 68%. Single-deal dependence at this level has no precedent in the series (the prior
   high was Verkor's 38.5% in 2023).
4. **The median rose to a six-year high (€4.4M)** — the middle of the market is bigger too.

### Sector value by Q3, 2021–2026 (all sector tags, €M)

| Sector | 2021 | 2022 | 2023 | 2024 | 2025 | 2026 | Note |
|---|---|---|---|---|---|---|---|
| **Artificial Intelligence** | 183 | 647 | 405 | 461 | 2,272 | **3,554** | Mistral both '25 & '26; ex-Mistral '26 ≈ €554M |
| **SaaS** | 1,040 | 1,033 | 227 | 506 | 150 | 425 | Rebound (Skello) |
| **SpaceTech & Aerospace** | 45 | 123 | 2 | — | 73 | **453** | Exploration Company €387M |
| **HealthTech** | 474 | 266 | 107 | 281 | 67 | 155 | Recovering |
| **MedTech** | 191 | 97 | 62 | 55 | 29 | 165 | Up sharply |
| **CleanTech** | 507 | 36 | 956 | 203 | 248 | 96 | Cooling |
| **Energy** | 472 | 22 | 999 | 340 | 231 | 33 | Near-zero in '26 |
| **Hardware** | 217 | 153 | 999 | 52 | 313 | 77 | Down |
| **Cybersecurity** | 51 | 111 | 111 | 12 | 10 | 37 | Thin |

**Read:** AI is the whole story — €3.55B, **81% of the quarter**, but €3.0B of it is Mistral.
Ex-Mistral, AI (~€554M) is up a healthy ~22% on Q3 2025's ex-Mistral ~€454M, consistent with the
report's standing finding that **AI still eats everything**. SpaceTech spikes on one deal; health
and medtech recover modestly; energy, cleantech and hardware all fell.

### Stage structure by Q3, 2021–2026

| Stage | 2021 | 2022 | 2023 | 2024 | 2025 | 2026 |
|---|---|---|---|---|---|---|
| Seed — **deals** | 66 | **104** | 101 | 85 | 61 | **50** |
| Pre-seed — deals | 55 | 60 | 39 | 24 | 9 | 10 |
| Series A — deals | 43 | 34 | 31 | 24 | 19 | 19 |
| Series B — €M | 1,087 | 477 | 182 | 144 | 363 | 148 |
| Growth — €M | 712 | 366 | 329 | — | 264 | 420 |
| Series D — €M | — | — | — | — | — | **3,000** |

**The thinning base, Q3 edition.** Seed + pre-seed deal count has fallen from a combined **121 in
2021 to 60 in 2026** (−50%), with seed itself at a six-year low (50). Series A has roughly halved
(43 → 19). Meanwhile a single **Series D (Mistral, €3.0B)** — a stage that didn't register in any
prior Q3 — is larger than every other stage combined. Top swelling, base eroding.

---

## 1C. The year so far: 2026 has already beaten 2025

With three quarters in hand, the cleanest macro question is how **2026 year-to-date (Jan–Sep)**
compares with the past five *complete* years.

| Year | Rounds | Total €M | ≥€100M rounds | Median €M |
|---|---|---|---|---|
| 2021 | 988 | 11,761 | 27 | 3.0 |
| **2022** | **1,248** | **14,708** | **33** | 3.0 |
| 2023 | 1,024 | 8,132 | 10 | 2.5 |
| 2024 | 849 | 7,175 | 11 | 2.9 |
| 2025 | 642 | 7,882 | 7 | 3.1 |
| **2026 (Jan–Sep)** | **388** | **9,244** | **12** | **4.6** |

**The headline: 2026 has already topped 2025 — with a quarter still to run.** Through nine months,
French startups have raised **€9.24B**, already **+17% above all of full-year 2025 (€7.88B)** and
above 2024 (€7.18B). On any Q4 at all, 2026 becomes **the strongest year since the 2022 peak
(€14.7B)** — likely the second-biggest in the series.

**But — the same theme, at the largest scale: it's concentration, not breadth.**
- **The 12 rounds ≥ €100M account for €5.89B — 64% of the entire year** — from just **3% of the
  deals** (12 of 388).
- **The top three — Mistral (€3.0B), AMI (€890M) and Alan (€480M) — are €4.37B, 47% of the year,
  from three companies.** Mistral alone is **€3.0B, ~32% of all 2026 funding.**
- **Deal count is the lowest on record.** 388 rounds in nine months annualizes to ~515 — fewer than
  2025's 642 and less than half of 2022's 1,248. 2026 pairs **record money with record-low deal
  volume.**
- **The median is a six-year high (€4.6M).** Even the middle of the market is bigger; the small end
  is simply disappearing.

**The one-sentence version:** *2026 is already a bigger year than 2025, and it got there with
barely half the deals — because a handful of global-scale AI rounds now do what hundreds of smaller
rounds used to.*

---

## 2. The outlier: Mistral AI (€3.0B) and the "with / without" analysis

Mistral AI — the Paris frontier-model lab — raised a **€3.0B Series D** (announced September),
France's largest-ever venture round. At **68.1% of the quarter's disclosed total**, it is the most
dominant single deal in the six-year dataset by a wide margin.

| Metric | With Mistral | Without Mistral |
|---|---|---|
| Q3 2026 total | €4,405M | **€1,405M** |
| YoY vs Q3 2025 (ex-Mistral €1,195M) | +46.2% | **+17.6%** |
| QoQ vs Q2 2026 (ex-Alan €1,627M) | — | **−13.6%** |
| Q3 2026 average (disclosed) | €44.0M | €14.2M |

**The core finding:** the quarter's record is Mistral. Ex-Mistral, the market grew a modest ~18%
year-on-year but **shrank ~14% from Q2** — the underlying base is still thinning. Note that Q3 2025
was *also* Mistral-topped (€1.82B), so even the YoY comparison is a tale of two Mistral rounds.

---

## 3. Monthly breakdown

| Month | Q3 2026 rounds | Q3 2026 €M |
|---|---|---|
| July | 32 | €485M |
| August | 14 | €89M |
| **September** | **62** | **€3,832M** |
| **Total** | **108** | **€4,405M** |

**Read:** **September was 87% of the quarter** — Mistral (€3.0B), The Exploration Company (€387M),
HighLife (€80M) and KAIKO (€49M) all landed in the month. August was nearly dormant (€89M across 14
deals — the French summer lull). July was a normal-sized month (€485M) with Skello's €150M.

---

## 4. Top 15 deals — Q3 2026

| # | Company | €M | Stage | Month | City |
|---|---|---|---|---|---|
| 1 | **Mistral AI** | 3,000.0 | Series D | Sep | Paris |
| 2 | **The Exploration Company** | 387.0 | Series C | Sep | Munich* |
| 3 | **Skello** | 150.0 | Growth | Jul | Paris |
| 4 | HighLife | 80.0 | Growth | Sep | Paris |
| 5 | KAIKO | 49.0 | Series B | Sep | Paris |
| 6 | Elixir Aircraft | 45.0 | Growth | Jul | La Rochelle |
| 7 | Amarris | 39.0 | Growth | Jul | Saint-Herblain |
| 8 | IMPLICITY | 35.0 | Growth | Sep | Paris |
| 9 | Cyllene Therapeutics | 33.0 | Series C | Jul | Paris |
| 10 | Biolevate | 30.0 | Series A | Sep | Paris |
| 11 | Arlequin AI | 28.0 | Series A | Sep | Paris |
| 12 | Gradium | 26.3 | Seed | Jul | Paris |
| 13 | Arrakis Technologies | 25.8 | Series A | Jul | London* |
| 14 | SYNTETICA | 25.8 | Series A | Jul | Reims |
| 15 | Chargepoly | 23.0 | Growth | Aug | Aix-en-Provence |

After Mistral, Exploration Co and Skello, the table **falls off a cliff** — #4 is €80M and #15 is
€23M. \*The Exploration Company (Franco-German space firm) and Arrakis are HQ'd outside France
(Munich, London) but tracked as French-ecosystem; see §10.

---

## 5. Sector analysis (all sector tags)

> Each deal counts under **all** its sector tags; totals overlap and exceed the €4.41B quarter.

### Q3 2026 (all-tags, top sectors)

| Sector | Deals | €M |
|---|---|---|
| **Artificial Intelligence** | 57 | **3,554** |
| SpaceTech & Aerospace | 6 | 453 |
| SaaS | 37 | 425 |
| MedTech | 11 | 165 |
| HealthTech | 19 | 155 |
| HRTech | 2 | 151 |
| FinTech | 12 | 135 |
| BioTech | 11 | 100 |
| CleanTech | 8 | 96 |
| DeepTech | 13 | 84 |

### Key sector YoY moves (all-tags, Q3'25 → Q3'26)

| Sector | Q3'25 €M | Q3'26 €M | Δ value | Note |
|---|---|---|---|---|
| **Artificial Intelligence** | 2,272 | 3,554 | +56% | ex-Mistral €454M→€554M (+22%) |
| SpaceTech & Aerospace | 73 | 453 | +521% | Exploration Co €387M |
| SaaS | 150 | 425 | +183% | Skello + breadth |
| MedTech | 29 | 165 | +469% | genuine recovery |
| HealthTech | 67 | 155 | +131% | recovery |
| FinTech | 97 | 135 | +39% | |
| CleanTech | 248 | 96 | −61% | cooling |
| Energy | 231 | 33 | −86% | near-zero |
| Hardware | 313 | 77 | −75% | down |

**The big sector story: AI *is* the quarter.** AI touched **€3.55B — 81% of all value** — but €3.0B
is Mistral; ex-Mistral AI (~€554M) is still the largest sector and up ~22% YoY. Away from AI, the
genuine, non-mega risers are **SpaceTech** (Exploration Co) and **medtech/health**; **energy,
cleantech and hardware** fell hard.

---

## 6. Stage analysis

| Stage | Q3'26 deals | Q3'26 €M | Q3'25 deals | Q3'25 €M |
|---|---|---|---|---|
| Series D | **1** | **3,000** | — | — |
| Growth | 18 | 420 | 15 | 264 |
| Series C | 2 | 420 | 2 | 1,828* |
| Series A | 19 | 221 | 19 | 221 |
| **Seed** | **50** | 182 | **61** | 311 |
| Series B | 8 | 148 | 11 | 363 |
| Pre-seed | 10 | 14 | 9 | 9 |

\* Q3 2025's "Series C" €1.83B is Mistral's 2025 round (recorded as Series C). **The structural
story is unchanged from Q2:** one giant late-stage round (Series D, €3.0B) sits atop a shrinking
base — **seed fell to 50 deals** (from 61), a six-year low, and Series B more than halved in value.

---

## 7. Geographic analysis

### Paris vs Regions

| | Q3 2026 deals | Q3 2026 €M |
|---|---|---|
| **Paris** | 47 (44%) | **€3,632M (82%)** |
| **Regions / abroad** | 61 (56%) | €773M (18%) |

**Read:** Paris took **82% of value** — almost all of it Mistral. Ex-Mistral, Paris still held ~€632M
(~45%). Regional activity was thin and small-cheque.

### Top hubs outside Paris, Q3 2026

| City | Deals | €M | Driven by |
|---|---|---|---|
| Munich* | 1 | 387 | The Exploration Company |
| La Rochelle | 1 | 45 | Elixir Aircraft |
| Saint-Herblain | 1 | 39 | Amarris |
| Toulouse | 4 | 31 | (spread) |
| Bordeaux | 4 | 28 | (spread) |
| Reims | 1 | 26 | SYNTETICA |
| Lyon | 4 | 25 | (spread) |

Grenoble — Q2's standout cluster — was quiet (€7M across 2 deals).

---

## 8. Investor activity (Q3 2026, by deal count)

| Investor | Deals |
|---|---|
| **Bpifrance** | **27** |
| Business Angels (aggregate) | 23 |
| Kima Ventures | 6 |
| BNP Paribas Développement · Founders Future · IRDI Capital | 4 each |
| Capital Cell · Crédit Agricole · Lita · Odyssée · SWEN · Ventech | 3 each |

**Read:** The public backbone again — **Bpifrance touched 27 of 108 deals (25%)**, its highest share
of the year, with Business Angels close behind. Private institutional money concentrated in the few
large rounds; the long tail of small deals leaned on public and angel capital.

---

## 9. Sector deep-dive candidate: Artificial Intelligence / frontier compute

*(Chosen for the Q3 deep-dive.)* With Mistral's €3.0B — the capstone of a €3.55B AI quarter — the
natural deep-dive is **French frontier AI and the compute-capital it now attracts**: Mistral's
trajectory, the sovereign-compute thesis, and the question of whether anything exists beneath the
one giant (ex-Mistral AI was ~€554M across 56 deals — healthy, but a different order of magnitude).
A SpaceTech angle (Exploration Co, Elixir Aircraft) is the alternative.

---

## 10. Data notes & reproducibility

- **Schema:** `organizations` / `funding_rounds` (`announced_date` DATE, `stage` enum) /
  `organization_sectors` / `funding_round_investors` / `cities`, project `oxqpmtttgicvxmesrjzy`.
- **Amount units:** `amount_eur` in **€ millions**.
- **Quarter windows:** Q3 = `announced_date BETWEEN 'YYYY-07-01' AND 'YYYY-09-30'`.
- **Sector aggregation (all-tags):** each round attributed to **every** sector tag; totals overlap
  and exceed the quarter total (the standard method — see `QUARTERLY-REPORT-GUIDE.md`).
- **Non-French HQs:** The Exploration Company (Munich) and Arrakis Technologies (London) are tracked
  as French-ecosystem companies but are HQ'd abroad; they sit in "Regions / abroad" for geography.
- **Partial year:** §1C's 2026 figure covers **Jan–Sep only**; 2021–2025 are complete years.
- **Mistral rounds:** Q3 2025 (€1,818M, recorded Series C) and Q3 2026 (€3,000M, Series D) are
  EUR-converted headline figures.

---

## Checklist status

- [x] Query Navigator DB for Q3 2026 (Jul–Sep) funding rounds
- [x] Query same DB for Q3 2025 comparison
- [x] Headline stats: total, deals, average, median, mega-rounds
- [x] Sequential Q2 → Q3 2026 (§1A)
- [x] Six-year Q3 series: headline, sector (all-tags), stage (§1B)
- [x] **Full-year context — 2026 YTD vs 2021–2025 full years (§1C)**
- [x] Outlier "with/without" analysis (Mistral €3.0B)
- [x] Monthly breakdown (Jul/Aug/Sep)
- [x] Top 15 deals
- [x] Sector analysis all-tags with YoY
- [x] Stage analysis with YoY
- [x] Geographic analysis
- [x] Investor activity
- [x] Theme identified ("The Mistral Singularity")
- [ ] Q3-2026-CONTENT-PLAN.md
- [ ] q3-2026-full-report.html
- [ ] Newsletter article · cover · sector deep-dive
