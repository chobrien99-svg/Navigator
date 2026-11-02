import type { SupabaseClient } from "@supabase/supabase-js";

// Email and phone numbers, for the Navigator team only.
//
// These columns can't be read directly (see lib/columns.ts). The two
// database functions below return them only when the signed-in user is on
// the Navigator team (is_navigator_team(): a confirmed @frenchtechjournal.com
// address); for anyone else they return nothing.
// Defined in supabase/migrations/phase28/01_contact_lookup.sql.
//
// Pass the client that acts as the signed-in user: the server client from
// ./supabase-server in server components, or the one from ./supabase in the
// browser. Saving email and phone (insert/update) works as before.

export async function getPersonEmail(
  supabase: SupabaseClient,
  personId: string
): Promise<string | null> {
  const { data, error } = await supabase.rpc("get_person_email", {
    p_person_id: personId,
  });
  if (error) {
    console.error("[contact] get_person_email failed:", error.message);
    return null;
  }
  return (data as string | null) ?? null;
}

export async function getOrganizationContact(
  supabase: SupabaseClient,
  organizationId: string
): Promise<{ email: string | null; phone: string | null }> {
  const { data, error } = await supabase.rpc("get_organization_contact", {
    p_organization_id: organizationId,
  });
  if (error) {
    console.error("[contact] get_organization_contact failed:", error.message);
    return { email: null, phone: null };
  }
  const row = (Array.isArray(data) ? data[0] : data) as
    | { email: string | null; phone: string | null }
    | undefined;
  return { email: row?.email ?? null, phone: row?.phone ?? null };
}
