-- =============================================================================
-- November 2026 Funding Deals Import — Week 3 (7 deals, announced Oct 15–Nov 5 2026)
-- =============================================================================
-- source_name 'funding_deals_november_2026_week3'. Amounts in millions, EUR.
--
-- 5 new orgs (Shaarp, QRU, Gimii, ArmorCheck, Sedipec) + 2 existing orgs that
-- get a new, distinct round (Excellent, AICE). All 7 SIRENs verified against
-- the French business registry (Pappers). New cities: Saint-Martin-le-Vinoux,
-- Sceaux.
--
-- Special cases:
--   * Excellent: existing org 'excellent' (2021 crunchbase import, €120K
--     pre-seed 2021). Name tidied 'EXCELLENT' -> 'Excellent'; description filled.
--     Legal entity is DUMANI (SIREN 838655181). Round closed summer 2026,
--     announced 2026-11-04 (announcement date used).
--   * AICE: existing org 'aice' (Station F Future 40) already holds SIREN
--     993293935, founders, city Versailles (= registered office). Gets the new
--     €4M seed + AI/DeepTech sectors; San Francisco added as secondary city.
--   * Sedipec: stage 'growth' (growth equity).
--   * Investor mapping onto existing records: Socomore Venture -> socomore-ventures,
--     Time4 (daphni) -> time4, SideAngels -> sideangels, Starquest Capital ->
--     starquest-capital, Innov'Alpes 2 -> innovalpes, Leia Capital II ->
--     leia-capital, Édouard de Raulin -> edouard-de-raulin.
--   * Sectors not in the taxonomy were not created: SalesTech, B2B SaaS, Sales
--     Intelligence, Enterprise Software, CRM (Shaarp -> SaaS), AgriFood
--     (Excellent), PetTech (QRU). Sedipec's 'FoodTech' omitted (flood protection).
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "unaccent";

-- Step 0: cities
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"name":"Saint-Martin-le-Vinoux","country":"France"},{"name":"Sceaux","country":"France"}
]$json$) AS (name TEXT, country TEXT))
INSERT INTO cities (id, name, slug, country, created_at, updated_at)
SELECT uuid_generate_v4(), s.name, lower(regexp_replace(regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g')), s.country, NOW(), NOW()
FROM source s ON CONFLICT (slug) DO NOTHING;

-- Step 1: new organizations
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"name":"Shaarp","slug":"shaarp","website":"https://shaarp.ai/","description":"Develops an AI-powered sales intelligence platform that helps B2B sales teams identify prospects, research companies, prepare meetings and personalize commercial outreach. The platform consolidates business information from multiple sources and integrates with existing sales tools."},
  {"name":"QRU","slug":"qru","website":"https://qru.pet/","description":"Produces premium raw-food meals for dogs and cats based on the BARF (Biologically Appropriate Raw Food) approach. Its French-made recipes combine raw meat with other ingredients and are distributed through its e-commerce platform, pet shops, garden centers, and a network of retail partners."},
  {"name":"Gimii","slug":"gimii","website":"https://gimii.fr/","description":"Develops a consent-management tool that allows website visitors to support charities by agreeing to advertising cookies. Integrated with existing consent-management platforms, its software lets users who initially reject cookies consent in exchange for a donation funded by a portion of the resulting advertising revenue."},
  {"name":"ArmorCheck","slug":"armorcheck","website":"https://www.armor-check.fr/","description":"Develops embedded sensors that allow military and security personnel to check the structural integrity of ceramic ballistic protection plates without destructive testing. Its passive wireless technology detects damage that may be invisible to the naked eye, enabling rapid field inspections and better equipment maintenance."},
  {"name":"Sedipec","slug":"sedipec","website":"https://sedipec.com/","description":"Develops and distributes flood-protection solutions for residential, commercial, and public buildings. Its platform combines flood-risk assessments, customized protective equipment, installation services, and assistance in obtaining public subsidies. Products include removable flood barriers, watertight doors, and backflow-prevention systems."}
]$json$) AS (name TEXT, slug TEXT, website TEXT, description TEXT))
INSERT INTO organizations (id, name, slug, organization_type, description, website, status, country, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), s.name, s.slug, 'startup'::organization_type, s.description, s.website, 'active'::organization_status, 'France', 'funding_deals_november_2026_week3', NOW(), NOW()
FROM source s
ON CONFLICT (slug) DO UPDATE SET website=COALESCE(organizations.website, EXCLUDED.website), description=COALESCE(organizations.description, EXCLUDED.description), updated_at=NOW();

