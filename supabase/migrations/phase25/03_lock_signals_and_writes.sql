-- =============================================================================
-- Phase 25 follow-up (15 Oct 2026): lock down signals, career history,
-- profile edits and two open INSERT policies.
--
-- Already applied by hand in the Supabase SQL editor on 15 Oct 2026; this
-- file records it. Safe to re-run (every statement is idempotent).
--
-- Why
--   01 kept `signals` public and `person_experience` readable by any signed-in
--   account only because France AI Radar read them with the anon key / its
--   users' sessions. Since France-AI-Radar#66 (merged 15 Oct 2026) AI Radar
--   reads both server-side with its service-role key, which bypasses RLS, so
--   they can be Navigator-team only. No public site reads them (01's API-log
--   review: the deals databases and Navigator /embed + /api/public don't).
--
--   Still public, unchanged: organizations, people, organization_people (and
--   the other tables 01 lists) because the Q2/Q3 deals databases and
--   Navigator /embed + /api/public read them without a login.
--
--   profiles: "Users can update own profile" allowed any column, so any
--   signed-in user (e.g. a free AI Radar sign-up) could set their own
--   subscription_status / tier / is_admin through the API. is_admin also
--   gates every "Admins can ..." write policy, so this was a path to editing
--   the whole database. Users may now only update the fields AI Radar's
--   account page edits; everything else goes through the service role
--   (Stripe webhook, admin dashboards).
--
--   sectors, organization_events: INSERT was open to any signed-in user
--   (WITH CHECK true). Now admins only, like every other table.
--
-- Undo: 04_rollback_lock_signals_and_writes.sql
-- =============================================================================

-- ─── Signals and career history: Navigator team only ─────────
DROP POLICY IF EXISTS "Public read access" ON public.signals;
DROP POLICY IF EXISTS "Navigator team read access" ON public.signals;
CREATE POLICY "Navigator team read access" ON public.signals
  FOR SELECT TO authenticated USING ((SELECT public.is_navigator_team()));

DROP POLICY IF EXISTS "Signed-in read access" ON public.person_experience;
DROP POLICY IF EXISTS "Navigator team read access" ON public.person_experience;
CREATE POLICY "Navigator team read access" ON public.person_experience
  FOR SELECT TO authenticated USING ((SELECT public.is_navigator_team()));

-- ─── profiles: users may edit only their own basic details ───
-- (Profiles are created by the on_auth_user_created trigger, so users never
-- need INSERT.)
REVOKE UPDATE ON public.profiles FROM anon, authenticated;
GRANT UPDATE (full_name, title, company, user_type, updated_at)
  ON public.profiles TO authenticated;
REVOKE INSERT ON public.profiles FROM anon, authenticated;

-- ─── INSERT: admins only ─────────────────────────────────────
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON public.sectors;
DROP POLICY IF EXISTS "Admins can insert sectors" ON public.sectors;
CREATE POLICY "Admins can insert sectors" ON public.sectors
  FOR INSERT WITH CHECK (auth.uid() IN (SELECT id FROM public.profiles WHERE is_admin = true));

DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON public.organization_events;
DROP POLICY IF EXISTS "Admins can insert organization_events" ON public.organization_events;
CREATE POLICY "Admins can insert organization_events" ON public.organization_events
  FOR INSERT WITH CHECK (auth.uid() IN (SELECT id FROM public.profiles WHERE is_admin = true));

-- ─── Checks (run after; see expected results) ────────────────
-- 1. Profile columns users can edit → company, full_name, title, updated_at, user_type
--    SELECT column_name FROM information_schema.column_privileges
--    WHERE table_schema = 'public' AND table_name = 'profiles'
--      AND grantee = 'authenticated' AND privilege_type = 'UPDATE' ORDER BY 1;
-- 2. Write policies open to anyone → no rows
--    SELECT tablename, policyname, cmd FROM pg_policies
--    WHERE schemaname = 'public' AND cmd IN ('INSERT','UPDATE','DELETE','ALL')
--      AND coalesce(qual,'') IN ('true','') AND coalesce(with_check,'') IN ('true','');
