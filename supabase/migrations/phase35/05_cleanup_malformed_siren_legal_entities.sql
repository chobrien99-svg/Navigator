-- =====================================================================
-- Phase 35 - Cleanup: remove malformed / duplicate legal_entities.
--
-- Two orgs carried junk legal-entity rows alongside their correct one:
--
--   Akur8    keep AKUR8 (841204720); remove "12531113" - only 8 digits,
--            no such company exists in the French registry.
--   Ever Dye keep EVER DYE (901979211); remove "90197921" (an 8-digit
--            truncation of that SIREN) and one exact duplicate row of
--            901979211 (same SIREN + SIRET).
--
-- Back Market was reviewed and left untouched: both its entities are
-- real (804049476 = JUNG S.A.S / enseigne BACK MARKET, the operating
-- company; 834103111 = LH BACKMARKET, the holding).
--
-- Idempotent: targets fixed row ids.
-- =====================================================================

BEGIN;

DELETE FROM legal_entities
WHERE id IN (
  'ce2d3ebd-bd2e-4066-b405-c6830ece88cb',  -- Akur8    siren 12531113  (invalid, 8 digits)
  '5759b69e-22a0-4a82-8ec0-895c82813654',  -- Ever Dye siren 90197921  (truncated, 8 digits)
  '534124a3-637b-4d2c-9a86-26b5a32c7bb5'   -- Ever Dye siren 901979211 (duplicate of d509c929)
);

COMMIT;
