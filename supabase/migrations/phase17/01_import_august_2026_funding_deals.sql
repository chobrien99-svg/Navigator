-- =============================================================================
-- August 2026 Funding Deals Import (batch dated August 14)
-- =============================================================================
-- Imports the funding deals from the August 14, 2026 roundup.
-- Creates/updates organizations, funding_rounds, investors, organization_sectors,
-- people (founders), organization_people links, cities, and city links.
-- Amounts stored in millions (DB convention).
--
-- Of the 11 companies in the roundup, 9 get a new funding round here:
--   Chargepoly (existing org, new Growth round), Eurodia, Neverhack, SkinBit,
--   AMDB Security Pro, Apolownia, Krème, Shiplog, Reboat.
-- Only Chargepoly already existed (it had a 2023 Series A); the other eight are
-- new organizations.
--
-- Deliberately EXCLUDED to avoid double-counting (already in the database):
--   * STRACKER  -- same EUR 2.5M seed already imported as source
--                  'funding_deals_july_2026_week3' (announced 2026-07-13).
--   * Hekat Fluidics -- same EUR 2.4M seed already imported as source
--                  'funding_deals_july_2026_week4' (announced 2026-07-20).
-- These are re-reports of the same rounds, so no new round/investors are created
-- for them here. The verification below therefore counts 9 new rounds, not 11.
--
-- Other notes:
--   * Undisclosed amounts (Krème, Reboat) are stored with amount_eur = NULL.
--   * SkinBit raised in USD ($6M); amount_eur is the converted estimate (is_estimated).
--   * AMDB Security Pro's backers are two anonymous U.S. private investors; since
--     funding_round_investors.investor_id is NOT NULL, no investor link is created
--     for it -- the backers are recorded in the round notes instead.
--   * SkinBit (Paris + Los Angeles) and Shiplog (Paris + San Francisco) are dual-HQ;
--     Paris is the primary city and the foreign city is the secondary. Los Angeles is
--     added as a US city. Org country stays 'France' (Paris-primary, French-tech tracker).
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "unaccent";

ALTER TABLE organizations
  ADD COLUMN IF NOT EXISTS secondary_city_id UUID REFERENCES cities(id) ON DELETE SET NULL;

-- =============================================================================
-- Step 0: Ensure cities exist (idempotent). Los Angeles is a US city.
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      { "name": "Aix-en-Provence", "country": "France" },
      { "name": "Pertuis", "country": "France" },
      { "name": "Guyancourt", "country": "France" },
      { "name": "Paris", "country": "France" },
      { "name": "Los Angeles", "country": "USA" },
      { "name": "Saint-Georges-d'Espéranche", "country": "France" },
      { "name": "San Francisco", "country": "USA" },
      { "name": "Lorient", "country": "France" }
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
  (uuid_generate_v4(), 'Blue Economy', 'blue-economy', NOW(), NOW())
ON CONFLICT (slug) DO NOTHING;

