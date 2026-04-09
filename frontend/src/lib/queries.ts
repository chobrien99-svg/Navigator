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
  ProgramOrganization,
} from "./types";

// ─── Helpers ──────────────────────────────────────────────────

// Amounts in the funding_rounds table are stored in millions (€M).
// e.g. 1818.18 means €1,818.18M = €1,818,180,000
const AMOUNT_MULTIPLIER = 1_000_000;

export function toRawEur(amountInMillions: number | null): number | null {
  if (amountInMillions == null) return null;
  return amountInMillions * AMOUNT_MULTIPLIER;
}

export function formatEur(amount: number | null): string {
  if (amount == null) return "—";
  if (amount >= 1_000_000_000)
    return `€${(amount / 1_000_000_000).toFixed(1)}B`;
  if (amount >= 1_000_000) return `€${(amount / 1_000_000).toFixed(1)}M`;
  if (amount >= 1_000) return `€${(amount / 1_000).toFixed(0)}K`;
  return `€${amount.toLocaleString()}`;
}

/** Format an amount stored in millions (as in the DB) directly to display */
export function formatEurFromDb(amountInMillions: number | null): string {
  return formatEur(toRawEur(amountInMillions));
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

// ─── Programs ────────────────────────────────────────────────

export async function getFrenchTechNextMembers() {
  // Step 1: Get the program ID
  const { data: programs, error: progErr } = await supabase
    .from("programs")
    .select("id")
    .eq("slug", "french-tech-next40-120");

  if (progErr) throw progErr;
  if (!programs || programs.length === 0) {
    throw new Error("Program 'french-tech-next40-120' not found. Check RLS policies on the programs table.");
  }
  const programId = programs[0].id;

  // Step 2: Get edition IDs for this program
  const { data: editions, error: edErr } = await supabase
    .from("program_editions")
    .select("id")
    .eq("program_id", programId);

  if (edErr) throw edErr;
  if (!editions || editions.length === 0) {
    throw new Error("No program editions found. Check RLS policies on the program_editions table.");
  }
  const editionIds = editions.map((e: { id: string }) => e.id);

  // Step 3: Get program organizations with their editions and orgs
  const { data, error } = await supabase
    .from("program_organizations")
    .select(
      `*,
      program_editions(id, year, cohort_label, slug, source_url),
      organizations(
        id, name, slug, organization_type, status, description, short_description,
        website, logo_url, country, total_raised_eur, employee_range, founded_year,
        cities(name, slug, region),
        organization_sectors(is_primary, sectors(name, slug))
      )`
    )
    .in("program_edition_id", editionIds);

  if (error) throw error;
  return data as ProgramOrganization[];
}

export async function getILabMembers() {
  return getProgramMembers("i-lab");
}

export async function getINovMembers() {
  return getProgramMembers("i-nov");
}

async function getProgramMembers(programSlug: string) {
  // Step 1: Get the program ID
  const { data: programs, error: progErr } = await supabase
    .from("programs")
    .select("id")
    .eq("slug", programSlug);

  if (progErr) throw progErr;
  if (!programs || programs.length === 0) {
    throw new Error(`Program '${programSlug}' not found.`);
  }
  const programId = programs[0].id;

  // Step 2: Get edition IDs
  const { data: editions, error: edErr } = await supabase
    .from("program_editions")
    .select("id")
    .eq("program_id", programId);

  if (edErr) throw edErr;
  if (!editions || editions.length === 0) {
    throw new Error(`No editions found for '${programSlug}'.`);
  }
  const editionIds = editions.map((e: { id: string }) => e.id);

  // Step 3: Get program organizations with editions and orgs
  const { data, error } = await supabase
    .from("program_organizations")
    .select(
      `*,
      program_editions(id, year, cohort_label, slug, source_url),
      organizations(
        id, name, slug, organization_type, status, description, short_description,
        website, logo_url, country, total_raised_eur, employee_range, founded_year,
        cities(name, slug, region),
        organization_sectors(is_primary, sectors(name, slug))
      )`
    )
    .in("program_edition_id", editionIds);

  if (error) throw error;
  return data as ProgramOrganization[];
}

export async function getOrganizationPrograms(orgId: string) {
  const { data, error } = await supabase
    .from("program_organizations")
    .select(
      `*, program_editions(*, programs(name, slug))`
    )
    .eq("organization_id", orgId);

  if (error) throw error;
  return data as ProgramOrganization[];
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
