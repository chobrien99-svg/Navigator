// ─── MESR Open Data API Client ─────────────────────────────
// Connects to data.enseignementsup-recherche.gouv.fr Explore API v2.1
// No auth required — fully public REST API

const BASE_URL =
  "https://data.enseignementsup-recherche.gouv.fr/api/explore/v2.1";

// ─── Core Datasets ────────────────────────────────────────

export const DATASETS = {
  // Higher education institutions (universities, grandes écoles, etc.)
  institutions:
    "fr-esr-principaux-etablissements-enseignement-superieur",
  // Active public research structures (labs, teams, units)
  researchStructures: "fr-esr-structures-recherche-publiques-actives",
  // scanR research funding (H2020, Horizon Europe, ANR, etc.)
  researchFunding: "export-des-financements-exposes-dans-scanr",
  // scanR organizations
  scanrOrganizations: "export-des-organisations-exposees-dans-scanr",
  // CIR/CII approved orgs (Research Tax Credit + Innovation Tax Credit)
  cirCiiApproved:
    "fr-esr-cir-et-cii-organismes-et-bureaux-de-style-agrees",
  // Public orgs approved for collaborative research tax credit (CICo)
  cicoApproved:
    "fr-esr-cico-organismes-publics-agrees-ci-collaboration-de-recherche",
  // Public & private entities involved in R&D
  rdEntities:
    "fr-esr-etablissements-publics-prives-impliques-recherche-developpement",
  // i-Lab laureates (deep-tech startup competition, since 1999)
  iLabLaureates: "fr-esr-laureats-concours-national-i-lab",
  // i-Nov laureates (innovation competition)
  iNovLaureates: "fr-esr-laureats-concours-i-nov",
  // i-PhD laureates (doctoral deep-tech competition)
  iPhDLaureates: "fr-esr-laureats-concours-i-phd",
  // Patent data
  patents: "fr-esr-brevets-france-inpi-oeb",
  // R&D spending by enterprises
  rdEnterprise: "fr-esr-rd-moyens-entreprises",
  // Doctoral schools
  doctoralSchools: "fr-esr-ecoles_doctorales_annuaire",
  // EU Horizon Europe projects
  horizonProjects: "fr-esr-all-projects-signed-informations",
  // Horizon Europe entity participation
  horizonEntities: "fr-esr-horizon-projects-entities",
  // Tech transfer structures (IRT, SATT, Carnot, etc.)
  techTransfer: "fr-esr-cartographie",
  // Ecosystem cartography
  cartography: "fr-esr-cartographie",
} as const;

// ─── Types ────────────────────────────────────────────────

export interface MESRResponse<T> {
  total_count: number;
  results: T[];
}

export interface MESRInstitution {
  uo_lib: string;
  nom_court: string | null;
  sigle: string | null;
  type_d_etablissement: string | null;
  secteur_d_etablissement: string | null;
  url: string | null;
  uai: string | null;
  siren: string | null;
  siret: string | null;
  date_creation: string | null;
  com_nom: string | null;
  dep_nom: string | null;
  reg_nom: string | null;
  coordonnees: { lat: number; lon: number } | null;
  inscrits: number | null;
  identifiant_ror: string | null;
  identifiant_wikidata: string | null;
  compte_linkedin: string | null;
  compte_twitter: string | null;
}

export interface MESRResearchStructure {
  numero_nacional_de_structure: string;
  libelle: string;
  sigle: string | null;
  annee_de_creation: number | null;
  type_de_structure: string | null;
  site_web: string | null;
  commune: string | null;
  code_postal: string | null;
  nom_du_responsable: string | null;
  prenom_du_responsable: string | null;
  tutelles: string | null;
  domaine_scientifique: string | null;
  panel_erc: string | null;
}

export interface MESRFunding {
  id: string;
  type: string | null;
  year: number | null;
  acronym: string | null;
  label: string | null;
  call: string | null;
  startdate: string | null;
  keywords: string | null;
  participantcount: number | null;
  participants: string | null;
}

