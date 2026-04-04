import { getFrenchTechNextMembers } from "@/lib/queries";
import { FrenchTechDashboard } from "./french-tech-dashboard";

export default async function FrenchTechNextPage() {
  let members: Record<string, unknown>[] = [];
  let error: string | null = null;

  try {
    members = await getFrenchTechNextMembers();
  } catch (e) {
    error = e instanceof Error ? e.message : "Failed to load program data";
  }

  return <FrenchTechDashboard members={members as never[]} error={error} />;
}
