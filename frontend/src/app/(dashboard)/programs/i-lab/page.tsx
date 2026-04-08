import { getILabMembers } from "@/lib/queries";
import { ILabDashboard } from "./ilab-dashboard";

export const dynamic = "force-dynamic";

export default async function ILabPage() {
  let members: never[] = [];
  let error: string | null = null;

  try {
    const data = await getILabMembers();
    members = data as never[];
  } catch (e) {
    error = e instanceof Error ? e.message : "Failed to load i-Lab data";
  }

  return <ILabDashboard members={members} error={error} />;
}
