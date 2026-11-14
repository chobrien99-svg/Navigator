-- =============================================================================
-- November 2026 Funding Deals Import — Week 6 (5 deals, announced Nov 9–12 2026)
-- =============================================================================
-- source_name 'funding_deals_november_2026_week6'. Amounts in millions, EUR.
-- All five are new organizations. SIRENs verified against the official French
-- company registry (recherche-entreprises.api.gouv.fr):
--   NGPES 508415676 = NGPES PAYMENTS (Paris, created 2008; Souren/Suren
--     Hayriyan chairs the board). €5M from existing investors incl. founders;
--     no named investors, so no investor links.
--   SolidUltra 106359821 = SOLIDULTRA (Massy, created 2026-06-02; Watt & Well
--     is its Président de SAS, Raul Iglesias DG). Watt & Well already exists
--     as org 'wattwell'.
--   Heal.dev 953111689 = legal entity MYIA (Paris; Malo Marrec président).
--   WELL 990915852 = WELL APP (registered office Neuilly-sur-Seine; HQ recorded
--     as Paris per the company). $4M pre-seed, stored as €3.6M as reported by
--     FrenchWeb, is_estimated TRUE. Lead: Speedinvest.
--   Humbird 839912631 = HUMBIRD (Nantes). €1.1M from Samuel Berthelot and
--     Grégoire Germain (new individual investors), who now jointly hold a
--     majority and are registered as DG and Président respectively.
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "unaccent";

-- Step 1: new organizations
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"name":"NGPES","slug":"ngpes","website":"https://www.ngpes.com/","description":"Develops a financial infrastructure platform connecting traditional banking and payment systems with blockchain-based digital asset settlement. Its platform combines IBAN-linked accounts, custodial wallets and euro on-ramp/off-ramp services, enabling financial institutions and businesses to manage fiat and digital asset transactions through a unified system."},
  {"name":"SolidUltra","slug":"solidultra","website":"https://solidultra.com/","description":"Develops modular solid-state transformers designed to connect medium-voltage electricity grids directly to the 800VDC power architecture emerging in AI data centers. Its technology aims to eliminate intermediate power-conversion stages, reducing energy losses, equipment footprint and the time required to deploy electrical infrastructure."},
  {"name":"Heal.dev","slug":"heal-dev","website":"https://www.heal.dev","description":"Develops AI agents that detect and reproduce software bugs, security vulnerabilities and performance problems. Its technology runs applications in simulated production environments to identify failures that conventional code reviews and automated tests may miss, providing developers with reproducible evidence to accelerate fixes."},
  {"name":"WELL","slug":"well","website":"https://wellapp.ai/","description":"Develops an AI assistant for founders and small-business owners that automates administrative and financial tasks through WhatsApp, ChatGPT, Claude, Chrome and a web application. Its platform connects banking, accounting, email, invoicing and CRM tools to prepare meetings, generate invoices, follow up on payments and organize tax filings. Actions involving financial commitments or external communications require user approval."},
  {"name":"Humbird","slug":"humbird","website":"https://www.humbird.fr/","description":"Designs and manufactures pedal-assisted lightweight vehicles for collective transportation and urban logistics. Its WoodyBus carries groups of children or adults, while its WoodyTruck targets short-distance commercial deliveries and equipment transportation. The vehicles incorporate wooden structures and electric assistance to reduce their environmental footprint."}
]$json$) AS (name TEXT, slug TEXT, website TEXT, description TEXT))
INSERT INTO organizations (id, name, slug, organization_type, description, website, status, country, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), s.name, s.slug, 'startup'::organization_type, s.description, s.website, 'active'::organization_status, 'France', 'funding_deals_november_2026_week6', NOW(), NOW()
FROM source s ON CONFLICT (slug) DO NOTHING;

-- Step 1b: cities
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"slug":"ngpes","city":"paris"},{"slug":"solidultra","city":"massy"},{"slug":"heal-dev","city":"paris"},
  {"slug":"well","city":"paris"},{"slug":"humbird","city":"nantes"}
]$json$) AS (slug TEXT, city TEXT))
UPDATE organizations o SET city_id=COALESCE(o.city_id, c.id), updated_at=NOW()
FROM source s JOIN cities c ON c.slug=s.city WHERE o.slug=s.slug;

