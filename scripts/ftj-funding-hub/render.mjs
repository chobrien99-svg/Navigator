// Renders the France Navigator funding data into the HTML block that lives
// inside the /funding/ page on The French Tech Journal (Ghost).
//
// Everything a reader or crawler needs is plain HTML: no JavaScript is
// required to see the numbers or the tables.

export const START_MARKER = "<!-- ftj-funding-hub:start -->";
export const END_MARKER = "<!-- ftj-funding-hub:end -->";

const MONTHS = ["Jan.", "Feb.", "March", "April", "May", "June", "July", "Aug.", "Sept.", "Oct.", "Nov.", "Dec."];

export function esc(value) {
  return String(value ?? "")
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;");
}

function safeUrl(url) {
  return typeof url === "string" && /^https?:\/\//i.test(url) ? url : null;
}

// "2026-09-28" or an ISO timestamp -> "Sept. 28, 2026" (AP style)
export function formatDate(value) {
  if (!value) return "—";
  const [y, m, d] = String(value).slice(0, 10).split("-").map(Number);
  if (!y || !m || !d) return "—";
  return `${MONTHS[m - 1]} ${d}, ${y}`;
}

// 80000000 -> "€80M", 1250000000 -> "€1.25B", 750000 -> "€750K"
export function formatEur(amount) {
  if (amount == null) return "Undisclosed";
  const trim = (n, digits) => Number(n.toFixed(digits)).toString();
  if (amount >= 1e9) return `€${trim(amount / 1e9, 2)}B`;
  if (amount >= 1e6) return `€${trim(amount / 1e6, 1)}M`;
  if (amount >= 1e3) return `€${trim(amount / 1e3, 0)}K`;
  return `€${Math.round(amount)}`;
}

// "2026-09-25" -> "Sept. 25" (the year is given by the section heading)
function formatShortDate(value) {
  if (!value) return "—";
  const [, m, d] = String(value).slice(0, 10).split("-").map(Number);
  return m && d ? `${MONTHS[m - 1]} ${d}` : "—";
}

function companyLink(r) {
  const href = safeUrl(r.ftj_url) ?? safeUrl(r.company_url);
  const name = esc(r.company_name);
  return href ? `<a href="${esc(href)}">${name}</a>` : name;
}

function place(r) {
  return r.hq_country && r.hq_country !== "France"
    ? [r.hq_city, r.hq_country].filter(Boolean).join(", ")
    : r.hq_city || "France";
}

// Company name with sector and HQ on a quieter second line.
function companyCell(r, extra = []) {
  const meta = [r.sectors?.slice(0, 2).join(", "), place(r), ...extra].filter(Boolean).map(esc);
  const tag = r.french_founded_abroad ? ` <span class="ftjf-tag">French-founded</span>` : "";
  return `<span class="ftjf-co">${companyLink(r)}</span>${tag}<span class="ftjf-meta">${meta.join(" · ")}</span>`;
}

function investorsCell(r, max = 3) {
  const list = r.investors?.length ? r.investors : r.lead_investors ?? [];
  if (!list.length) return `<span class="ftjf-muted">Not disclosed</span>`;
  const leads = new Set(r.lead_investors ?? []);
  const shown = list.slice(0, max).map((n) => (leads.has(n) ? `<strong>${esc(n)}</strong>` : esc(n)));
  const extra = list.length - max;
  return shown.join(", ") + (extra > 0 ? ` <span class="ftjf-muted">+${extra}</span>` : "");
}

function amountCell(r) {
  return r.amount_eur == null
    ? `<span class="ftjf-muted">Undisclosed</span>`
    : esc(formatEur(r.amount_eur));
}

function dateCell(value) {
  return value ? `<time datetime="${esc(String(value).slice(0, 10))}">${esc(formatDate(value))}</time>` : "—";
}

function shortDateCell(value) {
  return value ? `<time datetime="${esc(String(value).slice(0, 10))}">${esc(formatShortDate(value))}</time>` : "—";
}

