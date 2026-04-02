import Link from "next/link";
import { getDashboardStats, getOrganizations, formatEur } from "@/lib/queries";

export default async function EcosystemAtlas() {
  let stats = { organizations: 0, people: 0, fundingRounds: 0, totalRaised: 0 };
  let recentOrgs: { name: string; slug: string; organization_type: string }[] =
    [];

  try {
    stats = await getDashboardStats();
  } catch {
    // Stats will show zeros
  }
  try {
    const orgs = await getOrganizations({ limit: 5 });
    recentOrgs = orgs.map((o) => ({
      name: o.name,
      slug: o.slug,
      organization_type: o.organization_type,
    }));
  } catch {
    // Will show empty
  }

  return (
    <div className="px-10 py-8">
      {/* Hero Header */}
      <div className="flex items-start justify-between">
        <div className="max-w-xl">
          <h1 className="font-headline text-4xl font-semibold tracking-tight text-primary">
            The Ecosystem Atlas
          </h1>
          <p className="mt-3 font-headline text-lg italic text-on-surface-variant">
            Macro-view of the French Innovation Landscape · Updated Real-time
          </p>
        </div>

        {/* Key Metrics */}
        <div className="flex gap-10">
          <div className="text-right">
            <p className="diplomatic-label">Capital Tracked</p>
            <p className="font-headline text-3xl font-semibold tracking-tight text-on-surface">
              {formatEur(stats.totalRaised)}
            </p>
          </div>
          <div className="text-right">
            <p className="diplomatic-label">Entities</p>
            <p className="font-headline text-3xl font-semibold tracking-tight text-on-surface">
              {stats.organizations.toLocaleString()}
            </p>
          </div>
          <div className="text-right">
            <p className="diplomatic-label">People</p>
            <p className="font-headline text-3xl font-semibold tracking-tight text-on-surface">
              {stats.people.toLocaleString()}
            </p>
          </div>
          <div className="text-right">
            <p className="diplomatic-label">Funding Rounds</p>
            <p className="font-headline text-3xl font-semibold tracking-tight text-on-surface">
              {stats.fundingRounds.toLocaleString()}
            </p>
          </div>
        </div>
      </div>

      {/* Content Grid */}
      <div className="mt-12 grid grid-cols-3 gap-8">
        {/* Main area */}
        <div className="col-span-2 bg-surface-container-low p-8">
          <h2 className="diplomatic-label mb-6">Sector Clusters</h2>
          <div className="flex min-h-[400px] items-center justify-center text-on-surface-variant">
            <p className="font-headline text-lg italic">
              Cluster visualization will render here
            </p>
          </div>
        </div>

        {/* Quick access card */}
        <div className="space-y-6">
          {/* Quick Nav */}
          <div className="bg-surface-container-lowest p-6 ambient-shadow">
            <h3 className="diplomatic-label mb-4">Quick Access</h3>
            <div className="space-y-2">
              <Link
                href="/entities"
                className="flex items-center gap-3 py-2 text-sm text-on-surface transition-colors hover:text-primary"
              >
                <span className="material-symbols-outlined text-[18px]">
                  domain
                </span>
                Browse All Entities
              </Link>
              <Link
                href="/people"
                className="flex items-center gap-3 py-2 text-sm text-on-surface transition-colors hover:text-primary"
              >
                <span className="material-symbols-outlined text-[18px]">
                  person
                </span>
                Browse People
              </Link>
              <Link
                href="/funding"
                className="flex items-center gap-3 py-2 text-sm text-on-surface transition-colors hover:text-primary"
              >
                <span className="material-symbols-outlined text-[18px]">
                  payments
                </span>
                Funding Tracker
              </Link>
            </div>
          </div>

          {/* Recent Entities */}
          {recentOrgs.length > 0 && (
            <div className="bg-surface-container-lowest p-6 ambient-shadow">
              <h3 className="diplomatic-label mb-4">Recent Entities</h3>
              <div className="space-y-2">
                {recentOrgs.map((org) => (
                  <Link
                    key={org.slug}
                    href={`/entities/${org.slug}`}
                    className="flex items-center justify-between py-1.5 text-sm text-on-surface transition-colors hover:text-primary"
                  >
                    <span>{org.name}</span>
                    <span className="text-[0.6rem] text-on-surface-variant">
                      {org.organization_type.replace(/_/g, " ")}
                    </span>
                  </Link>
                ))}
              </div>
            </div>
          )}
        </div>
      </div>

      {/* Legend */}
      <div className="mt-10">
        <h3 className="font-headline text-base italic text-on-surface">
          Cartography Legend
        </h3>
        <div className="mt-3 flex gap-6">
          <div className="flex items-center gap-2">
            <span className="inline-block h-2.5 w-2.5 bg-primary" />
            <span className="text-xs text-on-surface-variant">
              Information Technology
            </span>
          </div>
          <div className="flex items-center gap-2">
            <span className="inline-block h-2.5 w-2.5 bg-secondary" />
            <span className="text-xs text-on-surface-variant">
              Natural Sciences
            </span>
          </div>
          <div className="flex items-center gap-2">
            <span className="inline-block h-2.5 w-2.5 bg-tertiary" />
            <span className="text-xs text-on-surface-variant">
              Industrial DeepTech
            </span>
          </div>
        </div>
      </div>
    </div>
  );
}
