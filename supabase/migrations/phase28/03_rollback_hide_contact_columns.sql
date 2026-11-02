-- =============================================================================
-- Undo 02_hide_contact_columns.sql (and 01_contact_lookup.sql).
--
-- Gives anon and authenticated back full read access to people and
-- organizations, including email and phone, as before phase 28.
-- Drop the functions only if the frontend no longer calls them (lib/contact.ts);
-- otherwise run just the GRANT lines.
-- =============================================================================

BEGIN;
GRANT SELECT ON public.people TO anon, authenticated;
GRANT SELECT ON public.organizations TO anon, authenticated;
COMMIT;

-- DROP FUNCTION IF EXISTS public.get_person_email(uuid);
-- DROP FUNCTION IF EXISTS public.get_organization_contact(uuid);