// Colours come from the Ghost theme's own tokens (so the site's dark mode
// works), with neutral fallbacks. The theme styles every <table> with a tinted
// background, nowrap cells and boxed borders; everything here is scoped to
// .ftjf to undo that without touching the rest of the site.
const STYLE = `<style>
.ftjf{--ftjf-ink:var(--color-text-primary,#111);--ftjf-ink-2:var(--color-text-secondary,#5c5c5c);--ftjf-line:var(--color-border-secondary,rgba(127,127,127,.25));--ftjf-line-strong:var(--color-text-primary,#111);--ftjf-track:rgba(127,127,127,.14);--ftjf-red:#d7141f;
  width:100%;max-width:100%;min-width:0!important;font-family:var(--font-family-sansSerif,Inter,system-ui,sans-serif);color:var(--ftjf-ink)}
.ftjf>*+*{margin-top:0}
.ftjf h2{margin:2.2em 0 .5em}
.ftjf h2:first-of-type{margin-top:.6em}
.c-content .ftjf a,.ftjf a{color:inherit!important;text-decoration:underline;text-decoration-color:var(--ftjf-line);text-underline-offset:3px;text-decoration-thickness:1px}
.c-content .ftjf a:hover,.ftjf a:hover{color:var(--ftjf-red)!important;text-decoration-color:currentColor}
.ftjf p,.ftjf ul,.ftjf li,.ftjf dl{font-family:var(--font-family-sansSerif,Inter,system-ui,sans-serif)!important}
.ftjf .ftjf-updated{font-size:14px;line-height:1.4;color:var(--ftjf-ink-2);margin:0;padding:10px 0;border-top:3px solid var(--ftjf-line-strong);border-bottom:1px solid var(--ftjf-line)}
.ftjf .ftjf-kpis{display:grid;grid-template-columns:repeat(3,1fr);margin:0;padding:0}
.ftjf .ftjf-kpi{margin:0;padding:16px 16px 18px 0}
.ftjf .ftjf-kpi+.ftjf-kpi{padding-left:16px;border-left:1px solid var(--ftjf-line)}
.ftjf .ftjf-kpi dt{font-size:12px;font-weight:600;text-transform:uppercase;letter-spacing:.06em;color:var(--ftjf-ink-2);margin:0 0 6px}
.ftjf .ftjf-kpi dt,.ftjf .ftjf-kpi dd{margin-left:0!important;padding-left:0!important}
.ftjf .ftjf-kpi dd{font-size:34px;font-weight:700;line-height:1.1;margin:0;font-variant-numeric:tabular-nums;letter-spacing:-.01em}
.ftjf .ftjf-kpi dd small{display:block;font-size:13px;font-weight:400;line-height:1.35;letter-spacing:0;color:var(--ftjf-ink-2);margin-top:6px}
.ftjf .ftjf-scroll{overflow-x:auto;-webkit-overflow-scrolling:touch;margin:0}
.ftjf table{width:100%;max-width:100%;background:transparent!important;border-collapse:collapse;font-size:15px;line-height:1.4;margin:0}
.ftjf caption{caption-side:top;text-align:left;font-size:14px;color:var(--ftjf-ink-2);padding:0 0 12px;border:0!important;background:transparent!important}
.ftjf th,.ftjf td{white-space:normal!important;text-align:left;vertical-align:top;padding:11px 12px 11px 0;border:0!important;border-bottom:1px solid var(--ftjf-line)!important;background:transparent!important;font-weight:400}
.ftjf th:last-child,.ftjf td:last-child{padding-right:0}
.ftjf thead th{font-size:12px;font-weight:600;text-transform:uppercase;letter-spacing:.06em;color:var(--ftjf-ink-2);padding-top:0;padding-bottom:8px;border-bottom:2px solid var(--ftjf-line-strong)!important;white-space:nowrap!important}
.ftjf .ftjf-num{text-align:right!important;white-space:nowrap!important;font-variant-numeric:tabular-nums}
.ftjf td.ftjf-amt{font-weight:600}
.ftjf .ftjf-nowrap{white-space:nowrap!important}
.ftjf .ftjf-date{color:var(--ftjf-ink-2);font-variant-numeric:tabular-nums}
.ftjf .ftjf-rank{color:var(--ftjf-ink-2);width:1.5em}
.ftjf .ftjf-co{font-weight:600}
.ftjf .ftjf-meta{display:block;font-size:13px;color:var(--ftjf-ink-2);margin-top:2px}
.ftjf .ftjf-inv{font-size:14px}
.ftjf .ftjf-muted{color:var(--ftjf-ink-2)}
.ftjf .ftjf-tag{display:inline-block;font-size:11px;font-weight:600;text-transform:uppercase;letter-spacing:.04em;padding:1px 5px;border-radius:3px;border:1px solid var(--ftjf-line);color:var(--ftjf-ink-2);vertical-align:2px}
.ftjf .ftjf-q td{vertical-align:middle}
.ftjf .ftjf-qbar{width:48%}
.ftjf .ftjf-track{display:block;height:12px;border-radius:0 4px 4px 0;background:var(--ftjf-track)}
.ftjf .ftjf-bar{display:block;height:12px;border-radius:0 4px 4px 0;background:var(--ftjf-red);min-width:2px}
.ftjf .ftjf-wire{list-style:none;padding:0;margin:0;border-top:2px solid var(--ftjf-line-strong)}
.ftjf .ftjf-wire li{margin:0;padding:12px 0;border-bottom:1px solid var(--ftjf-line);font-size:16px;line-height:1.4;font-weight:600}
.ftjf .ftjf-wire time{display:block;font-size:13px;font-weight:400;color:var(--ftjf-ink-2);margin-bottom:2px}
.ftjf .ftjf-more{margin:14px 0 0;font-size:15px;font-weight:600}
.ftjf .ftjf-sr{position:absolute;width:1px;height:1px;overflow:hidden;clip:rect(0 0 0 0);white-space:nowrap}
@media (max-width:600px){
  .ftjf .ftjf-kpis{grid-template-columns:1fr 1fr}
  .ftjf .ftjf-kpi:nth-child(3){grid-column:1/-1;padding-left:0;border-left:0;border-top:1px solid var(--ftjf-line)}
  .ftjf .ftjf-kpi dd{font-size:28px}
  .ftjf table{font-size:14px}
  .ftjf .ftjf-hide-sm{display:none}
  .ftjf .ftjf-qbar{width:35%}
}
</style>`;

