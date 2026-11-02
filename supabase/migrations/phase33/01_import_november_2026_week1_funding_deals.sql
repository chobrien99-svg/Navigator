-- =============================================================================
-- November 2026 Funding Deals Import — Week 1 (9 deals, announced Oct 5–29 2026)
-- =============================================================================
-- source_name 'funding_deals_november_2026_week1'. Amounts in millions, EUR.
--
-- 5 new orgs (Inevitable, AQQI, Aíma, PINT, Playa Rent) + existing orgs that
-- each get a new, distinct round (Wormsensing, Entroview, Bcell Design). All 9
-- SIRENs were verified against the French business registry.
--
-- Special cases:
--   * Bleu Robotics: its €5M pre-seed (2026-10-29, source 'The French Tech
--     Journal') was ALREADY in the DB with no investor links. No new round is
--     created; this migration only attaches its two co-leads (Contrarian
--     Ventures, OVNI Capital) and ensures its founders/sectors. (Step 3c.)
--   * Wormsensing: duplicate records 'wormsensing' (brand, 2022 seed, sectors,
--     city) and 'worms-sensing' (legacy 'ilab', holds SIREN 880418033). The new
--     Series A is attached to 'wormsensing'; the SIREN is re-pointed by the
--     companion merge migration (02_merge_worms_sensing…), so it is omitted from
--     Step 7 here.
--   * AQQI: legal entity is DIRECTLAYER (SIREN 100013937) — user-confirmed.
--   * Bcell Design: existing org slug 'b-cell-design'; €400K convertible-bond
--     round recorded with stage 'undisclosed'.
--   * Entroview: undisclosed Series A (amount_eur NULL). Investors: Covéa (lead),
--     Ventech, Rethink Ventures, Exergon. (The news names AFI Ventures, which is a
--     fund operated by Ventech — same investor.)
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "unaccent";
ALTER TABLE organizations ADD COLUMN IF NOT EXISTS secondary_city_id UUID REFERENCES cities(id) ON DELETE SET NULL;

-- Step 0: cities (Pornic is new; the rest already exist)
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"name":"Paris","country":"France"},{"name":"Seyssinet-Pariset","country":"France"},
  {"name":"Bordeaux","country":"France"},{"name":"Meylan","country":"France"},
  {"name":"Metz","country":"France"},{"name":"Illkirch-Graffenstaden","country":"France"},
  {"name":"Pornic","country":"France"}
]$json$) AS (name TEXT, country TEXT))
INSERT INTO cities (id, name, slug, country, created_at, updated_at)
SELECT uuid_generate_v4(), s.name, lower(regexp_replace(regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g')), s.country, NOW(), NOW()
FROM source s ON CONFLICT (slug) DO NOTHING;

-- Step 1: new organizations (existing ones are left untouched here)
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"name":"Inevitable","slug":"inevitable","website":"https://www.inevitable.click","description":"Develops a proprietary AI-assisted filmmaking pipeline that converts animated previsualizations into photorealistic feature films. The approach lets directors set camera movements, staging, and visual composition before AI generates the final imagery."},
  {"name":"AQQI","slug":"aqqi","website":"https://aqqi.com/","description":"Develops an AI-powered personal assistant that helps prospective homebuyers identify properties, contact real estate agencies, obtain information, organize viewings, and manage the administrative steps involved in purchasing a home. The service is free for buyers; revenue comes from partnerships with real estate professionals."},
  {"name":"Aíma","slug":"aima","website":"https://www.aima-diagnostics.com/","description":"Develops AI-powered liquid biopsy tests for early cancer detection and monitoring. Its technology combines DNA methylation analysis, fragmentomics, and sequencing of circulating cell-free DNA to identify tumor-associated signals in blood samples and potentially determine their tissue of origin."},
  {"name":"PINT","slug":"pint","website":"https://pint.fr/","description":"Develops high-performance metal alloys engineered for additive manufacturing. The company designs and qualifies customized materials, develops metal powders and 3D-printing parameters, and produces initial components for industrial customers. Its work includes aluminum and titanium alloys, as well as materials incorporating recycled metals."},
  {"name":"Playa Rent","slug":"playa-rent","website":"https://www.playa-rent.fr/","description":"Designs and manufactures autonomous rental stations for water sports equipment, including paddleboards and kayaks. Its self-service technology lets customers unlock equipment with their smartphones, without advance reservations or on-site staff. Stations are sold to ports, municipalities, nautical clubs, and tourism operators, which manage pricing and retain rental revenue."}
]$json$) AS (name TEXT, slug TEXT, website TEXT, description TEXT))
INSERT INTO organizations (id, name, slug, organization_type, description, website, status, country, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), s.name, s.slug, 'startup'::organization_type, s.description, s.website, 'active'::organization_status, 'France', 'funding_deals_november_2026_week1', NOW(), NOW()
FROM source s
ON CONFLICT (slug) DO UPDATE SET website=COALESCE(organizations.website, EXCLUDED.website), description=COALESCE(organizations.description, EXCLUDED.description), updated_at=NOW();

