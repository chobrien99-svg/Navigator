// Entity Dossier — Company/Organization detail page
// Matches design: screen.png / screen2.png

const mockEntity = {
  name: "NovaMind AI",
  type: "startup",
  status: "Seed / Active",
  description:
    "Advanced Neural Architectures for Sovereignty-First Industrial Intelligence.",
  longDescription:
    "NovaMind AI represents a strategic push in French-origin research, transforming France's expertise in high-capacity ML-first stack toward sovereignty-first industrial automation.",
  city: "Paris",
  sector: "Artificial Intelligence",
  subsector: "AI Agents",
  founded: "2024",
  employees: "12",
  fte: "84 FTE",
  sovereigntyScore: 85,
  origin: "ENS Paris-Saclay",
  innovationScore: 0.94,
  sovereigntyGrade: "A+",
  structuralDna: {
    legalStatus: "SAS · RCS Nanterre Q2 2024",
    founders: "Raphael K. Pierre / Manon de S.",
    governanceNote: "BPIFRANCE INTELLIGENCE FUND (20% cap-structured)",
  },
  fundingLineage: [
    {
      name: "Bpifrance i-Nov Grant",
      type: "Innovation/Sovereignty Fund",
      amount: "€3,254",
      date: "Oct 2023",
    },
    {
      name: "Seed Round: Elaia Partners",
      type: "Lead Aero-Digital Corridor",
      amount: "€6,316",
      date: "Feb 2024",
    },
    {
      name: "French Tech Seed",
      type: "Label BKP Initiative",
      amount: "€3,096",
      date: "May 2022",
    },
  ],
  institutionalContext: [
    {
      label: "Strategic Domain",
      title: "Industrial Autonomy",
      description:
        "Deploying transformer-based logic to manufacturing cycles, reducing latency in decision-making by 40% compared to traditional cloud architectures.",
    },
    {
      label: "Academic Pioneer",
      title: "Saclay Ecosystem",
      description:
        'Saclay hosts two High-Performance Computing clusters ("Fusion Saclay"), maintaining active IP sharing with CNRS. First-mile architecture.',
    },
    {
      label: "Sovereignty Field",
      title: "Defense Tier 2",
      description:
        "Identified as a critical technology provider for the DEED: Sovereignty AI, Defense, focusing on air-pipeline hardware-agnostic deployments.",
    },
  ],
  networkRelations: [
    { type: "Academic Anchor", detail: "Inria Scikit-learn Consortium" },
    { type: "Capital Injection Series AI", detail: "Elaia Partners — Cx3M Lead" },
  ],
  coreCapabilities: [
    "Low-Latency Symbolic Reasoning",
    "Private Data Enclave Training",
    "Multi-Agent Orchestration",
  ],
};

