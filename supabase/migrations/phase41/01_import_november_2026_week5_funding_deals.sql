-- =============================================================================
-- November 2026 Funding Deals Import — Week 5 (4 deals, announced Nov 5–12 2026)
-- =============================================================================
-- source_name 'funding_deals_november_2026_week5'. Amounts in millions, EUR.
-- All four SIRENs verified against the official French company registry
-- (recherche-entreprises.api.gouv.fr).
--
-- * Orakl Oncology: existing org (SIREN 948448972). New €30M Series A co-led by
--   Norrsken VC and Singular (reported as $34M by Sifted; the €30M figure is
--   stored as the EUR amount). Description refreshed in English; co-founders
--   Gustave Ronteix and Diane-Laure Pagès linked.
-- * Calogena: existing org (SIREN 908713043). €40M EU Innovation Fund GRANT
--   (non-dilutive) for its first commercial SMR at Pierrelatte. Recorded as
--   stage 'grant' with the European Commission as provider. Separate from the
--   earlier ~€50M equity round already in the database. Julien Dereux gets a
--   'President' role. HQ Paris, technical team in Aix-en-Provence.
-- * Gama (Gama Space): existing org 'gama' held the WRONG SIREN 802698746,
--   which is NAVYA (autonomous shuttles, Villeurbanne). Gama's real SIREN is
--   890751654 (GAMA, Ivry-sur-Seine, created 2020-10-26, président Andrew
--   Nutter). The 2015 seed (Karista, EIT Digital) and the €30M 2016 Series B
--   (360 Capital, Keolis) are Navya's rounds and are moved to a new Navya org,
--   together with the mobility/traveltech sectors. New €15M seed added.
-- * triPica: new org (SIREN 818123887). €12.4M from TiLT Capital Partners.
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "unaccent";

-- Step 0: Gama / Navya clean-up -----------------------------------------------
INSERT INTO organizations (id, name, slug, organization_type, description, website, status, country, legacy_source, created_at, updated_at)
VALUES (uuid_generate_v4(), 'Navya', 'navya', 'startup'::organization_type,
  'Develops autonomous driving systems and self-driving electric shuttles for passenger and goods transport.',
  NULL, 'active'::organization_status, 'France', 'funding_deals_november_2026_week5', NOW(), NOW())
ON CONFLICT (slug) DO NOTHING;

UPDATE legal_entities le SET organization_id=n.id, legal_name='NAVYA', updated_at=NOW()
FROM organizations g, organizations n
WHERE g.slug='gama' AND n.slug='navya' AND le.organization_id=g.id AND le.siren='802698746';

UPDATE funding_rounds fr SET organization_id=n.id
FROM organizations g, organizations n
WHERE g.slug='gama' AND n.slug='navya' AND fr.organization_id=g.id
  AND fr.source_name IN ('dealroom_2013_2015','dealroom_2016_2017') AND fr.announced_date < '2020-01-01';

UPDATE organization_sectors os SET organization_id=n.id
FROM organizations g, organizations n, sectors s
WHERE g.slug='gama' AND n.slug='navya' AND os.organization_id=g.id AND os.sector_id=s.id AND s.slug IN ('mobility','traveltech');

UPDATE organizations n SET city_id=COALESCE(n.city_id, c.id), updated_at=NOW()
FROM cities c WHERE c.slug='villeurbanne' AND n.slug='navya';

INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'GAMA', '890751654', 'France', NOT EXISTS (SELECT 1 FROM legal_entities le2 WHERE le2.organization_id=o.id), NOW(), NOW()
FROM organizations o WHERE o.slug='gama'
  AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.siren='890751654');
UPDATE legal_entities le SET is_primary=TRUE FROM organizations o WHERE o.slug='gama' AND le.organization_id=o.id AND le.siren='890751654';

-- Step 1: new org + descriptions / websites ------------------------------------
INSERT INTO organizations (id, name, slug, organization_type, description, website, status, country, legacy_source, created_at, updated_at)
VALUES (uuid_generate_v4(), 'triPica', 'tripica', 'startup'::organization_type,
  'Develops cloud-based customer management and billing software for energy suppliers and telecom operators. Its platform combines CRM, subscriptions, billing, payments, and customer service, enabling utilities to introduce dynamic electricity tariffs, solar self-consumption plans, and EV charging services without replacing multiple legacy systems.',
  'https://www.tripica.com', 'active'::organization_status, 'France', 'funding_deals_november_2026_week5', NOW(), NOW())
ON CONFLICT (slug) DO NOTHING;

