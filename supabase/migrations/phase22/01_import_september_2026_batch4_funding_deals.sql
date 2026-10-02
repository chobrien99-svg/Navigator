-- =============================================================================
-- September 2026 Funding Deals Import — Batch 4 (20 deals)
-- =============================================================================
-- source_name 'funding_deals_september_2026_batch4'. Amounts in millions.
--
-- 11 NEW organizations: Kheops, Horizom, RelaiSanté, Lightspring, IOPOLE,
--   WheelMove, LégiPilot, AlphaYoda, Le Petit Lunetier, Herapreg, Sinergy.
-- 9 EXISTING organizations get a new, distinct round (all confirmed same company,
--   e.g. by matching website): Biolevate, Graneet, HighLife, Incepto Medical,
--   Phocea DC, Primo (getprimo.com), Reecall (reecall.com), Wealthcome, Zeliq.
--
-- Corrections applied per the source's verification table:
--   * WheelMove: €1.5M total (€1M equity + €0.5M debt), not €1M.
--   * AlphaYoda: €900K, not €400K.
--   * WheelMove HQ "Vennette" corrected to Venette (Oise, near Compiègne).
--
-- Notes:
--   * Primo raised in USD ($8M) -> amount_eur estimated (is_estimated=TRUE).
--   * Undisclosed amounts (Sinergy, Phocea DC) store amount_eur NULL. LégiPilot's
--     investors are undisclosed (no investor links).
--   * Legal entities differ from brand for several: Primo=CLUTCH, Zeliq=GETHEROES,
--     Graneet=GABZO, Herapreg=FEMMA, Le Petit Lunetier=LE PETIT LUNETIER PARIS SAS,
--     Sinergy=SINERGY / NOSMEILLEURSPRODUCTEURS, Biolevate=BIOLEVATE SAS,
--     Incepto=INCEPTO MEDICAL SAS.
--   * Phocea DC's €120M is an investment plan (equity + bank debt), not an equity
--     raise; recorded as a growth round with undisclosed amount.
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "unaccent";

ALTER TABLE organizations
  ADD COLUMN IF NOT EXISTS secondary_city_id UUID REFERENCES cities(id) ON DELETE SET NULL;

