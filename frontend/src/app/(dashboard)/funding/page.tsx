import { getAllFundingRounds } from "@/lib/queries";
import { FundingDashboard } from "./funding-dashboard";

export const dynamic = "force-dynamic";

export default async function FundingPage() {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  let rounds: any[] = [];
  let error: string | null = null;

  try {
    // Load the full 2020-2026 window (dated newest-first, so a plain limit
    // would otherwise drop the oldest in-range rounds).
    rounds = await getAllFundingRounds({ since: "2020-01-01", limit: 8000 });
  } catch (e) {
    error = e instanceof Error ? e.message : "Failed to load funding data";
  }

  return <FundingDashboard rounds={rounds} error={error} />;
}
