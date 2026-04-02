-- =============================================================================
-- PHASE 3 - IMPORT: Organization Sectors (from company_sectors)
-- =============================================================================
-- Run in the UNIFIED DATABASE SQL Editor.
--
-- Instructions:
-- 1. Export company_sectors from Funding Tracker (batches of 200)
-- 2. Strip the {"json_agg": ...} wrapper
-- 3. Paste the inner JSON array below, replacing __PASTE_JSON_HERE__
-- 4. Use $$...$$::json (not single quotes)
-- 5. Run in the unified DB SQL editor
--
-- Mapping: company_id → organization_id, sector_id stays the same
-- =============================================================================

WITH source_data AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    '__PASTE_JSON_HERE__'::json
  ) AS (
    id          UUID,
    company_id  UUID,
    sector_id   UUID,
    is_primary  BOOLEAN,
    created_at  TIMESTAMPTZ
  )
)
INSERT INTO organization_sectors (
  id,
  organization_id,
  sector_id,
  is_primary,
  created_at
)
SELECT
  s.id,
  s.company_id,
  s.sector_id,
  COALESCE(s.is_primary, FALSE),
  COALESCE(s.created_at, NOW())
FROM source_data s
WHERE EXISTS (SELECT 1 FROM organizations WHERE id = s.company_id)
  AND EXISTS (SELECT 1 FROM sectors WHERE id = s.sector_id)
ON CONFLICT (organization_id, sector_id) DO NOTHING;

-- Verify
SELECT COUNT(*) AS organization_sectors_imported FROM organization_sectors;
