-- =============================================================================
-- PHASE 6 - AI RADAR IMPORT (all in one script)
-- =============================================================================
-- Run each section one at a time in the UNIFIED DB SQL Editor.
-- For each section, replace __PASTE_JSON_HERE__ with the exported JSON
-- (stripped of the json_agg wrapper) using $$...$$::json
-- =============================================================================

-- ─────────────────────────────────────────────────────────────────────────────
-- IMPORT 1: Startups → organizations
-- ─────────────────────────────────────────────────────────────────────────────
WITH source_data AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    '__PASTE_JSON_HERE__'::json
  ) AS (
    id                  UUID,
    name                TEXT,
    slug                TEXT,
    description         TEXT,
    city                TEXT,
    country             TEXT,
    sector              TEXT,
    stage               TEXT,
    founded_date        DATE,
    incorporation_date  DATE,
    total_raised_eur    NUMERIC,
    last_round          TEXT,
    fundraising_status  TEXT,
    technology_layer    TEXT,
    product_modality    TEXT,
    signal_count        INTEGER,
    last_signal_date    TIMESTAMPTZ,
    is_active           BOOLEAN,
    website_url         TEXT,
    linkedin_url        TEXT,
    contact_email       TEXT,
    contact_phone       TEXT,
    siren               TEXT,
    siret               TEXT,
    created_at          TIMESTAMPTZ,
    updated_at          TIMESTAMPTZ
  )
)
INSERT INTO organizations (
  id, name, slug, organization_type, description, website, linkedin_url,
  email, phone, status, country, founded_date, total_raised_eur, last_round,
  fundraising_status, technology_layer, signal_count, last_signal_date,
  legacy_source, legacy_id, created_at, updated_at
)
SELECT
  s.id, s.name, s.slug, 'startup'::organization_type, s.description,
  s.website_url, s.linkedin_url, s.contact_email, s.contact_phone,
  CASE WHEN s.is_active THEN 'active'::organization_status ELSE 'inactive'::organization_status END,
  COALESCE(s.country, 'France'), s.founded_date, s.total_raised_eur, s.last_round,
  CASE
    WHEN s.fundraising_status = 'not_raising' THEN 'not_raising'::fundraising_status_type
    WHEN s.fundraising_status = 'exploring' THEN 'exploring'::fundraising_status_type
    WHEN s.fundraising_status = 'actively_raising' THEN 'actively_raising'::fundraising_status_type
    WHEN s.fundraising_status = 'closing' THEN 'closing'::fundraising_status_type
    WHEN s.fundraising_status = 'recently_closed' THEN 'recently_closed'::fundraising_status_type
    ELSE 'unknown'::fundraising_status_type
  END,
  CASE
    WHEN s.technology_layer = 'infrastructure' THEN 'infrastructure'::technology_layer_type
    WHEN s.technology_layer = 'model' THEN 'model'::technology_layer_type
    WHEN s.technology_layer = 'application' THEN 'application'::technology_layer_type
    WHEN s.technology_layer = 'tooling' THEN 'tooling'::technology_layer_type
    WHEN s.technology_layer = 'data' THEN 'data'::technology_layer_type
    ELSE NULL
  END,
  COALESCE(s.signal_count, 0), s.last_signal_date,
  'ai_radar', s.id::TEXT,
  COALESCE(s.created_at, NOW()), COALESCE(s.updated_at, NOW())
FROM source_data s
ON CONFLICT (slug) DO NOTHING;

SELECT COUNT(*) AS orgs_from_radar FROM organizations WHERE legacy_source = 'ai_radar';