-- Step 1b: city links (COALESCE keeps any existing value)
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"slug":"inevitable","city":"Paris"},
  {"slug":"wormsensing","city":"Seyssinet-Pariset"},
  {"slug":"aqqi","city":"Bordeaux"},
  {"slug":"aima","city":"Meylan"},
  {"slug":"pint","city":"Metz"},
  {"slug":"entroview","city":"Paris"},
  {"slug":"b-cell-design","city":"Illkirch-Graffenstaden"},
  {"slug":"playa-rent","city":"Pornic"}
]$json$) AS (slug TEXT, city TEXT))
UPDATE organizations o SET city_id=COALESCE(o.city_id,c1.id), updated_at=NOW()
FROM source s
LEFT JOIN cities c1 ON c1.slug=lower(regexp_replace(regexp_replace(unaccent(s.city), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g'))
WHERE o.slug=s.slug;

-- Step 2: funding rounds (8; Bleu Robotics excluded — its round already exists)
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"slug":"inevitable","stage":"series_a","amount_eur":15.0,"currency_original":"EUR","amount_original":15000000,"announced_date":"2026-10-21","notes":"€15M to expand its AI filmmaking technology, production infrastructure and international operations (esp. US). Claims feature-length films in ~4 months with budgets from €250,000. Two demonstration productions: Sync (live-action sci-fi) and Naaru (animated sci-fi). Investors undisclosed. Production-cost/delivery claims company-reported and unvalidated. Source: J'aime les Startups, Advanced Television."},
  {"slug":"wormsensing","stage":"series_a","amount_eur":9.5,"currency_original":"EUR","amount_original":9500000,"announced_date":"2026-10-27","notes":"€9.5M Series A to expand its industrial vibration-monitoring technology (Dragonfly piezoelectric sensors, developed at CEA-Leti) internationally (Europe, North America, Asia) and build integrated monitoring services. Early customers in automotive and aerospace. Investors: Orano Venture Fund, Bpifrance, France 2030, Fonds Régional Avenir Industrie Auvergne-Rhône-Alpes, Innovacom, KBC Focus Fund, CEA Investissement. Source: Wormsensing, Le Dauphiné Libéré."},
  {"slug":"aqqi","stage":"pre_seed","amount_eur":4.0,"currency_original":"EUR","amount_original":4000000,"announced_date":"2026-10-27","notes":"€4M pre-seed, launching its AI assistant for residential property buyers (automates searches, agency communications, viewings, document management; buyer decides). Tested with several dozen users in Paris region, Bordeaux and Marseille; broader launch early 2027. Legal entity DIRECTLAYER. Investors: Axeleo Capital, Aquiti, Kima Ventures, 50 Partners, Source Ventures, Business Angels, Pierre Kosciusko-Morizet, Nicolas Steegmann. Source: Eurotribune."},
  {"slug":"aima","stage":"seed","amount_eur":2.2,"currency_original":"EUR","amount_original":2200000,"announced_date":"2026-10-05","notes":"€2.2M seed to accelerate its AI-powered liquid biopsy platform (cfDNA methylation + fragmentomics), initial focus colorectal cancer. Funds clinical validation, IP, regulatory prep, diagnostics partnerships and international expansion. Grenoble-area (Meylan). Investors: Business Angels, Cyrille Fleury, Benoit Lemaignan, Marc Aeschlimann, Pascale Witz, Spike Willcocks, Gilles Polo, Valérie Pierrard. Source: Le Dauphiné Libéré, Bref Eco."},
  {"slug":"pint","stage":"pre_seed","amount_eur":1.7,"currency_original":"EUR","amount_original":1700000,"announced_date":"2026-10-06","notes":"First round, >€1.7M, to accelerate development and industrialization of advanced metal alloys for 3D printing. Funds R&D/qualification of new materials, a dedicated production workshop and commercial development in France/Europe. Target markets: aerospace, space and rail, then defense and energy. 16 BFC Angels members participated alongside four other angel networks plus public programs. Investors: Bourgogne Franche-Comté Business Angels, Alsace Business Angels, Business Angels des Grandes Écoles, Défense Angels, Champagne Ardenne Angels, ADEME, France 2030. Source: Défense Angels, BFC Angels."},
  {"slug":"entroview","stage":"series_a","amount_eur":null,"currency_original":null,"amount_original":null,"announced_date":"2026-10-26","notes":"Second funding round (amount undisclosed) led by insurance group Covéa. Funds commercial deployment of its EV-battery diagnostic systems across insurers, garages, repair networks and dealers. Follows two years of testing with CESVI France (Covéa's technical center), which plans to certify the tech by early 2027. Targets 1,000+ garages/dealers by end-2028 and 50,000 diagnostics/year. Investors: Covéa (lead), Ventech, Rethink Ventures, Exergon. (The news names AFI Ventures, which is a fund operated by Ventech — same investor.) Source: Ventech, Entroview."},
  {"slug":"b-cell-design","stage":"undisclosed","amount_eur":0.4,"currency_original":"EUR","amount_original":400000,"announced_date":"2026-10-26","notes":"€400,000 in convertible bonds from existing shareholders (converting to equity incl. accrued interest, per ATON) to accelerate commercialization of its monoclonal-antibody technologies. Funds recruitment, marketing and international customer development (Europe, China, Canada, India). Three patented platforms (GammaPrim, HAMIGA, InEps); ~80 monoclonal antibodies; ISO 9001 manufacturing. Investors undisclosed. Source: Aton."},
  {"slug":"playa-rent","stage":"seed","amount_eur":0.8,"currency_original":"EUR","amount_original":800000,"announced_date":"2026-10-29","notes":"€800K to deploy its autonomous water-sports rental stations and support international expansion. €500K equity from undisclosed industrial partners + €300K non-dilutive (incl. ~€100K from the Brittany Region). Expanding into shared boat tenders (Boaty'nGo), automated life-raft rentals (Bib'nGo) and accessible beach wheelchairs (BeachWheel). No lead equity investor identified. Investors: Brittany Region (public support). Source: BoatIndustry."}
]$json$) AS (slug TEXT, stage TEXT, amount_eur NUMERIC, currency_original TEXT, amount_original NUMERIC, announced_date TEXT, notes TEXT))
INSERT INTO funding_rounds (id, organization_id, stage, amount_eur, currency_original, amount_original, announced_date, is_estimated, is_verified, source_name, notes, created_at)
SELECT uuid_generate_v4(), o.id, s.stage::funding_stage, s.amount_eur, s.currency_original, s.amount_original, s.announced_date::DATE,
  CASE WHEN s.currency_original IS NOT NULL AND s.currency_original!='EUR' AND s.amount_eur IS NOT NULL THEN TRUE ELSE FALSE END, FALSE, 'funding_deals_november_2026_week1', s.notes, NOW()
