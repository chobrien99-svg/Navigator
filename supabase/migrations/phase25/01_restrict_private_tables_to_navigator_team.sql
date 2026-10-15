-- =============================================================================
-- Restrict tables that no public site reads.
--
-- Until now every table below had a "Public read access" policy (USING true),
-- so anyone holding the public anon key could download it. Which tables stay
-- public was decided from two days of API logs (Oct 2026):
--
--   Still public, read without a login by:
--     - the Q2/Q3 deals databases (browser): funding_rounds,
--       funding_round_investors, organizations, organization_people,
--       organization_sectors, people, sectors, cities
--     - Navigator /api/public + /embed: the above plus programs,
--       program_editions, program_organizations
--     - France AI Radar (anon key): signals, program_organizations,
--       organization_people
--
--   Logged-in accounts only: person_experience. France AI Radar's paying
--     (non-team) users read it, so it can't be team-only yet.
--
--   Navigator team only: everything else below. France AI Radar reads
--     organization_profiles and product_organizations with its service-role
--     key, which bypasses RLS, so it is not affected.
--
-- Admin write policies are unchanged. The only admins are team members.
-- Undo: 02_rollback_restrict_private_tables.sql
--
-- UPDATE 15 Oct 2026: the France AI Radar reasons above no longer hold. It now
-- reads signals, person_experience, organization_people and
-- program_organizations server-side (service role). signals and
-- person_experience were made Navigator-team only, and profile/INSERT holes
-- closed, in 03_lock_signals_and_writes.sql.
-- =============================================================================

-- True when the caller is signed in with a confirmed @frenchtechjournal.com
-- email. Keep in sync with frontend/src/lib/team-access.ts.
CREATE OR REPLACE FUNCTION public.is_navigator_team()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT coalesce((
    SELECT u.email_confirmed_at IS NOT NULL
       AND lower(split_part(u.email, '@', 2)) = 'frenchtechjournal.com'
    FROM auth.users u
    WHERE u.id = auth.uid()
  ), false);
$$;

REVOKE ALL ON FUNCTION public.is_navigator_team() FROM public;
GRANT EXECUTE ON FUNCTION public.is_navigator_team() TO anon, authenticated;

-- ─── Team-only tables ────────────────────────────────────────
DO $$
DECLARE
  t text;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'article_organizations',
    'articles',
    'grants',
    'legal_entities',
    'organization_events',
    'organization_profiles',
    'organization_relationships',
    'organization_tags',
    'patent_inventors',
    'patents',
    'product_catalog',
    'product_organizations',
    'products'
  ] LOOP
    EXECUTE format('DROP POLICY IF EXISTS "Public read access" ON public.%I', t);
    EXECUTE format(
      'CREATE POLICY "Navigator team read access" ON public.%I
         FOR SELECT TO authenticated USING ((SELECT public.is_navigator_team()))',
      t
    );
  END LOOP;
END $$;

-- ─── Logged-in only ──────────────────────────────────────────
DROP POLICY IF EXISTS "Public read access" ON public.person_experience;
CREATE POLICY "Signed-in read access" ON public.person_experience
  FOR SELECT TO authenticated USING (true);
