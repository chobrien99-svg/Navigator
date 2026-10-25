-- =============================================================================
-- October 2026 Funding Deals Import — Week 4 (10 deals)
-- =============================================================================
-- source_name 'funding_deals_october_2026_week4'. Amounts in millions.
-- 6 new organizations (Elax Énergie, Bageera, Reduck, 3Pay, Pesia, Lift) +
-- 4 existing that each get a new, distinct round (Pigment, Sintermat, Weflayr,
-- Dyameo — verified: none of their prior rounds match this batch's stage/date).
--
-- All 11 provided SIRENs were verified against the French business registry
-- (recherche-entreprises.api.gouv.fr); every one matches its company.
--
-- Data-quality notes:
--   * Dyameo: its SIREN 828605386 (registry name DYAMEO) currently sits on a
--     separate duplicate record 'diagnostic-medical-in-vivo-dmiv' (legacy 'ilab',
--     the company's former name Diagnostic Medical In Vivo). The new round is
--     attached to the 'dyameo' brand org. The SIREN is NOT added here; it is
--     re-pointed to 'dyameo' by the companion merge migration (02_merge_dmiv…).
--   * Reduck: brand name 'Reduck'; legal entity CONCEPTION AI (SIREN 992141085).
--     Dual HQ San Francisco / Paris.
--   * leZèbre (SIREN 977814847) was listed in the source but had no deal card;
--     no record created (flagged to the user).
--
-- Currency / estimate handling (USD→EUR ≈ 0.86):
--   * Weflayr $2.5M (≈€2.15M), Reduck $3M (≈€2.58M) -> amount_eur estimated.
--   * Pigment: card headline €223M (= the round's $250M Series E); stored as EUR.
--   * Lift: amount undisclosed -> amount_eur NULL, stage 'growth'.
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "unaccent";
ALTER TABLE organizations ADD COLUMN IF NOT EXISTS secondary_city_id UUID REFERENCES cities(id) ON DELETE SET NULL;

-- Step 0: cities (Venarey-les-Laumes is new; the rest already exist)
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"name":"Paris","country":"France"},{"name":"Lyon","country":"France"},
  {"name":"Limoges","country":"France"},{"name":"Venarey-les-Laumes","country":"France"},
  {"name":"San Francisco","country":"USA"}
]$json$) AS (name TEXT, country TEXT))
INSERT INTO cities (id, name, slug, country, created_at, updated_at)
SELECT uuid_generate_v4(), s.name, lower(regexp_replace(regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g')), s.country, NOW(), NOW()
FROM source s ON CONFLICT (slug) DO NOTHING;

-- Step 1: organizations (new + existing upserted)
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"name":"Pigment","website":"https://www.pigment.com","description":"Develops an AI-powered business planning and performance management platform that enables companies to forecast revenue, model financial scenarios, manage budgets, and coordinate operational planning. Its Graphite engine supports autonomous AI agents that can analyze business data and execute planning workflows."},
  {"name":"Elax Énergie","website":"https://www.elaxenergie.com","description":"Develops connected thermostats and software that optimize the energy consumption of electric water heaters. Its technology adjusts heating schedules based on household needs and electricity availability, turning existing water heaters into distributed thermal energy storage assets that can provide flexibility to the electrical grid."},
  {"name":"Bageera","website":"https://bageera.ai/","description":"Builds a group of electrical engineering, HVAC, maintenance and industrial supervision businesses, using proprietary agentic AI tools to improve operations and technical service delivery."},
  {"name":"Sintermat","website":"https://sinter-mat.com","description":"Develops and manufactures advanced industrial materials using Spark Plasma Sintering (SPS), a powder-metallurgy process that produces high-performance metal, ceramic, and composite components. Its technology targets demanding applications in aerospace, defense, nuclear energy, automotive manufacturing, and industrial tooling."},
  {"name":"Dyameo","website":"https://www.dyameo.com","description":"Develops medical devices that help surgeons detect residual cancerous tissue during operations. Its TempoTouch system combines patented biological reagents, an optical probe, and real-time analysis to assess whether surgeons have completely removed tumor tissue."},
  {"name":"Weflayr","website":"https://weflayr.com","description":"Develops an intelligent AI gateway that benchmarks language models against customers' real production workloads and dynamically routes requests to the most appropriate models, optimizing inference costs, output quality, and application margins."},
  {"name":"Reduck","website":"https://reduck.ai","description":"Develops infrastructure that allows AI agents to interact with websites and business applications without conventional APIs. Its Reduck MCP platform lets agents discover, create, and run reusable browser automation scripts instead of navigating interfaces through repeated clicking and typing. Legal entity Conception AI."},
  {"name":"3Pay","website":"https://www.3pay.fr/","description":"Develops a payment card and software infrastructure allowing patients to pay medical expenses without advancing the amounts covered by their health insurance. The technology connects insurers, healthcare providers, and policyholders and verifies coverage before authorizing payments."},
  {"name":"Pesia","website":"https://pesia.fr/","description":"Develops Pesia OS, a payroll management platform designed for temporary staffing agencies. The software connects with applicant tracking systems and staffing platforms, automates regulatory updates, and detects payroll anomalies before statutory declarations are submitted. Pesia is also developing AI agents to automate payroll verification and repetitive administrative tasks."},
  {"name":"Lift","website":"https://www.lift-ed.fr","description":"Develops educational content and digital tools for adolescents covering emotional and relational development, mental health, harassment and violence prevention, used by schools, sports organizations and youth associations."}
]$json$) AS (name TEXT, website TEXT, description TEXT))
INSERT INTO organizations (id, name, slug, organization_type, description, website, status, country, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), s.name, lower(regexp_replace(regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g')), 'startup'::organization_type, s.description, s.website, 'active'::organization_status, 'France', 'funding_deals_october_2026_week4', NOW(), NOW()
FROM source s
ON CONFLICT (slug) DO UPDATE SET website=COALESCE(organizations.website, EXCLUDED.website), description=COALESCE(organizations.description, EXCLUDED.description), updated_at=NOW();

-- Step 1b: city links (primary; secondary for dual-HQ). COALESCE keeps existing.
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"org_name":"Pigment","city":"Paris","secondary_city":null},
  {"org_name":"Elax Énergie","city":"Paris","secondary_city":null},
  {"org_name":"Bageera","city":"Paris","secondary_city":null},
  {"org_name":"Sintermat","city":"Venarey-les-Laumes","secondary_city":null},
  {"org_name":"Dyameo","city":"Limoges","secondary_city":null},
  {"org_name":"Weflayr","city":"Paris","secondary_city":null},
  {"org_name":"Reduck","city":"San Francisco","secondary_city":"Paris"},
  {"org_name":"3Pay","city":"Lyon","secondary_city":null},
  {"org_name":"Pesia","city":"Paris","secondary_city":null},
  {"org_name":"Lift","city":"Paris","secondary_city":null}
]$json$) AS (org_name TEXT, city TEXT, secondary_city TEXT))
UPDATE organizations o SET city_id=COALESCE(o.city_id,c1.id), secondary_city_id=COALESCE(o.secondary_city_id,c2.id), updated_at=NOW()
FROM source s
LEFT JOIN cities c1 ON c1.slug=lower(regexp_replace(regexp_replace(unaccent(s.city), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g'))
LEFT JOIN cities c2 ON c2.slug=lower(regexp_replace(regexp_replace(unaccent(s.secondary_city), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g'))
WHERE o.slug=lower(regexp_replace(regexp_replace(unaccent(s.org_name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g'));

-- Step 2: funding rounds (10)
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"name":"Pigment","stage":"series_e","amount_eur":223.0,"currency_original":"EUR","amount_original":223000000,"announced_date":"2026-10-21","notes":"€223M Series E (= the $250M round) led by EQT's Scaleup Europe Fund to accelerate its autonomous business planning platform and expand internationally. Surpassed $100M ARR, doubling YoY; AI agents now create 85% of new metrics. Customers incl. Danone, Siemens, Snowflake, Unilever, Anthropic, ElevenLabs, Uber. NVIDIA participation described as planned in the official release. Investors: Scaleup Europe Fund (EQT), World Innovation Lab, Greenoaks, ICONIQ, IVP, Meritech, NVIDIA. Source: Pigment."},
  {"name":"Elax Énergie","stage":"growth","amount_eur":30.0,"currency_original":"EUR","amount_original":30000000,"announced_date":"2026-10-20","notes":"€30M from Noria and Crédit Mutuel Impact to expand its connected water-heater technology and enter new markets. ~100,000 homes equipped; 100+ social housing providers. Reduces domestic hot-water electricity ~20-25%. Funds Elax Pro (plumber/electrician network), collective-boiler electrification, and 30 hires by end-2027. Investors: Noria, Fonds Révolution Environnementale et Solidaire, Crédit Mutuel Impact. Source: Tecsol Quotidien, FrenchWeb."},
  {"name":"Bageera","stage":"growth","amount_eur":10.0,"currency_original":"EUR","amount_original":10000000,"announced_date":"2026-10-20","notes":"€10M announced financing plus the acquisition of a majority stake in CSM Groupe (French industrial services, ~€20M revenue, 100 employees; electrical/climate engineering for nuclear, data centers, defense). Split between acquisition and operating investment not disclosed. Plans to acquire and develop specialist companies while deploying its agentic AI. Investors: Varsity, Eurazeo, Frst, Banyan Ventures. Source: Bageera LinkedIn, CFNEWS."},
  {"name":"Sintermat","stage":"growth","amount_eur":6.0,"currency_original":"EUR","amount_original":6000000,"announced_date":"2026-10-13","notes":"€6M to accelerate industrial production of advanced materials, bringing Orano Venture Fund into the shareholder base. Funds a 4x capacity expansion, facility modernization, automation and certifications (aerospace, nuclear); plans to triple the production workforce over two years. 15 patent families, 100+ customers. Fresh capital, not a republication of its earlier €6M Series A (2022). Investors: Orano Venture Fund, Definvest, Bpifrance, Safran Corporate Ventures, UI Investissement. Source: Les Echos."},
  {"name":"Dyameo","stage":"growth","amount_eur":3.0,"currency_original":"EUR","amount_original":3000000,"announced_date":"2026-10-22","notes":"€3M to prepare the commercial launch of TempoTouch (intra-operative residual-cancer detection). Completed an initial clinical study across six French surgical centers; pursuing CE marking. Funds device/reagent production, commercial hiring, and international oncology-center expansion. 7 employees. Medevice Capital and NACO reinvested; Bpifrance, OBRATORI, Estellior Capital joined. Investors: Medevice Capital, NACO, Bpifrance, OBRATORI, Estellior Capital, Business Angels. Source: Bpifrance."},
  {"name":"Weflayr","stage":"pre_seed","amount_eur":2.15,"currency_original":"USD","amount_original":2500000,"announced_date":"2026-10-22","notes":"$2.5M (~€2.15M est.) pre-seed led by 13books Capital to develop an AI inference gateway that selects models based on real customer-workload performance. Mazeries is ex-co-founder of Mangopay. Claims inference costs >55% lower and quality up 15%. Funds engineering, AI research, product and EU/US expansion. Investors: 13books Capital, Founders Future, Kima Ventures, Plug and Play Europe, Station F, Roxanne Varza, Business Angels. Source: Startup.eu, France AI Radar."},
  {"name":"Reduck","stage":"pre_seed","amount_eur":2.58,"currency_original":"USD","amount_original":3000000,"announced_date":"2026-10-22","notes":"$3M (~€2.58M est.) pre-seed led by Daphni to expand its browser-automation infrastructure for AI agents (Reduck MCP). Library of 1,200+ scripts over 250+ websites; claims ~3x faster/cheaper agent tasks. Expanded to 8 employees; funds reliability, self-maintaining scripts, a developer offering for API-less apps, and GEO. French-American; dual HQ San Francisco/Paris. Investors: Daphni, Drysdale Ventures, Galion.exe, Business Angels, Olivier Pomel, Florian Douetteau, Guillaume Lample, Marie Brayer, Lucas Fischer, Xavier Fischer, Yann Lechelle, Raphaël Vullierme, Margaux Wehr, Nicolas Drizard, Hugo Dobbelaere, Florian Grison, Valentine Baudouin, Guillaume Roux-Romestaing, Noé Gersanois. Source: Reduck, Tech.eu."},
  {"name":"3Pay","stage":"seed","amount_eur":1.5,"currency_original":"EUR","amount_original":1500000,"announced_date":"2026-10-16","notes":"€1.5M round plus the acquisition of MoneyTrack (French payment-verification fintech; 9 employees, 4 mutual insurers, 300,000+ beneficiaries). Combined business valued ~€6.2M; acquisition price undisclosed. Plans to expand beyond health insurance via Tyris (auto/property) and internationally. Investors: Truffle Capital, Accurafy, SideAngels. Source: Maddyness."},
  {"name":"Pesia","stage":"seed","amount_eur":0.5,"currency_original":"EUR","amount_original":500000,"announced_date":"2026-10-14","notes":"€500K first round to accelerate deployment of Pesia OS, a payroll platform for temporary staffing agencies. In production with first customers since Sept 1, 2026. Company-reported: ~1,000 payslips/admin/month (vs 400), 10,000 payslips in under ten minutes; next phase adds AI agents targeting 4,000 payslips/admin/month (figures not independently validated). Investors: Business Angels. Source: LinkedIn."},
  {"name":"Lift","stage":"growth","amount_eur":null,"currency_original":null,"amount_original":null,"announced_date":"2026-10-20","notes":"Undisclosed amount. Kima Ventures and SideAngels joined the shareholder base to finance new educational content and expansion beyond schools into sports clubs, associations and youth organizations. Partnerships with 300 organizations across 20+ French departments, 150,000+ adolescents, 2,500+ teachers/educators. Founders retain strategic and editorial control. Investors: Kima Ventures, SideAngels. Source: Lift."}
]$json$) AS (name TEXT, stage TEXT, amount_eur NUMERIC, currency_original TEXT, amount_original NUMERIC, announced_date TEXT, notes TEXT))
INSERT INTO funding_rounds (id, organization_id, stage, amount_eur, currency_original, amount_original, announced_date, is_estimated, is_verified, source_name, notes, created_at)
SELECT uuid_generate_v4(), o.id, s.stage::funding_stage, s.amount_eur, s.currency_original, s.amount_original, s.announced_date::DATE,
  CASE WHEN s.currency_original IS NOT NULL AND s.currency_original!='EUR' AND s.amount_eur IS NOT NULL THEN TRUE ELSE FALSE END, FALSE, 'funding_deals_october_2026_week4', s.notes, NOW()
FROM source s JOIN organizations o ON o.slug=lower(regexp_replace(regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g'));

-- Step 3a: investor organizations (idempotent; existing ones are skipped)
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"name":"Scaleup Europe Fund"},{"name":"World Innovation Lab"},{"name":"Greenoaks"},{"name":"ICONIQ"},{"name":"IVP"},{"name":"Meritech"},{"name":"NVIDIA"},
  {"name":"Noria"},{"name":"Fonds Révolution Environnementale et Solidaire"},{"name":"Crédit Mutuel Impact"},
  {"name":"Varsity"},{"name":"Eurazeo"},{"name":"Frst"},{"name":"Banyan Ventures"},
  {"name":"Orano Venture Fund"},{"name":"Definvest"},{"name":"Bpifrance"},{"name":"Safran Corporate Ventures"},{"name":"UI Investissement"},
  {"name":"Medevice Capital"},{"name":"NACO"},{"name":"OBRATORI"},{"name":"Estellior Capital"},{"name":"Business Angels"},
  {"name":"13books Capital"},{"name":"Founders Future"},{"name":"Kima Ventures"},{"name":"Plug and Play Europe"},{"name":"Station F"},{"name":"Roxanne Varza"},
  {"name":"Daphni"},{"name":"Drysdale Ventures"},{"name":"Galion.exe"},{"name":"Olivier Pomel"},{"name":"Florian Douetteau"},{"name":"Guillaume Lample"},{"name":"Marie Brayer"},{"name":"Lucas Fischer"},{"name":"Xavier Fischer"},{"name":"Yann Lechelle"},{"name":"Raphaël Vullierme"},{"name":"Margaux Wehr"},{"name":"Nicolas Drizard"},{"name":"Hugo Dobbelaere"},{"name":"Florian Grison"},{"name":"Valentine Baudouin"},{"name":"Guillaume Roux-Romestaing"},{"name":"Noé Gersanois"},
  {"name":"Truffle Capital"},{"name":"Accurafy"},{"name":"SideAngels"}
]$json$) AS (name TEXT))
INSERT INTO organizations (id, name, slug, organization_type, status, country, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), s.name, lower(regexp_replace(regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g')), 'investor'::organization_type, 'active'::organization_status, 'France', 'funding_deals_october_2026_week4', NOW(), NOW()
FROM source s ON CONFLICT (slug) DO NOTHING;

-- Step 3b: funding round investors (joined on org + source). Pesia has only
-- "Business Angels"; all links de-duplicated via NOT EXISTS.
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"org_name":"Pigment","investor_name":"Scaleup Europe Fund","is_lead":true},{"org_name":"Pigment","investor_name":"World Innovation Lab","is_lead":false},{"org_name":"Pigment","investor_name":"Greenoaks","is_lead":false},{"org_name":"Pigment","investor_name":"ICONIQ","is_lead":false},{"org_name":"Pigment","investor_name":"IVP","is_lead":false},{"org_name":"Pigment","investor_name":"Meritech","is_lead":false},{"org_name":"Pigment","investor_name":"NVIDIA","is_lead":false},
  {"org_name":"Elax Énergie","investor_name":"Noria","is_lead":false},{"org_name":"Elax Énergie","investor_name":"Fonds Révolution Environnementale et Solidaire","is_lead":false},{"org_name":"Elax Énergie","investor_name":"Crédit Mutuel Impact","is_lead":false},
  {"org_name":"Bageera","investor_name":"Varsity","is_lead":false},{"org_name":"Bageera","investor_name":"Eurazeo","is_lead":false},{"org_name":"Bageera","investor_name":"Frst","is_lead":false},{"org_name":"Bageera","investor_name":"Banyan Ventures","is_lead":false},
  {"org_name":"Sintermat","investor_name":"Orano Venture Fund","is_lead":false},{"org_name":"Sintermat","investor_name":"Definvest","is_lead":false},{"org_name":"Sintermat","investor_name":"Bpifrance","is_lead":false},{"org_name":"Sintermat","investor_name":"Safran Corporate Ventures","is_lead":false},{"org_name":"Sintermat","investor_name":"UI Investissement","is_lead":false},
  {"org_name":"Dyameo","investor_name":"Medevice Capital","is_lead":false},{"org_name":"Dyameo","investor_name":"NACO","is_lead":false},{"org_name":"Dyameo","investor_name":"Bpifrance","is_lead":false},{"org_name":"Dyameo","investor_name":"OBRATORI","is_lead":false},{"org_name":"Dyameo","investor_name":"Estellior Capital","is_lead":false},{"org_name":"Dyameo","investor_name":"Business Angels","is_lead":false},
  {"org_name":"Weflayr","investor_name":"13books Capital","is_lead":true},{"org_name":"Weflayr","investor_name":"Founders Future","is_lead":false},{"org_name":"Weflayr","investor_name":"Kima Ventures","is_lead":false},{"org_name":"Weflayr","investor_name":"Plug and Play Europe","is_lead":false},{"org_name":"Weflayr","investor_name":"Station F","is_lead":false},{"org_name":"Weflayr","investor_name":"Roxanne Varza","is_lead":false},{"org_name":"Weflayr","investor_name":"Business Angels","is_lead":false},
  {"org_name":"Reduck","investor_name":"Daphni","is_lead":true},{"org_name":"Reduck","investor_name":"Drysdale Ventures","is_lead":false},{"org_name":"Reduck","investor_name":"Galion.exe","is_lead":false},{"org_name":"Reduck","investor_name":"Business Angels","is_lead":false},{"org_name":"Reduck","investor_name":"Olivier Pomel","is_lead":false},{"org_name":"Reduck","investor_name":"Florian Douetteau","is_lead":false},{"org_name":"Reduck","investor_name":"Guillaume Lample","is_lead":false},{"org_name":"Reduck","investor_name":"Marie Brayer","is_lead":false},{"org_name":"Reduck","investor_name":"Lucas Fischer","is_lead":false},{"org_name":"Reduck","investor_name":"Xavier Fischer","is_lead":false},{"org_name":"Reduck","investor_name":"Yann Lechelle","is_lead":false},{"org_name":"Reduck","investor_name":"Raphaël Vullierme","is_lead":false},{"org_name":"Reduck","investor_name":"Margaux Wehr","is_lead":false},{"org_name":"Reduck","investor_name":"Nicolas Drizard","is_lead":false},{"org_name":"Reduck","investor_name":"Hugo Dobbelaere","is_lead":false},{"org_name":"Reduck","investor_name":"Florian Grison","is_lead":false},{"org_name":"Reduck","investor_name":"Valentine Baudouin","is_lead":false},{"org_name":"Reduck","investor_name":"Guillaume Roux-Romestaing","is_lead":false},{"org_name":"Reduck","investor_name":"Noé Gersanois","is_lead":false},
  {"org_name":"3Pay","investor_name":"Truffle Capital","is_lead":false},{"org_name":"3Pay","investor_name":"Accurafy","is_lead":false},{"org_name":"3Pay","investor_name":"SideAngels","is_lead":false},
  {"org_name":"Pesia","investor_name":"Business Angels","is_lead":false},
  {"org_name":"Lift","investor_name":"Kima Ventures","is_lead":false},{"org_name":"Lift","investor_name":"SideAngels","is_lead":false}
]$json$) AS (org_name TEXT, investor_name TEXT, is_lead BOOLEAN))
INSERT INTO funding_round_investors (id, funding_round_id, investor_id, is_lead, investor_name, created_at)
SELECT uuid_generate_v4(), fr.id, inv.id, s.is_lead, s.investor_name, NOW()
FROM source s
JOIN organizations o ON o.slug=lower(regexp_replace(regexp_replace(unaccent(s.org_name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g'))
JOIN organizations inv ON inv.slug=lower(regexp_replace(regexp_replace(unaccent(s.investor_name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g'))
JOIN funding_rounds fr ON fr.organization_id=o.id AND fr.source_name='funding_deals_october_2026_week4'
WHERE NOT EXISTS (SELECT 1 FROM funding_round_investors x WHERE x.funding_round_id=fr.id AND x.investor_id=inv.id);

-- Step 4a: sector links (idempotent; only existing sector slugs used)
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"org":"pigment","sec":"artificial-intelligence"},{"org":"pigment","sec":"saas"},
  {"org":"elax-energie","sec":"climatetech"},{"org":"elax-energie","sec":"energy"},
  {"org":"bageera","sec":"climatetech"},{"org":"bageera","sec":"artificial-intelligence"},
  {"org":"sintermat","sec":"deeptech"},
  {"org":"dyameo","sec":"medtech"},{"org":"dyameo","sec":"healthtech"},
  {"org":"weflayr","sec":"artificial-intelligence"},{"org":"weflayr","sec":"saas"},
  {"org":"reduck","sec":"artificial-intelligence"},{"org":"reduck","sec":"saas"},
  {"org":"3pay","sec":"fintech"},{"org":"3pay","sec":"healthtech"},{"org":"3pay","sec":"insurtech"},
  {"org":"pesia","sec":"hrtech"},{"org":"pesia","sec":"saas"},{"org":"pesia","sec":"artificial-intelligence"},
  {"org":"lift","sec":"edtech"},{"org":"lift","sec":"healthtech"},{"org":"lift","sec":"saas"}
]$json$) AS (org TEXT, sec TEXT))
INSERT INTO organization_sectors (id, organization_id, sector_id, is_primary, created_at)
SELECT uuid_generate_v4(), o.id, sec.id, FALSE, NOW()
FROM source s JOIN organizations o ON o.slug=s.org JOIN sectors sec ON sec.slug=s.sec
ON CONFLICT (organization_id, sector_id) DO NOTHING;

-- Step 4b: promote primary where none exists
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"org":"pigment","sec":"artificial-intelligence"},{"org":"elax-energie","sec":"climatetech"},{"org":"bageera","sec":"climatetech"},{"org":"sintermat","sec":"deeptech"},{"org":"dyameo","sec":"medtech"},{"org":"weflayr","sec":"artificial-intelligence"},{"org":"reduck","sec":"artificial-intelligence"},{"org":"3pay","sec":"fintech"},{"org":"pesia","sec":"hrtech"},{"org":"lift","sec":"edtech"}
]$json$) AS (org TEXT, sec TEXT))
UPDATE organization_sectors os SET is_primary=TRUE
FROM source s JOIN organizations o ON o.slug=s.org JOIN sectors sec ON sec.slug=s.sec
WHERE os.organization_id=o.id AND os.sector_id=sec.id
  AND NOT EXISTS (SELECT 1 FROM organization_sectors x WHERE x.organization_id=o.id AND x.is_primary=TRUE);

-- Step 5: people (founders)
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"full_name":"Eléonore Crespo","first_name":"Eléonore","last_name":"Crespo"},{"full_name":"Romain Niccoli","first_name":"Romain","last_name":"Niccoli"},
  {"full_name":"Jean-François Eggericx","first_name":"Jean-François","last_name":"Eggericx"},{"full_name":"Thomas Tirtiaux","first_name":"Thomas","last_name":"Tirtiaux"},{"full_name":"Samuel Beaussier","first_name":"Samuel","last_name":"Beaussier"},
  {"full_name":"Adrien Leblanc","first_name":"Adrien","last_name":"Leblanc"},{"full_name":"Maxime Prieto","first_name":"Maxime","last_name":"Prieto"},{"full_name":"Maxime Privat Thierry","first_name":"Maxime","last_name":"Privat Thierry"},{"full_name":"Samuel Palti","first_name":"Samuel","last_name":"Palti"},
  {"full_name":"Foad Naimi","first_name":"Foad","last_name":"Naimi"},
  {"full_name":"Cédric Enguehard","first_name":"Cédric","last_name":"Enguehard"},{"full_name":"Virgile Barret-Vivin","first_name":"Virgile","last_name":"Barret-Vivin"},{"full_name":"Alexis Saintamand","first_name":"Alexis","last_name":"Saintamand"},
  {"full_name":"Romain Mazeries","first_name":"Romain","last_name":"Mazeries"},{"full_name":"Noé Achache","first_name":"Noé","last_name":"Achache"},
  {"full_name":"Daniel Huynh","first_name":"Daniel","last_name":"Huynh"},{"full_name":"Louis Abraham","first_name":"Louis","last_name":"Abraham"},{"full_name":"Raphaël Millet","first_name":"Raphaël","last_name":"Millet"},
  {"full_name":"Jérémy Benhaïm","first_name":"Jérémy","last_name":"Benhaïm"},
  {"full_name":"Stanislas Denis","first_name":"Stanislas","last_name":"Denis"},{"full_name":"Fabien Lefrançois","first_name":"Fabien","last_name":"Lefrançois"},
  {"full_name":"Lauren Onthank","first_name":"Lauren","last_name":"Onthank"},{"full_name":"Clément Chaudet","first_name":"Clément","last_name":"Chaudet"}
]$json$) AS (full_name TEXT, first_name TEXT, last_name TEXT))
INSERT INTO people (id, full_name, slug, first_name, last_name, legacy_source, created_at)
SELECT uuid_generate_v4(), s.full_name, lower(regexp_replace(regexp_replace(unaccent(s.full_name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g')), s.first_name, s.last_name, 'funding_deals_october_2026_week4', NOW()
FROM source s ON CONFLICT (slug) DO NOTHING;

-- Step 6: founder links
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"org_name":"Pigment","founder_name":"Eléonore Crespo"},{"org_name":"Pigment","founder_name":"Romain Niccoli"},
  {"org_name":"Elax Énergie","founder_name":"Jean-François Eggericx"},{"org_name":"Elax Énergie","founder_name":"Thomas Tirtiaux"},{"org_name":"Elax Énergie","founder_name":"Samuel Beaussier"},
  {"org_name":"Bageera","founder_name":"Adrien Leblanc"},{"org_name":"Bageera","founder_name":"Maxime Prieto"},{"org_name":"Bageera","founder_name":"Maxime Privat Thierry"},{"org_name":"Bageera","founder_name":"Samuel Palti"},
  {"org_name":"Sintermat","founder_name":"Foad Naimi"},
  {"org_name":"Dyameo","founder_name":"Cédric Enguehard"},{"org_name":"Dyameo","founder_name":"Virgile Barret-Vivin"},{"org_name":"Dyameo","founder_name":"Alexis Saintamand"},
  {"org_name":"Weflayr","founder_name":"Romain Mazeries"},{"org_name":"Weflayr","founder_name":"Noé Achache"},
  {"org_name":"Reduck","founder_name":"Daniel Huynh"},{"org_name":"Reduck","founder_name":"Louis Abraham"},{"org_name":"Reduck","founder_name":"Raphaël Millet"},
  {"org_name":"3Pay","founder_name":"Jérémy Benhaïm"},
  {"org_name":"Pesia","founder_name":"Stanislas Denis"},{"org_name":"Pesia","founder_name":"Fabien Lefrançois"},
  {"org_name":"Lift","founder_name":"Lauren Onthank"},{"org_name":"Lift","founder_name":"Clément Chaudet"}
]$json$) AS (org_name TEXT, founder_name TEXT))
INSERT INTO organization_people (id, organization_id, person_id, role, is_current, is_founder, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, p.id, 'Founder', TRUE, TRUE, NOW(), NOW()
FROM source s
JOIN organizations o ON o.slug=lower(regexp_replace(regexp_replace(unaccent(s.org_name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g'))
JOIN people p ON p.slug=lower(regexp_replace(regexp_replace(unaccent(s.founder_name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g'))
ON CONFLICT (organization_id, person_id, role) DO NOTHING;

-- Step 7: SIREN legal entities. Idempotent. Dyameo (SIREN 828605386) is handled
-- by 02_merge_dmiv_into_dyameo.sql (re-points the existing DMIV legal entity),
-- so it is intentionally omitted here. Pigment and Weflayr already hold their
-- SIRENs; the NOT EXISTS guard makes those rows no-ops.
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"org":"pigment","legal_name":"PIGMENT","siren":"852785914"},
  {"org":"elax-energie","legal_name":"ELAX ENERGIE","siren":"817839343"},
  {"org":"bageera","legal_name":"BAGEERA","siren":"992440438"},
  {"org":"sintermat","legal_name":"SINTERMAT","siren":"822982799"},
  {"org":"weflayr","legal_name":"WEFLAYR","siren":"103332649"},
  {"org":"reduck","legal_name":"CONCEPTION AI","siren":"992141085"},
  {"org":"3pay","legal_name":"3PAY","siren":"885303495"},
  {"org":"pesia","legal_name":"PESIA","siren":"999806946"},
  {"org":"lift","legal_name":"LIFT","siren":"932852742"}
]$json$) AS (org TEXT, legal_name TEXT, siren TEXT))
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, s.legal_name, s.siren, 'France', NOT EXISTS (SELECT 1 FROM legal_entities le2 WHERE le2.organization_id=o.id), NOW(), NOW()
FROM source s JOIN organizations o ON o.slug=s.org
WHERE NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id=o.id AND le.siren=s.siren);

-- Verification
SELECT 'Funding Rounds' AS entity, COUNT(*) AS count FROM funding_rounds WHERE source_name='funding_deals_october_2026_week4'
UNION ALL SELECT 'Investor Links', COUNT(*) FROM funding_round_investors fri JOIN funding_rounds fr ON fr.id=fri.funding_round_id WHERE fr.source_name='funding_deals_october_2026_week4'
UNION ALL SELECT 'New Orgs', COUNT(*) FROM organizations WHERE legacy_source='funding_deals_october_2026_week4' AND organization_type='startup'
UNION ALL SELECT 'Founder People (new)', COUNT(*) FROM people WHERE legacy_source='funding_deals_october_2026_week4';
