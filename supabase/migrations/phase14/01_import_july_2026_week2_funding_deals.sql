-- =============================================================================
-- July 2026 Funding Deals Import
-- =============================================================================
-- Imports 12 funding deals from July 2026 (week of July 6-10).
-- Creates/updates organizations, funding_rounds, investors, organization_sectors,
-- people (founders), organization_people links, cities, and city links
-- (city_id + secondary_city_id). Amounts stored in millions (DB convention).
-- Organizations that already exist (matched by slug) get the new round attached
-- rather than being duplicated.
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "unaccent";

-- Ensure the secondary_city_id column exists. It is present on the live
-- database (added out-of-band) but is not created by any committed migration,
-- so this guard lets the import also succeed on a fresh database build.
ALTER TABLE organizations
  ADD COLUMN IF NOT EXISTS secondary_city_id UUID REFERENCES cities(id) ON DELETE SET NULL;

-- =============================================================================
-- Step 0: Ensure cities exist (idempotent)
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      {
            "name": "Paris",
            "country": "France"
      },
      {
            "name": "San Francisco",
            "country": "USA"
      },
      {
            "name": "Toulouse",
            "country": "France"
      },
      {
            "name": "Bordeaux",
            "country": "France"
      }
]$json$
  ) AS (name TEXT, country TEXT)
)
INSERT INTO cities (id, name, slug, country, created_at, updated_at)
SELECT
  uuid_generate_v4(),
  s.name,
  lower(regexp_replace(
    regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\s-]', '', 'g'),
    '\s+', '-', 'g'
  )),
  s.country,
  NOW(), NOW()
FROM source s
ON CONFLICT (slug) DO NOTHING;

-- =============================================================================
-- Step 0c: Ensure new sectors exist (idempotent)
-- =============================================================================
INSERT INTO sectors (id, name, slug, created_at, updated_at)
VALUES
  (uuid_generate_v4(), 'Semiconductors', 'semiconductors', NOW(), NOW()),
  (uuid_generate_v4(), 'HRTech', 'hrtech', NOW(), NOW())
ON CONFLICT (slug) DO NOTHING;

-- =============================================================================
-- Step 1: Create organizations (12 startups; existing ones are preserved)
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      {
            "name": "Skello",
            "website": "https://www.skello.io",
            "description": "Skello is an AI-powered workforce-management platform for frontline teams that helps businesses manage employee scheduling, administration, regulatory compliance and operational performance. Its Skello Assistant AI agent converts workforce data into tailored HR insights and automates follow-up actions."
      },
      {
            "name": "Cyllene Therapeutics",
            "website": "https://www.cyllene-tx.com",
            "description": "Cyllene Therapeutics (formerly EG 427) is a clinical-stage biotechnology company developing precision DNA medicines for neurological and neuro-urological diseases. Its HERMES platform uses non-replicating HSV-1 vectors to deliver therapeutic DNA selectively to targeted neurons."
      },
      {
            "name": "Gradium",
            "website": "https://gradium.ai",
            "description": "Gradium is an AI infrastructure company developing foundational models for real-time voice applications, including streaming speech-to-text, expressive text-to-speech, speech-to-speech translation and conversational intelligence for developers and enterprises."
      },
      {
            "name": "ZML",
            "website": "http://zml.ai/",
            "description": "ZML is an AI infrastructure startup developing inference software that enables open-source large language models to run efficiently across multiple types of hardware, including Nvidia and AMD GPUs, Google TPUs, Apple Metal and Intel Arc chips."
      },
      {
            "name": "Bohr Energy",
            "website": "http://bohr-energie.fr/",
            "description": "Bohr Energie is an independent energy aggregator that uses proprietary software, AI, forecasting and real-time optimization tools to help renewable energy producers manage and commercialize distributed solar, wind, hydro, battery and hybrid assets."
      },
      {
            "name": "Aria",
            "website": "https://www.aria.finance",
            "description": "Aria provides embedded invoice financing infrastructure that enables B2B marketplaces, ERP platforms, and vertical SaaS providers to offer instant supplier payments while allowing buyers to retain standard payment terms."
      },
      {
            "name": "Naaia",
            "website": "https://naaia.ai/",
            "description": "Naaia is a RegTech platform that helps organizations manage AI-related risks and automate compliance with regulations and standards, including the EU AI Act, ISO 42001 and the Cyber Resilience Act. Its text-to-action technology converts regulatory requirements into executable compliance tasks."
      },
      {
            "name": "Click&Care",
            "website": "https://clickandcare.fr/",
            "description": "Click&Care is a digital home-care network that connects families with locally recruited care professionals while managing recruitment, matching and administrative processes through its platform. Its model combines centralized human support with technology designed to improve caregiver pay, reduce travel time, and support independent living."
      },
      {
            "name": "En Carta Diagnostics",
            "website": "https://encartadiagnostics.com",
            "description": "En Carta Diagnostics develops rapid molecular diagnostic tests that combine laboratory-grade PCR accuracy with the simplicity of at-home testing. Its programmable aptamer-based platform is designed to detect infectious diseases in around 30 minutes without requiring laboratory infrastructure."
      },
      {
            "name": "Panora",
            "website": "https://www.panora.co",
            "description": "Panora is an agentic AI platform for B2B insurance brokers that automates repetitive workflows, including multi-carrier quoting, document collection and generation, policy comparison, commission reconciliation and DDA compliance, while keeping brokers in control of advice and decision-making."
      },
      {
            "name": "Rivage",
            "website": "https://www.rivage.immo/",
            "description": "Rivage is a property-management SaaS platform for real estate professionals that automates rental accounting, payment requests, bank reconciliation, regulatory administration and communication between landlords and tenants. Its platform also uses AI to help handle maintenance requests and recommend service providers."
      },
      {
            "name": "W Platform",
            "website": "https://w-platform.fr/en/",
            "description": "W Platform is a climate-tech company developing patented systems that capture, purify, compress and store CO2 produced during wine and beer fermentation, allowing vineyards and breweries to reuse it on-site for processes such as inerting, carbonation and dry-ice production."
      }
]$json$
  ) AS (name TEXT, website TEXT, description TEXT)
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
  'funding_deals_july_2026',
  NOW(), NOW()
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
      {
            "org_name": "Skello",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "Cyllene Therapeutics",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "Gradium",
            "city": "Paris",
            "secondary_city": "San Francisco"
      },
      {
            "org_name": "ZML",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "Bohr Energy",
            "city": "Toulouse",
            "secondary_city": null
      },
      {
            "org_name": "Aria",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "Naaia",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "Click&Care",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "En Carta Diagnostics",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "Panora",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "Rivage",
            "city": "Paris",
            "secondary_city": null
      },
      {
            "org_name": "W Platform",
            "city": "Bordeaux",
            "secondary_city": null
      }
]$json$
  ) AS (org_name TEXT, city TEXT, secondary_city TEXT)
)
UPDATE organizations o SET
  city_id = COALESCE(o.city_id, c1.id),
  secondary_city_id = COALESCE(o.secondary_city_id, c2.id),
  updated_at = NOW()
