# Q2 2026 French Tech Funding — Data Analysis

> Raw analysis for the Q2 2026 (April–June 2026) French Tech Funding Report.
> Source: Navigator unified database (`funding_rounds`), project `oxqpmtttgicvxmesrjzy`.
> Comparison quarter: Q2 2025 (April–June 2025), same database.
> All euro amounts are in **€ millions** unless stated. Generated 2026-07-01.

---

## 0. The theme: **"Top-Heavy"**

**The tension:** Q2 2026 looks like a record — €2.09B raised, up 16% year-on-year. But almost
all of that growth is a single deal. Strip out Alan's €480M round and the quarter *contracted*
~11% YoY. Underneath the headline, the market is thinning: 17% fewer deals, seed rounds down a
third, and AI — the engine of the last two years — cooled hard (funding value −54% YoY). What
grew was the top of the market: the average check rose 53% and the median 43%. Capital is
concentrating into fewer, larger rounds while the base erodes.

**One-line framing for the report intro:** *"French tech just posted its biggest quarter in a
year. It took exactly one deal to get there."*

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

## 5. Sector analysis (primary sector)

### Q2 2026

| Sector | Deals | €M | Share of value |
|---|---|---|---|
| FinTech | 7 | **653** | 31% |
| Artificial Intelligence | 28 | 234 | 11% |
| BioTech | 8 | 187 | 9% |
| HealthTech | 13 | 171 | 8% |
| DeepTech | 5 | 168 | 8% |
| Other/Unclassified | 11 | 158 | 8% |
| CleanTech | 11 | 104 | 5% |
| SaaS | 6 | 91 | 4% |
| AgriTech | 2 | 52 | 2% |
| Gaming | 3 | 41 | 2% |
| ClimateTech | 6 | 38 | 2% |
| DefenseTech | 1 | 32 | 2% |

*(FinTech is inflated by Alan €480M + Morpho Labs €151M; the two account for ~97% of the FinTech
line. Strip them and "real" fintech is ~€22M.)*

### Q2 2025

| Sector | Deals | €M |
|---|---|---|
| Artificial Intelligence | 48 | 513 |
| CleanTech | 15 | 256 |
| FinTech | 18 | 247 |
| Cybersecurity | 5 | 153 |
| BioTech | 14 | 122 |
| DeepTech | 9 | 121 |
| HealthTech | 17 | 109 |
| SaaS | 17 | 96 |

### Key sector YoY moves

| Sector | Q2'25 €M | Q2'26 €M | Δ value | Q2'25 deals | Q2'26 deals | Δ deals |
|---|---|---|---|---|---|---|
| **Artificial Intelligence** | 513 | 234 | **−54%** | 48 | 28 | **−42%** |
| **Health cluster** (Bio+Health+Med) | 231 | 363 | **+57%** | 31 | 23 | −26% |
| DeepTech | 121 | 168 | +39% | 9 | 5 | −44% |
| CleanTech | 256 | 104 | −59% | 15 | 11 | −27% |
| Cybersecurity | 153 | 19 | −88% | 5 | 2 | −60% |

**The big sector story: AI cooled.** After two years as French tech's growth engine, AI funding
value more than halved (−54%) and deal count fell 42%. The euros that used to flow to AI showed
up in **health/biotech** (Bionyra, UROMEMS, Tissium, Sonomind) and **deeptech/quantum** (Quobly,
Mantle8). Cybersecurity — the Q1 deep-dive sector — nearly vanished this quarter (€153M → €19M).

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
rounds (Sanofi Ventures, Ajax Health), while the AI wave recedes — the euros rotated from models
to medicine.

---

## 10. Data notes & reproducibility

- **Schema note:** the live Navigator DB uses `organizations` / `funding_rounds` /
  `organization_sectors` / `cities` with `announced_date` (a DATE), **not** the
  `companies` / `announced_month` / `hq_city_name` fields shown in the guide's illustrative
  pseudo-code. Queries in this analysis reflect the real schema.
- **Amount units:** `funding_rounds.amount_eur` is stored in **€ millions**.
- **Quarter windows:** Q2 = `announced_date BETWEEN 'YYYY-04-01' AND 'YYYY-06-30'`.
- **Sector aggregation:** one primary sector per org via `DISTINCT ON (organization_id) … ORDER BY
  is_primary DESC`; orgs can carry multiple sector tags, which is why Alan surfaces in both FinTech
  (primary) and the health cluster.
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
- [x] Theme identified ("Top-Heavy")
- [x] Write Q2-2026-ANALYSIS.md
- [ ] Q2-2026-CONTENT-PLAN.md
- [ ] q2-2026-full-report.html
- [ ] Newsletter article
- [ ] Cover image
- [ ] Health-cluster deep-dive (sector chosen)
