-- =============================================================================
-- November 2026 Funding Deals Import — Week 4 (2 deals, announced Nov 5–6 2026)
-- =============================================================================
-- source_name 'funding_deals_november_2026_week4'. Amounts in millions, EUR.
--
-- * Physicl: new org. SIREN 105324149 verified (PHYSICL, registered office
--   Bordeaux, created 2026-05-20); HQ recorded as Paris per the company, with
--   San Francisco as secondary city. $10M converted at 0.86 EUR/USD (the rate
--   used for other autumn-2026 USD rounds) = €8.60M, is_estimated TRUE.
--   Lead: Inovia Capital.
-- * Resilience Care: existing org 'resilience' (already holds SIREN 893834713
--   and three earlier rounds). New €48M growth-equity round from PSG Equity;
--   founders linked (none were before).
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "unaccent";

-- Step 1: new organization
INSERT INTO organizations (id, name, slug, organization_type, description, website, status, country, legacy_source, created_at, updated_at)
VALUES (uuid_generate_v4(), 'Physicl', 'physicl', 'startup'::organization_type,
  'Develops a platform that generates high-fidelity synthetic training data for physical AI models, helping researchers identify and correct failures in unusual real-world scenarios. Its Studio application provides access to 10,000 3D environments, more than 100,000 assets, and billions of possible scene variations, enabling AI teams to recreate edge cases, generate targeted training data, and measure improvements.',
  'https://physicl.ai/', 'active'::organization_status, 'France', 'funding_deals_november_2026_week4', NOW(), NOW())
ON CONFLICT (slug) DO NOTHING;

-- Step 1b: cities
UPDATE organizations o SET city_id=COALESCE(o.city_id, c.id), updated_at=NOW()
FROM cities c WHERE c.slug='paris' AND o.slug IN ('physicl','resilience');
UPDATE organizations o SET secondary_city_id=COALESCE(o.secondary_city_id, c.id), updated_at=NOW()
FROM cities c WHERE c.slug='san-francisco' AND o.slug='physicl';

-- Step 2: funding rounds
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"slug":"physicl","stage":"seed","amount_eur":8.6,"currency_original":"USD","amount_original":10000000,"announced_date":"2026-11-06","notes":"$10M seed led by Inovia Capital to expand the team and accelerate its synthetic training-data platform for physical AI. Launched Studio, letting robotics and world-model researchers generate customized 3D environments and precise ground-truth data for situations where their models fail. Says it works with Meta, World Labs, Epic Games and SpAItial; SpAItial reportedly cut its room-reconstruction error rate by more than half using Physicl data (company-reported). EUR amount converted at 0.86. Investors: Inovia Capital (lead), U.S. Venture Partners, Insight Partners. Source: Physicl, TechCrunch."},
  {"slug":"resilience","stage":"growth","amount_eur":48.0,"currency_original":"EUR","amount_original":48000000,"announced_date":"2026-11-05","notes":"€48M growth equity from US firm PSG Equity to expand beyond cancer care into psychiatry and gastroenterology and accelerate international growth through acquisitions (incl. companies with established reimbursement arrangements). Platform developed with Gustave Roussy; >40,000 oncology patients across ~200 French institutions; 12 partner facilities in Germany; acquired German psychiatric-monitoring startup Recovery Cat (Sept 2026); US commercial team recruited. Targets group-level profitability by Q2 2027. Described as growth equity; a buyout or change of control has not been established. Investors: PSG Equity. Source: Les Echos."}
]$json$) AS (slug TEXT, stage TEXT, amount_eur NUMERIC, currency_original TEXT, amount_original NUMERIC, announced_date TEXT, notes TEXT))
INSERT INTO funding_rounds (id, organization_id, stage, amount_eur, currency_original, amount_original, announced_date, is_estimated, is_verified, source_name, notes, created_at)
SELECT uuid_generate_v4(), o.id, s.stage::funding_stage, s.amount_eur, s.currency_original, s.amount_original, s.announced_date::DATE,
  s.currency_original <> 'EUR', FALSE, 'funding_deals_november_2026_week4', s.notes, NOW()
FROM source s JOIN organizations o ON o.slug=s.slug
WHERE NOT EXISTS (SELECT 1 FROM funding_rounds x WHERE x.organization_id=o.id AND x.source_name='funding_deals_november_2026_week4');

-- Step 3a: new investor
INSERT INTO organizations (id, name, slug, organization_type, status, country, legacy_source, created_at, updated_at)
VALUES (uuid_generate_v4(), 'U.S. Venture Partners', 'us-venture-partners', 'investor'::organization_type, 'active'::organization_status, 'United States', 'funding_deals_november_2026_week4', NOW(), NOW())
ON CONFLICT (slug) DO NOTHING;

