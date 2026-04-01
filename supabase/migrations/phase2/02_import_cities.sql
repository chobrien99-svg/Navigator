-- =============================================================================
-- PHASE 2 - IMPORT 1: Cities
-- =============================================================================
-- Run in the UNIFIED DATABASE SQL Editor.
--
-- Instructions:
-- 1. Run Export 1 from 01_export_from_funding_tracker.sql in your Funding
--    Tracker SQL editor
-- 2. Copy the JSON array result
-- 3. Paste it below, replacing the placeholder '__PASTE_JSON_HERE__'
-- 4. Run this script in the unified database SQL editor
-- =============================================================================

WITH source_data AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    '__PASTE_JSON_HERE__'::json
  ) AS (
    id          UUID,
    name        TEXT,
    region      TEXT,
    country     TEXT,
    latitude    NUMERIC,
    longitude   NUMERIC,
    created_at  TIMESTAMPTZ
  )
)
INSERT INTO cities (
  id,
  name,
  slug,
  region,
  country,
  latitude,
  longitude,
  created_at,
  updated_at
)
SELECT
  s.id,
  s.name,
  lower(regexp_replace(
    regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\s-]', '', 'g'),
    '\s+', '-', 'g'
  )),
  s.region,
  COALESCE(s.country, 'France'),
  s.latitude,
  s.longitude,
  COALESCE(s.created_at, NOW()),
  NOW()
FROM source_data s
ON CONFLICT (slug) DO NOTHING;

-- Verify
SELECT COUNT(*) AS cities_imported FROM cities;
