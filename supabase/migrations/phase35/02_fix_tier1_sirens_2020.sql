-- =====================================================================
-- Phase 35 - Fix: correct wrong SIRENs on three 2020-import companies.
--
-- These three legal_entities rows carried a SIREN belonging to an
-- unrelated, recently-registered company (incorporated years after the
-- 2020 funding round - logically impossible; see the tier-1 rows in
-- data/siren_date_anomalies.csv). Each corrected SIREN was confirmed
-- against recherche-entreprises.api.gouv.fr (queried 2026-11-02):
--
--   Castalie   132192295 -> 532029600  CASTALIE  (Boulogne-Billancourt, inc. 2011)
--   Bubble BD  106201650 -> 812964203  HEAPPI    (Rouen, inc. 2015; publisher of the Bubble app)
--   Qobra      107596769 -> 885069039  SALESCREW (Ris-Orangis, inc. 2020; per Qobra legal notice / founders)
--
-- Matches on the old (wrong) SIREN, so re-running is a no-op.
-- =====================================================================

BEGIN;

WITH corr(old_siren, new_siren, legal_name, siret, naf, incorp, city, form) AS (VALUES
  ('132192295','532029600','CASTALIE','53202960000048','47.99B','2011-04-11'::date,'BOULOGNE-BILLANCOURT','SAS'),
  ('106201650','812964203','HEAPPI','81296420300028','62.01Z','2015-07-17'::date,'ROUEN','SAS'),
  ('107596769','885069039','SALESCREW','88506903900018','62.01Z','2020-07-08'::date,'RIS-ORANGIS','SAS')
)
UPDATE legal_entities le SET
  siren = c.new_siren,
  legal_name = c.legal_name,
  siret = c.siret,
  naf_code = c.naf,
  incorporation_date = c.incorp,
  registered_city = c.city,
  legal_form = c.form,
  verification_status = 'verified',
  updated_at = NOW()
FROM corr c
WHERE le.siren = c.old_siren;

COMMIT;
