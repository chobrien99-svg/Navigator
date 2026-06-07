# Handoff — French Tech Next 40/120 Dashboard ("The Navigator")

## TL;DR for the Dev

You're picking up a **design mockup** built in browser-Babel React + plain CSS, and your job is to **rebuild it inside the existing Next.js app in `frontend/`** (App Router + Tailwind, partially scaffolded already). Three editorial directions were explored — the team will pick one before you start; treat the others as reference.

This is a **hi-fi** mockup. Exact tokens, type, layouts, and copy are documented below. Use them.

---

## About the Design Files

The files in `mockup/` are **design references created in HTML/JSX** loaded via Babel-in-browser. They are **not production code to copy verbatim** — they're prototypes showing intended look, structure, and behavior. Your task is to recreate them inside the target codebase (`frontend/`) using its existing patterns:

- **Framework**: Next.js 14+ App Router (already chosen)
- **Styling**: Tailwind CSS + CSS custom properties (tokens already in `frontend/src/app/globals.css`)
- **Type**: React Server Components by default; mark client components only where needed (charts, interactivity)
- **Data**: replace the static `data.jsx` with real DB queries (see `frontend/src/lib/queries` referenced in existing scaffolding)

## Fidelity

**High-fidelity.** Pixel-perfect spec. Colors, font sizes, letter-spacing, padding, dividers — all final. Treat measurements as load-bearing.

---

## Product Context

- **Product name**: The Navigator — French Innovation Intelligence
- **Feature**: An annual dashboard / report covering the French Tech **Next 40 / 120** programme. The page below covers the **6th promotion (Class of 2025)**, announced 22 May 2025.
- **Audience**: institutional readers — policy folks, VCs, journalists, founders. Aesthetic should feel like a serious institutional publication (think *The Economist* / FT / IMF working papers), not a SaaS dashboard.
- **Existing pages in repo** (already partially scaffolded):
  - `/` (home — entity counts, capital tracked) — done in scaffold
  - `/funding` — funding tracker
  - `/entities/[slug]` — entity detail
  - `/programs/french-tech-next40-120` — **this dashboard**

---

## What's in this handoff

```
design_handoff_french_tech_dashboard/
├── README.md                     ← you are here
├── screenshots/                  ← PNG previews of all three directions
│   ├── direction-a-class-of-2025.png
│   ├── direction-b-bulletin-nr-6.png
│   └── direction-c-working-paper.png
├── mockup/                       ← The HTML/JSX prototype as designed
│   ├── index.html
│   ├── app.jsx                   (design canvas wiring)
│   ├── design-canvas.jsx
│   ├── direction-a.jsx           ← "The Class of 2025" — annual report
│   ├── direction-b.jsx           ← "Bulletin Nº 6" — newspaper grid
│   ├── direction-c.jsx           ← "Working Paper Nº 2025-06" — ministerial dossier
│   ├── charts.jsx                ← CohortFlow, SectorBars, SectorTreemap, FranceMap, NavChrome
│   ├── data.jsx                  ← static dataset (replace with DB queries)
│   └── styles.css                ← all design tokens + utility classes
└── existing-frontend-snapshot/   ← snapshot of what's already in frontend/ for reference
    └── ...
```

Open `mockup/index.html` in a browser to see the three directions side-by-side in a pan/zoom design canvas. Each artboard is a full page-design.

---

## The Three Directions

The team has been comparing three editorial treatments. **They'll pick one before you start.** All three render from the same data layer.

### Direction A — "The Class of 2025" (Annual Report)
- **File**: `mockup/direction-a.jsx`
- **Canvas**: 1440 × 2700 px
- **Treatment**: editorial special-edition. Big headline, four-stat band, hero alluvial flow chart, then sections § 1–5 (Arrivals, Promotions, Sector composition + Geography split, Exits).
- **Feel**: cleanest, most "report-like" — closest to a printed annual.

### Direction B — "Bulletin Nº 6" (Newspaper grid)
- **File**: `mockup/direction-b.jsx`
- **Canvas**: 1440 × 2480 px
- **Treatment**: front-page newspaper. Three-column lead spread (story + cohort flow + ledger), then arrivals as 4-column briefs, sectors + geography below, ticker tape of cohort names.
- **Feel**: most journalistic. Dropcap, column rules, double-rule mastheads.

### Direction C — "Working Paper Nº 2025-06" (Ministerial dossier)
- **File**: `mockup/direction-c.jsx`
- **Canvas**: 1280 × 3200 px
- **Treatment**: French-language ministerial / IMF working-paper aesthetic. Numbered sections § 1–§ 8, centered narrow column, marginalia with monospace ledger, narrow tables.
- **Feel**: most formal / academic. French-language body copy.

