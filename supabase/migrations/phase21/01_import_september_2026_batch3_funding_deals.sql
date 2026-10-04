-- =============================================================================
-- September 2026 Funding Deals Import — Batch 3
-- =============================================================================
-- 15 deals. source_name 'funding_deals_september_2026_batch3'. Amounts in millions.
--
-- 11 NEW organizations: Delos, Opio, Laboratoires üma, Armageddon, Kompa,
--   Wasoria, Bravi, AbTx, Fronterra, Switch, Simaptic.
-- 4 EXISTING organizations get a new, distinct round: Kaiko, Hackuity, Everimpact,
--   and Treewater — which exists as 'Tree Water SAS' (slug tree-water-sas) and is
--   referenced by that existing name so no duplicate org is created.
--
-- Corrections applied per the source's verification table:
--   * Simaptic: announced 2026-07-07 (NOT September) — a July seed.
--   * Kompa: SIREN 104993159 (the May-2026 Anglet entity), not the older 922165741.
--   * Wasoria 2026-09-04; Kaiko 2026-09-14; Treewater public date 2026-09-18.
--
-- Notes:
--   * USD raises (Hackuity $19M, Bravi $1.8M, Fronterra $1.1M, Everimpact $150k)
--     store amount_eur as a converted estimate (is_estimated=TRUE).
--   * Switch is an undisclosed stake acquisition by Fétis Group (amount_eur NULL).
--   * Dual-HQ: Kaiko (New York primary / Paris secondary), Fronterra (Marseille /
--     Cusco, Peru). New York added as a US city, Cusco as a Peru city. Org country
--     kept 'France' (French-tech tracker; French entity).
--   * Legal entities differ from brand for several: Kaiko=CHALLENGER DEEP SAS
--     (already attached), Delos=DELOS INTELLIGENCE, Armageddon=AAIS - ARMAGEDDON
--     ARTIFICIAL INTELLIGENCE SECURITY, Fronterra=AMA PACHA, Treewater=TREE WATER.
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "unaccent";

ALTER TABLE organizations
  ADD COLUMN IF NOT EXISTS secondary_city_id UUID REFERENCES cities(id) ON DELETE SET NULL;

-- =============================================================================
-- Step 0: Ensure cities exist (New York, Cholet, Cusco, Plabennec are new)
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      { "name": "New York", "country": "USA" },
      { "name": "Paris", "country": "France" },
      { "name": "Lyon", "country": "France" },
      { "name": "Anglet", "country": "France" },
      { "name": "Le Creusot", "country": "France" },
      { "name": "Cholet", "country": "France" },
      { "name": "Dijon", "country": "France" },
      { "name": "Marseille", "country": "France" },
      { "name": "Cusco", "country": "Peru" },
      { "name": "Vannes", "country": "France" },
      { "name": "Loos", "country": "France" },
      { "name": "Plabennec", "country": "France" }
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
  (uuid_generate_v4(), 'FemTech', 'femtech', NOW(), NOW()),
  (uuid_generate_v4(), 'WaterTech', 'watertech', NOW(), NOW())
ON CONFLICT (slug) DO NOTHING;