export interface MESRILabLaureate {
  annee_de_concours: number | null;
  nom_du_laureat: string | null;
  prenom_du_candidat: string | null;
  domaine_technologique: string | null;
  region: string | null;
  ndeg_siren: string | null;
  libelle_entreprise: string | null;
  site_web_entreprise: string | null;
  unite_de_recherche_liee_au_projet: string | null;
  structure_liee_au_projet: string | null;
  type_de_candidatura: string | null;
  grand_prix: string | null;
}

export interface MESRRdEntity {
  siren: string | null;
  libelle: string;
  sigle: string | null;
  date_de_creation: string | null;
  categorie: string | null;
  code_ape: string | null;
  libelle_ape: string | null;
  tranche_etp: string | null;
  chiffre_d_affaire_2014: number | null;
  commune: string | null;
  departement: string | null;
  region: string | null;
  badge: string | null;
  scanr: string | null;
  site_web: string | null;
}

export interface MESRCirApproved {
  dispositif: string | null;
  type_lib: string | null;
  annees: string | null;
  siren: string | null;
  entreprise: string | null;
  sigle: string | null;
  categorie: string | null;
  activite: string | null;
  ville: string | null;
  reg_nom: string | null;
  scanr: string | null;
}

// ─── Fetcher ──────────────────────────────────────────────

export async function queryMESR<T>(
  datasetId: string,
  opts?: {
    limit?: number;
    offset?: number;
    where?: string;
    orderBy?: string;
    select?: string;
    groupBy?: string;
  }
): Promise<MESRResponse<T>> {
  const params = new URLSearchParams();
  params.set("limit", String(opts?.limit ?? 20));
  if (opts?.offset) params.set("offset", String(opts.offset));
  if (opts?.where) params.set("where", opts.where);
  if (opts?.orderBy) params.set("order_by", opts.orderBy);
  if (opts?.select) params.set("select", opts.select);
  if (opts?.groupBy) params.set("group_by", opts.groupBy);

  const url = `${BASE_URL}/catalog/datasets/${datasetId}/records?${params}`;

  const res = await fetch(url, { next: { revalidate: 3600 } }); // cache 1hr
  if (!res.ok) {
    throw new Error(
      `MESR API error: ${res.status} ${res.statusText} for ${datasetId}`
    );
  }

  return res.json();
}

// ─── Convenience functions ────────────────────────────────

export async function getInstitutions(opts?: {
  limit?: number;
  offset?: number;
  region?: string;
  type?: string;
  search?: string;
}) {
  const where: string[] = [];
  if (opts?.region) where.push(`reg_nom = "${opts.region}"`);
  if (opts?.type) where.push(`type_d_etablissement = "${opts.type}"`);
  if (opts?.search) where.push(`search(uo_lib, "${opts.search}")`);

  return queryMESR<MESRInstitution>(DATASETS.institutions, {
    limit: opts?.limit ?? 50,
    offset: opts?.offset,
    where: where.length ? where.join(" AND ") : undefined,
    orderBy: "uo_lib ASC",
  });
}

export async function getResearchStructures(opts?: {
  limit?: number;
  offset?: number;
  domain?: string;
  search?: string;
}) {
  const where: string[] = [];
  if (opts?.domain) where.push(`domaine_scientifique = "${opts.domain}"`);
  if (opts?.search) where.push(`search(libelle, "${opts.search}")`);

  return queryMESR<MESRResearchStructure>(DATASETS.researchStructures, {
    limit: opts?.limit ?? 50,
    offset: opts?.offset,
    where: where.length ? where.join(" AND ") : undefined,
    orderBy: "libelle ASC",
  });
}

export async function getResearchFunding(opts?: {
  limit?: number;
  offset?: number;
  type?: string;
  yearFrom?: number;
  yearTo?: number;
  search?: string;
}) {
  const where: string[] = [];
  if (opts?.type) where.push(`type = "${opts.type}"`);
  if (opts?.yearFrom) where.push(`year >= ${opts.yearFrom}`);
  if (opts?.yearTo) where.push(`year <= ${opts.yearTo}`);
  if (opts?.search) where.push(`search(label, "${opts.search}")`);

  return queryMESR<MESRFunding>(DATASETS.researchFunding, {
    limit: opts?.limit ?? 50,
    offset: opts?.offset,
    where: where.length ? where.join(" AND ") : undefined,
    orderBy: "year DESC",
  });
}

