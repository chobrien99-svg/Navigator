// TypeScript types matching the Supabase unified schema

export type OrganizationType =
  | "startup"
  | "corporate"
  | "investor"
  | "accelerator"
  | "incubator"
  | "university"
  | "research_lab"
  | "public_agency"
  | "nonprofit"
  | "media"
  | "other";

export type OrganizationStatus =
  | "active"
  | "inactive"
  | "acquired"
  | "closed"
  | "ipo"
  | "stealth"
  | "unknown";

export type FundingStage =
  | "pre_seed"
  | "seed"
  | "series_a"
  | "series_b"
  | "series_c"
  | "series_d"
  | "series_e"
  | "series_f"
  | "growth"
  | "bridge"
  | "debt"
  | "grant"
  | "ipo"
  | "secondary"
  | "undisclosed"
  | "other";

export type FundraisingStatus =
  | "not_raising"
  | "exploring"
  | "actively_raising"
  | "closing"
  | "recently_closed"
  | "unknown";

export type TechnologyLayer =
  | "infrastructure"
  | "model"
  | "application"
  | "tooling"
  | "data"
  | "other";

export type RelationshipType =
  | "invested_in"
  | "acquired"
  | "partnered_with"
  | "spun_out_from"
  | "subsidiary_of"
  | "competes_with"
  | "incubated_by"
  | "accelerated_by"
  | "other";

// --- Core entities ---

export interface Organization {
  id: string;
  name: string;
  slug: string;
  organization_type: OrganizationType;
  description: string | null;
  short_description: string | null;
  website: string | null;
  email: string | null;
  linkedin_url: string | null;
  twitter_url: string | null;
  logo_url: string | null;
  status: OrganizationStatus;
  country: string;
  city_id: string | null;
  founded_date: string | null;
  employee_count: number | null;
  employee_range: string | null;
  founded_year: number | null;
  total_raised_eur: number | null;
  last_round: string | null;
  fundraising_status: FundraisingStatus | null;
  technology_layer: TechnologyLayer | null;
  signal_count: number | null;
  last_signal_date: string | null;
  created_at: string;
  updated_at: string;
  // Joined relations
  cities?: City | null;
  organization_sectors?: OrganizationSector[];
  organization_profiles?: OrganizationProfile[];
}

export interface City {
  id: string;
  name: string;
  slug: string;
  department: string | null;
  region: string | null;
  country: string;
  latitude: number | null;
  longitude: number | null;
}

export interface Person {
  id: string;
  full_name: string;
  slug: string;
  first_name: string | null;
  last_name: string | null;
  linkedin_url: string | null;
  twitter_url: string | null;
  email: string | null;
  bio: string | null;
  photo_url: string | null;
  has_phd: boolean;
  is_repeat_founder: boolean;
  has_big_tech_background: boolean;
  big_tech_employer: string | null;
  academic_lab: string | null;
  previous_exits: number;
  created_at: string;
  updated_at: string;
}

export interface OrganizationPerson {
  id: string;
  organization_id: string;
  person_id: string;
  role: string | null;
  title: string | null;
  is_current: boolean;
  is_founder: boolean;
  start_date: string | null;
  end_date: string | null;
  // Joined
  organizations?: Organization;
  people?: Person;
}

export interface PersonExperience {
  id: string;
  person_id: string;
  organization_id: string | null;
  company_name: string | null;
  role: string | null;
  title: string | null;
  start_date: string | null;
  end_date: string | null;
  is_current: boolean;
  description: string | null;
  // Joined
  organizations?: Organization;
}

export interface Sector {
  id: string;
  name: string;
  slug: string;
  parent_id: string | null;
  description: string | null;
  icon: string | null;
  color: string | null;
}

export interface OrganizationSector {
  id: string;
  organization_id: string;
  sector_id: string;
  is_primary: boolean;
  sectors?: Sector;
}

export interface OrganizationProfile {
  id: string;
  organization_id: string;
  what_they_are_building: string | null;
  why_it_matters: string | null;
  investor_brief: string | null;
  analyst_note: string | null;
  product_description: string | null;
  target_market: string | null;
  competitive_landscape: string | null;
  current_strategy: string | null;
  business_model_hypothesis: string | null;
  technical_thesis: string | null;
  fundraising_signal_summary: string | null;
  est_next_raise: string | null;
  entity_complexity: string | null;
}

export interface FundingRound {
  id: string;
  organization_id: string;
  stage: FundingStage;
  amount_eur: number | null;
  amount_usd: number | null;
  currency_original: string | null;
  amount_original: number | null;
  announced_date: string | null;
  closed_date: string | null;
  is_estimated: boolean;
  source_url: string | null;
  source_name: string | null;
  press_release_url: string | null;
  notes: string | null;
  valuation_eur: number | null;
  is_verified: boolean;
  created_at: string;
  // Joined
  organizations?: Organization;
  funding_round_investors?: FundingRoundInvestor[];
}

export interface FundingRoundInvestor {
  id: string;
  funding_round_id: string;
  investor_id: string;
  is_lead: boolean;
  investor_name: string | null;
  investment_amount_eur: number | null;
  // Joined
  organizations?: Organization;
}

export interface OrganizationRelationship {
  id: string;
  source_org_id: string;
  target_org_id: string;
  relationship_type: RelationshipType;
  description: string | null;
  start_date: string | null;
  end_date: string | null;
  // Joined — aliased in queries
  source_org?: Organization;
  target_org?: Organization;
}

export interface LegalEntity {
  id: string;
  organization_id: string;
  legal_name: string;
  legal_form: string | null;
  siren: string | null;
  siret: string | null;
  capital_eur: number | null;
  incorporation_date: string | null;
  registered_city: string | null;
  country: string;
  is_primary: boolean;
}

export interface OrganizationTag {
  id: string;
  organization_id: string;
  tag: string;
  strength: number | null;
}
