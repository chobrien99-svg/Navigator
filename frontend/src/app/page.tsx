import Link from "next/link";
import { getDashboardStats, formatEurFromDb } from "@/lib/queries";

export default async function HomePage() {
  let stats = {
    organizations: 0,
    people: 0,
    fundingRounds: 0,
    totalRaised: 0,
  };

  try {
    stats = await getDashboardStats();
  } catch {
    // Will show zeros if DB not connected
  }

  return (
    <div className="min-h-full bg-surface">
      {/* Navigation */}
      <nav className="flex items-center justify-between px-8 py-5">
        <div>
          <h1 className="font-headline text-xl font-semibold tracking-tight text-primary">
            The Navigator
          </h1>
        </div>
        <div className="flex items-center gap-6">
          <Link
            href="/entities"
            className="text-sm text-on-surface-variant transition-colors hover:text-on-surface"
          >
            Explorer
          </Link>
          <Link
            href="/funding"
            className="text-sm text-on-surface-variant transition-colors hover:text-on-surface"
          >
            Funding
          </Link>
          <Link
            href="/people"
            className="text-sm text-on-surface-variant transition-colors hover:text-on-surface"
          >
            People
          </Link>
          <Link
            href="/login"
            className="text-sm font-medium text-primary transition-colors hover:text-primary-container"
          >
            Team Login
          </Link>
        </div>
      </nav>

      {/* Hero */}
      <section className="px-8 pt-16 pb-20">
        <div className="mx-auto max-w-5xl">
          <p className="diplomatic-label">
          </p>
          <h2 className="mt-4 max-w-3xl font-headline text-6xl font-semibold leading-[1.1] tracking-tight text-on-surface">
<<<<<<< HEAD
            THE <span className="text-primary">NAVIGATOR</span>
            <br/>
          </h2>
          <p className="mt-6 max-w-xl text-base leading-relaxed text-on-surface-variant">
            A unified intelligence platform covering companies, capital, research, talent, 
            and public institutions across France — with a global view of French innovation. 
            Built for decision-makers who require depth over noise.
=======
            The Navigator
          </h2>
          <p className="mt-4 font-headline text-2xl font-medium tracking-tight text-primary">
            The French Innovation Intelligence System
          </p>
          <p className="mt-6 max-w-xl text-base leading-relaxed text-on-surface-variant">
            A unified intelligence platform covering companies, capital, research, talent,
            and public institutions across France with a global view of French innovation.
            Built for institutional decision-makers who require depth over noise.
>>>>>>> origin/claude/french-tech-hub-3Bnk0
          </p>

          <div className="mt-10 flex items-center gap-4">
            <Link
              href="/entities"
              className="institutional-gradient px-6 py-3 text-sm font-semibold text-on-primary transition-opacity hover:opacity-90"
            >
              Explore the Ecosystem
            </Link>
            <Link
              href="/funding"
              className="border border-primary px-6 py-3 text-sm font-semibold text-primary transition-colors hover:bg-primary hover:text-on-primary"
            >
              Funding Tracker
            </Link>
          </div>
        </div>
      </section>

      {/* Live Stats Bar */}
      <section className="bg-surface-container-low">
        <div className="mx-auto flex max-w-5xl items-center justify-between px-8 py-10">
          <div>
            <p className="diplomatic-label">Capital Tracked</p>
            <p className="mt-1 font-headline text-4xl font-semibold tracking-tight text-on-surface">
              {formatEurFromDb(stats.totalRaised)}
            </p>
          </div>
          <div>
            <p className="diplomatic-label">Entities</p>
            <p className="mt-1 font-headline text-4xl font-semibold tracking-tight text-on-surface">
              {stats.organizations.toLocaleString()}
            </p>
          </div>
          <div>
            <p className="diplomatic-label">People</p>
            <p className="mt-1 font-headline text-4xl font-semibold tracking-tight text-on-surface">
              {stats.people.toLocaleString()}
            </p>
          </div>
          <div>
            <p className="diplomatic-label">Funding Rounds</p>
            <p className="mt-1 font-headline text-4xl font-semibold tracking-tight text-on-surface">
              {stats.fundingRounds.toLocaleString()}
            </p>
          </div>
        </div>
      </section>

      {/* Intelligence Pillars */}
      <section className="px-8 py-20">
        <div className="mx-auto max-w-5xl">
          <p className="diplomatic-label">Intelligence Pillars</p>
          <h3 className="mt-3 font-headline text-3xl font-semibold tracking-tight text-on-surface">
            Four lenses on the French ecosystem
          </h3>

          <div className="mt-10 grid grid-cols-4 gap-8">
            <Link href="/entities" className="group">
              <div className="bg-surface-container-lowest p-6 transition-colors group-hover:bg-surface-container-low">
                <div className="flex h-10 w-10 items-center justify-center bg-primary">
                  <span className="material-symbols-outlined text-[20px] text-on-primary">
                    domain
                  </span>
                </div>
                <h4 className="mt-4 font-headline text-lg font-semibold text-on-surface">
                  Entity Explorer
                </h4>
                <p className="mt-2 text-sm leading-relaxed text-on-surface-variant">
                  Browse startups, corporates, investors, research labs, and
                  public agencies across the French innovation ecosystem.
                </p>
              </div>
            </Link>

            <Link href="/funding" className="group">
              <div className="bg-surface-container-lowest p-6 transition-colors group-hover:bg-surface-container-low">
                <div className="flex h-10 w-10 items-center justify-center bg-secondary">
                  <span className="material-symbols-outlined text-[20px] text-on-secondary">
                    payments
                  </span>
                </div>
                <h4 className="mt-4 font-headline text-lg font-semibold text-on-surface">
                  Funding Tracker
                </h4>
                <p className="mt-2 text-sm leading-relaxed text-on-surface-variant">
                  Track every funding round — seed to IPO — with investor
                  attribution, verification status, and stage analysis.
                </p>
              </div>
            </Link>

            <Link href="/people" className="group">
              <div className="bg-surface-container-lowest p-6 transition-colors group-hover:bg-surface-container-low">
                <div className="flex h-10 w-10 items-center justify-center bg-tertiary">
                  <span className="material-symbols-outlined text-[20px] text-on-tertiary">
                    person
                  </span>
                </div>
                <h4 className="mt-4 font-headline text-lg font-semibold text-on-surface">
                  People Intelligence
                </h4>
                <p className="mt-2 text-sm leading-relaxed text-on-surface-variant">
                  Map the talent network — founders, researchers, investors —
                  with experience timelines and institutional lineage.
                </p>
              </div>
            </Link>

            <div>
              <div className="bg-surface-container-lowest p-6">
                <div className="flex h-10 w-10 items-center justify-center bg-surface-container-highest">
                  <span className="material-symbols-outlined text-[20px] text-on-surface-variant">
                    hub
                  </span>
                </div>
                <h4 className="mt-4 font-headline text-lg font-semibold text-on-surface">
                  Network Navigator
                </h4>
                <p className="mt-2 text-sm leading-relaxed text-on-surface-variant">
                  Trace institutional lineage, funding provenance, and strategic
                  relationships across the ecosystem graph.
                </p>
                <p className="mt-3 text-xs italic text-outline">Coming soon</p>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-surface-container-low px-8 py-10">
        <div className="mx-auto flex max-w-5xl items-center justify-between">
          <div>
            <p className="font-headline text-base font-semibold text-primary">
              The Navigator
            </p>
            <p className="mt-1 text-xs text-on-surface-variant">
<<<<<<< HEAD
              French Innovation Intelligence Compass
=======
              The French Innovation Intelligence System
>>>>>>> origin/claude/french-tech-hub-3Bnk0
            </p>
          </div>
          <div className="flex items-center gap-6 text-xs text-on-surface-variant">
            <Link href="/entities" className="hover:text-on-surface">
              Entities
            </Link>
            <Link href="/funding" className="hover:text-on-surface">
              Funding
            </Link>
            <Link href="/people" className="hover:text-on-surface">
              People
            </Link>
            <Link href="/login" className="hover:text-on-surface">
              Team Login
            </Link>
          </div>
        </div>
      </footer>
    </div>
  );
}
