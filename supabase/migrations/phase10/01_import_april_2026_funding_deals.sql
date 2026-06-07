-- =============================================================================
-- April 2026 Funding Deals Import
-- =============================================================================
-- Imports 2 funding deals from April 2026.
-- Creates organizations, funding_rounds, investors, organization_sectors,
-- people (founders), and organization_people links.
-- Amounts stored in millions (DB convention).
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "unaccent";

-- =============================================================================
-- Step 1: Create organizations (2 startups)
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      {
        "name": "Generare",
        "website": "https://generare.bio/",
        "description": "Generare is a French biotech startup leveraging AI and microbial genomics to discover new bioactive molecules for pharmaceuticals, agrochemicals, and cosmetics. Its platform combines machine learning with cloning and sequencing technologies to explore previously untapped microbial diversity, generating novel molecular data that can unlock new therapeutic pathways and targets. The company operates upstream in the drug discovery value chain, supplying both data and physical molecules to industry players.",
        "city": "Paris"
      },
      {
        "name": "Omniscient",
        "website": "https://www.omniscient.so/",
        "description": "Omniscient is a decision intelligence platform designed for executives and large enterprises, acting as a real-time control tower over their business environment. By aggregating data from over 100,000 sources\u2014including media, social networks, and web content\u2014the platform detects weak signals, reputational risks, and strategic opportunities. Built on multiple large language models, it enables users to interact in natural language, generate sector analyses, and monitor critical topics through customizable alerts.",
        "city": "Paris"
      }
    ]$json$
  ) AS (name TEXT, website TEXT, description TEXT, city TEXT)
)
INSERT INTO organizations (
  id, name, slug, organization_type, description, website, status, country,
  legacy_source, created_at, updated_at
)
SELECT
  uuid_generate_v4(),
  s.name,
  lower(regexp_replace(
    regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\s-]', '', 'g'),
    '\s+', '-', 'g'
  )),
  'startup'::organization_type,
  s.description,
  s.website,
  'active'::organization_status,
  'France',
  'funding_deals_april_2026',
  NOW(),
  NOW()
FROM source s
ON CONFLICT (slug) DO UPDATE SET
  website = COALESCE(organizations.website, EXCLUDED.website),
  description = COALESCE(organizations.description, EXCLUDED.description),
  updated_at = NOW();

-- =============================================================================
-- Step 2: Create funding rounds
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      {
        "name": "Generare",
        "stage": "series_a",
        "amount_eur": 15.0,
        "currency_original": "EUR",
        "amount_original": 15000000,
        "announced_date": "2026-04-01",
        "source_url": "https://www.eu-startups.com/2026/04/paris-based-generare-raises-e20-million-to-generate-novel-molecular-data-for-drug-development-from-microbial-genomes/",
        "notes": "Total round \u20ac20M. \u20ac15M equity. Founded 2023, incubated at H\u00f4pital Cochin. 200+ novel small molecules identified. Targets 2,000 molecules by 2027."
      },
      {
        "name": "Omniscient",
        "stage": "seed",
        "amount_eur": 3.772,
        "currency_original": "USD",
        "amount_original": 4100000,
        "announced_date": "2026-04-02",
        "source_url": "https://siliconangle.com/2026/04/02/omniscient-raises-4-1m-ai-driven-decision-intelligence-platform/",
        "notes": "Reported as $4.1M. Converted from USD at 0.92 EUR/USD. Founded 2024 by ex-McKinsey consultants. Clients include Renault. Aggregates 100,000+ sources."
      }
    ]$json$
  ) AS (name TEXT, stage TEXT, amount_eur NUMERIC, currency_original TEXT,
        amount_original NUMERIC, announced_date TEXT, source_url TEXT, notes TEXT)
)
INSERT INTO funding_rounds (
  id, organization_id, stage, amount_eur, currency_original, amount_original,
  announced_date, is_estimated, is_verified, source_name, source_url, notes,
  created_at
)
SELECT
  uuid_generate_v4(),
  o.id,
  s.stage::funding_stage,
  s.amount_eur,
  s.currency_original,
  s.amount_original,
  s.announced_date::DATE,
  CASE WHEN s.currency_original != 'EUR' AND s.amount_eur IS NOT NULL THEN TRUE ELSE FALSE END,
  FALSE,
  'funding_deals_april_2026',
  s.source_url,
  s.notes,
  NOW()