-- =============================================================================
-- Step 1: Create organizations (existing ones are preserved)
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      {
            "name": "Chargepoly",
            "website": "https://www.chargepoly.com/en/",
            "description": "Chargepoly designs, deploys, and operates high-capacity DC charging infrastructure for medium- and heavy-duty vehicle fleets. Its integrated offering combines modular charging hardware, project delivery, Charging Point Operator capabilities, and its Lucie software suite to optimize power allocation, infrastructure utilization, and total cost of ownership."
      },
      {
            "name": "Eurodia",
            "website": "https://eurodia.com",
            "description": "Designs and installs eco-efficient industrial systems for extracting, purifying, and recovering components from complex liquids. Its technologies include electrodialysis, membrane filtration, chromatography, adsorption, and ion-exchange resins, with applications spanning lithium extraction and refining, critical-metals recycling, process decarbonization, and food production."
      },
      {
            "name": "Neverhack",
            "website": "https://neverhack.com",
            "description": "Provides cybersecurity services covering consulting, managed security, training, incident response, and sovereign AI infrastructure. The group employs more than 1,200 people across 12 countries and reports €220 million in annual revenue."
      },
      {
            "name": "SkinBit",
            "website": "https://skinbit.co/",
            "description": "SkinBit is building a longitudinal skin-health platform centered on 20-minute full-body scans delivered through clinics, med spas, longevity centers, and its own branded locations. Board-certified dermatologists review each scan and store it as a patient-owned baseline to track skin changes over time and improve early detection of skin cancer."
      },
      {
            "name": "AMDB Security Pro",
            "website": "https://www.amdbsecuritypro.com",
            "description": "AMDB Security Pro develops patented mechanical anti-theft systems for excavators, mini-excavators, and other construction equipment. Its tamper-resistant solution physically blocks unauthorized ignition without relying on electronics or connectivity, while adding deterrence features such as an alarm and GPS tracking."
      },
      {
            "name": "Apolownia",
            "website": "https://www.apolownia.com/",
            "description": "Apolownia develops high-integrity coastal ecosystem restoration projects designed to restore natural carbon sinks and regenerate biodiversity. Its model combines field operations with technologies including satellite remote sensing, geospatial analysis, drones, 3D modeling, advanced MRV, and AI to manage projects from site identification through long-term monitoring and impact measurement."
      },
      {
            "name": "Krème",
            "website": "https://kreme-paris.com/",
            "description": "Krème is a French dermocosmetics brand developing science-backed skincare focused on preserving and strengthening the skin microbiome. Its Ecocert-certified organic formulations combine probiotic ferments and biotech active ingredients and are distributed through pharmacies, department stores, and direct-to-consumer channels."
      },
      {
            "name": "Shiplog",
            "website": "https://useshiplog.com/",
            "description": "Shiplog develops an agentic customer intelligence platform designed to enable real-time, individualized personalization at scale. Its AI agent, Ada, continuously analyzes customer behavior, builds live profiles, and autonomously determines the next best action across marketing, product, onboarding, support, and customer success workflows."
      },
      {
            "name": "Reboat",
            "website": "https://reboat.com/",
            "description": "Reboat industrially refurbishes and redesigns pre-owned sailboats and catamarans, covering structural, functional, and aesthetic upgrades and offering bespoke layouts tailored to customers' sailing needs. Its refurbished vessels are positioned as a lower-cost, lower-carbon alternative to new boats, priced 30-50% below new models, with an estimated carbon footprint reduction of up to 64%."
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
  'funding_deals_august_2026',
  NOW(), NOW()
FROM source s
ON CONFLICT (slug) DO UPDATE SET
  website = COALESCE(organizations.website, EXCLUDED.website),
  description = COALESCE(organizations.description, EXCLUDED.description),
  updated_at = NOW();

-- =============================================================================
-- Step 1b: Link organizations to primary and secondary cities
-- (COALESCE preserves any city link an existing org already has)
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      { "org_name": "Chargepoly", "city": "Aix-en-Provence", "secondary_city": null },
      { "org_name": "Eurodia", "city": "Pertuis", "secondary_city": null },
      { "org_name": "Neverhack", "city": "Guyancourt", "secondary_city": null },
      { "org_name": "SkinBit", "city": "Paris", "secondary_city": "Los Angeles" },
      { "org_name": "AMDB Security Pro", "city": "Saint-Georges-d'Espéranche", "secondary_city": null },
      { "org_name": "Apolownia", "city": "Paris", "secondary_city": null },
      { "org_name": "Krème", "city": "Paris", "secondary_city": null },
      { "org_name": "Shiplog", "city": "Paris", "secondary_city": "San Francisco" },
      { "org_name": "Reboat", "city": "Lorient", "secondary_city": null }
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
-- Step 2: Create funding rounds (9 -- STRACKER and Hekat Fluidics excluded)
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      {
            "name": "Chargepoly",
            "stage": "growth",
            "amount_eur": 23.0,
            "currency_original": "EUR",
            "amount_original": 23000000,
            "announced_date": "2026-08-14",
            "notes": "€23M growth investment led by Meridiam Green Impact Growth Fund, with Fideve Groupe, to accelerate international expansion of its integrated DC fast-charging platform for heavy-duty and commercial vehicle fleets. Operates hundreds of DC charging points across France, the UK and Canada; customers include Groupe Rave, Nationex and CMA-CGM, working with OEMs Renault Trucks, Volvo Trucks and Daimler Truck. Attached to the existing 'Chargepoly' organization (had a 2023 Series A). Source: EU-Startups."
      },
      {
            "name": "Eurodia",
            "stage": "growth",
            "amount_eur": 18.0,
            "currency_original": "EUR",
            "amount_original": 18000000,
            "announced_date": "2026-08-14",
            "notes": "€18M growth equity: Starquest Capital and Yotta Capital Partners acquired minority stakes to support international expansion and larger industrial projects. Founded 1988; 450+ installations across 50 countries, 80%+ of business international. Revenue grew from €34M (2023) to €80M (2025). Source: ESG Today."
      },
      {
            "name": "Neverhack",
            "stage": "series_a",
            "amount_eur": 11.0,
            "currency_original": "EUR",
            "amount_original": 11000000,
            "announced_date": "2026-08-14",
            "notes": "€11M Series A from existing shareholders Carlyle and IK Partners, completed June 10, 2026. Funds a sovereign cybersecurity AI offering plus trusted infrastructure and GPU capacity in France, Italy and Estonia, and technical/commercial team growth. Founder Arthur Bataille appointed Executive Chairman; Frédéric Sarrailh appointed CEO. Source: Alliancy."
      },
      {
            "name": "SkinBit",
            "stage": "seed",
            "amount_eur": 5.16,
            "currency_original": "USD",
            "amount_original": 6000000,
            "announced_date": "2026-08-14",
            "notes": "$6M seed to expand its full-body skin-scanning platform for earlier skin-cancer detection. 20-minute scans reviewed by board-certified dermatologists and stored as patient-owned longitudinal records. First clinics planned for 2026; 5,000+ on the waitlist. Dual HQ Paris and Los Angeles. Source: LinkedIn."
      },
      {
            "name": "AMDB Security Pro",
            "stage": "seed",
            "amount_eur": 2.68,
            "currency_original": "EUR",
            "amount_original": 2680000,
            "announced_date": "2026-08-14",
            "notes": "€2.68M ($3.1M) seed from two U.S.-based private investors (not individually named) to fund US expansion (a US subsidiary, local teams, partnerships with rental firms, insurers and equipment makers) ahead of a larger 2027 rollout, plus R&D. Founded 2023; made-in-France mechanical anti-theft systems compatible with 100+ brands of mini-excavators. Won gold at the 2025 Concours Lépine. Source: Global Startups Insights, EU-Startups."
      },
      {
            "name": "Apolownia",
            "stage": "seed",
            "amount_eur": 1.0,
            "currency_original": "EUR",
            "amount_original": 1000000,
            "announced_date": "2026-08-14",
            "notes": "€1M first seed round to scale its high-integrity coastal (blue carbon) ecosystem restoration model and strengthen scientific, technological and deployment capabilities. Flagship BlueRizon project in Indonesia aims to restore 4,000+ hectares of mangroves (launch Q3 2026). Investors: LITA, Bpifrance, business angels and individual investors. Source: EU-Startups."
      },
      {
            "name": "Krème",
            "stage": "growth",
            "amount_eur": null,
            "currency_original": null,
            "amount_original": null,
            "announced_date": "2026-08-14",
            "notes": "Undisclosed first external equity investment: Iris Ventures acquired a minority stake in the French dermocosmetics brand (fifth investment from Iris Ventures' second €200M fund). Founded 2020; doubling revenue yearly, distributed in 3,000+ French pharmacies plus Galeries Lafayette, Samaritaine, Printemps Haussmann and DTC. Funds European expansion (Spain, UK), product development and team growth. Source: WWD."
      },
      {
            "name": "Shiplog",
            "stage": "pre_seed",
            "amount_eur": 0.8076,
            "currency_original": "EUR",
            "amount_original": 807600,
            "announced_date": "2026-08-14",
            "notes": "€807.6k+ ($930k) pre-Seed to develop Ada, an AI agent that evaluates customers individually and autonomously executes the next best action across the lifecycle (a live 'segment of one'). Integrates Salesforce, HubSpot, Snowflake, Shopify, Stripe; targeting FinTech, cybersecurity, software and consumer. Founded 2026, based at Station F. Investors: Kima Ventures, Project Europe, Purple, No Label Ventures, 100IN, Station F Fund and angels. Dual HQ Paris and San Francisco. Source: EU-Startups."
      },
      {
            "name": "Reboat",
            "stage": "seed",
            "amount_eur": null,
            "currency_original": null,
            "amount_original": null,
            "announced_date": "2026-08-14",
            "notes": "Undisclosed seed led by Seventure Partners (with Business Angels and Charlotte Souleau) to scale industrial refurbishment of used sailboats and catamarans. Founded 2024; expanding its 1,000 sqm Lorient workshop, opening a Mediterranean site, and recruiting; aims for 30 boats in 2027 and ~100/year by 2031. Seventure Partners and Charlotte Souleau join the leadership team. Source: Marine Business."
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
  'funding_deals_august_2026',
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
      { "name": "Meridiam Green Impact Growth Fund" },
      { "name": "Fideve Groupe" },
      { "name": "Starquest Capital" },
      { "name": "Yotta Capital Partners" },
      { "name": "Carlyle" },
      { "name": "IK Partners" },
      { "name": "Boost VC" },
      { "name": "Cleo Capital" },
      { "name": "Manna Ventures" },
      { "name": "Profluent Capital" },
      { "name": "Logan Green" },
      { "name": "Business Angels" },
      { "name": "Lita" },
      { "name": "Bpifrance" },
      { "name": "Iris Ventures" },
      { "name": "Kima Ventures" },
      { "name": "Project Europe" },
      { "name": "Purple" },
      { "name": "No Label Ventures" },
      { "name": "100IN" },
      { "name": "Station F Fund" },
      { "name": "Seventure Partners" },
      { "name": "Charlotte Souleau" }
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
  'funding_deals_august_2026',
  NOW(), NOW()
FROM source s
ON CONFLICT (slug) DO NOTHING;

-- =============================================================================
-- Step 3b: Create funding round investors
-- (AMDB Security Pro excluded -- anonymous backers; STRACKER/Hekat excluded)
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      { "org_name": "Chargepoly", "amount_eur": 23.0, "investor_name": "Meridiam Green Impact Growth Fund", "is_lead": true },
      { "org_name": "Chargepoly", "amount_eur": 23.0, "investor_name": "Fideve Groupe", "is_lead": false },
      { "org_name": "Eurodia", "amount_eur": 18.0, "investor_name": "Starquest Capital", "is_lead": false },
      { "org_name": "Eurodia", "amount_eur": 18.0, "investor_name": "Yotta Capital Partners", "is_lead": false },
      { "org_name": "Neverhack", "amount_eur": 11.0, "investor_name": "Carlyle", "is_lead": false },
      { "org_name": "Neverhack", "amount_eur": 11.0, "investor_name": "IK Partners", "is_lead": false },
      { "org_name": "SkinBit", "amount_eur": 5.16, "investor_name": "Boost VC", "is_lead": false },
      { "org_name": "SkinBit", "amount_eur": 5.16, "investor_name": "Cleo Capital", "is_lead": false },
      { "org_name": "SkinBit", "amount_eur": 5.16, "investor_name": "Manna Ventures", "is_lead": false },
      { "org_name": "SkinBit", "amount_eur": 5.16, "investor_name": "Profluent Capital", "is_lead": false },
      { "org_name": "SkinBit", "amount_eur": 5.16, "investor_name": "Logan Green", "is_lead": false },
      { "org_name": "SkinBit", "amount_eur": 5.16, "investor_name": "Business Angels", "is_lead": false },
      { "org_name": "Apolownia", "amount_eur": 1.0, "investor_name": "Lita", "is_lead": false },
      { "org_name": "Apolownia", "amount_eur": 1.0, "investor_name": "Bpifrance", "is_lead": false },
      { "org_name": "Apolownia", "amount_eur": 1.0, "investor_name": "Business Angels", "is_lead": false },
      { "org_name": "Krème", "amount_eur": null, "investor_name": "Iris Ventures", "is_lead": true },
      { "org_name": "Shiplog", "amount_eur": 0.8076, "investor_name": "Kima Ventures", "is_lead": false },
      { "org_name": "Shiplog", "amount_eur": 0.8076, "investor_name": "Project Europe", "is_lead": false },
      { "org_name": "Shiplog", "amount_eur": 0.8076, "investor_name": "Purple", "is_lead": false },
      { "org_name": "Shiplog", "amount_eur": 0.8076, "investor_name": "No Label Ventures", "is_lead": false },
      { "org_name": "Shiplog", "amount_eur": 0.8076, "investor_name": "100IN", "is_lead": false },
      { "org_name": "Shiplog", "amount_eur": 0.8076, "investor_name": "Station F Fund", "is_lead": false },
      { "org_name": "Shiplog", "amount_eur": 0.8076, "investor_name": "Business Angels", "is_lead": false },
      { "org_name": "Reboat", "amount_eur": null, "investor_name": "Seventure Partners", "is_lead": true },
      { "org_name": "Reboat", "amount_eur": null, "investor_name": "Business Angels", "is_lead": false },
      { "org_name": "Reboat", "amount_eur": null, "investor_name": "Charlotte Souleau", "is_lead": false }
]$json$
  ) AS (org_name TEXT, amount_eur NUMERIC, investor_name TEXT, is_lead BOOLEAN)
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
-- Join on org + source only: each org has exactly one August 2026 round, and
-- amount_eur is stored at 2-decimal scale (e.g. Shiplog's €0.8076M rounds to
-- 0.81), so matching on amount would silently drop links.
JOIN funding_rounds fr ON fr.organization_id = o.id
  AND fr.source_name = 'funding_deals_august_2026';

