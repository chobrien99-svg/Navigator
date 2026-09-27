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

function companyCell(r) {
  const href = safeUrl(r.ftj_url) ?? safeUrl(r.company_url);
  const name = esc(r.company_name);
  return href ? `<a href="${esc(href)}">${name}</a>` : name;
}

function investorsCell(r, max = 3) {
  const list = r.investors?.length ? r.investors : r.lead_investors ?? [];
  if (!list.length) return `<span class="ftjf-muted">Not disclosed</span>`;
  const leads = new Set(r.lead_investors ?? []);
  const shown = list.slice(0, max).map((n) => (leads.has(n) ? `<strong>${esc(n)}</strong>` : esc(n)));
  const extra = list.length - max;
  return shown.join(", ") + (extra > 0 ? ` <span class="ftjf-muted">+${extra} more</span>` : "");
}

function hqCell(r) {
  const place = r.hq_country && r.hq_country !== "France"
    ? [r.hq_city, r.hq_country].filter(Boolean).join(", ")
    : r.hq_city || "France";
  const tag = r.french_founded_abroad ? ` <span class="ftjf-tag">French-founded</span>` : "";
  return esc(place) + tag;
}

function sectorsCell(r) {
  return r.sectors?.length ? esc(r.sectors.slice(0, 2).join(", ")) : `<span class="ftjf-muted">—</span>`;
}

function amountCell(r) {
  return r.amount_eur == null
    ? `<span class="ftjf-muted">Undisclosed</span>`
    : esc(formatEur(r.amount_eur));
}

function dateCell(value) {
  return value ? `<time datetime="${esc(String(value).slice(0, 10))}">${esc(formatDate(value))}</time>` : "—";
}

