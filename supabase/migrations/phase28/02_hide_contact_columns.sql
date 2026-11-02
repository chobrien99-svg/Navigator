-- =============================================================================
-- Hide email and phone from the public key and from ordinary accounts.
--
-- Before: anyone with the public anon key (it ships to every browser that
-- opens a site using this database) could download people.email (45 rows),
-- organizations.email (37) and organizations.phone (7). So could any
-- signed-in account, including a free France AI Radar signup.
--
-- After: the anon and authenticated roles can read every other column of
-- these two tables, but not these three. Row access (RLS) is unchanged.
-- The Navigator team reads them through get_person_email() and
-- get_organization_contact() (01_contact_lookup.sql). The service role
-- (France AI Radar's server, scripts) is not affected.
--
-- ORDER: apply only after the Navigator frontend change that stops asking for
-- "*" on these tables is deployed. A query that asks for "*", or names one of
-- these columns, now fails with "permission denied for table ...".
-- Checked before writing this (2 Nov 2026): France AI Radar reads these
-- tables with explicit columns or the service role; the Q2/Q3 deals
-- databases and Navigator /embed, /api/public name their columns.
--
-- New columns: after this, a column added to people or organizations is NOT
-- readable by anon/authenticated until granted, e.g.
--   GRANT SELECT (new_column) ON public.people TO anon, authenticated;
-- and add it to frontend/src/lib/columns.ts.
--
-- Writes (INSERT/UPDATE by admins) are unchanged; email and phone can still
-- be saved from the admin forms.
-- Safe to run twice. Undo: 03_rollback_hide_contact_columns.sql
-- =============================================================================

BEGIN;

REVOKE SELECT ON public.people FROM PUBLIC, anon, authenticated;
GRANT SELECT (
  id, full_name, slug, first_name, last_name, linkedin_url, twitter_url,
  bio, photo_url, has_phd, is_repeat_founder, has_big_tech_background,
  big_tech_employer, academic_lab, previous_exits, legacy_source, legacy_id,
  created_at, updated_at, verification_status, is_public_profile,
  google_scholar_url, github_url, personal_website_url, notable_publications,
  short_bio
) ON public.people TO anon, authenticated;

REVOKE SELECT ON public.organizations FROM PUBLIC, anon, authenticated;
GRANT SELECT (
  id, name, slug, organization_type, description, short_description, website,
  linkedin_url, twitter_url, logo_url, status, country, city_id, founded_date,
  employee_count, employee_range, founded_year, first_seen_at, is_stealth,
  total_raised_eur, last_round, fundraising_status, technology_layer,
  signal_count, last_signal_date, legacy_source, legacy_id, created_at,
  updated_at, is_public_profile, verification_status, secondary_city_id
) ON public.organizations TO anon, authenticated;

-- Stop here (and keep the old access) if any column was missed: every column
-- except the three contact ones must still be readable.
DO $$
DECLARE missing text;
BEGIN
  SELECT string_agg(table_name || '.' || column_name, ', ') INTO missing
  FROM information_schema.columns
  WHERE table_schema = 'public'
    AND table_name IN ('people', 'organizations')
    AND (table_name, column_name) NOT IN (('people', 'email'), ('organizations', 'email'), ('organizations', 'phone'))
    AND NOT has_column_privilege('anon', format('public.%I', table_name), column_name, 'SELECT');
  IF missing IS NOT NULL THEN
    RAISE EXCEPTION 'Not granted to anon (add to this file): %', missing;
  END IF;
  IF has_column_privilege('anon', 'public.people', 'email', 'SELECT')
     OR has_column_privilege('authenticated', 'public.organizations', 'phone', 'SELECT') THEN
    RAISE EXCEPTION 'Contact columns are still readable';
  END IF;
END $$;

COMMIT;
