-- =============================================================================
-- PHASE 6 - AI RADAR MIGRATION (all in one script, data is small)
-- =============================================================================
-- Run each section in the AI RADAR SQL Editor to export,
-- then run the corresponding import in the UNIFIED DB SQL Editor.
-- =============================================================================

-- ─────────────────────────────────────────────────────────────────────────────
-- EXPORT 1: Startups (→ organizations)
-- Run in AI RADAR SQL Editor
-- ─────────────────────────────────────────────────────────────────────────────
SELECT json_agg(row_to_json(t))
FROM (
  SELECT id, name, slug, description, city, country, sector::text, stage::text,
         founded_date, incorporation_date, total_raised_eur, last_round,
         fundraising_status::text, technology_layer::text,
         product_modality::text, signal_count, last_signal_date,
         is_active, website_url, linkedin_url, contact_email, contact_phone,
         siren, siret, created_at, updated_at
  FROM startups
  ORDER BY name
) t;

-- ─────────────────────────────────────────────────────────────────────────────
-- EXPORT 2: Founders (→ people)
-- Run in AI RADAR SQL Editor
-- ─────────────────────────────────────────────────────────────────────────────
SELECT json_agg(row_to_json(t))
FROM (
  SELECT id, name, slug, role, bio, linkedin_url,
         has_phd, is_repeat_founder, has_big_tech_background,
         big_tech_employer, academic_lab, previous_exits,
         created_at
  FROM founders
  ORDER BY name
) t;

-- ─────────────────────────────────────────────────────────────────────────────
-- EXPORT 3: Startup Founders (→ organization_people)
-- ─────────────────────────────────────────────────────────────────────────────
SELECT json_agg(row_to_json(t))
FROM (
  SELECT startup_id, founder_id, role
  FROM startup_founders
) t;

-- ─────────────────────────────────────────────────────────────────────────────
-- EXPORT 4: Legal Entities
-- ─────────────────────────────────────────────────────────────────────────────
SELECT json_agg(row_to_json(t))
FROM (
  SELECT id, startup_id, legal_name, legal_form, siren, siret,
         capital_eur, incorporation_date, registered_city, is_primary, created_at
  FROM legal_entities
  ORDER BY legal_name
) t;

-- ─────────────────────────────────────────────────────────────────────────────
-- EXPORT 5: Signals
-- ─────────────────────────────────────────────────────────────────────────────
SELECT json_agg(row_to_json(t))
FROM (
  SELECT id, startup_id, signal_date, signal_type::text, strength::text,
         title, description, created_at
  FROM signals
  ORDER BY signal_date
) t;

-- ─────────────────────────────────────────────────────────────────────────────
-- EXPORT 6: Products
-- ─────────────────────────────────────────────────────────────────────────────
SELECT json_agg(row_to_json(t))
FROM (
  SELECT id, startup_id, name, description, product_type,
         modality::text, status, created_at
  FROM products
  ORDER BY name
) t;

-- ─────────────────────────────────────────────────────────────────────────────
-- EXPORT 7: Startup Tags (→ organization_tags)
-- ─────────────────────────────────────────────────────────────────────────────
SELECT json_agg(row_to_json(t))
FROM (
  SELECT id, startup_id, label, strength::text, created_at
  FROM startup_tags
  ORDER BY label
) t;

-- ─────────────────────────────────────────────────────────────────────────────
-- EXPORT 8: Founder Startups (→ person_experience)
-- ─────────────────────────────────────────────────────────────────────────────
SELECT json_agg(row_to_json(t))
FROM (
  SELECT founder_id, startup_name, role, start_year, end_year, outcome
  FROM founder_startups
) t;

-- ─────────────────────────────────────────────────────────────────────────────
-- EXPORT 9: Startup profiles data (→ organization_profiles)
-- These fields live directly on the startups table in AI Radar
-- ─────────────────────────────────────────────────────────────────────────────
SELECT json_agg(row_to_json(t))
FROM (
  SELECT id, investor_brief, product_description, target_market,
         competitive_landscape, current_strategy, business_model_hypothesis,
         analyst_note, technical_thesis, fundraising_signal_summary,
         est_next_raise, entity_complexity
  FROM startups
  WHERE investor_brief IS NOT NULL
     OR product_description IS NOT NULL
     OR analyst_note IS NOT NULL
  ORDER BY name
) t;

-- ─────────────────────────────────────────────────────────────────────────────
-- EXPORT 10: Profiles (user accounts)
-- ─────────────────────────────────────────────────────────────────────────────
SELECT json_agg(row_to_json(t))
FROM (
  SELECT id, email, full_name, subscription_tier::text,
         stripe_customer_id, stripe_subscription_id,
         subscription_status, subscription_period_end,
         is_admin, created_at, updated_at
  FROM profiles
) t;

-- ─────────────────────────────────────────────────────────────────────────────
-- EXPORT 11: Watchlist
-- ─────────────────────────────────────────────────────────────────────────────
SELECT json_agg(row_to_json(t))
FROM (
  SELECT id, user_id, startup_id, created_at
  FROM watchlist
) t;