const STYLE = `<style>
.ftjf{--ftjf-line:rgba(127,127,127,.25);--ftjf-soft:rgba(127,127,127,.08);--ftjf-accent:#e3001b}
.ftjf .ftjf-updated{font-size:.85em;opacity:.75;margin:0 0 1.5em}
.ftjf .ftjf-kpis{display:grid;grid-template-columns:repeat(auto-fit,minmax(150px,1fr));gap:12px;margin:0 0 2em;padding:0}
.ftjf .ftjf-kpi{border:1px solid var(--ftjf-line);border-radius:6px;padding:14px 16px;margin:0}
.ftjf .ftjf-kpi dt{font-size:.75em;text-transform:uppercase;letter-spacing:.06em;opacity:.7;margin:0 0 4px}
.ftjf .ftjf-kpi dd{font-size:1.5em;font-weight:700;margin:0;line-height:1.2;font-variant-numeric:tabular-nums}
.ftjf .ftjf-kpi dd small{display:block;font-size:.5em;font-weight:400;opacity:.75;margin-top:4px}
.ftjf .ftjf-scroll{overflow-x:auto;margin:0 0 2em;-webkit-overflow-scrolling:touch}
.ftjf table{width:100%;border-collapse:collapse;font-size:.85em;line-height:1.4;margin:0}
.ftjf caption{text-align:left;font-size:.85em;opacity:.7;padding:0 0 8px}
.ftjf th,.ftjf td{text-align:left;padding:8px 10px;border-bottom:1px solid var(--ftjf-line);vertical-align:top}
.ftjf thead th{font-size:.8em;text-transform:uppercase;letter-spacing:.05em;opacity:.75;white-space:nowrap}
.ftjf tbody tr:hover{background:var(--ftjf-soft)}
.ftjf td.ftjf-num,.ftjf th.ftjf-num{text-align:right;white-space:nowrap;font-variant-numeric:tabular-nums}
.ftjf td.ftjf-nowrap{white-space:nowrap}
.ftjf .ftjf-muted{opacity:.6}
.ftjf .ftjf-tag{display:inline-block;font-size:.75em;padding:1px 6px;border-radius:3px;background:var(--ftjf-soft);border:1px solid var(--ftjf-line);white-space:nowrap}
.ftjf .ftjf-bar{display:block;height:6px;border-radius:3px;background:var(--ftjf-accent);margin-top:6px;min-width:2px}
.ftjf .ftjf-wire{list-style:none;padding:0;margin:0 0 2em}
.ftjf .ftjf-wire li{padding:10px 0;border-bottom:1px solid var(--ftjf-line)}
.ftjf .ftjf-wire time{display:block;font-size:.8em;opacity:.7}
.ftjf .ftjf-more{margin:0 0 2em}
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
  parts.push(`<div class="ftjf-kpi"><dt>Funding rounds</dt><dd>${esc(summary.round_count.toLocaleString("en-US"))}<small>tracked in ${esc(year)}</small></dd></div>`);
  if (largestRound) {
    parts.push(
      `<div class="ftjf-kpi"><dt>Largest round</dt><dd>${esc(formatEur(largestRound.amount_eur))}` +
        `<small>${esc(largestRound.company_name)} · ${esc(largestRound.round_label)}</small></dd></div>`
    );
  }
  parts.push(`<div class="ftjf-kpi"><dt>Last updated</dt><dd>${dateCell(updated)}</dd></div>`);
  parts.push(`</dl>`);

  // ── Latest rounds ──────────────────────────────────────────
  parts.push(`<h2 id="latest-funding-rounds">Latest funding rounds</h2>`);
  parts.push(`<div class="ftjf-scroll"><table>`);
  parts.push(`<caption>The ${esc(latest.length)} most recent French startup funding rounds, newest first. Lead investors in bold.</caption>`);
  parts.push(`<thead><tr><th scope="col">Date</th><th scope="col">Company</th><th scope="col">Sector</th><th scope="col">Round</th><th scope="col" class="ftjf-num">Amount</th><th scope="col">Investors</th><th scope="col">HQ</th></tr></thead><tbody>`);
  for (const r of latest) {
    parts.push(
      `<tr><td class="ftjf-nowrap">${dateCell(r.announcement_date)}</td><th scope="row">${companyCell(r)}</th>` +
        `<td>${sectorsCell(r)}</td><td class="ftjf-nowrap">${esc(r.round_label)}</td>` +
        `<td class="ftjf-num">${amountCell(r)}</td><td>${investorsCell(r)}</td><td>${hqCell(r)}</td></tr>`
    );
  }
  parts.push(`</tbody></table></div>`);

  // ── Largest rounds ─────────────────────────────────────────
  const ranked = largest.filter((r) => r.amount_eur != null);
  parts.push(`<h2 id="largest-rounds">Largest rounds of ${esc(year)}</h2>`);
  parts.push(`<div class="ftjf-scroll"><table>`);
  parts.push(`<caption>The ${esc(ranked.length)} largest disclosed French startup funding rounds of ${esc(year)}.</caption>`);
  parts.push(`<thead><tr><th scope="col" class="ftjf-num">#</th><th scope="col">Company</th><th scope="col" class="ftjf-num">Amount</th><th scope="col">Round</th><th scope="col">Sector</th><th scope="col">Investors</th><th scope="col">Date</th></tr></thead><tbody>`);
  ranked.forEach((r, i) => {
    parts.push(
      `<tr><td class="ftjf-num">${i + 1}</td><th scope="row">${companyCell(r)}</th><td class="ftjf-num">${amountCell(r)}</td>` +
        `<td class="ftjf-nowrap">${esc(r.round_label)}</td><td>${sectorsCell(r)}</td><td>${investorsCell(r, 2)}</td>` +
        `<td class="ftjf-nowrap">${dateCell(r.announcement_date)}</td></tr>`
    );
  });
  parts.push(`</tbody></table></div>`);

  // ── Quarters ───────────────────────────────────────────────
  parts.push(`<h2 id="funding-by-quarter">Funding by quarter</h2>`);
  parts.push(`<div class="ftjf-scroll"><table>`);
  parts.push(`<caption>Disclosed capital raised by French startups in ${esc(year)}, by quarter of announcement.</caption>`);
  parts.push(`<thead><tr><th scope="col">Quarter</th><th scope="col" class="ftjf-num">Disclosed capital</th><th scope="col" class="ftjf-num">Rounds</th><th scope="col">Analysis</th></tr></thead><tbody>`);
  for (const q of summary.quarters) {
    const report = reports[q.quarter];
    const reportUrl = safeUrl(report?.url);
    const width = Math.round((q.total_disclosed_eur / maxQuarter) * 100);
    const empty = q.round_count === 0;
    parts.push(
      `<tr><th scope="row">${esc(q.quarter)} ${esc(year)}</th>` +
        `<td class="ftjf-num">${empty ? `<span class="ftjf-muted">—</span>` : esc(formatEur(q.total_disclosed_eur))}` +
        (empty ? "" : `<span class="ftjf-bar" style="width:${width}%" aria-hidden="true"></span>`) +
        `</td><td class="ftjf-num">${empty ? `<span class="ftjf-muted">—</span>` : esc(q.round_count)}</td>` +
        `<td>${reportUrl ? `<a href="${esc(reportUrl)}">${esc(report.title || `${q.quarter} ${year} French Tech funding report`)}</a>` : `<span class="ftjf-muted">—</span>`}</td></tr>`
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
