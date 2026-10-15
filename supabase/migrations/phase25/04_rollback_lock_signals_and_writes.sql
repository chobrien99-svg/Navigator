-- =============================================================================
-- UNDO for 03_lock_signals_and_writes.sql. Restores the state 01 left.
--
-- Only the signals / person_experience part is a plausible thing to undo
-- (if a site turns out to read them without a login). Restoring the profiles
-- grants or the open INSERT policies re-opens the self-upgrade / admin hole
-- 03 closed, so those sections are commented out on purpose.
--
-- Run this BEFORE 02_rollback_restrict_private_tables.sql if you ever need to
-- undo phase 25 entirely: 02 drops is_navigator_team(), which the policies
-- created in 03 depend on.
-- =============================================================================

DROP POLICY IF EXISTS "Navigator team read access" ON public.signals;
DROP POLICY IF EXISTS "Public read access" ON public.signals;
CREATE POLICY "Public read access" ON public.signals FOR SELECT USING (true);

DROP POLICY IF EXISTS "Navigator team read access" ON public.person_experience;
DROP POLICY IF EXISTS "Signed-in read access" ON public.person_experience;
CREATE POLICY "Signed-in read access" ON public.person_experience
  FOR SELECT TO authenticated USING (true);

-- Deliberately not restored (security holes):
-- GRANT UPDATE, INSERT ON public.profiles TO authenticated;
-- CREATE POLICY "Enable insert for authenticated users only" ON public.sectors
--   FOR INSERT TO authenticated WITH CHECK (true);
-- CREATE POLICY "Enable insert for authenticated users only" ON public.organization_events
--   FOR INSERT TO authenticated WITH CHECK (true);
