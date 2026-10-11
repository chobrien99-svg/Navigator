# FTJ Funding Hub — frenchtechjournal.com/funding/

This folder keeps the **French Startup Funding** page on The French Tech Journal
up to date with funding rounds from France Navigator.

## How it works

The page has two modules:

| Module | Contents | Where it lives | Who sees it |
|---|---|---|---|
| **Free** | Intro, "Last updated", year at a glance, annual funding chart, latest Funding Wire links | HTML card written into the Ghost page by `sync.mjs` | Whoever the card's visibility allows (public is best for search) |
| **Paid** | Funding by stage, latest rounds, largest rounds, top sectors, funding by quarter | Navigator app route `/embed/funding-hub` (Vercel), embedded with an iframe | Paid members, via the Ghost card's visibility |

```
France Navigator database (Supabase)
        │
        ▼
Navigator app (Vercel)                 frontend/src/app/…
  /api/public/v1/funding/summary?year=2026
  /api/public/v1/funding/annual?from=2021&to=2026
  /api/public/v1/funding/rounds?…      (used for previews)
  /embed/funding-hub                   ← paid module, served as a page
        │                                         │
        ▼                                         │
sync.mjs (hourly, GitHub Actions)                 │
  writes the FREE module into one HTML card       │
        │                                         │
        ▼                                         ▼
www.frenchtechjournal.com/funding/   ← iframe card (embed-snippet.html)
```

Both modules use the same drawing code,
`frontend/src/lib/funding-hub/render.mjs`, and the same settings,
`frontend/src/lib/funding-hub/config.json`, so they always match.

The free module is written into the page itself, so Google sees it without
running JavaScript. The paid module is inside an iframe and marked
`noindex`, so Google does not index it.

**Your own writing is safe.** The script only replaces the HTML card that
starts with `<!-- ftj-funding-hub:start -->`. That card also carries the intro,
which you edit in `intro.html`. The methodology and anything else you write in
the Ghost editor stay as they are.

**If Navigator is down**, the script stops without touching Ghost, so the page
keeps showing the last good data and its "Last updated" date.

## One-time setup

### 1. Database: add the publish switch (Supabase)

Run `supabase/migrations/phase16/01_funding_public_fields.sql` in the Supabase
SQL editor. It adds two columns to `funding_rounds`:

| Column | What it does |
|---|---|
| `publish_status` | `published` (default, shown on FTJ), `embargoed`, `draft` or `hidden` (not shown). All existing rounds start as `published`. |
| `ftj_url` | Optional link to the FTJ story about that round. If set, the company name on /funding/ links there instead of to the company website. |

Run this **before** deploying the Navigator code, because the API filters on
`publish_status`.

### 2. Deploy Navigator

Merge this branch so the Navigator site redeploys, then open
`https://www.francenavigator.com/api/public/v1/funding/summary?year=2026`
in a browser. You should see JSON with totals. (If Navigator lives at a
different address, change `navigatorApiBase` in `config.json`.)

### 3. Ghost: create the page