-- Step 1a: tidy existing Excellent record
UPDATE organizations SET name='Excellent',
  description=COALESCE(NULLIF(description,''), 'Develops and manufactures organic, French-made plant-based alternatives to meat for commercial and institutional catering. Its products include burgers, meatballs, strips, and crispy breaded alternatives made from plant proteins. The company focuses on short ingredient lists, avoiding additives such as methylcellulose, and developing food-processing techniques that improve texture and nutritional quality.'),
  updated_at=NOW()
WHERE slug='excellent';

-- Step 1b: city links (COALESCE keeps any existing value) + AICE secondary city
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"slug":"shaarp","city":"montpellier"},{"slug":"qru","city":"saint-martin-le-vinoux"},{"slug":"gimii","city":"paris"},
  {"slug":"armorcheck","city":"caudan"},{"slug":"sedipec","city":"sceaux"},{"slug":"excellent","city":"montreuil"}
]$json$) AS (slug TEXT, city TEXT))
UPDATE organizations o SET city_id=COALESCE(o.city_id, c.id), updated_at=NOW()
FROM source s JOIN cities c ON c.slug=s.city WHERE o.slug=s.slug;

UPDATE organizations o SET secondary_city_id=COALESCE(o.secondary_city_id, c.id), updated_at=NOW()
FROM cities c WHERE c.slug='san-francisco' AND o.slug='aice';

