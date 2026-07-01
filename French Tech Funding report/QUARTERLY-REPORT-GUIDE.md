# Quarterly Funding Report: Reproduction Guide
### How to recreate the Q1 2026 report for Q2 2026 (and beyond)

> **Context:** This document captures every step, design decision, data query, and editorial choice made in producing the Q1 2026 French Tech Funding Report. Use it to reproduce the report for any future quarter against any database.

---

## Table of Contents

1. [What We Built](#1-what-we-built)
2. [Data Analysis Pipeline](#2-data-analysis-pipeline)
3. [Design System: The Modern Archivist](#3-design-system-the-modern-archivist)
4. [Report HTML Structure](#4-report-html-structure)
5. [Chart Specifications](#5-chart-specifications)
6. [Editorial Content Structure](#6-editorial-content-structure)
7. [Newsletter Article Template](#7-newsletter-article-template)
8. [Cover Image Template](#8-cover-image-template)
9. [Sector Deep-Dive Template](#9-sector-deep-dive-template)
10. [PDF Export Guide](#10-pdf-export-guide)
11. [Deployment Guide](#11-deployment-guide)
12. [File Inventory](#12-file-inventory)

---

## 1. What We Built

Seven deliverables from a single data analysis session:

| File | Purpose |
|---|---|
| `Q1-2026-ANALYSIS.md` | Raw data analysis with all numbers, comparisons, tables |
| `Q1-2026-CONTENT-PLAN.md` | Editorial outline, theme, suggested page structure |
| `q1-2026-full-report.html` | Full interactive report with 9 Chart.js visualizations |
| `full-report/index.html` | Standalone deployable copy (same file, renamed for Vercel) |
| `q1-2026-newsletter-article.md` | ~900-word newsletter overview article |
| `newsletter-cover.html` | 960x600 cover image (HTML, screenshot to export) |
| `cybersecurity-funding-report.md` | Sector deep-dive: cybersecurity funding trends |

### Production order:
1. **Data analysis** → raw numbers, comparisons, top deals
2. **Content plan** → theme, narrative arcs, page structure
3. **Full report HTML** → interactive charts + editorial text
4. **Newsletter article** → 800-word journalistic summary
5. **Cover image** → HTML-based, 960x600
6. **Sector reports** → deep-dives on specific sectors (cybersecurity, etc.)

---

## 2. Data Analysis Pipeline

### Step 1: Query the database

The Q1 report pulls data from two sources:
- **Current quarter** (Q2 2026): from the Navigator's new database
- **Comparison quarter** (Q2 2025): from the same database or the legacy Supabase

**Key tables needed:**
- `funding_rounds` — with fields: `company_id`, `amount_eur`, `round_type`, `announced_month`, `announced_year`, `news_url`, `notes`
- `companies` — with fields: `id`, `name`, `description`, `website`, `hq_city_name`
- `company_sectors` — maps companies to sectors
- `sectors` — sector names
- `funding_round_investors` — maps rounds to investors
- `investors` — investor names
- `company_people` — maps companies to people (founders)
- `people` — person names

### Step 2: Filter for the quarter

```python
# For Q2: April (4), May (5), June (6)
Q2_MONTHS = [4, 5, 6]

# Normalize month values (database stores both 'April' and '4')
def norm_month(m):
    mapping = {'January':1, 'February':2, 'March':3, 'April':4, 'May':5,
               'June':6, 'July':7, 'August':8, 'September':9, 'October':10,
               'November':11, 'December':12}
    if isinstance(m, int): return m
    if isinstance(m, str):
        if m.isdigit(): return int(m)
        return mapping.get(m, 0)
    return 0

q2_2026 = [r for r in all_rounds if r['announced_year'] == 2026 and norm_month(r['announced_month']) in Q2_MONTHS]
q2_2025 = [r for r in all_rounds if r['announced_year'] == 2025 and norm_month(r['announced_month']) in Q2_MONTHS]
```

### Step 3: Compute headline stats

```python
total = sum(r['amount_eur'] for r in rounds if r.get('amount_eur'))
disclosed = [r for r in rounds if r.get('amount_eur') and r['amount_eur'] > 0]
avg = total / len(disclosed) if disclosed else 0
median = sorted(r['amount_eur'] for r in disclosed)[len(disclosed)//2]
mega_rounds = [r for r in rounds if r.get('amount_eur', 0) >= 100]
```

### Step 4: Build comparison tables

For each analysis dimension, compute both quarters and calculate YoY change:
- **Monthly breakdown** (3 months)
- **Top deals** (sorted by amount, top 15-20)
- **Sector analysis** (aggregate by sector, count deals + sum amounts)
- **Stage analysis** (aggregate by round_type)
- **Geographic analysis** (aggregate by hq_city_name)
- **Investor analysis** (aggregate by investor name via junction table)

### Step 5: "With and without" outlier analysis

If any single deal exceeds ~25% of the quarter's total, compute all metrics with and without it:

```python
outlier_amount = 890  # AMI in Q1 2026
total_ex_outlier = total - outlier_amount
avg_ex_outlier = total_ex_outlier / (len(disclosed) - 1)
yoy_ex_outlier = ((total_ex_outlier - prev_total) / prev_total) * 100
```

This gives a "what's the underlying trend" narrative.

### Step 6: Content analysis (if newsletter posts available)

Read all published articles from the quarter. Categorize into:
- **Funding Wires** (weekly deal recaps)
- **La Machine** (AI column)
- **French Tech Wire** (feature stories)
- **Deep Dives / Profiles** (standalone)

Extract: companies mentioned, people profiled, recurring themes, narrative arcs.

---

## 3. Design System: The Modern Archivist

### Philosophy
Inspired by prestigious print journalism and diplomatic correspondence. Rejects "SaaS Blue" aesthetics. Uses tonal layering instead of borders, extreme white space, and high-contrast typography.

### Core Rules
1. **No 1px borders for sectioning** — use background color shifts
2. **0px border radius everywhere** — sharp, architectural edges
3. **No KPI boxes** — display numbers as large typography on the surface
4. **Ghost borders only** (15% opacity) when accessibility requires it
5. **Gold accent ("wax seal")** used sparingly — once per section max
6. **Shadows are failure** — achieve depth through tonal stacking

### Color Tokens

```css
:root {
  /* Surfaces — warm parchment hierarchy */
  --surface: #fef9ee;              /* Primary background */
  --surface-dim: #dedacf;
  --surface-container-low: #f8f3e8;  /* Section backgrounds */
  --surface-container: #f2ede2;
  --surface-container-high: #ede8dd;
  --surface-container-highest: #e5e2db;
  --surface-container-lowest: #ffffff;  /* Cards, chart backgrounds */

  /* Primary — institutional ink blue */
  --primary: #114563;
  --primary-container: #2f5d7c;
  --on-primary: #ffffff;

  /* Text */
  --on-surface: #1d1c15;           /* Body text */
  --on-surface-variant: #41474d;   /* Secondary text, labels */

  /* Accents */
  --secondary: #775a0f;            /* Gold — "wax seal" accent */
  --secondary-container: #fdd580;
  --tertiary: #460602;             /* Oxblood — alerts, negative data */
  --gold-accent: #edbf74;          /* Accent lines, highlights */

  /* Utility */
  --outline: #72787e;
  --outline-variant: #c1c7ce;
  --graph-links: #C9C1B3;
  --error: #ba1a1a;

  /* Chart palette — muted, archival, 10 colors */
  --chart-1: #114563;  /* Ink blue */
  --chart-2: #2f5d7c;  /* Lighter blue */
  --chart-3: #775a0f;  /* Antique gold */
  --chart-4: #3c6840;  /* Forest green */
  --chart-5: #503863;  /* Purple */
  --chart-6: #8b6914;  /* Dark gold */
  --chart-7: #460602;  /* Oxblood */
  --chart-8: #5a7a8b;  /* Slate */
  --chart-9: #7a5a3a;  /* Brown */
  --chart-10: #3a7a7a; /* Teal */
}
```

### Typography

```css
/* Fonts — load from Google Fonts */
/* Newsreader: ital,opsz,wght@0,6..72,400;0,6..72,500;0,6..72,600;0,6..72,700;1,6..72,400;1,6..72,500 */
/* Public Sans: wght@300;400;500;600;700 */

/* Headlines — Newsreader serif */
.display-lg  { font: 700 clamp(2.8rem,5vw,4rem)/1.1 'Newsreader',serif; letter-spacing: -0.02em; }
.headline-lg { font: 600 2rem/1.2 'Newsreader',serif; letter-spacing: -0.01em; }
.headline-md { font: 600 1.5rem/1.3 'Newsreader',serif; }
.headline-sm { font: 600 1.15rem/1.35 'Newsreader',serif; }

/* Labels — Public Sans uppercase */
.label-md { font: 600 0.7rem/1 'Public Sans',sans-serif; text-transform: uppercase; letter-spacing: 0.1rem; }
.label-sm { font: 500 0.65rem/1 'Public Sans',sans-serif; text-transform: uppercase; letter-spacing: 0.08rem; }

/* Body — Public Sans */
.body-md { font-size: 0.935rem; line-height: 1.7; }
.body-sm { font-size: 0.8rem; line-height: 1.6; color: var(--on-surface-variant); }
```

### Key CSS Patterns

```css
/* Section dividers — background shifts, NOT lines */
.surface-shift { background: var(--surface-container-low); padding: 4rem 0; }

/* Ghost borders — 15% opacity max */
.ghost-border-bottom { border-bottom: 1px solid rgba(193,199,206,0.2); }

/* Callout boxes — gold left bar accent */
.callout { background: var(--surface-container-lowest); padding: 2.5rem 3rem; position: relative; }
.callout::before { content:''; position:absolute; left:0; top:0; bottom:0; width:3px; background:var(--secondary); }

/* Stat values — large typography on surface, no boxes */
.stat-value { font: 700 clamp(2.2rem,4vw,3.2rem)/1 'Newsreader',serif; color:var(--primary); letter-spacing:-0.02em; }

/* Masthead — institutional gradient */
.masthead { background: linear-gradient(135deg, var(--primary) 0%, var(--primary-container) 100%); }

/* Sector cards — colored left border, no box border */
.sector-card { padding: 1.8rem 1.5rem; background: var(--surface-container-lowest); border-left: 3px solid [sector-color]; }
```

---

## 4. Report HTML Structure

The report is a single self-contained HTML file. Sections in order:

```
1. <head> — fonts, Chart.js CDN, all CSS
2. Masthead bar (gradient)
3. Hero section — title, subtitle, intro paragraph
4. Headline stats (CSS Grid, 5 columns)
5. Monthly comparison charts (2-column: funding + deals)
6. Top deals (horizontal bar chart + table with 15 rows)
7. Sector analysis (2-column: funding chart + YoY change chart + sector cards grid)
8. Stage analysis (2-column: doughnut chart + stage breakdown list)
9. Geographic analysis (2-column: Paris vs Regions doughnut + top cities bar)
10. With/without outlier analysis (2-column: stacked bar chart + ex-outlier stats)
11. Timeline of key stories (2-column: month 1+2 left, month 3 right)
12. VC ecosystem section (3-column: fund profiles + ecosystem data points)
13. Outlook (2-column: 6 themes to watch)
14. Coverage index (3-column: content type counts)
15. "Save as PDF" button (hidden in print)
16. Footer
17. <script> — all Chart.js initializations
18. iframe-resizer contentWindow script
```

### Critical chart container pattern:
```html
<!-- ALWAYS set explicit height on chart-wrap to prevent Chart.js infinite resize -->
<div class="chart-wrap" style="height: 300px;">
  <div class="label-sm">Chart Title</div>
  <canvas id="chart-name"></canvas>  <!-- NO height attribute on canvas -->
</div>
```

### Stat row pattern (CSS Grid, not flexbox):
```css
.stat-row { display: grid; grid-template-columns: repeat(5, 1fr); }
```

---

## 5. Chart Specifications

All charts use Chart.js v4+ loaded from CDN.

### Global defaults:
```javascript
Chart.defaults.font.family = "'Public Sans', sans-serif";
Chart.defaults.font.size = 11;
Chart.defaults.color = '#41474d';
Chart.defaults.plugins.legend.display = false;
Chart.defaults.plugins.tooltip.backgroundColor = '#114563';
Chart.defaults.plugins.tooltip.cornerRadius = 0;
```

### Chart inventory (9 charts in Q1 report):

| Chart | Type | ID | Height | Data |
|---|---|---|---|---|
| Monthly funding | bar (grouped) | chart-monthly-funding | 300px | 2 datasets: prev year + current year, 3 bars each |
| Monthly deals | bar (grouped) | chart-monthly-deals | 300px | Same structure, deal counts |
| Top 10 deals | bar (horizontal) | chart-top-deals | 380px | Company names vs amounts |
| Sectors by funding | bar (horizontal) | chart-sectors | 420px | Sector names vs amounts |
| Sector YoY change | bar (horizontal) | chart-sector-change | 420px | Sector names vs % change |
| Stage doughnut | doughnut | chart-stage-donut | 360px | Stage labels vs amounts, cutout 58% |
| Paris vs Regions | doughnut | chart-geo-split | 300px | 2 segments, cutout 62% |
| Top cities | bar (horizontal) | chart-cities | 300px | City names vs amounts |
| With/without outlier | bar (stacked) | chart-ami-comparison | 340px | 2 datasets stacked: core + outlier |

### Color usage in charts:
- **Grouped bars**: current year = `#114563` (solid), previous year = `rgba(17,69,99,0.25)` (faded)
- **Horizontal bars**: cycle through `P` array (10 chart colors)
- **Doughnuts**: cycle through `P` array
- **Stacked bars**: core = `#114563`, outlier highlight = `#775a0f` (gold)

### Euro formatter:
```javascript
function fmt(m) {
  if (m >= 1000) return '€' + (m/1000).toFixed(1) + 'B';
  if (m >= 1) return '€' + Math.round(m) + 'M';
  return '€' + (m*1000).toFixed(0) + 'K';
}
```

### Grid styling:
```javascript
const gridColor = 'rgba(193,199,206,0.15)';
// x-axis: grid display false, border display false
// y-axis: grid color gridColor, border display false
```

---

## 6. Editorial Content Structure

### Report theme pattern:
The Q1 theme was **"The Great Concentration"** — derived from the central tension in the data (more money, fewer deals). Each quarter should have a theme that captures its defining dynamic.

**How to find the theme:**
1. Run the numbers first
2. Look for the *tension* — what's surprising, contradictory, or counterintuitive?
3. Name it in 2-4 words
4. The intro paragraph should state the tension in the first 2 sentences

### Section editorial formula:
Each section follows this pattern:
```
LABEL-MD: Category name (e.g., "Sector Intelligence")
HEADLINE-LG: Evocative section title (e.g., "Where the Money Went")
BODY-MD: 1-2 sentence summary of what the data shows (max-width: 640px)
[CHART(S)]
[CALLOUT BOX(ES)]: 1 key insight with a title + paragraph
```

### Callout box usage:
- Use for the single most important insight per section
- Give it a strong title (e.g., "The March Moment", "The Pipeline Paradox")
- 2-4 sentences max
- Gold left-bar accent signals importance

---

## 7. Newsletter Article Template

~800-900 words. Structure:

1. **Hook** (2 sentences) — headline number, then the twist
2. **The big number explained** — what the data actually shows
3. **Outlier caveat** — "with and without" the biggest deal
4. **Monthly shape** — which month(s) drove the quarter
5. **Sector highlights** — 3-4 sectors with the best stories
6. **Stage/structural insight** — growth stage, pipeline, etc.
7. **Geography** — Paris vs regions, one-liner
8. **Forward look** — 2-3 things to watch next quarter

**Voice:** Conversational, data-forward, occasional asides ("yes, really"), no jargon. End with tension, not a bow.

---

## 8. Cover Image Template

File: `newsletter-cover.html` — open in browser, screenshot at 960x600.

**Layout:**
- Full-bleed institutional blue gradient background
- Subtle grid texture overlay (CSS background-image)
- Gold radial light wash from top-right corner
- Masthead bar top (brand name + "Quarterly Funding Report")
- Left side: report label, title (Newsreader 3.8rem), subtitle (Newsreader italic 1.15rem)
- Right side: 3 stat blocks (value + label + change indicator)
- Gold accent line and bottom bar

**To customize for Q2:**
- Change title text
- Change subtitle text (mention the quarter's defining theme)
- Update the 3 stat blocks with new numbers
- Change "Q1 2026" references to "Q2 2026"

---

## 9. Sector Deep-Dive Template

Structure used for the cybersecurity report:

1. **Executive summary** — 3 sentences: total, deal count, key finding
2. **The numbers table** — period, deals, total, average
3. **All deals profiled** — for each: company, amount, round, month, city, description, investors, U.S. expansion status
4. **Previous year deals** — same format for comparison
5. **Key trends** — 4-5 numbered trends with supporting evidence
6. **Specific tracking table** — e.g., companies citing U.S. expansion
7. **Quarterly trajectory** — table showing quarter-by-quarter progression
8. **Outlook** — 3-4 sentences on what to watch

---

## 10. PDF Export Guide

The report includes `@media print` CSS. To export:

1. Open HTML in **Chrome** (best PDF support)
2. **Cmd+P** (or click "Save as PDF" button at bottom)
3. Settings:
   - Destination: **Save as PDF**
   - Layout: **Portrait**
   - Margins: **None** (CSS handles margins via `@page`)
   - Check: **Background graphics** (essential for colors)
4. Save

### Key print CSS decisions:
- Two-column layouts are preserved (they fit A4 portrait)
- Charts max 170px height
- Base font 8.5pt
- Page margins 1.2cm top/bottom, 1.5cm sides
- `page-break-before: always` on `.page-break` class
- Sector grid collapses to 3 columns
- All `print-color-adjust: exact` for background colors

---

## 11. Deployment Guide

### As part of existing site:
Place the HTML file in a served directory. Embed via iframe:
```html
<iframe src="/path/to/report.html" style="width:100%;border:none;min-height:800px;" id="report"></iframe>
<script src="https://cdn.jsdelivr.net/npm/iframe-resizer@4/js/iframeResizer.min.js"></script>
<script>iFrameResize({}, '#report')</script>
```

### As standalone Vercel deployment:
1. Create directory with `index.html` (the report) + `vercel.json`
2. `vercel.json` must include `X-Frame-Options: ALLOWALL` and `frame-ancestors *` in CSP
3. Point Vercel project root to this directory
4. Assign custom domain if desired

---

## 12. File Inventory

```
q1-report/
├── Q1-2026-ANALYSIS.md           # Raw data analysis
├── Q1-2026-CONTENT-PLAN.md       # Editorial plan + outline
├── q1-2026-full-report.html      # Interactive report (main file)
├── q1-2026-newsletter-article.md # Newsletter overview article
├── newsletter-cover.html         # 960x600 cover image
├── cybersecurity-funding-report.md # Sector deep-dive
├── full-report/
│   ├── index.html                # Standalone deployable copy
│   └── vercel.json               # Vercel config for standalone deployment
├── index.html                    # Original Q1 dashboard (Supabase-powered)
├── vercel.json                   # Original Q1 dashboard Vercel config
└── posts/                        # 75 newsletter articles from Q1
```

---

## Checklist: Reproducing for Q2 2026

- [ ] Query new Navigator database for Q2 2026 (Apr-Jun) funding rounds
- [ ] Query same database for Q2 2025 comparison data
- [ ] Run headline stats: total, deals, average, median, mega-rounds
- [ ] Run monthly breakdown (April, May, June)
- [ ] Identify top 15-20 deals
- [ ] Run sector analysis with YoY comparison
- [ ] Run stage analysis with YoY comparison
- [ ] Run geographic analysis (cities, Paris vs regions)
- [ ] Identify outlier deals for "with/without" analysis
- [ ] Find the theme (the tension in the data)
- [ ] Write Q2-2026-ANALYSIS.md with raw data
- [ ] Write Q2-2026-CONTENT-PLAN.md with editorial outline
- [ ] Build q2-2026-full-report.html (copy Q1 structure, update data + text)
- [ ] Write newsletter article (~800 words)
- [ ] Build newsletter cover image (960x600)
- [ ] Run any sector deep-dives requested
- [ ] Test print-to-PDF in Chrome
- [ ] Deploy to Vercel
- [ ] Analyze Q2 newsletter posts for timeline + coverage index
