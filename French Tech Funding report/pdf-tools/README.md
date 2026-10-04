# PDF tooling for quarterly funding reports

Renders a report HTML file (e.g. `q3-2026-full-report.html`) into a clean,
paginated **A4 PDF** — one report section per page, with a running header and
`Page X of N` footer on every page.

The pipeline is fully **offline**: Chart.js is vendored and the Newsreader +
Public Sans web fonts are embedded as base64, so no CDN or network fetch is
needed at render time (the sandbox blocks CDNs but allows the npm registry,
which is only used once up front to pull the vendored assets).

## Usage

From the `French Tech Funding report/` directory:

```bash
./pdf-tools/make-pdf.sh <input.html> <output.pdf> "Running-header right label"
```

Example (how the Q3 2026 PDF was built):

```bash
./pdf-tools/make-pdf.sh \
  q3-2026-full-report.html \
  Q3-2026-French-Tech-Funding-Report.pdf \
  "Q3 2026 French Tech Funding Report"
```

## How it works

1. `make-pdf.sh` — orchestrator. Creates a temp workdir, `npm pack`s
   `chart.js@4`, `@fontsource/newsreader@5`, `@fontsource/public-sans@5`, and
   `npm install`s `playwright-core`, then runs the two steps below.
2. `build_offline.py` — produces a self-contained copy of the report HTML:
   embeds the fonts as `@font-face` data-URIs, inlines the vendored Chart.js
   (with animation disabled and `devicePixelRatio=2` for crisp, final charts),
   and strips the Google Fonts `<link>`s and the embed-only iframe-resizer.
3. `render_pdf.js` — drives the pre-installed Chromium via `playwright-core`
   with `page.pdf({ displayHeaderFooter, headerTemplate, footerTemplate })` to
   get the running header and page numbers that the CLI `--print-to-pdf`
   cannot produce.

## Pagination contract (in the report HTML)

The report's own print CSS does the page layout; the tooling just renders it:

- each major section is wrapped in `.report-section.pbreak`
  (`page-break-before: always`),
- `break-inside: avoid` keeps sections, charts, callouts and table rows from
  splitting across pages,
- the on-page `.masthead` is hidden in print so the PDF running header
  replaces it.

Keep those classes when authoring a new quarter's report and the PDF will
paginate cleanly.

## Environment notes

- Chromium is auto-detected under `/opt/pw-browsers/chromium-*`; override with
  `PDF_CHROME=/path/to/chrome` if needed.
- Requires `node`, `npm`, `python3`.