-- Step 2: funding rounds
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"slug":"shaarp","stage":"pre_seed","amount_eur":0.4,"amount_original":400000,"announced_date":"2026-10-29","notes":"First round, €400,000, to accelerate development of its AI-powered B2B sales platform: expand functionality, strengthen customer support and develop sovereign AI that can run inside customers' IT environments. Targets SMEs/mid-sized firms (sales teams of 5–20); customers in insurance, banking and professional services, expanding into industry. 8 employees; recruitment to accelerate in 2027. The round brings together four business angels and financing partners, including Bpifrance and two regional banks (not recorded as investors). Investors: Frédéric Salles, Freddy Pintus, Édouard de Raulin, Frederi Scotto, Business Angels. Source: La LettreM."},
  {"slug":"excellent","stage":"pre_seed","amount_eur":1.2,"amount_original":1200000,"announced_date":"2026-11-04","notes":"€1.2M financing package (operating company Dumani SAS) combining investment from existing and new shareholders, bank financing and a convertible loan from Banque des Territoires. Closed summer 2026, announced Nov 4. Funds a stronger sales team, a broader range for professional kitchens and a first pilot industrial production line. ~40 active customers, >€2.6M cumulative revenue since 2021, >1.5M school meals served in 2026 (company-reported). Targets a separate Series A in 2028 (not included). Investors: Montgrand Executive, Galapagos Innovation, 7KO2, Pays de la Loire Participations, Marco & Co, Business Angels, SideAngels. Source: Resto Today."},
  {"slug":"qru","stage":"seed","amount_eur":1.65,"amount_original":1650000,"announced_date":"2026-10-15","notes":"€1.65M financing: ~€1M equity and equity-linked securities + €650,000 loans and subsidies. Funds expansion of its production facility near Grenoble, wider retail presence and online brand awareness. 12 employees, ~€1M annual revenue, ~300 retail partners; target 1,000 within five years. Legal entity QWILD. Investors: Rhône Dauphiné Développement, Casra Capital, Ora Groupe, Qwild BA Invest, Novus Orbs, Leia Capital II, Innov'Alpes 2, Business Angels. Source: Somudimec, Présences Grenoble."},
  {"slug":"gimii","stage":"pre_seed","amount_eur":1.5,"amount_original":1500000,"announced_date":"2026-10-29","notes":"€1.5M to accelerate European expansion (UK, Spain, Germany) and product development for its Cookies Solidaires consent tool (users who decline tracking can reconsider in exchange for a donation to a charity, funded by 10% of resulting ad revenue). Claims consent rates rise from ~60% to 85–90%; €330,000 donated to date; customers include Leboncoin and Orange; team to grow from 10 to 30 in 2027. Performance figures company-reported. Confirmed in an Oct 29 investor interview, covered again Nov 5. Investors: Time4 (daphni), Tomcat, Provence Angels, Business Angels, Augustin Decré, Thibault Hennion. Source: Provence."},
  {"slug":"armorcheck","stage":"pre_seed","amount_eur":1.0,"amount_original":1000000,"announced_date":"2026-11-02","notes":"€1M to industrialize its sensor technology for detecting damage in ceramic ballistic protection plates: production capacity, engineering team, commercial deployment with manufacturers/integrators. Technology technically validated by the DGA; Ministry of the Interior operational testing through early 2027. DefStart 2026 Special Jury Prize (Eurosatory). 2 employees, 3 hires planned in 2027. Investors: Socomore Venture, Défense Angels, Breizh Up. Source: Défense Angels."},
  {"slug":"aice","stage":"seed","amount_eur":4.0,"amount_original":4000000,"announced_date":"2026-10-29","notes":"€4M seed to develop autonomous underwater defense systems: coordinated fleets of underwater drones as a cheaper, scalable alternative to conventional maritime defense equipment. Y Combinator P26. Initial prototype tested in water; expanding engineering in Paris. Recently pivoted from industrial energy technology to underwater defense; exhibited at Euronaval (Nov 3–6). Investors: Motier Ventures, Global Founders Capital, Sisyphus Ventures, Leblon Capital. Source: CFNEWS."},
  {"slug":"sedipec","stage":"growth","amount_eur":4.0,"amount_original":4000000,"announced_date":"2026-11-05","notes":"€4M growth equity from Starquest Capital to accelerate expansion in France and internationally (neighbouring European countries first), deepen insurer partnerships and develop its SEDIDIAG diagnostic system and FLOODPOINT project-management software. Integrated offer: vulnerability assessment, flood-protection equipment, installation and access to Fonds Barnier subsidies. >2,500 projects via >300 installers; revenue up tenfold in four years to ~€4M. Amount confirmed by the company and Starquest. Investors: Starquest Capital. Source: CFNEWS, Sedipec."}
]$json$) AS (slug TEXT, stage TEXT, amount_eur NUMERIC, amount_original NUMERIC, announced_date TEXT, notes TEXT))
INSERT INTO funding_rounds (id, organization_id, stage, amount_eur, currency_original, amount_original, announced_date, is_estimated, is_verified, source_name, notes, created_at)
SELECT uuid_generate_v4(), o.id, s.stage::funding_stage, s.amount_eur, 'EUR', s.amount_original, s.announced_date::DATE,
  FALSE, FALSE, 'funding_deals_november_2026_week3', s.notes, NOW()
FROM source s JOIN organizations o ON o.slug=s.slug
WHERE NOT EXISTS (SELECT 1 FROM funding_rounds x WHERE x.organization_id=o.id AND x.source_name='funding_deals_november_2026_week3');