-- ─────────────────────────────────────────────────────────────────────────────
-- IMPORT 2: Founders → people
-- ─────────────────────────────────────────────────────────────────────────────
WITH source_data AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    '__PASTE_JSON_HERE__'::json
  ) AS (
    id                      UUID,
    name                    TEXT,
    slug                    TEXT,
    role                    TEXT,
    bio                     TEXT,
    linkedin_url            TEXT,
    has_phd                 BOOLEAN,
    is_repeat_founder       BOOLEAN,
    has_big_tech_background BOOLEAN,
    big_tech_employer       TEXT,
    academic_lab            TEXT,
    previous_exits          TEXT[],
    created_at              TIMESTAMPTZ
  )
)
INSERT INTO people (
  id, full_name, slug, linkedin_url, bio, has_phd, is_repeat_founder,
  has_big_tech_background, big_tech_employer, academic_lab,
  previous_exits, legacy_source, legacy_id, created_at, updated_at
)
SELECT
  s.id, s.name, s.slug, s.linkedin_url, s.bio,
  COALESCE(s.has_phd, FALSE), COALESCE(s.is_repeat_founder, FALSE),
  COALESCE(s.has_big_tech_background, FALSE), s.big_tech_employer, s.academic_lab,
  COALESCE(array_length(s.previous_exits, 1), 0),
  'ai_radar', s.id::TEXT,
  COALESCE(s.created_at, NOW()), NOW()
FROM source_data s
ON CONFLICT (slug) DO NOTHING;

SELECT COUNT(*) AS people_from_radar FROM people WHERE legacy_source = 'ai_radar';


-- ─────────────────────────────────────────────────────────────────────────────
-- IMPORT 3: Startup Founders → organization_people
-- ─────────────────────────────────────────────────────────────────────────────
WITH source_data AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    '__PASTE_JSON_HERE__'::json
  ) AS (
    startup_id UUID,
    founder_id UUID,
    role       TEXT
  )
)
INSERT INTO organization_people (
  organization_id, person_id, role, is_current, is_founder, created_at, updated_at
)
SELECT
  s.startup_id, s.founder_id, COALESCE(s.role, 'founder'),
  TRUE, TRUE, NOW(), NOW()
FROM source_data s
WHERE EXISTS (SELECT 1 FROM organizations WHERE id = s.startup_id)
  AND EXISTS (SELECT 1 FROM people WHERE id = s.founder_id)
ON CONFLICT (organization_id, person_id, role) DO NOTHING;

SELECT COUNT(*) AS org_people_added FROM organization_people
WHERE organization_id IN (SELECT id FROM organizations WHERE legacy_source = 'ai_radar');


-- ─────────────────────────────────────────────────────────────────────────────
-- IMPORT 4: Legal Entities
-- ─────────────────────────────────────────────────────────────────────────────
WITH source_data AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    '__PASTE_JSON_HERE__'::json
  ) AS (
    id                 UUID,
    startup_id         UUID,
    legal_name         TEXT,
    legal_form         TEXT,
    siren              TEXT,
    siret              TEXT,
    capital_eur        NUMERIC,
    incorporation_date DATE,
    registered_city    TEXT,
    is_primary         BOOLEAN,
    created_at         TIMESTAMPTZ
  )
)
INSERT INTO legal_entities (
  id, organization_id, legal_name, legal_form, siren, siret,
  capital_eur, incorporation_date, registered_city, is_primary,
  created_at, updated_at
)
SELECT
  s.id, s.startup_id, s.legal_name, s.legal_form, s.siren, s.siret,
  s.capital_eur, s.incorporation_date, s.registered_city,
  COALESCE(s.is_primary, TRUE),
  COALESCE(s.created_at, NOW()), NOW()
FROM source_data s
WHERE EXISTS (SELECT 1 FROM organizations WHERE id = s.startup_id)
ON CONFLICT DO NOTHING;

SELECT COUNT(*) AS legal_entities_total FROM legal_entities;


