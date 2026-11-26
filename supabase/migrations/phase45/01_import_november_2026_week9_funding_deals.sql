-- =============================================================================
-- November 2026 Funding Deals Import — Week 9 (3 deals, announced Nov 23–26 2026)
-- =============================================================================
-- source_name 'funding_deals_november_2026_week9'. Amounts in millions, EUR.
-- (Named week9 because the week8 name and phase44 were already used by a
-- separate Nov 16–19 import on branch bold-wozniak.)
-- All three are new organizations. SIRENs verified against the official
-- French company registry (recherche-entreprises.api.gouv.fr):
--   Korben 938054566 = SERVICE BOTICS FRANCE (registered office Fresnes;
--     président Lucas Goumarre). HQ recorded as Paris per the company.
--   VirtualBrain 977837061 = VIRTUALBRAIN (Marseille; président Terence
--     Mahier, DG Kata Nyitrai). Lead: Odyssée Venture.
--   Elysia Bioscience 848321279 = ELYSIA BIOSCIENCE (Canéjan; présidente
--     Emilie Obre, DG Su Melser). New city: Canéjan.
-- New investors: TIRESIAS Angels, Sparking Capital, Óbuda Uni Venture Capital
-- (Hungary), Altaïr Capital, Pragmatech Ventures.
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "unaccent";

-- Step 0: city
INSERT INTO cities (id, name, slug, country, created_at, updated_at)
VALUES (uuid_generate_v4(), 'Canéjan', 'canejan', 'France', NOW(), NOW())
ON CONFLICT (slug) DO NOTHING;

-- Step 1: new organizations
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"name":"Korben","slug":"korben","website":"https://korbenforpeople.com/","description":"Develops French-hosted AI software to manage and coordinate autonomous service robots. Its platform is intended to enable robots to adapt their programming and perform tasks such as cleaning, shelf stocking, and customer reception."},
  {"name":"VirtualBrain","slug":"virtualbrain","website":"https://www.getvirtualbrain.com/","description":"Develops an AI platform that enables consulting firms to transform their proprietary expertise, methodologies, and knowledge into reusable AI applications and agents for employees and clients. Its AI Factory combines model orchestration, source verification, workflow automation, and human oversight within European-hosted infrastructure."},
  {"name":"Elysia Bioscience","slug":"elysia-bioscience","website":"https://www.elysia-bioscience.com/","description":"Develops proteomic analysis and interpretation software that enables cosmetics and agricultural companies to evaluate the biological effects, efficacy, and mechanisms of action of ingredients and formulations. Its patented ElyOm software transforms complex biological datasets into actionable scientific insights. Its ElyScore SaaS platform makes this technology directly accessible to R&D, regulatory, and marketing teams."}
]$json$) AS (name TEXT, slug TEXT, website TEXT, description TEXT))
INSERT INTO organizations (id, name, slug, organization_type, description, website, status, country, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), s.name, s.slug, 'startup'::organization_type, s.description, s.website, 'active'::organization_status, 'France', 'funding_deals_november_2026_week9', NOW(), NOW()
FROM source s ON CONFLICT (slug) DO NOTHING;

-- Step 1b: cities
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"slug":"korben","city":"paris"},{"slug":"virtualbrain","city":"marseille"},{"slug":"elysia-bioscience","city":"canejan"}
]$json$) AS (slug TEXT, city TEXT))
UPDATE organizations o SET city_id=COALESCE(o.city_id, c.id), updated_at=NOW()
FROM source s JOIN cities c ON c.slug=s.city WHERE o.slug=s.slug;

