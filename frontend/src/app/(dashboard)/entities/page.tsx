import Link from "next/link";

// Mock data — will be replaced with Supabase queries
const mockOrganizations = [
  {
    slug: "novamind-ai",
    name: "NovaMind AI",
    type: "startup",
    description:
      "Advanced Neural Architectures for Sovereignty-First Industrial Intelligence.",
    city: "Paris",
    sector: "Artificial Intelligence",
    stage: "Seed / Active",
    totalRaised: "€3.2M",
    employees: "12",
    status: "active",
    sovereigntyScore: 85,
  },
  {
    slug: "mistral-ai",
    name: "Mistral AI",
    type: "startup",
    description:
      "Leading foundational model architecture. Direct route to Inria/DeepMind heritage.",
    city: "Paris",
    sector: "Artificial Intelligence",
    stage: "Series B",
    totalRaised: "€528M",
    employees: "60",
    status: "active",
    sovereigntyScore: 92,
  },
  {
    slug: "inria-saclay",
    name: "Inria Saclay",
    type: "research_lab",
    description:
      "National Institute for Research in Digital Science and Technology. Scikit-learn Consortium.",
    city: "Saclay",
    sector: "Research & Academia",
    stage: "—",
    totalRaised: "—",
    employees: "1,800",
    status: "active",
    sovereigntyScore: 95,
  },
  {
    slug: "bpifrance",
    name: "Bpifrance",
    type: "investor",
    description:
      "France's public investment bank acting as the primary vehicle for France 2030 deep-tech mobilization.",
    city: "Maisons-Alfort",
    sector: "Public Finance",
    stage: "—",
    totalRaised: "—",
    employees: "3,500",
    status: "active",
    sovereigntyScore: 98,
  },
  {
    slug: "elaia-partners",
    name: "Elaia Partners",
    type: "investor",
    description:
      "Lead Aero-Digital Corridor VC. Deep-tech first, sovereignty aligned.",
    city: "Paris",
    sector: "Venture Capital",
    stage: "—",
    totalRaised: "—",
    employees: "30",
    status: "active",
    sovereigntyScore: 78,
  },
];

const typeLabels: Record<string, { label: string; color: string }> = {
  startup: { label: "Startup", color: "bg-primary/10 text-primary" },
  corporate: { label: "Corporate", color: "bg-primary/10 text-primary" },
  investor: { label: "Investor", color: "bg-secondary/10 text-secondary" },
  research_lab: { label: "Research", color: "bg-research/15 text-research" },
  public_agency: {
    label: "Government",
    color: "bg-tertiary/10 text-tertiary",
  },
};

export default function EntitiesPage() {
  return (
    <div className="px-10 py-8">
      {/* Page Header */}
      <div className="flex items-end justify-between">
        <div>
          <h1 className="font-headline text-3xl font-semibold tracking-tight text-primary">
            Entity Explorer
          </h1>
          <p className="mt-1 text-sm text-on-surface-variant">
            {mockOrganizations.length} entities in the intelligence network
          </p>
        </div>

        {/* Filter Bar */}
        <div className="flex items-center gap-3">
          <button
            type="button"
            className="flex items-center gap-2 bg-surface-container-low px-3 py-2 text-sm text-on-surface-variant transition-colors duration-200 hover:bg-surface-container"
          >
            <span className="material-symbols-outlined text-[16px]">
              filter_list
            </span>
            Filters
          </button>
          <select className="border-b border-outline-variant/25 bg-transparent py-2 pr-8 text-sm text-on-surface focus:border-primary focus:outline-none">
            <option>All Types</option>
            <option>Startups</option>
            <option>Investors</option>
            <option>Research Labs</option>
            <option>Government</option>
          </select>
          <select className="border-b border-outline-variant/25 bg-transparent py-2 pr-8 text-sm text-on-surface focus:border-primary focus:outline-none">
            <option>All Sectors</option>
            <option>Artificial Intelligence</option>
            <option>DeepTech</option>
            <option>Life Sciences</option>
            <option>Quantum</option>
          </select>
        </div>
      </div>

      {/* Entity List */}
      <div className="mt-8 space-y-3">
        {mockOrganizations.map((org) => {
          const typeInfo = typeLabels[org.type] ?? {
            label: org.type,
            color: "bg-surface-container-high text-on-surface-variant",
          };
          return (
            <Link
              key={org.slug}
              href={`/entities/${org.slug}`}
              className="group flex items-start gap-6 bg-surface-container-lowest p-6 transition-colors duration-200 hover:bg-surface-container-low"
            >
              {/* Left: Core Identity */}
              <div className="flex-1">
                <div className="flex items-center gap-3">
                  <h2 className="font-headline text-lg font-semibold text-on-surface group-hover:text-primary">
                    {org.name}
                  </h2>
                  <span
                    className={`px-2 py-0.5 text-xs font-semibold ${typeInfo.color}`}
                  >
                    {typeInfo.label}
                  </span>
                </div>
                <p className="mt-1.5 max-w-2xl text-sm leading-relaxed text-on-surface-variant">
                  {org.description}
                </p>
                <div className="mt-3 flex items-center gap-4 text-xs text-on-surface-variant">
                  <span>{org.city}</span>
                  <span className="text-outline-variant">·</span>
                  <span>{org.sector}</span>
                  <span className="text-outline-variant">·</span>
                  <span>{org.employees} employees</span>
                </div>
              </div>

              {/* Right: Key Metrics */}
              <div className="flex shrink-0 items-center gap-8 text-right">
                <div>
                  <p className="diplomatic-label">Stage</p>
                  <p className="mt-0.5 text-sm font-medium text-on-surface">
                    {org.stage}
                  </p>
                </div>
                <div>
                  <p className="diplomatic-label">Total Raised</p>
                  <p className="mt-0.5 text-sm font-medium text-on-surface">
                    {org.totalRaised}
                  </p>
                </div>
                <div>
                  <p className="diplomatic-label">Score</p>
                  <p className="mt-0.5 font-headline text-lg font-semibold text-primary">
                    {org.sovereigntyScore}
                    <span className="text-xs font-normal text-on-surface-variant">
                      /100
                    </span>
                  </p>
                </div>
              </div>
            </Link>
          );
        })}
      </div>
    </div>
  );
}