-- Step 3a: new investor organizations
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"name":"Frédéric Salles"},{"name":"Freddy Pintus"},{"name":"Frederi Scotto"},
  {"name":"Montgrand Executive"},{"name":"7KO2"},
  {"name":"Casra Capital"},{"name":"Ora Groupe"},{"name":"Qwild BA Invest"},{"name":"Novus Orbs"},
  {"name":"Augustin Decré"},{"name":"Thibault Hennion"},
  {"name":"Sisyphus Ventures"}
]$json$) AS (name TEXT))
INSERT INTO organizations (id, name, slug, organization_type, status, country, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), s.name, lower(regexp_replace(regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g')), 'investor'::organization_type, 'active'::organization_status, 'France', 'funding_deals_november_2026_week3', NOW(), NOW()
FROM source s ON CONFLICT (slug) DO NOTHING;

-- Step 3b: funding round investors (explicit investor slugs)
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"slug":"shaarp","inv":"frederic-salles","name":"Frédéric Salles"},{"slug":"shaarp","inv":"freddy-pintus","name":"Freddy Pintus"},{"slug":"shaarp","inv":"edouard-de-raulin","name":"Édouard de Raulin"},{"slug":"shaarp","inv":"frederi-scotto","name":"Frederi Scotto"},{"slug":"shaarp","inv":"business-angels","name":"Business Angels"},
  {"slug":"excellent","inv":"montgrand-executive","name":"Montgrand Executive"},{"slug":"excellent","inv":"galapagos-innovation","name":"Galapagos Innovation"},{"slug":"excellent","inv":"7ko2","name":"7KO2"},{"slug":"excellent","inv":"pays-de-la-loire-participations","name":"Pays de la Loire Participations"},{"slug":"excellent","inv":"marco-co","name":"Marco & Co"},{"slug":"excellent","inv":"business-angels","name":"Business Angels"},{"slug":"excellent","inv":"sideangels","name":"SideAngels"},
  {"slug":"qru","inv":"rhone-dauphine-developpement","name":"Rhône Dauphiné Développement"},{"slug":"qru","inv":"casra-capital","name":"Casra Capital"},{"slug":"qru","inv":"ora-groupe","name":"Ora Groupe"},{"slug":"qru","inv":"qwild-ba-invest","name":"Qwild BA Invest"},{"slug":"qru","inv":"novus-orbs","name":"Novus Orbs"},{"slug":"qru","inv":"leia-capital","name":"Leia Capital II"},{"slug":"qru","inv":"innovalpes","name":"Innov'Alpes 2"},{"slug":"qru","inv":"business-angels","name":"Business Angels"},
  {"slug":"gimii","inv":"time4","name":"Time4 (daphni)"},{"slug":"gimii","inv":"tomcat","name":"Tomcat"},{"slug":"gimii","inv":"provence-angels","name":"Provence Angels"},{"slug":"gimii","inv":"business-angels","name":"Business Angels"},{"slug":"gimii","inv":"augustin-decre","name":"Augustin Decré"},{"slug":"gimii","inv":"thibault-hennion","name":"Thibault Hennion"},
  {"slug":"armorcheck","inv":"socomore-ventures","name":"Socomore Venture"},{"slug":"armorcheck","inv":"defense-angels","name":"Défense Angels"},{"slug":"armorcheck","inv":"breizh-up","name":"Breizh Up"},
  {"slug":"aice","inv":"motier-ventures","name":"Motier Ventures"},{"slug":"aice","inv":"global-founders-capital","name":"Global Founders Capital"},{"slug":"aice","inv":"sisyphus-ventures","name":"Sisyphus Ventures"},{"slug":"aice","inv":"leblon-capital","name":"Leblon Capital"},
  {"slug":"sedipec","inv":"starquest-capital","name":"Starquest Capital"}
]$json$) AS (slug TEXT, inv TEXT, name TEXT))
INSERT INTO funding_round_investors (id, funding_round_id, investor_id, is_lead, investor_name, created_at)
SELECT uuid_generate_v4(), fr.id, i.id, FALSE, s.name, NOW()
FROM source s
JOIN organizations o ON o.slug=s.slug
JOIN organizations i ON i.slug=s.inv
JOIN funding_rounds fr ON fr.organization_id=o.id AND fr.source_name='funding_deals_november_2026_week3'
WHERE NOT EXISTS (SELECT 1 FROM funding_round_investors x WHERE x.funding_round_id=fr.id AND x.investor_id=i.id);