export default async function EntityDossierPage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;

  return (
    <div className="px-10 py-8">
      {/* Breadcrumb */}
      <div className="text-xs text-on-surface-variant">
        <span>Ecosystem</span>
        <span className="mx-2">›</span>
        <span>Artificial Intelligence</span>
        <span className="mx-2">›</span>
        <span className="text-on-surface">{slug}</span>
      </div>

      {/* Dossier Header */}
      <div className="mt-6 flex items-start justify-between">
        <div>
          <p className="diplomatic-label">Dossier Numérique</p>
          <h1 className="mt-2 font-headline text-4xl font-semibold tracking-tight text-on-surface">
            {mockEntity.name}
          </h1>
          <p className="mt-2 max-w-xl font-headline text-base italic text-on-surface-variant">
            {mockEntity.description}
          </p>
        </div>

        {/* Sovereignty Score */}
        <div className="text-right">
          <p className="diplomatic-label">Sovereignty Score</p>
          <p className="mt-1 font-headline text-4xl font-bold text-primary">
            {mockEntity.sovereigntyScore}
            <span className="text-base font-normal text-on-surface-variant">
              {" "}
              /100
            </span>
          </p>
          <p className="mt-1 text-sm text-on-surface-variant">
            Origin:{" "}
            <span className="font-medium text-on-surface">
              {mockEntity.origin}
            </span>
          </p>
        </div>
      </div>

      {/* Company Vitality Summary Bar */}
      <div className="mt-8 flex items-center gap-8 bg-surface-container-low px-6 py-4">
        <div className="flex items-center gap-2">
          <span className="inline-block h-2 w-2 bg-secondary" />
          <span className="text-sm text-on-surface">{mockEntity.status}</span>
        </div>
        <div>
          <span className="diplomatic-label">Sector</span>
          <span className="ml-2 text-sm text-on-surface">
            {mockEntity.sector}
          </span>
        </div>
        <div>
          <span className="diplomatic-label">Employees</span>
          <span className="ml-2 text-sm text-on-surface">
            {mockEntity.fte}
          </span>
        </div>
        <div>
          <span className="diplomatic-label">Founded</span>
          <span className="ml-2 text-sm text-on-surface">
            {mockEntity.founded}
          </span>
        </div>
      </div>

      {/* Main Content — 2-column asymmetric layout */}
      <div className="mt-10 grid grid-cols-5 gap-10">
        {/* Left Column (3/5) */}
        <div className="col-span-3 space-y-10">
          {/* Executive Summary */}
          <section>
            <h2 className="diplomatic-label mb-4">Executive Summary</h2>
            <div className="flex items-start gap-8">
              <div>
                <p className="diplomatic-label">Innovation Core Index</p>
                <p className="mt-1 font-headline text-3xl font-semibold text-on-surface">
                  {mockEntity.innovationScore}
                </p>
              </div>
              <div>
                <p className="diplomatic-label">Sovereignty Compliance</p>
                <p className="mt-1 font-headline text-3xl font-semibold text-primary">
                  {mockEntity.sovereigntyGrade}
                </p>
              </div>
            </div>
            <p className="mt-4 text-sm leading-relaxed text-on-surface-variant">
              {mockEntity.longDescription}
            </p>
          </section>

          {/* Structural DNA */}
          <section>
            <h2 className="diplomatic-label mb-4">Structural DNA</h2>
            <div className="space-y-3">
              <div>
                <p className="text-xs text-on-surface-variant">
                  Legal Structure
                </p>
                <p className="text-sm text-on-surface">
                  {mockEntity.structuralDna.legalStatus}
                </p>
              </div>
              <div>
                <p className="text-xs text-on-surface-variant">Founders</p>
                <p className="text-sm text-on-surface">
                  {mockEntity.structuralDna.founders}
                </p>
              </div>
              <div>
                <p className="text-xs text-on-surface-variant">Governance</p>
                <p className="text-sm text-on-surface">
                  {mockEntity.structuralDna.governanceNote}
                </p>
              </div>
            </div>
          </section>

          {/* Institutional Context */}
          <section>
            <h2 className="diplomatic-label mb-4">Institutional Context</h2>
            <div className="grid grid-cols-3 gap-6">
              {mockEntity.institutionalContext.map((ctx) => (
                <div key={ctx.title}>
                  <p className="diplomatic-label">{ctx.label}</p>
                  <h3 className="mt-2 font-headline text-base font-semibold text-on-surface">
                    {ctx.title}
                  </h3>
                  <p className="mt-2 text-xs leading-relaxed text-on-surface-variant">
                    {ctx.description}
                  </p>
                </div>
              ))}
            </div>
          </section>
        </div>

        {/* Right Column (2/5) */}
        <div className="col-span-2 space-y-8">
          {/* Network Navigator Mini */}
          <section className="bg-surface-container-low p-6">
            <h2 className="diplomatic-label mb-4">Institutional Lineage</h2>
            <div className="space-y-3">
              {mockEntity.networkRelations.map((rel) => (
                <div key={rel.type}>
                  <p className="diplomatic-label text-[0.6rem]">{rel.type}</p>
                  <p className="text-sm text-on-surface">{rel.detail}</p>
                </div>
              ))}
            </div>
          </section>

          {/* Core Capabilities */}
          <section className="bg-surface-container-lowest p-6 ambient-shadow">
            <h2 className="diplomatic-label mb-4">Core Capabilities</h2>
            <ul className="space-y-2">
              {mockEntity.coreCapabilities.map((cap) => (
                <li
                  key={cap}
                  className="flex items-start gap-2 text-sm text-on-surface"
                >
                  <span className="mt-1 inline-block h-1.5 w-1.5 shrink-0 bg-primary" />
                  {cap}
                </li>
              ))}
            </ul>
          </section>

          {/* Funding Lineage */}
          <section>
            <h2 className="diplomatic-label mb-4">Funding Lineage</h2>
            <div className="space-y-4">
              {mockEntity.fundingLineage.map((round) => (
                <div
                  key={round.name}
                  className="flex items-start justify-between"
                >
                  <div>
                    <p className="text-sm font-medium text-on-surface">
                      {round.name}
                    </p>
                    <p className="text-xs text-on-surface-variant">
                      {round.type}
                    </p>
                  </div>
                  <div className="text-right">
                    <p className="text-sm font-medium text-on-surface">
                      {round.amount}
                    </p>
                    <p className="text-xs text-on-surface-variant">
                      {round.date}
                    </p>
                  </div>
                </div>
              ))}
            </div>
          </section>

          {/* CTA */}
          <button
            type="button"
            className="w-full border border-primary py-3 text-sm font-semibold text-primary transition-colors duration-200 hover:bg-primary hover:text-on-primary"
          >
            Access Full Intelligence Report
          </button>
        </div>
      </div>
    </div>
  );
}