FROM source s
JOIN organizations o ON o.slug = lower(regexp_replace(
  regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\s-]', '', 'g'),
  '\s+', '-', 'g'
));

-- =============================================================================
-- Step 3a: Create investor organizations
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      {"name": "Alven"},
      {"name": "Anamcara"},
      {"name": "Bpifrance"},
      {"name": "Drysdale Ventures"},
      {"name": "Galion.exe"},
      {"name": "MS & AD"},
      {"name": "Plug and Play"},
      {"name": "Raise"},
      {"name": "Seedcamp"},
      {"name": "Teampact Ventures"},
      {"name": "Vives Partners"},
      {"name": "daphni"},
      {"name": "xdeck"}
    ]$json$
  ) AS (name TEXT)
)
INSERT INTO organizations (
  id, name, slug, organization_type, status, country,
  legacy_source, created_at, updated_at
)
SELECT
  uuid_generate_v4(),
  s.name,
  lower(regexp_replace(
    regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\s-]', '', 'g'),
    '\s+', '-', 'g'
  )),
  'investor'::organization_type,
  'active'::organization_status,
  'France',
  'funding_deals_april_2026',
  NOW(),
  NOW()
FROM source s
ON CONFLICT (slug) DO NOTHING;

-- =============================================================================
-- Step 3b: Create funding round investors
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      {"org_name": "Generare", "announced_date": "2026-04-01", "amount_eur": 15.0, "investor_name": "Alven", "is_lead": true},
      {"org_name": "Generare", "announced_date": "2026-04-01", "amount_eur": 15.0, "investor_name": "daphni", "is_lead": true},
      {"org_name": "Generare", "announced_date": "2026-04-01", "amount_eur": 15.0, "investor_name": "Galion.exe", "is_lead": false},
      {"org_name": "Generare", "announced_date": "2026-04-01", "amount_eur": 15.0, "investor_name": "Teampact Ventures", "is_lead": false},
      {"org_name": "Generare", "announced_date": "2026-04-01", "amount_eur": 15.0, "investor_name": "Vives Partners", "is_lead": false},
      {"org_name": "Omniscient", "announced_date": "2026-04-02", "amount_eur": 3.772, "investor_name": "Seedcamp", "is_lead": true},
      {"org_name": "Omniscient", "announced_date": "2026-04-02", "amount_eur": 3.772, "investor_name": "Drysdale Ventures", "is_lead": false},
      {"org_name": "Omniscient", "announced_date": "2026-04-02", "amount_eur": 3.772, "investor_name": "Plug and Play", "is_lead": false},
      {"org_name": "Omniscient", "announced_date": "2026-04-02", "amount_eur": 3.772, "investor_name": "MS & AD", "is_lead": false},
      {"org_name": "Omniscient", "announced_date": "2026-04-02", "amount_eur": 3.772, "investor_name": "Raise", "is_lead": false},
      {"org_name": "Omniscient", "announced_date": "2026-04-02", "amount_eur": 3.772, "investor_name": "Anamcara", "is_lead": false},
      {"org_name": "Omniscient", "announced_date": "2026-04-02", "amount_eur": 3.772, "investor_name": "xdeck", "is_lead": false},
      {"org_name": "Omniscient", "announced_date": "2026-04-02", "amount_eur": 3.772, "investor_name": "Bpifrance", "is_lead": false}
    ]$json$
  ) AS (org_name TEXT, announced_date TEXT, amount_eur NUMERIC, investor_name TEXT, is_lead BOOLEAN)
)
INSERT INTO funding_round_investors (
  id, funding_round_id, investor_id, is_lead, investor_name, created_at
)
SELECT
  uuid_generate_v4(),
  fr.id,
  inv_org.id,
  s.is_lead,
  s.investor_name,
  NOW()
FROM source s
JOIN organizations o ON o.slug = lower(regexp_replace(
  regexp_replace(unaccent(s.org_name), '[^a-zA-Z0-9\s-]', '', 'g'),
  '\s+', '-', 'g'
))
JOIN organizations inv_org ON inv_org.slug = lower(regexp_replace(
  regexp_replace(unaccent(s.investor_name), '[^a-zA-Z0-9\s-]', '', 'g'),
  '\s+', '-', 'g'
))
JOIN funding_rounds fr ON fr.organization_id = o.id
  AND fr.source_name = 'funding_deals_april_2026'
  AND (
    (fr.announced_date::TEXT = s.announced_date OR (fr.announced_date IS NULL AND s.announced_date IS NULL))
    AND (fr.amount_eur = s.amount_eur OR (fr.amount_eur IS NULL AND s.amount_eur IS NULL))
  );

