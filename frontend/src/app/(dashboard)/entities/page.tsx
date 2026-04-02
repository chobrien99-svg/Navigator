import Link from "next/link";
import { getOrganizations, formatEur } from "@/lib/queries";
import type { Organization } from "@/lib/types";

const typeLabels: Record<string, { label: string; color: string }> = {
  startup: { label: "Startup", color: "bg-primary/10 text-primary" },
  corporate: { label: "Corporate", color: "bg-primary/10 text-primary" },
  investor: { label: "Investor", color: "bg-secondary/10 text-secondary" },
  accelerator: {
    label: "Accelerator",
    color: "bg-secondary/10 text-secondary",
  },
  incubator: { label: "Incubator", color: "bg-secondary/10 text-secondary" },
  university: { label: "University", color: "bg-research/15 text-research" },
  research_lab: { label: "Research", color: "bg-research/15 text-research" },
  public_agency: {
    label: "Government",
    color: "bg-tertiary/10 text-tertiary",
  },
  nonprofit: { label: "Nonprofit", color: "bg-tertiary/10 text-tertiary" },
  media: { label: "Media", color: "bg-outline/10 text-outline" },
  other: {
    label: "Other",
    color: "bg-surface-container-high text-on-surface-variant",
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

export default async function EntitiesPage() {
  let organizations: Organization[] = [];
  let error: string | null = null;

  try {
    organizations = await getOrganizations();
  } catch (e) {
    error = e instanceof Error ? e.message : "Failed to load organizations";
  }

  return (
    <div className="px-10 py-8">
      {/* Page Header */}
      <div className="flex items-end justify-between">
        <div>
          <h1 className="font-headline text-3xl font-semibold tracking-tight text-primary">
            Entity Explorer
          </h1>
          <p className="mt-1 text-sm text-on-surface-variant">
            {organizations.length} entities in the intelligence network
          </p>
        </div>
      </div>

      {error && (
        <div className="mt-6 bg-error-container p-4 text-sm text-on-error-container">
          {error}
        </div>
      )}

      {/* Entity List */}
      <div className="mt-8 space-y-3">
        {organizations.map((org) => {
          const typeInfo = typeLabels[org.organization_type] ?? {
            label: org.organization_type,
            color: "bg-surface-container-high text-on-surface-variant",
          };
          return (
            <Link
              key={org.id}
              href={`/entities/${org.slug}`}
              className="group flex items-start gap-6 bg-surface-container-lowest p-6 transition-colors duration-200 hover:bg-surface-container-low"
            >
              {/* Left: Core Identity */}
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-3">
                  <h2 className="font-headline text-lg font-semibold text-on-surface group-hover:text-primary">
                    {org.name}
                  </h2>
                  <span
                    className={`shrink-0 px-2 py-0.5 text-xs font-semibold ${typeInfo.color}`}
                  >
                    {typeInfo.label}
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
                <p className="mt-1.5 max-w-2xl truncate text-sm leading-relaxed text-on-surface-variant">
                  {org.short_description ?? org.description ?? "—"}
                </p>
                <div className="mt-3 flex items-center gap-4 text-xs text-on-surface-variant">
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

              {/* Right: Key Metrics */}
              <div className="flex shrink-0 items-center gap-8 text-right">
                {org.last_round && (
                  <div>
                    <p className="diplomatic-label">Last Round</p>
                    <p className="mt-0.5 text-sm font-medium text-on-surface">
                      {org.last_round.replace(/_/g, " ")}
                    </p>
                  </div>
                )}
                <div>
                  <p className="diplomatic-label">Total Raised</p>
                  <p className="mt-0.5 text-sm font-medium text-on-surface">
                    {formatEur(org.total_raised_eur)}
                  </p>
                </div>
              </div>
            </Link>
          );
        })}

        {organizations.length === 0 && !error && (
          <div className="py-20 text-center">
            <p className="font-headline text-lg italic text-on-surface-variant">
              No entities found in the database yet.
            </p>
            <p className="mt-2 text-sm text-on-surface-variant">
              Data will appear here once migration is complete.
            </p>
          </div>
        )}
      </div>
    </div>
  );
}
