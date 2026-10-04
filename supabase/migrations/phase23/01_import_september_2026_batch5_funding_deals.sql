-- =============================================================================
-- September 2026 Funding Deals Import — Batch 5 (final September batch, 10 deals)
-- =============================================================================
-- source_name 'funding_deals_september_2026_batch5'. Amounts in millions.
--
-- 3 EXISTING orgs get a new, distinct round: Inbolt (slug inbolt), Rayon
--   (slug rayon, SIREN matches), SPASH (slug spash, spash.com).
-- 7 NEW orgs: Marble (fraud-compliance checkmarble.com), Shadow Santé, Revalue,
--   SoonGo, Vasco, C-Clerc, Edison IA.
--
-- Name-collision handling:
--   * Marble: an UNRELATED existing org 'marble' (marble.studio, 2023 seed) already
--     holds that slug. This Marble is the checkmarble.com fraud/compliance company
--     (legal MARBLE SAS, SIREN 922444674), so it is created under slug
--     'marble-checkmarble' (name "Marble (Checkmarble)") to avoid conflation.
--   * Shadow Santé (shadow.eco, healthcare carbon) is distinct from the existing
--     'shadow' org (shadow.tech, cloud gaming); it uses slug 'shadow-sante'.
--   * SPASH's legal entity is NGTV EXPERIENCE (SIREN 821548468). The round is
--     attached to the existing brand org 'spash' (spash.com). NOTE: a separate
--     legacy org 'ngtv-experience' also exists (the pre-rebrand entity) — left
--     untouched here; worth merging later.
--
-- Corrections applied per the source's verification table:
--   * Shadow Santé total financing €2.5M (card said €1.5M).
--   * Rayon's startup SIREN is 903538403 (not the unrelated RAYON 899993018).
--   * Vasco €1.7M only — the separate ~€4M savers' property vehicle is excluded.
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "unaccent";

ALTER TABLE organizations
  ADD COLUMN IF NOT EXISTS secondary_city_id UUID REFERENCES cities(id) ON DELETE SET NULL;

