import { getFrenchTechNextMembers } from "@/lib/queries";
import { FrenchTechBulletin } from "@/app/(dashboard)/programs/french-tech-next40-120/french-tech-bulletin";
import { buildBulletinData } from "@/app/(dashboard)/programs/french-tech-next40-120/cohort-transform";
import type { BulletinData } from "@/app/(dashboard)/programs/french-tech-next40-120/cohort-data";

export const dynamic = "force-dynamic";

export const metadata = {
  title: "French Tech Next 40/120 — Cohort Bulletin",
  robots: { index: false, follow: false },
};

// Chrome-free, link-free build of the French Tech Next 40/120 bulletin,
// intended to be iframed into the French Tech Journal (Ghost) site.
export default async function FrenchTechEmbedPage() {
  let data: BulletinData | null = null;
  let error: string | null = null;

  try {
    const rows = await getFrenchTechNextMembers();
    data = buildBulletinData(rows);
  } catch (e) {
    error = e instanceof Error ? e.message : "Failed to load French Tech cohort data";
  }

  return (
    <main
      style={{
        background: "var(--color-background)",
        minHeight: "100vh",
        overflowX: "auto",
      }}
    >
      <FrenchTechBulletin data={data} error={error} embed />
    </main>
  );
}
