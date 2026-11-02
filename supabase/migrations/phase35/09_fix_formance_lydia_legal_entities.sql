-- =====================================================================
-- Phase 35 - Fix: correct legal entities for Formance and Lydia.
--
-- Both orgs had only wrong entities attached (name collisions / junk).
-- The real entities were verified against recherche-entreprises.api.gouv.fr
-- (2026-11-02):
--
--   Formance -> GOLDILOCKS (898531371), SAS, Paris, inc. 2021-04-20,
--               NAF 58.29A - holds the Formance trademark (founder
--               Clément Salaün).
--   Lydia    -> LYDIA SOLUTIONS (534479589), SAS, Paris, inc. 2011-08-31,
--               NAF 62.01Z - dirigeant Cyril Chiche.
--
-- Each org's primary row is repointed to the correct entity; the one
-- leftover wrong row per org is deleted:
--   formance: delete 235581006 (invalid SIREN)
--   lydia:    delete 884748898 (real-estate SCI)
-- (formance's 409983756 training association and lydia's 753222520
--  food-retail SARL were the primary rows, now overwritten in place.)
--
-- Idempotent: updates/deletes target fixed row ids.
-- =====================================================================

BEGIN;

UPDATE legal_entities SET
  legal_name='GOLDILOCKS', siren='898531371', siret='89853137100018', naf_code='58.29A',
  incorporation_date='2021-04-20', registered_city='PARIS', legal_form='SAS',
  verification_status='verified', updated_at=NOW()
WHERE id='60c97bf7-791b-4b51-9dff-c52460235526';

UPDATE legal_entities SET
  legal_name='LYDIA SOLUTIONS', siren='534479589', siret='53447958900051', naf_code='62.01Z',
  incorporation_date='2011-08-31', registered_city='PARIS', legal_form='SAS',
  verification_status='verified', updated_at=NOW()
WHERE id='536c4264-7143-44bc-a47c-11492ce01c0e';

DELETE FROM legal_entities
WHERE id IN (
  '0b0f5281-6826-4a68-98ba-f15cd48b9f3f',  -- formance 235581006 (invalid)
  '90fc7599-77d8-4ce5-afbc-6a759b49d5f1'   -- lydia    884748898 (SCI)
);

COMMIT;