-- =============================================================================
-- Step 0: Ensure cities exist (Venette, Yerres, Marlenheim are new)
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      { "name": "Paris", "country": "France" },
      { "name": "Bordeaux", "country": "France" },
      { "name": "Lyon", "country": "France" },
      { "name": "Besançon", "country": "France" },
      { "name": "Pérols", "country": "France" },
      { "name": "Venette", "country": "France" },
      { "name": "Lille", "country": "France" },
      { "name": "Metz", "country": "France" },
      { "name": "Yerres", "country": "France" },
      { "name": "Marlenheim", "country": "France" },
      { "name": "Marseille", "country": "France" }
]$json$
  ) AS (name TEXT, country TEXT)
)
INSERT INTO cities (id, name, slug, country, created_at, updated_at)
SELECT uuid_generate_v4(), s.name,
  lower(regexp_replace(regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g')),
  s.country, NOW(), NOW()
FROM source s ON CONFLICT (slug) DO NOTHING;

-- =============================================================================
-- Step 1: Create organizations (new; existing upserted, names preserved)
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      { "name": "HighLife", "website": "https://www.highlifemedical.com", "description": "Develops transcatheter technologies for treating structural heart disease, with a particular focus on mitral regurgitation." },
      { "name": "Biolevate", "website": "https://www.biolevate.com", "description": "Builds evidence-grade AI software for regulated life sciences workflows, using AI agents to automate scientific, clinical, and regulatory work while maintaining traceability, auditability, and human oversight." },
      { "name": "Wealthcome", "website": "https://www.wealthcome.fr", "description": "Software platform for wealth-management professionals that centralizes client and asset data, automates workflows, and provides tools for financial advisers, family offices, insurers, and banks. Also launching Binom, an AI layer for its WealthPro platform." },
      { "name": "Incepto Medical", "website": "https://incepto-medical.com/", "description": "European platform for deploying and orchestrating curated AI applications across medical-imaging workflows." },
      { "name": "Kheops", "website": "https://www.kheops.io", "description": "B2B platform connecting supermarket stores directly with local and regional suppliers while centralizing product listing, ordering, invoicing, and payments." },
      { "name": "Horizom", "website": "https://horizom.com", "description": "Develops a French bamboo value chain, partnering with farmers to establish bamboo plantations and supplying the resulting biomass to industrial customers as a lower-carbon alternative to wood and fossil-derived materials. The model also monetizes bamboo's carbon-sequestration potential." },
      { "name": "Primo", "website": "https://www.getprimo.com", "description": "All-in-one employee IT management platform combining device management, SaaS and identity/access management, cybersecurity, IT purchasing and support. Adding autonomous AI agents that execute IT operations end to end, including employee onboarding and offboarding." },
      { "name": "Zeliq", "website": "https://www.zeliq.com", "description": "AI-native sales workspace combining prospect identification, data enrichment, multichannel outreach, and sales automation. Its Zelia agent suite handles sourcing, qualification, and follow-up while keeping sales reps in control of key actions." },
      { "name": "Graneet", "website": "https://www.graneet.com/", "description": "Vertical ERP for construction SMEs covering estimating, invoicing, purchasing, workforce management, inventory, CRM, and real-time job profitability." },
      { "name": "RelaiSanté", "website": "https://www.relaisante.com/", "description": "Platform connecting hospitals with home-care professionals to organize patient discharge and continuity of care." },
      { "name": "Reecall", "website": "https://www.reecall.ai/", "description": "White-label infrastructure enabling software vendors, telecom operators, and outsourcers to build and operate enterprise voice-AI features for their customers." },
      { "name": "Lightspring", "website": "https://www.light-spring.com/", "description": "Develops 3D-fabricated optical interfaces for photonic integrated circuits, using two-photon lithography to make chip packaging more reproducible and scalable." },
      { "name": "IOPOLE", "website": "https://iopole.com/", "description": "Provides white-label electronic-invoicing infrastructure that software publishers and fintechs can integrate under their own brands." },
      { "name": "WheelMove", "website": "https://www.wheelmove.eu", "description": "Develops ZE ONE, a compact electric-assistance system that converts a manual wheelchair into an all-terrain powered chair while remaining removable and transportable." },
      { "name": "LégiPilot", "website": "https://www.legipilot.com/", "description": "SaaS platform automating HR and employment-law workflows, including contracts, compliance processes, employee administration, and an AI legal/HR assistant." },
      { "name": "AlphaYoda", "website": "https://alphayoda.com/", "description": "Uses AI to detect corporate controversies and estimate their potential financial and reputational impact for banks, asset managers, and other financial institutions." },
      { "name": "Le Petit Lunetier", "website": "https://www.lepetitlunetier.com", "description": "French eyewear brand selling prescription glasses and sunglasses through its own retail network and online." },
      { "name": "Herapreg", "website": "https://herapreg.com", "description": "Develops CE-marked medical compression garments for pelvic and vulvar health. Its Pelvinity compression overgarment relieves pelvic heaviness associated with pregnancy, prolapse, and pelvic congestion; expanding toward chronic gynecological conditions including endometriosis and severe dysmenorrhea." },
      { "name": "Sinergy", "website": "https://www.sinergy.fr", "description": "Provides turnkey fundraising campaigns for schools, sports clubs and associations based around sales of products from local artisan producers. Handles catalogs, personalized online shops, order preparation, and logistics, with associations retaining up to 40% of sales." },
      { "name": "Phocea DC", "website": "https://www.phocea-dc.com/", "description": "Develops sovereign, lower-impact edge data centers integrated into the urban fabric of Marseille." }
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
  'funding_deals_september_2026_batch4', NOW(), NOW()
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
      { "org_name": "HighLife", "city": "Paris" },
      { "org_name": "Biolevate", "city": "Paris" },
      { "org_name": "Wealthcome", "city": "Bordeaux" },
      { "org_name": "Incepto Medical", "city": "Paris" },
      { "org_name": "Kheops", "city": "Paris" },
      { "org_name": "Horizom", "city": "Bordeaux" },
      { "org_name": "Primo", "city": "Paris" },
      { "org_name": "Zeliq", "city": "Paris" },
      { "org_name": "Graneet", "city": "Paris" },
      { "org_name": "RelaiSanté", "city": "Paris" },
      { "org_name": "Reecall", "city": "Lyon" },
      { "org_name": "Lightspring", "city": "Besançon" },
      { "org_name": "IOPOLE", "city": "Pérols" },
      { "org_name": "WheelMove", "city": "Venette" },
      { "org_name": "LégiPilot", "city": "Lille" },
      { "org_name": "AlphaYoda", "city": "Metz" },
      { "org_name": "Le Petit Lunetier", "city": "Paris" },
      { "org_name": "Herapreg", "city": "Yerres" },
      { "org_name": "Sinergy", "city": "Marlenheim" },
      { "org_name": "Phocea DC", "city": "Marseille" }
]$json$
  ) AS (org_name TEXT, city TEXT)
)
UPDATE organizations o SET city_id = COALESCE(o.city_id, c1.id), updated_at = NOW()
FROM source s
LEFT JOIN cities c1 ON c1.slug = lower(regexp_replace(regexp_replace(unaccent(s.city), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g'))
WHERE o.slug = lower(regexp_replace(regexp_replace(unaccent(s.org_name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g'));

-- =============================================================================
-- Step 2: Create funding rounds (20)
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      { "name": "HighLife", "stage": "growth", "amount_eur": 80.0, "currency_original": "EUR", "amount_original": 80000000, "announced_date": "2026-09-22", "notes": "€80M (>$90M) growth financing to accelerate commercial expansion in Europe and advance its U.S. pivotal clinical program. Transcatheter mitral regurgitation technology. Investors: Andera Partners, Sofinnova Partners, Supernova Invest, Mérieux Equity Partners, European Investment Bank, BNP Paribas Développement, Capricorn Partners, Critical Path Ventures, Pro Benefis Familiae, SPRIM Global Investments, USVP, Sectoral, VI Partners. Source: Andera Partners, HighLife." },
      { "name": "Biolevate", "stage": "series_a", "amount_eur": 30.0, "currency_original": "EUR", "amount_original": 30000000, "announced_date": "2026-09-21", "notes": "€30M Series A to accelerate international expansion (incl. a new Boston office), deepen product capabilities and scale deployments. 12+ enterprise customers, ARR up 20x in 12 months, 50 employees. Investors: RAISE France, Orange Ventures, MSD Global Health Innovation Fund, EQT Ventures. Legal entity BIOLEVATE SAS. Source: Axios, Biolevate." },
      { "name": "Wealthcome", "stage": "series_b", "amount_eur": 15.0, "currency_original": "EUR", "amount_original": 15000000, "announced_date": "2026-09-24", "notes": "€15M Series B from Breega and BlackFin Capital Partners to expand with large financial institutions and grow. Since its €7M Series A (March 2025): 300->800+ firms, 2,500->6,000+ users, €20B->€80B+ assets. Total funding since Series A: €22M. Source: Wealthcome, Breega." },
      { "name": "Incepto Medical", "stage": "series_b", "amount_eur": 14.0, "currency_original": "EUR", "amount_original": 14000000, "announced_date": "2026-09-22", "notes": "€14M (~$16M) Series B for international expansion and further platform/AI development. Curated medical-imaging AI orchestration. Investors: Impactivist, LBO France, Karista, Bpifrance, Wille Finance. Legal entity INCEPTO MEDICAL SAS. Distinct from its earlier 2022 Series B. Source: Incepto." },
      { "name": "Kheops", "stage": "series_a", "amount_eur": 12.0, "currency_original": "EUR", "amount_original": 12000000, "announced_date": "2026-09-21", "notes": "€12M Series A to expand its store-to-supplier platform and build an AI layer for assortment recommendations and purchasing decisions. Investors: Odyssée Venture, ISAI, Elaia. Source: Odyssée Venture, Agra Presse." },
      { "name": "Horizom", "stage": "growth", "amount_eur": 10.0, "currency_original": "EUR", "amount_original": 10000000, "announced_date": "2026-09-17", "notes": "€10M from SWEN Terra (SWEN Capital Partners) to accelerate France's bamboo industry: expand its Landes nursery and team, first industrial deliveries, and agronomic R&D. ~600 ha planted across 24 departments; targeting 3,000 ha by 2030 and 7,000 tonnes of biomass. Source: SWEN." },
      { "name": "Primo", "stage": "seed", "amount_eur": 6.88, "currency_original": "USD", "amount_original": 8000000, "announced_date": "2026-09-22", "notes": "$8M (~€6.9M est.) seed to accelerate its autonomous IT agents, expand internationally and grow. 400+ customers across 10 countries, revenue quadrupled YoY past $4M ARR; >half of customers outside France. Investors: Headline, Global Founders Capital, Arthur Waller, Romain Niccoli, Business Angels. Legal entity CLUTCH. Source: The French Tech Journal." },
      { "name": "Zeliq", "stage": "seed", "amount_eur": 7.0, "currency_original": "EUR", "amount_original": 7000000, "announced_date": "2026-09-22", "notes": "€7M seed extension to develop its AI-agent sales platform (Zelia suite), double its product/tech team across Paris, Barcelona and Milan, and deepen European expansion. Total funding ~€21M in under three years; ~20,000 users. Investors: The Moon Venture, CMI, JJCapinvest, Sylvestre Blavet, Ora Global, Cleo Ventures, Business Angels. Legal entity GETHEROES. Source: Zeliq, Maddyness." },
      { "name": "Graneet", "stage": "growth", "amount_eur": 7.0, "currency_original": "EUR", "amount_original": 7000000, "announced_date": "2026-09-25", "notes": "€7M fresh capital as it accelerates around France's e-invoicing transition and adds AI agents and new modules to its construction ERP. Investors: Point Nine, Spring Invest. Legal entity GABZO. Source: Graneet, Business BTP." },
      { "name": "RelaiSanté", "stage": "seed", "amount_eur": 6.0, "currency_original": "EUR", "amount_original": 6000000, "announced_date": "2026-09-23", "notes": "€6M seed to expand beyond the 315+ healthcare establishments already using it, broaden home-care services and develop AI to anticipate patient discharges. Investors: Ternel, Aquiti, Elaia, Ventech. Source: Ventech." },
      { "name": "Reecall", "stage": "seed", "amount_eur": 3.5, "currency_original": "EUR", "amount_original": 3500000, "announced_date": "2026-09-24", "notes": "€3.5M equity following a pivot from direct SaaS to white-label voice-AI infrastructure; revenue quadrupled in eight months. Investors: Founders Future, Holnest, Mesh, Francis Nappez, Sébastien Lucas, Evolem. Attached to the existing 'Reecall' organization. Source: Planet Fintech, Scale-Up Corner." },
      { "name": "Lightspring", "stage": "seed", "amount_eur": 3.1, "currency_original": "EUR", "amount_original": 3100000, "announced_date": "2026-09-22", "notes": "€3.1M seed to move its photonic packaging technology from lab demonstrations toward industrial qualification and production (3D two-photon lithography optical interfaces for PICs). Investors: Atlantic, OVNI Capital, Concept Ventures, Ixcore, Plug and Play Ventures, Business Angels. Source: EU-Startups." },
      { "name": "IOPOLE", "stage": "seed", "amount_eur": 3.0, "currency_original": "EUR", "amount_original": 3000000, "announced_date": "2026-09-21", "notes": "€3M seed to fund international expansion, AI development, hiring and e-invoicing regulatory/technical work. White-label e-invoicing infrastructure; ~500,000 businesses via 300+ software-publisher partners. Investors: IRDI Capital Investissement, SOFILARO. Source: IRDI, La Lettre M." },
      { "name": "WheelMove", "stage": "seed", "amount_eur": 1.5, "currency_original": "EUR", "amount_original": 1500000, "announced_date": "2026-09-23", "notes": "€1.5M total (€1M equity + €0.5M debt / French Tech Seed) to industrialize ZE ONE ahead of launch, incl. an assembly operation near Compiègne, a distributor network and four hires. Prior €160K capital increase in September 2025. HQ Venette (Oise). Investors: Rives Croissance, Banque Populaire Rives de Paris, Bpifrance. Source: J'aime les Startups." },
      { "name": "LégiPilot", "stage": "pre_seed", "amount_eur": 0.5, "currency_original": "EUR", "amount_original": 500000, "announced_date": "2026-09-23", "notes": "~€500K first external financing to grow the team and accelerate deployment of its HR/employment-law automation platform with an AI legal/HR assistant. Investors undisclosed. Source: La Gazette Nord-Pas-de-Calais." },
      { "name": "AlphaYoda", "stage": "pre_seed", "amount_eur": 0.9, "currency_original": "EUR", "amount_original": 900000, "announced_date": "2026-09-23", "notes": "€900K first financing from business angels to accelerate commercial deployment across Europe and industrialize its reputation-risk platform (AI detection of corporate controversies and their financial impact). Source: Novethic." },
      { "name": "Le Petit Lunetier", "stage": "growth", "amount_eur": 0.25, "currency_original": "EUR", "amount_original": 248000, "announced_date": "2026-09-23", "notes": "€248K primary subscription (new shares) by NESO Brands, lifting its fully diluted stake from 31.82% to 34.34% (+2.52%). New money into the French company (not a secondary transfer). NESO had invested €250K in April 2026; 2026 total €498K. FY2026 turnover €7.7M. Source: scanx.trade." },
      { "name": "Herapreg", "stage": "seed", "amount_eur": 0.22, "currency_original": "EUR", "amount_original": 215000, "announced_date": "2026-09-18", "notes": "€215K second round (after an initial €100K in 2025) from business angels to support clinical validation, textile engineering, regulatory work and expansion. CE-marked pelvic/vulvar compression garments; adapting toward endometriosis and severe dysmenorrhea. Legal entity FEMMA. Source: Societe.Tech." },
      { "name": "Sinergy", "stage": "pre_seed", "amount_eur": null, "currency_original": null, "amount_original": null, "announced_date": "2026-09-14", "notes": "Undisclosed round with Yeast (Grand Est Business Angel Network), completed during the summer. Turnkey fundraising campaigns for associations via local artisan producers. In 2025: 50,000 orders, ~€500K returned to associations, €1M+ orders for producers. Legal entity SINERGY / NOSMEILLEURSPRODUCTEURS. Source: BFMTV." },
      { "name": "Phocea DC", "stage": "growth", "amount_eur": null, "currency_original": null, "amount_original": null, "announced_date": "2026-09-23", "notes": "Undisclosed equity + bank debt from Marguerite (transaction completed early August) backing a €120M+ capital-investment plan for additional sovereign edge data centers in Marseille, including a second site. Source: Marguerite, CFNEWS Infra." }
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
  FALSE, 'funding_deals_september_2026_batch4', s.notes, NOW()
FROM source s
JOIN organizations o ON o.slug = lower(regexp_replace(regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g'));

-- =============================================================================
-- Step 3a: Create investor organizations (idempotent)
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      {"name":"Andera Partners"},{"name":"Sofinnova Partners"},{"name":"Supernova Invest"},{"name":"Mérieux Equity Partners"},{"name":"European Investment Bank"},{"name":"BNP Paribas Développement"},{"name":"Capricorn Partners"},{"name":"Critical Path Ventures"},{"name":"Pro Benefis Familiae"},{"name":"SPRIM Global Investments"},{"name":"USVP"},{"name":"Sectoral"},{"name":"VI Partners"},
      {"name":"RAISE France"},{"name":"Orange Ventures"},{"name":"MSD Global Health Innovation Fund"},{"name":"EQT Ventures"},
      {"name":"Breega"},{"name":"BlackFin Capital Partners"},
      {"name":"Impactivist"},{"name":"LBO France"},{"name":"Karista"},{"name":"Bpifrance"},{"name":"Wille Finance"},
      {"name":"Odyssée Venture"},{"name":"ISAI"},{"name":"Elaia"},
      {"name":"SWEN Capital Partners"},
      {"name":"Headline"},{"name":"Global Founders Capital"},{"name":"Arthur Waller"},{"name":"Romain Niccoli"},{"name":"Business Angels"},
      {"name":"The Moon Venture"},{"name":"CMI"},{"name":"JJCapinvest"},{"name":"Sylvestre Blavet"},{"name":"Ora Global"},{"name":"Cleo Ventures"},
      {"name":"Point Nine"},{"name":"Spring Invest"},
      {"name":"Ternel"},{"name":"Aquiti"},{"name":"Ventech"},
      {"name":"Founders Future"},{"name":"Holnest"},{"name":"Mesh"},{"name":"Francis Nappez"},{"name":"Sébastien Lucas"},{"name":"Evolem"},
      {"name":"Atlantic"},{"name":"OVNI Capital"},{"name":"Concept Ventures"},{"name":"Ixcore"},{"name":"Plug and Play Ventures"},
      {"name":"IRDI Capital Investissement"},{"name":"SOFILARO"},
      {"name":"Rives Croissance"},{"name":"Banque Populaire Rives de Paris"},
      {"name":"NESO Brands"},
      {"name":"Yeast"},
      {"name":"Marguerite"}
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
  'funding_deals_september_2026_batch4', NOW(), NOW()
FROM source s
ON CONFLICT (slug) DO NOTHING;

-- =============================================================================
-- Step 3b: Create funding round investors (joined on org + source)
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      {"org_name":"HighLife","investor_name":"Andera Partners","is_lead":false},
      {"org_name":"HighLife","investor_name":"Sofinnova Partners","is_lead":false},
      {"org_name":"HighLife","investor_name":"Supernova Invest","is_lead":false},
      {"org_name":"HighLife","investor_name":"Mérieux Equity Partners","is_lead":false},
      {"org_name":"HighLife","investor_name":"European Investment Bank","is_lead":false},
      {"org_name":"HighLife","investor_name":"BNP Paribas Développement","is_lead":false},
      {"org_name":"HighLife","investor_name":"Capricorn Partners","is_lead":false},
      {"org_name":"HighLife","investor_name":"Critical Path Ventures","is_lead":false},
      {"org_name":"HighLife","investor_name":"Pro Benefis Familiae","is_lead":false},
      {"org_name":"HighLife","investor_name":"SPRIM Global Investments","is_lead":false},
      {"org_name":"HighLife","investor_name":"USVP","is_lead":false},
      {"org_name":"HighLife","investor_name":"Sectoral","is_lead":false},
      {"org_name":"HighLife","investor_name":"VI Partners","is_lead":false},
      {"org_name":"Biolevate","investor_name":"RAISE France","is_lead":false},
      {"org_name":"Biolevate","investor_name":"Orange Ventures","is_lead":false},
      {"org_name":"Biolevate","investor_name":"MSD Global Health Innovation Fund","is_lead":false},
      {"org_name":"Biolevate","investor_name":"EQT Ventures","is_lead":false},
      {"org_name":"Wealthcome","investor_name":"Breega","is_lead":false},
      {"org_name":"Wealthcome","investor_name":"BlackFin Capital Partners","is_lead":false},
      {"org_name":"Incepto Medical","investor_name":"Impactivist","is_lead":false},
      {"org_name":"Incepto Medical","investor_name":"LBO France","is_lead":false},
      {"org_name":"Incepto Medical","investor_name":"Karista","is_lead":false},
      {"org_name":"Incepto Medical","investor_name":"Bpifrance","is_lead":false},
      {"org_name":"Incepto Medical","investor_name":"Wille Finance","is_lead":false},
      {"org_name":"Kheops","investor_name":"Odyssée Venture","is_lead":false},
      {"org_name":"Kheops","investor_name":"ISAI","is_lead":false},
      {"org_name":"Kheops","investor_name":"Elaia","is_lead":false},
      {"org_name":"Horizom","investor_name":"SWEN Capital Partners","is_lead":true},
      {"org_name":"Primo","investor_name":"Headline","is_lead":false},
      {"org_name":"Primo","investor_name":"Global Founders Capital","is_lead":false},
      {"org_name":"Primo","investor_name":"Arthur Waller","is_lead":false},
      {"org_name":"Primo","investor_name":"Romain Niccoli","is_lead":false},
      {"org_name":"Primo","investor_name":"Business Angels","is_lead":false},
      {"org_name":"Zeliq","investor_name":"The Moon Venture","is_lead":false},
      {"org_name":"Zeliq","investor_name":"CMI","is_lead":false},
      {"org_name":"Zeliq","investor_name":"JJCapinvest","is_lead":false},
      {"org_name":"Zeliq","investor_name":"Sylvestre Blavet","is_lead":false},
      {"org_name":"Zeliq","investor_name":"Ora Global","is_lead":false},
      {"org_name":"Zeliq","investor_name":"Cleo Ventures","is_lead":false},
      {"org_name":"Zeliq","investor_name":"Business Angels","is_lead":false},
      {"org_name":"Graneet","investor_name":"Point Nine","is_lead":false},
      {"org_name":"Graneet","investor_name":"Spring Invest","is_lead":false},
      {"org_name":"RelaiSanté","investor_name":"Ternel","is_lead":false},
      {"org_name":"RelaiSanté","investor_name":"Aquiti","is_lead":false},
      {"org_name":"RelaiSanté","investor_name":"Elaia","is_lead":false},
      {"org_name":"RelaiSanté","investor_name":"Ventech","is_lead":false},
      {"org_name":"Reecall","investor_name":"Founders Future","is_lead":false},
      {"org_name":"Reecall","investor_name":"Holnest","is_lead":false},
      {"org_name":"Reecall","investor_name":"Mesh","is_lead":false},
      {"org_name":"Reecall","investor_name":"Francis Nappez","is_lead":false},
      {"org_name":"Reecall","investor_name":"Sébastien Lucas","is_lead":false},
      {"org_name":"Reecall","investor_name":"Evolem","is_lead":false},
      {"org_name":"Lightspring","investor_name":"Atlantic","is_lead":false},
      {"org_name":"Lightspring","investor_name":"OVNI Capital","is_lead":false},
      {"org_name":"Lightspring","investor_name":"Concept Ventures","is_lead":false},
      {"org_name":"Lightspring","investor_name":"Ixcore","is_lead":false},
      {"org_name":"Lightspring","investor_name":"Plug and Play Ventures","is_lead":false},
      {"org_name":"Lightspring","investor_name":"Business Angels","is_lead":false},
      {"org_name":"IOPOLE","investor_name":"IRDI Capital Investissement","is_lead":false},
      {"org_name":"IOPOLE","investor_name":"SOFILARO","is_lead":false},
      {"org_name":"WheelMove","investor_name":"Rives Croissance","is_lead":false},
      {"org_name":"WheelMove","investor_name":"Banque Populaire Rives de Paris","is_lead":false},
      {"org_name":"WheelMove","investor_name":"Bpifrance","is_lead":false},
      {"org_name":"AlphaYoda","investor_name":"Business Angels","is_lead":false},
      {"org_name":"Le Petit Lunetier","investor_name":"NESO Brands","is_lead":false},
      {"org_name":"Herapreg","investor_name":"Business Angels","is_lead":false},
      {"org_name":"Sinergy","investor_name":"Yeast","is_lead":false},
      {"org_name":"Phocea DC","investor_name":"Marguerite","is_lead":true}
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
JOIN funding_rounds fr ON fr.organization_id = o.id AND fr.source_name = 'funding_deals_september_2026_batch4'
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
      {"org":"highlife","sec":"medtech"},
      {"org":"biolevate","sec":"artificial-intelligence"},{"org":"biolevate","sec":"healthtech"},
      {"org":"wealthcome","sec":"fintech"},{"org":"wealthcome","sec":"saas"},{"org":"wealthcome","sec":"artificial-intelligence"},
      {"org":"incepto-medical","sec":"artificial-intelligence"},{"org":"incepto-medical","sec":"healthtech"},
      {"org":"kheops","sec":"saas"},{"org":"kheops","sec":"artificial-intelligence"},
      {"org":"horizom","sec":"agritech"},{"org":"horizom","sec":"climatetech"},{"org":"horizom","sec":"biotech"},
      {"org":"primo","sec":"artificial-intelligence"},{"org":"primo","sec":"saas"},{"org":"primo","sec":"cybersecurity"},
      {"org":"zeliq","sec":"artificial-intelligence"},{"org":"zeliq","sec":"saas"},
      {"org":"graneet","sec":"saas"},{"org":"graneet","sec":"artificial-intelligence"},
      {"org":"relaisante","sec":"healthtech"},{"org":"relaisante","sec":"saas"},{"org":"relaisante","sec":"artificial-intelligence"},
      {"org":"reecall","sec":"artificial-intelligence"},{"org":"reecall","sec":"saas"},
      {"org":"lightspring","sec":"deeptech"},{"org":"lightspring","sec":"semiconductors"},{"org":"lightspring","sec":"artificial-intelligence"},
      {"org":"iopole","sec":"fintech"},{"org":"iopole","sec":"saas"},
      {"org":"wheelmove","sec":"medtech"},{"org":"wheelmove","sec":"mobility"},
      {"org":"legipilot","sec":"hrtech"},{"org":"legipilot","sec":"legaltech"},{"org":"legipilot","sec":"saas"},{"org":"legipilot","sec":"artificial-intelligence"},
      {"org":"alphayoda","sec":"fintech"},{"org":"alphayoda","sec":"artificial-intelligence"},
      {"org":"le-petit-lunetier","sec":"e-commerce-retail"},
      {"org":"herapreg","sec":"medtech"},{"org":"herapreg","sec":"femtech"},
      {"org":"sinergy","sec":"fintech"},{"org":"sinergy","sec":"saas"},
      {"org":"phocea-dc","sec":"hardware"},{"org":"phocea-dc","sec":"artificial-intelligence"}
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
      {"org":"highlife","sec":"medtech"},{"org":"biolevate","sec":"artificial-intelligence"},{"org":"wealthcome","sec":"fintech"},
      {"org":"incepto-medical","sec":"artificial-intelligence"},{"org":"kheops","sec":"saas"},{"org":"horizom","sec":"agritech"},
      {"org":"primo","sec":"artificial-intelligence"},{"org":"zeliq","sec":"artificial-intelligence"},{"org":"graneet","sec":"saas"},
      {"org":"relaisante","sec":"healthtech"},{"org":"reecall","sec":"artificial-intelligence"},{"org":"lightspring","sec":"deeptech"},
      {"org":"iopole","sec":"fintech"},{"org":"wheelmove","sec":"medtech"},{"org":"legipilot","sec":"hrtech"},
      {"org":"alphayoda","sec":"fintech"},{"org":"le-petit-lunetier","sec":"e-commerce-retail"},{"org":"herapreg","sec":"medtech"},
      {"org":"sinergy","sec":"fintech"},{"org":"phocea-dc","sec":"hardware"}
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
      {"full_name":"Georg Börtlein","first_name":"Georg","last_name":"Börtlein"},
      {"full_name":"Malek Nasr","first_name":"Malek","last_name":"Nasr"},
      {"full_name":"Rüdiger Lange","first_name":"Rüdiger","last_name":"Lange"},
      {"full_name":"Nicolo Piazza","first_name":"Nicolo","last_name":"Piazza"},
      {"full_name":"Joël Belafa","first_name":"Joël","last_name":"Belafa"},
      {"full_name":"Nathan Chen","first_name":"Nathan","last_name":"Chen"},
      {"full_name":"Anas Laaroussi","first_name":"Anas","last_name":"Laaroussi"},
      {"full_name":"Cyprien Delmeule","first_name":"Cyprien","last_name":"Delmeule"},
      {"full_name":"Éric Foin","first_name":"Éric","last_name":"Foin"},
      {"full_name":"Morgan Emmery","first_name":"Morgan","last_name":"Emmery"},
      {"full_name":"Florence Moreau","first_name":"Florence","last_name":"Moreau"},
      {"full_name":"Antoine Jomier","first_name":"Antoine","last_name":"Jomier"},
      {"full_name":"Gaspard d'Assignies","first_name":"Gaspard","last_name":"d'Assignies"},
      {"full_name":"Caroline Poinsignon","first_name":"Caroline","last_name":"Poinsignon"},
      {"full_name":"Thibault Boyeux","first_name":"Thibault","last_name":"Boyeux"},
      {"full_name":"Stéphane Alzaix","first_name":"Stéphane","last_name":"Alzaix"},
      {"full_name":"Christophe Downey","first_name":"Christophe","last_name":"Downey"},
      {"full_name":"Dimitri Guyot","first_name":"Dimitri","last_name":"Guyot"},
      {"full_name":"Martin Pannier","first_name":"Martin","last_name":"Pannier"},
      {"full_name":"Antoine de Mereuil","first_name":"Antoine","last_name":"de Mereuil"},
      {"full_name":"Nicolas Nallet","first_name":"Nicolas","last_name":"Nallet"},
      {"full_name":"Dorian Ciavarella","first_name":"Dorian","last_name":"Ciavarella"},
      {"full_name":"Guillaume Cruz","first_name":"Guillaume","last_name":"Cruz"},
      {"full_name":"Jean-Gabriel Niel","first_name":"Jean-Gabriel","last_name":"Niel"},
      {"full_name":"Enzo Dozias","first_name":"Enzo","last_name":"Dozias"},
      {"full_name":"Raphaël Moulin","first_name":"Raphaël","last_name":"Moulin"},
      {"full_name":"Etienne Boix","first_name":"Etienne","last_name":"Boix"},
      {"full_name":"Pierre Godet","first_name":"Pierre","last_name":"Godet"},
      {"full_name":"Maxime Trouché","first_name":"Maxime","last_name":"Trouché"},
      {"full_name":"Raphaël Szymocha","first_name":"Raphaël","last_name":"Szymocha"},
      {"full_name":"Grégoire Bonnat","first_name":"Grégoire","last_name":"Bonnat"},
      {"full_name":"Adrià Grabulosa","first_name":"Adrià","last_name":"Grabulosa"},
      {"full_name":"Daniel Brunner","first_name":"Daniel","last_name":"Brunner"},
      {"full_name":"Dorian Keiflin","first_name":"Dorian","last_name":"Keiflin"},
      {"full_name":"Yoann Keiflin","first_name":"Yoann","last_name":"Keiflin"},
      {"full_name":"Nicolas Saudemont","first_name":"Nicolas","last_name":"Saudemont"},
      {"full_name":"Gabriel Pala","first_name":"Gabriel","last_name":"Pala"},
      {"full_name":"Amaury Dupas","first_name":"Amaury","last_name":"Dupas"},
      {"full_name":"Kévin Surbled","first_name":"Kévin","last_name":"Surbled"},
      {"full_name":"Victor Leclaire","first_name":"Victor","last_name":"Leclaire"},
      {"full_name":"Marin de Surirey","first_name":"Marin","last_name":"de Surirey"},
      {"full_name":"Axel Bonaldo","first_name":"Axel","last_name":"Bonaldo"},
      {"full_name":"Marion Bitoune","first_name":"Marion","last_name":"Bitoune"},
      {"full_name":"Cédric de Saint-Léger","first_name":"Cédric","last_name":"de Saint-Léger"},
      {"full_name":"Thomas Lagorce","first_name":"Thomas","last_name":"Lagorce"},
      {"full_name":"Jérémie Dumas","first_name":"Jérémie","last_name":"Dumas"},
      {"full_name":"Elie Attias","first_name":"Elie","last_name":"Attias"},
      {"full_name":"Emmanuelle Santos Souffir","first_name":"Emmanuelle","last_name":"Santos Souffir"},
      {"full_name":"Julien Vaillant","first_name":"Julien","last_name":"Vaillant"},
      {"full_name":"Cédric Nion","first_name":"Cédric","last_name":"Nion"},
      {"full_name":"Stéphane Mougenot","first_name":"Stéphane","last_name":"Mougenot"},
      {"full_name":"Damien Desanti","first_name":"Damien","last_name":"Desanti"}
]$json$
  ) AS (full_name TEXT, first_name TEXT, last_name TEXT)
)
INSERT INTO people (
  id, full_name, slug, first_name, last_name, legacy_source, created_at
)
SELECT
  uuid_generate_v4(), s.full_name,
  lower(regexp_replace(regexp_replace(unaccent(s.full_name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g')),
  s.first_name, s.last_name, 'funding_deals_september_2026_batch4', NOW()
FROM source s
ON CONFLICT (slug) DO NOTHING;

-- =============================================================================
-- Step 6: Link founders to organizations
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      {"org_name":"HighLife","founder_name":"Georg Börtlein"},
      {"org_name":"HighLife","founder_name":"Malek Nasr"},
      {"org_name":"HighLife","founder_name":"Rüdiger Lange"},
      {"org_name":"HighLife","founder_name":"Nicolo Piazza"},
      {"org_name":"Biolevate","founder_name":"Joël Belafa"},
      {"org_name":"Biolevate","founder_name":"Nathan Chen"},
      {"org_name":"Biolevate","founder_name":"Anas Laaroussi"},
      {"org_name":"Wealthcome","founder_name":"Cyprien Delmeule"},
      {"org_name":"Wealthcome","founder_name":"Éric Foin"},
      {"org_name":"Wealthcome","founder_name":"Morgan Emmery"},
      {"org_name":"Incepto Medical","founder_name":"Florence Moreau"},
      {"org_name":"Incepto Medical","founder_name":"Antoine Jomier"},
      {"org_name":"Incepto Medical","founder_name":"Gaspard d'Assignies"},
      {"org_name":"Kheops","founder_name":"Caroline Poinsignon"},
      {"org_name":"Kheops","founder_name":"Thibault Boyeux"},
      {"org_name":"Horizom","founder_name":"Stéphane Alzaix"},
      {"org_name":"Horizom","founder_name":"Christophe Downey"},
      {"org_name":"Horizom","founder_name":"Dimitri Guyot"},
      {"org_name":"Primo","founder_name":"Martin Pannier"},
      {"org_name":"Primo","founder_name":"Antoine de Mereuil"},
      {"org_name":"Primo","founder_name":"Nicolas Nallet"},
      {"org_name":"Zeliq","founder_name":"Dorian Ciavarella"},
      {"org_name":"Zeliq","founder_name":"Guillaume Cruz"},
      {"org_name":"Graneet","founder_name":"Jean-Gabriel Niel"},
      {"org_name":"Graneet","founder_name":"Enzo Dozias"},
      {"org_name":"Graneet","founder_name":"Raphaël Moulin"},
      {"org_name":"RelaiSanté","founder_name":"Etienne Boix"},
      {"org_name":"RelaiSanté","founder_name":"Pierre Godet"},
      {"org_name":"Reecall","founder_name":"Maxime Trouché"},
      {"org_name":"Reecall","founder_name":"Raphaël Szymocha"},
      {"org_name":"Lightspring","founder_name":"Grégoire Bonnat"},
      {"org_name":"Lightspring","founder_name":"Adrià Grabulosa"},
      {"org_name":"Lightspring","founder_name":"Daniel Brunner"},
      {"org_name":"IOPOLE","founder_name":"Dorian Keiflin"},
      {"org_name":"IOPOLE","founder_name":"Yoann Keiflin"},
      {"org_name":"IOPOLE","founder_name":"Nicolas Saudemont"},
      {"org_name":"IOPOLE","founder_name":"Gabriel Pala"},
      {"org_name":"WheelMove","founder_name":"Amaury Dupas"},
      {"org_name":"WheelMove","founder_name":"Kévin Surbled"},
      {"org_name":"LégiPilot","founder_name":"Victor Leclaire"},
      {"org_name":"LégiPilot","founder_name":"Marin de Surirey"},
      {"org_name":"AlphaYoda","founder_name":"Axel Bonaldo"},
      {"org_name":"AlphaYoda","founder_name":"Marion Bitoune"},
      {"org_name":"AlphaYoda","founder_name":"Cédric de Saint-Léger"},
      {"org_name":"AlphaYoda","founder_name":"Thomas Lagorce"},
      {"org_name":"Le Petit Lunetier","founder_name":"Jérémie Dumas"},
      {"org_name":"Le Petit Lunetier","founder_name":"Elie Attias"},
      {"org_name":"Herapreg","founder_name":"Emmanuelle Santos Souffir"},
      {"org_name":"Sinergy","founder_name":"Julien Vaillant"},
      {"org_name":"Sinergy","founder_name":"Cédric Nion"},
      {"org_name":"Sinergy","founder_name":"Stéphane Mougenot"},
      {"org_name":"Phocea DC","founder_name":"Damien Desanti"}
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
-- Step 7: Attach SIREN legal entities (French). Idempotent -- HighLife,
-- Wealthcome and Incepto Medical already carry their SIREN and are skipped.
-- =============================================================================
WITH source AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    $json$[
      {"org":"highlife","legal_name":"HIGHLIFE","siren":"529237695"},
      {"org":"biolevate","legal_name":"BIOLEVATE SAS","siren":"977728328"},
      {"org":"wealthcome","legal_name":"WEALTHCOME","siren":"909458531"},
      {"org":"incepto-medical","legal_name":"INCEPTO MEDICAL SAS","siren":"834926131"},
      {"org":"kheops","legal_name":"KHEOPS","siren":"897551834"},
      {"org":"horizom","legal_name":"HORIZOM","siren":"910035641"},
      {"org":"primo","legal_name":"CLUTCH","siren":"919404301"},
      {"org":"zeliq","legal_name":"GETHEROES","siren":"922560065"},
      {"org":"graneet","legal_name":"GABZO","siren":"881985014"},
      {"org":"relaisante","legal_name":"RELAISANTE","siren":"100709229"},
      {"org":"reecall","legal_name":"REECALL","siren":"842577017"},
      {"org":"lightspring","legal_name":"LIGHTSPRING","siren":"103414637"},
      {"org":"iopole","legal_name":"IOPOLE","siren":"922304308"},
      {"org":"wheelmove","legal_name":"WHEELMOVE","siren":"944431550"},
      {"org":"legipilot","legal_name":"LEGIPILOT","siren":"924992753"},
      {"org":"alphayoda","legal_name":"ALPHAYODA","siren":"990303638"},
      {"org":"le-petit-lunetier","legal_name":"LE PETIT LUNETIER PARIS SAS","siren":"809676356"},
      {"org":"herapreg","legal_name":"FEMMA","siren":"899848717"},
      {"org":"sinergy","legal_name":"SINERGY / NOSMEILLEURSPRODUCTEURS","siren":"814642740"},
      {"org":"phocea-dc","legal_name":"PHOCEA DC","siren":"952430049"}
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
FROM funding_rounds WHERE source_name = 'funding_deals_september_2026_batch4'
UNION ALL
SELECT 'Investor Links', COUNT(*)
FROM funding_round_investors fri JOIN funding_rounds fr ON fr.id = fri.funding_round_id
WHERE fr.source_name = 'funding_deals_september_2026_batch4'
UNION ALL
SELECT 'Founder People (new)', COUNT(*)
FROM people WHERE legacy_source = 'funding_deals_september_2026_batch4';
