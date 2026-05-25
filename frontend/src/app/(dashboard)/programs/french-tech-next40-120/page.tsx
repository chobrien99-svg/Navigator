import { getFrenchTechNextMembers } from "@/lib/queries";
import { FrenchTechBulletin } from "./french-tech-bulletin";
import { buildBulletinData } from "./cohort-transform";
import type { BulletinData } from "./cohort-data";

export const dynamic = "force-dynamic";

export const metadata = {
  title: "French Tech Next 40/120 — Cohort Bulletin | The Navigator",
};

export default async function FrenchTechNextPage() {
  let data: BulletinData | null = null;
  let error: string | null = null;

  try {
    const rows = await getFrenchTechNextMembers();
    data = buildBulletinData(rows);
  } catch (e) {
    error = e instanceof Error ? e.message : "Failed to load French Tech cohort data";
  }

  return <FrenchTechBulletin data={data} error={error} />;
}
