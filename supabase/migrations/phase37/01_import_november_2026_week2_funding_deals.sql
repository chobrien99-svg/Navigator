-- =============================================================================
-- November 2026 Funding Deals Import — Week 2 (2 deals, announced Nov 2 2026)
-- =============================================================================
-- source_name 'funding_deals_november_2026_week2'. Amounts in millions, EUR.
--
-- 2 new orgs (Gallium Defense, Pelagon). Both SIRENs verified against the
-- French business registry (Pappers): Gallium Defense 103443461 (Paris 15e,
-- created 2026-04-02), Pelagon 105773261 (Paris 1er, created 2026-05-26).
-- All 9 investors and all sectors already exist; no new cities.
--
-- Special cases:
--   * Gallium Defense: round closed June 2026, publicly announced 2026-11-02;
--     announced_date uses the announcement date. Co-leads: Keen Venture
--     Partners, 360 Capital.
--   * Pelagon: pre-seed, amount undisclosed (amount_eur NULL).
--   * Aymeric de Pontbriand: person slug already exists (co-founder of
--     Scortex); assumed to be the same person, so the existing record is
--     reused (ON CONFLICT DO NOTHING) and linked to Pelagon.
-- =============================================================================

-- Step 1: new organizations
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"name":"Gallium Defense","slug":"gallium-defense","website":"https://gallium-defense.com/","description":"Develops affordable, software-defined 3D radar systems for detecting and tracking drones. Its GDS-10 radar combines active electronically scanned array (AESA) technology, commercially available components, and embedded AI to protect military installations and critical infrastructure, including airports, ports, and energy facilities."},
  {"name":"Pelagon","slug":"pelagon","website":"https://pelagon.xyz/","description":"Develops autonomous underwater surveillance and interception systems to protect ports, naval bases, offshore energy installations, and submarine cables. Its Interdiction Dome combines distributed acoustic sensors, AI-powered threat detection, underwater interceptors, and integrated command software."}
]$json$) AS (name TEXT, slug TEXT, website TEXT, description TEXT))
INSERT INTO organizations (id, name, slug, organization_type, description, website, status, country, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), s.name, s.slug, 'startup'::organization_type, s.description, s.website, 'active'::organization_status, 'France', 'funding_deals_november_2026_week2', NOW(), NOW()
FROM source s
ON CONFLICT (slug) DO UPDATE SET website=COALESCE(organizations.website, EXCLUDED.website), description=COALESCE(organizations.description, EXCLUDED.description), updated_at=NOW();

-- Step 1b: city links (both Paris)
UPDATE organizations o SET city_id=COALESCE(o.city_id, c.id), updated_at=NOW()
FROM cities c WHERE c.slug='paris' AND o.slug IN ('gallium-defense','pelagon');

-- Step 2: funding rounds
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"slug":"gallium-defense","stage":"seed","amount_eur":7.1,"currency_original":"EUR","amount_original":7100000,"announced_date":"2026-11-02","notes":"€7.1M seed co-led by Keen Venture Partners and 360 Capital, announced as the company emerged from stealth, to industrialize its affordable drone-detection radar. The GDS-10 is designed to detect small drones up to 10 km away, track multiple targets and integrate with existing defense systems. Funds production, recruitment, AI model training and field demonstrations with civilian and military customers; orders to open Q1 2027. Round actually closed June 2026; Nov 2 is the public announcement date. Radar performance specs company-reported. Investors: Keen Venture Partners (co-lead), 360 Capital (co-lead), Omnes Capital, Polytechnique Ventures. Source: FrenchWeb, Keen Venture Partners, Tech.eu."},
  {"slug":"pelagon","stage":"pre_seed","amount_eur":null,"currency_original":null,"amount_original":null,"announced_date":"2026-11-02","notes":"First institutional round (amount undisclosed), announced as the company emerged from stealth. Funds recruitment, AI research and commercial deployment of its autonomous maritime security systems. The Interdiction Dome integrates distributed acoustic sensors, the ORCA underwater perception model, MARLIN interceptors and proprietary software as a managed protection service. First real-world tests in Sweden (May 2026); commercial deployments in the Mediterranean since August 2026; Baltic and Black Sea deployments planned before end-2026 (company-reported). Investors: Bpifrance Digital Venture, Elaia, Seedcamp, Hexa, Business Angels. Source: Bpifrance."}
]$json$) AS (slug TEXT, stage TEXT, amount_eur NUMERIC, currency_original TEXT, amount_original NUMERIC, announced_date TEXT, notes TEXT))
INSERT INTO funding_rounds (id, organization_id, stage, amount_eur, currency_original, amount_original, announced_date, is_estimated, is_verified, source_name, notes, created_at)
SELECT uuid_generate_v4(), o.id, s.stage::funding_stage, s.amount_eur, s.currency_original, s.amount_original, s.announced_date::DATE,
  FALSE, FALSE, 'funding_deals_november_2026_week2', s.notes, NOW()
