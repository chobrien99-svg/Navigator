-- =============================================================================
-- UNDO for 01_restrict_private_tables_to_navigator_team.sql.
-- Only run this if the restriction broke a site; it makes the tables public
-- again exactly as before.
--
-- Run 04_rollback_lock_signals_and_writes.sql FIRST: this file drops
-- is_navigator_team(), and since 03 the signals and person_experience
-- policies depend on it, so the DROP FUNCTION below would fail.
-- =============================================================================
DO $$
DECLARE
  t text;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'article_organizations', 'articles', 'grants', 'legal_entities',
    'organization_events', 'organization_profiles',
    'organization_relationships', 'organization_tags', 'patent_inventors',
    'patents', 'product_catalog', 'product_organizations', 'products'
  ] LOOP
    EXECUTE format('DROP POLICY IF EXISTS "Navigator team read access" ON public.%I', t);
    EXECUTE format('CREATE POLICY "Public read access" ON public.%I FOR SELECT USING (true)', t);
  END LOOP;
END $$;

DROP POLICY IF EXISTS "Signed-in read access" ON public.person_experience;
CREATE POLICY "Public read access" ON public.person_experience
  FOR SELECT USING (true);

DROP FUNCTION IF EXISTS public.is_navigator_team();