-- Step 2: funding rounds
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"slug":"korben","stage":"seed","amount_eur":10.2,"amount_original":10200000,"announced_date":"2026-11-26","notes":"€10.2M seed to expand its autonomous service-robot management platform across Europe. Nearly two-thirds of the funding goes to software development, R&D and French-hosted cloud infrastructure. Plans 70 hires, split equally between technical and commercial/operational roles. Reports €500,000 EBITDA over its most recent eight months (company-reported) and plans an additional €500,000 equity offering via Sowefund. Investors: TIRESIAS Angels, business angels, Bpifrance. Source: Maddyness."},
  {"slug":"virtualbrain","stage":"series_a","amount_eur":4.0,"amount_original":4000000,"announced_date":"2026-11-24","notes":"€4M Series A led by Odyssée Venture to accelerate agentic-AI adoption in consulting. Previously bootstrapped; its AI Factory lets consulting firms turn their IP into specialized AI applications deployable at client organizations. Reports 50 customers in ~10 European countries and ~20 employees; uses forward-deployed engineers (incl. former consultants). European infrastructure; ISO 27001 and SOC 2 Type II certified. Funds orchestration/governance tech, European expansion and hiring. Investors: Odyssée Venture (lead), Sparking Capital, Óbuda Uni Venture Capital (OUVC), Altaïr Capital, Pragmatech Ventures, Paris Business Angels, Side Angels, Jonathan Anguelov, business angels. Source: Planet Fintech."},
  {"slug":"elysia-bioscience","stage":"seed","amount_eur":2.7,"amount_original":2700000,"announced_date":"2026-11-23","notes":"€2.7M to move from specialist laboratory to scalable software business: launch of its ElyScore SaaS platform, expansion of its proprietary proteomic-signature database, international commercial development, and lab equipment including its own mass spectrometer. Customers include Lallemand, Alland & Robert, Vidya Europe, De Sangosse and Staphyt. Says revenue has quadrupled since 2021 (company-reported). Investors: Demea Sustainable Investment, Crédit Agricole, Intellagri Capital, business angels. Source: Demea, CFNEWS."}
]$json$) AS (slug TEXT, stage TEXT, amount_eur NUMERIC, amount_original NUMERIC, announced_date TEXT, notes TEXT))
INSERT INTO funding_rounds (id, organization_id, stage, amount_eur, currency_original, amount_original, announced_date, is_estimated, is_verified, source_name, notes, created_at)
SELECT uuid_generate_v4(), o.id, s.stage::funding_stage, s.amount_eur, 'EUR', s.amount_original, s.announced_date::DATE,
  FALSE, FALSE, 'funding_deals_november_2026_week9', s.notes, NOW()
FROM source s JOIN organizations o ON o.slug=s.slug
WHERE NOT EXISTS (SELECT 1 FROM funding_rounds x WHERE x.organization_id=o.id AND x.source_name='funding_deals_november_2026_week9');

-- Step 3a: new investors
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"name":"TIRESIAS Angels","slug":"tiresias-angels","country":"France"},
  {"name":"Sparking Capital","slug":"sparking-capital","country":"France"},
  {"name":"Óbuda Uni Venture Capital","slug":"obuda-uni-venture-capital","country":"Hungary"},
  {"name":"Altaïr Capital","slug":"altair-capital","country":"France"},
  {"name":"Pragmatech Ventures","slug":"pragmatech-ventures","country":"France"}
]$json$) AS (name TEXT, slug TEXT, country TEXT))
INSERT INTO organizations (id, name, slug, organization_type, status, country, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), s.name, s.slug, 'investor'::organization_type, 'active'::organization_status, s.country, 'funding_deals_november_2026_week9', NOW(), NOW()
FROM source s ON CONFLICT (slug) DO NOTHING;

-- Step 3b: investor links
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"slug":"korben","inv":"tiresias-angels","name":"TIRESIAS Angels","is_lead":false},
  {"slug":"korben","inv":"business-angels","name":"Business Angels","is_lead":false},
  {"slug":"korben","inv":"bpifrance","name":"Bpifrance","is_lead":false},
  {"slug":"virtualbrain","inv":"odyssee-venture","name":"Odyssée Venture","is_lead":true},
  {"slug":"virtualbrain","inv":"sparking-capital","name":"Sparking Capital","is_lead":false},
  {"slug":"virtualbrain","inv":"obuda-uni-venture-capital","name":"Óbuda Uni Venture Capital (OUVC)","is_lead":false},
  {"slug":"virtualbrain","inv":"altair-capital","name":"Altaïr Capital","is_lead":false},
  {"slug":"virtualbrain","inv":"pragmatech-ventures","name":"Pragmatech Ventures","is_lead":false},
  {"slug":"virtualbrain","inv":"paris-business-angels","name":"Paris Business Angels","is_lead":false},
  {"slug":"virtualbrain","inv":"side-angels","name":"Side Angels","is_lead":false},
  {"slug":"virtualbrain","inv":"jonathan-anguelov","name":"Jonathan Anguelov","is_lead":false},
  {"slug":"virtualbrain","inv":"business-angels","name":"Business Angels","is_lead":false},
  {"slug":"elysia-bioscience","inv":"demea-sustainable-investment","name":"Demea Sustainable Investment","is_lead":false},
  {"slug":"elysia-bioscience","inv":"credit-agricole","name":"Crédit Agricole","is_lead":false},
  {"slug":"elysia-bioscience","inv":"intellagri","name":"Intellagri Capital","is_lead":false},
  {"slug":"elysia-bioscience","inv":"business-angels","name":"Business Angels","is_lead":false}
]$json$) AS (slug TEXT, inv TEXT, name TEXT, is_lead BOOLEAN))
INSERT INTO funding_round_investors (id, funding_round_id, investor_id, is_lead, investor_name, created_at)
SELECT uuid_generate_v4(), fr.id, i.id, s.is_lead, s.name, NOW()
FROM source s
JOIN organizations o ON o.slug=s.slug
JOIN organizations i ON i.slug=s.inv
JOIN funding_rounds fr ON fr.organization_id=o.id AND fr.source_name='funding_deals_november_2026_week9'
WHERE NOT EXISTS (SELECT 1 FROM funding_round_investors x WHERE x.funding_round_id=fr.id AND x.investor_id=i.id);

