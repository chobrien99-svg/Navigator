-- Phase 14 · Sekoia/Sekoia.io merge + i-Nov year correction
--
-- Two duplicate organization records for the same company:
--   /entities/sekoia    (SIREN 828903310) — rich profile, FT Next 40/120 2025
--                                            membership, founder link
--   /entities/sekoiaio  (SIREN 913174744) — the correct/current SIREN, holds
--                                            the 2023 Series A and 2025 Series B
--
-- Fold sekoiaio → sekoia via merge_organizations() so the survivor keeps the
-- rich profile + FT Next 40/120 link and absorbs the funding history. Both
-- 913174744 rows on sekoiaio move over (the source had a true duplicate);
-- post-merge cleanup drops the duplicate, makes 913174744 the sole primary,
-- and demotes the two older SIRENs (828903310 and the original 2008
-- 502067705) to historical non-primary registrations.
--
-- Separately, sekoia was attached to i-Nov 2020 but should be on the 2021
-- edition — repointed below.

BEGIN;

-- 1. Merge: source 'sekoiaio' folds into target 'sekoia'
SELECT merge_organizations('sekoiaio', 'sekoia');

-- 2. Legal-entity cleanup on the survivor:
--    a) drop the duplicate 913174744 row that moved over from sekoiaio
DELETE FROM legal_entities
 WHERE id = '7ee4b630-d7ca-4bc0-b059-ed01824e32d6';

--    b) 913174744 is the sole primary; 828903310 and 502067705 are historical
UPDATE legal_entities
   SET is_primary = TRUE, updated_at = NOW()
 WHERE id = '52bf9ef5-6da0-411e-bddd-f83952891825';

UPDATE legal_entities
   SET is_primary = FALSE, updated_at = NOW()
 WHERE id IN (
   '67ad0030-df3a-4f11-855f-335bb91489b9',  -- 828903310 "Sekoia"
   '7e7884d5-69ba-4507-b5b1-4ba2bd56467c'   -- 502067705 "SEKOIA" (original 2008)
 );

-- 3. Repoint Sekoia's i-Nov membership from the 2020 edition to 2021
UPDATE program_organizations
   SET program_edition_id = '2ebb4932-be1f-4ea6-b459-79115db61e63'  -- i-Nov 2021
 WHERE organization_id    = '4534a56a-1484-42df-bffb-208176f4b226'  -- sekoia
   AND program_edition_id = '5c72344d-4527-459b-aac4-01939ef3651d'; -- i-Nov 2020

COMMIT;
