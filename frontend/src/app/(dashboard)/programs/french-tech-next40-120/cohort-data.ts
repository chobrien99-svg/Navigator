// French Tech Next 40/120 — Cohort dataset (v1 fixture)
//
// Ported from the design handoff (design_handoff_french_tech_dashboard/mockup/data.jsx).
// These are editorial/aggregate figures that do not map onto the DB schema
// (cohort-flow transitions, sector deltas, map coordinates, hand-written notes),
// so they live here as typed fixture data until a dedicated query layer exists.

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

export type Tier = "Next 40" | "FT 120";

export type Arrival = {
  name: string;
  sector: string;
  city: string;
  raised: string;
  note: string;
  tier: Tier;
  initial: string;
  color: string;
};

export type Promotion = {
  name: string;
  from: "FT 120";
  to: "Next 40";
  sector: string;
  city: string;
  raised: string;
  note: string;
};

export type Exit = {
  name: string;
  reason: string;
  from: Tier;
  since: number;
  sector: string;
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
  from: string;
  to: string;
  color: string;
};

export type Headline = {
  total: number;
  next40: number;
  ft120: number;
  new: number;
  promoted: number;
  demoted: number;
  retained: number;
  exited: number;
  unicorns: number;
  totalRaised: string;
  womenFounders: number;
  paris: number;
};

// Cohort flow numbers — each year holds Next40=40 and FT120=80 (120 total).
export const COHORTS: Cohort[] = [
  { year: 2020, label: "1er", next40: 40, ft120: 80 },
  { year: 2021, label: "2e", next40: 40, ft120: 80 },
  { year: 2022, label: "3e", next40: 40, ft120: 80 },
  { year: 2023, label: "4e", next40: 40, ft120: 80 },
  { year: 2024, label: "5e", next40: 40, ft120: 80 },
  { year: 2025, label: "6e", next40: 40, ft120: 80, current: true },
];

export const TRANSITIONS: Transition[] = [
  { from: 2020, to: 2021, retainedN40: 30, retainedFT120: 56, promoted: 8, demoted: 2, exitedN40: 8, exitedFT120: 16, newToN40: 2, newToFT120: 22 },
  { from: 2021, to: 2022, retainedN40: 31, retainedFT120: 58, promoted: 7, demoted: 2, exitedN40: 7, exitedFT120: 15, newToN40: 2, newToFT120: 20 },
  { from: 2022, to: 2023, retainedN40: 28, retainedFT120: 55, promoted: 10, demoted: 2, exitedN40: 10, exitedFT120: 15, newToN40: 2, newToFT120: 23 },
  { from: 2023, to: 2024, retainedN40: 30, retainedFT120: 57, promoted: 8, demoted: 2, exitedN40: 8, exitedFT120: 15, newToN40: 2, newToFT120: 21 },
  { from: 2024, to: 2025, retainedN40: 29, retainedFT120: 42, promoted: 7, demoted: 2, exitedN40: 9, exitedFT120: 31, newToN40: 4, newToFT120: 36 },
];

