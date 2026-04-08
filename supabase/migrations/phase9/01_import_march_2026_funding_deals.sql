-- =============================================================================
-- March 2026 Funding Deals Import
-- =============================================================================
-- Imports 7 funding deals from March 2026.
-- Creates organizations, funding_rounds, investors, organization_sectors,
-- people (founders), and organization_people links.
-- Currency conversion: USD->EUR at 0.92 fixed rate.
-- Amounts stored in millions (DB convention).
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "unaccent";

-- =============================================================================
-- Step 1: Create new sectors that don't yet exist
-- =============================================================================
INSERT INTO sectors (id, name, slug, color, created_at, updated_at)
VALUES
  (uuid_generate_v4(), 'InsurTech', 'insurtech', '#64748b', NOW(), NOW())
ON CONFLICT (slug) DO NOTHING;

-- =============================================================================
-- Step 2: Create organizations (7 startups)
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      {
        "name": "Standing Ovation",
        "website": "https://standing-ovation.co/",
        "description": "Standing Ovation is a French foodtech startup producing animal-free dairy proteins using precision fermentation. Its core innovation enables the production of casein\u2014the key protein in milk\u2014without livestock, allowing manufacturers to recreate dairy products such as cheese, yogurt, and cream with identical functional properties while significantly reducing environmental impact. The company operates a B2B model, supplying food, nutrition, and future health/cosmetics players with sustainable protein ingredients.",
        "city": "Paris"
      },
      {
        "name": "SCorp-io",
        "website": "https://www.scorp-io.com/",
        "description": "SCorp-io is a French startup developing an intelligent building management system (BMS/GTB) for mid-sized tertiary buildings. Its solution combines plug-and-play hardware with AI-driven software to connect, model, and optimize existing building equipment. Through features such as digital twin creation, remote control, and automated energy optimization, the platform enables rapid deployment and delivers significant energy savings without requiring substantial infrastructure investment.",
        "city": "Paris"
      },
      {
        "name": "AI6 Technologies",
        "website": "https://ai6technologies.fr/",
        "description": "AI6 Technologies is a French assurtech startup developing AI- and big-data-powered solutions for risk prevention and claims management. Its platform helps insurers prevent climate-related losses, accelerate claims resolution, and improve operational efficiency through tools such as AI videobots for self-diagnostics, automated decision support, and predictive modeling for risks like drought-related soil shrink-swell. The company positions its services as market-wide infrastructure for insurers rather than point solutions for a single carrier.",
        "city": "Paris"
      },
      {
        "name": "Kestra",
        "website": "https://kestra.io/",
        "description": "Kestra is an open-source orchestration platform that enables enterprises to coordinate data pipelines, AI workflows, infrastructure automation, and business processes within a unified control plane. Designed for highly distributed environments across cloud, on-premises, and AI systems, Kestra provides a scalable, extensible orchestration layer with a large plugin ecosystem, allowing teams to manage complex workflows consistently and securely.",
        "city": "Paris"
      },
      {
        "name": "Loamics",
        "website": "http://loamics.com/",
        "description": "Loamics is the healthcare data subsidiary of Energisme, focused on leveraging data analytics to support healthcare systems and improve decision-making. The company operates at the intersection of health data infrastructure and analytics, aiming to unlock value from large-scale datasets for medical, operational, and research use cases.",
        "city": "Boulogne-Billancourt"
      },
      {
        "name": "Lifebloom",
        "website": "https://www.lifebloom.eu/",
        "description": "Lifebloom is a French medtech startup developing an integrated exoskeleton-based therapy to restore autonomous walking for patients with mobility impairments. Its solution combines a chair-exoskeleton device, gait analysis systems, and a digital care platform to support rehabilitation across hospitals, specialized centers, and at-home care. The therapy aims to increase patient autonomy while improving rehabilitation outcomes and care efficiency.",
        "city": null
      },
      {
        "name": "Fairglow",
        "website": "https://www.fairglow.io/",
        "description": "Fairglow is a French sustainability data platform for the beauty and health industries, enabling companies to measure, report, and reduce product-level environmental impacts. Its SaaS solution integrates life cycle assessment (LCA), carbon accounting, and eco-design tools, leveraging AI to reconstruct missing environmental data across complex supply chains. The platform supports compliance with evolving regulations while enabling real-time, data-driven formulation and packaging decisions.",
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
  'funding_deals_march_2026',
  NOW(),
  NOW()
FROM source s
ON CONFLICT (slug) DO UPDATE SET
  website = COALESCE(organizations.website, EXCLUDED.website),
  description = COALESCE(organizations.description, EXCLUDED.description),
  updated_at = NOW();

-- =============================================================================
-- Step 3: Create funding rounds
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      {
        "name": "Standing Ovation",
        "stage": "series_b",
        "amount_eur": 25.0,
        "currency_original": "EUR",
        "amount_original": 25000000,
        "announced_date": "2026-03-01",
        "source_url": "https://www.lesechos.fr/start-up/ecosysteme/on-va-ouvrir-la-voie-avec-standing-ovation-la-foodtech-reprend-des-couleurs-2224029",
        "notes": "Total round \u20ac30M including \u20ac25M equity. U.S. Self-GRAS regulatory approval secured."
      },
      {
        "name": "SCorp-io",
        "stage": "seed",
        "amount_eur": 5.0,
        "currency_original": "EUR",
        "amount_original": 5000000,
        "announced_date": "2026-03-01",
        "source_url": "https://www.frenchweb.fr/scorp-io-leve-5-millions-deuros-pour-industrialiser-la-decarbonation-des-batiments-intermediaires/461083",
        "notes": "Deployed across 250+ sites, 52 clients. 440 GWh energy savings in 2025."
      },
      {
        "name": "AI6 Technologies",
        "stage": "seed",
        "amount_eur": 4.0,
        "currency_original": "EUR",
        "amount_original": 4000000,
        "announced_date": "2026-03-30",
        "source_url": "https://tribune-assurance.optionfinance.fr/depeches/d/2026-03-30-generali-france-et-socadif-entrent-au-capital-dai6-technologies.html",
        "notes": "Founded in 2025. Generali France to integrate AI6 tools across prevention, underwriting, and claims."
      },
      {
        "name": "Kestra",
        "stage": "series_a",
        "amount_eur": 23.0,
        "currency_original": "USD",
        "amount_original": 25000000,
        "announced_date": "2026-03-31",
        "source_url": "https://tech.eu/2026/03/31/kestra-raises-25m-series-a-to-build-the-enterprise-orchestration-standard/",
        "notes": "Converted from USD at 0.92 EUR/USD. 30,000+ orgs using open-source, 2B+ workflows executed in 2025."
      },
      {
        "name": "Loamics",
        "stage": "growth",
        "amount_eur": 3.0,
        "currency_original": "EUR",
        "amount_original": 3000000,
        "announced_date": "2026-03-01",
        "source_url": "https://webdisclosure.com/article/energisme-epa-alnrg-5-million-investment-for-energismes-healthcare-subsidiary-GOgfVjYqnfz",
        "notes": "Total \u20ac5M investment (\u20ac3M equity + \u20ac2M convertible bonds). Healthcare subsidiary of Energisme."
      },
      {
        "name": "Lifebloom",
        "stage": "seed",
        "amount_eur": 6.0,
        "currency_original": "EUR",
        "amount_original": 6000000,
        "announced_date": "2026-03-01",
        "source_url": "https://www.mind.eu.com/health/article/lifebloom-leve-8-me-pour-deployer-sa-therapie-basee-sur-un-fauteuil-exosquelette/",
        "notes": "Total \u20ac8M (\u20ac6M equity + \u20ac2M France 2030 public support). Targets 30 hospitals, 1,000 patients by 2028."
      },
      {
        "name": "Fairglow",
        "stage": "seed",
        "amount_eur": 3.0,
        "currency_original": "EUR",
        "amount_original": 3000000,
        "announced_date": "2026-03-01",
        "source_url": "https://www.esgtoday.com/fairglow-raises-e3-million-to-decarbonize-beauty-supply-chain/",
        "notes": "50+ industry clients. Supports CSRD and Digital Product Passport compliance."
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
  CASE WHEN s.currency_original != 'EUR' THEN TRUE ELSE FALSE END,
  FALSE,
  'funding_deals_march_2026',
  s.source_url,
  s.notes,
  NOW()
FROM source s
JOIN organizations o ON o.slug = lower(regexp_replace(
  regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\s-]', '', 'g'),
  '\s+', '-', 'g'
));

-- =============================================================================
-- Step 4a: Create investor organizations
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      {"name": "Alven"},
      {"name": "Angelor"},
      {"name": "Astanor"},
      {"name": "Axeleo"},
      {"name": "Bel Group"},
      {"name": "Big Idea Ventures"},
      {"name": "Bpifrance"},
      {"name": "Business Angels"},
      {"name": "Crédit Mutuel"},
      {"name": "Danone Ventures"},
      {"name": "France 2030"},
      {"name": "Generali France"},
      {"name": "Good Startup"},
      {"name": "ISAI"},
      {"name": "Kima Ventures"},
      {"name": "RTP Global"},
      {"name": "SOCADIF Capital Investissement"},
      {"name": "SWEN Capital Partners"},
      {"name": "Seventure Partners"},
      {"name": "Ternel"},
      {"name": "Vatel Capital"},
      {"name": "Île-de-France Décarbonation Fund"}
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
  'funding_deals_march_2026',
  NOW(),
  NOW()
FROM source s
ON CONFLICT (slug) DO NOTHING;

-- =============================================================================
-- Step 4b: Create funding round investors
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      {"org_name": "Standing Ovation", "announced_date": "2026-03-01", "amount_eur": 25.0, "investor_name": "Danone Ventures", "is_lead": true},
      {"org_name": "Standing Ovation", "announced_date": "2026-03-01", "amount_eur": 25.0, "investor_name": "Crédit Mutuel", "is_lead": false},
      {"org_name": "Standing Ovation", "announced_date": "2026-03-01", "amount_eur": 25.0, "investor_name": "Angelor", "is_lead": false},
      {"org_name": "Standing Ovation", "announced_date": "2026-03-01", "amount_eur": 25.0, "investor_name": "Bel Group", "is_lead": false},
      {"org_name": "Standing Ovation", "announced_date": "2026-03-01", "amount_eur": 25.0, "investor_name": "Bpifrance", "is_lead": false},
      {"org_name": "Standing Ovation", "announced_date": "2026-03-01", "amount_eur": 25.0, "investor_name": "Astanor", "is_lead": false},
      {"org_name": "Standing Ovation", "announced_date": "2026-03-01", "amount_eur": 25.0, "investor_name": "Seventure Partners", "is_lead": false},
      {"org_name": "Standing Ovation", "announced_date": "2026-03-01", "amount_eur": 25.0, "investor_name": "Good Startup", "is_lead": false},
      {"org_name": "Standing Ovation", "announced_date": "2026-03-01", "amount_eur": 25.0, "investor_name": "Big Idea Ventures", "is_lead": false},
      {"org_name": "SCorp-io", "announced_date": "2026-03-01", "amount_eur": 5.0, "investor_name": "Île-de-France Décarbonation Fund", "is_lead": true},
      {"org_name": "AI6 Technologies", "announced_date": "2026-03-30", "amount_eur": 4.0, "investor_name": "Generali France", "is_lead": true},
      {"org_name": "AI6 Technologies", "announced_date": "2026-03-30", "amount_eur": 4.0, "investor_name": "SOCADIF Capital Investissement", "is_lead": false},
      {"org_name": "Kestra", "announced_date": "2026-03-31", "amount_eur": 23.0, "investor_name": "RTP Global", "is_lead": true},
      {"org_name": "Kestra", "announced_date": "2026-03-31", "amount_eur": 23.0, "investor_name": "Alven", "is_lead": false},
      {"org_name": "Kestra", "announced_date": "2026-03-31", "amount_eur": 23.0, "investor_name": "ISAI", "is_lead": false},
      {"org_name": "Kestra", "announced_date": "2026-03-31", "amount_eur": 23.0, "investor_name": "Axeleo", "is_lead": false},
      {"org_name": "Loamics", "announced_date": "2026-03-01", "amount_eur": 3.0, "investor_name": "Vatel Capital", "is_lead": true},
      {"org_name": "Lifebloom", "announced_date": "2026-03-01", "amount_eur": 6.0, "investor_name": "Business Angels", "is_lead": true},
      {"org_name": "Lifebloom", "announced_date": "2026-03-01", "amount_eur": 6.0, "investor_name": "France 2030", "is_lead": false},
      {"org_name": "Fairglow", "announced_date": "2026-03-01", "amount_eur": 3.0, "investor_name": "Ternel", "is_lead": true},
      {"org_name": "Fairglow", "announced_date": "2026-03-01", "amount_eur": 3.0, "investor_name": "SWEN Capital Partners", "is_lead": false},
      {"org_name": "Fairglow", "announced_date": "2026-03-01", "amount_eur": 3.0, "investor_name": "Kima Ventures", "is_lead": false}
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
  AND fr.source_name = 'funding_deals_march_2026'
  AND (
    (fr.announced_date::TEXT = s.announced_date OR (fr.announced_date IS NULL AND s.announced_date IS NULL))
    AND (fr.amount_eur = s.amount_eur OR (fr.amount_eur IS NULL AND s.amount_eur IS NULL))
  );

-- =============================================================================
-- Step 5: Link organizations to sectors
-- =============================================================================
-- Standing Ovation: FoodTech, ClimateTech, BioTech
INSERT INTO organization_sectors (id, organization_id, sector_id, is_primary, created_at)
SELECT uuid_generate_v4(), o.id, sec.id, (sec.slug = 'foodtech'), NOW()
FROM organizations o, sectors sec
WHERE o.slug = 'standing-ovation'
  AND sec.slug IN ('foodtech', 'climatetech', 'biotech')
ON CONFLICT (organization_id, sector_id) DO NOTHING;

-- SCorp-io: ClimateTech, PropTech, AI & Machine Learning, SaaS & Enterprise
INSERT INTO organization_sectors (id, organization_id, sector_id, is_primary, created_at)
SELECT uuid_generate_v4(), o.id, sec.id, (sec.slug = 'climatetech'), NOW()
FROM organizations o, sectors sec
WHERE o.slug = 'scorp-io'
  AND sec.slug IN ('climatetech', 'proptech-and-real-estate', 'ai-and-machine-learning', 'saas-and-enterprise')
ON CONFLICT (organization_id, sector_id) DO NOTHING;

-- AI6 Technologies: InsurTech, AI & Machine Learning, SaaS & Enterprise
INSERT INTO organization_sectors (id, organization_id, sector_id, is_primary, created_at)
SELECT uuid_generate_v4(), o.id, sec.id, (sec.slug = 'insurtech'), NOW()
FROM organizations o, sectors sec
WHERE o.slug = 'ai6-technologies'
  AND sec.slug IN ('insurtech', 'ai-and-machine-learning', 'saas-and-enterprise')
ON CONFLICT (organization_id, sector_id) DO NOTHING;

-- Kestra: AI & Machine Learning, SaaS & Enterprise
INSERT INTO organization_sectors (id, organization_id, sector_id, is_primary, created_at)
SELECT uuid_generate_v4(), o.id, sec.id, (sec.slug = 'ai-and-machine-learning'), NOW()
FROM organizations o, sectors sec
WHERE o.slug = 'kestra'
  AND sec.slug IN ('ai-and-machine-learning', 'saas-and-enterprise')
ON CONFLICT (organization_id, sector_id) DO NOTHING;

-- Loamics: HealthTech, SaaS & Enterprise, MedTech
INSERT INTO organization_sectors (id, organization_id, sector_id, is_primary, created_at)
SELECT uuid_generate_v4(), o.id, sec.id, (sec.slug = 'healthtech'), NOW()
FROM organizations o, sectors sec
WHERE o.slug = 'loamics'
  AND sec.slug IN ('healthtech', 'saas-and-enterprise', 'medtech')
ON CONFLICT (organization_id, sector_id) DO NOTHING;

-- Lifebloom: HealthTech, MedTech, Robotics
INSERT INTO organization_sectors (id, organization_id, sector_id, is_primary, created_at)
SELECT uuid_generate_v4(), o.id, sec.id, (sec.slug = 'healthtech'), NOW()
FROM organizations o, sectors sec
WHERE o.slug = 'lifebloom'
  AND sec.slug IN ('healthtech', 'medtech', 'robotics')
ON CONFLICT (organization_id, sector_id) DO NOTHING;

-- Fairglow: ClimateTech, SaaS & Enterprise
INSERT INTO organization_sectors (id, organization_id, sector_id, is_primary, created_at)
SELECT uuid_generate_v4(), o.id, sec.id, (sec.slug = 'climatetech'), NOW()
FROM organizations o, sectors sec
WHERE o.slug = 'fairglow'
  AND sec.slug IN ('climatetech', 'saas-and-enterprise')
ON CONFLICT (organization_id, sector_id) DO NOTHING;

-- =============================================================================
-- Step 6: Create people records for founders
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      {"full_name": "Romain Chayot", "first_name": "Romain", "last_name": "Chayot"},
      {"full_name": "Yvan Chardonnens", "first_name": "Yvan", "last_name": "Chardonnens"},
      {"full_name": "Jean-Romain Bardet", "first_name": "Jean-Romain", "last_name": "Bardet"},
      {"full_name": "Cédric Godefroy", "first_name": "Cédric", "last_name": "Godefroy"},
      {"full_name": "Bastien Robinot", "first_name": "Bastien", "last_name": "Robinot"},
      {"full_name": "Alain Tabatabai", "first_name": "Alain", "last_name": "Tabatabai"},
      {"full_name": "Sébastien Drouyer", "first_name": "Sébastien", "last_name": "Drouyer"},
      {"full_name": "Emmanuel Darras", "first_name": "Emmanuel", "last_name": "Darras"},
      {"full_name": "Ludovic Dehon", "first_name": "Ludovic", "last_name": "Dehon"},
      {"full_name": "Damien Roche", "first_name": "Damien", "last_name": "Roche"},
      {"full_name": "Quentin Carayon", "first_name": "Quentin", "last_name": "Carayon"},
      {"full_name": "Evan Peters", "first_name": "Evan", "last_name": "Peters"}
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
  'funding_deals_march_2026',
  NOW()
FROM source s
ON CONFLICT (slug) DO NOTHING;

-- =============================================================================
-- Step 7: Link founders to organizations
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      {"org_name": "Standing Ovation", "founder_name": "Romain Chayot"},
      {"org_name": "Standing Ovation", "founder_name": "Yvan Chardonnens"},
      {"org_name": "SCorp-io", "founder_name": "Jean-Romain Bardet"},
      {"org_name": "SCorp-io", "founder_name": "Cédric Godefroy"},
      {"org_name": "SCorp-io", "founder_name": "Bastien Robinot"},
      {"org_name": "AI6 Technologies", "founder_name": "Alain Tabatabai"},
      {"org_name": "AI6 Technologies", "founder_name": "Sébastien Drouyer"},
      {"org_name": "Kestra", "founder_name": "Emmanuel Darras"},
      {"org_name": "Kestra", "founder_name": "Ludovic Dehon"},
      {"org_name": "Lifebloom", "founder_name": "Damien Roche"},
      {"org_name": "Fairglow", "founder_name": "Quentin Carayon"},
      {"org_name": "Fairglow", "founder_name": "Evan Peters"}
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
FROM organizations WHERE legacy_source = 'funding_deals_march_2026'
UNION ALL
SELECT 'Funding Rounds', COUNT(*)
FROM funding_rounds WHERE source_name = 'funding_deals_march_2026'
UNION ALL
SELECT 'Investor Links', COUNT(*)
FROM funding_round_investors fri
JOIN funding_rounds fr ON fr.id = fri.funding_round_id
WHERE fr.source_name = 'funding_deals_march_2026';
