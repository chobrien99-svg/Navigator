import { notFound } from "next/navigation";
import { getFrenchTechNextMembers } from "@/lib/queries";
import { FrenchTechBulletin } from "../french-tech-bulletin";
import { buildBulletinData, buildEditionIndex } from "../cohort-transform";

export const dynamic = "force-dynamic";

export async function generateMetadata({ params }: { params: Promise<{ year: string }> }) {
  const { year } = await params;
  return { title: `French Tech Next 40/120 — ${year} Edition | The Navigator` };
}

export default async function FrenchTechEditionPage({
  params,
}: {
  params: Promise<{ year: string }>;
}) {
  const { year } = await params;
  const targetYear = Number(year);

  let rows;
  try {
    rows = await getFrenchTechNextMembers();
  } catch (e) {
    const error = e instanceof Error ? e.message : "Failed to load French Tech cohort data";
    return <FrenchTechBulletin data={null} error={error} />;
  }

  const editions = buildEditionIndex(rows);
  const match = editions.find((ed) => ed.year === targetYear);
  if (!Number.isInteger(targetYear) || !match) notFound();

  const data = buildBulletinData(rows, targetYear);

  return (
    <FrenchTechBulletin
      data={data}
      archiveHref="/programs/french-tech-next40-120/archive"
      isHistoric={!match.current}
    />
  );
}