FROM source s JOIN organizations o ON o.slug=s.slug
WHERE NOT EXISTS (SELECT 1 FROM funding_rounds x WHERE x.organization_id=o.id AND x.source_name='funding_deals_november_2026_week2');

-- Step 3: funding round investors (all investor orgs already exist; joined by slug)
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"slug":"gallium-defense","investor_slug":"keen-venture-partners","investor_name":"Keen Venture Partners","is_lead":true},
  {"slug":"gallium-defense","investor_slug":"360-capital","investor_name":"360 Capital","is_lead":true},
  {"slug":"gallium-defense","investor_slug":"omnes-capital","investor_name":"Omnes Capital","is_lead":false},
  {"slug":"gallium-defense","investor_slug":"polytechnique-ventures","investor_name":"Polytechnique Ventures","is_lead":false},
  {"slug":"pelagon","investor_slug":"bpifrance-digital-venture","investor_name":"Bpifrance Digital Venture","is_lead":false},
  {"slug":"pelagon","investor_slug":"elaia","investor_name":"Elaia","is_lead":false},
  {"slug":"pelagon","investor_slug":"seedcamp","investor_name":"Seedcamp","is_lead":false},
  {"slug":"pelagon","investor_slug":"hexa","investor_name":"Hexa","is_lead":false},
  {"slug":"pelagon","investor_slug":"business-angels","investor_name":"Business Angels","is_lead":false}
]$json$) AS (slug TEXT, investor_slug TEXT, investor_name TEXT, is_lead BOOLEAN))
INSERT INTO funding_round_investors (id, funding_round_id, investor_id, is_lead, investor_name, created_at)
SELECT uuid_generate_v4(), fr.id, inv.id, s.is_lead, s.investor_name, NOW()
FROM source s
JOIN organizations o ON o.slug=s.slug
JOIN organizations inv ON inv.slug=s.investor_slug
JOIN funding_rounds fr ON fr.organization_id=o.id AND fr.source_name='funding_deals_november_2026_week2'
WHERE NOT EXISTS (SELECT 1 FROM funding_round_investors x WHERE x.funding_round_id=fr.id AND x.investor_id=inv.id);

-- Step 4a: sector links
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"org":"gallium-defense","sec":"defensetech"},{"org":"gallium-defense","sec":"deeptech"},{"org":"gallium-defense","sec":"artificial-intelligence"},{"org":"gallium-defense","sec":"drones"},
  {"org":"pelagon","sec":"defensetech"},{"org":"pelagon","sec":"artificial-intelligence"},{"org":"pelagon","sec":"deeptech"}
]$json$) AS (org TEXT, sec TEXT))
INSERT INTO organization_sectors (id, organization_id, sector_id, is_primary, created_at)
SELECT uuid_generate_v4(), o.id, sec.id, FALSE, NOW()
FROM source s JOIN organizations o ON o.slug=s.org JOIN sectors sec ON sec.slug=s.sec
ON CONFLICT (organization_id, sector_id) DO NOTHING;

