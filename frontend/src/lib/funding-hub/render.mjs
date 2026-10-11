// Renders the France Navigator funding data for the French Tech Journal
// /funding/ page. Shared by two consumers:
//   - scripts/ftj-funding-hub/sync.mjs writes renderFreeModule() into the
//     Ghost page (intro, KPIs, annual chart, Funding Wire links);
//   - the Navigator route /embed/funding-hub serves renderPaidModule() inside
//     renderEmbedDocument(), which FTJ embeds for paid members.
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
.ftjf .ftjf-intro{margin:0 0 2em}
.ftjf .ftjf-intro p{font-family:var(--font-family-serif,Georgia,serif)!important;font-size:var(--font-size-scale-body-copy,20px);line-height:var(--line-height-scale-body-copy,1.6);margin:0}
.ftjf .ftjf-intro p+p{margin-top:var(--content-flow,32px)}
.c-content .ftjf .ftjf-intro a,.ftjf .ftjf-intro a{color:var(--color-accent,#2373bb)!important;text-decoration-color:currentColor}
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
.ftjf{--ftjf-s1:#f08a90;--ftjf-s2:#e0454f;--ftjf-s3:#b8121d;--ftjf-s4:#7d0c13;--ftjf-s5:#a8a8a8;--ftjf-on1:#111;--ftjf-on2:#111;--ftjf-on3:#fff;--ftjf-on4:#fff;--ftjf-on5:#111}
:root[data-user-color-scheme=dark] .ftjf{--ftjf-s1:#9a1f28;--ftjf-s2:#d0343e;--ftjf-s3:#f07a82;--ftjf-s4:#fbbdc1;--ftjf-s5:#6e6e6e;--ftjf-on1:#fff;--ftjf-on2:#fff;--ftjf-on3:#111;--ftjf-on4:#111;--ftjf-on5:#fff}
@media (prefers-color-scheme:dark){:root:not([data-user-color-scheme]).is-darkModeAdminSetting-enabled .ftjf{--ftjf-s1:#9a1f28;--ftjf-s2:#d0343e;--ftjf-s3:#f07a82;--ftjf-s4:#fbbdc1;--ftjf-s5:#6e6e6e;--ftjf-on1:#fff;--ftjf-on2:#fff;--ftjf-on3:#111;--ftjf-on4:#111;--ftjf-on5:#fff}}
.ftjf .ftjf-cap{font-size:14px;line-height:1.45;color:var(--ftjf-ink-2);margin:0 0 14px}
.ftjf .ftjf-stackchart{margin:0 0 16px}
.ftjf .ftjf-stack-row{display:flex;align-items:center;gap:12px;margin:0 0 8px}
.ftjf .ftjf-stack-name{flex:0 0 64px;font-size:12px;font-weight:600;text-transform:uppercase;letter-spacing:.06em;color:var(--ftjf-ink-2)}
.ftjf .ftjf-stack{flex:1;display:flex;gap:2px;height:30px;min-width:0}
.ftjf .ftjf-seg{display:flex;align-items:center;justify-content:center;flex-basis:0;min-width:3px;overflow:hidden;font-size:12px;font-weight:700;font-variant-numeric:tabular-nums}
.ftjf .ftjf-seg:first-child{border-radius:4px 0 0 4px}
.ftjf .ftjf-seg:last-child{border-radius:0 4px 4px 0}
.ftjf .ftjf-seg:only-child{border-radius:4px}
.ftjf .ftjf-s1{background:var(--ftjf-s1);color:var(--ftjf-on1)}
.ftjf .ftjf-s2{background:var(--ftjf-s2);color:var(--ftjf-on2)}
.ftjf .ftjf-s3{background:var(--ftjf-s3);color:var(--ftjf-on3)}
.ftjf .ftjf-s4{background:var(--ftjf-s4);color:var(--ftjf-on4)}
.ftjf .ftjf-s5{background:var(--ftjf-s5);color:var(--ftjf-on5)}
.ftjf .ftjf-swatch{display:inline-block;width:12px;height:12px;border-radius:3px;margin-right:8px;vertical-align:-1px}
.ftjf table.ftjf-legend th,.ftjf table.ftjf-legend td{padding-top:8px;padding-bottom:8px}
.ftjf table.ftjf-legend{max-width:760px}
.ftjf table.ftjf-legend tbody th{font-weight:600;white-space:nowrap!important}
.ftjf .ftjf-years{list-style:none;margin:8px 0 0!important;padding:0!important;display:grid;grid-template-columns:repeat(var(--ftjf-n),minmax(0,1fr));gap:0}
.ftjf .ftjf-year{display:flex;flex-direction:column;align-items:center;text-align:center;margin:0!important;padding:0;font-weight:400}
.ftjf .ftjf-year-col{display:flex;flex-direction:column;justify-content:flex-end;align-items:center;width:100%;height:200px;border-bottom:2px solid var(--ftjf-line-strong)}
.ftjf .ftjf-year-val{font-size:14px;font-weight:700;font-variant-numeric:tabular-nums;margin-bottom:6px;white-space:nowrap}
.ftjf .ftjf-year-bar{display:block;width:min(64px,72%);min-height:2px;background:var(--ftjf-red);border-radius:4px 4px 0 0}
.ftjf .ftjf-year-partial .ftjf-year-bar{background:var(--ftjf-s1)}
.ftjf .ftjf-year-label{font-size:15px;font-weight:600;margin-top:8px;line-height:1.25}
.ftjf .ftjf-year-label small{display:block;line-height:1.3;font-size:11px;font-weight:600;text-transform:uppercase;letter-spacing:.05em;color:var(--ftjf-ink-2)}
.ftjf .ftjf-year-n{font-size:12px;line-height:1.3;color:var(--ftjf-ink-2);margin-top:2px;padding:0 2px}
.ftjf .ftjf-note{margin-top:10px}
.ftjf .ftjf-sr{position:absolute;width:1px;height:1px;overflow:hidden;clip:rect(0 0 0 0);white-space:nowrap}
@media (max-width:600px){
  .ftjf .ftjf-kpis{grid-template-columns:1fr 1fr}
  .ftjf .ftjf-kpi:nth-child(3){grid-column:1/-1;padding-left:0;border-left:0;border-top:1px solid var(--ftjf-line)}
  .ftjf .ftjf-kpi dd{font-size:28px}
  .ftjf table{font-size:14px}
  .ftjf .ftjf-hide-sm{display:none}
  .ftjf .ftjf-qbar{width:35%}
  .ftjf .ftjf-stack-name{flex-basis:56px}
  .ftjf .ftjf-year-col{height:150px}
  .ftjf .ftjf-year-val{font-size:11px}
  .ftjf .ftjf-year-label{font-size:13px}
  .ftjf .ftjf-year-n{font-size:10px}
}
</style>`;


// ── Charts ───────────────────────────────────────────────────
// Stages are grouped into four ordered buckets plus "Other", coloured with a
// one-hue red ramp (validated as an ordinal ramp in light and dark).
const STAGE_GROUPS = [
  { label: "Pre-seed & seed", stages: ["pre_seed", "seed"] },
  { label: "Series A", stages: ["series_a"] },
  { label: "Series B–F", stages: ["series_b", "series_c", "series_d", "series_e", "series_f"] },
  { label: "Growth & later", stages: ["growth", "ipo", "secondary"] },
];

function pct(part, whole) {
  return whole > 0 ? (part / whole) * 100 : 0;
}

function fmtPct(p) {
  return p > 0 && p < 1 ? "<1%" : `${Math.round(p)}%`;
}

function stageGroups(byStage) {
  const groups = STAGE_GROUPS.map((g) => ({ ...g, total: 0, count: 0 }));
  const other = { label: "Other", stages: [], total: 0, count: 0 };
  for (const b of byStage) {
    const g = groups.find((x) => x.stages.includes(b.stage)) ?? other;
    g.total += b.total_disclosed_eur ?? 0;
    g.count += b.round_count ?? 0;
  }
  return [...groups, other].map((g, i) => ({ ...g, slot: i + 1 }));
}

function stackBar(groups, value, whole, label) {
  const segs = groups
    .filter((g) => value(g) > 0)
    .map((g) => {
      const p = pct(value(g), whole);
      const text = p >= 9 ? `<span class="ftjf-seg-label">${esc(fmtPct(p))}</span>` : "";
      return `<span class="ftjf-seg ftjf-s${g.slot}" style="flex-grow:${p.toFixed(3)}" title="${esc(`${g.label}: ${fmtPct(p)} of ${label.toLowerCase()}`)}">${text}</span>`;
    })
    .join("");
  return `<div class="ftjf-stack-row"><span class="ftjf-stack-name">${esc(label)}</span><span class="ftjf-stack" aria-hidden="true">${segs}</span></div>`;
}

function renderStageChart(summary) {
  if (!Array.isArray(summary.by_stage) || !summary.by_stage.length) return "";
  const groups = stageGroups(summary.by_stage);
  const totalEur = groups.reduce((a, g) => a + g.total, 0);
  const totalCount = groups.reduce((a, g) => a + g.count, 0);
  if (!totalEur || !totalCount) return "";
  const rows = groups
    .filter((g) => g.count > 0)
    .map(
      (g) =>
        `<tr><th scope="row"><span class="ftjf-swatch ftjf-s${g.slot}" aria-hidden="true"></span>${esc(g.label)}</th>` +
        `<td class="ftjf-num ftjf-amt">${esc(formatEur(g.total))}</td><td class="ftjf-num ftjf-hide-sm">${esc(fmtPct(pct(g.total, totalEur)))}</td>` +
        `<td class="ftjf-num">${esc(g.count)}</td><td class="ftjf-num ftjf-hide-sm">${esc(fmtPct(pct(g.count, totalCount)))}</td></tr>`
    )
    .join("");
  return (
    `<h2 id="funding-by-stage">Funding by stage</h2>` +
    `<p class="ftjf-cap">How ${esc(summary.year)}'s disclosed capital and its funding rounds split across stages.</p>` +
    `<div class="ftjf-stackchart">${stackBar(groups, (g) => g.total, totalEur, "Capital")}${stackBar(groups, (g) => g.count, totalCount, "Rounds")}</div>` +
    `<div class="ftjf-scroll"><table class="ftjf-legend"><thead><tr><th scope="col">Stage</th><th scope="col" class="ftjf-num">Capital</th><th scope="col" class="ftjf-num ftjf-hide-sm">Share</th><th scope="col" class="ftjf-num">Rounds</th><th scope="col" class="ftjf-num ftjf-hide-sm">Share</th></tr></thead><tbody>${rows}</tbody></table></div>`
  );
}

function renderSectorChart(summary, limit = 8) {
  if (!Array.isArray(summary.by_sector)) return "";
  const top = summary.by_sector
    .filter((b) => b.sector && b.sector.toLowerCase() !== "other" && b.total_disclosed_eur > 0)
    .slice(0, limit);
  if (top.length < 3) return "";
  const max = top[0].total_disclosed_eur;
  const rows = top
    .map((b) => {
      const w = Math.max(1, Math.round((b.total_disclosed_eur / max) * 100));
      return (
        `<tr><th scope="row"><span class="ftjf-co">${esc(b.sector)}</span></th>` +
        `<td class="ftjf-qbar"><span class="ftjf-track"><span class="ftjf-bar" style="width:${w}%" title="${esc(`${b.sector}: ${formatEur(b.total_disclosed_eur)} across ${b.round_count} rounds`)}"></span></span></td>` +
        `<td class="ftjf-num ftjf-amt">${esc(formatEur(b.total_disclosed_eur))}</td><td class="ftjf-num">${esc(b.round_count)}</td></tr>`
      );
    })
    .join("");
  return (
    `<h2 id="top-sectors">Top sectors</h2>` +
    `<div class="ftjf-scroll"><table class="ftjf-q">` +
    `<caption>The ${esc(top.length)} sectors with the most disclosed capital in ${esc(summary.year)}. Companies can belong to more than one sector, so these totals overlap.</caption>` +
    `<thead><tr><th scope="col">Sector</th><th scope="col" class="ftjf-qbar"><span class="ftjf-sr">Share of top sector</span></th><th scope="col" class="ftjf-num">Raised</th><th scope="col" class="ftjf-num">Rounds</th></tr></thead>` +
    `<tbody>${rows}</tbody></table></div>`
  );
}

// ── Annual chart ─────────────────────────────────────────────
// Columns of disclosed capital per year. The current year is partial, so it
// gets a lighter tint plus a "to date" label. Years filled from
// config.annualOverrides (e.g. a year Navigator does not cover) are marked
// with an asterisk and their source is printed under the chart.
function renderAnnualChart(annual, { currentYear, overrides = {} }) {
  if (!Array.isArray(annual) || annual.length < 2) return "";
  const years = annual.map((y) => {
    const o = overrides[String(y.year)];
    return o && Number.isFinite(o.total_disclosed_eur)
      ? { ...y, total_disclosed_eur: o.total_disclosed_eur, round_count: o.round_count ?? null, source: o.source || "FTJ" }
      : y;
  });
  const max = Math.max(1, ...years.map((y) => y.total_disclosed_eur));
  const first = years[0].year;
  const cols = years
    .map((y) => {
      const h = Math.max(1, Math.round((y.total_disclosed_eur / max) * 100));
      const partial = y.year === currentYear;
      const mark = y.source ? "*" : "";
      const rounds = y.round_count != null ? `${Number(y.round_count).toLocaleString("en-US")} rounds` : "";
      const tip = `${y.year}${partial ? " (to date)" : ""}: ${formatEur(y.total_disclosed_eur)}${rounds ? ` across ${rounds}` : ""}`;
      return (
        `<li class="ftjf-year${partial ? " ftjf-year-partial" : ""}" title="${esc(tip)}">` +
        `<span class="ftjf-year-col"><span class="ftjf-year-val">${esc(formatEur(y.total_disclosed_eur))}</span>` +
        `<span class="ftjf-year-bar" style="height:${h}%" aria-hidden="true"></span></span>` +
        `<span class="ftjf-year-label">${esc(y.year)}${mark}${partial ? `<small>to date</small>` : ""}</span>` +
        (rounds ? `<span class="ftjf-year-n">${esc(rounds)}</span>` : "") +
        `</li>`
      );
    })
    .join("");
  const notes = years.filter((y) => y.source).map((y) => `*${esc(y.year)}: ${esc(y.source)}.`);
  return (
    `<h2 id="funding-by-year">French startup funding since ${esc(first)}</h2>` +
    `<p class="ftjf-cap">Disclosed capital raised by French startups each year.` +
    (years.some((y) => y.year === currentYear) ? ` ${esc(currentYear)} is year to date.` : "") +
    `</p>` +
    `<ol class="ftjf-years" style="--ftjf-n:${years.length}">${cols}</ol>` +
    (notes.length ? `<p class="ftjf-cap ftjf-note">${notes.join(" ")}</p>` : "")
  );
}

function pageWidthStyle(config) {
  // Widen the whole /funding/ page (title, editorial text and modules) by
  // overriding the theme's --content-width for this page only. Ghost adds a
  // page-<slug> class to <body>, so other pages are unaffected.
  const width = Number(config.pageWidthPx);
  const slug = String(config.ghostPageSlug || "funding").replace(/[^a-z0-9-]/gi, "");
  return Number.isFinite(width) && width >= 600 && width <= 1600
    ? `<style>body.page-${slug}{--content-width:${Math.round(width)}px}</style>`
    : "";
}

/**
 * Free module, written into the Ghost page by the sync script.
 * @param {object} input
 * @param {object} input.summary   /funding/summary response
 * @param {object[]} input.annual  /funding/annual data
 * @param {object[]} input.wire    [{title, url, published_at}] Funding Wire posts
 * @param {object} input.config    config.json contents
 * @param {string} input.intro     intro.html contents
 */
export function renderFreeModule({ summary, annual = [], wire = [], config, intro = "" }) {
  const year = summary.year;
  const updated = summary.updated_at;
  const navigatorUrl = safeUrl(config.navigatorFundingUrl);
  const largestRound = summary.largest_round;

  const parts = [];
  parts.push(START_MARKER);
  parts.push(`<section class="ftjf" data-year="${esc(year)}">`);
  parts.push(STYLE);
  parts.push(pageWidthStyle(config));

  // Editorial intro (intro.html, trusted repo content), set in the theme's
  // article typography so it matches text written in the Ghost editor.
  const introHtml = String(intro).replace(/<!--[\s\S]*?-->/g, "").trim();
  if (introHtml) parts.push(`<div class="ftjf-intro">${introHtml}</div>`);

  parts.push(
    `<p class="ftjf-updated">Last updated ${dateCell(updated)}` +
      ` · Data: ` + (navigatorUrl ? `<a href="${esc(navigatorUrl)}">France Navigator</a>` : `France Navigator`) +
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

  // ── Annual chart ───────────────────────────────────────────
  parts.push(renderAnnualChart(annual, { currentYear: year, overrides: config.annualOverrides }));

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

/**
 * Paid module, served by the Navigator /embed/funding-hub route.
 * @param {object} input
 * @param {object} input.summary   /funding/summary response
 * @param {object[]} input.latest  rounds sorted by date (newest first)
 * @param {object[]} input.largest rounds sorted by amount (largest first)
 * @param {object} input.config    config.json contents
 */
export function renderPaidModule({ summary, latest, largest, config }) {
  const year = summary.year;
  const reports = config.quarterlyReports?.[String(year)] ?? {};
  const maxQuarter = Math.max(1, ...summary.quarters.map((q) => q.total_disclosed_eur));

  const parts = [];
  parts.push(`<section class="ftjf ftjf-paid" data-year="${esc(year)}">`);
  parts.push(STYLE);

  // ── Stage chart ────────────────────────────────────────────
  parts.push(renderStageChart(summary));

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

  // ── Sector chart ───────────────────────────────────────────
  parts.push(renderSectorChart(summary));

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

  parts.push(`</section>`);
  return parts.join("\n");
}

// ── Embed document ───────────────────────────────────────────
// A standalone page for the paid module. Inside an iframe the Ghost theme's
// CSS is not available, so its colour tokens and Inter are defined here. The
// page reports its height to the parent (see embed-snippet.html in
// scripts/ftj-funding-hub) and follows the parent's light/dark choice.
const EMBED_HEAD_STYLE = `<style>
:root{--color-text-primary:#000;--color-text-secondary:#4E5965;--color-border-secondary:#D9D9D9;--color-background-primary:#fff;--color-background-secondary:#EFF8FA;--font-family-sansSerif:Inter,-apple-system,BlinkMacSystemFont,"Segoe UI",Helvetica,Arial,sans-serif}
:root[data-user-color-scheme=dark]{--color-text-primary:#fff;--color-text-secondary:#B3B3B3;--color-border-secondary:#303030;--color-background-primary:#000;--color-background-secondary:#1C1C1E}
@media (prefers-color-scheme:dark){:root:not([data-user-color-scheme]){--color-text-primary:#fff;--color-text-secondary:#B3B3B3;--color-border-secondary:#303030;--color-background-primary:#000;--color-background-secondary:#1C1C1E}
:root:not([data-user-color-scheme]) .ftjf{--ftjf-s1:#9a1f28;--ftjf-s2:#d0343e;--ftjf-s3:#f07a82;--ftjf-s4:#fbbdc1;--ftjf-s5:#6e6e6e;--ftjf-on1:#fff;--ftjf-on2:#fff;--ftjf-on3:#111;--ftjf-on4:#111;--ftjf-on5:#fff}}
html,body{margin:0;padding:0;background:var(--color-background-primary);color:var(--color-text-primary);font-family:var(--font-family-sansSerif);-webkit-font-smoothing:antialiased}
body{padding:2px 0 8px}
.ftjf h2{font-size:28px;font-weight:600;line-height:1.25;letter-spacing:-.01em}
.ftjf h2:first-of-type{margin-top:0}
</style>`;

const EMBED_SCRIPT = `<script>
(function () {
  var root = document.documentElement;
  function send() {
    var h = Math.ceil(document.body.getBoundingClientRect().height) + 16;
    parent.postMessage({ type: "ftj-funding-embed:height", height: h }, "*");
  }
  window.addEventListener("message", function (e) {
    var d = e.data || {};
    if (d.type === "ftj-funding-embed:scheme") {
      if (d.scheme === "dark" || d.scheme === "light") root.setAttribute("data-user-color-scheme", d.scheme);
      else root.removeAttribute("data-user-color-scheme");
      send();
    }
  });
  if (window.ResizeObserver) new ResizeObserver(send).observe(document.body);
  window.addEventListener("load", send);
  send();
})();
</script>`;

export function renderEmbedDocument({ body, title = "French startup funding data" }) {
  return (
    `<!doctype html><html lang="en"><head><meta charset="utf-8">` +
    `<meta name="viewport" content="width=device-width,initial-scale=1">` +
    `<meta name="robots" content="noindex,nofollow">` +
    `<title>${esc(title)}</title>` +
    `<base target="_top">` +
    `<link rel="preconnect" href="https://fonts.googleapis.com"><link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>` +
    `<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap">` +
    EMBED_HEAD_STYLE +
    `</head><body>${body}${EMBED_SCRIPT}</body></html>`
  );
}
