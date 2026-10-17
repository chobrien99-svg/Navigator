-- Phase 25: Merge duplicate organization records
--
-- Cleans up three flagged duplicate/split organization records by re-pointing
-- the child records worth keeping onto the canonical "survivor" org, then
-- deleting the duplicate org (ON DELETE CASCADE removes the remaining child
-- rows, which are all duplicates already present on the survivor).
--
--   Pair 1: ALT-G PROTEIN (dup)      -> Edonia          (survivor)
--           dup = 655f3804-0df1-42a0-8fc4-807fa4d2f109
--           surv= fe354a18-b4a4-4ef9-be1e-a047d49c15f7
--           Edonia is the current brand; ALT-G PROTEIN is the former name.
--           Move the real legal entity (SIREN 949848907 — Edonia had none)
--           and the "Grand Prix" program edition. The single remaining
--           founder row on the dup is already on Edonia (cascade-removed).
--
--   Pair 2: ARCHEON (dup)            -> ARCHEON MEDICAL  (survivor)
--           dup = 21ad5069-96b3-4369-aeb4-7074f586ff51
--           surv= 30f6ea1a-4a69-4252-b5d4-c06a66634469
--           Both hold SIREN 835009465. Move the two funding rounds only;
--           the dup's legal entity / person / sector / two program rows all
--           duplicate rows already on the survivor (cascade-removed).
--
--   Pair 3: NGTV Experience (dup)    -> Spash            (survivor)
--           dup = 9bd9edd9-05a6-41a2-9a38-de6b7dd6fff0
--           surv= da4e1772-60b0-470f-b8b3-15bddad4fbfc
--           Spash already carries the NGTV legal entity (SIREN 821548468).
--           Move the one legacy 2021 funding round; dup is otherwise empty.
--
-- Idempotent: the re-point UPDATEs match nothing once applied; the DELETEs
-- are guarded by id and are no-ops once the dup rows are gone.
--
-- NOTE: the DELETE statements at the bottom were run manually in the Supabase
-- SQL editor because DELETE statements time out over the MCP connection.

BEGIN;

-- ---------------------------------------------------------------------------
-- Re-point child records onto the survivors (non-destructive)
-- ---------------------------------------------------------------------------

-- PAIR 1: ALT-G PROTEIN -> Edonia
UPDATE legal_entities
   SET organization_id = 'fe354a18-b4a4-4ef9-be1e-a047d49c15f7'
 WHERE organization_id = '655f3804-0df1-42a0-8fc4-807fa4d2f109'
   AND NOT EXISTS (
     SELECT 1 FROM legal_entities le2
      WHERE le2.organization_id = 'fe354a18-b4a4-4ef9-be1e-a047d49c15f7'
        AND le2.siren = legal_entities.siren);

UPDATE program_organizations
   SET organization_id = 'fe354a18-b4a4-4ef9-be1e-a047d49c15f7'
 WHERE organization_id = '655f3804-0df1-42a0-8fc4-807fa4d2f109'
   AND NOT EXISTS (
     SELECT 1 FROM program_organizations p2
      WHERE p2.organization_id = 'fe354a18-b4a4-4ef9-be1e-a047d49c15f7'
        AND p2.program_edition_id = program_organizations.program_edition_id);

-- PAIR 2: ARCHEON -> ARCHEON MEDICAL
UPDATE funding_rounds
   SET organization_id = '30f6ea1a-4a69-4252-b5d4-c06a66634469'
 WHERE organization_id = '21ad5069-96b3-4369-aeb4-7074f586ff51';

-- PAIR 3: NGTV Experience -> Spash
UPDATE funding_rounds
   SET organization_id = 'da4e1772-60b0-470f-b8b3-15bddad4fbfc'
 WHERE organization_id = '9bd9edd9-05a6-41a2-9a38-de6b7dd6fff0';

COMMIT;

-- ---------------------------------------------------------------------------
-- Delete the duplicate organization rows (ON DELETE CASCADE cleans leftovers).
-- Run these in the Supabase SQL editor (DELETE times out over MCP).
-- ---------------------------------------------------------------------------

DELETE FROM organizations WHERE id = '655f3804-0df1-42a0-8fc4-807fa4d2f109'; -- ALT-G PROTEIN
DELETE FROM organizations WHERE id = '21ad5069-96b3-4369-aeb4-7074f586ff51'; -- ARCHEON
DELETE FROM organizations WHERE id = '9bd9edd9-05a6-41a2-9a38-de6b7dd6fff0'; -- NGTV Experience
