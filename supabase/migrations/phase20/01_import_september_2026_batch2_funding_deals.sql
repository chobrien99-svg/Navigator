-- =============================================================================
-- September 2026 Funding Deals Import — Batch 2 (Sept 8–14 funding wire)
-- =============================================================================
-- 16 deals. source_name 'funding_deals_september_2026_batch2' (distinct from the
-- earlier 'funding_deals_september_2026' batch). Amounts stored in millions.
--
-- 8 NEW organizations: The Exploration Company, Olenbee, Tellia, Outline,
--   Bob! Desk, ANA Healthcare, OTEO, BlueSecure.
-- 8 EXISTING organizations get a new, distinct round attached: Mistral AI,
--   Implicity, Arlequin AI, Actionable, Ed AI (slug ed-ai), Paradigme, Quiet,
--   V4 Cure (slug v4-cure). Ed.ai and V4Cure are referenced by their existing
--   names ("Ed AI", "V4 Cure") so their existing slugs match (no duplicate org).
--
-- Corrections applied per the source's own verification table:
--   * Actionable: announced as $10M (not €8.5M); stored in USD, amount_eur est.
--   * ANA Healthcare: €2.2M (not €1.8M), announced 2026-09-14.
--   * Paradigme announced 2026-09-08; OTEO 2026-09-02; Bob! Desk 2026-09-07.
--
-- Data caveats (see round notes):
--   * Arlequin AI already carries SIREN 927627034 in the DB; the provided
--     ARLEQUIN SIREN 983592676 is added as a SECOND (non-primary) legal entity,
--     not a replacement — reconcile which is correct.
--   * Foreign-currency raises (Exploration $450M, Actionable $10M, Tellia $5M,
--     Outline $3M) store amount_eur as a converted estimate (is_estimated=TRUE).
--   * Dual-HQ: The Exploration Company (Munich primary / Bordeaux secondary) and
--     Tellia (San Francisco primary / Paris secondary). Munich added as a DE city.
--     Org country kept 'France' (French-tech tracker; French entity + FR office).
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "unaccent";

ALTER TABLE organizations
  ADD COLUMN IF NOT EXISTS secondary_city_id UUID REFERENCES cities(id) ON DELETE SET NULL;

-- =============================================================================
-- Step 0: Ensure cities exist (only Munich is new; rest idempotent)
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      { "name": "Paris", "country": "France" },
      { "name": "Munich", "country": "Germany" },
      { "name": "Bordeaux", "country": "France" },
      { "name": "Rouen", "country": "France" },
      { "name": "San Francisco", "country": "USA" },
      { "name": "Marseille", "country": "France" },
      { "name": "Saint-Cloud", "country": "France" },
      { "name": "Talence", "country": "France" },
      { "name": "Annecy", "country": "France" }
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
  (uuid_generate_v4(), 'Voice AI', 'voice-ai', NOW(), NOW()),
  (uuid_generate_v4(), 'AgTech', 'agtech', NOW(), NOW())
ON CONFLICT (slug) DO NOTHING;

