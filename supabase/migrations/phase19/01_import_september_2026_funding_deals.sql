-- =============================================================================
-- September 2026 Funding Deals Import
-- =============================================================================
-- Imports a batch of 9 funding deals reported around September 2026 (individual
-- announcement dates range June–September 2026 and are stored per round).
-- Creates/updates organizations, funding_rounds, investors, organization_sectors,
-- people (founders), organization_people links, cities, and city links.
-- Amounts stored in millions (DB convention).
--
-- New organizations (4): Lupin Dental, Huscarl, Viraj Aero, Swiftask.
-- Existing organizations, new round attached (3): Lys Therapeutics, ColibrITD,
--   TheraSonic (each already had an earlier round; the new rounds are distinct).
-- Rebrands handled in Step 0b (2):
--   * Absolut Sensing  -> Sensing Atmospheric Intelligence (confirmed rebrand).
--   * Space Quarters   -> ArcSpace (same SIREN 918767047, same founder Guillaume
--     Mohara, same in-orbit metal-assembly business; confirmed as a rename).
--   For both, the existing org's name, slug, website and description are updated
--   and the new round is attached to that SAME org (no duplicate is created).
--
-- Notes:
--   * Huscarl raised in USD ($5.6M); amount_eur is the converted estimate.
--   * Sensing Atmospheric Intelligence's raise is undisclosed (amount_eur NULL);
--     it is described as a capital increase backing a €12M investment plan.
--   * Lys Therapeutics' €13M is the new capital reported alongside its
--     >€25M cumulative-since-founding milestone (see round notes).
--   * TheraSonic's round is a Capital Cell crowdfunding campaign (stored as seed).
--   * Lupin Dental's legal entity is DIGICUTO; Swiftask's is SWIFTASK TECHNOLOGY.
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "unaccent";

ALTER TABLE organizations
  ADD COLUMN IF NOT EXISTS secondary_city_id UUID REFERENCES cities(id) ON DELETE SET NULL;

