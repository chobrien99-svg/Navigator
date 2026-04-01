-- =============================================================================
-- PHASE 2 - IMPORT 2: Sectors
-- =============================================================================
-- Run in the UNIFIED DATABASE SQL Editor.
--
-- Instructions:
-- 1. Run Export 2 from 01_export_from_funding_tracker.sql in your Funding
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
    id               UUID,
    name             TEXT,
    slug             TEXT,
    description      TEXT,
    icon             TEXT,
    color            TEXT,
    parent_sector_id UUID,
    created_at       TIMESTAMPTZ
  )
)
INSERT INTO sectors (
  id,
  name,
  slug,
  description,
  icon,
  color,
  parent_id,
  created_at,
  updated_at
)
SELECT
  s.id,
  s.name,
  s.slug,
  s.description,
  s.icon,
  s.color,
  s.parent_sector_id,
  COALESCE(s.created_at, NOW()),
  NOW()
FROM source_data s
ON CONFLICT (slug) DO NOTHING;

-- Verify
SELECT COUNT(*) AS sectors_imported FROM sectors;
