export default function EcosystemAtlas() {
  return (
    <div className="px-10 py-8">
      {/* Hero Header — asymmetric editorial layout */}
      <div className="flex items-start justify-between">
        <div className="max-w-xl">
          <h1 className="font-headline text-4xl font-semibold tracking-tight text-primary">
            The Ecosystem Atlas
          </h1>
          <p className="mt-3 font-headline text-lg italic text-on-surface-variant">
            Macro-view of the French Innovation Landscape · Updated Real-time
          </p>
        </div>

        {/* Key Metrics — editorial display typography */}
        <div className="flex gap-10">
          <div className="text-right">
            <p className="diplomatic-label">Capital Flows</p>
            <p className="font-headline text-3xl font-semibold tracking-tight text-on-surface">
              €14.2B
            </p>
          </div>
          <div className="text-right">
            <p className="diplomatic-label">Active Patents</p>
            <p className="font-headline text-3xl font-semibold tracking-tight text-on-surface">
              8.4K
            </p>
          </div>
          <div className="text-right">
            <p className="diplomatic-label">Live Signals</p>
            <p className="font-headline text-3xl font-semibold tracking-tight text-on-surface">
              212
            </p>
          </div>
        </div>
      </div>

      {/* Content Grid */}
      <div className="mt-12 grid grid-cols-3 gap-8">
        {/* Sector Clusters — left 2 columns */}
        <div className="col-span-2 bg-surface-container-low p-8">
          <h2 className="diplomatic-label mb-6">Sector Clusters</h2>
          <div className="flex min-h-[400px] items-center justify-center text-on-surface-variant">
            <p className="font-headline text-lg italic">
              Cluster visualization will render here
            </p>
          </div>
        </div>

        {/* Active Node Card */}
        <div className="bg-surface-container-lowest p-6 ambient-shadow">
          <span className="inline-block bg-primary px-2 py-0.5 text-xs font-semibold text-on-primary">
            ACTIVE NODE
          </span>
          <h3 className="mt-4 font-headline text-xl font-semibold text-on-surface">
            Station F Cluster
          </h3>
          <div className="mt-4">
            <p className="diplomatic-label">Concentration Index</p>
            <p className="mt-1 font-headline text-2xl font-semibold text-on-surface">
              0.92{" "}
              <span className="text-sm font-normal text-secondary">+4%</span>
            </p>
          </div>
          <div className="mt-4">
            <p className="diplomatic-label">Primary Investors</p>
            <p className="mt-1 text-sm text-on-surface">
              Eurazeo, Bpifrance, Kima
            </p>
          </div>
          <button
            type="button"
            className="institutional-gradient mt-6 w-full py-3 text-sm font-semibold text-on-primary transition-opacity duration-200 hover:opacity-90"
          >
            Investigate Entities
          </button>
        </div>
      </div>

      {/* Cartography Legend */}
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