-- =============================================================================
-- Step 1: Create organizations (new; existing upserted, names preserved)
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      { "name": "Mistral AI", "website": "https://mistral.ai/", "description": "Paris-based AI company developing open-weight frontier models, enterprise AI products, and infrastructure. Mistral positions its full-stack platform around sovereign AI, giving enterprises and governments greater control over models, data, compute, and deployment." },
      { "name": "The Exploration Company", "website": "https://www.exploration.space/", "description": "Franco-German space company developing reusable and refillable spacecraft to transport cargo to and from space stations in low-Earth orbit. Its flagship Nyx vehicle is designed to provide Europe and international customers with an independent space transportation capability." },
      { "name": "Implicity", "website": "https://implicity.com/", "description": "Developer of a manufacturer-neutral platform that centralizes data from connected cardiac devices and helps care teams prioritize remote-monitoring alerts, workflows, and billing." },
      { "name": "Arlequin AI", "website": "https://arlq.ai/", "description": "Developer of topological neural-network models and data-analysis software designed to uncover complex relationships across fragmented datasets for government and enterprise users." },
      { "name": "Actionable", "website": "https://actionable.live/", "description": "Predictive customer-experience platform that models enterprise customer journeys and uses AI to identify churn, dissatisfaction, complaints, and repeat-purchase risk across an entire customer base." },
      { "name": "Olenbee", "website": "https://olenbee.com/", "description": "Employee-benefits platform using open banking and AI to identify eligible purchases on employees' personal bank accounts, enabling employers to reimburse meal vouchers, gift vouchers, and other benefits directly." },
      { "name": "Ed AI", "website": "https://ed.ai/", "description": "AI assistant for teachers that pre-corrects student work, identifies individual and class-wide learning gaps, and generates personalized remediation materials." },
      { "name": "Tellia", "website": "https://tellia.com/", "description": "Voice AI platform for agriculture that turns phone calls, voice notes, WhatsApp messages, texts, photos, and emails from field teams into structured operational data. Tellia connects information to the right fields, crops, crews, and operations, and is building an agentic layer that integrates with existing agricultural software." },
      { "name": "Outline", "website": "https://www.outlineapp.ai/", "description": "AI-powered financial-planning platform for SMEs and mid-market companies, connecting accounting, billing, payroll, and sales data so finance teams can build forecasts and scenario simulations in natural language." },
      { "name": "Bob! Desk", "website": "https://bob-desk.fr/", "description": "SaaS platform for managing technical interventions, maintenance requests, and service providers across multi-site property portfolios, retail networks, and other distributed operations. A cloud-based CMMS/GMAO that centralizes tickets, scheduling, communications, and maintenance tracking." },
      { "name": "ANA Healthcare", "website": "https://www.ana-healthcare.com/", "description": "Developer of on-premises clinical data software that collects, structures, and anonymizes hospital clinical and imaging data, turning fragmented health information into research-ready cohorts for hospitals, researchers, and healthcare industry partners." },
      { "name": "V4 Cure", "website": "https://v4cure.com/", "description": "CEA spinout developing synthetic peptide-based treatments for severe kidney and liver-related conditions, led by its preclinical candidate V4C-232." },
      { "name": "Paradigme", "website": "https://paradigme.fr/", "description": "Paris-based second-hand fashion platform combining a B2C marketplace with white-label resale services for fashion brands and retailers. Consumers can trade in clothing for gift cards usable with partner brands, while Paradigme manages resale. It is also developing AI Studio, which automatically generates product imagery and listings for fashion companies." },
      { "name": "Quiet", "website": "https://getquiet.co/", "description": "Manufacturer of noise-reducing tableware for collective catering, combining tempered glass with a patented silicone coating. Quiet says its products cut impact noise by 85% while being lighter, more resistant, and recyclable than conventional ceramic tableware." },
      { "name": "OTEO", "website": "https://www.oteo.care/", "description": "Annecy-based startup helping hospitals deploy and manage Hebergement Temporaire Non Medicalise (HTNM), or hospital hotels. Its platform handles patient eligibility, hotel reservations, administration, and reimbursement, alongside consulting and implementation services for healthcare providers." },
      { "name": "BlueSecure", "website": "https://www.bluesecure.fr/", "description": "Cybersecurity-awareness platform combining interactive training, serious games, and simulated attacks to help employees recognize threats." }
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
  'funding_deals_september_2026_batch2', NOW(), NOW()
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
      { "org_name": "Mistral AI", "city": "Paris", "secondary_city": null },
      { "org_name": "The Exploration Company", "city": "Munich", "secondary_city": "Bordeaux" },
      { "org_name": "Implicity", "city": "Paris", "secondary_city": null },
      { "org_name": "Arlequin AI", "city": "Paris", "secondary_city": null },
      { "org_name": "Actionable", "city": "Paris", "secondary_city": null },
      { "org_name": "Olenbee", "city": "Rouen", "secondary_city": null },
      { "org_name": "Ed AI", "city": "Paris", "secondary_city": null },
      { "org_name": "Tellia", "city": "San Francisco", "secondary_city": "Paris" },
      { "org_name": "Outline", "city": "Paris", "secondary_city": null },
      { "org_name": "Bob! Desk", "city": "Paris", "secondary_city": null },
      { "org_name": "ANA Healthcare", "city": "Marseille", "secondary_city": null },
      { "org_name": "V4 Cure", "city": "Saint-Cloud", "secondary_city": null },
      { "org_name": "Paradigme", "city": "Paris", "secondary_city": null },
      { "org_name": "Quiet", "city": "Talence", "secondary_city": null },
      { "org_name": "OTEO", "city": "Annecy", "secondary_city": null },
      { "org_name": "BlueSecure", "city": "Paris", "secondary_city": null }
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
-- Step 2: Create funding rounds (16)
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      { "name": "Mistral AI", "stage": "series_d", "amount_eur": 3000.0, "currency_original": "EUR", "amount_original": 3000000000, "announced_date": "2026-09-08", "notes": "€3B Series D at a post-money valuation of >€21B — described as the largest equity round ever by a European tech company. Samsung Electronics led; co-leads Scaleup Europe Fund (managed by EQT) and PSG Equity. Funds frontier-model research, compute, infrastructure, commercial growth and international expansion. Operates across 20 countries; 125+ enterprise customers incl. Airbus, ASML, HSBC. Source: The French Tech Journal." },
      { "name": "The Exploration Company", "stage": "series_c", "amount_eur": 387.0, "currency_original": "USD", "amount_original": 450000000, "announced_date": "2026-09-08", "notes": "$450M Series C (~€387M est.), bringing total funding to ~$680M. Co-led by Bessemer Venture Partners, Atomico and Scaleup Europe Fund (managed by EQT). Franco-German; reusable Nyx cargo spacecraft. Founded 2021 by ex-Airbus exec Hélène Huby; offices in the US and UAE. Dual HQ Munich / Bordeaux. Source: Sifted." },
      { "name": "Implicity", "stage": "growth", "amount_eur": 35.0, "currency_original": "EUR", "amount_original": 35000000, "announced_date": "2026-09-09", "notes": "€35M growth equity from IRIS and Five Arrows to expand in the US and build predictive algorithms for cardiac care. Manufacturer-neutral cardiac remote-monitoring platform deployed in 250+ centers across France, Germany and the US, monitoring 120,000+ patients. Source: FrenchWeb, EU-Startups." },
      { "name": "Arlequin AI", "stage": "series_a", "amount_eur": 28.0, "currency_original": "EUR", "amount_original": 28000000, "announced_date": "2026-09-10", "notes": "€28M Series A to expand R&D, train proprietary topological AI models and support deployments; positions itself as a European sovereign alternative to Palantir. Offices in London and Berlin; a Silicon Valley research lab planned. Investors: Redalpine, OTB Ventures, Bpifrance's Fonds Innovation Défense, Vsquared Ventures, 10x Founders, Xavier Niel. NOTE: provided SIREN 983592676 (ARLEQUIN) differs from the DB's existing 927627034; added as a second legal entity. Source: FrenchWeb." },
      { "name": "Actionable", "stage": "seed", "amount_eur": 8.5, "currency_original": "USD", "amount_original": 10000000, "announced_date": "2026-09-09", "notes": "Seed round announced as $10M (~€8.5M) led by Hi Inov with Axeleo Capital. Predictive CX platform mapping the journeys of 117M consumers for clients incl. Carrefour, SNCF, Engie, Edenred. Founded 2024. Source: EU-Startups, Hi Inov." },
      { "name": "Olenbee", "stage": "seed", "amount_eur": 6.46, "currency_original": "EUR", "amount_original": 6460000, "announced_date": "2026-09-08", "notes": "€6.46M seed from Go Capital, Bpifrance, the European Regional Development Fund (ERDF) and business angels to expand R&D and sales and broaden its benefits offering. Open-banking employee-benefits platform; 6,000 users across 260 client companies, targeting 80,000 users by early 2027. Source: Maddyness." },
      { "name": "Ed AI", "stage": "seed", "amount_eur": 5.0, "currency_original": "EUR", "amount_original": 5000000, "announced_date": "2026-09-10", "notes": "€5M seed led by Bpifrance Digital Venture with La Poste Ventures, 50 Partners, AFI Ventures, CentraleSupélec Venture, Ring Capital Generations and Super Capital. AI teacher assistant deployed in 500 French schools; 100,000+ papers processed in six months. Attached to the existing 'Ed AI' organization. Source: Maddyness." },
      { "name": "Tellia", "stage": "pre_seed", "amount_eur": 4.3, "currency_original": "USD", "amount_original": 5000000, "announced_date": "2026-09-08", "notes": "$5M (~€4.3M est.) pre-seed from Revent, Grey Silo Ventures, Jeriko and Fund F to expand its voice-AI/agentic platform in the US and Europe. Deployed across 1M+ acres; customers incl. Campos Brothers Farms, Duckhorn, IFV, Val de Gascogne, KWS Saat. Dual HQ San Francisco / Paris (French entity TELLIA FRANCE). Source: Tellia." },
      { "name": "Outline", "stage": "pre_seed", "amount_eur": 2.58, "currency_original": "USD", "amount_original": 3000000, "announced_date": "2026-09-08", "notes": "$3M (~€2.58M est.) pre-seed led by Founders Future with 100IN, Newschool and angels (Bruno Vaffier, Antoine Lizée, Raphaël Nahum). AI FP&A platform for SMEs/mid-market. Founded June 2026 by two ex-Alan execs; clients incl. Zelty, Shares, HarfangLab. Source: Maddyness, Crowdfund Insider." },
      { "name": "Bob! Desk", "stage": "growth", "amount_eur": 2.5, "currency_original": "EUR", "amount_original": 2500000, "announced_date": "2026-09-07", "notes": "€2.5M financing (incl. €600k debt) combining a minority share buyback and a capital increase, with Cita Investissement. CMMS/GMAO maintenance-management SaaS; grew out of Bob! Dépannage (2015). Legal entity BOB DEPANNAGE. Source: LinkedIn." },
      { "name": "ANA Healthcare", "stage": "series_a", "amount_eur": 2.2, "currency_original": "EUR", "amount_original": 2200000, "announced_date": "2026-09-14", "notes": "€2.2M Series A from Région Sud Investissement, CAAP Création and business angels. On-premises software turning hospital clinical and imaging data into structured, anonymized research cohorts. Founded 2023. (Announced total €2.2M; some databases date it Sept 10.) Source: La Provence, Les Echos." },
      { "name": "V4 Cure", "stage": "seed", "amount_eur": 2.0, "currency_original": "EUR", "amount_original": 2000000, "announced_date": "2026-09-08", "notes": "€2M seed (transaction finalized July 2026) from new business angels and existing investors (identities undisclosed) to fund preclinical and regulatory work for V4C-232. CEA spinout, synthetic peptide therapies for kidney/liver conditions. Attached to the existing 'V4 Cure' organization. Source: PR." },
      { "name": "Paradigme", "stage": "series_a", "amount_eur": 2.0, "currency_original": "EUR", "amount_original": 2000000, "announced_date": "2026-09-08", "notes": "€2M second round to expand its second-hand fashion business, grow its ~50 brand/retail partners and invest in AI Studio (auto-generated product photos/listings). Founded 2022; previously raised €1.2M in 2024. Investors: Hartwood, One Green, Pelintex, Showroomprivé, Business Angels. Legal entity IRMAOS. Source: Fusacq, Dealroom." },
      { "name": "Quiet", "stage": "series_a", "amount_eur": 1.4, "currency_original": "EUR", "amount_original": 1400000, "announced_date": "2026-09-08", "notes": "€1.4M from Demea Sustainable Investment and Bpifrance to accelerate commercialization, automate production and continue materials R&D. Noise-reducing tableware (tempered glass + patented silicone) used in 200+ schools/hospitals; targeting 650,000 pieces in 2027. Source: Demea Invest." },
      { "name": "OTEO", "stage": "seed", "amount_eur": 1.2, "currency_original": "EUR", "amount_original": 1200000, "announced_date": "2026-09-02", "notes": "€1.2M seed to deploy its hospital-hotel (HTNM) platform across France. Investors: makesense, 50 Partners, INSEAD, Business Angels, BADGE, Bpifrance, Crédit Agricole des Savoie, CIC. Deployed with 15 establishments / 10,000 stays; targeting 175 establishments and 500,000 stays/year by 2030. Source: Le Dauphiné." },
      { "name": "BlueSecure", "stage": "seed", "amount_eur": 1.0, "currency_original": "EUR", "amount_original": 1000000, "announced_date": "2026-09-10", "notes": "€1M seed from Paris Business Angels, Arts & Métiers Business Angels and Bpifrance to hire, build new AI-threat training formats and prepare European expansion. Cybersecurity-awareness platform (training, serious games, simulated attacks). Commercial name of BLUEDIGITAL. Source: Silicon." }
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
  FALSE, 'funding_deals_september_2026_batch2', s.notes, NOW()