-- Step 4a: sector links
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"org":"shaarp","sec":"artificial-intelligence"},{"org":"shaarp","sec":"saas"},
  {"org":"excellent","sec":"foodtech"},{"org":"excellent","sec":"climatetech"},
  {"org":"qru","sec":"foodtech"},{"org":"qru","sec":"e-commerce-retail"},
  {"org":"gimii","sec":"adtech"},{"org":"gimii","sec":"martech"},{"org":"gimii","sec":"saas"},
  {"org":"armorcheck","sec":"defensetech"},{"org":"armorcheck","sec":"deeptech"},
  {"org":"aice","sec":"defensetech"},{"org":"aice","sec":"robotics"},{"org":"aice","sec":"artificial-intelligence"},{"org":"aice","sec":"deeptech"},
  {"org":"sedipec","sec":"climatetech"},{"org":"sedipec","sec":"proptech"}
]$json$) AS (org TEXT, sec TEXT))
INSERT INTO organization_sectors (id, organization_id, sector_id, is_primary, created_at)
SELECT uuid_generate_v4(), o.id, sec.id, FALSE, NOW()
FROM source s JOIN organizations o ON o.slug=s.org JOIN sectors sec ON sec.slug=s.sec
ON CONFLICT (organization_id, sector_id) DO NOTHING;

-- Step 4b: primary sector where none exists
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"org":"shaarp","sec":"artificial-intelligence"},{"org":"qru","sec":"foodtech"},{"org":"gimii","sec":"adtech"},
  {"org":"armorcheck","sec":"defensetech"},{"org":"sedipec","sec":"climatetech"}
]$json$) AS (org TEXT, sec TEXT))
UPDATE organization_sectors os SET is_primary=TRUE
FROM source s JOIN organizations o ON o.slug=s.org JOIN sectors sec ON sec.slug=s.sec
WHERE os.organization_id=o.id AND os.sector_id=sec.id
  AND NOT EXISTS (SELECT 1 FROM organization_sectors x WHERE x.organization_id=o.id AND x.is_primary=TRUE);

