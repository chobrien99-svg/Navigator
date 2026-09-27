#!/usr/bin/env node
// FTJ Funding Hub sync
//
// Pulls funding data from the France Navigator public API, renders it to
// HTML and writes it into the /funding/ page on The French Tech Journal.
//
//   node scripts/ftj-funding-hub/sync.mjs --fixtures --out ./out   # offline preview
//   node scripts/ftj-funding-hub/sync.mjs --out ./out              # live data, no Ghost write
//   node scripts/ftj-funding-hub/sync.mjs --publish                # live data -> Ghost
//
// Environment (for --publish): GHOST_ADMIN_URL, GHOST_ADMIN_API_KEY
// Optional: NAVIGATOR_API_BASE, FUNDING_YEAR
//
// Safety: if Navigator is unreachable or returns data that fails validation,
// the script exits with an error and does NOT touch Ghost, so the page keeps
// its last good version.

import { readFile, writeFile, mkdir } from "node:fs/promises";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { parseArgs } from "node:util";
import { renderFundingHub } from "./render.mjs";
import { createGhostClient, upsertHubCard } from "./ghost.mjs";

const HERE = dirname(fileURLToPath(import.meta.url));

const { values: args } = parseArgs({
  options: {
    publish: { type: "boolean", default: false },
    fixtures: { type: "boolean", default: false },
    out: { type: "string" },
    year: { type: "string" },
  },
});

const readJson = async (path) => JSON.parse(await readFile(path, "utf8"));
const config = await readJson(join(HERE, "config.json"));

function parisYear() {
  return Number(new Intl.DateTimeFormat("en", { year: "numeric", timeZone: "Europe/Paris" }).format(new Date()));
}

async function fetchJson(url) {
  const res = await fetch(url, { headers: { Accept: "application/json" }, signal: AbortSignal.timeout(30_000) });
  if (!res.ok) throw new Error(`${url} -> HTTP ${res.status}`);
  return res.json();
}

async function loadNavigatorData(year) {
  if (args.fixtures) {
    const dir = join(HERE, "fixtures");
    const [summary, latest, largest] = await Promise.all(
      ["summary.json", "latest.json", "largest.json"].map((f) => readJson(join(dir, f)))
    );
    return { summary, latest, largest };
  }
  const base = (process.env.NAVIGATOR_API_BASE || config.navigatorApiBase).replace(/\/+$/, "");
  const [summary, latest, largest] = await Promise.all([
    fetchJson(`${base}/funding/summary?year=${year}`),
    fetchJson(`${base}/funding/rounds?year=${year}&limit=${config.latestLimit}&sort=announcement_date:desc`),
    fetchJson(`${base}/funding/rounds?year=${year}&limit=${config.largestLimit}&sort=amount_eur:desc`),
  ]);
  return { summary, latest, largest };
}

function validate({ summary, latest, largest }, year) {
  const problems = [];
  const isNum = (v) => typeof v === "number" && Number.isFinite(v);
  if (summary?.year !== year) problems.push(`summary.year is ${summary?.year}, expected ${year}`);
  if (!isNum(summary?.total_disclosed_eur)) problems.push("summary.total_disclosed_eur missing");
  if (!isNum(summary?.round_count)) problems.push("summary.round_count missing");
  if (!Array.isArray(summary?.quarters) || summary.quarters.length !== 4) problems.push("summary.quarters must have 4 entries");
  for (const [name, list] of [["latest", latest], ["largest", largest]]) {
    if (!Array.isArray(list?.data)) { problems.push(`${name}.data is not an array`); continue; }
    list.data.forEach((r, i) => {
      if (!r.id || !r.company_name) problems.push(`${name}.data[${i}] missing id/company_name`);
      if (r.amount_eur != null && !isNum(r.amount_eur)) problems.push(`${name}.data[${i}].amount_eur not a number`);
    });
  }
  // A year with rounds but an empty table means something upstream broke.
  if (summary?.round_count > 0 && latest?.data?.length === 0) problems.push("summary has rounds but latest list is empty");
  if (problems.length) throw new Error("Navigator data failed validation:\n  - " + problems.join("\n  - "));
}