FROM source s
JOIN organizations o ON o.slug = lower(regexp_replace(regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g'));

-- =============================================================================
-- Step 3a: Create investor organizations (idempotent)
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      {"name":"Samsung Electronics"},{"name":"Scaleup Europe Fund"},{"name":"PSG Equity"},{"name":"Advent"},
      {"name":"BlackRock"},{"name":"Grand Duchy of Luxembourg"},{"name":"a16z"},{"name":"ASML"},{"name":"Belfius"},
      {"name":"BNP Paribas CIB"},{"name":"Bpifrance"},{"name":"Carmignac"},{"name":"DST Global"},{"name":"Eurazeo"},
      {"name":"General Catalyst"},{"name":"Headline"},{"name":"Hillspire"},{"name":"Index Ventures"},
      {"name":"Korelya Capital"},{"name":"Lightspeed"},{"name":"NVIDIA"},{"name":"Phoenix Court"},{"name":"Salesforce Ventures"},
      {"name":"Bessemer Venture Partners"},{"name":"Atomico"},{"name":"Balderton Capital"},{"name":"Plural"},{"name":"Cherry Ventures"},
      {"name":"IRIS"},{"name":"Five Arrows"},
      {"name":"Redalpine"},{"name":"OTB Ventures"},{"name":"Bpifrance Fonds Innovation Défense"},{"name":"Vsquared Ventures"},{"name":"10x Founders"},{"name":"Xavier Niel"},
      {"name":"Hi Inov"},{"name":"Axeleo Capital"},
      {"name":"Go Capital"},{"name":"European Regional Development Fund"},{"name":"Business Angels"},
      {"name":"Bpifrance Digital Venture"},{"name":"La Poste Ventures"},{"name":"50 Partners"},{"name":"AFI Ventures"},{"name":"CentraleSupélec Venture"},{"name":"Ring Capital Generations"},{"name":"Super Capital"},
      {"name":"Revent"},{"name":"Grey Silo Ventures"},{"name":"Jeriko"},{"name":"Fund F"},
      {"name":"Founders Future"},{"name":"100IN"},{"name":"Newschool"},{"name":"Bruno Vaffier"},{"name":"Antoine Lizée"},{"name":"Raphaël Nahum"},
      {"name":"Cita Investissement"},
      {"name":"Région Sud Investissement"},{"name":"CAAP Création"},
      {"name":"Hartwood"},{"name":"One Green"},{"name":"Pelintex"},{"name":"Showroomprivé"},
      {"name":"Demea Sustainable Investment"},
      {"name":"makesense"},{"name":"INSEAD"},{"name":"BADGE"},{"name":"Crédit Agricole des Savoie"},{"name":"CIC"},
      {"name":"Paris Business Angels"},{"name":"Arts & Métiers Business Angels"}
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
  'funding_deals_september_2026_batch2', NOW(), NOW()
FROM source s
ON CONFLICT (slug) DO NOTHING;

-- =============================================================================
-- Step 3b: Create funding round investors (joined on org + source)
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      {"org_name":"Mistral AI","investor_name":"Samsung Electronics","is_lead":true},
      {"org_name":"Mistral AI","investor_name":"Scaleup Europe Fund","is_lead":true},
      {"org_name":"Mistral AI","investor_name":"PSG Equity","is_lead":true},
      {"org_name":"Mistral AI","investor_name":"Advent","is_lead":false},
      {"org_name":"Mistral AI","investor_name":"BlackRock","is_lead":false},
      {"org_name":"Mistral AI","investor_name":"Grand Duchy of Luxembourg","is_lead":false},
      {"org_name":"Mistral AI","investor_name":"a16z","is_lead":false},
      {"org_name":"Mistral AI","investor_name":"ASML","is_lead":false},
      {"org_name":"Mistral AI","investor_name":"Belfius","is_lead":false},
      {"org_name":"Mistral AI","investor_name":"BNP Paribas CIB","is_lead":false},
      {"org_name":"Mistral AI","investor_name":"Bpifrance","is_lead":false},
      {"org_name":"Mistral AI","investor_name":"Carmignac","is_lead":false},
      {"org_name":"Mistral AI","investor_name":"DST Global","is_lead":false},
      {"org_name":"Mistral AI","investor_name":"Eurazeo","is_lead":false},
      {"org_name":"Mistral AI","investor_name":"General Catalyst","is_lead":false},
      {"org_name":"Mistral AI","investor_name":"Headline","is_lead":false},
      {"org_name":"Mistral AI","investor_name":"Hillspire","is_lead":false},
      {"org_name":"Mistral AI","investor_name":"Index Ventures","is_lead":false},
      {"org_name":"Mistral AI","investor_name":"Korelya Capital","is_lead":false},
      {"org_name":"Mistral AI","investor_name":"Lightspeed","is_lead":false},
      {"org_name":"Mistral AI","investor_name":"NVIDIA","is_lead":false},
      {"org_name":"Mistral AI","investor_name":"Phoenix Court","is_lead":false},
      {"org_name":"Mistral AI","investor_name":"Salesforce Ventures","is_lead":false},
      {"org_name":"The Exploration Company","investor_name":"Bessemer Venture Partners","is_lead":true},
      {"org_name":"The Exploration Company","investor_name":"Atomico","is_lead":true},
      {"org_name":"The Exploration Company","investor_name":"Scaleup Europe Fund","is_lead":true},
      {"org_name":"The Exploration Company","investor_name":"Balderton Capital","is_lead":false},
      {"org_name":"The Exploration Company","investor_name":"Plural","is_lead":false},
      {"org_name":"The Exploration Company","investor_name":"Cherry Ventures","is_lead":false},
      {"org_name":"Implicity","investor_name":"IRIS","is_lead":false},
      {"org_name":"Implicity","investor_name":"Five Arrows","is_lead":false},
      {"org_name":"Arlequin AI","investor_name":"Redalpine","is_lead":false},
      {"org_name":"Arlequin AI","investor_name":"OTB Ventures","is_lead":false},
      {"org_name":"Arlequin AI","investor_name":"Bpifrance Fonds Innovation Défense","is_lead":false},
      {"org_name":"Arlequin AI","investor_name":"Vsquared Ventures","is_lead":false},
      {"org_name":"Arlequin AI","investor_name":"10x Founders","is_lead":false},
      {"org_name":"Arlequin AI","investor_name":"Xavier Niel","is_lead":false},
      {"org_name":"Actionable","investor_name":"Hi Inov","is_lead":true},
      {"org_name":"Actionable","investor_name":"Axeleo Capital","is_lead":false},
      {"org_name":"Olenbee","investor_name":"Go Capital","is_lead":false},
      {"org_name":"Olenbee","investor_name":"Bpifrance","is_lead":false},
      {"org_name":"Olenbee","investor_name":"European Regional Development Fund","is_lead":false},
      {"org_name":"Olenbee","investor_name":"Business Angels","is_lead":false},
      {"org_name":"Ed AI","investor_name":"Bpifrance Digital Venture","is_lead":true},
      {"org_name":"Ed AI","investor_name":"La Poste Ventures","is_lead":false},
      {"org_name":"Ed AI","investor_name":"50 Partners","is_lead":false},
      {"org_name":"Ed AI","investor_name":"AFI Ventures","is_lead":false},
      {"org_name":"Ed AI","investor_name":"CentraleSupélec Venture","is_lead":false},
      {"org_name":"Ed AI","investor_name":"Ring Capital Generations","is_lead":false},
      {"org_name":"Ed AI","investor_name":"Super Capital","is_lead":false},
      {"org_name":"Tellia","investor_name":"Revent","is_lead":false},
      {"org_name":"Tellia","investor_name":"Grey Silo Ventures","is_lead":false},
      {"org_name":"Tellia","investor_name":"Jeriko","is_lead":false},
      {"org_name":"Tellia","investor_name":"Fund F","is_lead":false},
      {"org_name":"Outline","investor_name":"Founders Future","is_lead":true},
      {"org_name":"Outline","investor_name":"100IN","is_lead":false},
      {"org_name":"Outline","investor_name":"Newschool","is_lead":false},
      {"org_name":"Outline","investor_name":"Bruno Vaffier","is_lead":false},
      {"org_name":"Outline","investor_name":"Antoine Lizée","is_lead":false},
      {"org_name":"Outline","investor_name":"Raphaël Nahum","is_lead":false},
      {"org_name":"Bob! Desk","investor_name":"Cita Investissement","is_lead":true},
      {"org_name":"ANA Healthcare","investor_name":"Région Sud Investissement","is_lead":false},
      {"org_name":"ANA Healthcare","investor_name":"CAAP Création","is_lead":false},
      {"org_name":"ANA Healthcare","investor_name":"Business Angels","is_lead":false},
      {"org_name":"V4 Cure","investor_name":"Business Angels","is_lead":false},
      {"org_name":"Paradigme","investor_name":"Hartwood","is_lead":false},
      {"org_name":"Paradigme","investor_name":"One Green","is_lead":false},
      {"org_name":"Paradigme","investor_name":"Pelintex","is_lead":false},
      {"org_name":"Paradigme","investor_name":"Showroomprivé","is_lead":false},
      {"org_name":"Paradigme","investor_name":"Business Angels","is_lead":false},
      {"org_name":"Quiet","investor_name":"Demea Sustainable Investment","is_lead":false},
      {"org_name":"Quiet","investor_name":"Bpifrance","is_lead":false},
      {"org_name":"OTEO","investor_name":"makesense","is_lead":false},
      {"org_name":"OTEO","investor_name":"50 Partners","is_lead":false},
      {"org_name":"OTEO","investor_name":"INSEAD","is_lead":false},
      {"org_name":"OTEO","investor_name":"Business Angels","is_lead":false},
      {"org_name":"OTEO","investor_name":"BADGE","is_lead":false},
      {"org_name":"OTEO","investor_name":"Bpifrance","is_lead":false},
      {"org_name":"OTEO","investor_name":"Crédit Agricole des Savoie","is_lead":false},
      {"org_name":"OTEO","investor_name":"CIC","is_lead":false},
      {"org_name":"BlueSecure","investor_name":"Paris Business Angels","is_lead":false},
      {"org_name":"BlueSecure","investor_name":"Arts & Métiers Business Angels","is_lead":false},
      {"org_name":"BlueSecure","investor_name":"Bpifrance","is_lead":false}
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
JOIN funding_rounds fr ON fr.organization_id = o.id AND fr.source_name = 'funding_deals_september_2026_batch2'
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
      {"org":"mistral-ai","sec":"artificial-intelligence"},
      {"org":"the-exploration-company","sec":"spacetech-aerospace"},
      {"org":"implicity","sec":"healthtech"},{"org":"implicity","sec":"medtech"},{"org":"implicity","sec":"artificial-intelligence"},
      {"org":"arlequin-ai","sec":"artificial-intelligence"},{"org":"arlequin-ai","sec":"defensetech"},
      {"org":"actionable","sec":"artificial-intelligence"},{"org":"actionable","sec":"saas"},
      {"org":"olenbee","sec":"fintech"},{"org":"olenbee","sec":"saas"},{"org":"olenbee","sec":"artificial-intelligence"},
      {"org":"ed-ai","sec":"edtech"},{"org":"ed-ai","sec":"artificial-intelligence"},
      {"org":"tellia","sec":"artificial-intelligence"},{"org":"tellia","sec":"voice-ai"},{"org":"tellia","sec":"agtech"},
      {"org":"outline","sec":"fintech"},{"org":"outline","sec":"artificial-intelligence"},{"org":"outline","sec":"saas"},
      {"org":"bob-desk","sec":"saas"},{"org":"bob-desk","sec":"proptech"},
      {"org":"ana-healthcare","sec":"healthtech"},{"org":"ana-healthcare","sec":"medtech"},
      {"org":"v4-cure","sec":"biotech"},
      {"org":"paradigme","sec":"e-commerce-retail"},{"org":"paradigme","sec":"artificial-intelligence"},
      {"org":"quiet","sec":"deeptech"},{"org":"quiet","sec":"foodtech"},
      {"org":"oteo","sec":"healthtech"},{"org":"oteo","sec":"saas"},
      {"org":"bluesecure","sec":"cybersecurity"},{"org":"bluesecure","sec":"edtech"},{"org":"bluesecure","sec":"saas"}
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
      {"org":"mistral-ai","sec":"artificial-intelligence"},
      {"org":"the-exploration-company","sec":"spacetech-aerospace"},
      {"org":"implicity","sec":"healthtech"},
      {"org":"arlequin-ai","sec":"artificial-intelligence"},
      {"org":"actionable","sec":"artificial-intelligence"},
      {"org":"olenbee","sec":"fintech"},
      {"org":"ed-ai","sec":"edtech"},
      {"org":"tellia","sec":"artificial-intelligence"},
      {"org":"outline","sec":"fintech"},
      {"org":"bob-desk","sec":"saas"},
      {"org":"ana-healthcare","sec":"healthtech"},
      {"org":"v4-cure","sec":"biotech"},
      {"org":"paradigme","sec":"e-commerce-retail"},
      {"org":"quiet","sec":"deeptech"},
      {"org":"oteo","sec":"healthtech"},
      {"org":"bluesecure","sec":"cybersecurity"}
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
      {"full_name":"Arthur Mensch","first_name":"Arthur","last_name":"Mensch"},
      {"full_name":"Guillaume Lample","first_name":"Guillaume","last_name":"Lample"},
      {"full_name":"Timothée Lacroix","first_name":"Timothée","last_name":"Lacroix"},
      {"full_name":"Hélène Huby","first_name":"Hélène","last_name":"Huby"},
      {"full_name":"Arnaud Rosier","first_name":"Arnaud","last_name":"Rosier"},
      {"full_name":"David Perlmutter","first_name":"David","last_name":"Perlmutter"},
      {"full_name":"Hugo Micheron","first_name":"Hugo","last_name":"Micheron"},
      {"full_name":"Antoine Jardin","first_name":"Antoine","last_name":"Jardin"},
      {"full_name":"Nans Thomas","first_name":"Nans","last_name":"Thomas"},
      {"full_name":"Nicolas Rieul","first_name":"Nicolas","last_name":"Rieul"},
      {"full_name":"Arnaud Martenat","first_name":"Arnaud","last_name":"Martenat"},
      {"full_name":"Olivier Berthommier","first_name":"Olivier","last_name":"Berthommier"},
      {"full_name":"François Roulin","first_name":"François","last_name":"Roulin"},
      {"full_name":"Gonzague Bourrut Lacouture","first_name":"Gonzague","last_name":"Bourrut Lacouture"},
      {"full_name":"Jonathan Banon","first_name":"Jonathan","last_name":"Banon"},
      {"full_name":"Cédric Bignon","first_name":"Cédric","last_name":"Bignon"},
      {"full_name":"Rémi Mazières","first_name":"Rémi","last_name":"Mazières"},
      {"full_name":"Coline Labadie de Faÿ","first_name":"Coline","last_name":"Labadie de Faÿ"},
      {"full_name":"Vincent Trastour","first_name":"Vincent","last_name":"Trastour"},
      {"full_name":"Antoine de Mereuil","first_name":"Antoine","last_name":"de Mereuil"},
      {"full_name":"Hubert Jaouen","first_name":"Hubert","last_name":"Jaouen"},
      {"full_name":"Hamza Hassoun","first_name":"Hamza","last_name":"Hassoun"},
      {"full_name":"Pierre Michel","first_name":"Pierre","last_name":"Michel"},
      {"full_name":"Kai Hashimoto","first_name":"Kai","last_name":"Hashimoto"},
      {"full_name":"Nicolas Gilles","first_name":"Nicolas","last_name":"Gilles"},
      {"full_name":"Sonia Escaich","first_name":"Sonia","last_name":"Escaich"},
      {"full_name":"Nabil Gharios","first_name":"Nabil","last_name":"Gharios"},
      {"full_name":"Fabien Huché-Deniset","first_name":"Fabien","last_name":"Huché-Deniset"},
      {"full_name":"Vincent Huché-Deniset","first_name":"Vincent","last_name":"Huché-Deniset"},
      {"full_name":"Pierre Busquet","first_name":"Pierre","last_name":"Busquet"},
      {"full_name":"Sébastien Chauvin","first_name":"Sébastien","last_name":"Chauvin"},
      {"full_name":"Sophie Moritel","first_name":"Sophie","last_name":"Moritel"},
      {"full_name":"Léa Jakubowicz","first_name":"Léa","last_name":"Jakubowicz"},
      {"full_name":"Elsa Kiefer","first_name":"Elsa","last_name":"Kiefer"},
      {"full_name":"Jean-Baptiste Artignan","first_name":"Jean-Baptiste","last_name":"Artignan"},
      {"full_name":"Matthieu Deroubaix","first_name":"Matthieu","last_name":"Deroubaix"}
]$json$
  ) AS (full_name TEXT, first_name TEXT, last_name TEXT)
)
INSERT INTO people (
  id, full_name, slug, first_name, last_name, legacy_source, created_at
)
SELECT
  uuid_generate_v4(), s.full_name,
  lower(regexp_replace(regexp_replace(unaccent(s.full_name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g')),
  s.first_name, s.last_name, 'funding_deals_september_2026_batch2', NOW()
FROM source s
ON CONFLICT (slug) DO NOTHING;

-- =============================================================================
-- Step 6: Link founders to organizations
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      {"org_name":"Mistral AI","founder_name":"Arthur Mensch"},
      {"org_name":"Mistral AI","founder_name":"Guillaume Lample"},
      {"org_name":"Mistral AI","founder_name":"Timothée Lacroix"},
      {"org_name":"The Exploration Company","founder_name":"Hélène Huby"},
      {"org_name":"Implicity","founder_name":"Arnaud Rosier"},
      {"org_name":"Implicity","founder_name":"David Perlmutter"},
      {"org_name":"Arlequin AI","founder_name":"Hugo Micheron"},
      {"org_name":"Arlequin AI","founder_name":"Antoine Jardin"},
      {"org_name":"Actionable","founder_name":"Nans Thomas"},
      {"org_name":"Actionable","founder_name":"Nicolas Rieul"},
      {"org_name":"Olenbee","founder_name":"Arnaud Martenat"},
      {"org_name":"Olenbee","founder_name":"Olivier Berthommier"},
      {"org_name":"Olenbee","founder_name":"François Roulin"},
      {"org_name":"Olenbee","founder_name":"Gonzague Bourrut Lacouture"},
      {"org_name":"Ed AI","founder_name":"Jonathan Banon"},
      {"org_name":"Ed AI","founder_name":"Cédric Bignon"},
      {"org_name":"Ed AI","founder_name":"Rémi Mazières"},
      {"org_name":"Tellia","founder_name":"Coline Labadie de Faÿ"},
      {"org_name":"Tellia","founder_name":"Vincent Trastour"},
      {"org_name":"Outline","founder_name":"Antoine de Mereuil"},
      {"org_name":"Outline","founder_name":"Hubert Jaouen"},
      {"org_name":"Bob! Desk","founder_name":"Hamza Hassoun"},
      {"org_name":"ANA Healthcare","founder_name":"Pierre Michel"},
      {"org_name":"ANA Healthcare","founder_name":"Kai Hashimoto"},
      {"org_name":"V4 Cure","founder_name":"Nicolas Gilles"},
      {"org_name":"V4 Cure","founder_name":"Sonia Escaich"},
      {"org_name":"V4 Cure","founder_name":"Nabil Gharios"},
      {"org_name":"Paradigme","founder_name":"Fabien Huché-Deniset"},
      {"org_name":"Paradigme","founder_name":"Vincent Huché-Deniset"},
      {"org_name":"Quiet","founder_name":"Pierre Busquet"},
      {"org_name":"Quiet","founder_name":"Sébastien Chauvin"},
      {"org_name":"Quiet","founder_name":"Sophie Moritel"},
      {"org_name":"OTEO","founder_name":"Léa Jakubowicz"},
      {"org_name":"OTEO","founder_name":"Elsa Kiefer"},
      {"org_name":"BlueSecure","founder_name":"Jean-Baptiste Artignan"},
      {"org_name":"BlueSecure","founder_name":"Matthieu Deroubaix"}
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
-- Step 7: Attach SIREN legal entities (French). Idempotent -- Mistral, Implicity,
-- Ed AI and V4 Cure already carry their SIREN and are skipped. Arlequin's provided
-- SIREN differs from the existing one and is added as a second legal entity.
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      {"org":"mistral-ai","legal_name":"MISTRAL AI","siren":"952418325"},
      {"org":"the-exploration-company","legal_name":"THE EXPLORATION COMPANY","siren":"900427857"},
      {"org":"implicity","legal_name":"IMPLICITY","siren":"820529089"},
      {"org":"arlequin-ai","legal_name":"ARLEQUIN","siren":"983592676"},
      {"org":"actionable","legal_name":"ACTIONABLE","siren":"985066760"},
      {"org":"olenbee","legal_name":"OLENBEE","siren":"933025371"},
      {"org":"ed-ai","legal_name":"ED.AI","siren":"932580087"},
      {"org":"tellia","legal_name":"TELLIA FRANCE","siren":"999497407"},
      {"org":"outline","legal_name":"OUTLINE","siren":"105710222"},
      {"org":"bob-desk","legal_name":"BOB DEPANNAGE","siren":"810972927"},
      {"org":"ana-healthcare","legal_name":"ANA","siren":"922408034"},
      {"org":"v4-cure","legal_name":"V4CURE","siren":"949746655"},
      {"org":"paradigme","legal_name":"IRMAOS","siren":"898360839"},
      {"org":"quiet","legal_name":"QUIET","siren":"897995767"},
      {"org":"oteo","legal_name":"OTEO","siren":"948157987"},
      {"org":"bluesecure","legal_name":"BLUEDIGITAL","siren":"833999352"}
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
FROM funding_rounds WHERE source_name = 'funding_deals_september_2026_batch2'
UNION ALL
SELECT 'Investor Links', COUNT(*)
FROM funding_round_investors fri JOIN funding_rounds fr ON fr.id = fri.funding_round_id
WHERE fr.source_name = 'funding_deals_september_2026_batch2'
UNION ALL
SELECT 'Founder People (new)', COUNT(*)
FROM people WHERE legacy_source = 'funding_deals_september_2026_batch2';