-- =============================================================================
-- Step 4: Link organizations to sectors
-- =============================================================================
-- Step 4a: insert all org-sector links as non-primary (idempotent)
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      { "org": "chargepoly", "sec": "cleantech" },
      { "org": "chargepoly", "sec": "mobility" },
      { "org": "eurodia", "sec": "deeptech" },
      { "org": "eurodia", "sec": "cleantech" },
      { "org": "neverhack", "sec": "cybersecurity" },
      { "org": "neverhack", "sec": "artificial-intelligence" },
      { "org": "skinbit", "sec": "healthtech" },
      { "org": "skinbit", "sec": "medtech" },
      { "org": "skinbit", "sec": "biotech" },
      { "org": "skinbit", "sec": "artificial-intelligence" },
      { "org": "skinbit", "sec": "deeptech" },
      { "org": "amdb-security-pro", "sec": "deeptech" },
      { "org": "apolownia", "sec": "climatetech" },
      { "org": "apolownia", "sec": "artificial-intelligence" },
      { "org": "kreme", "sec": "healthtech" },
      { "org": "shiplog", "sec": "artificial-intelligence" },
      { "org": "shiplog", "sec": "martech" },
      { "org": "reboat", "sec": "blue-economy" },
      { "org": "reboat", "sec": "circular-economy" },
      { "org": "reboat", "sec": "deeptech" }
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
      { "org": "chargepoly", "sec": "cleantech" },
      { "org": "eurodia", "sec": "deeptech" },
      { "org": "neverhack", "sec": "cybersecurity" },
      { "org": "skinbit", "sec": "healthtech" },
      { "org": "amdb-security-pro", "sec": "deeptech" },
      { "org": "apolownia", "sec": "climatetech" },
      { "org": "kreme", "sec": "healthtech" },
      { "org": "shiplog", "sec": "artificial-intelligence" },
      { "org": "reboat", "sec": "blue-economy" }
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
      { "full_name": "Hadi Moussavi", "first_name": "Hadi", "last_name": "Moussavi" },
      { "full_name": "Bernard Gillery", "first_name": "Bernard", "last_name": "Gillery" },
      { "full_name": "Arthur Bataille", "first_name": "Arthur", "last_name": "Bataille" },
      { "full_name": "Ilya Novoselskiy", "first_name": "Ilya", "last_name": "Novoselskiy" },
      { "full_name": "Jonathan Benassaya", "first_name": "Jonathan", "last_name": "Benassaya" },
      { "full_name": "Pascal Bonnevay-Oltra", "first_name": "Pascal", "last_name": "Bonnevay-Oltra" },
      { "full_name": "Kévin Kaarouche", "first_name": "Kévin", "last_name": "Kaarouche" },
      { "full_name": "Théo Derache", "first_name": "Théo", "last_name": "Derache" },
      { "full_name": "Juliette Lailler", "first_name": "Juliette", "last_name": "Lailler" },
      { "full_name": "Marie Belile", "first_name": "Marie", "last_name": "Belile" },
      { "full_name": "Khushi Mehta", "first_name": "Khushi", "last_name": "Mehta" },
      { "full_name": "Mehdi Gribaa", "first_name": "Mehdi", "last_name": "Gribaa" },
      { "full_name": "Dimitri Caudrelier", "first_name": "Dimitri", "last_name": "Caudrelier" },
      { "full_name": "Vincent Taupin", "first_name": "Vincent", "last_name": "Taupin" }
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
  'funding_deals_august_2026',
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
      { "org_name": "Chargepoly", "founder_name": "Hadi Moussavi" },
      { "org_name": "Eurodia", "founder_name": "Bernard Gillery" },
      { "org_name": "Neverhack", "founder_name": "Arthur Bataille" },
      { "org_name": "SkinBit", "founder_name": "Ilya Novoselskiy" },
      { "org_name": "SkinBit", "founder_name": "Jonathan Benassaya" },
      { "org_name": "AMDB Security Pro", "founder_name": "Pascal Bonnevay-Oltra" },
      { "org_name": "AMDB Security Pro", "founder_name": "Kévin Kaarouche" },
      { "org_name": "Apolownia", "founder_name": "Théo Derache" },
      { "org_name": "Krème", "founder_name": "Juliette Lailler" },
      { "org_name": "Krème", "founder_name": "Marie Belile" },
      { "org_name": "Shiplog", "founder_name": "Khushi Mehta" },
      { "org_name": "Shiplog", "founder_name": "Mehdi Gribaa" },
      { "org_name": "Reboat", "founder_name": "Dimitri Caudrelier" },
      { "org_name": "Reboat", "founder_name": "Vincent Taupin" }
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
-- Step 7: Attach SIREN legal entities to companies (French). Idempotent.
-- (STRACKER, Hekat, Shiplog and AMDB Security Pro are not listed: the first two
-- already have their SIRENs; Shiplog and AMDB have no SIREN in the source.)
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      { "org": "chargepoly", "siren": "850854993" },
      { "org": "eurodia", "siren": "390953545" },
      { "org": "neverhack", "siren": "327086435" },
      { "org": "skinbit", "siren": "942659327" },
      { "org": "apolownia", "siren": "931045439" },
      { "org": "kreme", "siren": "880048079" },
      { "org": "reboat", "siren": "932735681" }
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
FROM funding_rounds WHERE source_name = 'funding_deals_august_2026'
UNION ALL
SELECT 'Investor Links', COUNT(*)
FROM funding_round_investors fri
JOIN funding_rounds fr ON fr.id = fri.funding_round_id
WHERE fr.source_name = 'funding_deals_august_2026'
UNION ALL
SELECT 'Founder People (new)', COUNT(*)
FROM people WHERE legacy_source = 'funding_deals_august_2026';
