import { supabase } from "./supabase";
import type {
  Organization,
  Person,
  FundingRound,
  OrganizationPerson,
  PersonExperience,
  LegalEntity,
  OrganizationRelationship,
  OrganizationTag,
} from "./types";

// ─── Helpers ──────────────────────────────────────────────────

export function formatEur(amount: number | null): string {
  if (amount == null) return "—";
  if (amount >= 1_000_000_000)
    return `€${(amount / 1_000_000_000).toFixed(1)}B`;
  if (amount >= 1_000_000) return `€${(amount / 1_000_000).toFixed(1)}M`;
  if (amount >= 1_000) return `€${(amount / 1_000).toFixed(0)}K`;
  return `€${amount.toLocaleString()}`;
}

export function formatStage(stage: string): string {
  return stage
    .replace(/_/g, " ")
    .replace(/\b\w/g, (c) => c.toUpperCase());
}

// ─── Organizations ────────────────────────────────────────────

export async function getOrganizations(opts?: {
  type?: string;
  limit?: number;
}) {
  let query = supabase
    .from("organizations")
    .select(
      `*, cities(name, slug, region), organization_sectors(is_primary, sectors(name, slug))`
    )
    .order("name");

  if (opts?.type) {
    query = query.eq("organization_type", opts.type);
  }
  if (opts?.limit) {
    query = query.limit(opts.limit);
  }

  const { data, error } = await query;
  if (error) throw error;
  return data as Organization[];
}

export async function getOrganizationBySlug(slug: string) {
  const { data, error } = await supabase
    .from("organizations")
    .select(
      `*,
      cities(name, slug, region),
      organization_sectors(is_primary, sectors(name, slug)),
      organization_profiles(*)`
    )
    .eq("slug", slug)
    .single();

  if (error) throw error;
  return data as Organization;
}

export async function getOrganizationFunding(orgId: string) {
  const { data, error } = await supabase
    .from("funding_rounds")
    .select(
      `*, funding_round_investors(*, organizations:investor_id(name, slug))`
    )
    .eq("organization_id", orgId)
    .order("announced_date", { ascending: false });

  if (error) throw error;
  return data as FundingRound[];
}

export async function getOrganizationPeople(orgId: string) {
  const { data, error } = await supabase
    .from("organization_people")
    .select(`*, people(*)`)
    .eq("organization_id", orgId)
    .order("is_founder", { ascending: false });

  if (error) throw error;
  return data as OrganizationPerson[];
}

export async function getOrganizationLegalEntities(orgId: string) {
  const { data, error } = await supabase
    .from("legal_entities")
    .select("*")
    .eq("organization_id", orgId);

  if (error) throw error;
  return data as LegalEntity[];
}

export async function getOrganizationRelationships(orgId: string) {
  const { data: outbound, error: e1 } = await supabase
    .from("organization_relationships")
    .select(`*, target_org:target_org_id(name, slug, organization_type)`)
    .eq("source_org_id", orgId);

  const { data: inbound, error: e2 } = await supabase
    .from("organization_relationships")
    .select(`*, source_org:source_org_id(name, slug, organization_type)`)
    .eq("target_org_id", orgId);

  if (e1) throw e1;
  if (e2) throw e2;
  return {
    outbound: (outbound ?? []) as OrganizationRelationship[],
    inbound: (inbound ?? []) as OrganizationRelationship[],
  };
}

export async function getOrganizationTags(orgId: string) {
  const { data, error } = await supabase
    .from("organization_tags")
    .select("*")
    .eq("organization_id", orgId)
    .order("strength", { ascending: false });

  if (error) throw error;
  return data as OrganizationTag[];
}

// ─── Investors (organizations with type=investor) ─────────────

export async function getInvestorPortfolio(investorId: string) {
  const { data, error } = await supabase
    .from("funding_round_investors")
    .select(
      `*, funding_rounds(*, organizations:organization_id(name, slug, organization_type, status, total_raised_eur))`
    )
    .eq("investor_id", investorId)
    .order("created_at", { ascending: false });

  if (error) throw error;
  return data;
}

// ─── People ───────────────────────────────────────────────────

export async function getPeople(opts?: { limit?: number }) {
  let query = supabase.from("people").select("*").order("full_name");
  if (opts?.limit) query = query.limit(opts.limit);

  const { data, error } = await query;
  if (error) throw error;
  return data as Person[];
}

export async function getPersonBySlug(slug: string) {
  const { data, error } = await supabase
    .from("people")
    .select("*")
    .eq("slug", slug)
    .single();

  if (error) throw error;
  return data as Person;
}

export async function getPersonOrganizations(personId: string) {
  const { data, error } = await supabase
    .from("organization_people")
    .select(
      `*, organizations(name, slug, organization_type, status, logo_url, cities(name))`
    )
    .eq("person_id", personId)
    .order("is_current", { ascending: false });

  if (error) throw error;
  return data as OrganizationPerson[];
}

export async function getPersonExperience(personId: string) {
  const { data, error } = await supabase
    .from("person_experience")
    .select(`*, organizations(name, slug)`)
    .eq("person_id", personId)
    .order("start_date", { ascending: false });

  if (error) throw error;
  return data as PersonExperience[];
}

// ─── Funding ──────────────────────────────────────────────────

export async function getAllFundingRounds(opts?: { limit?: number }) {
  let query = supabase
    .from("funding_rounds")
    .select(
      `*,
      organizations:organization_id(name, slug, organization_type, organization_sectors(is_primary, sectors(name, slug))),
      funding_round_investors(is_lead, investor_name, organizations:investor_id(name, slug))`
    )
    .order("announced_date", { ascending: false });

  if (opts?.limit) query = query.limit(opts.limit);

  const { data, error } = await query;
  if (error) throw error;
  return data as FundingRound[];
}

// ─── Stats ────────────────────────────────────────────────────

export async function getDashboardStats() {
  const [orgCount, peopleCount, roundsCount] = await Promise.all([
    supabase.from("organizations").select("id", { count: "exact", head: true }),
    supabase.from("people").select("id", { count: "exact", head: true }),
    supabase.from("funding_rounds").select("id", { count: "exact", head: true }),
  ]);

  // Sum total raised
  const { data: fundingSum } = await supabase
    .from("funding_rounds")
    .select("amount_eur");

  const totalRaised =
    fundingSum?.reduce((sum, r) => sum + (r.amount_eur ?? 0), 0) ?? 0;

  return {
    organizations: orgCount.count ?? 0,
    people: peopleCount.count ?? 0,
    fundingRounds: roundsCount.count ?? 0,
    totalRaised,
  };
}