-- Step 2: funding rounds
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"slug":"ngpes","stage":"growth","amount_eur":5.0,"currency_original":"EUR","amount_original":5000000,"announced_date":"2026-11-10","est":false,"notes":"Additional €5M from existing investors, including its founders, ahead of the commercial launch of its platform connecting conventional payment infrastructure (IBAN-linked accounts) with blockchain-based settlement, digital asset custody and euro conversion. Holds a French Payment Institution authorization; EMI and CASP approvals still pending and required for planned services. Follows an earlier round and ~€5M in initial founder commitments. Plans EuroF, a euro stablecoin, subject to regulatory authorization. Investors: undisclosed (existing investors incl. founders). Source: IBS Intelligence."},
  {"slug":"solidultra","stage":"seed","amount_eur":3.0,"currency_original":"EUR","amount_original":3000000,"announced_date":"2026-11-09","est":false,"notes":"€3M initial financing backed by industrial partner Watt & Well (also its registered Président) to develop solid-state transformers converting medium-voltage grid power directly to 800VDC for AI data centers. Targets 98.5% efficiency and a 4x smaller footprint; commercial deployment targeted for 2028 and 10,000 modular systems (~1 GW) by 2032 (company projections, not demonstrated results). Funds engineering, product development, industrialization and first customers. Investors: Watt & Well. Source: GlobeNewswire."},
  {"slug":"heal-dev","stage":"seed","amount_eur":4.0,"currency_original":"EUR","amount_original":4000000,"announced_date":"2026-11-10","est":false,"notes":"€4M from Mango Capital and Alven for its AI agents that detect and reproduce software bugs, security vulnerabilities and performance problems. Pivoted from automated testing toward issues that code reviews miss; says its agents catch failures traditional tools overlook in ~70% of cases (internal benchmark, company-reported). Around a dozen startup customers. Funds product, engineering hires and European expansion. Investors: Mango Capital, Alven. Source: L'Informaticien, J'aime les startups."},
  {"slug":"well","stage":"pre_seed","amount_eur":3.6,"currency_original":"USD","amount_original":4000000,"announced_date":"2026-11-12","est":true,"notes":"$4M (~€3.6M) pre-seed led by Speedinvest, alongside the launch of its AI assistant on WhatsApp (public in France since Nov 4). Integrates with Qonto, Pennylane, Stripe, Gmail and CRMs to automate invoicing, payment follow-ups, meeting prep and accounting; sensitive actions require human approval ('System 2' architecture). Reports >700,000 business records processed and 12 employees (Sept 2026). Funds engineering/product hires, integrations, e-invoicing and expansion to the US and Europe. Investors: Speedinvest (lead), Kima Ventures, Purple, OPRTRS Club, Relics Ventures, Source Ventures, 199 Ventures. Source: FrenchWeb."},
  {"slug":"humbird","stage":"seed","amount_eur":1.1,"currency_original":"EUR","amount_original":1100000,"announced_date":"2026-11-10","est":false,"notes":"€1.1M from private investors and executives Samuel Berthelot and Grégoire Germain, who now jointly hold a majority of the share capital (whether part of the deal is a secondary purchase is undisclosed). >100 vehicles deployed in France and Belgium; plans to enter the Netherlands, Germany, Spain and Italy in 2027–2028. Funds hiring, manufacturing improvements and commercialization of the WoodyTruck (up to 250 kg payload). Investors: Samuel Berthelot, Grégoire Germain. Source: Presse Agence, SPORTéco."}
]$json$) AS (slug TEXT, stage TEXT, amount_eur NUMERIC, currency_original TEXT, amount_original NUMERIC, announced_date TEXT, est BOOLEAN, notes TEXT))
INSERT INTO funding_rounds (id, organization_id, stage, amount_eur, currency_original, amount_original, announced_date, is_estimated, is_verified, source_name, notes, created_at)
SELECT uuid_generate_v4(), o.id, s.stage::funding_stage, s.amount_eur, s.currency_original, s.amount_original, s.announced_date::DATE,
  s.est, FALSE, 'funding_deals_november_2026_week6', s.notes, NOW()
FROM source s JOIN organizations o ON o.slug=s.slug
WHERE NOT EXISTS (SELECT 1 FROM funding_rounds x WHERE x.organization_id=o.id AND x.source_name='funding_deals_november_2026_week6');

