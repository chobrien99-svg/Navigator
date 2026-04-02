-- =============================================================================
-- PHASE 3 - IMPORT: Organization People (from company_people)
-- =============================================================================
-- Run in the UNIFIED DATABASE SQL Editor.
--
-- Instructions:
-- 1. Export company_people from Funding Tracker (batches of 200)
-- 2. Strip the {"json_agg": ...} wrapper
-- 3. Paste the inner JSON array below, replacing __PASTE_JSON_HERE__
-- 4. Use $$...$$::json (not single quotes) for French names
-- 5. Run in the unified DB SQL editor
--
-- Mapping: company_id → organization_id, person_id stays the same
-- The IDs match because we preserved them during Phase 2 import.
-- =============================================================================

WITH source_data AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    '__PASTE_JSON_HERE__'::json
  ) AS (
    id          UUID,
    company_id  UUID,
    person_id   UUID,
    role        TEXT,
    is_current  BOOLEAN,
    start_date  DATE,
    end_date    DATE,
    created_at  TIMESTAMPTZ
  )
)
INSERT INTO organization_people (
  id,
  organization_id,
  person_id,
  role,
  is_current,
  is_founder,
  start_date,
  end_date,
  created_at,
  updated_at
)
SELECT
  s.id,
  s.company_id,
  s.person_id,
  s.role,
  COALESCE(s.is_current, TRUE),
  CASE WHEN lower(s.role) = 'founder' OR lower(s.role) LIKE '%co-founder%' OR lower(s.role) LIKE '%cofounder%' THEN TRUE ELSE FALSE END,
  s.start_date,
  s.end_date,
  COALESCE(s.created_at, NOW()),
  NOW()
FROM source_data s
WHERE EXISTS (SELECT 1 FROM organizations WHERE id = s.company_id)
  AND EXISTS (SELECT 1 FROM people WHERE id = s.person_id)
ON CONFLICT (organization_id, person_id, role) DO NOTHING;

-- Verify
SELECT COUNT(*) AS organization_people_imported FROM organization_people;