FROM source s JOIN organizations o ON o.slug=s.slug;

-- Step 3a: investor organizations (idempotent)
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"name":"Orano Venture Fund"},{"name":"Bpifrance"},{"name":"France 2030"},{"name":"Fonds Régional Avenir Industrie Auvergne-Rhône-Alpes"},{"name":"Innovacom"},{"name":"KBC Focus Fund"},{"name":"CEA Investissement"},
  {"name":"Contrarian Ventures"},{"name":"OVNI Capital"},
  {"name":"Axeleo Capital"},{"name":"Aquiti"},{"name":"Kima Ventures"},{"name":"50 Partners"},{"name":"Source Ventures"},{"name":"Business Angels"},{"name":"Pierre Kosciusko-Morizet"},{"name":"Nicolas Steegmann"},
  {"name":"Cyrille Fleury"},{"name":"Benoit Lemaignan"},{"name":"Marc Aeschlimann"},{"name":"Pascale Witz"},{"name":"Spike Willcocks"},{"name":"Gilles Polo"},{"name":"Valérie Pierrard"},
  {"name":"Bourgogne Franche-Comté Business Angels"},{"name":"Alsace Business Angels"},{"name":"Business Angels des Grandes Écoles"},{"name":"Défense Angels"},{"name":"Champagne Ardenne Angels"},{"name":"ADEME"},
  {"name":"Covéa"},{"name":"Ventech"},{"name":"Rethink Ventures"},{"name":"Exergon"},
  {"name":"Brittany Region"}
]$json$) AS (name TEXT))
INSERT INTO organizations (id, name, slug, organization_type, status, country, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), s.name, lower(regexp_replace(regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g')), 'investor'::organization_type, 'active'::organization_status, 'France', 'funding_deals_november_2026_week1', NOW(), NOW()
FROM source s ON CONFLICT (slug) DO NOTHING;

-- Step 3b: funding round investors for this batch's rounds (joined on slug + source)
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"slug":"wormsensing","investor_name":"Orano Venture Fund","is_lead":false},{"slug":"wormsensing","investor_name":"Bpifrance","is_lead":false},{"slug":"wormsensing","investor_name":"France 2030","is_lead":false},{"slug":"wormsensing","investor_name":"Fonds Régional Avenir Industrie Auvergne-Rhône-Alpes","is_lead":false},{"slug":"wormsensing","investor_name":"Innovacom","is_lead":false},{"slug":"wormsensing","investor_name":"KBC Focus Fund","is_lead":false},{"slug":"wormsensing","investor_name":"CEA Investissement","is_lead":false},
  {"slug":"aqqi","investor_name":"Axeleo Capital","is_lead":false},{"slug":"aqqi","investor_name":"Aquiti","is_lead":false},{"slug":"aqqi","investor_name":"Kima Ventures","is_lead":false},{"slug":"aqqi","investor_name":"50 Partners","is_lead":false},{"slug":"aqqi","investor_name":"Source Ventures","is_lead":false},{"slug":"aqqi","investor_name":"Business Angels","is_lead":false},{"slug":"aqqi","investor_name":"Pierre Kosciusko-Morizet","is_lead":false},{"slug":"aqqi","investor_name":"Nicolas Steegmann","is_lead":false},
  {"slug":"aima","investor_name":"Business Angels","is_lead":false},{"slug":"aima","investor_name":"Cyrille Fleury","is_lead":false},{"slug":"aima","investor_name":"Benoit Lemaignan","is_lead":false},{"slug":"aima","investor_name":"Marc Aeschlimann","is_lead":false},{"slug":"aima","investor_name":"Pascale Witz","is_lead":false},{"slug":"aima","investor_name":"Spike Willcocks","is_lead":false},{"slug":"aima","investor_name":"Gilles Polo","is_lead":false},{"slug":"aima","investor_name":"Valérie Pierrard","is_lead":false},
  {"slug":"pint","investor_name":"Bourgogne Franche-Comté Business Angels","is_lead":false},{"slug":"pint","investor_name":"Alsace Business Angels","is_lead":false},{"slug":"pint","investor_name":"Business Angels des Grandes Écoles","is_lead":false},{"slug":"pint","investor_name":"Défense Angels","is_lead":false},{"slug":"pint","investor_name":"Champagne Ardenne Angels","is_lead":false},{"slug":"pint","investor_name":"ADEME","is_lead":false},{"slug":"pint","investor_name":"France 2030","is_lead":false},
  {"slug":"entroview","investor_name":"Covéa","is_lead":true},{"slug":"entroview","investor_name":"Ventech","is_lead":false},{"slug":"entroview","investor_name":"Rethink Ventures","is_lead":false},{"slug":"entroview","investor_name":"Exergon","is_lead":false},
  {"slug":"playa-rent","investor_name":"Brittany Region","is_lead":false}
]$json$) AS (slug TEXT, investor_name TEXT, is_lead BOOLEAN))
INSERT INTO funding_round_investors (id, funding_round_id, investor_id, is_lead, investor_name, created_at)
SELECT uuid_generate_v4(), fr.id, inv.id, s.is_lead, s.investor_name, NOW()
FROM source s
JOIN organizations o ON o.slug=s.slug
JOIN organizations inv ON inv.slug=lower(regexp_replace(regexp_replace(unaccent(s.investor_name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g'))
JOIN funding_rounds fr ON fr.organization_id=o.id AND fr.source_name='funding_deals_november_2026_week1'
WHERE NOT EXISTS (SELECT 1 FROM funding_round_investors x WHERE x.funding_round_id=fr.id AND x.investor_id=inv.id);

-- Step 3c: Bleu Robotics investors, attached to its PRE-EXISTING €5M round
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"investor_name":"Contrarian Ventures","is_lead":true},{"investor_name":"OVNI Capital","is_lead":true}
]$json$) AS (investor_name TEXT, is_lead BOOLEAN))
INSERT INTO funding_round_investors (id, funding_round_id, investor_id, is_lead, investor_name, created_at)
SELECT uuid_generate_v4(), fr.id, inv.id, s.is_lead, s.investor_name, NOW()
FROM source s
JOIN organizations inv ON inv.slug=lower(regexp_replace(regexp_replace(unaccent(s.investor_name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g'))
JOIN organizations o ON o.slug='bleu-robotics'
JOIN funding_rounds fr ON fr.organization_id=o.id AND fr.stage='pre_seed' AND fr.announced_date='2026-10-29' AND fr.amount_eur=5.00
WHERE NOT EXISTS (SELECT 1 FROM funding_round_investors x WHERE x.funding_round_id=fr.id AND x.investor_id=inv.id);

-- Step 4a: sector links (idempotent)
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"org":"inevitable","sec":"artificial-intelligence"},{"org":"inevitable","sec":"media"},
  {"org":"wormsensing","sec":"deeptech"},
  {"org":"bleu-robotics","sec":"artificial-intelligence"},{"org":"bleu-robotics","sec":"robotics"},{"org":"bleu-robotics","sec":"deeptech"},
  {"org":"aqqi","sec":"proptech"},{"org":"aqqi","sec":"artificial-intelligence"},
  {"org":"aima","sec":"medtech"},{"org":"aima","sec":"biotech"},{"org":"aima","sec":"artificial-intelligence"},
  {"org":"pint","sec":"deeptech"},{"org":"pint","sec":"spacetech-aerospace"},{"org":"pint","sec":"defensetech"},
  {"org":"entroview","sec":"climatetech"},{"org":"entroview","sec":"deeptech"},{"org":"entroview","sec":"mobility"},
  {"org":"b-cell-design","sec":"biotech"},{"org":"b-cell-design","sec":"medtech"},
  {"org":"playa-rent","sec":"traveltech"},{"org":"playa-rent","sec":"sportstech"}
]$json$) AS (org TEXT, sec TEXT))
INSERT INTO organization_sectors (id, organization_id, sector_id, is_primary, created_at)
SELECT uuid_generate_v4(), o.id, sec.id, FALSE, NOW()
FROM source s JOIN organizations o ON o.slug=s.org JOIN sectors sec ON sec.slug=s.sec
ON CONFLICT (organization_id, sector_id) DO NOTHING;

