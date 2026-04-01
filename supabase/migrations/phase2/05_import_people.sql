-- =============================================================================
-- PHASE 2 - IMPORT 4: People
-- =============================================================================
-- Run in the UNIFIED DATABASE SQL Editor.
--
-- Instructions:
-- 1. Run Export 4 from 01_export_from_funding_tracker.sql in your Funding
--    Tracker SQL editor
-- 2. Copy the JSON array result
-- 3. Paste it below, replacing the placeholder '__PASTE_JSON_HERE__'
-- 4. Run this script in the unified database SQL editor
-- =============================================================================

-- Ensure unaccent extension is available (for slug generation)
CREATE EXTENSION IF NOT EXISTS "unaccent";

WITH source_data AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    '__PASTE_JSON_HERE__'::json
  ) AS (
    id           UUID,
    full_name    TEXT,
    linkedin_url TEXT,
    twitter_url  TEXT,
    email        TEXT,
    bio          TEXT,
    photo_url    TEXT,
    created_at   TIMESTAMPTZ,
    updated_at   TIMESTAMPTZ
  )
)
INSERT INTO people (
  id,
  full_name,
  slug,
  first_name,
  last_name,
  linkedin_url,
  twitter_url,
  email,
  bio,
  photo_url,
  legacy_source,
  legacy_id,
  created_at,
  updated_at
)
SELECT
  s.id,
  s.full_name,
  lower(regexp_replace(
    regexp_replace(unaccent(s.full_name), '[^a-zA-Z0-9\s-]', '', 'g'),
    '\s+', '-', 'g'
  )),
  -- Extract first name (everything before the last space)
  CASE
    WHEN position(' ' in s.full_name) > 0
    THEN trim(left(s.full_name, length(s.full_name) - length(split_part(s.full_name, ' ', array_length(string_to_array(s.full_name, ' '), 1)))))
    ELSE s.full_name
  END,
  -- Extract last name (everything after the last space)
  CASE
    WHEN position(' ' in s.full_name) > 0
    THEN split_part(s.full_name, ' ', array_length(string_to_array(s.full_name, ' '), 1))
    ELSE NULL
  END,
  s.linkedin_url,
  s.twitter_url,
  s.email,
  s.bio,
  s.photo_url,
  'funding_tracker',
  s.id::TEXT,
  COALESCE(s.created_at, NOW()),
  COALESCE(s.updated_at, NOW())
FROM source_data s
ON CONFLICT (slug) DO NOTHING;

-- Record in merge map for provenance tracking
INSERT INTO person_merge_map (person_id, source_db, source_table, source_id)
SELECT id, 'funding_tracker', 'people', legacy_id
FROM people
WHERE legacy_source = 'funding_tracker'
ON CONFLICT (source_db, source_table, source_id) DO NOTHING;

-- Verify
SELECT COUNT(*) AS people_imported FROM people;
SELECT COUNT(*) AS merge_map_entries FROM person_merge_map;
