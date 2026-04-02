import Link from "next/link";
import { notFound } from "next/navigation";
import { queryMESR, DATASETS } from "@/lib/mesr";

interface GrantDetail {
  id: string;
  type: string | null;
  year: number | null;
  acronym: string | null;
  label: string | null;
  call: string | null;
  startdate: string | null;
  keywords: string | null;
  participantcount: number | null;
  participants: string | null;
}

function parseParticipants(raw: string | null) {
  if (!raw) return [];
  // Format: "name (Structure: id) | Role: x | Funding: y; name2 ..."
  // Actual format varies — try to parse structured text
  const entries = raw.split(/;\s*(?=[A-Z])/);
  return entries.map((entry) => {
    const structureMatch = entry.match(/\(Structure:\s*([^)]+)\)/);
    const roleMatch = entry.match(/Role:\s*([^|]+)/);
    const fundingMatch = entry.match(/Funding:\s*€?([\d,.]+)/);
    const nameMatch = entry.match(/^([^(|]+)/);
    return {
      name: nameMatch?.[1]?.trim() ?? entry.trim(),
      structureId: structureMatch?.[1]?.trim() ?? null,
      role: roleMatch?.[1]?.trim() ?? null,
      funding: fundingMatch?.[1]?.trim() ?? null,
    };
  });
}

export default async function GrantDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;

  let grant: GrantDetail | null = null;
  try {
    const res = await queryMESR<GrantDetail>(DATASETS.researchFunding, {
      where: `id = "${id}"`,
      limit: 1,
    });
    grant = res.results[0] ?? null;
  } catch {
    // fall through to notFound
  }

  if (!grant) notFound();

  const participants = parseParticipants(grant.participants);
  const keywords = grant.keywords
    ?.split(/[,;]/)
    .map((k) => k.trim())
    .filter(Boolean) ?? [];

  return (
    <div className="px-10 py-8">
      {/* Breadcrumb */}
      <div className="text-xs text-on-surface-variant">
        <Link href="/research" className="hover:text-on-surface">
          Research Intelligence
        </Link>
        <span className="mx-2">›</span>
        <span className="text-on-surface">
          {grant.acronym ?? grant.id}
        </span>
      </div>

      {/* Header */}
      <div className="mt-6 flex items-start justify-between">
        <div className="max-w-3xl">
          <p className="diplomatic-label">Research Grant</p>
          <h1 className="mt-2 font-headline text-4xl font-semibold tracking-tight text-on-surface">
            {grant.acronym ?? "Untitled Grant"}
          </h1>
          {grant.label && (
            <p className="mt-2 font-headline text-base italic text-on-surface-variant">
              {grant.label}
            </p>
          )}
        </div>
        <div className="text-right">
          {grant.type && (
            <span className="inline-block bg-primary px-3 py-1 text-xs font-semibold text-on-primary">
              {grant.type}
            </span>
          )}
        </div>
      </div>

      {/* Summary Bar */}
      <div className="mt-8 flex items-center gap-8 bg-surface-container-low px-6 py-4">
        <div>
          <span className="diplomatic-label">Year</span>
          <span className="ml-2 text-sm text-on-surface">
            {grant.year ?? "—"}
          </span>
        </div>
        <div>
          <span className="diplomatic-label">Start Date</span>
          <span className="ml-2 text-sm text-on-surface">
            {grant.startdate
              ? new Date(grant.startdate).toLocaleDateString("en-GB", {
                  day: "numeric",
                  month: "long",
                  year: "numeric",
                })
              : "—"}
          </span>
        </div>
        {grant.call && (
          <div>
            <span className="diplomatic-label">Call</span>
            <span className="ml-2 text-sm text-on-surface">{grant.call}</span>
          </div>
        )}
        <div>
          <span className="diplomatic-label">Participants</span>
          <span className="ml-2 text-sm text-on-surface">
            {grant.participantcount ?? participants.length}
          </span>
        </div>
      </div>

      {/* Main Content */}
      <div className="mt-10 grid grid-cols-5 gap-10">
        {/* Left: Participants */}
        <div className="col-span-3">
          <h2 className="diplomatic-label mb-4">
            Participants & Funding Allocation
          </h2>
          {participants.length > 0 ? (
            <div className="space-y-3">
              {participants.map((p, i) => (
                <div
                  key={i}
                  className="flex items-start justify-between bg-surface-container-lowest p-5"
                >
                  <div className="flex-1">
                    <p className="text-sm font-medium text-on-surface">
                      {p.name}
                    </p>
                    <div className="mt-1 flex items-center gap-3 text-xs text-on-surface-variant">
                      {p.role && (
                        <span
                          className={
                            p.role === "Coordinator"
                              ? "bg-primary/10 px-1.5 py-0.5 text-primary font-semibold"
                              : ""
                          }
                        >
                          {p.role}
                        </span>
                      )}
                      {p.structureId && (
                        <span>Structure: {p.structureId}</span>
                      )}
                    </div>
                  </div>
                  {p.funding && (
                    <div className="text-right">
                      <p className="text-sm font-medium text-primary">
                        €{p.funding}
                      </p>
                    </div>
                  )}
                </div>
              ))}
            </div>
          ) : (
            <div className="bg-surface-container-low p-6">
              <p className="text-sm text-on-surface-variant">
                Participant details are encoded in the raw data format.
                Full participant breakdown is available via the scanR platform.
              </p>
              {grant.participants && (
                <p className="mt-3 text-xs leading-relaxed text-outline">
                  {grant.participants}
                </p>
              )}
            </div>
          )}
        </div>

        {/* Right: Keywords & Meta */}
        <div className="col-span-2 space-y-8">
          {/* Keywords */}
          {keywords.length > 0 && (
            <section>
              <h2 className="diplomatic-label mb-3">Research Keywords</h2>
              <div className="flex flex-wrap gap-2">
                {keywords.map((kw) => (
                  <span
                    key={kw}
                    className="bg-primary-fixed/60 px-2.5 py-1 text-xs font-medium text-on-primary-fixed"
                  >
                    {kw}
                  </span>
                ))}
              </div>
            </section>
          )}

          {/* Links */}
          <section className="bg-surface-container-low p-6">
            <h2 className="diplomatic-label mb-3">External Links</h2>
            <div className="space-y-2">
              <a
                href={`https://scanr.enseignementsup-recherche.gouv.fr/financement/${grant.id}`}
                target="_blank"
                rel="noopener noreferrer"
                className="flex items-center gap-2 text-sm text-primary hover:underline"
              >
                <span className="material-symbols-outlined text-[16px]">
                  open_in_new
                </span>
                View on scanR
              </a>
              {grant.type === "H2020" && (
                <a
                  href={`https://cordis.europa.eu/project/id/${grant.id}`}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="flex items-center gap-2 text-sm text-primary hover:underline"
                >
                  <span className="material-symbols-outlined text-[16px]">
                    open_in_new
                  </span>
                  View on CORDIS (EU)
                </a>
              )}
            </div>
          </section>

          {/* Data Source */}
          <section>
            <p className="text-xs leading-relaxed text-on-surface-variant">
              Data sourced from the Ministère de l&apos;Enseignement supérieur,
              de la Recherche et de l&apos;Espace open data platform via
              the scanR research funding export.
            </p>
          </section>
        </div>
      </div>
    </div>
  );
}
