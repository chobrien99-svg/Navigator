import { getAllFundingRounds } from "@/lib/queries";
import { FundingDashboard } from "./funding-dashboard";

export const dynamic = "force-dynamic";

export default async function FundingPage() {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  let rounds: any[] = [];
  let error: string | null = null;

  try {
    // Load the full 2000-2026 history. getAllFundingRounds pages through
    // Supabase's 1,000-row response cap; the limit is just a safety ceiling.
    rounds = await getAllFundingRounds({ limit: 20000 });
  } catch (e) {
    error = e instanceof Error ? e.message : "Failed to load funding data";
  }

  return <FundingDashboard rounds={rounds} error={error} />;
}
