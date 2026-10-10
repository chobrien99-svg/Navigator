-- =============================================================================
-- PHASE 24 - Sanity check on funding_rounds.amount_eur
-- =============================================================================
-- amount_eur is stored in millions of euros (5 = €5M). A round entered in raw
-- euros (5000000) would otherwise be read as €5,000Bn and top the funding page,
-- as happened with Granit's Seed round on 2026-10-08.
--
-- Reject anything at or above €100B (100000 in €M) and negative amounts.
-- The largest legitimate round at the time of writing is €3B (3000).
-- =============================================================================

ALTER TABLE funding_rounds
  ADD CONSTRAINT funding_rounds_amount_eur_sane
  CHECK (amount_eur IS NULL OR (amount_eur >= 0 AND amount_eur < 100000));
