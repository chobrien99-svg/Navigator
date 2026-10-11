import type { SupabaseClient } from "@supabase/supabase-js";

// Shared by the server home page (via queries.ts) and the browser admin page,
// so each can pass the Supabase client that fits where it runs.
export async function fetchDashboardStats(supabase: SupabaseClient) {
  const [orgCount, peopleCount, roundsCount] = await Promise.all([
    supabase.from("organizations").select("id", { count: "exact", head: true }),
    supabase.from("people").select("id", { count: "exact", head: true }),
    supabase.from("funding_rounds").select("id", { count: "exact", head: true }),
  ]);

  // Sum total raised
  const { data: fundingSum } = await supabase
    .from("funding_rounds")
    .select("amount_eur");

  const totalRaised =
    fundingSum?.reduce((sum, r) => sum + (r.amount_eur ?? 0), 0) ?? 0;

  return {
    organizations: orgCount.count ?? 0,
    people: peopleCount.count ?? 0,
    fundingRounds: roundsCount.count ?? 0,
    totalRaised,
  };
}
