import { getFrenchTechNextMembers } from "@/lib/queries";
import { FrenchTechDashboard } from "./french-tech-dashboard";

export default async function FrenchTechNextPage() {
  let members: never[] = [];
  let error: string | null = null;

  try {
    const data = await getFrenchTechNextMembers();
    members = data as never[];
  } catch (e) {
    error = e instanceof Error ? e.message : "Failed to load program data";
  }

  return <FrenchTechDashboard members={members} error={error} />;
}