-- =============================================================================
-- Step 0: Ensure cities exist (idempotent -- all already present)
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      { "name": "Montpellier", "country": "France" },
      { "name": "Lyon", "country": "France" },
      { "name": "Caen", "country": "France" },
      { "name": "Paris", "country": "France" },
      { "name": "Toulouse", "country": "France" },
      { "name": "Nantes", "country": "France" }
]$json$
  ) AS (name TEXT, country TEXT)
)
INSERT INTO cities (id, name, slug, country, created_at, updated_at)
SELECT
  uuid_generate_v4(), s.name,
  lower(regexp_replace(regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g')),
  s.country, NOW(), NOW()
FROM source s
ON CONFLICT (slug) DO NOTHING;

-- =============================================================================
-- Step 0b: Apply the two rebrands to the EXISTING organizations (in place)
-- =============================================================================
UPDATE organizations SET
  name = 'Sensing Atmospheric Intelligence',
  slug = 'sensing-atmospheric-intelligence',
  website = 'https://sensing-ai.eu/',
  description = 'Toulouse-based satellite operator providing atmospheric-intelligence data, initially focused on equipment-level detection and quantification of industrial methane emissions. Its GESat satellites combine hyperspectral sensing with physics-guided AI. Formerly Absolut Sensing.',
  updated_at = NOW()
WHERE slug = 'absolut-sensing';

UPDATE organizations SET
  name = 'ArcSpace',
  slug = 'arcspace',
  website = 'https://arc-space.com/',
  description = 'Developer of a compact electron-beam system for welding and cutting metal in orbit, initially targeting satellite servicing and repair before expanding to orbital manufacturing and space infrastructure. Formerly Space Quarters.',
  updated_at = NOW()
WHERE slug = 'space-quarters';

-- =============================================================================
-- Step 0c: Ensure new sectors exist (idempotent)
-- =============================================================================
INSERT INTO sectors (id, name, slug, created_at, updated_at)
VALUES
  (uuid_generate_v4(), 'Aviation', 'aviation', NOW(), NOW()),
  (uuid_generate_v4(), 'Propulsion', 'propulsion', NOW(), NOW()),
  (uuid_generate_v4(), 'NeuroTech', 'neurotech', NOW(), NOW())
ON CONFLICT (slug) DO NOTHING;

-- =============================================================================
-- Step 1: Create organizations (new + existing non-rebrand; existing preserved)
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      {
            "name": "Lupin Dental",
            "website": "https://lupindental.com/",
            "description": "Lupin Dental develops supervised robotic systems for minimally invasive dental procedures. Its Lupin Robotic System combines treatment-planning software with a robotic workstation that automates tooth preparation for aesthetic veneers, aiming to improve precision, clinical workflows, and patient outcomes."
      },
      {
            "name": "Lys Therapeutics",
            "website": "https://lys-tx.com/",
            "description": "Advanced preclinical biotech developing LYS241, a humanized monoclonal antibody designed to block the tPA-NMDAr pathway in neurodegenerative and neurovascular diseases, including Parkinson's disease, synucleinopathies and ischemic stroke."
      },
      {
            "name": "Huscarl",
            "website": "http://huscarl.io/",
            "description": "Huscarl develops an AI-powered actuarial platform for corporations, self-insured companies, insurance captives, and risk retention groups. Its autonomous AI actuary ingests unstructured data and automates workflows, including risk modeling, pricing, reserving, and capital analysis, with studies reviewed and signed by credentialed human actuaries."
      },
      {
            "name": "ColibriTD",
            "website": "https://www.colibritd.com/",
            "description": "ColibriTD develops a hardware-agnostic quantum-powered multiphysics simulation platform built around H-DES, its proprietary hybrid quantum-classical algorithm for solving partial differential equations. The company targets computationally intensive applications across defense, aerospace, semiconductors, energy, automotive, climate science, and quantitative finance."
      },
      {
            "name": "Viraj Aero",
            "website": "https://virajaero.com/",
            "description": "Toulouse-based startup developing an onboard steam-injection turbine system that recovers water from aircraft exhaust and reinjects it into the engine, aiming to reduce fuel use, CO2, NOx emissions and non-CO2 climate effects."
      },
      {
            "name": "Swiftask",
            "website": "https://swiftask.ai/",
            "description": "Enterprise software platform for building, deploying and governing AI agents across business workflows. Hosted in France, it offers access to more than 80 AI models and aims to provide a vendor-neutral control layer for enterprise AI use."
      },
      {
            "name": "TheraSonic",
            "website": "https://www.therasonic.fr/",
            "description": "CEA/CNRS spin-off developing a robot-guided focused-ultrasound device that temporarily and non-invasively opens the blood-brain barrier to improve delivery of drugs to targeted brain regions."
      }
]$json$
  ) AS (name TEXT, website TEXT, description TEXT)
)
INSERT INTO organizations (
  id, name, slug, organization_type, description, website, status, country,
  legacy_source, created_at, updated_at
)
SELECT
  uuid_generate_v4(), s.name,
  lower(regexp_replace(regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g')),
  'startup'::organization_type, s.description, s.website, 'active'::organization_status, 'France',
  'funding_deals_september_2026', NOW(), NOW()
FROM source s
ON CONFLICT (slug) DO UPDATE SET
  website = COALESCE(organizations.website, EXCLUDED.website),
  description = COALESCE(organizations.description, EXCLUDED.description),
  updated_at = NOW();

-- =============================================================================
-- Step 1b: Link organizations to primary and secondary cities
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      { "org_name": "Lupin Dental", "city": "Montpellier", "secondary_city": null },
      { "org_name": "Lys Therapeutics", "city": "Lyon", "secondary_city": "Caen" },
      { "org_name": "Huscarl", "city": "Paris", "secondary_city": null },
      { "org_name": "ColibriTD", "city": "Paris", "secondary_city": null },
      { "org_name": "Viraj Aero", "city": "Toulouse", "secondary_city": null },
      { "org_name": "Swiftask", "city": "Nantes", "secondary_city": null },
      { "org_name": "TheraSonic", "city": "Paris", "secondary_city": null },
      { "org_name": "Sensing Atmospheric Intelligence", "city": "Toulouse", "secondary_city": null },
      { "org_name": "ArcSpace", "city": "Toulouse", "secondary_city": null }
]$json$
  ) AS (org_name TEXT, city TEXT, secondary_city TEXT)
)
UPDATE organizations o SET
  city_id = COALESCE(o.city_id, c1.id),
  secondary_city_id = COALESCE(o.secondary_city_id, c2.id),
  updated_at = NOW()
