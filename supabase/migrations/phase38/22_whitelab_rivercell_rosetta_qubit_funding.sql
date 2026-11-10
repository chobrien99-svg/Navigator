-- =============================================================================
-- Funding histories: WhiteLab Genomics, Rivercell, Rosetta Omics, Qubit
-- =============================================================================
-- legacy_source 'techbio_funding_tables_november_2026'. Editor-supplied (FTJ)
-- funding tables, 10 Nov 2026. The unlabelled table is WhiteLab Genomics
-- (matches its Y Combinator 2022, Omnes/Debiopharm Sept 2022 and Oct 2026
-- $26M rounds).
-- WHITELAB GENOMICS
--   Sep 2019 EIT Health support €50k (grant); Feb 2020 angel round €150k
--   (pre-seed); Mar 2020 WILCO €150k (debt); Mar 2020 Bpifrance grant €50k;
--   Sep 2020 Bpifrance €300k convertible (stage 'other', not counted as equity);
--   Jan 2022 EIT Health support (amount n/a).
--   Mar 2022 Y Combinator: kept at €0.47M (= YC's 2022 standard $500k:
--   $125k + $375k MFN SAFE); the table shows only the $125k part.
--   Sep 2022: stage seed -> Series A; $10M (≈ €10.0M at the Sept 2022 rate),
--   was €9.5M. Investors Omnes Capital and Debiopharm unchanged (Y Combinator
--   left in place).
--   Oct 2026 Series B $26M: already recorded.
-- RIVERCELL: Oct 2026 seed = €22.7M (was €21.5M estimated from $25M);
--   Bpifrance link -> Bpifrance Digital Venture.
-- ROSETTA OMICS: Agoranov support programme from Jan 2024 (incubated_by).
-- QUBIT: Quantonation pre-seed, mid-2020, amount undisclosed (Quantonation:
--   "provided the pre-seed funding in mid-2020").
-- =============================================================================
BEGIN;
-- WhiteLab rounds
INSERT INTO funding_rounds (id, organization_id, stage, amount_eur, currency_original, amount_original, announced_date, is_estimated, source_name, notes, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, s.st::funding_stage, s.eur, 'EUR', s.orig, s.d::date, FALSE, 'Editor-supplied funding table (FTJ)', s.note, 'techbio_funding_tables_november_2026', NOW(), NOW()
FROM organizations o, (VALUES
 ('pre_seed',0.15,150000,'2020-02-01','Angel round, €150k (month and year only).'),
 ('debt',0.15,150000,'2020-03-01','WILCO accelerator loan, €150k (month and year only).'),
 ('other',0.30,300000,'2020-09-01','Bpifrance convertible, €300k (month and year only). Not counted as equity.')) s(st,eur,orig,d,note)
WHERE o.slug='whitelab-genomics'
  AND NOT EXISTS (SELECT 1 FROM funding_rounds x WHERE x.organization_id=o.id AND x.announced_date=s.d::date AND x.stage=s.st::funding_stage);
INSERT INTO funding_round_investors (id, funding_round_id, investor_id, is_lead, investor_name, created_at)
SELECT uuid_generate_v4(), fr.id, i.id, TRUE, i.name, NOW()
FROM funding_rounds fr JOIN organizations o ON o.id=fr.organization_id AND o.slug='whitelab-genomics'
JOIN (VALUES ('2020-02-01','pre_seed','business-angels'),('2020-03-01','debt','wilco'),('2020-09-01','other','bpifrance')) s(d,st,inv) ON fr.announced_date=s.d::date AND fr.stage=s.st::funding_stage
JOIN organizations i ON i.slug=s.inv
WHERE NOT EXISTS (SELECT 1 FROM funding_round_investors x WHERE x.funding_round_id=fr.id AND x.investor_id=i.id);
UPDATE funding_rounds fr SET stage='series_a', amount_eur=10.0, currency_original='USD', amount_original=10000000, is_estimated=FALSE,
  notes=coalesce(fr.notes||' ','')||'Series A of $10M (editor-supplied table); previously recorded as a €9.5M seed.', updated_at=NOW()
FROM organizations o WHERE fr.organization_id=o.id AND o.slug='whitelab-genomics' AND fr.announced_date='2022-09-12' AND fr.stage='seed';
UPDATE funding_rounds fr SET notes=coalesce(fr.notes||' ','')||'Y Combinator standard 2022 deal: $125k for equity plus a $375k uncapped MFN SAFE ($500k in all).', updated_at=NOW()
FROM organizations o WHERE fr.organization_id=o.id AND o.slug='whitelab-genomics' AND fr.announced_date='2022-03-29' AND coalesce(fr.notes,'') NOT LIKE '%MFN SAFE%';
INSERT INTO grants (id, organization_id, grant_name, granting_body, amount_eur, awarded_date, program, description, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, s.n, s.b, s.a, s.d::date, s.p, s.descr, NOW(), NOW()
FROM organizations o, (VALUES
 ('EIT Health support programme (2019)','EIT Health',50000,'2019-09-01','EIT Health','Support programme, €50k (editor-supplied; month and year only).'),
 ('Bpifrance grant (2020)','Bpifrance',50000,'2020-03-01','Bpifrance','Grant, €50k (editor-supplied; month and year only).'),
 ('EIT Health support programme (2022)','EIT Health',NULL,'2022-01-01','EIT Health','Support programme, amount not disclosed (editor-supplied; month and year only).')) s(n,b,a,d,p,descr)
WHERE o.slug='whitelab-genomics' AND NOT EXISTS (SELECT 1 FROM grants g WHERE g.organization_id=o.id AND g.grant_name=s.n);

-- Rivercell
UPDATE funding_rounds fr SET amount_eur=22.7, is_estimated=FALSE, currency_original='EUR', amount_original=22700000,
  notes=coalesce(fr.notes||' ','')||'€22.7M per editor-supplied table (announced as $25M).', updated_at=NOW()
FROM organizations o WHERE fr.organization_id=o.id AND o.slug='rivercell' AND fr.announced_date='2026-10-07' AND fr.stage='seed';
UPDATE funding_round_investors fri SET investor_id=(SELECT id FROM organizations WHERE slug='bpifrance-digital-venture'), investor_name='Bpifrance Digital Venture'
FROM funding_rounds fr, organizations o, organizations i
WHERE fri.funding_round_id=fr.id AND fr.organization_id=o.id AND fri.investor_id=i.id AND o.slug='rivercell' AND fr.announced_date='2026-10-07' AND i.slug='bpifrance';

-- Rosetta Omics
INSERT INTO organization_relationships (id, source_org_id, target_org_id, relationship_type, description, start_date, source_type, source_name, verification_status, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), a.id, b.id, 'incubated_by'::relationship_type, 'Agoranov support programme from January 2024.', '2024-01-01', 'editor', 'Editor-supplied funding table (FTJ)', 'medium', 'techbio_funding_tables_november_2026', NOW(), NOW()
FROM organizations a JOIN organizations b ON b.slug='agoranov' WHERE a.slug='rosetta-omics'
  AND NOT EXISTS (SELECT 1 FROM organization_relationships x WHERE x.source_org_id=a.id AND x.target_org_id=b.id AND x.relationship_type='incubated_by');

-- Qubit: Quantonation pre-seed
INSERT INTO funding_rounds (id, organization_id, stage, amount_eur, announced_date, is_estimated, source_name, source_url, notes, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'pre_seed', NULL, '2020-06-01', FALSE, 'Quantonation', 'https://www.quantonation.com/?p=7570', 'Pre-seed from Quantonation, mid-2020; amount not disclosed; date approximate.', 'techbio_funding_tables_november_2026', NOW(), NOW()
FROM organizations o WHERE o.slug='qubit-pharmaceuticals'
  AND NOT EXISTS (SELECT 1 FROM funding_rounds x WHERE x.organization_id=o.id AND x.stage='pre_seed');
INSERT INTO funding_round_investors (id, funding_round_id, investor_id, is_lead, investor_name, created_at)
SELECT uuid_generate_v4(), fr.id, i.id, TRUE, i.name, NOW()
FROM funding_rounds fr JOIN organizations o ON o.id=fr.organization_id AND o.slug='qubit-pharmaceuticals' JOIN organizations i ON i.slug='quantonation'
WHERE fr.stage='pre_seed' AND NOT EXISTS (SELECT 1 FROM funding_round_investors x WHERE x.funding_round_id=fr.id AND x.investor_id=i.id);
COMMIT;

SELECT o.slug, fr.announced_date::text d, fr.stage::text s, fr.amount_eur::text a, (SELECT string_agg(i.slug,', ') FROM funding_round_investors x JOIN organizations i ON i.id=x.investor_id WHERE x.funding_round_id=fr.id) inv
FROM funding_rounds fr JOIN organizations o ON o.id=fr.organization_id WHERE o.slug IN ('whitelab-genomics','rivercell','qubit-pharmaceuticals') ORDER BY 1,2;

-- Addendum (10 Nov 2026, editor): Y Combinator did not take part in WhiteLab's
-- September 2022 Series A; removed from that round.
DELETE FROM funding_round_investors fri USING funding_rounds fr, organizations o, organizations i
WHERE fri.funding_round_id=fr.id AND fr.organization_id=o.id AND fri.investor_id=i.id
  AND o.slug='whitelab-genomics' AND fr.announced_date='2022-09-12' AND i.slug='y-combinator';
