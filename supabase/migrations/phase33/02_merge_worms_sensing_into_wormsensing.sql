-- =============================================================================
-- Merge duplicate 'WORMS Sensing' into 'WORMSENSING'
-- =============================================================================
-- Two records describe the same company (both website wormsensing.com):
--   survivor  'wormsensing'   (48b5282e-316a-4c85-a138-0bb3f59c2ce9)
--             legacy 'funding_deals_2022_crunchbase'; 2022 seed, 7 sectors, city,
--             and the new Nov-2026 Series A attached in 01_import.
--   duplicate 'worms-sensing' (324f9d1c-04ba-4ff4-bad9-d8590129698c)
--             legacy 'ilab'; holds SIREN 880418033, 1 founder, 1 program.
--
-- Registry name for SIREN 880418033 is WORMSENSING. Re-point the duplicate's
-- children to 'wormsensing', then delete the shell. Non-destructive re-points
-- (Steps 1-3) are applied via MCP; the final DELETE (Step 4) is run by the user
-- in the Supabase SQL editor. Run after 01_import (so the founder guard sees
-- any founders added there).
-- =============================================================================

-- Step 1: legal entity — move the SIREN, normalise the name, make it primary.
UPDATE legal_entities le
SET organization_id='48b5282e-316a-4c85-a138-0bb3f59c2ce9', legal_name='WORMSENSING', is_primary=TRUE, updated_at=NOW()
WHERE le.organization_id='324f9d1c-04ba-4ff4-bad9-d8590129698c'
  AND NOT EXISTS (SELECT 1 FROM legal_entities x WHERE x.organization_id='48b5282e-316a-4c85-a138-0bb3f59c2ce9' AND x.siren=le.siren);

-- Step 2: founder link — re-point unless the survivor already links that person.
UPDATE organization_people op
SET organization_id='48b5282e-316a-4c85-a138-0bb3f59c2ce9', is_founder=TRUE, updated_at=NOW()
WHERE op.organization_id='324f9d1c-04ba-4ff4-bad9-d8590129698c'
  AND NOT EXISTS (SELECT 1 FROM organization_people x WHERE x.organization_id='48b5282e-316a-4c85-a138-0bb3f59c2ce9' AND x.person_id=op.person_id);

-- Step 3: program link — re-point unless the survivor already has that edition.
UPDATE program_organizations po
SET organization_id='48b5282e-316a-4c85-a138-0bb3f59c2ce9'
WHERE po.organization_id='324f9d1c-04ba-4ff4-bad9-d8590129698c'
  AND NOT EXISTS (SELECT 1 FROM program_organizations x WHERE x.organization_id='48b5282e-316a-4c85-a138-0bb3f59c2ce9' AND x.program_edition_id=po.program_edition_id);

-- Step 4: delete the duplicate (run in the Supabase SQL editor; CASCADE clears
-- any residual child rows left unmoved by the guards above).
-- DELETE FROM organizations WHERE id='324f9d1c-04ba-4ff4-bad9-d8590129698c';
