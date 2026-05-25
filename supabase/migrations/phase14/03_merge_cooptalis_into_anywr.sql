-- =============================================================================
-- Merge Cooptalis → Anywr
-- =============================================================================
-- Anywr is the renamed Cooptalis. Cooptalis (SIREN 753670306) raised in 2022
-- and rebranded to Anywr, which registered a new SIREN (832985048). The two
-- entered the DB as separate organizations, splitting one company's history:
--
--   Cooptalis  → French Tech Next 40/120 · FT 120 · 2020, 2021, 2022
--   Anywr      → French Tech Next 40/120 · FT 120 · 2023, 2024  (+ 2022 round)
--
-- Folding Cooptalis into Anywr makes it a continuous FT 120 member 2020–2024
-- (instead of a phantom 2022 exit + 2023 re-entry) and keeps both SIRENs as
-- legal entities under the surviving org.
--
-- Keep the current name (anywr) and fold Cooptalis's history into it, then
-- delete the Cooptalis org. Uses the merge_organizations() helper from
-- phase12/04_merge_duplicate_orgs.sql.
--
-- Idempotent: no-op if 'cooptalis' has already been merged/removed.
-- =============================================================================

SELECT merge_organizations('cooptalis', 'anywr') AS result;

-- After the merge Anywr holds two legal entities (832985048 from Anywr,
-- 753670306 from Cooptalis), both flagged primary. Keep the current Anywr
-- registration as the single primary and mark the legacy Cooptalis SIREN
-- as historical.
UPDATE legal_entities
   SET is_primary = FALSE,
       updated_at = NOW()
 WHERE siren = '753670306'
   AND organization_id = (SELECT id FROM organizations WHERE slug = 'anywr');
