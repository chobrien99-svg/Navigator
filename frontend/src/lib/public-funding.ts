import { supabase } from "./supabase";
import { toRawEur } from "./queries";

// Public, read-only view of funding_rounds for external surfaces such as the
// French Tech Journal /funding/ hub. Only rows with publish_status =
// 'published' are returned, and only the fields listed in PublicFundingRound.
// Amounts are converted from the DB's €M convention to whole euros.

export interface PublicFundingRound {
  id: string;
  announcement_date: string | null;
  company_name: string;
  company_slug: string;
  sectors: string[];
  round_label: string;
  amount_original: number | null;
  currency_original: string | null;
  amount_eur: number | null;
  lead_investors: string[];
  investors: string[];
  hq_city: string | null;
  hq_country: string | null;
  french_founded_abroad: boolean;
  company_url: string | null;
  primary_source_url: string | null;
  ftj_url: string | null;
  updated_at: string;
}

export interface PublicFundingSummary {
  year: number;
  currency: "EUR";
  total_disclosed_eur: number;
  round_count: number;
  disclosed_round_count: number;
  largest_round: Pick<
    PublicFundingRound,
    "company_name" | "company_slug" | "amount_eur" | "round_label" | "announcement_date"
  > | null;
  quarters: { quarter: string; total_disclosed_eur: number; round_count: number }[];
  updated_at: string | null;
}

export type RoundSort = "announcement_date:desc" | "amount_eur:desc";

const ROUND_SELECT = `id, stage, amount_eur, amount_original, currency_original,
  announced_date, source_url, press_release_url, ftj_url, updated_at, created_at,
  organizations:organization_id(name, slug, website, country,
    cities!city_id(name),
    organization_sectors(is_primary, sectors(name))),
  funding_round_investors(is_lead, investor_name, organizations:investor_id(name))`;

// Supabase caps a single response at 1,000 rows, so page through the year.
const PAGE_SIZE = 1000;

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type Row = any;

const ROUND_LABELS: Record<string, string> = {
  pre_seed: "Pre-seed",
  seed: "Seed",
  series_a: "Series A",
  series_b: "Series B",
  series_c: "Series C",
  series_d: "Series D",
  series_e: "Series E",
  series_f: "Series F",
  growth: "Growth",
  bridge: "Bridge",
  debt: "Debt",
  grant: "Grant",
  ipo: "IPO",
  secondary: "Secondary",
  undisclosed: "Undisclosed",
  other: "Other",
};

async function fetchPublishedRoundsForYear(year: number): Promise<Row[]> {
  const rows: Row[] = [];
  for (let from = 0; ; from += PAGE_SIZE) {
    const { data, error } = await supabase
      .from("funding_rounds")
      .select(ROUND_SELECT)
      .eq("publish_status", "published")
      .gte("announced_date", `${year}-01-01`)
      .lte("announced_date", `${year}-12-31`)
      .order("announced_date", { ascending: false })
      .order("id")
      .range(from, from + PAGE_SIZE - 1);
    if (error) throw error;
    rows.push(...(data ?? []));
    if (!data || data.length < PAGE_SIZE) return rows;
  }
}

function toPublicRound(r: Row): PublicFundingRound {
  const org = r.organizations ?? {};
  const sectors = [...(org.organization_sectors ?? [])]
    .sort((a: Row, b: Row) => Number(b.is_primary) - Number(a.is_primary))
    .map((s: Row) => s.sectors?.name)
    .filter(Boolean);
  const investorRows = [...(r.funding_round_investors ?? [])].sort(
    (a: Row, b: Row) => Number(b.is_lead) - Number(a.is_lead)
  );
  const nameOf = (i: Row) => i.organizations?.name ?? i.investor_name;
  const country = org.country ?? null;

  return {
    id: r.id,
    announcement_date: r.announced_date,
    company_name: (org.name ?? "").trim(),
    company_slug: org.slug ?? "",
    sectors: [...new Set<string>(sectors)],
    round_label: ROUND_LABELS[r.stage] ?? "Undisclosed",
    amount_original: r.amount_original ?? null,
    currency_original: r.currency_original ?? null,
    amount_eur: toRawEur(r.amount_eur),
    lead_investors: investorRows.filter((i: Row) => i.is_lead).map(nameOf).filter(Boolean),
    investors: investorRows.map(nameOf).filter(Boolean),
    hq_city: org.cities?.name ?? null,
    hq_country: country,
    french_founded_abroad: Boolean(country && country !== "France"),
    company_url: org.website ?? null,
    primary_source_url: r.press_release_url ?? r.source_url ?? null,
    ftj_url: r.ftj_url ?? null,
    updated_at: r.updated_at ?? r.created_at,
  };
}

export async function getPublicRounds(opts: {
  year: number;
  limit: number;
  sort: RoundSort;
}): Promise<PublicFundingRound[]> {
  const rounds = (await fetchPublishedRoundsForYear(opts.year)).map(toPublicRound);
  if (opts.sort === "amount_eur:desc") {
    rounds.sort((a, b) => (b.amount_eur ?? -1) - (a.amount_eur ?? -1));
  }
  return rounds.slice(0, opts.limit);
}

export async function getPublicSummary(year: number): Promise<PublicFundingSummary> {
  const rounds = (await fetchPublishedRoundsForYear(year)).map(toPublicRound);

  const quarters = ["Q1", "Q2", "Q3", "Q4"].map((quarter) => ({
    quarter,
    total_disclosed_eur: 0,
    round_count: 0,
  }));
  let total = 0;
  let disclosed = 0;
  let largest: PublicFundingRound | null = null;
  let updatedAt: string | null = null;

  for (const r of rounds) {
    const month = Number(r.announcement_date?.slice(5, 7));
    const q = quarters[Math.floor((month - 1) / 3)];
    if (q) q.round_count += 1;
    if (r.amount_eur != null) {
      total += r.amount_eur;
      disclosed += 1;
      if (q) q.total_disclosed_eur += r.amount_eur;
      if (!largest || r.amount_eur > (largest.amount_eur ?? 0)) largest = r;
    }
    if (!updatedAt || r.updated_at > updatedAt) updatedAt = r.updated_at;
  }

  return {
    year,
    currency: "EUR",
    total_disclosed_eur: Math.round(total),
    round_count: rounds.length,
    disclosed_round_count: disclosed,
    largest_round: largest && {
      company_name: largest.company_name,
      company_slug: largest.company_slug,
      amount_eur: largest.amount_eur,
      round_label: largest.round_label,
      announcement_date: largest.announcement_date,
    },
    quarters: quarters.map((q) => ({ ...q, total_disclosed_eur: Math.round(q.total_disclosed_eur) })),
    updated_at: updatedAt,
  };
}

// ─── Route helpers ────────────────────────────────────────────

export const PUBLIC_API_HEADERS = {
  // Cache at the CDN for 30 min, and keep serving the last good copy for a
  // day while revalidating or if Supabase is briefly unavailable.
  "Cache-Control": "public, s-maxage=1800, stale-while-revalidate=86400, stale-if-error=86400",
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, OPTIONS",
};

export function parseYear(value: string | null): number | null {
  const year = value ? Number(value) : new Date().getFullYear();
  return Number.isInteger(year) && year >= 2015 && year <= 2100 ? year : null;
}

export function publicError(message: string, status: number) {
  return Response.json({ error: message }, { status, headers: { "Cache-Control": "no-store" } });
}
