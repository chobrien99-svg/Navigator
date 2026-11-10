-- =============================================================================
-- Iktos funding history (editor-supplied, 10 Nov 2026)
-- =============================================================================
-- legacy_source 'iktos_funding_november_2026'. Source: funding timeline supplied
-- by the editor (FTJ). Changes:
--   * Jun 2017 seed: amount stored as €0 -> NULL (undisclosed).
--   * Oct 2017: HEC Challenge+ (HEC Paris incubator programme), new programme.
--   * Feb 2018: incubated by Agoranov (relationship).
--   * Jan 2019 seed: already recorded, undisclosed.
--   * Jan 2021: €0.9M Bpifrance loan (stage 'debt'; not equity).
--   * Mar 2023 Series A: €15.16M (converted) -> €15.5M; investors Omnes
--     Capital, Debiopharm (lead), M Ventures unchanged.
--   * Oct 2024: EIC Accelerator grant AIR-3D (€2.5M, already loaded from
--     CORDIS in file 17) gets its award date. The supplied list shows "$2.5m";
--     EIC grants are in euros (CORDIS: €2,499,616).
-- =============================================================================
BEGIN;
UPDATE funding_rounds fr SET amount_eur=NULL, notes=coalesce(fr.notes||' ','')||'Amount undisclosed.', updated_at=NOW()
FROM organizations o WHERE fr.organization_id=o.id AND o.slug='iktos' AND fr.announced_date='2017-06-01' AND fr.amount_eur=0;

UPDATE funding_rounds fr SET amount_eur=15.5, is_estimated=FALSE, notes=coalesce(fr.notes||' ','')||'Amount €15.5M per editor-supplied funding list (previously €15.16M converted).', updated_at=NOW()
FROM organizations o WHERE fr.organization_id=o.id AND o.slug='iktos' AND fr.announced_date='2023-03-09' AND fr.stage='series_a';

INSERT INTO funding_rounds (id, organization_id, stage, amount_eur, currency_original, amount_original, announced_date, is_estimated, source_name, notes, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), o.id, 'debt'::funding_stage, 0.9, 'EUR', 900000, '2021-01-01', FALSE, 'Editor-supplied funding list (FTJ)', 'Bpifrance loan of €900k (month and year only).', 'iktos_funding_november_2026', NOW(), NOW()
FROM organizations o WHERE o.slug='iktos'
  AND NOT EXISTS (SELECT 1 FROM funding_rounds x WHERE x.organization_id=o.id AND x.stage='debt' AND x.announced_date='2021-01-01');

INSERT INTO funding_round_investors (id, funding_round_id, investor_id, is_lead, created_at)
SELECT uuid_generate_v4(), fr.id, b.id, TRUE, NOW()
FROM funding_rounds fr JOIN organizations o ON o.id=fr.organization_id AND o.slug='iktos' JOIN organizations b ON b.slug='bpifrance'
WHERE fr.stage='debt' AND fr.announced_date='2021-01-01'
  AND NOT EXISTS (SELECT 1 FROM funding_round_investors x WHERE x.funding_round_id=fr.id AND x.investor_id=b.id);

INSERT INTO programs (id, name, slug, program_type, description, country, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), 'HEC Challenge+', 'hec-challenge-plus', 'incubator', 'Start-up support programme of HEC Paris (later part of Incubateur HEC Paris).', 'France', 'iktos_funding_november_2026', NOW(), NOW()
WHERE NOT EXISTS (SELECT 1 FROM programs WHERE slug='hec-challenge-plus');
INSERT INTO program_editions (id, program_id, name, slug, year, cohort_label, created_at, updated_at)
SELECT uuid_generate_v4(), p.id, 'HEC Challenge+ — 2017', 'hec-challenge-plus-2017', 2017, 'October 2017', NOW(), NOW()
FROM programs p WHERE p.slug='hec-challenge-plus' AND NOT EXISTS (SELECT 1 FROM program_editions WHERE slug='hec-challenge-plus-2017');
INSERT INTO program_organizations (id, program_edition_id, organization_id, membership_role, notes, verification_status, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), pe.id, o.id, 'Participant', 'Support programme, October 2017 (editor-supplied).', 'medium', 'iktos_funding_november_2026', NOW(), NOW()
FROM program_editions pe JOIN organizations o ON o.slug='iktos' WHERE pe.slug='hec-challenge-plus-2017'
ON CONFLICT (program_edition_id, organization_id) DO NOTHING;

INSERT INTO organization_relationships (id, source_org_id, target_org_id, relationship_type, description, start_date, source_type, source_name, verification_status, legacy_source, created_at, updated_at)
SELECT uuid_generate_v4(), a.id, b.id, 'incubated_by'::relationship_type, 'Incubated at Agoranov from February 2018.', '2018-02-01', 'editor', 'Editor-supplied funding list (FTJ)', 'medium', 'iktos_funding_november_2026', NOW(), NOW()
FROM organizations a JOIN organizations b ON b.slug='agoranov' WHERE a.slug='iktos'
  AND NOT EXISTS (SELECT 1 FROM organization_relationships x WHERE x.source_org_id=a.id AND x.target_org_id=b.id AND x.relationship_type='incubated_by');

UPDATE grants g SET awarded_date='2024-10-01', updated_at=NOW()
FROM organizations o WHERE g.organization_id=o.id AND o.slug='iktos' AND g.grant_name='Horizon Europe – AIR-3D (EIC Accelerator)';
COMMIT;

SELECT fr.announced_date, fr.stage, fr.amount_eur, (SELECT string_agg(i.name,', ') FROM funding_round_investors x JOIN organizations i ON i.id=x.investor_id WHERE x.funding_round_id=fr.id) inv
FROM funding_rounds fr JOIN organizations o ON o.id=fr.organization_id WHERE o.slug='iktos' ORDER BY 1;