export const ARRIVALS: Arrival[] = [
  // Next 40 arrivals (4)
  { name: "Dust", sector: "Artificial Intelligence", city: "Paris", raised: "€85M", note: "Enterprise AI agents platform; surge after €60M Series B closed Q1 2025.", tier: "Next 40", initial: "D", color: "#114563" },
  { name: "Owkin", sector: "BioTech", city: "Paris", raised: "€420M", note: "AI-powered drug discovery in oncology; strategic alliance with Sanofi extended.", tier: "Next 40", initial: "O", color: "#503863" },
  { name: "Photoroom", sector: "Artificial Intelligence", city: "Paris", raised: "€48M", note: "Generative imaging suite for commerce; 200M downloads, 70% YoY revenue.", tier: "Next 40", initial: "P", color: "#3c6840" },
  { name: "Sweep", sector: "ClimateTech", city: "Paris", raised: "€32M", note: "Carbon disclosure platform; promoted from FT 120 — sustained enterprise growth.", tier: "Next 40", initial: "S", color: "#3c6840" },

  // FT 120 arrivals (36)
  { name: "Linkup", sector: "Artificial Intelligence", city: "Paris", raised: "€12M", note: "Real-time web search infrastructure for LLMs; AWS Activate partner of the year.", tier: "FT 120", initial: "L", color: "#114563" },
  { name: "LightOn", sector: "Artificial Intelligence", city: "Paris", raised: "€18M", note: "Sovereign LLM platform; €15M Series A closed with state participation.", tier: "FT 120", initial: "L", color: "#114563" },
  { name: "Pigment", sector: "SaaS", city: "Paris", raised: "€220M", note: "Business planning OS; expansion to defense forecasting workflows.", tier: "FT 120", initial: "P", color: "#3c6840" },
  { name: "Cosmian", sector: "Cybersecurity", city: "Paris", raised: "€14M", note: "Confidential computing; certified by ANSSI for defense applications.", tier: "FT 120", initial: "C", color: "#963d3d" },
  { name: "Tehtris", sector: "Cybersecurity", city: "Bordeaux", raised: "€44M", note: "Sovereign XDR platform; ANSSI-qualified, expanding across NATO ministries.", tier: "FT 120", initial: "T", color: "#963d3d" },
  { name: "HarfangLab", sector: "Cybersecurity", city: "Paris", raised: "€25M", note: "Endpoint detection & response; SecNumCloud-ready, ANSSI Visa de sécurité.", tier: "FT 120", initial: "H", color: "#963d3d" },
  { name: "Sorare", sector: "Web3 / Gaming", city: "Paris", raised: "€680M", note: "Fantasy football platform; reclassified after revenue recovery and FIFA deal.", tier: "FT 120", initial: "S", color: "#503863" },
  { name: "ManoMano", sector: "E-commerce", city: "Paris", raised: "€430M", note: "DIY marketplace; profitability milestone in FY25.", tier: "FT 120", initial: "M", color: "#3c6840" },
  { name: "Welcome to the Jungle", sector: "HR Tech", city: "Paris", raised: "€52M", note: "Recruitment media platform; international expansion across DACH.", tier: "FT 120", initial: "W", color: "#3c6840" },
  { name: "Loft Orbital", sector: "SpaceTech", city: "Toulouse", raised: "€110M", note: "Shared satellite infrastructure; multi-mission contracts with CNES, ESA.", tier: "FT 120", initial: "L", color: "#114563" },
  { name: "Constellr", sector: "SpaceTech", city: "Paris", raised: "€20M", note: "Thermal Earth observation; first French deployment from Lyon ground station.", tier: "FT 120", initial: "C", color: "#114563" },
  { name: "Skello", sector: "SaaS", city: "Paris", raised: "€40M", note: "Workforce scheduling SaaS; 20K customer locations.", tier: "FT 120", initial: "S", color: "#3c6840" },
  { name: "Ramify", sector: "FinTech", city: "Paris", raised: "€11M", note: "Private wealth management for top 5% earners; AMF-licensed advisor.", tier: "FT 120", initial: "R", color: "#503863" },
  { name: "Lumio", sector: "CleanTech", city: "Lyon", raised: "€22M", note: "Residential solar marketplace; 8,000 installations completed in FY25.", tier: "FT 120", initial: "L", color: "#3c6840" },
  { name: "Verkor Mobility", sector: "Mobility", city: "Grenoble", raised: "€18M", note: "Spin-off from Verkor; battery management software for fleets.", tier: "FT 120", initial: "V", color: "#3c6840" },
  { name: "Aledia", sector: "DeepTech", city: "Grenoble", raised: "€80M", note: "MicroLED displays; first product samples shipping to Tier-1 customers.", tier: "FT 120", initial: "A", color: "#114563" },
  { name: "Diabeloop", sector: "MedTech", city: "Grenoble", raised: "€80M", note: "AI-driven insulin delivery; FDA breakthrough designation received.", tier: "FT 120", initial: "D", color: "#503863" },
  { name: "Lifen", sector: "HealthTech", city: "Paris", raised: "€55M", note: "Health-data interoperability; ENS-compliant exchange across 2,500 facilities.", tier: "FT 120", initial: "L", color: "#503863" },
  { name: "Cardiologs", sector: "MedTech", city: "Paris", raised: "€30M", note: "ECG analysis suite; reclassified post-Philips spin-back.", tier: "FT 120", initial: "C", color: "#503863" },
  { name: "Verteego", sector: "SaaS", city: "Paris", raised: "€10M", note: "Prescriptive analytics for retail; deployment at Carrefour-scale.", tier: "FT 120", initial: "V", color: "#3c6840" },
  { name: "Kuna AI", sector: "Artificial Intelligence", city: "Paris", raised: "€8M", note: "Multi-agent industrial QA; pilot at three Stellantis sites.", tier: "FT 120", initial: "K", color: "#114563" },
  { name: "Naco Travel", sector: "TravelTech", city: "Paris", raised: "€16M", note: "Corporate travel platform; CMA-validated reductions of 18%.", tier: "FT 120", initial: "N", color: "#3c6840" },
  { name: "Onestock", sector: "E-commerce", city: "Toulouse", raised: "€44M", note: "Order management for omnichannel retail; expansion to Spain & UK.", tier: "FT 120", initial: "O", color: "#3c6840" },
  { name: "Klima", sector: "ClimateTech", city: "Paris", raised: "€12M", note: "Climate accounting for SMBs; 4,000 mid-market customers signed.", tier: "FT 120", initial: "K", color: "#3c6840" },
  { name: "Carbon Maps", sector: "FoodTech", city: "Paris", raised: "€20M", note: "Carbon footprint mapping in food supply chains.", tier: "FT 120", initial: "C", color: "#3c6840" },
  { name: "Atmen", sector: "DeepTech", city: "Paris", raised: "€8M", note: "Sovereign clean-hydrogen certification platform.", tier: "FT 120", initial: "A", color: "#114563" },
  { name: "Ÿnsect", sector: "AgriTech", city: "Évry", raised: "€430M", note: "Insect protein at industrial scale; reclassified following restructuring.", tier: "FT 120", initial: "Ÿ", color: "#3c6840" },
  { name: "Toucan Toco", sector: "SaaS", city: "Paris", raised: "€31M", note: "Embedded analytics; 600 enterprise dashboards in production.", tier: "FT 120", initial: "T", color: "#3c6840" },
  { name: "Believe Direct", sector: "Media", city: "Paris", raised: "€18M", note: "Spin-off of Believe; artist-direct distribution.", tier: "FT 120", initial: "B", color: "#503863" },
  { name: "Cohabs", sector: "PropTech", city: "Paris", raised: "€30M", note: "Co-living operator; 1,400 rooms across Paris, Lyon, Brussels.", tier: "FT 120", initial: "C", color: "#3c6840" },
  { name: "Stoik", sector: "InsurTech", city: "Paris", raised: "€25M", note: "Cyber insurance for European SMBs; 2,000 policies bound.", tier: "FT 120", initial: "S", color: "#963d3d" },
  { name: "Defacto", sector: "FinTech", city: "Paris", raised: "€18M", note: "Embedded SME financing API; €1B disbursed YTD.", tier: "FT 120", initial: "D", color: "#503863" },
  { name: "Gourmey", sector: "FoodTech", city: "Paris", raised: "€48M", note: "Cultivated foie gras; first regulatory approval in Switzerland.", tier: "FT 120", initial: "G", color: "#3c6840" },
  { name: "Innovafeed Aqua", sector: "AgriTech", city: "Nesle", raised: "€20M", note: "Spin-off targeting aquaculture proteins.", tier: "FT 120", initial: "I", color: "#3c6840" },
  { name: "Lemon Way", sector: "FinTech", city: "Paris", raised: "€30M", note: "Marketplace payments; reclassified after recovery year.", tier: "FT 120", initial: "L", color: "#503863" },
  { name: "Ostrum AI", sector: "Artificial Intelligence", city: "Paris", raised: "€14M", note: "Document understanding for European banks; LCL deployment underway.", tier: "FT 120", initial: "O", color: "#114563" },
  { name: "Vianova", sector: "Mobility", city: "Paris", raised: "€8M", note: "Mobility data infrastructure; deployed in 50+ European cities.", tier: "FT 120", initial: "V", color: "#3c6840" },
  { name: "Carbonable", sector: "ClimateTech", city: "Paris", raised: "€6M", note: "Tokenized carbon registry; Banque de France pilot complete.", tier: "FT 120", initial: "C", color: "#3c6840" },
  { name: "Akimbo", sector: "FinTech", city: "Paris", raised: "€11M", note: "Equity-management for startups; 800 companies onboarded.", tier: "FT 120", initial: "A", color: "#503863" },
  { name: "Holistik", sector: "HealthTech", city: "Paris", raised: "€9M", note: "Women's hormonal health platform; 300K users.", tier: "FT 120", initial: "H", color: "#503863" },
];