---

## Design Tokens

All tokens live in `mockup/styles.css` under `:root`. **Move these to `frontend/src/app/globals.css`** as CSS custom properties, and wire them into `tailwind.config.ts` via the `theme.extend.colors` map (use the existing scaffold's convention — e.g. `bg-primary`, `text-on-surface`).

### Color palette

| Token | Hex | Purpose |
|---|---|---|
| `--color-primary` | `#114563` | Deep institutional blue. Headlines, links, Next 40 tier. |
| `--color-primary-container` | `#2f5d7c` | Lighter primary for gradients. |
| `--color-secondary` | `#3c6840` | Forest green. FT 120 tier, "new" movements. |
| `--color-tertiary` | `#503863` | Plum. Tertiary accents. |
| `--color-background` | `#fef9ee` | Warm parchment. Page background. |
| `--color-surface` | `#fef9ee` | Same as background. |
| `--color-surface-container-low` | `#f8f3e8` | Slightly warmer cards. |
| `--color-surface-container` | `#f2ede2` | Card / panel fill. |
| `--color-surface-container-high` | `#ede8dd` | Hover / nested. |
| `--color-on-surface` | `#1d1c15` | Primary text — warm near-black. |
| `--color-on-surface-variant` | `#41474d` | Secondary text. |
| `--color-outline` | `#72787e` | Borders, separators. |
| `--color-outline-variant` | `#c1c7ce` | Hairline borders. |
| **Movement palette** | | (used by the cohort flow chart) |
| `--color-retained` | `#c4b894` | Parchment-on-parchment ribbon (held position). |
| `--color-promoted` | `#114563` | FT 120 → Next 40. |
| `--color-demoted` | `#b8862c` | Muted ochre. |
| `--color-new` | `#3c6840` | New entrants. |
| `--color-exit` | `#963d3d` | Muted rouge. |

### Type pairing

| Family | Use | Source |
|---|---|---|
| **Newsreader** (serif) | Headlines, decks, body prose in editorial layouts | Google Fonts — `--font-headline` |
| **Public Sans** (sans) | UI / labels / running body in dashboards | Google Fonts — `--font-body` |
| **JetBrains Mono** | Numerals (`.num`), tabular figures, dateline / folio | Google Fonts — `--font-mono` |

**Important typographic rules** (already in `styles.css`):
- All numerals (stat figures, table values, dates, cohort counts) use `.num` class → JetBrains Mono with `font-variant-numeric: tabular-nums`. **Tabular figures are non-negotiable** for the institutional feel.
- The "diplomatic label" utility (`.diplomatic-label`) — 10px Public Sans, weight 600, `letter-spacing: 0.18em`, uppercase — is used everywhere for overlines.
- The "editorial overline" utility is identical but `0.2em` letter-spacing.
- Body type in directions A and B is sans-serif Public Sans; body type in Direction C is **Newsreader at 14.5px, line-height 1.55, justified, with hyphens enabled**.
- Drop-cap class `.dropcap` (in Direction B's lead column): first letter 4.5em Newsreader weight 500 in primary blue.

### Spacing

The mockup doesn't use a strict 4px / 8px scale — it uses values calibrated for editorial density. Treat these as exact:

- Page padding: 40–48px horizontal, 32–48px vertical
- Section gap between major blocks: **56–80px**
- Stat band column gap: 28px with vertical hairline
- Card grid gap: 14px (cards) or 1px (cards with shared hairline background trick)
- Body line-height: 1.45 (sans), 1.55 (serif body), 1.05 (large headlines), 0.98 (extra-large hero)

### Letter spacing scale

- Hero headlines (96px): `-0.025em`
- Section h2 (32–44px): `-0.015em` to `-0.02em`
- Overlines / labels: `0.18em` to `0.2em` uppercase
- Tabular numerals: `0.04em` to `0.06em`

### Borders & dividers

The aesthetic relies on a vocabulary of rules:

- **Hairline** — `1px solid rgba(29,28,21,0.35)` — between sub-sections
- **Section rule** — `1px solid var(--color-on-surface)` — between major blocks
- **Double rule** — `4px double var(--color-on-surface)` — masthead dividers (Direction B)
- **Dotted hairline** — `1px dotted rgba(29,28,21,0.3)` — table rows in Direction C
- **Ghost border** — `1px solid rgba(193,199,206,0.55)` — card frames

No rounded corners anywhere. No drop shadows. The aesthetic is **flat, bordered, institutional**.

---

## Components to Build

### 1. `NavChrome` (shared layout)
**Source**: `mockup/charts.jsx` (function `NavChrome`) + `mockup/styles.css` (`.nav-sidebar`, `.nav-topbar`)
**Existing in repo**: partial — `frontend/src/components/sidebar.tsx`, `top-bar.tsx`

The dashboard pages render inside a sidebar + top-bar shell:
- **Sidebar (240px wide)**: masthead "The Navigator", primary nav (Dashboard, Entities, Funding, People, Programs, Research, Capital), sectioned by `border-top: 1px solid rgba(193,199,206,0.25)`. Each nav item: 13.5px Public Sans, weight 500, 10px / 14px padding, icon-then-label, `material-symbols-outlined` at 20px weight 300.
- **Top bar (60px tall)**: breadcrumb (Programs / French Tech Next 40 120 — active), search stub (`max-width: 360px`, 36px tall), right-side actions (notification bell, user avatar), scope toggle ("Active" / "Historic" / "All-Time" — only one underlined in primary).
- **Page content area**: `flex: 1`, scrolls independently.

Should be wrapped via a Next.js route group: `(dashboard)/layout.tsx` provides `<NavChrome>`.

### 2. `CohortFlow` (alluvial chart — **the hero element**)
**Source**: `mockup/charts.jsx`, function `CohortFlow` (line 8). ~650 lines of hand-rolled SVG. Highly tuned.

**What it does**: shows 6 annual cohorts (2020–2025) as paired vertical bars (Next 40 / FT 120), with ribbons between adjacent years for retained / promoted / demoted, plus bookend strips above and below each column for new arrivals and exits.

**Props**:
```ts
type CohortFlowProps = {
  width?: number;        // default 1000
  height?: number;       // default 480
  barWidth?: number;     // default 18
  highlightYear?: number; // default 2025 — the current cohort
  tonal?: "full" | "muted" | "spot"; // "spot" = only highlight current year transition
  showLabels?: boolean;
  showLegend?: boolean;
  colorScheme?: "default" | "ink";
};
```

**Notes for the rebuild**:
- This is **client-side** (SVG, no interactivity needed but it's measured at runtime). Mark `"use client"`.
- The math is non-trivial — recommend porting the entire function as-is into a TypeScript component, then refactoring. Don't rewrite from scratch.
- Data comes from `window.COHORTS` and `window.TRANSITIONS` in the mockup. In the real build, pass them in as props: `<CohortFlow cohorts={cohorts} transitions={transitions} />`.

### 3. `SectorBars`
**Source**: `mockup/charts.jsx`, function `SectorBars`
Horizontal bar chart of sectors. Simple — port directly. Each row: sector name (110px), bar (flex 1, 8px tall, primary blue fill on `rgba(29,28,21,0.08)` track), value in JetBrains Mono right-aligned (56px). The CSS class `.bar-row` already exists.

### 4. `SectorTreemap`
**Source**: `mockup/charts.jsx`, function `SectorTreemap`
Used only in Direction B. Area-proportional rectangles. ~80 lines.

### 5. `FranceMap`
**Source**: `mockup/charts.jsx`, function `FranceMap`
SVG outline of metropolitan France with city dots sized by cohort count. Read coordinates from `window.REGIONS_2026` (which contains `{ city, region, count, x, y, delta }`).

### 6. The page sections themselves

These are layout components — pick the chosen direction and build accordingly. All three are documented in detail in their respective JSX files; reading them top-to-bottom is the spec.

---

## Data Model

The static dataset is in `mockup/data.jsx`. Replace with real DB-backed types. Suggested shape:

```ts
// cohorts and transitions — for the CohortFlow chart
type Cohort = { year: number; label: string; next40: number; ft120: number; current?: boolean };
type Transition = {
  from: number; to: number;
  retainedN40: number; retainedFT120: number;
  promoted: number; demoted: number;
  exitedN40: number; exitedFT120: number;
  newToN40: number; newToFT120: number;
};

// company-level records
type Arrival = {
  name: string; sector: string; city: string; raised: string;
  note: string; tier: "Next 40" | "FT 120";
  initial: string; color: string;
};
type Promotion = {
  name: string; from: "FT 120"; to: "Next 40";
  sector: string; city: string; raised: string; note: string;
};
type Exit = {
  name: string; reason: string;
  from: "Next 40" | "FT 120"; since: number; sector: string;
};

// aggregate rollups
type Sector = { sector: string; count: number; pct: number; delta: number };
type Region = { city: string; region: string; count: number; x: number; y: number; delta: number };

type HeadlineStats = {
  total: number; next40: number; ft120: number;
  new: number; promoted: number; demoted: number;
  retained: number; exited: number;
  unicorns: number; totalRaised: string;
  womenFounders: number; paris: number;
};
```

The static data in `mockup/data.jsx` is *plausible* but not fully verified — treat it as fixture data for the prototype. Replace with real queries before launch.

---

## Interactions & Behavior

The mockup is **static** — there are no interactive states designed (yet). For the build:

- **No interactivity needed in v1** beyond standard chrome (sidebar nav, search). The page is a read-mostly editorial dashboard.
- **Scope toggle** (top-bar "Active / Historic / All-Time") should filter the page data but in v1 can be wired to active-only.
- **Future considerations** (worth a stub):
  - Hover state on cohort flow ribbons → tooltip showing exact movement counts
  - Click company card → drill to entity page (`/entities/[slug]`)
  - Year selector to view past promotions

## Responsive Behavior

The mockup is **fixed-width** (1280–1440px). The dashboard is desktop-first; small-screen treatment is **out of scope** for v1. Set a min-width of 1200px and let it scroll horizontally on smaller screens.

## State Management

None needed. Server Components fetch data; charts are deterministic SVG from props. No client state required.

---

## Assets

- **Fonts**: load Newsreader, Public Sans, JetBrains Mono from Google Fonts in `frontend/src/app/layout.tsx` via `next/font/google`.
- **Icons**: Material Symbols Outlined. Already used in the mockup via the standard CDN; in production, install `@material-symbols/svg-400` or similar and tree-shake.
- **No images / no logos** in the mockup. If a French Tech logo is added later, treat as separate asset request.

---

## Existing Frontend Snapshot

`existing-frontend-snapshot/` contains the partial Next.js scaffold already in the repo:

- `src/app/layout.tsx`, `src/app/globals.css` — root layout
- `src/app/page.tsx` — homepage (already styled)
- `src/app/(dashboard)/funding/funding-dashboard.tsx` — sister dashboard, same chrome
- `src/app/(dashboard)/programs/french-tech-next40-120/page.tsx` + `french-tech-dashboard.tsx` — **stub for this feature**
- `src/components/sidebar.tsx`, `src/components/top-bar.tsx` — chrome components

**The scaffold is missing**: `package.json`, `next.config.js`, `tsconfig.json`, `tailwind.config.ts`, lockfile, `lib/queries`. Standing those up is the first task before you write any UI code.

Suggested first 60 minutes:
1. `npx create-next-app@latest` in a temp dir to grab the config files; merge them into `frontend/`
2. Install Tailwind + the @tailwindcss/typography plugin
3. Port `mockup/styles.css` → `frontend/src/app/globals.css` (most of it is utility classes; some becomes Tailwind config)
4. Install fonts via `next/font/google`
5. Smoke-test the existing homepage renders
6. Then start on the chosen direction.

---

## Open Questions for the Product Owner

Things the designer/PM should clarify before you spend serious time:

1. **Which direction?** — A, B, or C. Or a hybrid (e.g., Direction A's hero + Direction C's tables).
2. **English or French?** — Direction C is French-language. Confirm primary language. (i18n out of scope unless explicit.)
3. **Annual snapshot or live data?** — Is the 2025 cohort frozen on announcement day, or does the page re-render as exits/IPOs/M&A happen mid-year?
4. **Data sources** — Where does the cohort roster live? (Internal DB? Scraped from La French Tech site? Google Sheet?) Determines how the queries are written.
5. **Print/PDF export** — Several directions reference "folio" pagination. Is a print stylesheet wanted?
6. **Sub-pages from the cards?** — Click an arriving company → does it go to `/entities/[slug]`? (If yes, the data layer needs to join cohort entries to entity records.)

---

## Style "Don'ts" — preserving the aesthetic

These are the easy ways to drift away from the design intent. Hold the line:

- **No rounded corners.** Anywhere. Cards, buttons, tags, chips — all square.
- **No drop shadows.** Depth comes from borders and surface tones.
- **No gradients** except the single primary-blue institutional CTA (linear-gradient 135deg primary → primary-container).
- **No emoji.**
- **No animation** beyond hover color transitions (200ms ease).
- **Numerals always tabular** — use `.num` (JetBrains Mono, `tabular-nums`).
- **Letter spacing must be tight on headlines** (`-0.02em` or so) and **loose on labels** (`0.18–0.2em`).
- **Editorial overlines always uppercase, 600 weight**, never larger than 11px.
- **Capitalization**: headlines are sentence case, not Title Case. "Seven graduate to Next 40", not "Seven Graduate to Next 40".

---

## Contact

Designer of record: <fill in>
Last updated: 25 May 2026