-- ─────────────────────────────────────────────────────────────────────────────
-- IMPORT 5: Signals
-- ─────────────────────────────────────────────────────────────────────────────
WITH source_data AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    '__PASTE_JSON_HERE__'::json
  ) AS (
    id          UUID,
    startup_id  UUID,
    signal_date DATE,
    signal_type TEXT,
    strength    TEXT,
    title       TEXT,
    description TEXT,
    created_at  TIMESTAMPTZ
  )
)
INSERT INTO signals (
  id, organization_id, signal_type, signal_date, strength,
  title, description, created_at, updated_at
)
SELECT
  s.id, s.startup_id,
  CASE
    WHEN s.signal_type = 'hiring_surge' THEN 'hiring_surge'::signal_type
    WHEN s.signal_type = 'new_product' THEN 'new_product'::signal_type
    WHEN s.signal_type = 'pivot' THEN 'pivot'::signal_type
    WHEN s.signal_type = 'expansion' THEN 'expansion'::signal_type
    WHEN s.signal_type = 'partnership' THEN 'partnership'::signal_type
    WHEN s.signal_type = 'award' THEN 'award'::signal_type
    WHEN s.signal_type = 'media_mention' THEN 'media_mention'::signal_type
    WHEN s.signal_type = 'regulatory' THEN 'regulatory'::signal_type
    WHEN s.signal_type = 'talent_move' THEN 'talent_move'::signal_type
    WHEN s.signal_type = 'patent_filing' THEN 'patent_filing'::signal_type
    WHEN s.signal_type = 'open_source' THEN 'open_source'::signal_type
    WHEN s.signal_type = 'conference' THEN 'conference'::signal_type
    ELSE 'other'::signal_type
  END,
  s.signal_date,
  CASE
    WHEN s.strength = 'strong' THEN 5
    WHEN s.strength = 'moderate' THEN 3
    WHEN s.strength = 'weak' THEN 1
    WHEN s.strength = 'neutral' THEN 2
    ELSE 2
  END,
  s.title, s.description,
  COALESCE(s.created_at, NOW()), NOW()
FROM source_data s
WHERE EXISTS (SELECT 1 FROM organizations WHERE id = s.startup_id)
ON CONFLICT DO NOTHING;

SELECT COUNT(*) AS signals_total FROM signals;


-- ─────────────────────────────────────────────────────────────────────────────
-- IMPORT 6: Products
-- ─────────────────────────────────────────────────────────────────────────────
WITH source_data AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    '__PASTE_JSON_HERE__'::json
  ) AS (
    id           UUID,
    startup_id   UUID,
    name         TEXT,
    description  TEXT,
    product_type TEXT,
    modality     TEXT,
    status       TEXT,
    created_at   TIMESTAMPTZ
  )
)
INSERT INTO products (
  id, organization_id, name, description, product_type, modality, status,
  created_at, updated_at
)
SELECT
  s.id, s.startup_id, s.name, s.description, s.product_type,
  CASE
    WHEN s.modality = 'software' THEN 'software'::product_modality_type
    WHEN s.modality = 'hardware' THEN 'hardware'::product_modality_type
    WHEN s.modality = 'api' THEN 'api'::product_modality_type
    WHEN s.modality = 'platform' THEN 'platform'::product_modality_type
    WHEN s.modality = 'saas' THEN 'saas'::product_modality_type
    ELSE 'software'::product_modality_type
  END,
  COALESCE(s.status, 'active'),
  COALESCE(s.created_at, NOW()), NOW()
FROM source_data s
WHERE EXISTS (SELECT 1 FROM organizations WHERE id = s.startup_id)
ON CONFLICT DO NOTHING;

SELECT COUNT(*) AS products_total FROM products;


-- ─────────────────────────────────────────────────────────────────────────────
-- IMPORT 7: Startup Tags → organization_tags
-- ─────────────────────────────────────────────────────────────────────────────
WITH source_data AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    '__PASTE_JSON_HERE__'::json
  ) AS (
    id         UUID,
    startup_id UUID,
    label      TEXT,
    strength   TEXT,
    created_at TIMESTAMPTZ
  )
)
INSERT INTO organization_tags (
  id, organization_id, tag, strength, created_at
)
SELECT
  s.id, s.startup_id, s.label,
  CASE
    WHEN s.strength = 'strong' THEN 5
    WHEN s.strength = 'moderate' THEN 3
    WHEN s.strength = 'weak' THEN 1
    WHEN s.strength = 'neutral' THEN 2
    ELSE 2
  END,
  COALESCE(s.created_at, NOW())
FROM source_data s
WHERE EXISTS (SELECT 1 FROM organizations WHERE id = s.startup_id)
ON CONFLICT (organization_id, tag) DO NOTHING;

SELECT COUNT(*) AS tags_total FROM organization_tags;