-- Step 4b: promote primary where none exists
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"org":"inevitable","sec":"artificial-intelligence"},{"org":"wormsensing","sec":"deeptech"},{"org":"aqqi","sec":"proptech"},{"org":"aima","sec":"medtech"},{"org":"pint","sec":"deeptech"},{"org":"entroview","sec":"climatetech"},{"org":"b-cell-design","sec":"biotech"},{"org":"playa-rent","sec":"traveltech"}
]$json$) AS (org TEXT, sec TEXT))
UPDATE organization_sectors os SET is_primary=TRUE
FROM source s JOIN organizations o ON o.slug=s.org JOIN sectors sec ON sec.slug=s.sec
WHERE os.organization_id=o.id AND os.sector_id=sec.id
  AND NOT EXISTS (SELECT 1 FROM organization_sectors x WHERE x.organization_id=o.id AND x.is_primary=TRUE);

-- Step 5: people (founders)
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"full_name":"Jean Mach","first_name":"Jean","last_name":"Mach"},{"full_name":"Alexandre Pelletier","first_name":"Alexandre","last_name":"Pelletier"},
  {"full_name":"Jean-Sébastien Moulet","first_name":"Jean-Sébastien","last_name":"Moulet"},{"full_name":"Lamine Benaissa","first_name":"Lamine","last_name":"Benaissa"},
  {"full_name":"Benoît Berkoukchi","first_name":"Benoît","last_name":"Berkoukchi"},{"full_name":"Jean-Baptiste Mouret","first_name":"Jean-Baptiste","last_name":"Mouret"},{"full_name":"Serena Ivaldi","first_name":"Serena","last_name":"Ivaldi"},
  {"full_name":"Alexandre Ducoeur Martins","first_name":"Alexandre","last_name":"Ducoeur Martins"},{"full_name":"Julie de la Porte des Vaux","first_name":"Julie","last_name":"de la Porte des Vaux"},
  {"full_name":"Arnaud Sandrin","first_name":"Arnaud","last_name":"Sandrin"},{"full_name":"Romain Boidot","first_name":"Romain","last_name":"Boidot"},{"full_name":"Michael Blum","first_name":"Michael","last_name":"Blum"},
  {"full_name":"Paul Didier","first_name":"Paul","last_name":"Didier"},{"full_name":"Paul Bourot","first_name":"Paul","last_name":"Bourot"},
  {"full_name":"Gaëtan Depaëpe","first_name":"Gaëtan","last_name":"Depaëpe"},{"full_name":"Sohaïb El Outmani","first_name":"Sohaïb","last_name":"El Outmani"},
  {"full_name":"Jean Sainte-Laudy","first_name":"Jean","last_name":"Sainte-Laudy"},{"full_name":"Armelle Cuvillier","first_name":"Armelle","last_name":"Cuvillier"},{"full_name":"Gaël Champier","first_name":"Gaël","last_name":"Champier"},
  {"full_name":"Nicolas Roche","first_name":"Nicolas","last_name":"Roche"},{"full_name":"Julien Duprat","first_name":"Julien","last_name":"Duprat"},{"full_name":"Gilles Fatton","first_name":"Gilles","last_name":"Fatton"}
]$json$) AS (full_name TEXT, first_name TEXT, last_name TEXT))
INSERT INTO people (id, full_name, slug, first_name, last_name, legacy_source, created_at)
SELECT uuid_generate_v4(), s.full_name, lower(regexp_replace(regexp_replace(unaccent(s.full_name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g')), s.first_name, s.last_name, 'funding_deals_november_2026_week1', NOW()
FROM source s ON CONFLICT (slug) DO NOTHING;

-- Step 6: founder links
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"org":"inevitable","founder":"Jean Mach"},{"org":"inevitable","founder":"Alexandre Pelletier"},
  {"org":"wormsensing","founder":"Jean-Sébastien Moulet"},{"org":"wormsensing","founder":"Lamine Benaissa"},
  {"org":"bleu-robotics","founder":"Benoît Berkoukchi"},{"org":"bleu-robotics","founder":"Jean-Baptiste Mouret"},{"org":"bleu-robotics","founder":"Serena Ivaldi"},
  {"org":"aqqi","founder":"Alexandre Ducoeur Martins"},{"org":"aqqi","founder":"Julie de la Porte des Vaux"},
  {"org":"aima","founder":"Arnaud Sandrin"},{"org":"aima","founder":"Romain Boidot"},{"org":"aima","founder":"Michael Blum"},
  {"org":"pint","founder":"Paul Didier"},{"org":"pint","founder":"Paul Bourot"},
  {"org":"entroview","founder":"Gaëtan Depaëpe"},{"org":"entroview","founder":"Sohaïb El Outmani"},
  {"org":"b-cell-design","founder":"Jean Sainte-Laudy"},{"org":"b-cell-design","founder":"Armelle Cuvillier"},{"org":"b-cell-design","founder":"Gaël Champier"},
  {"org":"playa-rent","founder":"Nicolas Roche"},{"org":"playa-rent","founder":"Julien Duprat"},{"org":"playa-rent","founder":"Gilles Fatton"}
]$json$) AS (org TEXT, founder TEXT))
INSERT INTO organization_people (id, organization_id, person_id, role, is_current, is_founder, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, p.id, 'Founder', TRUE, TRUE, NOW(), NOW()
FROM source s
JOIN organizations o ON o.slug=s.org
JOIN people p ON p.slug=lower(regexp_replace(regexp_replace(unaccent(s.founder), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g'))
ON CONFLICT (organization_id, person_id, role) DO NOTHING;

-- Step 7: SIREN legal entities (new/missing only). Wormsensing handled by the
-- merge migration; Bleu Robotics, Entroview, Bcell Design already hold theirs.
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"org":"inevitable","legal_name":"INEVITABLE","siren":"991621467"},
  {"org":"aqqi","legal_name":"DIRECTLAYER","siren":"100013937"},
  {"org":"aima","legal_name":"AÍMA","siren":"945009918"},
  {"org":"pint","legal_name":"PINT","siren":"893402016"},
  {"org":"playa-rent","legal_name":"PLAYA RENT","siren":"922698725"}
]$json$) AS (org TEXT, legal_name TEXT, siren TEXT))
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, s.legal_name, s.siren, 'France', NOT EXISTS (SELECT 1 FROM legal_entities le2 WHERE le2.organization_id=o.id), NOW(), NOW()
FROM source s JOIN organizations o ON o.slug=s.org
WHERE NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id=o.id AND le.siren=s.siren);

-- Verification
SELECT 'Funding Rounds' AS entity, COUNT(*) AS count FROM funding_rounds WHERE source_name='funding_deals_november_2026_week1'
UNION ALL SELECT 'Investor Links (batch rounds)', COUNT(*) FROM funding_round_investors fri JOIN funding_rounds fr ON fr.id=fri.funding_round_id WHERE fr.source_name='funding_deals_november_2026_week1'
UNION ALL SELECT 'New Orgs (startup)', COUNT(*) FROM organizations WHERE legacy_source='funding_deals_november_2026_week1' AND organization_type='startup'
UNION ALL SELECT 'Founder People (new)', COUNT(*) FROM people WHERE legacy_source='funding_deals_november_2026_week1';
