-- =============================================================================
-- PHASE 2 - STEP 1: Export from Funding Tracker
-- =============================================================================
-- Run these queries ONE AT A TIME in the Funding Tracker Supabase SQL Editor.
-- Copy the JSON output from each query — you will paste it into the
-- corresponding import script in the unified database.
-- =============================================================================

-- ─────────────────────────────────────────────────────────────────────────────
-- EXPORT 1: Cities
-- ─────────────────────────────────────────────────────────────────────────────
SELECT json_agg(row_to_json(t))
FROM (
  SELECT
    id,
    name,
    region,
    country,
    latitude,
    longitude,
    created_at
  FROM cities
  ORDER BY name
) t;

-- ─────────────────────────────────────────────────────────────────────────────
-- EXPORT 2: Sectors
-- ─────────────────────────────────────────────────────────────────────────────
SELECT json_agg(row_to_json(t))
FROM (
  SELECT
    id,
    name,
    slug,
    description,
    icon,
    color,
    parent_sector_id,
    created_at
  FROM sectors
  ORDER BY name
) t;

-- ─────────────────────────────────────────────────────────────────────────────
-- EXPORT 3: Companies (→ organizations)
-- ─────────────────────────────────────────────────────────────────────────────
SELECT json_agg(row_to_json(t))
FROM (
  SELECT
    id,
    name,
    description,
    website,
    hq_city_id,
    hq_city_name,
    hq_country,
    founded_year,
    status,
    logo_url,
    siren,
    siret,
    created_at,
    updated_at
  FROM companies
  ORDER BY name
) t;

-- ─────────────────────────────────────────────────────────────────────────────
-- EXPORT 4: People
-- ─────────────────────────────────────────────────────────────────────────────
SELECT json_agg(row_to_json(t))
FROM (
  SELECT
    id,
    full_name,
    linkedin_url,
    twitter_url,
    email,
    bio,
    photo_url,
    created_at,
    updated_at
  FROM people
  ORDER BY full_name
) t;