-- =============================================================================
-- Step 1: Create organizations (new; existing upserted, names preserved)
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      { "name": "Kaiko", "website": "https://www.kaiko.com/", "description": "Provides regulated institutional-grade market data, analytics, indices, and infrastructure for digital-asset and tokenized markets." },
      { "name": "Hackuity", "website": "https://www.hackuity.ai", "description": "AI-powered platform that consolidates security findings, prioritizes vulnerabilities by business risk, and coordinates remediation across enterprise teams." },
      { "name": "Delos", "website": "https://www.delos.so/", "description": "Develops autonomous AI workers capable of handling continuing business processes such as prospecting, CRM administration, and back-office operations." },
      { "name": "Opio", "website": "https://www.opio.fi/", "description": "AI-native platform that collects, verifies, and structures financial information for transaction services and financial due diligence teams." },
      { "name": "Laboratoires üma", "website": "https://umawell.fr/", "description": "French women's health company developing natural, hormone-free supplements designed to address symptoms associated with perimenopause, menopause, and post-menopause." },
      { "name": "Armageddon", "website": "https://www.aais.ai", "description": "Lyon-based cybersecurity startup developing a sovereign SaaS platform that measures and improves employees' cybersecurity maturity through awareness, training, and simulated attacks. Formerly AAIS (Armageddon Artificial Intelligence Security)." },
      { "name": "Tree Water SAS", "website": "https://www.treewater.fr", "description": "French WaterTech company (Treewater) developing advanced oxidation systems to destroy pollutants and micropollutants in industrial wastewater, groundwater, and contaminated soils. Also developing technology targeting PFAS, reporting removal rates above 99% for some of the most common compounds." },
      { "name": "Kompa", "website": "https://kompa.pro", "description": "Develops business-management software for tradespeople and small construction companies, combining quotations, invoicing, CRM, scheduling, and accounting workflows." },
      { "name": "Wasoria", "website": "https://wasoria.fr", "description": "Le Creusot-based startup developing AI-powered industrial vision systems for waste-sorting centers. Its connected portals continuously analyze material flows to detect dangerous objects such as lithium batteries and gas or nitrous oxide cylinders, monitor sorting quality, and provide operators with actionable performance data." },
      { "name": "Bravi", "website": "https://bravi.app", "description": "AI platform for manufacturers and home-improvement companies that gives field sales, installation, and support teams instant, sourced answers to technical questions, helps configure complex products, and can generate quotes in seconds." },
      { "name": "AbTx", "website": "https://www.abtx-bio.com", "description": "Dijon-based biotech developing miniaturized antibody-drug conjugates, called Fragment Drug Conjugates (FDCs), for solid tumors including pancreatic cancer. Its patented Therano-Stick enzymatic bioconjugation platform aims to improve tumor penetration and reduce off-target exposure compared with conventional ADCs." },
      { "name": "Fronterra", "website": "https://fronterra.eco/", "description": "Franco-Peruvian developer of community-based nature restoration and conservation projects spanning reforestation, agroforestry, forest conservation, and biodiversity, with projects designed to generate carbon and nature credits." },
      { "name": "Switch", "website": "https://switchsas.fr/", "description": "Vannes-based startup designing and integrating electric and hybrid propulsion, onboard energy storage, and energy-management systems for professional vessels, including both new-build and retrofit projects." },
      { "name": "Simaptic", "website": "https://simaptic.com/", "description": "Develops immersive medical training technology that transforms basic training mannequins into high-fidelity simulators, making hands-on healthcare education more accessible and affordable." },
      { "name": "Everimpact", "website": "https://www.everimpact.com/", "description": "Measures greenhouse-gas emissions using satellite imagery, ground sensors, and AI, helping cities and businesses identify reductions and access climate finance." }
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
  'funding_deals_september_2026_batch3', NOW(), NOW()
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
      { "org_name": "Kaiko", "city": "New York", "secondary_city": "Paris" },
      { "org_name": "Hackuity", "city": "Lyon", "secondary_city": null },
      { "org_name": "Delos", "city": "Paris", "secondary_city": null },
      { "org_name": "Opio", "city": "Paris", "secondary_city": null },
      { "org_name": "Laboratoires üma", "city": "Lyon", "secondary_city": null },
      { "org_name": "Armageddon", "city": "Lyon", "secondary_city": null },
      { "org_name": "Tree Water SAS", "city": "Lyon", "secondary_city": null },
      { "org_name": "Kompa", "city": "Anglet", "secondary_city": null },
      { "org_name": "Wasoria", "city": "Le Creusot", "secondary_city": null },
      { "org_name": "Bravi", "city": "Cholet", "secondary_city": null },
      { "org_name": "AbTx", "city": "Dijon", "secondary_city": null },
      { "org_name": "Fronterra", "city": "Marseille", "secondary_city": "Cusco" },
      { "org_name": "Switch", "city": "Vannes", "secondary_city": null },
      { "org_name": "Simaptic", "city": "Loos", "secondary_city": null },
      { "org_name": "Everimpact", "city": "Plabennec", "secondary_city": null }
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
-- Step 2: Create funding rounds (15)
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      { "name": "Kaiko", "stage": "series_b", "amount_eur": 49.0, "currency_original": "EUR", "amount_original": 49000000, "announced_date": "2026-09-14", "notes": "€49M Series B extension bringing Kaiko's June 2022 Series B to $110M (original Series B was $53M). Strengthens its core data business and infrastructure for tokenized, continuously traded markets. Investors incl. S&P Global, BNP Paribas, Bpifrance, Broadridge, Canton Foundation, Coinbase Ventures, DRW VC, Nasdaq Ventures, Royal Bank of Canada, Stellar, Susquehanna, Anthemis, Point Nine, Revaia. Legal entity CHALLENGER DEEP SAS. Dual HQ New York / Paris. Source: Kaiko, S&P Global." },
      { "name": "Hackuity", "stage": "series_b", "amount_eur": 16.34, "currency_original": "USD", "amount_original": 19000000, "announced_date": "2026-09-16", "notes": "$19M (~€16.3M est.) Series B (recorded as raised in July), total funding to $38M, to finance product development, AI capabilities and expansion across Europe and Asia. Investors: Forgepoint Capital International, Bright Pixel, Bpifrance, Seventure Partners. Source: Company announcement, Axios." },
      { "name": "Delos", "stage": "series_a", "amount_eur": 10.0, "currency_original": "EUR", "amount_original": 10000000, "announced_date": "2026-09-16", "notes": "€10M Series A from Bpifrance, C4 Ventures and Founders Future to expand its commercial team, develop specialized AI-worker roles and accelerate deployment in France and the US. Legal entity DELOS INTELLIGENCE. Source: Maddyness, Journal du Net." },
      { "name": "Opio", "stage": "seed", "amount_eur": 4.0, "currency_original": "EUR", "amount_original": 4000000, "announced_date": "2026-09-16", "notes": "€4M seed from Frst, Seedcamp, Global Founders Capital and angels (Arthur Waller, Stanislas Polu) to recruit engineers, expand in the UK and Germany, and broaden from transaction due diligence into statutory auditing. Source: Tech.eu, Tech Funding News." },
      { "name": "Laboratoires üma", "stage": "seed", "amount_eur": 4.0, "currency_original": "EUR", "amount_original": 4000000, "announced_date": "2026-09-18", "notes": "€4M seed from The Moon Venture, Le DealClub, Ring Capital and Kima Ventures to accelerate growth, expand its product range and strengthen its position in menopause care. Natural, hormone-free products for peri/menopause. Legal entity LABORATOIRES UMA. Source: ProYarn." },
      { "name": "Armageddon", "stage": "seed", "amount_eur": 2.2, "currency_original": "EUR", "amount_original": 2200000, "announced_date": "2026-09-25", "notes": "€2.2M seed (formerly AAIS) from Generis Capital Partners, Pascal Houillon and Leo Gonzales to accelerate growth and expand its team. Founded 2023; 600+ customers and 1M+ users across 17 countries. Legal entity AAIS - ARMAGEDDON ARTIFICIAL INTELLIGENCE SECURITY. Source: LinkedIn." },
      { "name": "Tree Water SAS", "stage": "seed", "amount_eur": 2.0, "currency_original": "EUR", "amount_original": 2000000, "announced_date": "2026-09-18", "notes": "First €2M round (Treewater) from Family Offices to move to industrial scale at a new 2,800 sqm facility in Rovaltain (near Valence). Founded 2017; advanced oxidation water treatment, expanding to PFAS. Capacity expected to suffice through 2028-2029; a second round planned by end-2027. Public announcement date 2026-09-18 (capital increase implemented earlier, in July). Source: Les Echos." },
      { "name": "Kompa", "stage": "pre_seed", "amount_eur": 1.5, "currency_original": "EUR", "amount_original": 1500000, "announced_date": "2026-09-10", "notes": "€1.5M pre-seed from WeLoveFounders, Imagination Machine and Super Capital for its AI business-management software for tradespeople and small construction firms. Entity founded May 2026 in Anglet (SIREN 104993159). Source: Startup EU." },
      { "name": "Wasoria", "stage": "seed", "amount_eur": 1.5, "currency_original": "EUR", "amount_original": 1500000, "announced_date": "2026-09-04", "notes": "~€1.5M seed from Business Angels de Bourgogne-Franche-Comté for commercial expansion and AI R&D. AI vision for waste-sorting centers; 36 portals across 5 French centers, 10 more planned in 2026. €215K revenue in 2025, aiming to triple. Source: Les Echos." },
      { "name": "Bravi", "stage": "pre_seed", "amount_eur": 1.55, "currency_original": "USD", "amount_original": 1800000, "announced_date": "2026-09-15", "notes": "$1.8M (~€1.55M est.) pre-seed to expand its platform and grow in France and the US. YC F25; ~20 manufacturers/home-improvement customers. Investors: Y Combinator, Rebel Fund, Embedding VC, Deel Ventures, Bpifrance Business Angels, Nicolas Dessaigne, Othman Laraki. Founded May 2025. Source: LinkedIn." },
      { "name": "AbTx", "stage": "seed", "amount_eur": 1.7, "currency_original": "EUR", "amount_original": 1700000, "announced_date": "2026-09-17", "notes": "€1.7M seed to develop its Therano-Stick platform and FDC drug candidates toward preclinical milestones. A-TLAS project won the 2026 i-Lab competition. Investors: Calyseed, Capital Cell, Covalab, Bpifrance, Région Bourgogne-Franche-Comté, Dijon Métropole, i-Lab 2026. Source: FrenchWeb, Genopole." },
      { "name": "Fronterra", "stage": "seed", "amount_eur": 0.95, "currency_original": "USD", "amount_original": 1100000, "announced_date": "2026-09-15", "notes": "$1.1M (~€0.95M est.) combined seed equity (via Lita) plus a zero-coupon project-development facility from the Restoration Seed Capital Facility. Franco-Peruvian nature restoration; advancing four Peru projects (Sumaq Allpa ARR, Sierra del Divisor REDD+). Series A planned 2027. Investors: Christian del Valle, Lita, Restoration Seed Capital. Legal entity AMA PACHA. Dual HQ Marseille / Cusco (Peru). Source: Carbon Herald." },
      { "name": "Switch", "stage": "growth", "amount_eur": null, "currency_original": null, "amount_original": null, "announced_date": "2026-09-15", "notes": "Undisclosed stake acquisition by Fétis Group (through Kinell), adding industrial, engineering and financial resources to scale its electric/hybrid propulsion for professional vessels. Founded 2023; moving from €50K-€200K projects toward €800K-€1M contracts. Source: Marine Business News." },
      { "name": "Simaptic", "stage": "seed", "amount_eur": 0.41, "currency_original": "EUR", "amount_original": 410000, "announced_date": "2026-07-07", "notes": "€410K seed (announced July 7, 2026 — not September) to launch v2 of its solution by end-2026, expand its software platform and accelerate deployment across France and Europe. Immersive medical-training tech; 10+ centers equipped, 2,000+ trained, four patents filed. Investors: Business Angels (Franck Harrold, Nicolas Duriez, Mickael Danvin, Joël Wyon), Bpifrance. Source: LinkedIn." },
      { "name": "Everimpact", "stage": "pre_seed", "amount_eur": 0.13, "currency_original": "USD", "amount_original": 150000, "announced_date": "2026-09-14", "notes": "$150K equity investment via Morgan Stanley Inclusive & Sustainable Ventures' five-month global impact accelerator (mentoring, workspace, network). GHG measurement via satellite, ground sensors and AI. Source: Morgan Stanley." }
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
  FALSE, 'funding_deals_september_2026_batch3', s.notes, NOW()