/**
 * @param {object} input
 * @param {object} input.summary   /funding/summary response
 * @param {object[]} input.latest  rounds sorted by date (newest first)
 * @param {object[]} input.largest rounds sorted by amount (largest first)
 * @param {object[]} input.wire    [{title, url, published_at}] Funding Wire posts
 * @param {object} input.config    config.json contents
 */
export function renderFundingHub({ summary, latest, largest, wire = [], config }) {
  const year = summary.year;
  const updated = summary.updated_at;
  const navigatorUrl = safeUrl(config.navigatorFundingUrl);
  const reports = config.quarterlyReports?.[String(year)] ?? {};
  const maxQuarter = Math.max(1, ...summary.quarters.map((q) => q.total_disclosed_eur));
  const largestRound = summary.largest_round;

  const parts = [];
  parts.push(START_MARKER);
  parts.push(`<section class="ftjf" data-year="${esc(year)}">`);
  parts.push(STYLE);
  // Widen the whole /funding/ page (title, editorial text and this block) by
  // overriding the theme's --content-width for this page only. Ghost adds a
  // page-<slug> class to <body>, so other pages are unaffected.
  const width = Number(config.pageWidthPx);
  const slug = String(config.ghostPageSlug || "funding").replace(/[^a-z0-9-]/gi, "");
  if (Number.isFinite(width) && width >= 600 && width <= 1600) {
    parts.push(`<style>body.page-${slug}{--content-width:${Math.round(width)}px}</style>`);
  }

  parts.push(
    `<p class="ftjf-updated">Last updated ${dateCell(updated)}` +
      (navigatorUrl ? ` · Data: <a href="${esc(navigatorUrl)}">France Navigator</a>` : "") +
      `</p>`
  );

  // ── At a glance ────────────────────────────────────────────
  parts.push(`<h2 id="at-a-glance">${esc(year)} at a glance</h2>`);
  parts.push(`<dl class="ftjf-kpis">`);
  parts.push(
    `<div class="ftjf-kpi"><dt>Disclosed capital</dt><dd>${esc(formatEur(summary.total_disclosed_eur))}` +
      `<small>across ${esc(summary.disclosed_round_count ?? summary.round_count)} rounds with a disclosed amount</small></dd></div>`
  );
  parts.push(`<div class="ftjf-kpi"><dt>Funding rounds</dt><dd>${esc(summary.round_count.toLocaleString("en-US"))}<small>announced in ${esc(year)}</small></dd></div>`);
  if (largestRound) {
    parts.push(
      `<div class="ftjf-kpi"><dt>Largest round</dt><dd>${esc(formatEur(largestRound.amount_eur))}` +
        `<small>${esc(largestRound.company_name)} · ${esc(largestRound.round_label)}</small></dd></div>`
    );
  }
  parts.push(`</dl>`);

  // ── Latest rounds ──────────────────────────────────────────
  parts.push(`<h2 id="latest-funding-rounds">Latest funding rounds</h2>`);
  parts.push(`<div class="ftjf-scroll"><table>`);
  parts.push(`<caption>The ${esc(latest.length)} most recent French startup funding rounds, newest first. Lead investors in bold.</caption>`);
  parts.push(`<thead><tr><th scope="col">Date</th><th scope="col">Company</th><th scope="col" class="ftjf-hide-sm">Round</th><th scope="col" class="ftjf-num">Amount</th><th scope="col" class="ftjf-hide-sm">Investors</th></tr></thead><tbody>`);
  for (const r of latest) {
    parts.push(
      `<tr><td class="ftjf-nowrap ftjf-date">${shortDateCell(r.announcement_date)}</td>` +
        `<th scope="row">${companyCell(r)}</th><td class="ftjf-nowrap ftjf-hide-sm">${esc(r.round_label)}</td>` +
        `<td class="ftjf-num ftjf-amt">${amountCell(r)}</td><td class="ftjf-inv ftjf-hide-sm">${investorsCell(r)}</td></tr>`
    );
  }
  parts.push(`</tbody></table></div>`);

  // ── Largest rounds ─────────────────────────────────────────
  const ranked = largest.filter((r) => r.amount_eur != null);
  parts.push(`<h2 id="largest-rounds">Largest rounds of ${esc(year)}</h2>`);
  parts.push(`<div class="ftjf-scroll"><table>`);
  parts.push(`<caption>The ${esc(ranked.length)} largest disclosed French startup funding rounds of ${esc(year)}.</caption>`);
  parts.push(`<thead><tr><th scope="col" class="ftjf-num">#</th><th scope="col">Company</th><th scope="col" class="ftjf-hide-sm">Round</th><th scope="col" class="ftjf-num">Amount</th><th scope="col" class="ftjf-hide-sm">Investors</th></tr></thead><tbody>`);
  ranked.forEach((r, i) => {
    parts.push(
      `<tr><td class="ftjf-num ftjf-rank">${i + 1}</td><th scope="row">${companyCell(r, [formatShortDate(r.announcement_date)])}</th>` +
        `<td class="ftjf-nowrap ftjf-hide-sm">${esc(r.round_label)}</td><td class="ftjf-num ftjf-amt">${amountCell(r)}</td>` +
        `<td class="ftjf-inv ftjf-hide-sm">${investorsCell(r, 2)}</td></tr>`
    );
  });
  parts.push(`</tbody></table></div>`);

  // ── Quarters ───────────────────────────────────────────────
  // A labelled bar chart built as a table: values are printed next to each
  // bar, so it reads without colour and without JavaScript.
  parts.push(`<h2 id="funding-by-quarter">Funding by quarter</h2>`);
  parts.push(`<div class="ftjf-scroll"><table class="ftjf-q">`);
  parts.push(`<caption>Disclosed capital raised by French startups in ${esc(year)}, by quarter of announcement.</caption>`);
  parts.push(`<thead><tr><th scope="col">Quarter</th><th scope="col" class="ftjf-qbar"><span class="ftjf-sr">Share of largest quarter</span></th><th scope="col" class="ftjf-num">Raised</th><th scope="col" class="ftjf-num">Rounds</th></tr></thead><tbody>`);
  for (const q of summary.quarters) {
    const report = reports[q.quarter];
    const reportUrl = safeUrl(report?.url);
    const width = Math.max(1, Math.round((q.total_disclosed_eur / maxQuarter) * 100));
    const empty = q.round_count === 0;
    const label = `${esc(q.quarter)} ${esc(year)}`;
    parts.push(
      `<tr><th scope="row"><span class="ftjf-co">${label}</span>` +
        (reportUrl ? `<span class="ftjf-meta"><a href="${esc(reportUrl)}">${esc(report.title || `${q.quarter} ${year} funding report`)}</a></span>` : "") +
        `</th><td class="ftjf-qbar">` +
        (empty ? `` : `<span class="ftjf-track"><span class="ftjf-bar" style="width:${width}%"></span></span>`) +
        `</td><td class="ftjf-num ftjf-amt">${empty ? `<span class="ftjf-muted">—</span>` : esc(formatEur(q.total_disclosed_eur))}</td>` +
        `<td class="ftjf-num">${empty ? `<span class="ftjf-muted">—</span>` : esc(q.round_count)}</td></tr>`
    );
  }
  parts.push(`</tbody></table></div>`);

  // ── Funding Wire ───────────────────────────────────────────
  const wirePosts = wire.filter((p) => p.title && safeUrl(p.url));
  if (wirePosts.length) {
    parts.push(`<h2 id="latest-funding-wire">Latest Funding Wire</h2>`);
    parts.push(`<ul class="ftjf-wire">`);
    for (const p of wirePosts) {
      parts.push(`<li><time datetime="${esc(String(p.published_at ?? "").slice(0, 10))}">${esc(formatDate(p.published_at))}</time><a href="${esc(p.url)}">${esc(p.title)}</a></li>`);
    }
    parts.push(`</ul>`);
    const archive = safeUrl(config.fundingWireArchiveUrl);
    if (archive) parts.push(`<p class="ftjf-more"><a href="${esc(archive)}">All French Tech Funding Wire editions →</a></p>`);
  }

  parts.push(`</section>`);
  parts.push(END_MARKER);
  return parts.join("\n");
}