export const PROMOTIONS: Promotion[] = [
  { name: "Akeneo", from: "FT 120", to: "Next 40", sector: "SaaS", city: "Nantes", raised: "€135M", note: "Product information management; first French SaaS unicorn from Nantes." },
  { name: "Aqemia", from: "FT 120", to: "Next 40", sector: "BioTech", city: "Paris", raised: "€60M", note: "Quantum-physics drug discovery; Pfizer multi-target deal expanded." },
  { name: "Pasqal", from: "FT 120", to: "Next 40", sector: "DeepTech", city: "Palaiseau", raised: "€140M", note: "Neutral-atom quantum computers; 1000-qubit machine delivered to GENCI." },
  { name: "Swan", from: "FT 120", to: "Next 40", sector: "FinTech", city: "Paris", raised: "€58M", note: "Embedded banking infrastructure; profitable, expanding across 6 EU markets." },
  { name: "Greenly", from: "FT 120", to: "Next 40", sector: "ClimateTech", city: "Paris", raised: "€67M", note: "Carbon accounting; CSRD wave drove 3× revenue in FY25." },
  { name: "Filigran", from: "FT 120", to: "Next 40", sector: "Cybersecurity", city: "Paris", raised: "€58M", note: "Open-source threat intelligence; OpenCTI deployed across 4 ministries." },
  { name: "Wandercraft", from: "FT 120", to: "Next 40", sector: "DeepTech", city: "Paris", raised: "€90M", note: "Robotic exoskeletons; first CE-marked self-balancing wheelchair in Europe." },
];