FROM source s
JOIN organizations o ON o.slug = lower(regexp_replace(regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g'));

-- =============================================================================
-- Step 3a: Create investor organizations (idempotent)
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      {"name":"S&P Global"},{"name":"BNP Paribas"},{"name":"Bpifrance"},{"name":"Broadridge"},{"name":"Canton Foundation"},{"name":"Coinbase Ventures"},{"name":"DRW Venture Capital"},{"name":"Nasdaq Ventures"},{"name":"Royal Bank of Canada"},{"name":"Stellar"},{"name":"Susquehanna"},{"name":"Anthemis"},{"name":"Point Nine"},{"name":"Revaia"},
      {"name":"Forgepoint Capital International"},{"name":"Bright Pixel"},{"name":"Seventure Partners"},
      {"name":"C4 Ventures"},{"name":"Founders Future"},
      {"name":"Frst"},{"name":"Seedcamp"},{"name":"Global Founders Capital"},{"name":"Business Angels"},{"name":"Arthur Waller"},{"name":"Stanislas Polu"},
      {"name":"The Moon Venture"},{"name":"Le DealClub"},{"name":"Ring Capital"},{"name":"Kima Ventures"},
      {"name":"Generis Capital Partners"},{"name":"Pascal Houillon"},{"name":"Leo Gonzales"},
      {"name":"Family Offices"},
      {"name":"WeLoveFounders"},{"name":"Imagination Machine"},{"name":"Super Capital"},
      {"name":"Business Angels de Bourgogne-Franche-Comté"},
      {"name":"Y Combinator"},{"name":"Rebel Fund"},{"name":"Embedding VC"},{"name":"Deel Ventures"},{"name":"Bpifrance Business Angels"},{"name":"Nicolas Dessaigne"},{"name":"Othman Laraki"},
      {"name":"Calyseed"},{"name":"Capital Cell"},{"name":"Covalab"},{"name":"Région Bourgogne-Franche-Comté"},{"name":"Dijon Métropole"},{"name":"i-Lab 2026"},
      {"name":"Christian del Valle"},{"name":"Lita"},{"name":"Restoration Seed Capital"},
      {"name":"Fétis Group"},
      {"name":"Franck Harrold"},{"name":"Nicolas Duriez"},{"name":"Mickael Danvin"},{"name":"Joël Wyon"},
      {"name":"Morgan Stanley Inclusive & Sustainable Ventures"}
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
  'funding_deals_september_2026_batch3', NOW(), NOW()
FROM source s
ON CONFLICT (slug) DO NOTHING;

-- =============================================================================
-- Step 3b: Create funding round investors (joined on org + source)
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      {"org_name":"Kaiko","investor_name":"S&P Global","is_lead":false},
      {"org_name":"Kaiko","investor_name":"BNP Paribas","is_lead":false},
      {"org_name":"Kaiko","investor_name":"Bpifrance","is_lead":false},
      {"org_name":"Kaiko","investor_name":"Broadridge","is_lead":false},
      {"org_name":"Kaiko","investor_name":"Canton Foundation","is_lead":false},
      {"org_name":"Kaiko","investor_name":"Coinbase Ventures","is_lead":false},
      {"org_name":"Kaiko","investor_name":"DRW Venture Capital","is_lead":false},
      {"org_name":"Kaiko","investor_name":"Nasdaq Ventures","is_lead":false},
      {"org_name":"Kaiko","investor_name":"Royal Bank of Canada","is_lead":false},
      {"org_name":"Kaiko","investor_name":"Stellar","is_lead":false},
      {"org_name":"Kaiko","investor_name":"Susquehanna","is_lead":false},
      {"org_name":"Kaiko","investor_name":"Anthemis","is_lead":false},
      {"org_name":"Kaiko","investor_name":"Point Nine","is_lead":false},
      {"org_name":"Kaiko","investor_name":"Revaia","is_lead":false},
      {"org_name":"Hackuity","investor_name":"Forgepoint Capital International","is_lead":false},
      {"org_name":"Hackuity","investor_name":"Bright Pixel","is_lead":false},
      {"org_name":"Hackuity","investor_name":"Bpifrance","is_lead":false},
      {"org_name":"Hackuity","investor_name":"Seventure Partners","is_lead":false},
      {"org_name":"Delos","investor_name":"Bpifrance","is_lead":false},
      {"org_name":"Delos","investor_name":"C4 Ventures","is_lead":false},
      {"org_name":"Delos","investor_name":"Founders Future","is_lead":false},
      {"org_name":"Opio","investor_name":"Frst","is_lead":false},
      {"org_name":"Opio","investor_name":"Seedcamp","is_lead":false},
      {"org_name":"Opio","investor_name":"Global Founders Capital","is_lead":false},
      {"org_name":"Opio","investor_name":"Business Angels","is_lead":false},
      {"org_name":"Opio","investor_name":"Arthur Waller","is_lead":false},
      {"org_name":"Opio","investor_name":"Stanislas Polu","is_lead":false},
      {"org_name":"Laboratoires üma","investor_name":"The Moon Venture","is_lead":false},
      {"org_name":"Laboratoires üma","investor_name":"Le DealClub","is_lead":false},
      {"org_name":"Laboratoires üma","investor_name":"Ring Capital","is_lead":false},
      {"org_name":"Laboratoires üma","investor_name":"Kima Ventures","is_lead":false},
      {"org_name":"Armageddon","investor_name":"Generis Capital Partners","is_lead":false},
      {"org_name":"Armageddon","investor_name":"Pascal Houillon","is_lead":false},
      {"org_name":"Armageddon","investor_name":"Leo Gonzales","is_lead":false},
      {"org_name":"Tree Water SAS","investor_name":"Family Offices","is_lead":false},
      {"org_name":"Kompa","investor_name":"WeLoveFounders","is_lead":false},
      {"org_name":"Kompa","investor_name":"Imagination Machine","is_lead":false},
      {"org_name":"Kompa","investor_name":"Super Capital","is_lead":false},
      {"org_name":"Wasoria","investor_name":"Business Angels de Bourgogne-Franche-Comté","is_lead":false},
      {"org_name":"Bravi","investor_name":"Y Combinator","is_lead":false},
      {"org_name":"Bravi","investor_name":"Rebel Fund","is_lead":false},
      {"org_name":"Bravi","investor_name":"Embedding VC","is_lead":false},
      {"org_name":"Bravi","investor_name":"Deel Ventures","is_lead":false},
      {"org_name":"Bravi","investor_name":"Bpifrance Business Angels","is_lead":false},
      {"org_name":"Bravi","investor_name":"Nicolas Dessaigne","is_lead":false},
      {"org_name":"Bravi","investor_name":"Othman Laraki","is_lead":false},
      {"org_name":"AbTx","investor_name":"Calyseed","is_lead":false},
      {"org_name":"AbTx","investor_name":"Capital Cell","is_lead":false},
      {"org_name":"AbTx","investor_name":"Covalab","is_lead":false},
      {"org_name":"AbTx","investor_name":"Bpifrance","is_lead":false},
      {"org_name":"AbTx","investor_name":"Région Bourgogne-Franche-Comté","is_lead":false},
      {"org_name":"AbTx","investor_name":"Dijon Métropole","is_lead":false},
      {"org_name":"AbTx","investor_name":"i-Lab 2026","is_lead":false},
      {"org_name":"Fronterra","investor_name":"Christian del Valle","is_lead":false},
      {"org_name":"Fronterra","investor_name":"Lita","is_lead":false},
      {"org_name":"Fronterra","investor_name":"Restoration Seed Capital","is_lead":false},
      {"org_name":"Switch","investor_name":"Fétis Group","is_lead":true},
      {"org_name":"Simaptic","investor_name":"Business Angels","is_lead":false},
      {"org_name":"Simaptic","investor_name":"Franck Harrold","is_lead":false},
      {"org_name":"Simaptic","investor_name":"Nicolas Duriez","is_lead":false},
      {"org_name":"Simaptic","investor_name":"Mickael Danvin","is_lead":false},
      {"org_name":"Simaptic","investor_name":"Joël Wyon","is_lead":false},
      {"org_name":"Simaptic","investor_name":"Bpifrance","is_lead":false},
      {"org_name":"Everimpact","investor_name":"Morgan Stanley Inclusive & Sustainable Ventures","is_lead":false}
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
JOIN funding_rounds fr ON fr.organization_id = o.id AND fr.source_name = 'funding_deals_september_2026_batch3'
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
      {"org":"kaiko","sec":"fintech"},{"org":"kaiko","sec":"web3"},
      {"org":"hackuity","sec":"cybersecurity"},{"org":"hackuity","sec":"saas"},{"org":"hackuity","sec":"artificial-intelligence"},
      {"org":"delos","sec":"artificial-intelligence"},{"org":"delos","sec":"saas"},
      {"org":"opio","sec":"fintech"},{"org":"opio","sec":"artificial-intelligence"},{"org":"opio","sec":"saas"},
      {"org":"laboratoires-uma","sec":"femtech"},{"org":"laboratoires-uma","sec":"healthtech"},
      {"org":"armageddon","sec":"cybersecurity"},{"org":"armageddon","sec":"saas"},{"org":"armageddon","sec":"artificial-intelligence"},
      {"org":"tree-water-sas","sec":"watertech"},{"org":"tree-water-sas","sec":"cleantech"},
      {"org":"kompa","sec":"artificial-intelligence"},{"org":"kompa","sec":"saas"},
      {"org":"wasoria","sec":"deeptech"},{"org":"wasoria","sec":"artificial-intelligence"},{"org":"wasoria","sec":"cleantech"},
      {"org":"bravi","sec":"artificial-intelligence"},{"org":"bravi","sec":"saas"},
      {"org":"abtx","sec":"biotech"},
      {"org":"fronterra","sec":"climatetech"},
      {"org":"switch","sec":"climatetech"},{"org":"switch","sec":"energy"},
      {"org":"simaptic","sec":"healthtech"},{"org":"simaptic","sec":"edtech"},
      {"org":"everimpact","sec":"climatetech"},{"org":"everimpact","sec":"spacetech-aerospace"},{"org":"everimpact","sec":"artificial-intelligence"}
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
      {"org":"kaiko","sec":"fintech"},{"org":"hackuity","sec":"cybersecurity"},{"org":"delos","sec":"artificial-intelligence"},
      {"org":"opio","sec":"fintech"},{"org":"laboratoires-uma","sec":"femtech"},{"org":"armageddon","sec":"cybersecurity"},
      {"org":"tree-water-sas","sec":"watertech"},{"org":"kompa","sec":"artificial-intelligence"},{"org":"wasoria","sec":"deeptech"},
      {"org":"bravi","sec":"artificial-intelligence"},{"org":"abtx","sec":"biotech"},{"org":"fronterra","sec":"climatetech"},
      {"org":"switch","sec":"climatetech"},{"org":"simaptic","sec":"healthtech"},{"org":"everimpact","sec":"climatetech"}
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
      {"full_name":"Pascal Gauthier","first_name":"Pascal","last_name":"Gauthier"},
      {"full_name":"Patrick Ragaru","first_name":"Patrick","last_name":"Ragaru"},
      {"full_name":"Pierre Polette","first_name":"Pierre","last_name":"Polette"},
      {"full_name":"Pierre Samson","first_name":"Pierre","last_name":"Samson"},
      {"full_name":"Wilfrid Blanc","first_name":"Wilfrid","last_name":"Blanc"},
      {"full_name":"Pierre de la Grand'rive","first_name":"Pierre","last_name":"de la Grand'rive"},
      {"full_name":"Thibaut de la Grand'rive","first_name":"Thibaut","last_name":"de la Grand'rive"},
      {"full_name":"Tristan Fulchiron","first_name":"Tristan","last_name":"Fulchiron"},
      {"full_name":"Olivier Chancé","first_name":"Olivier","last_name":"Chancé"},
      {"full_name":"Priscaël Tovolahy-Gauvin","first_name":"Priscaël","last_name":"Tovolahy-Gauvin"},
      {"full_name":"Alexandre Marché","first_name":"Alexandre","last_name":"Marché"},
      {"full_name":"Jeremy Semoun","first_name":"Jeremy","last_name":"Semoun"},
      {"full_name":"Chirag Goyal","first_name":"Chirag","last_name":"Goyal"},
      {"full_name":"Marc-Emmanuel Bouchard","first_name":"Marc-Emmanuel","last_name":"Bouchard"},
      {"full_name":"Pierre Marneffe","first_name":"Pierre","last_name":"Marneffe"},
      {"full_name":"Tristan Daeschner","first_name":"Tristan","last_name":"Daeschner"},
      {"full_name":"Franck Lafontaine","first_name":"Franck","last_name":"Lafontaine"},
      {"full_name":"Anas Bouassami","first_name":"Anas","last_name":"Bouassami"},
      {"full_name":"Pierre-Habté Nouvellon","first_name":"Pierre-Habté","last_name":"Nouvellon"},
      {"full_name":"Meddy El Alaoui","first_name":"Meddy","last_name":"El Alaoui"},
      {"full_name":"Claudine Vermot-Desroches","first_name":"Claudine","last_name":"Vermot-Desroches"},
      {"full_name":"Boris Vuillermoz","first_name":"Boris","last_name":"Vuillermoz"},
      {"full_name":"Juan Carlos González Aybar","first_name":"Juan Carlos","last_name":"González Aybar"},
      {"full_name":"Gildas Olivier","first_name":"Gildas","last_name":"Olivier"},
      {"full_name":"Mehdi Imouloudene","first_name":"Mehdi","last_name":"Imouloudene"},
      {"full_name":"Mathieu Carlier","first_name":"Mathieu","last_name":"Carlier"},
      {"full_name":"Alain Retière","first_name":"Alain","last_name":"Retière"},
      {"full_name":"Jan Mattsson","first_name":"Jan","last_name":"Mattsson"}
]$json$
  ) AS (full_name TEXT, first_name TEXT, last_name TEXT)
)
INSERT INTO people (
  id, full_name, slug, first_name, last_name, legacy_source, created_at
)
SELECT
  uuid_generate_v4(), s.full_name,
  lower(regexp_replace(regexp_replace(unaccent(s.full_name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g')),
  s.first_name, s.last_name, 'funding_deals_september_2026_batch3', NOW()
FROM source s
ON CONFLICT (slug) DO NOTHING;

-- =============================================================================
-- Step 6: Link founders to organizations
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      {"org_name":"Kaiko","founder_name":"Pascal Gauthier"},
      {"org_name":"Hackuity","founder_name":"Patrick Ragaru"},
      {"org_name":"Hackuity","founder_name":"Pierre Polette"},
      {"org_name":"Hackuity","founder_name":"Pierre Samson"},
      {"org_name":"Hackuity","founder_name":"Wilfrid Blanc"},
      {"org_name":"Delos","founder_name":"Pierre de la Grand'rive"},
      {"org_name":"Delos","founder_name":"Thibaut de la Grand'rive"},
      {"org_name":"Opio","founder_name":"Tristan Fulchiron"},
      {"org_name":"Opio","founder_name":"Olivier Chancé"},
      {"org_name":"Laboratoires üma","founder_name":"Priscaël Tovolahy-Gauvin"},
      {"org_name":"Armageddon","founder_name":"Alexandre Marché"},
      {"org_name":"Armageddon","founder_name":"Jeremy Semoun"},
      {"org_name":"Armageddon","founder_name":"Chirag Goyal"},
      {"org_name":"Tree Water SAS","founder_name":"Marc-Emmanuel Bouchard"},
      {"org_name":"Kompa","founder_name":"Pierre Marneffe"},
      {"org_name":"Kompa","founder_name":"Tristan Daeschner"},
      {"org_name":"Wasoria","founder_name":"Franck Lafontaine"},
      {"org_name":"Bravi","founder_name":"Anas Bouassami"},
      {"org_name":"Bravi","founder_name":"Pierre-Habté Nouvellon"},
      {"org_name":"AbTx","founder_name":"Meddy El Alaoui"},
      {"org_name":"AbTx","founder_name":"Claudine Vermot-Desroches"},
      {"org_name":"AbTx","founder_name":"Boris Vuillermoz"},
      {"org_name":"Fronterra","founder_name":"Juan Carlos González Aybar"},
      {"org_name":"Switch","founder_name":"Gildas Olivier"},
      {"org_name":"Simaptic","founder_name":"Mehdi Imouloudene"},
      {"org_name":"Everimpact","founder_name":"Mathieu Carlier"},
      {"org_name":"Everimpact","founder_name":"Alain Retière"},
      {"org_name":"Everimpact","founder_name":"Jan Mattsson"}
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
-- Step 7: Attach SIREN legal entities (French). Idempotent -- Kaiko, Hackuity,
-- Everimpact and Tree Water SAS already carry their SIREN and are skipped.
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      {"org":"kaiko","legal_name":"CHALLENGER DEEP SAS","siren":"807388376"},
      {"org":"hackuity","legal_name":"HACKUITY","siren":"841324577"},
      {"org":"delos","legal_name":"DELOS INTELLIGENCE","siren":"977575612"},
      {"org":"opio","legal_name":"OPIO","siren":"939411641"},
      {"org":"laboratoires-uma","legal_name":"LABORATOIRES UMA","siren":"981407158"},
      {"org":"armageddon","legal_name":"AAIS - ARMAGEDDON ARTIFICIAL INTELLIGENCE SECURITY","siren":"978274058"},
      {"org":"tree-water-sas","legal_name":"TREE WATER","siren":"828379636"},
      {"org":"kompa","legal_name":"KOMPA","siren":"104993159"},
      {"org":"wasoria","legal_name":"WASORIA","siren":"883256414"},
      {"org":"bravi","legal_name":"BRAVI","siren":"942222597"},
      {"org":"abtx","legal_name":"ABTX","siren":"982436883"},
      {"org":"fronterra","legal_name":"AMA PACHA","siren":"983615881"},
      {"org":"switch","legal_name":"SWITCH","siren":"978269819"},
      {"org":"simaptic","legal_name":"SIMAPTIC","siren":"919798009"},
      {"org":"everimpact","legal_name":"EVERIMPACT","siren":"814798971"}
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
FROM funding_rounds WHERE source_name = 'funding_deals_september_2026_batch3'
UNION ALL
SELECT 'Investor Links', COUNT(*)
FROM funding_round_investors fri JOIN funding_rounds fr ON fr.id = fri.funding_round_id
WHERE fr.source_name = 'funding_deals_september_2026_batch3'
UNION ALL
SELECT 'Founder People (new)', COUNT(*)
FROM people WHERE legacy_source = 'funding_deals_september_2026_batch3';