-- Step 3a: new investors (individual angels are stored as investor orgs, as before)
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"name":"Relics Ventures","slug":"relics-ventures"},
  {"name":"Samuel Berthelot","slug":"samuel-berthelot"},
  {"name":"Grégoire Germain","slug":"gregoire-germain"}
]$json$) AS (name TEXT, slug TEXT))
INSERT INTO organizations (id, name, slug, organization_type, status, country, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), s.name, s.slug, 'investor'::organization_type, 'active'::organization_status, 'France', 'funding_deals_november_2026_week6', NOW(), NOW()
FROM source s ON CONFLICT (slug) DO NOTHING;

-- Step 3b: investor links
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"slug":"solidultra","inv":"wattwell","name":"Watt & Well","is_lead":true},
  {"slug":"heal-dev","inv":"mango-capital","name":"Mango Capital","is_lead":false},
  {"slug":"heal-dev","inv":"alven","name":"Alven","is_lead":false},
  {"slug":"well","inv":"speedinvest","name":"Speedinvest","is_lead":true},
  {"slug":"well","inv":"kima-ventures","name":"Kima Ventures","is_lead":false},
  {"slug":"well","inv":"purple","name":"Purple","is_lead":false},
  {"slug":"well","inv":"oprtrs-club","name":"OPRTRS Club","is_lead":false},
  {"slug":"well","inv":"relics-ventures","name":"Relics Ventures","is_lead":false},
  {"slug":"well","inv":"source-ventures","name":"Source Ventures","is_lead":false},
  {"slug":"well","inv":"199-ventures","name":"199 Ventures","is_lead":false},
  {"slug":"humbird","inv":"samuel-berthelot","name":"Samuel Berthelot","is_lead":false},
  {"slug":"humbird","inv":"gregoire-germain","name":"Grégoire Germain","is_lead":false}
]$json$) AS (slug TEXT, inv TEXT, name TEXT, is_lead BOOLEAN))
INSERT INTO funding_round_investors (id, funding_round_id, investor_id, is_lead, investor_name, created_at)
SELECT uuid_generate_v4(), fr.id, i.id, s.is_lead, s.name, NOW()
FROM source s
JOIN organizations o ON o.slug=s.slug
JOIN organizations i ON i.slug=s.inv
JOIN funding_rounds fr ON fr.organization_id=o.id AND fr.source_name='funding_deals_november_2026_week6'
WHERE NOT EXISTS (SELECT 1 FROM funding_round_investors x WHERE x.funding_round_id=fr.id AND x.investor_id=i.id);

-- Step 4: sectors (first listed = primary)
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"org":"ngpes","sec":"fintech","p":true},{"org":"ngpes","sec":"blockchain","p":false},{"org":"ngpes","sec":"web3","p":false},
  {"org":"solidultra","sec":"deeptech","p":true},{"org":"solidultra","sec":"artificial-intelligence","p":false},{"org":"solidultra","sec":"semiconductors","p":false},{"org":"solidultra","sec":"energy","p":false},
  {"org":"heal-dev","sec":"artificial-intelligence","p":true},{"org":"heal-dev","sec":"cybersecurity","p":false},{"org":"heal-dev","sec":"saas","p":false},
  {"org":"well","sec":"artificial-intelligence","p":true},{"org":"well","sec":"fintech","p":false},{"org":"well","sec":"saas","p":false},
  {"org":"humbird","sec":"mobility","p":true},{"org":"humbird","sec":"climatetech","p":false}
]$json$) AS (org TEXT, sec TEXT, p BOOLEAN))
INSERT INTO organization_sectors (id, organization_id, sector_id, is_primary, created_at)
SELECT uuid_generate_v4(), o.id, sec.id, s.p, NOW()
FROM source s JOIN organizations o ON o.slug=s.org JOIN sectors sec ON sec.slug=s.sec
ON CONFLICT (organization_id, sector_id) DO NOTHING;

