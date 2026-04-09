import { getINovMembers } from "@/lib/queries";
import { ILabDashboard } from "../i-lab/ilab-dashboard";

export const dynamic = "force-dynamic";

export default async function INovPage() {
  let members: never[] = [];
  let error: string | null = null;

  try {
    const data = await getINovMembers();
    members = data as never[];
  } catch (e) {
    error = e instanceof Error ? e.message : "Failed to load i-Nov data";
  }

  return (
    <ILabDashboard
      members={members}
      error={error}
      title="i-Nov Laureates"
      description="Concours d'innovation i-Nov, run by Bpifrance and ADEME. Funds innovative projects with high economic potential for France, across themes like energy transition, digital health, and sustainable agriculture."
      officialUrl="https://www.bpifrance.fr/catalogue-offres/soutien-a-linnovation/concours-dinnovation-i-nov"
      icon="rocket_launch"
    />
  );
}