UPDATE organizations SET updated_at=NOW(), website='https://www.orakl-oncology.com/',
  description='Develops an AI-powered platform that predicts how cancer drugs will perform in clinical trials using virtual patient models. Spun out of the Gustave Roussy cancer research institute, the company grows tumor organoids from real patient cells, tests them against drugs, and combines the results with genomic, molecular, and clinical data to train predictive AI models. Its technology helps pharmaceutical companies identify promising drug candidates, select patient populations, and reduce clinical development risks.'
WHERE slug='orakl-oncology';

UPDATE organizations SET updated_at=NOW(),
  description='Develops small modular nuclear reactors designed specifically to supply low-carbon heat to urban district heating networks. Its CAL30 water-cooled reactor is designed to produce 30 MW of thermal power, enough to heat approximately 20,000 homes. Founded in 2021 as a subsidiary of Groupe Gorgé.'
WHERE slug='calogena';

UPDATE organizations SET updated_at=NOW(), name='Gama', website='https://www.gamaspace.com/',
  description='Develops large deployable structures and power systems for commercial satellites. Its Wing platform combines foldable solar arrays, power management, optional battery storage, and control software. The company uses high-volume silicon solar cells to reduce costs and shorten manufacturing lead times compared with conventional satellite solar panels.'
WHERE slug='gama';

-- Step 1b: cities
UPDATE organizations o SET city_id=COALESCE(o.city_id, c.id), updated_at=NOW()
FROM cities c WHERE c.slug='paris' AND o.slug IN ('calogena','tripica');
UPDATE organizations o SET secondary_city_id=COALESCE(o.secondary_city_id, c.id), updated_at=NOW()
FROM cities c WHERE c.slug='aix-en-provence' AND o.slug='calogena';
UPDATE organizations o SET city_id=COALESCE(o.city_id, c.id), updated_at=NOW()
FROM cities c WHERE c.slug='ivry-sur-seine' AND o.slug='gama';
UPDATE organizations o SET city_id=COALESCE(o.city_id, c.id), updated_at=NOW()
FROM cities c WHERE c.slug='villejuif' AND o.slug='orakl-oncology';

-- Step 2: funding rounds --------------------------------------------------------
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"slug":"orakl-oncology","stage":"series_a","amount_eur":30.0,"currency_original":"EUR","amount_original":30000000,"announced_date":"2026-11-12","notes":"€30M Series A (reported as $34M by Sifted) co-led by Norrsken VC and Singular to expand its AI platform for predicting cancer drug efficacy before clinical trials. Combines patient-derived tumor organoids with molecular and clinical data to build virtual patient cohorts. Claims 90% accuracy in retrospectively predicting outcomes of 40 published oncology trials (company claim, not independently established). Funds a fivefold expansion in data generation, new lung and gastric cancer models (alongside colorectal and pancreatic), US and UK teams, and deployment across 10+ drug-development programs. Investors: Norrsken VC (co-lead), Singular (co-lead), InfraVia Capital Partners, Serena, Teampact Ventures, Bpifrance, Plug and Play, Verve Ventures, Speedinvest, HCVC. Source: Sifted, Norrsken VC."},
  {"slug":"calogena","stage":"grant","amount_eur":40.0,"currency_original":"EUR","amount_original":40000000,"announced_date":"2026-11-05","notes":"€40M non-dilutive grant from the European Commission Innovation Fund (not equity) to support the potential construction of Calogena's first commercial SMR in Pierrelatte, supplying low-carbon heat to the city's district heating network. Company says it is the first European grant specifically supporting construction of a commercial SMR. Follows France 2030 support and a separate ~€50M equity round (April 2026). Exploring projects in Finland and Central/Eastern Europe, incl. a cooperation agreement with Veolia; first commercial deployment targeted for 2032. The award does not mean construction authorization has been granted or that the grant has been fully disbursed. Press release dated Nov 2, published Nov 5. Source: Calogena, World Nuclear News."},
  {"slug":"gama","stage":"seed","amount_eur":15.0,"currency_original":"EUR","amount_original":15000000,"announced_date":"2026-11-12","notes":"€15M seed to industrialize its Wing deployable solar arrays for satellites. Pivoted from solar-sail propulsion to power systems for commercial constellations. Funds its first Wing production line in Ivry-sur-Seine, in-house testing, and ~60 hires (on top of a 30-person team). Uses mass-produced silicon cells instead of specialist space cells. Partnership with US satellite maker Eclipse Space; first demonstration unit scheduled for summer 2027. Investors: Transition, Planet A, Draper Associates, Manta Ray. Source: Tech Funding News."},
  {"slug":"tripica","stage":"growth","amount_eur":12.4,"currency_original":"EUR","amount_original":12400000,"announced_date":"2026-11-10","notes":"€12.4M from TiLT Capital Partners to accelerate European expansion (notably Germany and Italy) and integrate AI into its billing and customer-service software. Originally built for telecoms, now increasingly targeting energy suppliers modernizing billing and introducing flexible pricing. Customers include Enercity (Germany), Digicel and CelcomDigi. Funds product development, international sales and marketing, and its partner ecosystem. Investors: TiLT Capital Partners. Source: Tech.eu, Tech Funding News."}
]$json$) AS (slug TEXT, stage TEXT, amount_eur NUMERIC, currency_original TEXT, amount_original NUMERIC, announced_date TEXT, notes TEXT))
INSERT INTO funding_rounds (id, organization_id, stage, amount_eur, currency_original, amount_original, announced_date, is_estimated, is_verified, source_name, notes, created_at)
SELECT uuid_generate_v4(), o.id, s.stage::funding_stage, s.amount_eur, s.currency_original, s.amount_original, s.announced_date::DATE,
  FALSE, FALSE, 'funding_deals_november_2026_week5', s.notes, NOW()
