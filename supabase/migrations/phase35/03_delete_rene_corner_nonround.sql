-- =====================================================================
-- Phase 35 - Delete a non-round: Renée Corner (2020 import).
--
-- The "round" recorded for Renée Corner (org slug rene-corner,
-- SIREN 898272612) on 2020-12-16 had no amount and a single "investor",
-- IMT Starter - a startup incubator, not a funder. Combined with the
-- ShowroomPrivé "Move Forward" accelerator link and no locatable
-- funding announcement, this is accelerator/incubator participation
-- that was mis-recorded as a funding round. Remove it.
--
-- Idempotent: targets a fixed round id; re-running affects nothing.
-- =====================================================================

BEGIN;

DELETE FROM funding_round_investors WHERE funding_round_id = 'ffa75b48-03dd-4717-893c-1b669fc15ee9';
DELETE FROM funding_rounds          WHERE id               = 'ffa75b48-03dd-4717-893c-1b669fc15ee9';

COMMIT;