-- =============================================================================
-- Step 0: Ensure cities exist (all already present; idempotent)
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      { "name": "Paris", "country": "France" },
      { "name": "Sophia Antipolis", "country": "France" },
      { "name": "Grenoble", "country": "France" },
      { "name": "Nantes", "country": "France" },
      { "name": "Lyon", "country": "France" },
      { "name": "Bordeaux", "country": "France" },
      { "name": "Neuilly-sur-Seine", "country": "France" }
]$json$
  ) AS (name TEXT, country TEXT)
)
INSERT INTO cities (id, name, slug, country, created_at, updated_at)
SELECT uuid_generate_v4(), s.name,
  lower(regexp_replace(regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g')),
  s.country, NOW(), NOW()
FROM source s ON CONFLICT (slug) DO NOTHING;

-- =============================================================================
-- Step 0c: Ensure new sectors exist (idempotent)
-- =============================================================================
INSERT INTO sectors (id, name, slug, created_at, updated_at)
VALUES
  (uuid_generate_v4(), 'RegTech', 'regtech', NOW(), NOW())
ON CONFLICT (slug) DO NOTHING;

-- =============================================================================
-- Step 1: Create organizations (new; existing upserted, names preserved)
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      { "name": "Inbolt", "website": "https://www.inbolt.com", "description": "Develops a hardware-agnostic AI and 3D-vision software layer that lets industrial robots perceive changes in their environment and adjust their movements in real time. Its technology can retrofit existing robots and power new production lines." },
      { "name": "Rayon", "website": "https://www.rayon.design/", "description": "Browser-based collaborative drawing and design software built for interior designers and other space-design professionals. Rayon combines architectural drawings, specifications, and project data in a shared web environment and is expanding into AI-assisted workflows and 3D design." },
      { "name": "Marble (Checkmarble)", "website": "https://www.checkmarble.com/", "description": "Open-source fraud-detection and financial-crime compliance infrastructure for banks, fintechs and payment providers. Risk teams can build and deploy detection rules, transaction monitoring and compliance workflows, hosted or on-premise. Brand 'Marble'; product Checkmarble." },
      { "name": "Shadow Santé", "website": "https://www.shadow.eco/", "description": "Environmental-management platform for hospitals and other healthcare facilities, automating carbon accounting, energy monitoring and waste management while identifying potential cost savings." },
      { "name": "Revalue", "website": "https://revalue.eco/", "description": "Software platform that helps industrial companies determine the most economically attractive second-life route for equipment and components — repair, reconditioning, reuse, dismantling and recycling. Customers currently process more than 100,000 products annually through the platform." },
      { "name": "SoonGo", "website": "https://soongo.co/", "description": "AI-native SaaS platform for managing professional vehicle fleets, centralising data from leasing companies, fuel cards, insurers, telematics and government systems to help operators reduce costs, administrative workload and CO2 emissions." },
      { "name": "SPASH", "website": "https://spash.com/", "description": "Develops connected-video and analytics technology for sports clubs, allowing players and coaches to capture, replay, share and analyse matches and performance data. Used across padel, tennis, five-a-side football and indoor sports." },
      { "name": "Vasco", "website": "https://www.vasco-impact.com", "description": "Finances home renovations without conventional loans or monthly repayments: Vasco funds the work in exchange for a share of the property's value, which the homeowner can later repurchase or settle when the property is sold." },
      { "name": "C-Clerc", "website": "https://c-clerc.fr", "description": "SaaS platform for French notarial offices combining CRM, client communication and marketing automation with AI tools designed for regulated legal workflows." },
      { "name": "Edison IA", "website": "https://edison-ia.fr", "description": "AI deployment platform and services company helping SMEs and mid-sized businesses move from generative-AI experiments into production. Its annual Lightning Program combines executive training, process diagnostics, AI agents connected to company systems, and ROI tracking." }
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
  'funding_deals_september_2026_batch5', NOW(), NOW()
FROM source s
ON CONFLICT (slug) DO UPDATE SET
  website = COALESCE(organizations.website, EXCLUDED.website),
  description = COALESCE(organizations.description, EXCLUDED.description),
  updated_at = NOW();

-- =============================================================================
-- Step 1b: Link organizations to cities
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      { "org_name": "Inbolt", "city": "Paris" },
      { "org_name": "Rayon", "city": "Paris" },
      { "org_name": "Marble (Checkmarble)", "city": "Paris" },
      { "org_name": "Shadow Santé", "city": "Sophia Antipolis" },
      { "org_name": "Revalue", "city": "Grenoble" },
      { "org_name": "SoonGo", "city": "Nantes" },
      { "org_name": "SPASH", "city": "Lyon" },
      { "org_name": "Vasco", "city": "Bordeaux" },
      { "org_name": "C-Clerc", "city": "Neuilly-sur-Seine" },
      { "org_name": "Edison IA", "city": "Nantes" }
]$json$
  ) AS (org_name TEXT, city TEXT)
)
UPDATE organizations o SET city_id = COALESCE(o.city_id, c1.id), updated_at = NOW()
FROM source s
LEFT JOIN cities c1 ON c1.slug = lower(regexp_replace(regexp_replace(unaccent(s.city), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g'))
WHERE o.slug = lower(regexp_replace(regexp_replace(unaccent(s.org_name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g'));

-- =============================================================================
-- Step 2: Create funding rounds (10)
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      { "name": "Inbolt", "stage": "series_b", "amount_eur": 11.0, "announced_date": "2026-09-30", "notes": "€11M Series B, bringing disclosed total funding to €30M, to expand in the U.S. and Asia-Pacific and enter data-center and electronics-manufacturing markets. Deployed on 200+ robots in 100+ factories; customers incl. Bosch, Beko, Flex, Ford, Stellantis, Toyota. Investors: Shift4Good, Bridges Climate Transition Partners, BNP Paribas Développement, Ora Global. Attached to the existing 'InBolt' org. Source: Shift4Good." },
      { "name": "Rayon", "stage": "series_a", "amount_eur": 10.0, "announced_date": "2026-09-29", "notes": "€10M Series A to launch 3D capabilities, embed more AI into its design workflow and scale go-to-market. 4M+ drawings created; total funding ~€16M after a €4M seed (2023) and an earlier pre-seed. Investors: Partech, Northzone, Foundamental, Seedcamp. Startup SIREN 903538403 (not the unrelated RAYON 899993018). Source: Partech, Tech.eu." },
      { "name": "Marble (Checkmarble)", "stage": "series_a", "amount_eur": 6.5, "announced_date": "2026-09-29", "notes": "€6.5M Series A, total funding to €9M. Open-source fraud/financial-crime compliance infrastructure; in production at 100+ institutions across 25+ countries, ~70% of customers outside France. Funds AI in compliance workflows and on-prem deployments. Investors: Smartfin, ADNEXUS, Passion Capital, 42Capital, Hexa. Legal entity MARBLE SAS (checkmarble.com); recorded as a separate org from the unrelated 'marble' (marble.studio). Source: The French Tech Journal." },
      { "name": "Shadow Santé", "stage": "seed", "amount_eur": 2.5, "announced_date": "2026-09-07", "notes": "€2.5M seed to raise its rollout rate from ~10 to 50 new healthcare establishments/month in 2027 and expand internationally (Canada, UK). ~300 customers / 2,000+ sites. Environmental-management platform for hospitals. Investors: Good Only Ventures, Impact Seed Ventures, Caisse d'Épargne Côte d'Azur, Provence Angels, Paris Business Angels, Angels Santé. Legal entity SHADOW (distinct from shadow.tech). Source: LinkedIn." },
      { "name": "Revalue", "stage": "seed", "amount_eur": 2.2, "announced_date": "2026-09-28", "notes": "€2.2M seed led by Asterion Ventures (with Hoji Ventures, Kima Ventures). Founded 2025 with Lyon studio Hoji; AI-powered circularity platform for industrial after-sales/maintenance (second-life routing). Source: Le Dauphiné Libéré." },
      { "name": "SoonGo", "stage": "seed", "amount_eur": 2.2, "announced_date": "2026-09-30", "notes": "€2.2M seed to expand sales, invest in R&D and add AI capabilities. 30+ customers, 10,000 vehicles under management, targeting 100,000 within three years. AI-native fleet-management SaaS. Investors: GO Capital, Station F, Jean-Marc Gonon, Business Angels. Source: Societe.Tech, Journal Auto." },
      { "name": "SPASH", "stage": "series_a", "amount_eur": 2.0, "announced_date": "2026-09-25", "notes": "€2M Series A (completed at the beginning of summer) to accelerate AI development, expand teams and grow internationally (Italy, Benelux, UK, German-speaking Europe). Operates in 20+ countries. Connected-video/analytics for sports. Legal entity NGTV EXPERIENCE (SIREN 821548468); attached to the existing 'spash' org. (Possible separate April 2026 €2.3M round flagged for review.) Source: Presse Agence." },
      { "name": "Vasco", "stage": "seed", "amount_eur": 1.7, "announced_date": "2026-09-30", "notes": "€1.7M seed to hire, automate processes and expand its renovation-financing model (home renovation funded for a share of property value), targeting 1,000 financed renovations/year by 2030. Separate from the ~€4M contributed by savers to Vasco's solidarity property vehicle (not counted as startup funding). Investors: Aquiti, makesense. Source: Fusacq, MonImmeuble." },
      { "name": "C-Clerc", "stage": "seed", "amount_eur": 1.2, "announced_date": "2026-09-30", "notes": "€1.2M from ADNEXUS to accelerate its product roadmap and commercial deployment. Used by ~500 notarial offices, approaching €2M ARR under two years after launch. SaaS + AI for French notarial offices. Source: Presse Agence." },
      { "name": "Edison IA", "stage": "seed", "amount_eur": 1.0, "announced_date": "2026-09-29", "notes": "First €1M seed to expand from its Grand Ouest base across France, recruit, and broaden its AI-agent catalog. Founded December 2025; targets 50-5,000-employee businesses; flagship Lightning Program at €50,000/year with a six-month ROI stop clause. Investors: Go Capital, CIC Ouest, Bpifrance. Legal entity SAS EDISON IA. Source: LinkedIn, FrenchWeb." }
]$json$
  ) AS (name TEXT, stage TEXT, amount_eur NUMERIC, announced_date TEXT, notes TEXT)
)
INSERT INTO funding_rounds (
  id, organization_id, stage, amount_eur, currency_original, amount_original,
  announced_date, is_estimated, is_verified, source_name, notes, created_at
)
SELECT
  uuid_generate_v4(), o.id, s.stage::funding_stage, s.amount_eur, 'EUR', (s.amount_eur*1000000)::NUMERIC,
  s.announced_date::DATE, FALSE, FALSE, 'funding_deals_september_2026_batch5', s.notes, NOW()
FROM source s
JOIN organizations o ON o.slug = lower(regexp_replace(regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g'));

-- =============================================================================
-- Step 3a: Create investor organizations (idempotent)
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      {"name":"Shift4Good"},{"name":"Bridges Climate Transition Partners"},{"name":"BNP Paribas Développement"},{"name":"Ora Global"},
      {"name":"Partech"},{"name":"Northzone"},{"name":"Foundamental"},{"name":"Seedcamp"},
      {"name":"Smartfin"},{"name":"ADNEXUS"},{"name":"Passion Capital"},{"name":"42Capital"},{"name":"Hexa"},
      {"name":"Good Only Ventures"},{"name":"Impact Seed Ventures"},{"name":"Caisse d'Épargne Côte d'Azur"},{"name":"Provence Angels"},{"name":"Paris Business Angels"},{"name":"Angels Santé"},
      {"name":"Asterion Ventures"},{"name":"Hoji Ventures"},{"name":"Kima Ventures"},
      {"name":"GO Capital"},{"name":"Station F"},{"name":"Jean-Marc Gonon"},{"name":"Business Angels"},
      {"name":"Vessoa Invest"},{"name":"GO Ventures"},{"name":"CoopVenture"},
      {"name":"Aquiti"},{"name":"makesense"},
      {"name":"CIC Ouest"},{"name":"Bpifrance"}
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
  'funding_deals_september_2026_batch5', NOW(), NOW()
FROM source s
ON CONFLICT (slug) DO NOTHING;

-- =============================================================================
-- Step 3b: Create funding round investors (joined on org + source)
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      {"org_name":"Inbolt","investor_name":"Shift4Good","is_lead":false},
      {"org_name":"Inbolt","investor_name":"Bridges Climate Transition Partners","is_lead":false},
      {"org_name":"Inbolt","investor_name":"BNP Paribas Développement","is_lead":false},
      {"org_name":"Inbolt","investor_name":"Ora Global","is_lead":false},
      {"org_name":"Rayon","investor_name":"Partech","is_lead":false},
      {"org_name":"Rayon","investor_name":"Northzone","is_lead":false},
      {"org_name":"Rayon","investor_name":"Foundamental","is_lead":false},
      {"org_name":"Rayon","investor_name":"Seedcamp","is_lead":false},
      {"org_name":"Marble (Checkmarble)","investor_name":"Smartfin","is_lead":false},
      {"org_name":"Marble (Checkmarble)","investor_name":"ADNEXUS","is_lead":false},
      {"org_name":"Marble (Checkmarble)","investor_name":"Passion Capital","is_lead":false},
      {"org_name":"Marble (Checkmarble)","investor_name":"42Capital","is_lead":false},
      {"org_name":"Marble (Checkmarble)","investor_name":"Hexa","is_lead":false},
      {"org_name":"Shadow Santé","investor_name":"Good Only Ventures","is_lead":false},
      {"org_name":"Shadow Santé","investor_name":"Impact Seed Ventures","is_lead":false},
      {"org_name":"Shadow Santé","investor_name":"Caisse d'Épargne Côte d'Azur","is_lead":false},
      {"org_name":"Shadow Santé","investor_name":"Provence Angels","is_lead":false},
      {"org_name":"Shadow Santé","investor_name":"Paris Business Angels","is_lead":false},
      {"org_name":"Shadow Santé","investor_name":"Angels Santé","is_lead":false},
      {"org_name":"Revalue","investor_name":"Asterion Ventures","is_lead":true},
      {"org_name":"Revalue","investor_name":"Hoji Ventures","is_lead":false},
      {"org_name":"Revalue","investor_name":"Kima Ventures","is_lead":false},
      {"org_name":"SoonGo","investor_name":"GO Capital","is_lead":false},
      {"org_name":"SoonGo","investor_name":"Station F","is_lead":false},
      {"org_name":"SoonGo","investor_name":"Jean-Marc Gonon","is_lead":false},
      {"org_name":"SoonGo","investor_name":"Business Angels","is_lead":false},
      {"org_name":"SPASH","investor_name":"Vessoa Invest","is_lead":false},
      {"org_name":"SPASH","investor_name":"GO Ventures","is_lead":false},
      {"org_name":"SPASH","investor_name":"CoopVenture","is_lead":false},
      {"org_name":"Vasco","investor_name":"Aquiti","is_lead":false},
      {"org_name":"Vasco","investor_name":"makesense","is_lead":false},
      {"org_name":"C-Clerc","investor_name":"ADNEXUS","is_lead":false},
      {"org_name":"Edison IA","investor_name":"GO Capital","is_lead":false},
      {"org_name":"Edison IA","investor_name":"CIC Ouest","is_lead":false},
      {"org_name":"Edison IA","investor_name":"Bpifrance","is_lead":false}
]$json$
  ) AS (org_name TEXT, investor_name TEXT, is_lead BOOLEAN)
)
INSERT INTO funding_round_investors (
  id, funding_round_id, investor_id, is_lead, investor_name, created_at
)
SELECT
  uuid_generate_v4(), fr.id, inv.id, s.is_lead, s.investor_name, NOW()
FROM source s
JOIN organizations o ON o.slug = lower(regexp_replace(regexp_replace(unaccent(s.org_name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g'))
JOIN organizations inv ON inv.slug = lower(regexp_replace(regexp_replace(unaccent(s.investor_name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g'))
JOIN funding_rounds fr ON fr.organization_id = o.id AND fr.source_name = 'funding_deals_september_2026_batch5'
WHERE NOT EXISTS (
  SELECT 1 FROM funding_round_investors x WHERE x.funding_round_id = fr.id AND x.investor_id = inv.id
);

-- =============================================================================
-- Step 4: Link organizations to sectors
-- =============================================================================
-- Step 4a: insert all org-sector links as non-primary (idempotent)
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      {"org":"inbolt","sec":"artificial-intelligence"},{"org":"inbolt","sec":"robotics"},
      {"org":"rayon","sec":"saas"},{"org":"rayon","sec":"artificial-intelligence"},{"org":"rayon","sec":"proptech"},
      {"org":"marble-checkmarble","sec":"fintech"},{"org":"marble-checkmarble","sec":"regtech"},{"org":"marble-checkmarble","sec":"artificial-intelligence"},
      {"org":"shadow-sante","sec":"healthtech"},{"org":"shadow-sante","sec":"climatetech"},
      {"org":"revalue","sec":"artificial-intelligence"},{"org":"revalue","sec":"saas"},
      {"org":"soongo","sec":"saas"},{"org":"soongo","sec":"artificial-intelligence"},{"org":"soongo","sec":"mobility"},{"org":"soongo","sec":"climatetech"},
      {"org":"spash","sec":"sportstech"},{"org":"spash","sec":"artificial-intelligence"},{"org":"spash","sec":"saas"},
      {"org":"vasco","sec":"climatetech"},{"org":"vasco","sec":"fintech"},{"org":"vasco","sec":"proptech"},
      {"org":"c-clerc","sec":"legaltech"},{"org":"c-clerc","sec":"artificial-intelligence"},{"org":"c-clerc","sec":"saas"},
      {"org":"edison-ia","sec":"artificial-intelligence"},{"org":"edison-ia","sec":"saas"}
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
      {"org":"inbolt","sec":"artificial-intelligence"},{"org":"rayon","sec":"saas"},{"org":"marble-checkmarble","sec":"fintech"},
      {"org":"shadow-sante","sec":"healthtech"},{"org":"revalue","sec":"artificial-intelligence"},{"org":"soongo","sec":"saas"},
      {"org":"spash","sec":"sportstech"},{"org":"vasco","sec":"climatetech"},{"org":"c-clerc","sec":"legaltech"},{"org":"edison-ia","sec":"artificial-intelligence"}
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
-- Step 5: Create people records for founders
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      {"full_name":"Rudy Cohen","first_name":"Rudy","last_name":"Cohen"},
      {"full_name":"Albane Dersy","first_name":"Albane","last_name":"Dersy"},
      {"full_name":"Louis Dumas","first_name":"Louis","last_name":"Dumas"},
      {"full_name":"Bastien Dolla","first_name":"Bastien","last_name":"Dolla"},
      {"full_name":"Stanislas Chaillou","first_name":"Stanislas","last_name":"Chaillou"},
      {"full_name":"Arnaud Schwartz","first_name":"Arnaud","last_name":"Schwartz"},
      {"full_name":"Pascal Delange","first_name":"Pascal","last_name":"Delange"},
      {"full_name":"Alexis Patissier","first_name":"Alexis","last_name":"Patissier"},
      {"full_name":"Charles Souillard","first_name":"Charles","last_name":"Souillard"},
      {"full_name":"François-Joseph Bouyer","first_name":"François-Joseph","last_name":"Bouyer"},
      {"full_name":"François Aspe","first_name":"François","last_name":"Aspe"},
      {"full_name":"Matthieu Glotz","first_name":"Matthieu","last_name":"Glotz"},
      {"full_name":"Guillaume Noé","first_name":"Guillaume","last_name":"Noé"},
      {"full_name":"Tristan Vernay","first_name":"Tristan","last_name":"Vernay"},
      {"full_name":"Sébastien Prot","first_name":"Sébastien","last_name":"Prot"},
      {"full_name":"Mathieu Guerchoux","first_name":"Mathieu","last_name":"Guerchoux"},
      {"full_name":"Hervé Degreve","first_name":"Hervé","last_name":"Degreve"},
      {"full_name":"Leah Benguigui","first_name":"Leah","last_name":"Benguigui"},
      {"full_name":"Jacques Claire-Sagot","first_name":"Jacques","last_name":"Claire-Sagot"},
      {"full_name":"Clément Couadou","first_name":"Clément","last_name":"Couadou"},
      {"full_name":"Anaïs Vivion","first_name":"Anaïs","last_name":"Vivion"},
      {"full_name":"Julien Hervouët","first_name":"Julien","last_name":"Hervouët"}
]$json$
  ) AS (full_name TEXT, first_name TEXT, last_name TEXT)
)
INSERT INTO people (
  id, full_name, slug, first_name, last_name, legacy_source, created_at
)
SELECT
  uuid_generate_v4(), s.full_name,
  lower(regexp_replace(regexp_replace(unaccent(s.full_name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g')),
  s.first_name, s.last_name, 'funding_deals_september_2026_batch5', NOW()
FROM source s
ON CONFLICT (slug) DO NOTHING;

-- =============================================================================
-- Step 6: Link founders to organizations
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      {"org_name":"Inbolt","founder_name":"Rudy Cohen"},
      {"org_name":"Inbolt","founder_name":"Albane Dersy"},
      {"org_name":"Inbolt","founder_name":"Louis Dumas"},
      {"org_name":"Rayon","founder_name":"Bastien Dolla"},
      {"org_name":"Rayon","founder_name":"Stanislas Chaillou"},
      {"org_name":"Marble (Checkmarble)","founder_name":"Arnaud Schwartz"},
      {"org_name":"Marble (Checkmarble)","founder_name":"Pascal Delange"},
      {"org_name":"Shadow Santé","founder_name":"Alexis Patissier"},
      {"org_name":"Revalue","founder_name":"Charles Souillard"},
      {"org_name":"SoonGo","founder_name":"François-Joseph Bouyer"},
      {"org_name":"SoonGo","founder_name":"François Aspe"},
      {"org_name":"SoonGo","founder_name":"Matthieu Glotz"},
      {"org_name":"SPASH","founder_name":"Guillaume Noé"},
      {"org_name":"SPASH","founder_name":"Tristan Vernay"},
      {"org_name":"Vasco","founder_name":"Sébastien Prot"},
      {"org_name":"Vasco","founder_name":"Mathieu Guerchoux"},
      {"org_name":"Vasco","founder_name":"Hervé Degreve"},
      {"org_name":"C-Clerc","founder_name":"Leah Benguigui"},
      {"org_name":"C-Clerc","founder_name":"Jacques Claire-Sagot"},
      {"org_name":"C-Clerc","founder_name":"Clément Couadou"},
      {"org_name":"Edison IA","founder_name":"Anaïs Vivion"},
      {"org_name":"Edison IA","founder_name":"Julien Hervouët"}
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
-- Step 7: Attach SIREN legal entities (French). Idempotent -- Inbolt and Rayon
-- already carry their SIREN and are skipped.
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      {"org":"inbolt","legal_name":"INBOLT","siren":"853337665"},
      {"org":"rayon","legal_name":"RAYON","siren":"903538403"},
      {"org":"marble-checkmarble","legal_name":"MARBLE SAS","siren":"922444674"},
      {"org":"shadow-sante","legal_name":"SHADOW","siren":"921919932"},
      {"org":"revalue","legal_name":"REVALUE","siren":"988937066"},
      {"org":"soongo","legal_name":"SOONGO","siren":"981327091"},
      {"org":"spash","legal_name":"NGTV EXPERIENCE","siren":"821548468"},
      {"org":"vasco","legal_name":"VASCO","siren":"978280923"},
      {"org":"c-clerc","legal_name":"C-CLERC","siren":"949182737"},
      {"org":"edison-ia","legal_name":"SAS EDISON IA","siren":"994690535"}
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
FROM funding_rounds WHERE source_name = 'funding_deals_september_2026_batch5'
UNION ALL
SELECT 'Investor Links', COUNT(*)
FROM funding_round_investors fri JOIN funding_rounds fr ON fr.id = fri.funding_round_id
WHERE fr.source_name = 'funding_deals_september_2026_batch5'
UNION ALL
SELECT 'Founder People (new)', COUNT(*)
FROM people WHERE legacy_source = 'funding_deals_september_2026_batch5';
