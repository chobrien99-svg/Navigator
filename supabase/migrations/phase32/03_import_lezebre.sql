-- =============================================================================
-- October 2026 Week-4 batch — leZèbre (deal 11)
-- =============================================================================
-- Added after the initial 10-deal batch: the source list included SIREN
-- 977814847 (registry name LEZEBRE) but no deal card at the time. Same
-- source_name 'funding_deals_october_2026_week4'.
--
-- New org; HQ Antony (existing city). Investors PRO BTP and Swiss Life France
-- already exist. Seed round, amount undisclosed (amount_eur NULL).
-- =============================================================================

-- Org
INSERT INTO organizations (id, name, slug, organization_type, description, website, status, country, legacy_source, created_at, updated_at)
VALUES (uuid_generate_v4(), 'leZèbre', 'lezebre', 'startup'::organization_type,
  'Develops an integrated insurance and technology platform for employee health insurance, income protection, and retirement benefits. It combines wholesale insurance brokerage, digital policy administration, and HR analytics software for accountants and businesses.',
  'https://lezebre.io', 'active'::organization_status, 'France', 'funding_deals_october_2026_week4', NOW(), NOW())
ON CONFLICT (slug) DO UPDATE SET website=COALESCE(organizations.website, EXCLUDED.website), description=COALESCE(organizations.description, EXCLUDED.description), updated_at=NOW();

-- City link (Antony)
UPDATE organizations o SET city_id=COALESCE(o.city_id, c.id), updated_at=NOW()
FROM cities c WHERE c.slug='antony' AND o.slug='lezebre';

-- Funding round (seed, undisclosed)
INSERT INTO funding_rounds (id, organization_id, stage, amount_eur, currency_original, amount_original, announced_date, is_estimated, is_verified, source_name, notes, created_at)
SELECT uuid_generate_v4(), o.id, 'seed'::funding_stage, NULL, NULL, NULL, '2026-10-06'::DATE, FALSE, FALSE, 'funding_deals_october_2026_week4',
  'First seed financing (amount undisclosed), bringing insurance groups PRO BTP and Swiss Life France into the capital. Plans three interconnected businesses: RH BI (payroll/workforce data to HR analytics), digital insurance subscription/administration software, and wholesale employee-benefits brokerage. Funds product development, new insurance offerings and employer/employee services; a WhatsApp-based insurance management interface is planned for 2027. Investors: PRO BTP, Swiss Life France. Source: Le Zèbre, Digital & Assurance.',
  NOW()
FROM organizations o WHERE o.slug='lezebre';

-- Investor orgs (idempotent; both already exist)
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"name":"PRO BTP"},{"name":"Swiss Life France"}
]$json$) AS (name TEXT))
INSERT INTO organizations (id, name, slug, organization_type, status, country, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), s.name, lower(regexp_replace(regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g')), 'investor'::organization_type, 'active'::organization_status, 'France', 'funding_deals_october_2026_week4', NOW(), NOW()
FROM source s ON CONFLICT (slug) DO NOTHING;

-- Investor links
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"investor_name":"PRO BTP"},{"investor_name":"Swiss Life France"}
]$json$) AS (investor_name TEXT))
INSERT INTO funding_round_investors (id, funding_round_id, investor_id, is_lead, investor_name, created_at)
SELECT uuid_generate_v4(), fr.id, inv.id, FALSE, s.investor_name, NOW()
FROM source s
JOIN organizations o ON o.slug='lezebre'
JOIN organizations inv ON inv.slug=lower(regexp_replace(regexp_replace(unaccent(s.investor_name), '[^a-zA-Z0-9\s-]', '', 'g'), '\s+', '-', 'g'))
JOIN funding_rounds fr ON fr.organization_id=o.id AND fr.source_name='funding_deals_october_2026_week4'
WHERE NOT EXISTS (SELECT 1 FROM funding_round_investors x WHERE x.funding_round_id=fr.id AND x.investor_id=inv.id);

-- Sectors (InsurTech primary, SaaS)
WITH source AS (SELECT * FROM json_populate_recordset(NULL::record, $json$[
  {"sec":"insurtech"},{"sec":"saas"}
]$json$) AS (sec TEXT))
INSERT INTO organization_sectors (id, organization_id, sector_id, is_primary, created_at)
SELECT uuid_generate_v4(), o.id, sec.id, FALSE, NOW()
FROM source s JOIN organizations o ON o.slug='lezebre' JOIN sectors sec ON sec.slug=s.sec
ON CONFLICT (organization_id, sector_id) DO NOTHING;

UPDATE organization_sectors os SET is_primary=TRUE
FROM organizations o JOIN sectors sec ON sec.slug='insurtech'
WHERE os.organization_id=o.id AND os.sector_id=sec.id AND o.slug='lezebre'
  AND NOT EXISTS (SELECT 1 FROM organization_sectors x WHERE x.organization_id=o.id AND x.is_primary=TRUE);

-- Founder
INSERT INTO people (id, full_name, slug, first_name, last_name, legacy_source, created_at)
VALUES (uuid_generate_v4(), 'Nicolas Ciornei', 'nicolas-ciornei', 'Nicolas', 'Ciornei', 'funding_deals_october_2026_week4', NOW())
ON CONFLICT (slug) DO NOTHING;

INSERT INTO organization_people (id, organization_id, person_id, role, is_current, is_founder, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, p.id, 'Founder', TRUE, TRUE, NOW(), NOW()
FROM organizations o JOIN people p ON p.slug='nicolas-ciornei'
WHERE o.slug='lezebre'
ON CONFLICT (organization_id, person_id, role) DO NOTHING;

-- Legal entity (SIREN 977814847, registry name LEZEBRE)
INSERT INTO legal_entities (id, organization_id, legal_name, siren, country, is_primary, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'LEZEBRE', '977814847', 'France', TRUE, NOW(), NOW()
FROM organizations o WHERE o.slug='lezebre'
  AND NOT EXISTS (SELECT 1 FROM legal_entities le WHERE le.organization_id=o.id AND le.siren='977814847');

-- Verification
SELECT o.name, o.slug, fr.stage, fr.amount_eur, fr.announced_date,
  (SELECT count(*) FROM funding_round_investors i WHERE i.funding_round_id=fr.id) AS investors,
  (SELECT count(*) FROM organization_people op WHERE op.organization_id=o.id) AS founders,
  (SELECT count(*) FROM organization_sectors os WHERE os.organization_id=o.id) AS sectors,
  (SELECT le.siren||' '||le.legal_name FROM legal_entities le WHERE le.organization_id=o.id) AS legal_entity
FROM organizations o JOIN funding_rounds fr ON fr.organization_id=o.id AND fr.source_name='funding_deals_october_2026_week4'
WHERE o.slug='lezebre';