-- Step 5: people (founders; AICE founders already exist)
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"full_name":"Nicolas Rouvière","first_name":"Nicolas","last_name":"Rouvière"},{"full_name":"Loris Venturelli","first_name":"Loris","last_name":"Venturelli"},{"full_name":"Jérôme Brunel","first_name":"Jérôme","last_name":"Brunel"},
  {"full_name":"Maximilien Nguyen","first_name":"Maximilien","last_name":"Nguyen"},{"full_name":"Guillaume Bies","first_name":"Guillaume","last_name":"Bies"},
  {"full_name":"Estelle Evieux","first_name":"Estelle","last_name":"Evieux"},{"full_name":"Mégane Richez","first_name":"Mégane","last_name":"Richez"},
  {"full_name":"Thomas Gicquel","first_name":"Thomas","last_name":"Gicquel"},{"full_name":"Quentin Pomarel","first_name":"Quentin","last_name":"Pomarel"},{"full_name":"Julien Sergent","first_name":"Julien","last_name":"Sergent"},
  {"full_name":"Clémentine Beutier","first_name":"Clémentine","last_name":"Beutier"},{"full_name":"Morgann Jacob","first_name":"Morgann","last_name":"Jacob"},{"full_name":"Mathieu Richard","first_name":"Mathieu","last_name":"Richard"},
  {"full_name":"Jonathan Flahaut","first_name":"Jonathan","last_name":"Flahaut"},{"full_name":"David Delannoy","first_name":"David","last_name":"Delannoy"},{"full_name":"Pierre-Jean Goupil","first_name":"Pierre-Jean","last_name":"Goupil"}
]$json$) AS (full_name TEXT, first_name TEXT, last_name TEXT))
INSERT INTO people (id, full_name, slug, first_name, last_name, legacy_source, created_at)
SELECT uuid_generate_v4(), s.full_name, lower(regexp_replace(regexp_replace(unaccent(s.full_name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g')), s.first_name, s.last_name, 'funding_deals_november_2026_week3', NOW()
FROM source s ON CONFLICT (slug) DO NOTHING;

-- Step 6: founder links
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"org":"shaarp","p":"nicolas-rouviere"},{"org":"shaarp","p":"loris-venturelli"},{"org":"shaarp","p":"jerome-brunel"},
  {"org":"excellent","p":"maximilien-nguyen"},{"org":"excellent","p":"guillaume-bies"},
  {"org":"qru","p":"estelle-evieux"},{"org":"qru","p":"megane-richez"},
  {"org":"gimii","p":"thomas-gicquel"},{"org":"gimii","p":"quentin-pomarel"},{"org":"gimii","p":"julien-sergent"},
  {"org":"armorcheck","p":"clementine-beutier"},{"org":"armorcheck","p":"morgann-jacob"},{"org":"armorcheck","p":"mathieu-richard"},
  {"org":"aice","p":"gregoire-chomette"},{"org":"aice","p":"remi-bouteiller"},
  {"org":"sedipec","p":"jonathan-flahaut"},{"org":"sedipec","p":"david-delannoy"},{"org":"sedipec","p":"pierre-jean-goupil"}
]$json$) AS (org TEXT, p TEXT))
INSERT INTO organization_people (id, organization_id, person_id, role, is_current, is_founder, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, pp.id, 'Founder', TRUE, TRUE, NOW(), NOW()
FROM source s JOIN organizations o ON o.slug=s.org JOIN people pp ON pp.slug=s.p
WHERE NOT EXISTS (SELECT 1 FROM organization_people x WHERE x.organization_id=o.id AND x.person_id=pp.id)
ON CONFLICT (organization_id, person_id, role) DO NOTHING;

-- Step 7: SIREN legal entities (AICE already holds its SIREN)
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"org":"shaarp","legal_name":"SHAARP AI","siren":"937556611"},
  {"org":"excellent","legal_name":"DUMANI","siren":"838655181"},
  {"org":"qru","legal_name":"QWILD","siren":"838441780"},
  {"org":"gimii","legal_name":"GIMII","siren":"951318088"},
  {"org":"armorcheck","legal_name":"ARMOR CHECK","siren":"989894969"},
  {"org":"sedipec","legal_name":"SEDIPEC","siren":"838188258"}
]$json$) AS (org TEXT, legal_name TEXT, siren TEXT))
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, s.legal_name, s.siren, 'France', NOT EXISTS (SELECT 1 FROM legal_entities le2 WHERE le2.organization_id=o.id), NOW(), NOW()
FROM source s JOIN organizations o ON o.slug=s.org
WHERE NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id=o.id AND le.siren=s.siren);

-- Verification
SELECT 'Funding Rounds' AS entity, COUNT(*) AS count FROM funding_rounds WHERE source_name='funding_deals_november_2026_week3'
UNION ALL SELECT 'Investor Links', COUNT(*) FROM funding_round_investors fri JOIN funding_rounds fr ON fr.id=fri.funding_round_id WHERE fr.source_name='funding_deals_november_2026_week3'
UNION ALL SELECT 'New Orgs (startup)', COUNT(*) FROM organizations WHERE legacy_source='funding_deals_november_2026_week3' AND organization_type='startup'
UNION ALL SELECT 'New Investors', COUNT(*) FROM organizations WHERE legacy_source='funding_deals_november_2026_week3' AND organization_type='investor'
UNION ALL SELECT 'Founder Links', COUNT(*) FROM organization_people op JOIN organizations o ON o.id=op.organization_id WHERE o.slug IN ('shaarp','excellent','qru','gimii','armorcheck','aice','sedipec') AND op.is_founder
UNION ALL SELECT 'Legal Entities', COUNT(*) FROM legal_entities WHERE siren IN ('937556611','838655181','838441780','951318088','989894969','993293935','838188258');