export async function getILabLaureates(opts?: {
  limit?: number;
  offset?: number;
  yearFrom?: number;
  domain?: string;
  search?: string;
}) {
  const where: string[] = [];
  if (opts?.yearFrom) where.push(`annee_de_concours >= ${opts.yearFrom}`);
  if (opts?.domain)
    where.push(`domaine_technologique = "${opts.domain}"`);
  if (opts?.search) where.push(`search(nom_du_laureat, "${opts.search}")`);

  return queryMESR<MESRILabLaureate>(DATASETS.iLabLaureates, {
    limit: opts?.limit ?? 50,
    offset: opts?.offset,
    where: where.length ? where.join(" AND ") : undefined,
    orderBy: "annee_de_concours DESC",
  });
}

export async function getRdEntities(opts?: {
  limit?: number;
  offset?: number;
  badge?: string;
  search?: string;
}) {
  const where: string[] = [];
  if (opts?.badge) where.push(`badge like "${opts.badge}"`);
  if (opts?.search) where.push(`search(libelle, "${opts.search}")`);

  return queryMESR<MESRRdEntity>(DATASETS.rdEntities, {
    limit: opts?.limit ?? 50,
    offset: opts?.offset,
    where: where.length ? where.join(" AND ") : undefined,
    orderBy: "libelle ASC",
  });
}

export async function getCirApproved(opts?: {
  limit?: number;
  offset?: number;
  dispositif?: string;
  search?: string;
}) {
  const where: string[] = [];
  if (opts?.dispositif) where.push(`dispositif = "${opts.dispositif}"`);
  if (opts?.search) where.push(`search(entreprise, "${opts.search}")`);

  return queryMESR<MESRCirApproved>(DATASETS.cirCiiApproved, {
    limit: opts?.limit ?? 50,
    offset: opts?.offset,
    where: where.length ? where.join(" AND ") : undefined,
    orderBy: "entreprise ASC",
  });
}

// ─── Aggregation helpers ──────────────────────────────────

export async function getInstitutionStats() {
  const [byType, byRegion] = await Promise.all([
    queryMESR<{ type_d_etablissement: string; count: number }>(
      DATASETS.institutions,
      {
        select: "type_d_etablissement, count(*) as count",
        groupBy: "type_d_etablissement",
        orderBy: "count DESC",
        limit: 50,
      }
    ),
    queryMESR<{ reg_nom: string; count: number }>(DATASETS.institutions, {
      select: "reg_nom, count(*) as count",
      groupBy: "reg_nom",
      orderBy: "count DESC",
      limit: 20,
    }),
  ]);

  return {
    total: byType.total_count,
    byType: byType.results,
    byRegion: byRegion.results,
  };
}

export async function getResearchStructureStats() {
  const [byDomain] = await Promise.all([
    queryMESR<{ domaine_scientifique: string; count: number }>(
      DATASETS.researchStructures,
      {
        select: "domaine_scientifique, count(*) as count",
        groupBy: "domaine_scientifique",
        orderBy: "count DESC",
        limit: 20,
      }
    ),
  ]);

  return {
    total: byDomain.total_count,
    byDomain: byDomain.results,
  };
}

export async function getFundingStats() {
  const [byType, byYear] = await Promise.all([
    queryMESR<{ type: string; count: number }>(DATASETS.researchFunding, {
      select: "type, count(*) as count",
      groupBy: "type",
      orderBy: "count DESC",
      limit: 20,
    }),
    queryMESR<{ year: number; count: number }>(DATASETS.researchFunding, {
      select: "year, count(*) as count",
      groupBy: "year",
      orderBy: "year DESC",
      limit: 30,
    }),
  ]);

  return {
    total: byType.total_count,
    byType: byType.results,
    byYear: byYear.results,
  };
}
