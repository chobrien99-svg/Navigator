-- =============================================================================
-- Merge duplicate 'Diagnostic Medical In Vivo (DMIV)' into 'Dyameo'
-- =============================================================================
-- Two records describe the same company (both website dyameo.com):
--   survivor  'dyameo'                           (55814aa6-86c4-4164-aedf-d2f50f0c204b)
--             brand org, has funding rounds, sectors, city (Limoges)
--   duplicate 'diagnostic-medical-in-vivo-dmiv'  (b4ce194a-2b4e-4f19-8311-8fcd6ca11fbe)
--             legacy 'ilab', former name; holds the SIREN, 1 founder, 1 program
--
-- The company's legal entity (SIREN 828605386) is registered under the name
-- DYAMEO (confirmed against recherche-entreprises.api.gouv.fr); DMIV is its
-- former name. Re-point DMIV's children to 'dyameo', then delete the duplicate.
--
-- Non-destructive re-points (Steps 1-3) are applied via MCP. The final DELETE
-- (Step 4) is run by the user in the Supabase SQL editor (DELETEs time out over
-- MCP). Run order: after 01_import_october_2026_week4_funding_deals.sql, so the
-- founder link guard sees Dyameo's newly-imported founders.
-- =============================================================================

-- Step 1: legal entity — move the SIREN to Dyameo, normalise the name to the
-- registry value, and make it Dyameo's primary (Dyameo had no legal entity).
UPDATE legal_entities le
SET organization_id='55814aa6-86c4-4164-aedf-d2f50f0c204b',
    legal_name='DYAMEO',
    is_primary=TRUE,
    updated_at=NOW()
WHERE le.organization_id='b4ce194a-2b4e-4f19-8311-8fcd6ca11fbe'
  AND NOT EXISTS (SELECT 1 FROM legal_entities x
                  WHERE x.organization_id='55814aa6-86c4-4164-aedf-d2f50f0c204b' AND x.siren=le.siren);

-- Step 2: founder link — re-point only if Dyameo doesn't already link that
-- person (the import adds Cédric Enguehard to Dyameo with role 'Founder').
UPDATE organization_people op
SET organization_id='55814aa6-86c4-4164-aedf-d2f50f0c204b', is_founder=TRUE, updated_at=NOW()
WHERE op.organization_id='b4ce194a-2b4e-4f19-8311-8fcd6ca11fbe'
  AND NOT EXISTS (SELECT 1 FROM organization_people x
                  WHERE x.organization_id='55814aa6-86c4-4164-aedf-d2f50f0c204b' AND x.person_id=op.person_id);

-- Step 3: program link — re-point unless Dyameo already has that edition.
UPDATE program_organizations po
SET organization_id='55814aa6-86c4-4164-aedf-d2f50f0c204b'
WHERE po.organization_id='b4ce194a-2b4e-4f19-8311-8fcd6ca11fbe'
  AND NOT EXISTS (SELECT 1 FROM program_organizations x
                  WHERE x.organization_id='55814aa6-86c4-4164-aedf-d2f50f0c204b' AND x.program_edition_id=po.program_edition_id);

-- Step 4: delete the duplicate (run in the Supabase SQL editor). CASCADE clears
-- any residual child rows left unmoved by the guards above.
-- DELETE FROM organizations WHERE id='b4ce194a-2b4e-4f19-8311-8fcd6ca11fbe';