-- =============================================================================
-- Step 4: Link organizations to sectors
-- =============================================================================
-- Generare: BioTech, AI & Machine Learning, DeepTech
INSERT INTO organization_sectors (id, organization_id, sector_id, is_primary, created_at)
SELECT uuid_generate_v4(), o.id, sec.id, (sec.slug = 'biotech'), NOW()
FROM organizations o, sectors sec
WHERE o.slug = 'generare'
  AND sec.slug IN ('biotech', 'ai-and-machine-learning', 'deeptech')
ON CONFLICT (organization_id, sector_id) DO NOTHING;

-- Omniscient: AI & Machine Learning, SaaS & Enterprise
INSERT INTO organization_sectors (id, organization_id, sector_id, is_primary, created_at)
SELECT uuid_generate_v4(), o.id, sec.id, (sec.slug = 'ai-and-machine-learning'), NOW()
FROM organizations o, sectors sec
WHERE o.slug = 'omniscient'
  AND sec.slug IN ('ai-and-machine-learning', 'saas-and-enterprise')
ON CONFLICT (organization_id, sector_id) DO NOTHING;

-- =============================================================================
-- Step 5: Create people records for founders
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      {"full_name": "Guillaume Vandenesch", "first_name": "Guillaume", "last_name": "Vandenesch"},
      {"full_name": "Arnaud d'Estienne", "first_name": "Arnaud", "last_name": "d'Estienne"},
      {"full_name": "Mehdi Benseghir", "first_name": "Mehdi", "last_name": "Benseghir"}
    ]$json$
  ) AS (full_name TEXT, first_name TEXT, last_name TEXT)
)
INSERT INTO people (
  id, full_name, slug, first_name, last_name,
  legacy_source, created_at
)
SELECT
  uuid_generate_v4(),
  s.full_name,
  lower(regexp_replace(
    regexp_replace(unaccent(s.full_name), '[^a-zA-Z0-9\s-]', '', 'g'),
    '\s+', '-', 'g'
  )),
  s.first_name,
  s.last_name,
  'funding_deals_april_2026',
  NOW()
FROM source s
ON CONFLICT (slug) DO NOTHING;

-- =============================================================================
-- Step 6: Link founders to organizations
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      {"org_name": "Generare", "founder_name": "Guillaume Vandenesch"},
      {"org_name": "Omniscient", "founder_name": "Arnaud d'Estienne"},
      {"org_name": "Omniscient", "founder_name": "Mehdi Benseghir"}
    ]$json$
  ) AS (org_name TEXT, founder_name TEXT)
)
INSERT INTO organization_people (
  id, organization_id, person_id, role, is_current, is_founder, created_at, updated_at
)
SELECT
  uuid_generate_v4(),
  o.id,
  p.id,
  'Founder',
  TRUE,
  TRUE,
  NOW(),
  NOW()
FROM source s
JOIN organizations o ON o.slug = lower(regexp_replace(
  regexp_replace(unaccent(s.org_name), '[^a-zA-Z0-9\s-]', '', 'g'),
  '\s+', '-', 'g'
))
JOIN people p ON p.slug = lower(regexp_replace(
  regexp_replace(unaccent(s.founder_name), '[^a-zA-Z0-9\s-]', '', 'g'),
  '\s+', '-', 'g'
))
ON CONFLICT (organization_id, person_id, role) DO NOTHING;

-- =============================================================================
-- Verification queries
-- =============================================================================
SELECT 'Organizations' AS entity, COUNT(*) AS count
FROM organizations WHERE legacy_source = 'funding_deals_april_2026'
UNION ALL
SELECT 'Funding Rounds', COUNT(*)
FROM funding_rounds WHERE source_name = 'funding_deals_april_2026'
UNION ALL
SELECT 'Investor Links', COUNT(*)
FROM funding_round_investors fri
JOIN funding_rounds fr ON fr.id = fri.funding_round_id
WHERE fr.source_name = 'funding_deals_april_2026';
