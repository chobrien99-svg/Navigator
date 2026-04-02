-- =============================================================================
-- PHASE 4 - IMPORT: Funding Rounds
-- =============================================================================
-- Run in the UNIFIED DATABASE SQL Editor.
-- Same process: export from Funding Tracker, strip wrapper, paste with $$...$$.
--
-- Mapping: company_id → organization_id
-- =============================================================================

WITH source_data AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    '__PASTE_JSON_HERE__'::json
  ) AS (
    id                UUID,
    company_id        UUID,
    round_type        TEXT,
    amount_eur        NUMERIC,
    announced_date    DATE,
    announced_month   TEXT,
    announced_year    INTEGER,
    valuation_eur     NUMERIC,
    news_url          TEXT,
    press_release_url TEXT,
    notes             TEXT,
    is_verified       BOOLEAN,
    source            TEXT,
    created_at        TIMESTAMPTZ,
    updated_at        TIMESTAMPTZ
  )
)
INSERT INTO funding_rounds (
  id,
  organization_id,
  stage,
  amount_eur,
  announced_date,
  valuation_eur,
  source_url,
  press_release_url,
  notes,
  is_verified,
  source_name,
  legacy_source,
  legacy_id,
  created_at,
  updated_at
)
SELECT
  s.id,
  s.company_id,
  CASE
    WHEN lower(s.round_type) = 'pre-seed' OR lower(s.round_type) = 'pre_seed' THEN 'pre_seed'::funding_stage
    WHEN lower(s.round_type) = 'seed' THEN 'seed'::funding_stage
    WHEN lower(s.round_type) IN ('series a', 'series_a') THEN 'series_a'::funding_stage
    WHEN lower(s.round_type) IN ('series b', 'series_b') THEN 'series_b'::funding_stage
    WHEN lower(s.round_type) IN ('series c', 'series_c') THEN 'series_c'::funding_stage
    WHEN lower(s.round_type) IN ('series d', 'series_d') THEN 'series_d'::funding_stage
    WHEN lower(s.round_type) IN ('series e', 'series_e') THEN 'series_e'::funding_stage
    WHEN lower(s.round_type) IN ('series f', 'series_f') THEN 'series_f'::funding_stage
    WHEN lower(s.round_type) = 'growth' THEN 'growth'::funding_stage
    WHEN lower(s.round_type) = 'bridge' THEN 'bridge'::funding_stage
    WHEN lower(s.round_type) = 'debt' THEN 'debt'::funding_stage
    WHEN lower(s.round_type) = 'grant' THEN 'grant'::funding_stage
    WHEN lower(s.round_type) = 'ipo' THEN 'ipo'::funding_stage
    WHEN lower(s.round_type) = 'secondary' THEN 'secondary'::funding_stage
    WHEN lower(s.round_type) = 'undisclosed' THEN 'undisclosed'::funding_stage
    ELSE 'other'::funding_stage
  END,
  s.amount_eur,
  s.announced_date,
  s.valuation_eur,
  s.news_url,
  s.press_release_url,
  s.notes,
  COALESCE(s.is_verified, FALSE),
  s.source,
  'funding_tracker',
  s.id::TEXT,
  COALESCE(s.created_at, NOW()),
  COALESCE(s.updated_at, NOW())
FROM source_data s
WHERE EXISTS (SELECT 1 FROM organizations WHERE id = s.company_id)
ON CONFLICT DO NOTHING;

-- Verify
SELECT COUNT(*) AS funding_rounds_imported FROM funding_rounds;
