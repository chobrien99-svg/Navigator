-- =============================================================================
-- PHASE 2 - IMPORT 5: Investors (as organizations)
-- =============================================================================
-- The Funding Tracker has a separate 'investors' table. In the unified schema,
-- investors are organizations with organization_type = 'investor'.
--
-- Run in the UNIFIED DATABASE SQL Editor.
--
-- Instructions:
-- 1. Run the export query below in the Funding Tracker SQL editor
-- 2. Copy the JSON array result
-- 3. Paste it below, replacing the placeholder '__PASTE_JSON_HERE__'
-- 4. Run this script in the unified database SQL editor
-- =============================================================================

-- ┌─────────────────────────────────────────────────────────────────────────┐
-- │ EXPORT QUERY — run this in the FUNDING TRACKER SQL editor first:       │
-- │                                                                        │
-- │  SELECT json_agg(row_to_json(t))                                       │
-- │  FROM (                                                                │
-- │    SELECT                                                              │
-- │      id,                                                               │
-- │      name,                                                             │
-- │      type,                                                             │
-- │      website,                                                          │
-- │      description,                                                      │
-- │      hq_city,                                                          │
-- │      hq_country,                                                       │
-- │      logo_url,                                                         │
-- │      created_at,                                                       │
-- │      updated_at                                                        │
-- │    FROM investors                                                      │
-- │    ORDER BY name                                                       │
-- │  ) t;                                                                  │
-- └─────────────────────────────────────────────────────────────────────────┘

CREATE EXTENSION IF NOT EXISTS "unaccent";

WITH source_data AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    '__PASTE_JSON_HERE__'::json
  ) AS (
    id          UUID,
    name        TEXT,
    type        TEXT,
    website     TEXT,
    description TEXT,
    hq_city     TEXT,
    hq_country  TEXT,
    logo_url    TEXT,
    created_at  TIMESTAMPTZ,
    updated_at  TIMESTAMPTZ
  )
)
INSERT INTO organizations (
  name,
  slug,
  organization_type,
  description,
  website,
  logo_url,
  status,
  country,
  legacy_source,
  legacy_id,
  created_at,
  updated_at
)
SELECT
  s.name,
  lower(regexp_replace(
    regexp_replace(unaccent(s.name), '[^a-zA-Z0-9\s-]', '', 'g'),
    '\s+', '-', 'g'
  )),
  'investor'::organization_type,
  s.description,
  s.website,
  s.logo_url,
  'active'::organization_status,
  COALESCE(s.hq_country, 'France'),
  'funding_tracker',
  s.id::TEXT,
  COALESCE(s.created_at, NOW()),
  COALESCE(s.updated_at, NOW())
FROM source_data s
ON CONFLICT (slug) DO NOTHING;

-- Record in merge map
INSERT INTO organization_merge_map (organization_id, source_db, source_table, source_id)
SELECT o.id, 'funding_tracker', 'investors', o.legacy_id
FROM organizations o
WHERE o.legacy_source = 'funding_tracker'
  AND o.organization_type = 'investor'
  AND NOT EXISTS (
    SELECT 1 FROM organization_merge_map m
    WHERE m.source_db = 'funding_tracker'
      AND m.source_table = 'investors'
      AND m.source_id = o.legacy_id
  );

-- Verify
SELECT COUNT(*) AS investors_imported
FROM organizations
WHERE organization_type = 'investor';