-- Step 4: sectors (first listed = primary)
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"org":"korben","sec":"robotics","p":true},{"org":"korben","sec":"artificial-intelligence","p":false},
  {"org":"virtualbrain","sec":"artificial-intelligence","p":true},{"org":"virtualbrain","sec":"saas","p":false},
  {"org":"elysia-bioscience","sec":"biotech","p":true},{"org":"elysia-bioscience","sec":"deeptech","p":false},{"org":"elysia-bioscience","sec":"agritech","p":false},{"org":"elysia-bioscience","sec":"healthtech","p":false}
]$json$) AS (org TEXT, sec TEXT, p BOOLEAN))
INSERT INTO organization_sectors (id, organization_id, sector_id, is_primary, created_at)
SELECT uuid_generate_v4(), o.id, sec.id, s.p, NOW()
FROM source s JOIN organizations o ON o.slug=s.org JOIN sectors sec ON sec.slug=s.sec
ON CONFLICT (organization_id, sector_id) DO NOTHING;

-- Step 5: people
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"full_name":"Lucas Goumarre","first_name":"Lucas","last_name":"Goumarre"},
  {"full_name":"Terence Mahier","first_name":"Terence","last_name":"Mahier"},
  {"full_name":"Kata Nyitrai","first_name":"Kata","last_name":"Nyitrai"},
  {"full_name":"Emilie Obre","first_name":"Emilie","last_name":"Obre"},
  {"full_name":"Su Melser","first_name":"Su","last_name":"Melser"}
]$json$) AS (full_name TEXT, first_name TEXT, last_name TEXT))
INSERT INTO people (id, full_name, slug, first_name, last_name, legacy_source, created_at)
SELECT uuid_generate_v4(), s.full_name, lower(regexp_replace(regexp_replace(unaccent(s.full_name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g')), s.first_name, s.last_name, 'funding_deals_november_2026_week9', NOW()
FROM source s ON CONFLICT (slug) DO NOTHING;

-- Step 6: founder links
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"org":"korben","p":"lucas-goumarre"},
  {"org":"virtualbrain","p":"terence-mahier"},{"org":"virtualbrain","p":"kata-nyitrai"},
  {"org":"elysia-bioscience","p":"emilie-obre"},{"org":"elysia-bioscience","p":"su-melser"}
]$json$) AS (org TEXT, p TEXT))
INSERT INTO organization_people (id, organization_id, person_id, role, is_current, is_founder, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, pp.id, 'Founder', TRUE, TRUE, NOW(), NOW()
FROM source s JOIN organizations o ON o.slug=s.org JOIN people pp ON pp.slug=s.p
WHERE NOT EXISTS (SELECT 1 FROM organization_people x WHERE x.organization_id=o.id AND x.person_id=pp.id)
ON CONFLICT (organization_id, person_id, role) DO NOTHING;

-- Step 7: legal entities
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"org":"korben","legal":"SERVICE BOTICS FRANCE","siren":"938054566"},
  {"org":"virtualbrain","legal":"VIRTUALBRAIN","siren":"977837061"},
  {"org":"elysia-bioscience","legal":"ELYSIA BIOSCIENCE","siren":"848321279"}
]$json$) AS (org TEXT, legal TEXT, siren TEXT))
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, s.legal, s.siren, 'France', NOT EXISTS (SELECT 1 FROM legal_entities le2 WHERE le2.organization_id=o.id), NOW(), NOW()
FROM source s JOIN organizations o ON o.slug=s.org
WHERE NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.siren=s.siren);

-- Verification
SELECT 'Funding Rounds' AS entity, COUNT(*) AS count FROM funding_rounds WHERE source_name='funding_deals_november_2026_week9'
UNION ALL SELECT 'Investor Links', COUNT(*) FROM funding_round_investors fri JOIN funding_rounds fr ON fr.id=fri.funding_round_id WHERE fr.source_name='funding_deals_november_2026_week9'
UNION ALL SELECT 'Founder Links', COUNT(*) FROM organization_people op JOIN organizations o ON o.id=op.organization_id WHERE o.slug IN ('korben','virtualbrain','elysia-bioscience') AND op.is_founder
UNION ALL SELECT 'Sectors', COUNT(*) FROM organization_sectors os JOIN organizations o ON o.id=os.organization_id WHERE o.slug IN ('korben','virtualbrain','elysia-bioscience')
UNION ALL SELECT 'Legal Entities', COUNT(*) FROM legal_entities WHERE siren IN ('938054566','977837061','848321279');