async function main() {
  if (args.publish && args.fixtures) throw new Error("Refusing to publish sample fixture data to Ghost.");
  const year = Number(args.year || process.env.FUNDING_YEAR || parisYear());
  const data = await loadNavigatorData(year);
  validate(data, year);

  const ghost = args.publish
    ? createGhostClient({ url: requireEnv("GHOST_ADMIN_URL"), adminApiKey: requireEnv("GHOST_ADMIN_API_KEY") })
    : null;

  // Funding Wire links are nice-to-have: never fail the sync over them.
  let wire = [];
  if (ghost && config.fundingWireTag) {
    try {
      wire = await ghost.getRecentPostsByTag(config.fundingWireTag, config.fundingWireLimit);
    } catch (e) {
      console.warn(`Could not load Funding Wire posts (${e.message}); skipping that section.`);
    }
  }

  const html = renderFundingHub({
    summary: data.summary,
    latest: data.latest.data,
    largest: data.largest.data,
    wire,
    config,
  });
  console.log(
    `Rendered ${year}: ${data.summary.round_count} rounds, ${data.latest.data.length} latest, ` +
      `${data.largest.data.length} largest, ${wire.length} Funding Wire posts (${html.length.toLocaleString()} chars).`
  );

  if (args.out) {
    await mkdir(args.out, { recursive: true });
    await writeFile(join(args.out, "funding-hub-card.html"), html);
    const draft = await readFile(join(HERE, "editorial-draft.html"), "utf8");
    const [intro, methodology] = draft.split("<!-- FUNDING HUB CARD GOES HERE -->");
    await writeFile(join(args.out, "preview.html"), previewPage(intro + html + methodology, args.fixtures));
    console.log(`Wrote ${join(args.out, "funding-hub-card.html")} and preview.html`);
  }

  if (ghost) {
    const page = await ghost.getPageBySlug(config.ghostPageSlug);
    if (!page) throw new Error(`No Ghost page with slug "${config.ghostPageSlug}". Create it first (see README).`);
    const { doc, changed, created } = upsertHubCard(JSON.parse(page.lexical), html);
    if (!changed) {
      console.log("Ghost page already up to date; nothing to publish.");
      return;
    }
    await ghost.updatePageLexical(page, doc);
    console.log(`Ghost page "/${config.ghostPageSlug}/" ${created ? "received a new funding card" : "updated"}.`);
  }
}

function requireEnv(name) {
  const value = process.env[name];
  if (!value) throw new Error(`Missing environment variable ${name}`);
  return value;
}

function previewPage(body, isSample) {
  return `<!doctype html><html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>French Startup Funding: Latest Rounds, Deals &amp; Data | FTJ (preview)</title>
<style>body{font-family:Georgia,serif;max-width:960px;margin:0 auto;padding:24px 16px;color:#15171a;background:#fff;line-height:1.6}
h1{font-size:2.4em;line-height:1.1}a{color:#e3001b}
.preview-note{font:14px system-ui,sans-serif;background:#fff4d6;border:1px solid #e8c766;padding:10px 14px;border-radius:6px}
@media (prefers-color-scheme:dark){body{background:#15171a;color:#e8e8e8}.preview-note{background:#3a3218;border-color:#6b5a22}}</style>
</head><body>
<p class="preview-note">Local preview only. ${isSample ? "Figures are <strong>sample data</strong> built from repo CSVs, not live Navigator data. " : ""}The intro and methodology are draft copy for you to paste into the Ghost editor; the data block in the middle is what the sync script writes.</p>
${body}
</body></html>`;
}

main().catch((e) => {
  console.error(`\nFunding hub sync failed; Ghost was not modified.\n${e.stack || e.message}`);
  process.exit(1);
});