-- Step 5: people
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"full_name":"Raul Iglesias","first_name":"Raul","last_name":"Iglesias"},
  {"full_name":"Romain Beaume","first_name":"Romain","last_name":"Beaume"},
  {"full_name":"Alain Rouault","first_name":"Alain","last_name":"Rouault"},
  {"full_name":"Malo Marrec","first_name":"Malo","last_name":"Marrec"},
  {"full_name":"Pierre Oucif","first_name":"Pierre","last_name":"Oucif"},
  {"full_name":"Ben Lang","first_name":"Ben","last_name":"Lang"},
  {"full_name":"Maxime Champoux","first_name":"Maxime","last_name":"Champoux"},
  {"full_name":"Bastien Blanc","first_name":"Bastien","last_name":"Blanc"},
  {"full_name":"Jean-François Robert","first_name":"Jean-François","last_name":"Robert"},
  {"full_name":"Samuel Berthelot","first_name":"Samuel","last_name":"Berthelot"},
  {"full_name":"Grégoire Germain","first_name":"Grégoire","last_name":"Germain"}
]$json$) AS (full_name TEXT, first_name TEXT, last_name TEXT))
INSERT INTO people (id, full_name, slug, first_name, last_name, legacy_source, created_at)
SELECT uuid_generate_v4(), s.full_name, lower(regexp_replace(regexp_replace(unaccent(s.full_name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g')), s.first_name, s.last_name, 'funding_deals_november_2026_week6', NOW()
FROM source s ON CONFLICT (slug) DO NOTHING;

-- Step 6: founder links + Humbird's registered officers
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"org":"ngpes","p":"suren-hayriyan","role":"Founder","f":true},
  {"org":"solidultra","p":"raul-iglesias","role":"Founder","f":true},{"org":"solidultra","p":"romain-beaume","role":"Founder","f":true},{"org":"solidultra","p":"alain-rouault","role":"Founder","f":true},
  {"org":"heal-dev","p":"malo-marrec","role":"Founder","f":true},{"org":"heal-dev","p":"pierre-oucif","role":"Founder","f":true},{"org":"heal-dev","p":"ben-lang","role":"Founder","f":true},
  {"org":"well","p":"maxime-champoux","role":"Founder","f":true},{"org":"well","p":"bastien-blanc","role":"Founder","f":true},
  {"org":"humbird","p":"jean-francois-robert","role":"Founder","f":true},
  {"org":"humbird","p":"gregoire-germain","role":"President","f":false},
  {"org":"humbird","p":"samuel-berthelot","role":"Managing Director","f":false}
]$json$) AS (org TEXT, p TEXT, role TEXT, f BOOLEAN))
INSERT INTO organization_people (id, organization_id, person_id, role, is_current, is_founder, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, pp.id, s.role, TRUE, s.f, NOW(), NOW()
FROM source s JOIN organizations o ON o.slug=s.org JOIN people pp ON pp.slug=s.p
WHERE NOT EXISTS (SELECT 1 FROM organization_people x WHERE x.organization_id=o.id AND x.person_id=pp.id)
ON CONFLICT (organization_id, person_id, role) DO NOTHING;

-- Step 7: legal entities
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"org":"ngpes","legal":"NGPES PAYMENTS","siren":"508415676"},
  {"org":"solidultra","legal":"SOLIDULTRA","siren":"106359821"},
  {"org":"heal-dev","legal":"MYIA","siren":"953111689"},
  {"org":"well","legal":"WELL APP","siren":"990915852"},
  {"org":"humbird","legal":"HUMBIRD","siren":"839912631"}
]$json$) AS (org TEXT, legal TEXT, siren TEXT))
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, s.legal, s.siren, 'France', NOT EXISTS (SELECT 1 FROM legal_entities le2 WHERE le2.organization_id=o.id), NOW(), NOW()
FROM source s JOIN organizations o ON o.slug=s.org
WHERE NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.siren=s.siren);

-- Verification
SELECT 'Funding Rounds' AS entity, COUNT(*) AS count FROM funding_rounds WHERE source_name='funding_deals_november_2026_week6'
UNION ALL SELECT 'Investor Links', COUNT(*) FROM funding_round_investors fri JOIN funding_rounds fr ON fr.id=fri.funding_round_id WHERE fr.source_name='funding_deals_november_2026_week6'
UNION ALL SELECT 'Founder Links', COUNT(*) FROM organization_people op JOIN organizations o ON o.id=op.organization_id WHERE o.slug IN ('ngpes','solidultra','heal-dev','well','humbird') AND op.is_founder
UNION ALL SELECT 'Legal Entities', COUNT(*) FROM legal_entities WHERE siren IN ('508415676','106359821','953111689','990915852','839912631');
