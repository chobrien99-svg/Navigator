import type { ProgramOrganization, Organization } from "@/lib/types";
import {
  CITY_COORDS,
  METRO_ROLLUP,
  type Arrival,
  type BulletinData,
  type Cohort,
  type EditionSummary,
  type LedgerRow,
  type Region,
  type Sector,
  type Tier,
  type Transition,
} from "./cohort-data";

const COLOR = {
  next40: "#114563",
  ft120: "#3c6840",
  promoted: "#114563",
  demoted: "#b8862c",
  exit: "#963d3d",
} as const;

const ROMAN = ["", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII"];
const ORDINAL_WORD = [
  "",
  "First", "Second", "Third", "Fourth", "Fifth", "Sixth",
  "Seventh", "Eighth", "Ninth", "Tenth", "Eleventh", "Twelfth",
];

const UNITS = [
  "zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine",
  "ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen",
  "seventeen", "eighteen", "nineteen",
];
const TENS = ["", "", "twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety"];

/** Spell an integer 0–99 (for the editorial voice); falls back to digits beyond. */
export function numberToWords(n: number): string {
  if (n < 0 || n > 99 || !Number.isInteger(n)) return String(n);
  if (n < 20) return UNITS[n];
  const t = Math.floor(n / 10);
  const u = n % 10;
  return u === 0 ? TENS[t] : `${TENS[t]}-${UNITS[u]}`;
}

export function capitalize(s: string): string {
  return s.length ? s[0].toUpperCase() + s.slice(1) : s;
}

function tierOf(label: string | null | undefined): Tier | null {
  if (label === "Next 40" || label === "FT 120") return label;
  return null;
}

function primarySector(org: Organization | null | undefined): string | null {
  const list = org?.organization_sectors;
  if (!list || list.length === 0) return null;
  const primary = list.find((s) => s.is_primary) ?? list[0];
  return primary?.sectors?.name ?? null;
}

function cityName(org: Organization | null | undefined): string | null {
  return org?.cities?.name ?? null;
}

function canonicalCity(city: string): string {
  return METRO_ROLLUP[city.trim().toLowerCase()] ?? city.trim();
}

function arrivalNote(org: Organization): string {
  const short = org.short_description?.trim();
  if (short) return short;
  const long = org.description?.trim();
  if (long) {
    if (long.length <= 150) return long;
    const cut = long.slice(0, 150);
    const lastSpace = cut.lastIndexOf(" ");
    return `${cut.slice(0, lastSpace > 80 ? lastSpace : 150).trimEnd()}…`;
  }
  return "";
}

type Member = { oid: string; tier: Tier; org: Organization };

/**
 * Build every figure shown in the bulletin from the raw program rows.
 *
 * When `targetYear` is given, the data is scoped to editions up to and
 * including that year, so a past promotion renders as it stood then
 * (the chart, numbers, and ledger all end at the chosen year). Omitting
 * `targetYear` reports on the latest edition.
 */
export function buildBulletinData(rows: ProgramOrganization[], targetYear?: number): BulletinData {
  const scopedRows =
    targetYear == null
      ? rows
      : rows.filter((r) => {
          const y = r.program_editions?.year;
          return y != null && y <= targetYear;
        });

  // Group members by edition year.
  const byYear = new Map<number, Member[]>();
  for (const row of scopedRows) {
    const year = row.program_editions?.year ?? null;
    const tier = tierOf(row.group_label);
    const org = row.organizations ?? null;
    if (year == null || tier == null || !org) continue;
    if (!byYear.has(year)) byYear.set(year, []);
    byYear.get(year)!.push({ oid: row.organization_id, tier, org });
  }

  const years = [...byYear.keys()].sort((a, b) => a - b);
  const latestYear = years[years.length - 1];

  const tierMap = (year: number) => {
    const m = new Map<string, Tier>();
    for (const mem of byYear.get(year) ?? []) m.set(mem.oid, mem.tier);
    return m;
  };
  const orgMap = (year: number) => {
    const m = new Map<string, Organization>();
    for (const mem of byYear.get(year) ?? []) m.set(mem.oid, mem.org);
    return m;
  };
  const count = (year: number, tier: Tier) =>
    (byYear.get(year) ?? []).filter((m) => m.tier === tier).length;

  // ── Cohorts ──
  const cohorts: Cohort[] = years.map((year, i) => ({
    year,
    label: i === 0 ? "1er" : `${i + 1}e`,
    next40: count(year, "Next 40"),
    ft120: count(year, "FT 120"),
    current: year === latestYear,
  }));

  // ── Transitions (consecutive years) ──
  const transitions: Transition[] = [];
  for (let i = 0; i < years.length - 1; i++) {
    const a = tierMap(years[i]);
    const b = tierMap(years[i + 1]);
    const t: Transition = {
      from: years[i],
      to: years[i + 1],
      retainedN40: 0, retainedFT120: 0, promoted: 0, demoted: 0,
      exitedN40: 0, exitedFT120: 0, newToN40: 0, newToFT120: 0,
    };
    for (const [oid, at] of a) {
      const bt = b.get(oid);
      if (bt === undefined) {
        if (at === "Next 40") t.exitedN40++;
        else t.exitedFT120++;
      } else if (at === "Next 40" && bt === "Next 40") t.retainedN40++;
      else if (at === "FT 120" && bt === "FT 120") t.retainedFT120++;
      else if (at === "FT 120" && bt === "Next 40") t.promoted++;
      else if (at === "Next 40" && bt === "FT 120") t.demoted++;
    }
    for (const [oid, bt] of b) {
      if (!a.has(oid)) {
        if (bt === "Next 40") t.newToN40++;
        else t.newToFT120++;
      }
    }
    transitions.push(t);
  }

  const lastTransition = transitions[transitions.length - 1];
  const prevYear = years.length > 1 ? years[years.length - 2] : null;

  // ── Arrivals (members new to the latest cohort) ──
  const prevTiers = prevYear != null ? tierMap(prevYear) : new Map<string, Tier>();
  const latestMembers = byYear.get(latestYear) ?? [];
  const arrivals: Arrival[] = latestMembers
    .filter((m) => !prevTiers.has(m.oid))
    .map((m) => {
      const sector = primarySector(m.org);
      const city = cityName(m.org);
      return {
        name: m.org.name,
        slug: m.org.slug,
        sector: sector ?? "—",
        city: city ?? "—",
        note: arrivalNote(m.org),
        tier: m.tier,
      };
    })
    .sort((x, y) => {
      if (x.tier !== y.tier) return x.tier === "Next 40" ? -1 : 1;
      return x.name.localeCompare(y.name);
    });
  const arrivalsMeta = {
    total: arrivals.length,
    toNext40: arrivals.filter((a) => a.tier === "Next 40").length,
    toFt120: arrivals.filter((a) => a.tier === "FT 120").length,
  };

  // ── Sectors (latest cohort composition + YoY delta) ──
  const sectorCount = (year: number) => {
    const m = new Map<string, number>();
    for (const mem of byYear.get(year) ?? []) {
      const s = primarySector(mem.org);
      if (s) m.set(s, (m.get(s) ?? 0) + 1);
    }
    return m;
  };
  const latestSectors = sectorCount(latestYear);
  const prevSectors = prevYear != null ? sectorCount(prevYear) : new Map<string, number>();
  const classifiedTotal = [...latestSectors.values()].reduce((s, n) => s + n, 0);

  const sortedSectors = [...latestSectors.entries()]
    .map(([sector, c]) => ({ sector, count: c, delta: c - (prevSectors.get(sector) ?? 0) }))
    .sort((a, b) => b.count - a.count || a.sector.localeCompare(b.sector));

  const TOP = 11;
  const head = sortedSectors.slice(0, TOP);
  const tail = sortedSectors.slice(TOP);
  const sectors: Sector[] = head.map((s) => ({
    sector: s.sector,
    count: s.count,
    pct: classifiedTotal ? (s.count / classifiedTotal) * 100 : 0,
    delta: s.delta,
  }));
  if (tail.length) {
    const c = tail.reduce((sum, s) => sum + s.count, 0);
    sectors.push({
      sector: "Other",
      count: c,
      pct: classifiedTotal ? (c / classifiedTotal) * 100 : 0,
      delta: tail.reduce((sum, s) => sum + s.delta, 0),
    });
  }
  const gainer = sortedSectors
    .filter((s) => s.delta > 0)
    .sort((a, b) => b.delta - a.delta)[0];
  const sectorsMeta = {
    leader: sortedSectors[0]?.sector ?? "—",
    gainer: gainer ? gainer.sector : null,
  };

  // ── Geography ──
  const cityCount = (year: number) => {
    const m = new Map<string, number>();
    let located = 0;
    for (const mem of byYear.get(year) ?? []) {
      const raw = cityName(mem.org);
      if (!raw) continue;
      located++;
      const canon = canonicalCity(raw);
      m.set(canon, (m.get(canon) ?? 0) + 1);
    }
    return { m, located };
  };
  const { m: latestCities, located } = cityCount(latestYear);
  const prevCities = prevYear != null ? cityCount(prevYear).m : new Map<string, number>();

  const regions: Region[] = [...latestCities.entries()]
    .filter(([city]) => CITY_COORDS[city])
    .map(([city, c]) => ({
      city,
      region: CITY_COORDS[city].region,
      count: c,
      x: CITY_COORDS[city].x,
      y: CITY_COORDS[city].y,
      delta: c - (prevCities.get(city) ?? 0),
    }))
    .sort((a, b) => b.count - a.count || a.city.localeCompare(b.city));

  const parisCount = latestCities.get("Paris") ?? 0;
  const geo = {
    paris: parisCount,
    province: located - parisCount,
    located,
    total: latestMembers.length,
  };

  // ── Movements ledger (latest transition, company-level) ──
  const prevOrgs = prevYear != null ? orgMap(prevYear) : new Map<string, Organization>();
  const latestTier = tierMap(latestYear);
  const latestOrgs = orgMap(latestYear);

  const promotions: LedgerRow[] = [];
  const demotions: LedgerRow[] = [];
  const exits: LedgerRow[] = [];
  for (const [oid, at] of prevTiers) {
    const bt = latestTier.get(oid);
    const org = latestOrgs.get(oid) ?? prevOrgs.get(oid);
    const name = org?.name ?? "—";
    const slug = org?.slug ?? "";
    if (bt === undefined) {
      exits.push({ sym: "−", name, slug, from: at, to: "Exit", color: COLOR.exit });
    } else if (at === "FT 120" && bt === "Next 40") {
      promotions.push({ sym: "↑", name, slug, from: "FT 120", to: "Next 40", color: COLOR.promoted });
    } else if (at === "Next 40" && bt === "FT 120") {
      demotions.push({ sym: "↓", name, slug, from: "Next 40", to: "FT 120", color: COLOR.demoted });
    }
  }
  const newcomers: LedgerRow[] = arrivals.map((a) => ({
    sym: "+", name: a.name, slug: a.slug, from: "—", to: a.tier, color: COLOR.ft120,
  }));

  const byName = (a: LedgerRow, b: LedgerRow) => a.name.localeCompare(b.name);
  const ledger = [
    ...promotions.sort(byName),
    ...demotions.sort(byName),
    ...newcomers,
    ...exits.sort(byName),
  ];
  const ledgerMeta = { total: ledger.length };

  // ── Mini stats / headline numbers ──
  // The inaugural edition has no prior cohort, so the whole founding group
  // counts as new arrivals and there are no promotions/demotions/exits.
  const miniStats = lastTransition
    ? {
        newCount: lastTransition.newToN40 + lastTransition.newToFT120,
        promoted: lastTransition.promoted,
        demoted: lastTransition.demoted,
        exited: lastTransition.exitedN40 + lastTransition.exitedFT120,
      }
    : { newCount: latestMembers.length, promoted: 0, demoted: 0, exited: 0 };

  const cumulative = new Set(scopedRows.map((r) => r.organization_id)).size;
  const numbers = {
    total: latestMembers.length,
    cumulative,
    next40: count(latestYear, "Next 40"),
    ft120: count(latestYear, "FT 120"),
  };

  // ── Tape (active cohort, alphabetical) ──
  const tapeNames = latestMembers
    .map((m) => ({ name: m.org.name, slug: m.org.slug }))
    .sort((a, b) => a.name.localeCompare(b.name));
  const TAPE_SHOWN = 47;
  const tape = {
    names: tapeNames.slice(0, TAPE_SHOWN),
    remaining: Math.max(0, tapeNames.length - TAPE_SHOWN),
  };

  const n = cohorts.length;
  const meta = {
    bulletinNo: n,
    roman: ROMAN[n] ?? String(n),
    ordinalWord: ORDINAL_WORD[n] ?? `${n}th`,
    latestYear,
  };

  return {
    meta,
    cohorts,
    transitions,
    arrivals,
    arrivalsMeta,
    sectors,
    sectorsMeta,
    regions,
    geo,
    ledger,
    ledgerMeta,
    miniStats,
    numbers,
    tape,
  };
}

/** One summary row per promotion year, for the editions archive index. */
export function buildEditionIndex(rows: ProgramOrganization[]): EditionSummary[] {
  const byYear = new Map<number, Member[]>();
  for (const row of rows) {
    const year = row.program_editions?.year ?? null;
    const tier = tierOf(row.group_label);
    const org = row.organizations ?? null;
    if (year == null || tier == null || !org) continue;
    if (!byYear.has(year)) byYear.set(year, []);
    byYear.get(year)!.push({ oid: row.organization_id, tier, org });
  }

  const years = [...byYear.keys()].sort((a, b) => a - b);
  const latestYear = years[years.length - 1];
  const idsOf = (y: number) => new Set((byYear.get(y) ?? []).map((m) => m.oid));

  return years.map((year, i) => {
    const members = byYear.get(year) ?? [];
    const next40 = members.filter((m) => m.tier === "Next 40").length;
    const ft120 = members.filter((m) => m.tier === "FT 120").length;
    const newCount =
      i === 0
        ? members.length
        : members.filter((m) => !idsOf(years[i - 1]).has(m.oid)).length;
    const n = i + 1;
    return {
      year,
      label: i === 0 ? "1er" : `${i + 1}e`,
      bulletinNo: n,
      ordinalWord: ORDINAL_WORD[n] ?? `${n}th`,
      roman: ROMAN[n] ?? String(n),
      total: members.length,
      next40,
      ft120,
      newCount,
      current: year === latestYear,
    };
  });
}