export const EXITS: Exit[] = [
  { name: "Mirakl", reason: "Pre-IPO listing track", from: "Next 40", since: 2020, sector: "SaaS" },
  { name: "Doctolib", reason: "Listed on Euronext, May 2025", from: "Next 40", since: 2020, sector: "HealthTech" },
  { name: "Voodoo", reason: "Strategic divestiture", from: "Next 40", since: 2020, sector: "Mobile / Gaming" },
  { name: "Worldia", reason: "Acquired by TUI Group", from: "Next 40", since: 2020, sector: "TravelTech" },
  { name: "Equativ", reason: "Merged with Sharethrough Inc.", from: "Next 40", since: 2020, sector: "AdTech" },
  { name: "Brut", reason: "Revenue threshold not met", from: "FT 120", since: 2020, sector: "Media" },
  { name: "Yubo", reason: "Acquired", from: "FT 120", since: 2024, sector: "Social" },
  { name: "Madbox", reason: "Restructured under Voodoo", from: "FT 120", since: 2021, sector: "Gaming" },
  { name: "Driiveme", reason: "Outside qualifying criteria", from: "FT 120", since: 2021, sector: "Mobility" },
  { name: "Le Collectionist", reason: "Acquired by Marriott", from: "FT 120", since: 2022, sector: "TravelTech" },
  { name: "Pixmania", reason: "Cessation of activity", from: "FT 120", since: 2025, sector: "E-commerce" },
  { name: "Locala", reason: "Outside qualifying criteria", from: "FT 120", since: 2025, sector: "AdTech" },
];

export const SECTORS: Sector[] = [
  { sector: "Artificial Intelligence", count: 22, pct: 18.3, delta: +6 },
  { sector: "FinTech", count: 18, pct: 15.0, delta: -1 },
  { sector: "SaaS", count: 14, pct: 11.7, delta: 0 },
  { sector: "ClimateTech", count: 13, pct: 10.8, delta: +5 },
  { sector: "HealthTech / MedTech", count: 12, pct: 10.0, delta: +1 },
  { sector: "Cybersecurity", count: 10, pct: 8.3, delta: +3 },
  { sector: "DeepTech", count: 9, pct: 7.5, delta: +2 },
  { sector: "Mobility", count: 7, pct: 5.8, delta: -2 },
  { sector: "E-commerce / Retail", count: 6, pct: 5.0, delta: -3 },
  { sector: "BioTech", count: 5, pct: 4.2, delta: 0 },
  { sector: "SpaceTech", count: 3, pct: 2.5, delta: +1 },
  { sector: "Other", count: 1, pct: 0.8, delta: -2 },
];

export const REGIONS: Region[] = [
  { city: "Paris", region: "Île-de-France", count: 78, x: 488, y: 188, delta: -2 },
  { city: "Lyon", region: "Auvergne-Rhône-A.", count: 9, x: 565, y: 333, delta: +1 },
  { city: "Toulouse", region: "Occitanie", count: 6, x: 410, y: 470, delta: 0 },
  { city: "Grenoble", region: "Auvergne-Rhône-A.", count: 5, x: 595, y: 360, delta: +1 },
  { city: "Nantes", region: "Pays de la Loire", count: 4, x: 248, y: 300, delta: 0 },
  { city: "Bordeaux", region: "N. Aquitaine", count: 4, x: 295, y: 405, delta: +1 },
  { city: "Marseille", region: "Sud / PACA", count: 4, x: 595, y: 480, delta: 0 },
  { city: "Lille", region: "Hauts-de-France", count: 3, x: 490, y: 100, delta: 0 },
  { city: "Rennes", region: "Bretagne", count: 3, x: 230, y: 220, delta: 0 },
  { city: "Strasbourg", region: "Grand Est", count: 2, x: 660, y: 195, delta: 0 },
  { city: "Montpellier", region: "Occitanie", count: 1, x: 478, y: 488, delta: -1 },
  { city: "Nice", region: "Sud / PACA", count: 1, x: 692, y: 460, delta: 0 },
];

