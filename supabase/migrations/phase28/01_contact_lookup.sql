-- =============================================================================
-- Email and phone lookups for the Navigator team.
--
-- people.email, organizations.email and organizations.phone can currently be
-- read by anyone holding the public anon key (policy "Public read access",
-- USING true). 02_hide_contact_columns.sql takes those columns away from the
-- anon and authenticated roles. Since any France AI Radar subscriber is
-- "authenticated" too, the team needs another way to read them: these two
-- functions return the values only when is_navigator_team() is true, and
-- nothing for anyone else.
--
-- Used by frontend/src/lib/contact.ts.
-- Additive only, safe to run twice. Apply BEFORE deploying the frontend
-- change that calls them, and before 02_hide_contact_columns.sql.
-- Undo: 03_rollback_hide_contact_columns.sql (drops these too).
-- =============================================================================

CREATE OR REPLACE FUNCTION public.get_person_email(p_person_id uuid)
RETURNS text
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path TO ''
AS $$
  SELECT p.email
  FROM public.people p
  WHERE p.id = p_person_id
    AND (SELECT public.is_navigator_team());
$$;

CREATE OR REPLACE FUNCTION public.get_organization_contact(p_organization_id uuid)
RETURNS TABLE (email text, phone text)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path TO ''
AS $$
  SELECT o.email, o.phone
  FROM public.organizations o
  WHERE o.id = p_organization_id
    AND (SELECT public.is_navigator_team());
$$;

-- Signed-in users only (the team check happens inside).
REVOKE EXECUTE ON FUNCTION public.get_person_email(uuid) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION public.get_organization_contact(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.get_person_email(uuid) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.get_organization_contact(uuid) TO authenticated, service_role;