1. In Ghost Admin, **Pages → New page**.
2. Title: `French Startup Funding` (the theme shows this as the page's H1, so
   don't add another H1 in the body).
3. Paste the methodology from `editorial-draft.html` and edit it. The intro
   is published by the sync, from `intro.html`.
4. Page settings (gear icon):
   - **Page URL**: `funding`
   - **Meta data → Meta title**: `French Startup Funding: Latest Rounds, Deals & Data | FTJ`
   - **Meta description**: `Track French startup funding rounds, investors and sectors with continuously updated data and analysis from The French Tech Journal.`
   - Leave the canonical URL empty. Ghost then points it at the page itself,
     which is what we want.
5. Publish. Ghost adds published pages to `sitemap-pages.xml` automatically.
6. **Settings → Navigation**: add `French Startup Funding` → `/funding/`.

### 4. Ghost: create an API key for the script

**Settings → Integrations → Add custom integration**, name it
`Navigator Funding Hub`. Copy the **Admin API key** and the **API URL**.

Treat the Admin API key like a password. It can edit anything on the site.

### 5. GitHub: store the key and run it

In this repository: **Settings → Secrets and variables → Actions → New
repository secret**, twice:

| Name | Value |
|---|---|
| `GHOST_ADMIN_URL` | the API URL from step 4, e.g. `https://frenchtechjournal.ghost.io` |
| `GHOST_ADMIN_API_KEY` | the Admin API key from step 4 |

Then **Actions → FTJ Funding Hub sync → Run workflow**. The first run adds the
data card at the **bottom** of the page. In the Ghost editor, drag it above
the methodology. Later runs update the card where it is.

After that the workflow runs every hour and only saves to Ghost when the data
has actually changed.

## Paid module (iframe)

1. In the Ghost editor, add an **HTML card** below the free funding card.
2. Paste in the contents of `embed-snippet.html` (everything after the
   comment).
3. Set that card's **visibility** to paid members. In current Ghost versions
   this is in the card's settings (Visibility → web: paid members). If your
   Ghost version has no card visibility, instead set the page's access to
   paid members and insert a **public preview** divider between the two
   cards: everything above the divider stays public.
4. Update the page. The iframe sizes itself to its content and follows the
   site's light/dark mode.

**Access note:** card visibility only controls who sees the iframe on
frenchtechjournal.com. The embed page itself
(`https://www.francenavigator.com/embed/funding-hub`) and the public API can be
opened by anyone who has the address. Locking them down needs a member check
on the Navigator side; see the pull request discussion before relying on this
for paid-only data.

## Everyday use

- **Hold back a round** (embargo, rumour, error): set its `publish_status` to
  `embargoed`, `draft` or `hidden` in Navigator. It disappears from /funding/
  on the next hourly run. It still shows inside Navigator itself.
- **Link a round to our story**: fill in its `ftj_url`.
- **Quarterly report links**: add each report's URL under `quarterlyReports`
  in `frontend/src/lib/funding-hub/config.json`. They appear in the paid
  module once Navigator redeploys.
- **Annual chart**: starts at `annualFromYear` (2021; Navigator has almost no
  2020 rounds). To show a year Navigator does not cover, add it to
  `annualOverrides`, for example
  `"2020": { "total_disclosed_eur": 1234500000, "round_count": 456, "source": "FTJ 2020 report" }`
  (placeholder numbers),
  and set `annualFromYear` to 2020. Overridden years get an asterisk and their
  source is printed under the chart.
- **Funding Wire list**: the script looks at recent posts tagged
  `funding-news` (Funding News) and keeps those with "Funding Wire" in the
  title, so quarterly reports and databases with the same tag are left out.
  Change `fundingWireTag` / `fundingWireTitleMatch` in the config if that
  changes.
- **Page width**: `pageWidthPx` in the config (default 1180) widens the
  whole /funding/ page, title, text and data together, by overriding the
  theme's `--content-width` on this page only. Other pages are unaffected. The
  theme default is 708; lower it towards ~900 if long text lines feel hard to
  read.
- **Only one data card**: the page must contain exactly one HTML card with the
  funding data. If you paste the preview into Ghost by mistake, the sync stops
  with an error until the extra card is deleted.
- **Editing the page while a sync runs**: if Ghost warns that the page was
  changed elsewhere, reload it. The hourly sync only saves when data changes,
  so this is rare.

## Previewing locally

```bash
# Sample data from the CSVs in data/ (no network needed)
node scripts/ftj-funding-hub/sync.mjs --fixtures --out ./out
# Live Navigator data, without writing to Ghost
node scripts/ftj-funding-hub/sync.mjs --out ./out
```

Open `out/preview.html` (free module) and `out/paid-embed.html` (paid module)
in a browser. To refresh the sample data, run
`python3 scripts/ftj-funding-hub/fixtures/build_fixtures.py`.

## Files

| File | Purpose |
|---|---|
| `sync.mjs` | Fetch → validate → render the free module → update Ghost |
| `ghost.mjs` | Talks to the Ghost Admin API |
| `intro.html` | The intro at the top of the page (published by the sync) |
| `embed-snippet.html` | The iframe card to paste into Ghost for the paid module |
| `editorial-draft.html` | Draft methodology to paste into Ghost |
| `fixtures/` | Sample API responses for previews |
| `frontend/src/lib/funding-hub/render.mjs` | Drawing code for both modules and the embed page |
| `frontend/src/lib/funding-hub/config.json` | Settings: API address, list sizes, report links, annual chart, Funding Wire tag |
| `frontend/src/app/embed/funding-hub/route.ts` | The paid module page on Vercel |
| `.github/workflows/ftj-funding-hub.yml` | Hourly schedule |