-- Step 4b: primary sector (DefenseTech for both) where none exists
UPDATE organization_sectors os SET is_primary=TRUE
FROM organizations o, sectors sec
WHERE o.slug IN ('gallium-defense','pelagon') AND sec.slug='defensetech'
  AND os.organization_id=o.id AND os.sector_id=sec.id
  AND NOT EXISTS (SELECT 1 FROM organization_sectors x WHERE x.organization_id=o.id AND x.is_primary=TRUE);

-- Step 5: people (founders; Aymeric de Pontbriand already exists and is reused)
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"full_name":"Eric Fournier","first_name":"Eric","last_name":"Fournier"},
  {"full_name":"Florian Lemoine","first_name":"Florian","last_name":"Lemoine"},
  {"full_name":"Robin Mandel","first_name":"Robin","last_name":"Mandel"},
  {"full_name":"Gauthier Bouxin","first_name":"Gauthier","last_name":"Bouxin"},
  {"full_name":"Aymeric de Pontbriand","first_name":"Aymeric","last_name":"de Pontbriand"}
]$json$) AS (full_name TEXT, first_name TEXT, last_name TEXT))
INSERT INTO people (id, full_name, slug, first_name, last_name, legacy_source, created_at)
SELECT uuid_generate_v4(), s.full_name, lower(regexp_replace(regexp_replace(unaccent(s.full_name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g')), s.first_name, s.last_name, 'funding_deals_november_2026_week2', NOW()
FROM source s ON CONFLICT (slug) DO NOTHING;

-- Step 6: founder links
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"org":"gallium-defense","founder":"eric-fournier"},{"org":"gallium-defense","founder":"florian-lemoine"},{"org":"gallium-defense","founder":"robin-mandel"},
  {"org":"pelagon","founder":"gauthier-bouxin"},{"org":"pelagon","founder":"aymeric-de-pontbriand"}
]$json$) AS (org TEXT, founder TEXT))
INSERT INTO organization_people (id, organization_id, person_id, role, is_current, is_founder, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, p.id, 'Founder', TRUE, TRUE, NOW(), NOW()
FROM source s JOIN organizations o ON o.slug=s.org JOIN people p ON p.slug=s.founder
ON CONFLICT (organization_id, person_id, role) DO NOTHING;

-- Step 7: SIREN legal entities
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"org":"gallium-defense","legal_name":"GALLIUM DEFENSE","siren":"103443461"},
  {"org":"pelagon","legal_name":"PELAGON","siren":"105773261"}
]$json$) AS (org TEXT, legal_name TEXT, siren TEXT))
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, s.legal_name, s.siren, 'France', NOT EXISTS (SELECT 1 FROM legal_entities le2 WHERE le2.organization_id=o.id), NOW(), NOW()
FROM source s JOIN organizations o ON o.slug=s.org
WHERE NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id=o.id AND le.siren=s.siren);

-- Verification
SELECT 'Funding Rounds' AS entity, COUNT(*) AS count FROM funding_rounds WHERE source_name='funding_deals_november_2026_week2'
UNION ALL SELECT 'Investor Links', COUNT(*) FROM funding_round_investors fri JOIN funding_rounds fr ON fr.id=fri.funding_round_id WHERE fr.source_name='funding_deals_november_2026_week2'
UNION ALL SELECT 'New Orgs (startup)', COUNT(*) FROM organizations WHERE legacy_source='funding_deals_november_2026_week2' AND organization_type='startup'
UNION ALL SELECT 'Founder Links', COUNT(*) FROM organization_people op JOIN organizations o ON o.id=op.organization_id WHERE o.slug IN ('gallium-defense','pelagon') AND op.is_founder
UNION ALL SELECT 'Legal Entities', COUNT(*) FROM legal_entities WHERE siren IN ('103443461','105773261');