FROM source s
LEFT JOIN cities c1 ON c1.slug = lower(regexp_replace(
  regexp_replace(unaccent(s.city), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g'))
LEFT JOIN cities c2 ON c2.slug = lower(regexp_replace(
  regexp_replace(unaccent(s.secondary_city), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g'))
WHERE o.slug = lower(regexp_replace(
  regexp_replace(unaccent(s.org_name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g'));

-- =============================================================================
-- Step 2: Create funding rounds
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      {
            "name": "Skello",
            "stage": "growth",
            "amount_eur": 150.0,
            "currency_original": "EUR",
            "amount_original": 150000000,
            "announced_date": "2026-07-06",
            "notes": "\u20ac150M growth round (part of a ~\u20ac200M investment, ~\u20ac50M secondary, plus debt) led by Bridgepoint. 25,000 businesses, 600,000 daily users; \u20ac50M+ ARR, profitable in 2025. Sources: EU-Startups, Maddyness."
      },
      {
            "name": "Cyllene Therapeutics",
            "stage": "series_c",
            "amount_eur": 33.0,
            "currency_original": "EUR",
            "amount_original": 33000000,
            "announced_date": "2026-07-06",
            "notes": "\u20ac33M Series C; rebranded from EG 427. Advances EG110A for neurogenic detrusor overactivity; Phase 2b/3 planned for 2027. Attached to the existing EG 427 organization. Sources: PR, BioWorld."
      },
      {
            "name": "Gradium",
            "stage": "seed",
            "amount_eur": 26.3,
            "currency_original": "EUR",
            "amount_original": 26300000,
            "announced_date": "2026-07-06",
            "notes": "Seed extension surpassing $100M total financing (7 months after launch). Products incl. Gradium Translate, on-device Phonon, and open-source GradBot. Establishing a San Francisco Bay Area office. Sources: Gradium, Maddyness."
      },
      {
            "name": "ZML",
            "stage": "seed",
            "amount_eur": 17.2,
            "currency_original": "USD",
            "amount_original": 20000000,
            "announced_date": "2026-07-06",
            "notes": "$20M seed; launched ZML/LLMD, a free LLM inference server to reduce hardware vendor lock-in. Cap table includes Solomon Hykes, Cl\u00e9ment Delangue, Julien Chaumond, Yann LeCun. Source: TechCrunch."
      },
      {
            "name": "Bohr Energy",
            "stage": "series_a",
            "amount_eur": 10.0,
            "currency_original": "EUR",
            "amount_original": 10000000,
            "announced_date": "2026-07-06",
            "notes": "\u20ac10M Series A to strengthen its France position and expand into Spain and Italy. Manages 170+ renewable/flexible assets; targeting ~1 GW under management by year-end. Attached to the existing 'Bohr Energy' organization. Source: EU-Startups."
      },
      {
            "name": "Aria",
            "stage": "series_a",
            "amount_eur": 7.0,
            "currency_original": "EUR",
            "amount_original": 7000000,
            "announced_date": "2026-07-06",
            "notes": "\u20ac7M Series A extension led by 115K (La Banque Postale VC), plus a \u20ac240M debt securitization facility led by Nomura. \u20ac22M total Series A. Financed \u20ac1.5B+ of invoices; 70+ platforms incl. Malt. Sources: EU-Startups, Axios."
      },
      {
            "name": "Naaia",
            "stage": "series_a",
            "amount_eur": 6.0,
            "currency_original": "EUR",
            "amount_original": 6000000,
            "announced_date": "2026-07-06",
            "notes": "\u20ac6M Series A led by Ventech (\u20ac9M total). Funds commercial/product/technical teams and AI-agent development. Source: Maddyness."
      },
      {
            "name": "Click&Care",
            "stage": "seed",
            "amount_eur": 5.0,
            "currency_original": "EUR",
            "amount_original": 5000000,
            "announced_date": "2026-07-06",
            "notes": "\u20ac5M to scale its digital home-care model nationwide and add AI decision-support tools. Source: Les \u00c9chos."
      },
      {
            "name": "En Carta Diagnostics",
            "stage": "seed",
            "amount_eur": 3.0,
            "currency_original": "EUR",
            "amount_original": 3000000,
            "announced_date": "2026-07-06",
            "notes": "\u20ac3M equity within a \u20ac5M first closing (+\u20ac2M non-dilutive). Lyme test received FDA Breakthrough Device Designation (Jan 2026); \u20ac13M co-development deal with AAZ. Attached to the existing organization. Source: EU-Startups."
      },
      {
            "name": "Panora",
            "stage": "seed",
            "amount_eur": 4.4,
            "currency_original": "EUR",
            "amount_original": 4400000,
            "announced_date": "2026-07-06",
            "notes": "Reported as $4.5M seed. Incubated by Hexa (ex-eFounders); clients incl. Howden and ~50 brokerages in France and Belgium. Source: Panora."
      },
      {
            "name": "Rivage",
            "stage": "seed",
            "amount_eur": 1.5,
            "currency_original": "EUR",
            "amount_original": 1500000,
            "announced_date": "2026-07-06",
            "notes": "\u20ac1.5M seed to invest in marketing and product and accelerate customer acquisition in France. Founded 2025 (Rivage SAS, SIREN 940386303); distinct from the payroll company now named Alassio. Source: Tech Funding News."
      },
      {
            "name": "W Platform",
            "stage": "seed",
            "amount_eur": 1.0,
            "currency_original": "EUR",
            "amount_original": 1000000,
            "announced_date": "2026-07-06",
            "notes": "\u20ac1M seed to deploy its CO2 Box for vineyards and breweries. Founded 2021, ~20 customers; targeting break-even in 2027. Source: Les \u00c9chos."
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
  uuid_generate_v4(),
  o.id,
  s.stage::funding_stage,
  s.amount_eur,
  s.currency_original,
  s.amount_original,
  s.announced_date::DATE,
  CASE WHEN s.currency_original IS NOT NULL AND s.currency_original != 'EUR' AND s.amount_eur IS NOT NULL THEN TRUE ELSE FALSE END,
  FALSE,
  'funding_deals_july_2026',
  s.notes,
  NOW()
FROM source s
JOIN organizations o ON o.slug = lower(regexp_replace(
  regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\s-]', '', 'g'),
  '\s+', '-', 'g'
));

-- =============================================================================
-- Step 3a: Create investor organizations (idempotent)
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      {
            "name": "100in"
      },
      {
            "name": "115K"
      },
      {
            "name": "13books Capital"
      },
      {
            "name": "199 Ventures"
      },
      {
            "name": "20VC"
      },
      {
            "name": "50 Partners Health"
      },
      {
            "name": "AALVC"
      },
      {
            "name": "AFI Ventures"
      },
      {
            "name": "Andera Partners"
      },
      {
            "name": "Banque des Territoires"
      },
      {
            "name": "Blue Forest Ventures"
      },
      {
            "name": "Bpifrance"
      },
      {
            "name": "Bridgepoint"
      },
      {
            "name": "CentraleSup\u00e9lec Venture"
      },
      {
            "name": "Cl\u00e9ment Delangue"
      },
      {
            "name": "commit"
      },
      {
            "name": "Cr\u00e9dit Agricole"
      },
      {
            "name": "Demea Invest"
      },
      {
            "name": "Drysdale Ventures"
      },
      {
            "name": "Fost"
      },
      {
            "name": "Founders Future"
      },
      {
            "name": "GordonMD Global Investments"
      },
      {
            "name": "GSO Capital"
      },
      {
            "name": "InvESS \u00cele-de-France D\u00e9veloppement"
      },
      {
            "name": "Irdi Capital Investissement"
      },
      {
            "name": "ISAI"
      },
      {
            "name": "Julien Chaumond"
      },
      {
            "name": "Kima Ventures"
      },
      {
            "name": "Kindred Capital"
      },
      {
            "name": "Lamond Ventures"
      },
      {
            "name": "LocalGlobe"
      },
      {
            "name": "M Ventures"
      },
      {
            "name": "Montpensier Arbevel"
      },
      {
            "name": "Nomura"
      },
      {
            "name": "NVIDIA"
      },
      {
            "name": "Partech"
      },
      {
            "name": "Puzzle Ventures"
      },
      {
            "name": "Ring Capital"
      },
      {
            "name": "Sienna"
      },
      {
            "name": "Solomon Hykes"
      },
      {
            "name": "Suma Capital"
      },
      {
            "name": "SWEN Capital Partners"
      },
      {
            "name": "Tudigo"
      },
      {
            "name": "Varsity"
      },
      {
            "name": "Ventech"
      },
      {
            "name": "Vitirev Innovation"
      },
      {
            "name": "XAnge"
      },
      {
            "name": "Yann LeCun"
      }
]$json$
  ) AS (name TEXT)
)
INSERT INTO organizations (
  id, name, slug, organization_type, status, country, legacy_source, created_at, updated_at
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
  'funding_deals_july_2026',
  NOW(), NOW()
FROM source s
ON CONFLICT (slug) DO NOTHING;

-- =============================================================================
-- Step 3b: Create funding round investors
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      {
            "org_name": "Skello",
            "announced_date": "2026-07-06",
            "amount_eur": 150.0,
            "investor_name": "Bridgepoint",
            "is_lead": true
      },
      {
            "org_name": "Skello",
            "announced_date": "2026-07-06",
            "amount_eur": 150.0,
            "investor_name": "Partech",
            "is_lead": false
      },
      {
            "org_name": "Skello",
            "announced_date": "2026-07-06",
            "amount_eur": 150.0,
            "investor_name": "XAnge",
            "is_lead": false
      },
      {
            "org_name": "Cyllene Therapeutics",
            "announced_date": "2026-07-06",
            "amount_eur": 33.0,
            "investor_name": "GordonMD Global Investments",
            "is_lead": false
      },
      {
            "org_name": "Cyllene Therapeutics",
            "announced_date": "2026-07-06",
            "amount_eur": 33.0,
            "investor_name": "M Ventures",
            "is_lead": false
      },
      {
            "org_name": "Cyllene Therapeutics",
            "announced_date": "2026-07-06",
            "amount_eur": 33.0,
            "investor_name": "Andera Partners",
            "is_lead": false
      },
      {
            "org_name": "Cyllene Therapeutics",
            "announced_date": "2026-07-06",
            "amount_eur": 33.0,
            "investor_name": "Bpifrance",
            "is_lead": false
      },
      {
            "org_name": "Cyllene Therapeutics",
            "announced_date": "2026-07-06",
            "amount_eur": 33.0,
            "investor_name": "Lamond Ventures",
            "is_lead": false
      },
      {
            "org_name": "Gradium",
            "announced_date": "2026-07-06",
            "amount_eur": 26.3,
            "investor_name": "NVIDIA",
            "is_lead": false
      },
      {
            "org_name": "ZML",
            "announced_date": "2026-07-06",
            "amount_eur": 17.2,
            "investor_name": "20VC",
            "is_lead": false
      },
      {
            "org_name": "ZML",
            "announced_date": "2026-07-06",
            "amount_eur": 17.2,
            "investor_name": "commit",
            "is_lead": false
      },
      {
            "org_name": "ZML",
            "announced_date": "2026-07-06",
            "amount_eur": 17.2,
            "investor_name": "AALVC",
            "is_lead": false
      },
      {
            "org_name": "ZML",
            "announced_date": "2026-07-06",
            "amount_eur": 17.2,
            "investor_name": "Drysdale Ventures",
            "is_lead": false
      },
      {
            "org_name": "ZML",
            "announced_date": "2026-07-06",
            "amount_eur": 17.2,
            "investor_name": "Kima Ventures",
            "is_lead": false
      },
      {
            "org_name": "ZML",
            "announced_date": "2026-07-06",
            "amount_eur": 17.2,
            "investor_name": "Kindred Capital",
            "is_lead": false
      },
      {
            "org_name": "ZML",
            "announced_date": "2026-07-06",
            "amount_eur": 17.2,
            "investor_name": "LocalGlobe",
            "is_lead": false
      },
      {
            "org_name": "ZML",
            "announced_date": "2026-07-06",
            "amount_eur": 17.2,
            "investor_name": "Puzzle Ventures",
            "is_lead": false
      },
      {
            "org_name": "ZML",
            "announced_date": "2026-07-06",
            "amount_eur": 17.2,
            "investor_name": "Solomon Hykes",
            "is_lead": false
      },
      {
            "org_name": "ZML",
            "announced_date": "2026-07-06",
            "amount_eur": 17.2,
            "investor_name": "Cl\u00e9ment Delangue",
            "is_lead": false
      },
      {
            "org_name": "ZML",
            "announced_date": "2026-07-06",
            "amount_eur": 17.2,
            "investor_name": "Julien Chaumond",
            "is_lead": false
      },
      {
            "org_name": "ZML",
            "announced_date": "2026-07-06",
            "amount_eur": 17.2,
            "investor_name": "Yann LeCun",
            "is_lead": false
      },
      {
            "org_name": "Bohr Energy",
            "announced_date": "2026-07-06",
            "amount_eur": 10.0,
            "investor_name": "Suma Capital",
            "is_lead": false
      },
      {
            "org_name": "Bohr Energy",
            "announced_date": "2026-07-06",
            "amount_eur": 10.0,
            "investor_name": "Irdi Capital Investissement",
            "is_lead": false
      },
      {
            "org_name": "Bohr Energy",
            "announced_date": "2026-07-06",
            "amount_eur": 10.0,
            "investor_name": "GSO Capital",
            "is_lead": false
      },
      {
            "org_name": "Bohr Energy",
            "announced_date": "2026-07-06",
            "amount_eur": 10.0,
            "investor_name": "Cr\u00e9dit Agricole",
            "is_lead": false
      },
      {
            "org_name": "Bohr Energy",
            "announced_date": "2026-07-06",
            "amount_eur": 10.0,
            "investor_name": "Varsity",
            "is_lead": false
      },
      {
            "org_name": "Bohr Energy",
            "announced_date": "2026-07-06",
            "amount_eur": 10.0,
            "investor_name": "Founders Future",
            "is_lead": false
      },
      {
            "org_name": "Bohr Energy",
            "announced_date": "2026-07-06",
            "amount_eur": 10.0,
            "investor_name": "AFI Ventures",
            "is_lead": false
      },
      {
            "org_name": "Aria",
            "announced_date": "2026-07-06",
            "amount_eur": 7.0,
            "investor_name": "115K",
            "is_lead": true
      },
      {
            "org_name": "Aria",
            "announced_date": "2026-07-06",
            "amount_eur": 7.0,
            "investor_name": "13books Capital",
            "is_lead": false
      },
      {
            "org_name": "Aria",
            "announced_date": "2026-07-06",
            "amount_eur": 7.0,
            "investor_name": "Nomura",
            "is_lead": false
      },
      {
            "org_name": "Aria",
            "announced_date": "2026-07-06",
            "amount_eur": 7.0,
            "investor_name": "Fost",
            "is_lead": false
      },
      {
            "org_name": "Aria",
            "announced_date": "2026-07-06",
            "amount_eur": 7.0,
            "investor_name": "Sienna",
            "is_lead": false
      },
      {
            "org_name": "Aria",
            "announced_date": "2026-07-06",
            "amount_eur": 7.0,
            "investor_name": "Montpensier Arbevel",
            "is_lead": false
      },
      {
            "org_name": "Naaia",
            "announced_date": "2026-07-06",
            "amount_eur": 6.0,
            "investor_name": "Ventech",
            "is_lead": true
      },
      {
            "org_name": "Click&Care",
            "announced_date": "2026-07-06",
            "amount_eur": 5.0,
            "investor_name": "SWEN Capital Partners",
            "is_lead": false
      },
      {
            "org_name": "Click&Care",
            "announced_date": "2026-07-06",
            "amount_eur": 5.0,
            "investor_name": "InvESS \u00cele-de-France D\u00e9veloppement",
            "is_lead": false
      },
      {
            "org_name": "Click&Care",
            "announced_date": "2026-07-06",
            "amount_eur": 5.0,
            "investor_name": "Banque des Territoires",
            "is_lead": false
      },
      {
            "org_name": "En Carta Diagnostics",
            "announced_date": "2026-07-06",
            "amount_eur": 3.0,
            "investor_name": "Blue Forest Ventures",
            "is_lead": false
      },
      {
            "org_name": "En Carta Diagnostics",
            "announced_date": "2026-07-06",
            "amount_eur": 3.0,
            "investor_name": "Ring Capital",
            "is_lead": false
      },
      {
            "org_name": "En Carta Diagnostics",
            "announced_date": "2026-07-06",
            "amount_eur": 3.0,
            "investor_name": "CentraleSup\u00e9lec Venture",
            "is_lead": false
      },
      {
            "org_name": "En Carta Diagnostics",
            "announced_date": "2026-07-06",
            "amount_eur": 3.0,
            "investor_name": "50 Partners Health",
            "is_lead": false
      },
      {
            "org_name": "En Carta Diagnostics",
            "announced_date": "2026-07-06",
            "amount_eur": 3.0,
            "investor_name": "Bpifrance",
            "is_lead": false
      },
      {
            "org_name": "Panora",
            "announced_date": "2026-07-06",
            "amount_eur": 4.4,
            "investor_name": "ISAI",
            "is_lead": false
      },
      {
            "org_name": "Panora",
            "announced_date": "2026-07-06",
            "amount_eur": 4.4,
            "investor_name": "Kima Ventures",
            "is_lead": false
      },
      {
            "org_name": "Panora",
            "announced_date": "2026-07-06",
            "amount_eur": 4.4,
            "investor_name": "100in",
            "is_lead": false
      },
      {
            "org_name": "Panora",
            "announced_date": "2026-07-06",
            "amount_eur": 4.4,
            "investor_name": "199 Ventures",
            "is_lead": false
      },
      {
            "org_name": "Rivage",
            "announced_date": "2026-07-06",
            "amount_eur": 1.5,
            "investor_name": "Kima Ventures",
            "is_lead": false
      },
      {
            "org_name": "W Platform",
            "announced_date": "2026-07-06",
            "amount_eur": 1.0,
            "investor_name": "Vitirev Innovation",
            "is_lead": false
      },
      {
            "org_name": "W Platform",
            "announced_date": "2026-07-06",
            "amount_eur": 1.0,
            "investor_name": "Demea Invest",
            "is_lead": false
      },
      {
            "org_name": "W Platform",
            "announced_date": "2026-07-06",
            "amount_eur": 1.0,
            "investor_name": "Tudigo",
            "is_lead": false
      }
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
  AND fr.source_name = 'funding_deals_july_2026'
  AND (
    (fr.announced_date::TEXT = s.announced_date OR (fr.announced_date IS NULL AND s.announced_date IS NULL))
    AND (fr.amount_eur = s.amount_eur OR (fr.amount_eur IS NULL AND s.amount_eur IS NULL))
  );

-- =============================================================================
-- Step 4: Link organizations to sectors
-- =============================================================================
-- Step 4a: insert all org-sector links as non-primary (idempotent)
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      {
            "org": "skello",
            "sec": "hrtech"
      },
      {
            "org": "skello",
            "sec": "saas"
      },
      {
            "org": "skello",
            "sec": "artificial-intelligence"
      },
      {
            "org": "cyllene-therapeutics",
            "sec": "biotech"
      },
      {
            "org": "gradium",
            "sec": "artificial-intelligence"
      },
      {
            "org": "zml",
            "sec": "artificial-intelligence"
      },
      {
            "org": "bohr-energy",
            "sec": "energy"
      },
      {
            "org": "bohr-energy",
            "sec": "artificial-intelligence"
      },
      {
            "org": "aria",
            "sec": "fintech"
      },
      {
            "org": "naaia",
            "sec": "artificial-intelligence"
      },
      {
            "org": "naaia",
            "sec": "saas"
      },
      {
            "org": "clickcare",
            "sec": "healthtech"
      },
      {
            "org": "en-carta-diagnostics",
            "sec": "medtech"
      },
      {
            "org": "en-carta-diagnostics",
            "sec": "deeptech"
      },
      {
            "org": "panora",
            "sec": "insurtech"
      },
      {
            "org": "panora",
            "sec": "artificial-intelligence"
      },
      {
            "org": "rivage",
            "sec": "proptech"
      },
      {
            "org": "rivage",
            "sec": "artificial-intelligence"
      },
      {
            "org": "w-platform",
            "sec": "climatetech"
      }
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
      {
            "org": "skello",
            "sec": "hrtech"
      },
      {
            "org": "cyllene-therapeutics",
            "sec": "biotech"
      },
      {
            "org": "gradium",
            "sec": "artificial-intelligence"
      },
      {
            "org": "zml",
            "sec": "artificial-intelligence"
      },
      {
            "org": "bohr-energy",
            "sec": "energy"
      },
      {
            "org": "aria",
            "sec": "fintech"
      },
      {
            "org": "naaia",
            "sec": "artificial-intelligence"
      },
      {
            "org": "clickcare",
            "sec": "healthtech"
      },
      {
            "org": "en-carta-diagnostics",
            "sec": "medtech"
      },
      {
            "org": "panora",
            "sec": "insurtech"
      },
      {
            "org": "rivage",
            "sec": "proptech"
      },
      {
            "org": "w-platform",
            "sec": "climatetech"
      }
]$json$
  ) AS (org TEXT, sec TEXT)
)
UPDATE organization_sectors os SET is_primary = TRUE
FROM source s
JOIN organizations o ON o.slug = s.org
JOIN sectors sec ON sec.slug = s.sec
WHERE os.organization_id = o.id AND os.sector_id = sec.id
  AND NOT EXISTS (
    SELECT 1 FROM organization_sectors x
    WHERE x.organization_id = o.id AND x.is_primary = TRUE
  );

-- =============================================================================
-- Step 5: Create people records for founders
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      {
            "full_name": "Quitterie Mathelin-Moreaux",
            "first_name": "Quitterie",
            "last_name": "Mathelin-Moreaux"
      },
      {
            "full_name": "Emmanuelle Fauchier-Magnan",
            "first_name": "Emmanuelle",
            "last_name": "Fauchier-Magnan"
      },
      {
            "full_name": "Philippe Chambon",
            "first_name": "Philippe",
            "last_name": "Chambon"
      },
      {
            "full_name": "Neil Zeghidour",
            "first_name": "Neil",
            "last_name": "Zeghidour"
      },
      {
            "full_name": "Laurent Mazar\u00e9",
            "first_name": "Laurent",
            "last_name": "Mazar\u00e9"
      },
      {
            "full_name": "Olivier Teboul",
            "first_name": "Olivier",
            "last_name": "Teboul"
      },
      {
            "full_name": "Alexandre D\u00e9fossez",
            "first_name": "Alexandre",
            "last_name": "D\u00e9fossez"
      },
      {
            "full_name": "Steeve Morin",
            "first_name": "Steeve",
            "last_name": "Morin"
      },
      {
            "full_name": "Julien Haure",
            "first_name": "Julien",
            "last_name": "Haure"
      },
      {
            "full_name": "Luis Urday",
            "first_name": "Luis",
            "last_name": "Urday"
      },
      {
            "full_name": "Julien Chollet",
            "first_name": "Julien",
            "last_name": "Chollet"
      },
      {
            "full_name": "Jean-Pierre Mader",
            "first_name": "Jean-Pierre",
            "last_name": "Mader"
      },
      {
            "full_name": "Cl\u00e9ment Carrier",
            "first_name": "Cl\u00e9ment",
            "last_name": "Carrier"
      },
      {
            "full_name": "Nathalie Beslay",
            "first_name": "Nathalie",
            "last_name": "Beslay"
      },
      {
            "full_name": "Benjamin May",
            "first_name": "Benjamin",
            "last_name": "May"
      },
      {
            "full_name": "Olivia Rime",
            "first_name": "Olivia",
            "last_name": "Rime"
      },
      {
            "full_name": "C\u00f4me Sauzay",
            "first_name": "C\u00f4me",
            "last_name": "Sauzay"
      },
      {
            "full_name": "Lina Bougrini",
            "first_name": "Lina",
            "last_name": "Bougrini"
      },
      {
            "full_name": "Guillaume Horreard",
            "first_name": "Guillaume",
            "last_name": "Horreard"
      },
      {
            "full_name": "Margot Karlikow",
            "first_name": "Margot",
            "last_name": "Karlikow"
      },
      {
            "full_name": "Diane du Paty",
            "first_name": "Diane",
            "last_name": "du Paty"
      },
      {
            "full_name": "Fabian Langlet",
            "first_name": "Fabian",
            "last_name": "Langlet"
      },
      {
            "full_name": "Alex Chauvin",
            "first_name": "Alex",
            "last_name": "Chauvin"
      },
      {
            "full_name": "Matthieu Plant\u00e9",
            "first_name": "Matthieu",
            "last_name": "Plant\u00e9"
      }
]$json$
  ) AS (full_name TEXT, first_name TEXT, last_name TEXT)
)
INSERT INTO people (
  id, full_name, slug, first_name, last_name, legacy_source, created_at
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
  'funding_deals_july_2026',
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
      {
            "org_name": "Skello",
            "founder_name": "Quitterie Mathelin-Moreaux"
      },
      {
            "org_name": "Skello",
            "founder_name": "Emmanuelle Fauchier-Magnan"
      },
      {
            "org_name": "Cyllene Therapeutics",
            "founder_name": "Philippe Chambon"
      },
      {
            "org_name": "Gradium",
            "founder_name": "Neil Zeghidour"
      },
      {
            "org_name": "Gradium",
            "founder_name": "Laurent Mazar\u00e9"
      },
      {
            "org_name": "Gradium",
            "founder_name": "Olivier Teboul"
      },
      {
            "org_name": "Gradium",
            "founder_name": "Alexandre D\u00e9fossez"
      },
      {
            "org_name": "ZML",
            "founder_name": "Steeve Morin"
      },
      {
            "org_name": "Bohr Energy",
            "founder_name": "Julien Haure"
      },
      {
            "org_name": "Bohr Energy",
            "founder_name": "Luis Urday"
      },
      {
            "org_name": "Bohr Energy",
            "founder_name": "Julien Chollet"
      },
      {
            "org_name": "Bohr Energy",
            "founder_name": "Jean-Pierre Mader"
      },
      {
            "org_name": "Aria",
            "founder_name": "Cl\u00e9ment Carrier"
      },
      {
            "org_name": "Naaia",
            "founder_name": "Nathalie Beslay"
      },
      {
            "org_name": "Naaia",
            "founder_name": "Benjamin May"
      },
      {
            "org_name": "Naaia",
            "founder_name": "Olivia Rime"
      },
      {
            "org_name": "Naaia",
            "founder_name": "C\u00f4me Sauzay"
      },
      {
            "org_name": "Click&Care",
            "founder_name": "Lina Bougrini"
      },
      {
            "org_name": "En Carta Diagnostics",
            "founder_name": "Guillaume Horreard"
      },
      {
            "org_name": "En Carta Diagnostics",
            "founder_name": "Margot Karlikow"
      },
      {
            "org_name": "Panora",
            "founder_name": "Diane du Paty"
      },
      {
            "org_name": "Panora",
            "founder_name": "Fabian Langlet"
      },
      {
            "org_name": "Rivage",
            "founder_name": "Alex Chauvin"
      },
      {
            "org_name": "W Platform",
            "founder_name": "Matthieu Plant\u00e9"
      }
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
  TRUE, TRUE,
  NOW(), NOW()
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
-- Step 7: Attach SIREN legal entities to companies
-- =============================================================================
-- Inserts one legal_entities row per company that has a SIREN, but only when
-- that company does not already carry that exact SIREN (idempotent). is_primary
-- is set only when the organization has no other legal entity yet.
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      {
            "org": "skello",
            "siren": "820275956"
      },
      {
            "org": "cyllene-therapeutics",
            "siren": "851225599"
      },
      {
            "org": "gradium",
            "siren": "989284955"
      },
      {
            "org": "zml",
            "siren": "981723638"
      },
      {
            "org": "bohr-energy",
            "siren": "889663654"
      },
      {
            "org": "aria",
            "siren": "837680966"
      },
      {
            "org": "naaia",
            "siren": "913352688"
      },
      {
            "org": "clickcare",
            "siren": "820048585"
      },
      {
            "org": "rivage",
            "siren": "940386303"
      },
      {
            "org": "w-platform",
            "siren": "899623979"
      }
]$json$
  ) AS (org TEXT, siren TEXT)
)
INSERT INTO legal_entities (
  id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at
)
SELECT
  uuid_generate_v4(),
  o.id,
  o.name,
  s.siren,
  'France',
  NOT EXISTS (SELECT 1 FROM legal_entities le2 WHERE le2.organization_id = o.id),
  NOW(), NOW()
FROM source s
JOIN organizations o ON o.slug = s.org
WHERE NOT EXISTS (
  SELECT 1 FROM legal_entities le
  WHERE le.organization_id = o.id AND le.siren = s.siren
);

-- =============================================================================
-- Verification queries
-- =============================================================================
SELECT 'Funding Rounds' AS entity, COUNT(*) AS count
FROM funding_rounds WHERE source_name = 'funding_deals_july_2026'
UNION ALL
SELECT 'Investor Links', COUNT(*)
FROM funding_round_investors fri
JOIN funding_rounds fr ON fr.id = fri.funding_round_id
WHERE fr.source_name = 'funding_deals_july_2026'
UNION ALL
SELECT 'Founder Links (new people)', COUNT(*)
FROM people WHERE legacy_source = 'funding_deals_july_2026';
