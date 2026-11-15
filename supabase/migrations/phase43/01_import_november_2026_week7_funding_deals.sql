-- =============================================================================
-- November 2026 Funding Deals Import — Week 7 (1 deal, announced Nov 12 2026)
-- =============================================================================
-- source_name 'funding_deals_november_2026_week7'. Amounts in millions, EUR.
--
-- * Namkin: new org. SIREN 811785088 verified against the official French
--   company registry (NAMKIN, Rosières-près-Troyes, created 2015-06-01;
--   président Nicolas Declercq-Duvernoy). €1.5M with an equity investment from
--   Hand Partners (lead), plus Bpifrance and Caisse d'Épargne; the equity/debt
--   split is undisclosed. All three investors already exist. No IndustrialTech
--   sector exists, so AI / MarTech / SaaS are used.
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "unaccent";

INSERT INTO organizations (id, name, slug, organization_type, description, website, status, country, legacy_source, created_at, updated_at)
VALUES (uuid_generate_v4(), 'Namkin', 'namkin', 'startup'::organization_type,
  'Develops Iteraa, an AI-powered market intelligence platform for industrial companies. The software analyzes web content, news and social media to identify emerging market trends, monitor customers and competitors, map industrial supply chains and uncover commercial opportunities. Namkin also provides industrial marketing consulting and digital transformation services.',
  'https://namkin.fr/', 'active'::organization_status, 'France', 'funding_deals_november_2026_week7', NOW(), NOW())
ON CONFLICT (slug) DO NOTHING;

UPDATE organizations o SET city_id=COALESCE(o.city_id, c.id), updated_at=NOW()
FROM cities c WHERE c.slug='rosieres-pres-troyes' AND o.slug='namkin';

INSERT INTO funding_rounds (id, organization_id, stage, amount_eur, currency_original, amount_original, announced_date, is_estimated, is_verified, source_name, notes, created_at)
SELECT uuid_generate_v4(), o.id, 'seed'::funding_stage, 1.5, 'EUR', 1500000, '2026-11-12'::DATE, FALSE, FALSE, 'funding_deals_november_2026_week7',
  '€1.5M financing involving an equity investment from Hand Partners to accelerate development and commercialization of Iteraa, its AI market-intelligence platform for industrial markets (weak-signal detection, mapping of customers, suppliers and competitors). The equity/debt breakdown has not been disclosed. Plans 5 hires in AI engineering and consulting, stronger predictive/automation features and commercial expansion. Reports €1.2M annual revenue and 150+ industrial clients served; targets €5M revenue by 2030 and a tenfold increase in Iteraa customers. Investors: Hand Partners (lead), Bpifrance, Caisse d''Épargne. Source: Scale-Up Corner, Mediavenir.',
  NOW()
FROM organizations o WHERE o.slug='namkin'
  AND NOT EXISTS (SELECT 1 FROM funding_rounds x WHERE x.organization_id=o.id AND x.source_name='funding_deals_november_2026_week7');

WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"inv":"hand-partners","name":"Hand Partners","is_lead":true},
  {"inv":"bpifrance","name":"Bpifrance","is_lead":false},
  {"inv":"caisse-depargne","name":"Caisse d'Épargne","is_lead":false}
]$json$) AS (inv TEXT, name TEXT, is_lead BOOLEAN))
INSERT INTO funding_round_investors (id, funding_round_id, investor_id, is_lead, investor_name, created_at)
SELECT uuid_generate_v4(), fr.id, i.id, s.is_lead, s.name, NOW()
FROM source s
JOIN organizations i ON i.slug=s.inv
JOIN organizations o ON o.slug='namkin'
JOIN funding_rounds fr ON fr.organization_id=o.id AND fr.source_name='funding_deals_november_2026_week7'
WHERE NOT EXISTS (SELECT 1 FROM funding_round_investors x WHERE x.funding_round_id=fr.id AND x.investor_id=i.id);

WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"sec":"artificial-intelligence","p":true},{"sec":"martech","p":false},{"sec":"saas","p":false}
]$json$) AS (sec TEXT, p BOOLEAN))
INSERT INTO organization_sectors (id, organization_id, sector_id, is_primary, created_at)
SELECT uuid_generate_v4(), o.id, sec.id, s.p, NOW()
FROM source s JOIN organizations o ON o.slug='namkin' JOIN sectors sec ON sec.slug=s.sec
ON CONFLICT (organization_id, sector_id) DO NOTHING;

INSERT INTO people (id, full_name, slug, first_name, last_name, legacy_source, created_at)
VALUES (uuid_generate_v4(), 'Nicolas Declercq', 'nicolas-declercq', 'Nicolas', 'Declercq', 'funding_deals_november_2026_week7', NOW())
ON CONFLICT (slug) DO NOTHING;

INSERT INTO organization_people (id, organization_id, person_id, role, is_current, is_founder, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, pp.id, 'Founder', TRUE, TRUE, NOW(), NOW()
FROM organizations o, people pp WHERE o.slug='namkin' AND pp.slug='nicolas-declercq'
ON CONFLICT (organization_id, person_id, role) DO NOTHING;

INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'NAMKIN', '811785088', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug='namkin'
  AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.siren='811785088');

SELECT 'Funding Rounds' AS entity, COUNT(*) AS count FROM funding_rounds WHERE source_name='funding_deals_november_2026_week7'
UNION ALL SELECT 'Investor Links', COUNT(*) FROM funding_round_investors fri JOIN funding_rounds fr ON fr.id=fri.funding_round_id WHERE fr.source_name='funding_deals_november_2026_week7'
UNION ALL SELECT 'Founder Links', COUNT(*) FROM organization_people op JOIN organizations o ON o.id=op.organization_id WHERE o.slug='namkin' AND op.is_founder
UNION ALL SELECT 'Sectors', COUNT(*) FROM organization_sectors os JOIN organizations o ON o.id=os.organization_id WHERE o.slug='namkin'
UNION ALL SELECT 'Legal Entities', COUNT(*) FROM legal_entities WHERE siren='811785088';
