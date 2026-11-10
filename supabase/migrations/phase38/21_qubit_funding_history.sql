-- =============================================================================
-- Qubit Pharmaceuticals funding history (editor-supplied table, 10 Nov 2026)
-- =============================================================================
-- legacy_source 'qubit_funding_november_2026'. Changes:
--   * Apr 2020 spin-out: CNRS and Sorbonne Université (spun_out_from); SATT
--     Lutech and CNRS Innovation as technology-transfer partners ('other').
--   * Jun 2020: EIT Health support programme, €40k (grant).
--   * Jun 2021: EIC Fund equity investment €5M (stage 'other': blended finance
--     alongside the 2021 EIC Accelerator grant).
--   * Jun 2021: EIC Accelerator grant ATLAS (€2.5M, loaded from CORDIS in file
--     17) gets its award date. The table shows "$2.5m"; EIC grants are in euros.
--   * Jun 2022 seed: the European Innovation Council was wrongly attached as
--     lead investor; removed. Press coverage (Omnes Capital, Quantonation, The
--     Quantum Insider) names XAnge, Omnes Capital, Quantonation and Octave
--     Klaba and no single lead. Amount kept at €16.1M (press); the table rounds
--     it to €16.0M.
-- =============================================================================
BEGIN;
DELETE FROM funding_round_investors fri USING funding_rounds fr, organizations o, organizations i
WHERE fri.funding_round_id=fr.id AND fr.organization_id=o.id AND fri.investor_id=i.id
  AND o.slug='qubit-pharmaceuticals' AND fr.announced_date='2022-06-10' AND i.slug='european-innovation-council';
UPDATE funding_rounds fr SET notes=coalesce(fr.notes||' ','')||'Investors: XAnge, Omnes Capital, Quantonation, Octave Klaba (no single lead named in press releases).', updated_at=NOW()
FROM organizations o WHERE fr.organization_id=o.id AND o.slug='qubit-pharmaceuticals' AND fr.announced_date='2022-06-10' AND coalesce(fr.notes,'') NOT LIKE '%no single lead%';

INSERT INTO funding_rounds (id, organization_id, stage, amount_eur, currency_original, amount_original, announced_date, is_estimated, source_name, notes, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'other'::funding_stage, 5.0, 'EUR', 5000000, '2021-06-01', FALSE, 'Editor-supplied funding table (FTJ)', 'EIC Fund equity investment (€5M), blended finance alongside the 2021 EIC Accelerator grant. Month and year only.', 'qubit_funding_november_2026', NOW(), NOW()
FROM organizations o WHERE o.slug='qubit-pharmaceuticals'
  AND NOT EXISTS (SELECT 1 FROM funding_rounds x WHERE x.organization_id=o.id AND x.announced_date='2021-06-01' AND x.stage='other');
INSERT INTO funding_round_investors (id, funding_round_id, investor_id, is_lead, investor_name, created_at)
SELECT uuid_generate_v4(), fr.id, i.id, TRUE, i.name, NOW()
FROM funding_rounds fr JOIN organizations o ON o.id=fr.organization_id AND o.slug='qubit-pharmaceuticals' JOIN organizations i ON i.slug='eic-fund'
WHERE fr.announced_date='2021-06-01' AND fr.stage='other'
  AND NOT EXISTS (SELECT 1 FROM funding_round_investors x WHERE x.funding_round_id=fr.id AND x.investor_id=i.id);

UPDATE grants g SET awarded_date='2021-06-01', updated_at=NOW()
FROM organizations o WHERE g.organization_id=o.id AND o.slug='qubit-pharmaceuticals' AND g.grant_name='Horizon Europe – ATLAS (EIC Accelerator)';
INSERT INTO grants (id, organization_id, grant_name, granting_body, amount_eur, awarded_date, program, description, source_url, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'EIT Health support programme (2020)', 'EIT Health', 40000, '2020-06-01', 'EIT Health', 'Support programme, €40k (editor-supplied funding table; month and year only).', NULL, NOW(), NOW()
FROM organizations o WHERE o.slug='qubit-pharmaceuticals'
  AND NOT EXISTS (SELECT 1 FROM grants g WHERE g.organization_id=o.id AND g.grant_name='EIT Health support programme (2020)');

INSERT INTO organization_relationships (id, source_org_id, target_org_id, relationship_type, description, start_date, source_type, source_name, verification_status, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), a.id, b.id, s.t::relationship_type, s.d, '2020-04-01', 'editor', 'Editor-supplied funding table (FTJ)', 'medium', 'qubit_funding_november_2026', NOW(), NOW()
FROM (VALUES ('cnrs','spun_out_from','Spin-out from CNRS research (April 2020).'),
             ('sorbonne-universite','spun_out_from','Spin-out from Sorbonne Université research (April 2020).'),
             ('satt-lutech','other','Technology transfer at spin-out (SATT Lutech, April 2020).'),
             ('cnrs-innovation','other','Technology transfer at spin-out (CNRS Innovation, April 2020).')) s(slug,t,d)
JOIN organizations a ON a.slug='qubit-pharmaceuticals' JOIN organizations b ON b.slug=s.slug
WHERE NOT EXISTS (SELECT 1 FROM organization_relationships x WHERE x.source_org_id=a.id AND x.target_org_id=b.id AND x.relationship_type=s.t::relationship_type);
COMMIT;

SELECT fr.announced_date::text d, fr.stage::text s, fr.amount_eur::text a, (SELECT string_agg(i.name||CASE WHEN x.is_lead THEN '*' ELSE '' END,', ') FROM funding_round_investors x JOIN organizations i ON i.id=x.investor_id WHERE x.funding_round_id=fr.id) inv
FROM funding_rounds fr JOIN organizations o ON o.id=fr.organization_id WHERE o.slug='qubit-pharmaceuticals'
UNION ALL SELECT g.awarded_date::text, 'grant', g.amount_eur::text, g.grant_name FROM grants g JOIN organizations o ON o.id=g.organization_id WHERE o.slug='qubit-pharmaceuticals'
UNION ALL SELECT r.start_date::text, r.relationship_type::text, NULL, b.slug FROM organization_relationships r JOIN organizations a ON a.id=r.source_org_id JOIN organizations b ON b.id=r.target_org_id WHERE a.slug='qubit-pharmaceuticals' AND r.legacy_source='qubit_funding_november_2026';
