// French Tech Next 40/120 — Cohort dataset types + static layout lookups.
//
// The figures shown in the bulletin are derived at request time from the
// Navigator DB (programs → program_editions → program_organizations → …) by
// `cohort-transform.ts`. This file holds only (a) the shared types and (b) the
// non-DB editorial layout data: map coordinates and city→metro rollups, which
// describe where dots sit on the stylised France map, not cohort facts.

export type Tier = "Next 40" | "FT 120";

export type Cohort = {
  year: number;
  label: string;
  next40: number;
  ft120: number;
  current?: boolean;
};

export type Transition = {
  from: number;
  to: number;
  retainedN40: number;
  retainedFT120: number;
  promoted: number;
  demoted: number;
  exitedN40: number;
  exitedFT120: number;
  newToN40: number;
  newToFT120: number;
};

export type Arrival = {
  name: string;
  slug: string;
  sector: string;
  city: string;
  note: string;
  tier: Tier;
};

export type Sector = { sector: string; count: number; pct: number; delta: number };

export type Region = {
  city: string;
  region: string;
  count: number;
  x: number;
  y: number;
  delta: number;
};

export type LedgerRow = {
  sym: "↑" | "↓" | "+" | "−";
  name: string;
  slug: string;
  from: string;
  to: string;
  color: string;
};

// One row per promotion year, for the editions archive index.
export type EditionSummary = {
  year: number;
  label: string;
  bulletinNo: number;
  ordinalWord: string;
  roman: string;
  total: number;
  next40: number;
  ft120: number;
  newCount: number;
  current: boolean;
};

// The fully-derived shape consumed by <FrenchTechBulletin>.
export type BulletinData = {
  meta: {
    bulletinNo: number;
    roman: string;
    ordinalWord: string;
    latestYear: number;
  };
  cohorts: Cohort[];
  transitions: Transition[];
  arrivals: Arrival[];
  arrivalsMeta: { total: number; toNext40: number; toFt120: number };
  sectors: Sector[];
  sectorsMeta: { leader: string; gainer: string | null };
  regions: Region[];
  geo: { paris: number; province: number; located: number; total: number };
  ledger: LedgerRow[];
  ledgerMeta: { total: number };
  miniStats: { newCount: number; promoted: number; demoted: number; exited: number };
  numbers: { total: number; cumulative: number; next40: number; ft120: number };
  tape: { names: { name: string; slug: string }[]; remaining: number };
};

// ─── Static layout lookups (no DB source) ─────────────────────

// Dot positions on the stylised France map (viewBox 800 × 640, see france-map.tsx).
export const CITY_COORDS: Record<string, { x: number; y: number; region: string }> = {
  Paris: { x: 488, y: 188, region: "Île-de-France" },
  Lyon: { x: 565, y: 333, region: "Auvergne-Rhône-Alpes" },
  Marseille: { x: 595, y: 480, region: "Sud / PACA" },
  "Aix-en-Provence": { x: 612, y: 466, region: "Sud / PACA" },
  Toulouse: { x: 410, y: 470, region: "Occitanie" },
  Montpellier: { x: 478, y: 488, region: "Occitanie" },
  Grenoble: { x: 595, y: 360, region: "Auvergne-Rhône-Alpes" },
  Nantes: { x: 248, y: 300, region: "Pays de la Loire" },
  Bordeaux: { x: 295, y: 405, region: "Nouvelle-Aquitaine" },
  Lille: { x: 490, y: 100, region: "Hauts-de-France" },
  Rennes: { x: 230, y: 220, region: "Bretagne" },
  Strasbourg: { x: 660, y: 195, region: "Grand Est" },
  Nice: { x: 692, y: 460, region: "Sud / PACA" },
  "Clermont-Ferrand": { x: 470, y: 372, region: "Auvergne-Rhône-Alpes" },
  Nancy: { x: 632, y: 205, region: "Grand Est" },
  Angers: { x: 285, y: 295, region: "Pays de la Loire" },
};

// Communes that report under a larger metro for the geography view.
// Keys are lower-cased; values must exist in CITY_COORDS.
export const METRO_ROLLUP: Record<string, string> = {
  // Greater Paris / Île-de-France
  "suresnes": "Paris",
  "neuilly-sur-seine": "Paris",
  "boulogne-billancourt": "Paris",
  "massy": "Paris",
  "villejuif": "Paris",
  "palaiseau": "Paris",
  "évry": "Paris",
  "evry": "Paris",
  "évry-courcouronnes": "Paris",
  "issy-les-moulineaux": "Paris",
  "montrouge": "Paris",
  "saint-cloud": "Paris",
  "levallois-perret": "Paris",
  "courbevoie": "Paris",
  "nanterre": "Paris",
  "vincennes": "Paris",
  "charenton-le-pont": "Paris",
  "clichy": "Paris",
  "saint-denis": "Paris",
  "montreuil": "Paris",
  "ivry-sur-seine": "Paris",
  "rueil-malmaison": "Paris",
  "vélizy-villacoublay": "Paris",
  "gentilly": "Paris",
  "le kremlin-bicêtre": "Paris",
  "malakoff": "Paris",
  "bagneux": "Paris",
  "gennevilliers": "Paris",
  "puteaux": "Paris",
  "nesle": "Paris",
  // Greater Lyon
  "jonage": "Lyon",
  "villeurbanne": "Lyon",
  "écully": "Lyon",
  "ecully": "Lyon",
  "vaulx-en-velin": "Lyon",
  // Clermont-Ferrand basin
  "issoire": "Clermont-Ferrand",
  "pont-du-château": "Clermont-Ferrand",
  "pont-du-chateau": "Clermont-Ferrand",
  "riom": "Clermont-Ferrand",
  "aubière": "Clermont-Ferrand",
  "cournon-d'auvergne": "Clermont-Ferrand",
};
