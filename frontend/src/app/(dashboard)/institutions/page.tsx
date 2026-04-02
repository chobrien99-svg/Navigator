import {
  getInstitutions,
  getInstitutionStats,
  getResearchStructures,
  getResearchStructureStats,
} from "@/lib/mesr";
import { InstitutionsDashboard } from "./institutions-dashboard";

export default async function InstitutionsPage() {
  let institutions: Record<string, unknown>[] = [];
  let labs: Record<string, unknown>[] = [];
  let instStats = { total: 0, byType: [], byRegion: [] } as Record<string, unknown>;
  let labStats = { total: 0, byDomain: [] } as Record<string, unknown>;
  let error: string | null = null;

  try {
    const [instData, labData, iStats, lStats] = await Promise.all([
      getInstitutions({ limit: 100 }),
      getResearchStructures({ limit: 100 }),
      getInstitutionStats(),
      getResearchStructureStats(),
    ]);
    institutions = instData.results as unknown as Record<string, unknown>[];
    labs = labData.results as unknown as Record<string, unknown>[];
    instStats = iStats as unknown as Record<string, unknown>;
    labStats = lStats as unknown as Record<string, unknown>;
  } catch (e) {
    error = e instanceof Error ? e.message : "Failed to load data from MESR";
  }

  return (
    <InstitutionsDashboard
      institutions={institutions}
      labs={labs}
      instStats={instStats}
      labStats={labStats}
      error={error}
    />
  );
}