export const HEADLINE: Headline = {
  total: 120,
  next40: 40,
  ft120: 80,
  new: 40,
  promoted: 7,
  demoted: 2,
  retained: 71,
  exited: 40,
  unicorns: 28,
  totalRaised: "€34.2B",
  womenFounders: 23,
  paris: 78,
};

// Programme totals across all six cohorts (2020 → 2025).
export const ALL_TIME = {
  totalTracked: 312,
  alumni: 152,
  active: 120,
  ipos: 4,
  acquisitions: 18,
  graduations: 9,
  shutdowns: 6,
};

// Movements ledger — the 2024 → 2025 inter-cohort changes (24 of 89 shown).
export const LEDGER: LedgerRow[] = [
  { sym: "↑", name: "Akeneo", from: "FT 120", to: "Next 40", color: "#114563" },
  { sym: "↑", name: "Aqemia", from: "FT 120", to: "Next 40", color: "#114563" },
  { sym: "↑", name: "Pasqal", from: "FT 120", to: "Next 40", color: "#114563" },
  { sym: "↑", name: "Swan", from: "FT 120", to: "Next 40", color: "#114563" },
  { sym: "↑", name: "Greenly", from: "FT 120", to: "Next 40", color: "#114563" },
  { sym: "↑", name: "Filigran", from: "FT 120", to: "Next 40", color: "#114563" },
  { sym: "↑", name: "Wandercraft", from: "FT 120", to: "Next 40", color: "#114563" },
  { sym: "↓", name: "Shift Technology", from: "Next 40", to: "FT 120", color: "#b8862c" },
  { sym: "↓", name: "Worldia", from: "Next 40", to: "FT 120", color: "#b8862c" },
  { sym: "+", name: "Dust", from: "—", to: "Next 40", color: "#3c6840" },
  { sym: "+", name: "Owkin", from: "—", to: "Next 40", color: "#3c6840" },
  { sym: "+", name: "Photoroom", from: "—", to: "Next 40", color: "#3c6840" },
  { sym: "+", name: "Sweep", from: "FT 120", to: "Next 40", color: "#3c6840" },
  { sym: "+", name: "Linkup", from: "—", to: "FT 120", color: "#3c6840" },
  { sym: "+", name: "LightOn", from: "—", to: "FT 120", color: "#3c6840" },
  { sym: "+", name: "Cosmian", from: "—", to: "FT 120", color: "#3c6840" },
  { sym: "+", name: "Tehtris", from: "—", to: "FT 120", color: "#3c6840" },
  { sym: "+", name: "HarfangLab", from: "—", to: "FT 120", color: "#3c6840" },
  { sym: "−", name: "Mirakl", from: "Next 40", to: "Exit", color: "#963d3d" },
  { sym: "−", name: "Doctolib", from: "Next 40", to: "IPO", color: "#963d3d" },
  { sym: "−", name: "Voodoo", from: "Next 40", to: "Exit", color: "#963d3d" },
  { sym: "−", name: "Equativ", from: "Next 40", to: "M&A", color: "#963d3d" },
  { sym: "−", name: "Brut", from: "FT 120", to: "Exit", color: "#963d3d" },
  { sym: "−", name: "Yubo", from: "FT 120", to: "M&A", color: "#963d3d" },
];

// The tape — active cohort sampling shown in the bottom ticker.
export const TAPE_NAMES: string[] = [
  ...ARRIVALS.slice(0, 14).map((a) => a.name),
  "Alan", "Doctolib", "Mistral AI", "Qonto", "Ledger", "Back Market", "Contentsquare",
  "Brevo", "Pennylane", "Pigment", "Verkor", "Innovafeed", "Alice & Bob", "Electra",
  "Chapsvision", "Spendesk", "Mirakl", "Akeneo", "Aqemia", "Pasqal", "Swan", "Greenly",
  "Filigran", "Wandercraft", "BlaBlaCar", "EcoVadis", "ekWateur", "Vestiaire Collective",
  "Malt", "PayFit", "Exotec", "Flying Whales", "Voodoo",
];