FROM source s JOIN organizations o ON o.slug=s.slug
WHERE NOT EXISTS (SELECT 1 FROM funding_rounds x WHERE x.organization_id=o.id AND x.source_name='funding_deals_november_2026_week5');

-- Step 3a: new investor
INSERT INTO organizations (id, name, slug, organization_type, status, country, legacy_source, created_at, updated_at)
VALUES (uuid_generate_v4(), 'Manta Ray', 'manta-ray', 'investor'::organization_type, 'active'::organization_status, 'United Kingdom', 'funding_deals_november_2026_week5', NOW(), NOW())
ON CONFLICT (slug) DO NOTHING;

-- Step 3b: investor links
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"slug":"orakl-oncology","inv":"norrsken-vc","name":"Norrsken VC","is_lead":true},
  {"slug":"orakl-oncology","inv":"singular","name":"Singular","is_lead":true},
  {"slug":"orakl-oncology","inv":"infravia-capital-partners","name":"InfraVia Capital Partners","is_lead":false},
  {"slug":"orakl-oncology","inv":"serena","name":"Serena","is_lead":false},
  {"slug":"orakl-oncology","inv":"teampact-ventures","name":"Teampact Ventures","is_lead":false},
  {"slug":"orakl-oncology","inv":"bpifrance","name":"Bpifrance","is_lead":false},
  {"slug":"orakl-oncology","inv":"plug-and-play","name":"Plug and Play","is_lead":false},
  {"slug":"orakl-oncology","inv":"verve-ventures","name":"Verve Ventures","is_lead":false},
  {"slug":"orakl-oncology","inv":"speedinvest","name":"Speedinvest","is_lead":false},
  {"slug":"orakl-oncology","inv":"hcvc","name":"HCVC","is_lead":false},
  {"slug":"calogena","inv":"european-commission","name":"European Commission (Innovation Fund)","is_lead":true},
  {"slug":"gama","inv":"transition","name":"Transition","is_lead":false},
  {"slug":"gama","inv":"planet-a","name":"Planet A","is_lead":false},
  {"slug":"gama","inv":"draper-associates","name":"Draper Associates","is_lead":false},
  {"slug":"gama","inv":"manta-ray","name":"Manta Ray","is_lead":false},
  {"slug":"tripica","inv":"tilt-capital-partners","name":"TiLT Capital Partners","is_lead":true}
]$json$) AS (slug TEXT, inv TEXT, name TEXT, is_lead BOOLEAN))
INSERT INTO funding_round_investors (id, funding_round_id, investor_id, is_lead, investor_name, created_at)
SELECT uuid_generate_v4(), fr.id, i.id, s.is_lead, s.name, NOW()
FROM source s
JOIN organizations o ON o.slug=s.slug
JOIN organizations i ON i.slug=s.inv
JOIN funding_rounds fr ON fr.organization_id=o.id AND fr.source_name='funding_deals_november_2026_week5'
WHERE NOT EXISTS (SELECT 1 FROM funding_round_investors x WHERE x.funding_round_id=fr.id AND x.investor_id=i.id);

-- Step 4: sectors (+ primary where none)
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"org":"orakl-oncology","sec":"techbio"},{"org":"orakl-oncology","sec":"artificial-intelligence"},{"org":"orakl-oncology","sec":"biotech"},
  {"org":"calogena","sec":"nuclear"},{"org":"calogena","sec":"climatetech"},{"org":"calogena","sec":"cleantech"},{"org":"calogena","sec":"energy"},{"org":"calogena","sec":"deeptech"},
  {"org":"gama","sec":"spacetech-aerospace"},{"org":"gama","sec":"deeptech"},
  {"org":"tripica","sec":"saas"},{"org":"tripica","sec":"energy"},{"org":"tripica","sec":"mobility"},{"org":"tripica","sec":"artificial-intelligence"}
]$json$) AS (org TEXT, sec TEXT))
INSERT INTO organization_sectors (id, organization_id, sector_id, is_primary, created_at)
SELECT uuid_generate_v4(), o.id, sec.id, FALSE, NOW()
FROM source s JOIN organizations o ON o.slug=s.org JOIN sectors sec ON sec.slug=s.sec
ON CONFLICT (organization_id, sector_id) DO NOTHING;

WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"org":"orakl-oncology","sec":"techbio"},{"org":"calogena","sec":"nuclear"},{"org":"gama","sec":"spacetech-aerospace"},
  {"org":"tripica","sec":"saas"},{"org":"navya","sec":"mobility"}
]$json$) AS (org TEXT, sec TEXT))
UPDATE organization_sectors os SET is_primary=TRUE
FROM source s JOIN organizations o ON o.slug=s.org JOIN sectors sec ON sec.slug=s.sec
WHERE os.organization_id=o.id AND os.sector_id=sec.id
  AND NOT EXISTS (SELECT 1 FROM organization_sectors x WHERE x.organization_id=o.id AND x.is_primary=TRUE);

-- Step 5: people
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"full_name":"Gustave Ronteix","first_name":"Gustave","last_name":"Ronteix"},
  {"full_name":"Andrew Nutter","first_name":"Andrew","last_name":"Nutter"},
  {"full_name":"Louis de Gouyon Matignon","first_name":"Louis","last_name":"de Gouyon Matignon"},
  {"full_name":"Thibaud Elzière","first_name":"Thibaud","last_name":"Elzière"},
  {"full_name":"Mathieu Horn","first_name":"Mathieu","last_name":"Horn"},
  {"full_name":"Walid Bounar","first_name":"Walid","last_name":"Bounar"},
  {"full_name":"Christophe Ruzé","first_name":"Christophe","last_name":"Ruzé"}
]$json$) AS (full_name TEXT, first_name TEXT, last_name TEXT))
INSERT INTO people (id, full_name, slug, first_name, last_name, legacy_source, created_at)
SELECT uuid_generate_v4(), s.full_name, lower(regexp_replace(regexp_replace(unaccent(s.full_name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g')), s.first_name, s.last_name, 'funding_deals_november_2026_week5', NOW()
FROM source s ON CONFLICT (slug) DO NOTHING;

-- Step 6: founder links
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"org":"orakl-oncology","p":"fanny-jaulin"},{"org":"orakl-oncology","p":"gustave-ronteix"},{"org":"orakl-oncology","p":"diane-laure-pages"},
  {"org":"gama","p":"andrew-nutter"},{"org":"gama","p":"louis-de-gouyon-matignon"},{"org":"gama","p":"thibaud-elziere"},
  {"org":"tripica","p":"mathieu-horn"},{"org":"tripica","p":"walid-bounar"},{"org":"tripica","p":"christophe-ruze"}
]$json$) AS (org TEXT, p TEXT))
INSERT INTO organization_people (id, organization_id, person_id, role, is_current, is_founder, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, pp.id, 'Founder', TRUE, TRUE, NOW(), NOW()
FROM source s JOIN organizations o ON o.slug=s.org JOIN people pp ON pp.slug=s.p
WHERE NOT EXISTS (SELECT 1 FROM organization_people x WHERE x.organization_id=o.id AND x.person_id=pp.id)
ON CONFLICT (organization_id, person_id, role) DO NOTHING;

-- Calogena: Julien Dereux is the current President
INSERT INTO organization_people (id, organization_id, person_id, role, is_current, is_founder, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, pp.id, 'President', TRUE, FALSE, NOW(), NOW()
FROM organizations o, people pp WHERE o.slug='calogena' AND pp.slug='julien-dereux'
ON CONFLICT (organization_id, person_id, role) DO NOTHING;

-- Step 7: legal entity for triPica (others already hold theirs)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'TRIPICA', '818123887', 'France', NOT EXISTS (SELECT 1 FROM legal_entities le2 WHERE le2.organization_id=o.id), NOW(), NOW()
FROM organizations o WHERE o.slug='tripica'
  AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.siren='818123887');

-- Verification
SELECT 'Funding Rounds' AS entity, COUNT(*) AS count FROM funding_rounds WHERE source_name='funding_deals_november_2026_week5'
UNION ALL SELECT 'Investor Links', COUNT(*) FROM funding_round_investors fri JOIN funding_rounds fr ON fr.id=fri.funding_round_id WHERE fr.source_name='funding_deals_november_2026_week5'
UNION ALL SELECT 'Founder Links', COUNT(*) FROM organization_people op JOIN organizations o ON o.id=op.organization_id WHERE o.slug IN ('orakl-oncology','gama','tripica') AND op.is_founder
UNION ALL SELECT 'Legal Entities', COUNT(*) FROM legal_entities WHERE siren IN ('948448972','908713043','890751654','818123887','802698746');