FROM source s
LEFT JOIN cities c1 ON c1.slug = lower(regexp_replace(regexp_replace(unaccent(s.city), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g'))
LEFT JOIN cities c2 ON c2.slug = lower(regexp_replace(regexp_replace(unaccent(s.secondary_city), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g'))
WHERE o.slug = lower(regexp_replace(regexp_replace(unaccent(s.org_name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g'));

-- =============================================================================
-- Step 2: Create funding rounds (9)
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      {
            "name": "Lupin Dental", "stage": "series_a", "amount_eur": 15.0,
            "currency_original": "EUR", "amount_original": 15000000, "announced_date": "2026-08-28",
            "notes": "€15M Series A led by Fynveur (€10M), with existing shareholders, private investors and additional loan financing from Bpifrance. Flagship Lupin Robotic System automates minimally invasive tooth preparation for veneers. Received UKCA certification June 2026 (commercialization in Great Britain); earlier clearance in India; not yet approved in the EU or US. Legal entity DIGICUTO. Source: EU-Startups."
      },
      {
            "name": "Lys Therapeutics", "stage": "growth", "amount_eur": 13.0,
            "currency_original": "EUR", "amount_original": 13000000, "announced_date": "2026-06-22",
            "notes": "€13M reported as new capital alongside a milestone of >€25M raised cumulatively since the 2021 founding (equity, non-dilutive public funding and foundation support; ~€12M previously disclosed across seven rounds incl. a €3M seed, Bpifrance/France 2030 grants and Michael J. Fox Foundation awards). Funds regulatory studies, industrial manufacturing and a biomarker-rich Phase 1a/1b trial for LYS241. Investors: Normandie Participation, TCD Capital, FIDAT Ventures, ZCUBE. Source: PR."
      },
      {
            "name": "Huscarl", "stage": "seed", "amount_eur": 4.82,
            "currency_original": "USD", "amount_original": 5600000, "announced_date": "2026-09-01",
            "notes": "$5.6M (~€4.82M) seed led by FRST to accelerate its AI actuarial platform and US expansion. Y Combinator-backed; automates modeling, pricing, reserving and capital analysis with credentialed human actuaries signing studies. Founded by ex-Descartes Underwriting Alexandre Musy and Paulien Jeunesse. Investors: FRST, Y Combinator, MS&AD Ventures, Business Angels. Source: LinkedIn, Coverager."
      },
      {
            "name": "ColibriTD", "stage": "seed", "amount_eur": 4.0,
            "currency_original": "EUR", "amount_original": 4000000, "announced_date": "2026-08-27",
            "notes": "€4M seed led by Earlybird Venture Capital (which also backed the €1M pre-Seed), with SymbiaVC and Medin VC, to advance its H-DES quantum simulation R&D and expand internationally. Founded 2019; seven co-construction projects across six sectors incl. Thales, ESA and BMW. Attached to the existing 'ColibrITD' organization. Source: EU-Startups, La Revue Digitale."
      },
      {
            "name": "Viraj Aero", "stage": "seed", "amount_eur": 4.5,
            "currency_original": "EUR", "amount_original": 4500000, "announced_date": "2026-08-31",
            "notes": "€4.5M seed to finance flight testing of its Ailefroide demonstrator (2027) and grow its Toulouse engineering team. Onboard steam-injection turbine recovers water from exhaust to cut fuel, CO2, NOx and non-CO2 effects; targets a 2029 commercial launch of its EYJA system for light aviation, then regional aircraft. Investors: IRDI Capital Investissement, Climate Founders, OCSEED, ARTS Aero, Business Angels, Bpifrance. Source: Les Echos, La Tribune, PR."
      },
      {
            "name": "ArcSpace", "stage": "seed", "amount_eur": 2.0,
            "currency_original": "EUR", "amount_original": 2000000, "announced_date": "2026-08-25",
            "notes": "€2M+ seed to qualify its flight hardware and run an autonomous in-orbit demonstration in 2027. Compact electron-beam system for in-orbit welding/cutting, targeting satellite servicing and repair. Company rebranded from Space Quarters (SIREN 918767047); round attached to that same organization. Investors: DEPO Ventures, SCE Freiraum Ventures, IRDI Capital Investissement, Business Angels. Source: The French Tech Journal."
      },
      {
            "name": "Swiftask", "stage": "seed", "amount_eur": 1.55,
            "currency_original": "EUR", "amount_original": 1550000, "announced_date": "2026-09-02",
            "notes": "€1.55M first round (closed August 2026) to expand direct sales and its distributor network in France, Europe and Africa. Enterprise platform for building/governing AI agents, hosted in France with access to 80+ models; says 100+ customers and 14,000 active AI agents. Legal entity SWIFTASK TECHNOLOGY. Source: FinYear."
      },
      {
            "name": "TheraSonic", "stage": "seed", "amount_eur": 1.52,
            "currency_original": "EUR", "amount_original": 1523874, "announced_date": "2026-08-09",
            "notes": "€1,523,874 raised via a Capital Cell crowdfunding campaign (closed July 31, 2026), surpassing a €1.2M target at a €5.8M pre-money valuation. CEA/CNRS spin-off; robot-guided focused ultrasound to temporarily open the blood-brain barrier. Funds industrialization and the regulatory path following a first-in-human programme at Gustave Roussy. Source: Capital Cell."
      },
      {
            "name": "Sensing Atmospheric Intelligence", "stage": "growth", "amount_eur": null,
            "currency_original": null, "amount_original": null, "announced_date": "2026-06-18",
            "notes": "Undisclosed capital increase financing a €12M investment plan. Company rebranded from Absolut Sensing and appointed Nicolas Fabre as managing director and partner. Will develop and launch its GEN2 hyperspectral satellite to measure methane emissions below 50 kg/hour, with launch planned for late 2027 / early 2028. Round attached to the existing (renamed) organization. Source: Company announcement."
      }
]$json$
  ) AS (name TEXT, stage TEXT, amount_eur NUMERIC, currency_original TEXT,
        amount_original NUMERIC, announced_date TEXT, notes TEXT)
)
INSERT INTO funding_rounds (
  id, organization_id, stage, amount_eur, currency_original, amount_original,
  announced_date, is_estimated, is_verified, source_name, notes, created_at
)
SELECT
  uuid_generate_v4(), o.id, s.stage::funding_stage, s.amount_eur, s.currency_original, s.amount_original,
  s.announced_date::DATE,
  CASE WHEN s.currency_original IS NOT NULL AND s.currency_original != 'EUR' AND s.amount_eur IS NOT NULL THEN TRUE ELSE FALSE END,
  FALSE, 'funding_deals_september_2026', s.notes, NOW()
FROM source s
JOIN organizations o ON o.slug = lower(regexp_replace(regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g'));

-- =============================================================================
-- Step 3a: Create investor organizations (idempotent)
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      { "name": "Fynveur" }, { "name": "Bpifrance" }, { "name": "Normandie Participation" },
      { "name": "TCD Capital" }, { "name": "FIDAT Ventures" }, { "name": "ZCUBE" },
      { "name": "FRST" }, { "name": "Y Combinator" }, { "name": "MS&AD Ventures" },
      { "name": "Business Angels" }, { "name": "Earlybird Venture Capital" }, { "name": "SymbiaVC" },
      { "name": "Medin VC" }, { "name": "IRDI Capital Investissement" }, { "name": "Climate Founders" },
      { "name": "OCSEED" }, { "name": "ARTS Aero" }, { "name": "DEPO Ventures" },
      { "name": "SCE Freiraum Ventures" }, { "name": "Capital Cell" }
]$json$
  ) AS (name TEXT)
)
INSERT INTO organizations (
  id, name, slug, organization_type, status, country, legacy_source, created_at, updated_at
)
SELECT
  uuid_generate_v4(), s.name,
  lower(regexp_replace(regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g')),
  'investor'::organization_type, 'active'::organization_status, 'France',
  'funding_deals_september_2026', NOW(), NOW()
FROM source s
ON CONFLICT (slug) DO NOTHING;

-- =============================================================================
-- Step 3b: Create funding round investors
-- (Sensing has no disclosed investors; joined on org + source, one round each)
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      { "org_name": "Lupin Dental", "investor_name": "Fynveur", "is_lead": true },
      { "org_name": "Lupin Dental", "investor_name": "Bpifrance", "is_lead": false },
      { "org_name": "Lys Therapeutics", "investor_name": "Normandie Participation", "is_lead": false },
      { "org_name": "Lys Therapeutics", "investor_name": "TCD Capital", "is_lead": false },
      { "org_name": "Lys Therapeutics", "investor_name": "FIDAT Ventures", "is_lead": false },
      { "org_name": "Lys Therapeutics", "investor_name": "ZCUBE", "is_lead": false },
      { "org_name": "Huscarl", "investor_name": "FRST", "is_lead": true },
      { "org_name": "Huscarl", "investor_name": "Y Combinator", "is_lead": false },
      { "org_name": "Huscarl", "investor_name": "MS&AD Ventures", "is_lead": false },
      { "org_name": "Huscarl", "investor_name": "Business Angels", "is_lead": false },
      { "org_name": "ColibriTD", "investor_name": "Earlybird Venture Capital", "is_lead": true },
      { "org_name": "ColibriTD", "investor_name": "SymbiaVC", "is_lead": false },
      { "org_name": "ColibriTD", "investor_name": "Medin VC", "is_lead": false },
      { "org_name": "Viraj Aero", "investor_name": "IRDI Capital Investissement", "is_lead": false },
      { "org_name": "Viraj Aero", "investor_name": "Climate Founders", "is_lead": false },
      { "org_name": "Viraj Aero", "investor_name": "OCSEED", "is_lead": false },
      { "org_name": "Viraj Aero", "investor_name": "ARTS Aero", "is_lead": false },
      { "org_name": "Viraj Aero", "investor_name": "Business Angels", "is_lead": false },
      { "org_name": "Viraj Aero", "investor_name": "Bpifrance", "is_lead": false },
      { "org_name": "ArcSpace", "investor_name": "DEPO Ventures", "is_lead": false },
      { "org_name": "ArcSpace", "investor_name": "SCE Freiraum Ventures", "is_lead": false },
      { "org_name": "ArcSpace", "investor_name": "IRDI Capital Investissement", "is_lead": false },
      { "org_name": "ArcSpace", "investor_name": "Business Angels", "is_lead": false },
      { "org_name": "Swiftask", "investor_name": "Business Angels", "is_lead": false },
      { "org_name": "TheraSonic", "investor_name": "Capital Cell", "is_lead": false }
]$json$
  ) AS (org_name TEXT, investor_name TEXT, is_lead BOOLEAN)
)
INSERT INTO funding_round_investors (
  id, funding_round_id, investor_id, is_lead, investor_name, created_at
)
SELECT
  uuid_generate_v4(), fr.id, inv_org.id, s.is_lead, s.investor_name, NOW()
FROM source s
JOIN organizations o ON o.slug = lower(regexp_replace(regexp_replace(unaccent(s.org_name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g'))
JOIN organizations inv_org ON inv_org.slug = lower(regexp_replace(regexp_replace(unaccent(s.investor_name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g'))
-- Join on org + source only: each org has exactly one September 2026 round, and
-- amount_eur is stored at 2-decimal scale, so matching on amount could drop links.
JOIN funding_rounds fr ON fr.organization_id = o.id
  AND fr.source_name = 'funding_deals_september_2026'
WHERE NOT EXISTS (
  SELECT 1 FROM funding_round_investors x WHERE x.funding_round_id = fr.id AND x.investor_id = inv_org.id
);

-- =============================================================================
-- Step 4: Link organizations to sectors
-- =============================================================================
-- Step 4a: insert all org-sector links as non-primary (idempotent)
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      { "org": "lupin-dental", "sec": "medtech" },
      { "org": "lupin-dental", "sec": "robotics" },
      { "org": "lys-therapeutics", "sec": "biotech" },
      { "org": "lys-therapeutics", "sec": "healthtech" },
      { "org": "huscarl", "sec": "insurtech" },
      { "org": "huscarl", "sec": "artificial-intelligence" },
      { "org": "huscarl", "sec": "saas" },
      { "org": "colibritd", "sec": "quantum-computing" },
      { "org": "colibritd", "sec": "deeptech" },
      { "org": "viraj-aero", "sec": "climatetech" },
      { "org": "viraj-aero", "sec": "spacetech-aerospace" },
      { "org": "viraj-aero", "sec": "aviation" },
      { "org": "viraj-aero", "sec": "propulsion" },
      { "org": "swiftask", "sec": "artificial-intelligence" },
      { "org": "swiftask", "sec": "saas" },
      { "org": "therasonic", "sec": "medtech" },
      { "org": "therasonic", "sec": "healthtech" },
      { "org": "therasonic", "sec": "neurotech" },
      { "org": "therasonic", "sec": "robotics" },
      { "org": "sensing-atmospheric-intelligence", "sec": "spacetech-aerospace" },
      { "org": "sensing-atmospheric-intelligence", "sec": "climatetech" },
      { "org": "arcspace", "sec": "spacetech-aerospace" },
      { "org": "arcspace", "sec": "deeptech" }
]$json$
  ) AS (org TEXT, sec TEXT)
)
INSERT INTO organization_sectors (id, organization_id, sector_id, is_primary, created_at)
SELECT uuid_generate_v4(), o.id, sec.id, FALSE, NOW()
FROM source s
JOIN organizations o ON o.slug = s.org
JOIN sectors sec ON sec.slug = s.sec
ON CONFLICT (organization_id, sector_id) DO NOTHING;

-- Step 4b: promote the primary sector only for orgs that do not already have one
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      { "org": "lupin-dental", "sec": "medtech" },
      { "org": "lys-therapeutics", "sec": "biotech" },
      { "org": "huscarl", "sec": "insurtech" },
      { "org": "colibritd", "sec": "quantum-computing" },
      { "org": "viraj-aero", "sec": "climatetech" },
      { "org": "swiftask", "sec": "artificial-intelligence" },
      { "org": "therasonic", "sec": "medtech" },
      { "org": "sensing-atmospheric-intelligence", "sec": "spacetech-aerospace" },
      { "org": "arcspace", "sec": "spacetech-aerospace" }
]$json$
  ) AS (org TEXT, sec TEXT)
)
UPDATE organization_sectors os SET is_primary = TRUE
FROM source s
JOIN organizations o ON o.slug = s.org
JOIN sectors sec ON sec.slug = s.sec
WHERE os.organization_id = o.id AND os.sector_id = sec.id
  AND NOT EXISTS (
    SELECT 1 FROM organization_sectors x WHERE x.organization_id = o.id AND x.is_primary = TRUE
  );

-- =============================================================================
-- Step 5: Create people records for founders (titles stripped)
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      { "full_name": "Galip Gürel", "first_name": "Galip", "last_name": "Gürel" },
      { "full_name": "Stefen Koubi", "first_name": "Stefen", "last_name": "Koubi" },
      { "full_name": "Manuel Blanc", "first_name": "Manuel", "last_name": "Blanc" },
      { "full_name": "Philippe Dujardin", "first_name": "Philippe", "last_name": "Dujardin" },
      { "full_name": "Thibault Honegger", "first_name": "Thibault", "last_name": "Honegger" },
      { "full_name": "Alexandre Musy", "first_name": "Alexandre", "last_name": "Musy" },
      { "full_name": "Paulien Jeunesse", "first_name": "Paulien", "last_name": "Jeunesse" },
      { "full_name": "Laurent Guiraud", "first_name": "Laurent", "last_name": "Guiraud" },
      { "full_name": "Hacène Goudjil", "first_name": "Hacène", "last_name": "Goudjil" },
      { "full_name": "Mathilde Bouilloux", "first_name": "Mathilde", "last_name": "Bouilloux" },
      { "full_name": "Joseph Brisson", "first_name": "Joseph", "last_name": "Brisson" },
      { "full_name": "Guillaume Mohara", "first_name": "Guillaume", "last_name": "Mohara" },
      { "full_name": "Adam Abdin", "first_name": "Adam", "last_name": "Abdin" },
      { "full_name": "Stanislas Randriamilasoa", "first_name": "Stanislas", "last_name": "Randriamilasoa" },
      { "full_name": "Matthieu Lardillet", "first_name": "Matthieu", "last_name": "Lardillet" },
      { "full_name": "Gaël Brisson", "first_name": "Gaël", "last_name": "Brisson" },
      { "full_name": "Benoît Larrat", "first_name": "Benoît", "last_name": "Larrat" },
      { "full_name": "Anthony Novell", "first_name": "Anthony", "last_name": "Novell" },
      { "full_name": "Tristan Laurent", "first_name": "Tristan", "last_name": "Laurent" }
]$json$
  ) AS (full_name TEXT, first_name TEXT, last_name TEXT)
)
INSERT INTO people (
  id, full_name, slug, first_name, last_name, legacy_source, created_at
)
SELECT
  uuid_generate_v4(), s.full_name,
  lower(regexp_replace(regexp_replace(unaccent(s.full_name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g')),
  s.first_name, s.last_name, 'funding_deals_september_2026', NOW()
FROM source s
ON CONFLICT (slug) DO NOTHING;

-- =============================================================================
-- Step 6: Link founders to organizations
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      { "org_name": "Lupin Dental", "founder_name": "Galip Gürel" },
      { "org_name": "Lupin Dental", "founder_name": "Stefen Koubi" },
      { "org_name": "Lys Therapeutics", "founder_name": "Manuel Blanc" },
      { "org_name": "Lys Therapeutics", "founder_name": "Philippe Dujardin" },
      { "org_name": "Lys Therapeutics", "founder_name": "Thibault Honegger" },
      { "org_name": "Huscarl", "founder_name": "Alexandre Musy" },
      { "org_name": "Huscarl", "founder_name": "Paulien Jeunesse" },
      { "org_name": "ColibriTD", "founder_name": "Laurent Guiraud" },
      { "org_name": "ColibriTD", "founder_name": "Hacène Goudjil" },
      { "org_name": "Viraj Aero", "founder_name": "Mathilde Bouilloux" },
      { "org_name": "Viraj Aero", "founder_name": "Joseph Brisson" },
      { "org_name": "ArcSpace", "founder_name": "Guillaume Mohara" },
      { "org_name": "ArcSpace", "founder_name": "Adam Abdin" },
      { "org_name": "Swiftask", "founder_name": "Stanislas Randriamilasoa" },
      { "org_name": "Swiftask", "founder_name": "Matthieu Lardillet" },
      { "org_name": "Swiftask", "founder_name": "Gaël Brisson" },
      { "org_name": "TheraSonic", "founder_name": "Benoît Larrat" },
      { "org_name": "TheraSonic", "founder_name": "Anthony Novell" },
      { "org_name": "Sensing Atmospheric Intelligence", "founder_name": "Tristan Laurent" }
]$json$
  ) AS (org_name TEXT, founder_name TEXT)
)
INSERT INTO organization_people (
  id, organization_id, person_id, role, is_current, is_founder, created_at, updated_at
)
SELECT
  uuid_generate_v4(), o.id, p.id, 'Founder', TRUE, TRUE, NOW(), NOW()
FROM source s
JOIN organizations o ON o.slug = lower(regexp_replace(regexp_replace(unaccent(s.org_name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g'))
JOIN people p ON p.slug = lower(regexp_replace(regexp_replace(unaccent(s.founder_name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g'))
ON CONFLICT (organization_id, person_id, role) DO NOTHING;

-- =============================================================================
-- Step 7: Attach SIREN legal entities (French). Idempotent -- Lys, TheraSonic
-- and ArcSpace (ex-Space Quarters) already carry their SIREN and are skipped.
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      { "org": "lupin-dental", "legal_name": "DIGICUTO", "siren": "850067877" },
      { "org": "lys-therapeutics", "legal_name": "Lys Therapeutics", "siren": "895069904" },
      { "org": "huscarl", "legal_name": "HUSCARL", "siren": "992337022" },
      { "org": "colibritd", "legal_name": "COLIBRITD", "siren": "852155571" },
      { "org": "viraj-aero", "legal_name": "VIRAJ AERO", "siren": "985157080" },
      { "org": "arcspace", "legal_name": "ARCSPACE", "siren": "918767047" },
      { "org": "swiftask", "legal_name": "SWIFTASK TECHNOLOGY", "siren": "928363191" },
      { "org": "therasonic", "legal_name": "THERASONIC", "siren": "981781289" },
      { "org": "sensing-atmospheric-intelligence", "legal_name": "SENSING ATMOSPHERIC INTELLIGENCE", "siren": "903878171" }
]$json$
  ) AS (org TEXT, legal_name TEXT, siren TEXT)
)
INSERT INTO legal_entities (
  id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at
)
SELECT
  uuid_generate_v4(), o.id, s.legal_name, s.siren, 'France',
  NOT EXISTS (SELECT 1 FROM legal_entities le2 WHERE le2.organization_id = o.id),
  NOW(), NOW()
FROM source s
JOIN organizations o ON o.slug = s.org
WHERE NOT EXISTS (
  SELECT 1 FROM legal_entities le WHERE le.organization_id = o.id AND le.siren = s.siren
);

-- =============================================================================
-- Verification queries
-- =============================================================================
SELECT 'Funding Rounds' AS entity, COUNT(*) AS count
FROM funding_rounds WHERE source_name = 'funding_deals_september_2026'
UNION ALL
SELECT 'Investor Links', COUNT(*)
FROM funding_round_investors fri
JOIN funding_rounds fr ON fr.id = fri.funding_round_id
WHERE fr.source_name = 'funding_deals_september_2026'
UNION ALL
SELECT 'Founder People (new)', COUNT(*)
FROM people WHERE legacy_source = 'funding_deals_september_2026';
