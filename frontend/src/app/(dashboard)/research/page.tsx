import {
  getResearchFunding,
  getILabLaureates,
  getCirApproved,
  getFundingStats,
} from "@/lib/mesr";
import { ResearchDashboard } from "./research-dashboard";

export default async function ResearchPage() {
  let funding: Record<string, unknown>[] = [];
  let ilab: Record<string, unknown>[] = [];
  let cir: Record<string, unknown>[] = [];
  let fundingStats = { total: 0, byType: [], byYear: [] } as Record<string, unknown>;
  let error: string | null = null;

  try {
    const [fundingData, ilabData, cirData, fStats] = await Promise.all([
      getResearchFunding({ limit: 100 }),
      getILabLaureates({ limit: 100 }),
      getCirApproved({ limit: 100 }),
      getFundingStats(),
    ]);
    funding = fundingData.results as unknown as Record<string, unknown>[];
    ilab = ilabData.results as unknown as Record<string, unknown>[];
    cir = cirData.results as unknown as Record<string, unknown>[];
    fundingStats = fStats as unknown as Record<string, unknown>;
  } catch (e) {
    error = e instanceof Error ? e.message : "Failed to load research data";
  }

  return (
    <ResearchDashboard
      funding={funding}
      ilab={ilab}
      cir={cir}
      fundingStats={fundingStats}
      error={error}
    />
  );
}
