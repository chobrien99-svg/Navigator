import Link from "next/link";
import { getFrenchTechNextMembers, formatEurFromDb } from "@/lib/queries";
import type { ProgramOrganization, Organization } from "@/lib/types";

const groupLabels: Record<string, { label: string; color: string }> = {
  "Next 40": {
    label: "Next 40",
    color: "bg-primary/15 text-primary",
  },
  "FT 120": {
    label: "FT 120",
    color: "bg-secondary/10 text-secondary",
  },
};

function getPrimarySector(org: Organization): string {
  const sectors = org.organization_sectors ?? [];
  const primary = sectors.find((s) => s.is_primary);
  const sector = primary ?? sectors[0];
  return sector?.sectors?.name ?? "—";
}

function getCityName(org: Organization): string {
  return (org.cities as { name: string } | null)?.name ?? org.country ?? "—";
}

function getYear(entry: ProgramOrganization): number {
  return entry.program_editions?.year ?? 0;
}

function getGroupLabel(entry: ProgramOrganization): string {
  return entry.group_label ?? "—";
}

export default async function FrenchTechNextPage() {
  let members: ProgramOrganization[] = [];
  let error: string | null = null;

  try {
    members = await getFrenchTechNextMembers();
  } catch (e) {
    error = e instanceof Error ? e.message : "Failed to load program data";
  }

  // Group by year
  const byYear = new Map<number, ProgramOrganization[]>();
  for (const m of members) {
    const year = getYear(m);
    const list = byYear.get(year) ?? [];
    list.push(m);
    byYear.set(year, list);
  }
  const years = Array.from(byYear.keys()).sort((a, b) => b - a);

  // Unique companies count
  const uniqueOrgIds = new Set(members.map((m) => m.organization_id));

  return (
    <div className="px-10 py-8">
      {/* Page Header */}
      <div className="flex items-end justify-between">
        <div>
          <div className="flex items-center gap-3">
            <h1 className="font-headline text-3xl font-semibold tracking-tight text-primary">
              French Tech Next 40/120
            </h1>
          </div>
          <p className="mt-1 max-w-2xl text-sm leading-relaxed text-on-surface-variant">
            The French government&apos;s flagship program highlighting the
            nation&apos;s most promising and high-growth tech companies. The{" "}
            <strong>Next 40</strong> recognizes the top-tier scale-ups, while the{" "}
            <strong>FT 120</strong> captures the broader cohort of rising
            champions.
          </p>
          <div className="mt-3 flex items-center gap-6 text-xs text-on-surface-variant">
            <span>
              <strong className="text-on-surface">{uniqueOrgIds.size}</strong>{" "}
              companies tracked
            </span>
            <span className="text-outline-variant">·</span>
            <span>
              <strong className="text-on-surface">{years.length}</strong>{" "}
              cohort {years.length === 1 ? "year" : "years"}
            </span>
            <span className="text-outline-variant">·</span>
            <a
              href="https://lafrenchtech.gouv.fr/fr/programme/french-tech-next-40-120/"
              target="_blank"
              rel="noopener noreferrer"
              className="text-primary hover:underline"
            >
              Official program page ↗
            </a>
          </div>
        </div>
      </div>

      {error && (
        <div className="mt-6 bg-error-container p-4 text-sm text-on-error-container">
          {error}
        </div>
      )}

      {/* Cohort Years */}
      {years.map((year) => {
        const cohort = byYear.get(year) ?? [];
        const next40 = cohort.filter((m) => getGroupLabel(m) === "Next 40");
        const ft120 = cohort.filter((m) => getGroupLabel(m) === "FT 120");

        return (
          <div key={year} className="mt-10">
            <div className="flex items-center gap-4 border-b border-outline-variant/20 pb-3">
              <h2 className="font-headline text-xl font-semibold text-on-surface">
                {year}
              </h2>
              <span className="text-xs text-on-surface-variant">
                {cohort.length} {cohort.length === 1 ? "company" : "companies"}
              </span>
              {next40.length > 0 && (
                <span className="px-2 py-0.5 text-xs font-semibold bg-primary/15 text-primary">
                  {next40.length} Next 40
                </span>
              )}
              {ft120.length > 0 && (
                <span className="px-2 py-0.5 text-xs font-semibold bg-secondary/10 text-secondary">
                  {ft120.length} FT 120
                </span>
              )}
            </div>

            <div className="mt-4 space-y-3">
              {cohort
                .sort((a, b) => {
                  // Next 40 first, then alphabetical
                  const aIsNext40 = getGroupLabel(a) === "Next 40";
                  const bIsNext40 = getGroupLabel(b) === "Next 40";
                  if (aIsNext40 && !bIsNext40) return -1;
                  if (!aIsNext40 && bIsNext40) return 1;
                  const nameA = a.organizations?.name ?? "";
                  const nameB = b.organizations?.name ?? "";
                  return nameA.localeCompare(nameB);
                })
                .map((entry) => {
                  const org = entry.organizations;
                  if (!org) return null;
                  const label = getGroupLabel(entry);
                  const labelInfo = groupLabels[label] ?? {
                    label,
                    color:
                      "bg-surface-container-high text-on-surface-variant",
                  };

                  return (
                    <Link
                      key={entry.id}
                      href={`/entities/${org.slug}`}
                      className="group flex items-start gap-6 bg-surface-container-lowest p-5 transition-colors duration-200 hover:bg-surface-container-low"
                    >
                      {/* Left: Identity */}
                      <div className="flex-1 min-w-0">
                        <div className="flex items-center gap-3">
                          <h3 className="font-headline text-base font-semibold text-on-surface group-hover:text-primary">
                            {org.name}
                          </h3>
                          <span
                            className={`shrink-0 px-2 py-0.5 text-xs font-semibold ${labelInfo.color}`}
                          >
                            {labelInfo.label}
                          </span>
                          <span
                            className={`shrink-0 px-1.5 py-0.5 text-[0.6rem] font-semibold ${
                              org.status === "active"
                                ? "bg-secondary/10 text-secondary"
                                : "bg-outline/10 text-outline"
                            }`}
                          >
                            {org.status}
                          </span>
                        </div>
                        <p className="mt-1 max-w-2xl truncate text-sm leading-relaxed text-on-surface-variant">
                          {org.short_description ?? org.description ?? "—"}
                        </p>
                        <div className="mt-2 flex items-center gap-4 text-xs text-on-surface-variant">
                          <span>{getCityName(org)}</span>
                          <span className="text-outline-variant">·</span>
                          <span>{getPrimarySector(org)}</span>
                          {org.employee_range && (
                            <>
                              <span className="text-outline-variant">·</span>
                              <span>{org.employee_range} employees</span>
                            </>
                          )}
                          {org.founded_year && (
                            <>
                              <span className="text-outline-variant">·</span>
                              <span>Founded {org.founded_year}</span>
                            </>
                          )}
                        </div>
                      </div>

                      {/* Right: Metrics */}
                      <div className="flex shrink-0 items-center gap-8 text-right">
                        <div>
                          <p className="diplomatic-label">Total Raised</p>
                          <p className="mt-0.5 text-sm font-medium text-on-surface">
                            {formatEurFromDb(org.total_raised_eur)}
                          </p>
                        </div>
                      </div>
                    </Link>
                  );
                })}
            </div>
          </div>
        );
      })}

      {members.length === 0 && !error && (
        <div className="mt-16 py-20 text-center">
          <span className="material-symbols-outlined text-5xl text-on-surface-variant/40">
            emoji_events
          </span>
          <p className="mt-4 font-headline text-lg italic text-on-surface-variant">
            No French Tech Next 40/120 data imported yet.
          </p>
          <p className="mt-2 text-sm text-on-surface-variant">
            Companies will appear here once cohort data is added via program
            editions and program organizations.
          </p>
        </div>
      )}
    </div>
  );
}