-- ─────────────────────────────────────────────────────────────────────────────
-- IMPORT 8: Founder Startups → person_experience
-- ─────────────────────────────────────────────────────────────────────────────
WITH source_data AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    '__PASTE_JSON_HERE__'::json
  ) AS (
    founder_id   UUID,
    startup_name TEXT,
    role         TEXT,
    start_year   INTEGER,
    end_year     INTEGER,
    outcome      TEXT
  )
)
INSERT INTO person_experience (
  person_id, company_name, role, start_date, end_date, description,
  created_at, updated_at
)
SELECT
  s.founder_id, s.startup_name, s.role,
  CASE WHEN s.start_year IS NOT NULL THEN make_date(s.start_year, 1, 1) ELSE NULL END,
  CASE WHEN s.end_year IS NOT NULL THEN make_date(s.end_year, 1, 1) ELSE NULL END,
  s.outcome,
  NOW(), NOW()
FROM source_data s
WHERE EXISTS (SELECT 1 FROM people WHERE id = s.founder_id)
ON CONFLICT DO NOTHING;

SELECT COUNT(*) AS experience_total FROM person_experience;


-- ─────────────────────────────────────────────────────────────────────────────
-- IMPORT 9: Organization Profiles (from startup fields)
-- ─────────────────────────────────────────────────────────────────────────────
WITH source_data AS (
  SELECT * FROM json_populate_recordset(
    NULL::record,
    '__PASTE_JSON_HERE__'::json
  ) AS (
    id                          UUID,
    investor_brief              TEXT,
    product_description         TEXT,
    target_market               TEXT,
    competitive_landscape       TEXT,
    current_strategy            TEXT,
    business_model_hypothesis   TEXT,
    analyst_note                TEXT,
    technical_thesis            TEXT,
    fundraising_signal_summary  TEXT,
    est_next_raise              TEXT,
    entity_complexity           TEXT
  )
)
INSERT INTO organization_profiles (
  organization_id, investor_brief, product_description, target_market,
  competitive_landscape, current_strategy, business_model_hypothesis,
  analyst_note, technical_thesis, fundraising_signal_summary,
  est_next_raise, entity_complexity, created_at, updated_at
)
SELECT
  s.id, s.investor_brief, s.product_description, s.target_market,
  s.competitive_landscape, s.current_strategy, s.business_model_hypothesis,
  s.analyst_note, s.technical_thesis, s.fundraising_signal_summary,
  s.est_next_raise, s.entity_complexity, NOW(), NOW()
FROM source_data s
WHERE EXISTS (SELECT 1 FROM organizations WHERE id = s.id)
ON CONFLICT (organization_id) DO NOTHING;

SELECT COUNT(*) AS profiles_total FROM organization_profiles;


-- ─────────────────────────────────────────────────────────────────────────────
-- IMPORT 10: User Profiles
-- NOTE: These reference auth.users — the user accounts must exist in
-- Supabase Auth first. If they don't, skip this and recreate accounts.
-- ─────────────────────────────────────────────────────────────────────────────
-- WITH source_data AS (
--   SELECT * FROM json_populate_recordset(
--     NULL::record,
--     '__PASTE_JSON_HERE__'::json
--   ) AS (
--     id                      UUID,
--     email                   TEXT,
--     full_name               TEXT,
--     subscription_tier       TEXT,
--     stripe_customer_id      TEXT,
--     stripe_subscription_id  TEXT,
--     subscription_status     TEXT,
--     subscription_period_end TIMESTAMPTZ,
--     is_admin                BOOLEAN,
--     created_at              TIMESTAMPTZ,
--     updated_at              TIMESTAMPTZ
--   )
-- )
-- INSERT INTO profiles (
--   id, email, full_name, subscription_tier, stripe_customer_id,
--   stripe_subscription_id, subscription_status, subscription_period_end,
--   is_admin, created_at, updated_at
-- )
-- SELECT
--   s.id, s.email, s.full_name,
--   COALESCE(s.subscription_tier, 'free')::subscription_tier,
--   s.stripe_customer_id, s.stripe_subscription_id,
--   COALESCE(s.subscription_status, 'inactive'),
--   s.subscription_period_end,
--   COALESCE(s.is_admin, FALSE),
--   COALESCE(s.created_at, NOW()), COALESCE(s.updated_at, NOW())
-- FROM source_data s
-- ON CONFLICT (id) DO NOTHING;
--
-- SELECT COUNT(*) AS profiles_total FROM profiles;