-- Step 3b: investor links
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"slug":"physicl","inv":"inovia-capital","name":"Inovia Capital","is_lead":true},
  {"slug":"physicl","inv":"us-venture-partners","name":"U.S. Venture Partners","is_lead":false},
  {"slug":"physicl","inv":"insight-partners","name":"Insight Partners","is_lead":false},
  {"slug":"resilience","inv":"psg-equity","name":"PSG Equity","is_lead":true}
]$json$) AS (slug TEXT, inv TEXT, name TEXT, is_lead BOOLEAN))
INSERT INTO funding_round_investors (id, funding_round_id, investor_id, is_lead, investor_name, created_at)
SELECT uuid_generate_v4(), fr.id, i.id, s.is_lead, s.name, NOW()
FROM source s
JOIN organizations o ON o.slug=s.slug
JOIN organizations i ON i.slug=s.inv
JOIN funding_rounds fr ON fr.organization_id=o.id AND fr.source_name='funding_deals_november_2026_week4'
WHERE NOT EXISTS (SELECT 1 FROM funding_round_investors x WHERE x.funding_round_id=fr.id AND x.investor_id=i.id);

-- Step 4: sectors (+ primary where none)
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"org":"physicl","sec":"artificial-intelligence"},{"org":"physicl","sec":"robotics"},
  {"org":"resilience","sec":"healthtech"},{"org":"resilience","sec":"medtech"}
]$json$) AS (org TEXT, sec TEXT))
INSERT INTO organization_sectors (id, organization_id, sector_id, is_primary, created_at)
SELECT uuid_generate_v4(), o.id, sec.id, FALSE, NOW()
FROM source s JOIN organizations o ON o.slug=s.org JOIN sectors sec ON sec.slug=s.sec
ON CONFLICT (organization_id, sector_id) DO NOTHING;

WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"org":"physicl","sec":"artificial-intelligence"},{"org":"resilience","sec":"healthtech"}
]$json$) AS (org TEXT, sec TEXT))
UPDATE organization_sectors os SET is_primary=TRUE
FROM source s JOIN organizations o ON o.slug=s.org JOIN sectors sec ON sec.slug=s.sec
WHERE os.organization_id=o.id AND os.sector_id=sec.id
  AND NOT EXISTS (SELECT 1 FROM organization_sectors x WHERE x.organization_id=o.id AND x.is_primary=TRUE);

-- Step 5: people
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"full_name":"Alex de Vigan","first_name":"Alex","last_name":"de Vigan"},
  {"full_name":"Thomas Gourlat","first_name":"Thomas","last_name":"Gourlat"},
  {"full_name":"Céline Lazorthes","first_name":"Céline","last_name":"Lazorthes"},
  {"full_name":"Jonathan Benhamou","first_name":"Jonathan","last_name":"Benhamou"}
]$json$) AS (full_name TEXT, first_name TEXT, last_name TEXT))
INSERT INTO people (id, full_name, slug, first_name, last_name, legacy_source, created_at)
SELECT uuid_generate_v4(), s.full_name, lower(regexp_replace(regexp_replace(unaccent(s.full_name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g')), s.first_name, s.last_name, 'funding_deals_november_2026_week4', NOW()
FROM source s ON CONFLICT (slug) DO NOTHING;

-- Step 6: founder links
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"org":"physicl","p":"alex-de-vigan"},{"org":"physicl","p":"thomas-gourlat"},
  {"org":"resilience","p":"celine-lazorthes"},{"org":"resilience","p":"jonathan-benhamou"}
]$json$) AS (org TEXT, p TEXT))
INSERT INTO organization_people (id, organization_id, person_id, role, is_current, is_founder, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, pp.id, 'Founder', TRUE, TRUE, NOW(), NOW()
FROM source s JOIN organizations o ON o.slug=s.org JOIN people pp ON pp.slug=s.p
WHERE NOT EXISTS (SELECT 1 FROM organization_people x WHERE x.organization_id=o.id AND x.person_id=pp.id)
ON CONFLICT (organization_id, person_id, role) DO NOTHING;

-- Step 7: legal entity (Resilience already holds its SIREN)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'PHYSICL', '105324149', 'France', NOT EXISTS (SELECT 1 FROM legal_entities le2 WHERE le2.organization_id=o.id), NOW(), NOW()
FROM organizations o WHERE o.slug='physicl'
  AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id=o.id AND le.siren='105324149');

-- Verification
SELECT 'Funding Rounds' AS entity, COUNT(*) AS count FROM funding_rounds WHERE source_name='funding_deals_november_2026_week4'
UNION ALL SELECT 'Investor Links', COUNT(*) FROM funding_round_investors fri JOIN funding_rounds fr ON fr.id=fri.funding_round_id WHERE fr.source_name='funding_deals_november_2026_week4'
UNION ALL SELECT 'Founder Links', COUNT(*) FROM organization_people op JOIN organizations o ON o.id=op.organization_id WHERE o.slug IN ('physicl','resilience') AND op.is_founder
UNION ALL SELECT 'Legal Entities', COUNT(*) FROM legal_entities WHERE siren IN ('105324149','893834713');
