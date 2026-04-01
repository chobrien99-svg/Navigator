-- =============================================================================
-- PHASE 2 - IMPORT 3: Organizations (from Funding Tracker companies)
-- =============================================================================
-- Run in the UNIFIED DATABASE SQL Editor.
--
-- Instructions:
-- 1. Run Export 3 from 01_export_from_funding_tracker.sql in your Funding
--    Tracker SQL editor
-- 2. Copy the JSON array result
-- 3. Paste it below, replacing the placeholder '__PASTE_JSON_HERE__'
-- 4. Run this script in the unified database SQL editor
--
-- NOTE: Run AFTER 02_import_cities.sql so city references resolve correctly.
-- =============================================================================

-- Ensure unaccent extension is available (for slug generation)
CREATE EXTENSION IF NOT EXISTS "unaccent";

WITH source_data AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    '__PASTE_JSON_HERE__'::json
  ) AS (
    id           UUID,
    name         TEXT,
    description  TEXT,
    website      TEXT,
    hq_city_id   UUID,
    hq_city_name TEXT,
    hq_country   TEXT,
    founded_year INTEGER,
    status       TEXT,
    logo_url     TEXT,
    siren        TEXT,
    siret        TEXT,
    created_at   TIMESTAMPTZ,
    updated_at   TIMESTAMPTZ
  )
)
INSERT INTO organizations (
  id,
  name,
  slug,
  organization_type,
  description,
  website,
  logo_url,
  status,
  country,
  city_id,
  founded_year,
  founded_date,
  legacy_source,
  legacy_id,
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
  'startup'::organization_type,
  s.description,
  s.website,
  s.logo_url,
  CASE
    WHEN s.status = 'active'   THEN 'active'::organization_status
    WHEN s.status = 'inactive' THEN 'inactive'::organization_status
    WHEN s.status = 'acquired' THEN 'acquired'::organization_status
    WHEN s.status = 'closed'   THEN 'closed'::organization_status
    WHEN s.status = 'ipo'      THEN 'ipo'::organization_status
    ELSE 'unknown'::organization_status
  END,
  COALESCE(s.hq_country, 'France'),
  s.hq_city_id,
  s.founded_year,
  CASE
    WHEN s.founded_year IS NOT NULL
    THEN make_date(s.founded_year, 1, 1)
    ELSE NULL
  END,
  'funding_tracker',
  s.id::TEXT,
  COALESCE(s.created_at, NOW()),
  COALESCE(s.updated_at, NOW())
FROM source_data s
ON CONFLICT (slug) DO NOTHING;

-- Also create legal_entities for any companies that had SIREN/SIRET
INSERT INTO legal_entities (
  organization_id,
  legal_name,
  siren,
  siret,
  country,
  is_primary
)
SELECT
  o.id,
  o.name,
  s.siren,
  s.siret,
  COALESCE(s.hq_country, 'France'),
  TRUE
FROM json_populate_recordset(
  NULL::record,
  '__PASTE_JSON_HERE__'::json
) AS s(
  id UUID, name TEXT, description TEXT, website TEXT,
  hq_city_id UUID, hq_city_name TEXT, hq_country TEXT,
  founded_year INTEGER, status TEXT, logo_url TEXT,
  siren TEXT, siret TEXT, created_at TIMESTAMPTZ, updated_at TIMESTAMPTZ
)
JOIN organizations o ON o.legacy_source = 'funding_tracker' AND o.legacy_id = s.id::TEXT
WHERE s.siren IS NOT NULL OR s.siret IS NOT NULL;

-- Record in merge map for provenance tracking
INSERT INTO organization_merge_map (organization_id, source_db, source_table, source_id)
SELECT id, 'funding_tracker', 'companies', legacy_id
FROM organizations
WHERE legacy_source = 'funding_tracker'
ON CONFLICT (source_db, source_table, source_id) DO NOTHING;

-- Verify
SELECT COUNT(*) AS organizations_imported FROM organizations;
SELECT COUNT(*) AS legal_entities_created FROM legal_entities;
SELECT COUNT(*) AS merge_map_entries FROM organization_merge_map;
