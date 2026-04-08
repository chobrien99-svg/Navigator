"use client";

import { useMemo, useState } from "react";
import Link from "next/link";

// ─── Types ────────────────────────────────────────────────

interface OrgData {
  id: string;
  name: string;
  slug: string;
  organization_type: string;
  status: string;
  description: string | null;
  short_description: string | null;
  website: string | null;
  logo_url: string | null;
  country: string;
  total_raised_eur: number | null;
  employee_range: string | null;
  founded_year: number | null;
  cities?: { name: string; slug: string; region: string | null } | null;
  organization_sectors?: {
    is_primary: boolean;
    sectors: { name: string; slug: string } | null;
  }[];
}

interface MemberEntry {
  id: string;
  organization_id: string;
  group_label: string | null;
  membership_role: string | null;
  notes: string | null;
  program_editions?: {
    id: string;
    year: number | null;
    cohort_label: string | null;
  } | null;
  organizations?: OrgData | null;
}

interface Props {
  members: MemberEntry[];
  error: string | null;
}

// ─── Helpers ──────────────────────────────────────────────

const AMOUNT_MULTIPLIER = 1_000_000;

function formatEurFromDb(amountInMillions: number | null): string {
  if (amountInMillions == null) return "—";
  const raw = amountInMillions * AMOUNT_MULTIPLIER;
  if (raw >= 1_000_000_000) return `€${(raw / 1_000_000_000).toFixed(1)}B`;
  if (raw >= 1_000_000) return `€${(raw / 1_000_000).toFixed(1)}M`;
  if (raw >= 1_000) return `€${(raw / 1_000).toFixed(0)}K`;
  return `€${raw.toLocaleString()}`;
}

function getCityName(org: OrgData): string {
  return org.cities?.name ?? org.country ?? "—";
}

function getRegion(org: OrgData): string {
  return org.cities?.region ?? "—";
}

// ─── Component ────────────────────────────────────────────

export function ILabDashboard({ members, error }: Props) {
  const [selectedYear, setSelectedYear] = useState<number | null>(null);
  const [domainFilter, setDomainFilter] = useState<string>("all");
  const [roleFilter, setRoleFilter] = useState<string>("all");
  const [search, setSearch] = useState("");

  // Compute years, domains, stats
  const { years, domains, byYear } = useMemo(() => {
    const byYear = new Map<number, MemberEntry[]>();
    const domainSet = new Set<string>();

    for (const m of members) {
      const year = m.program_editions?.year ?? 0;
      const list = byYear.get(year) ?? [];
      list.push(m);
      byYear.set(year, list);
      if (m.group_label) domainSet.add(m.group_label);
    }

    const years = Array.from(byYear.keys()).sort((a, b) => b - a);
    const domains = Array.from(domainSet).sort();
    return { years, domains, byYear };
  }, [members]);

  const activeYear = selectedYear ?? years[0] ?? 0;

  // Stats for selected year
  const yearStats = useMemo(() => {
    const cohort = byYear.get(activeYear) ?? [];
    const grandPrix = cohort.filter((m) => m.membership_role === "Grand Prix");
    const domainCounts = new Map<string, number>();
    for (const m of cohort) {
      const d = m.group_label ?? "Unknown";
      domainCounts.set(d, (domainCounts.get(d) ?? 0) + 1);
    }
    const topDomains = Array.from(domainCounts.entries())
      .sort((a, b) => b[1] - a[1])
      .slice(0, 8);

    return {
      total: cohort.length,
      grandPrix: grandPrix.length,
      domainCounts: topDomains,
    };
  }, [activeYear, byYear]);

  // Filter
  const filtered = useMemo(() => {
    let list = byYear.get(activeYear) ?? [];

    if (domainFilter !== "all") {
      list = list.filter((m) => m.group_label === domainFilter);
    }
    if (roleFilter !== "all") {
      list = list.filter((m) => m.membership_role === roleFilter);
    }
    if (search.trim()) {
      const q = search.toLowerCase();
      list = list.filter(
        (m) =>
          (m.organizations?.name ?? "").toLowerCase().includes(q) ||
          (m.organizations?.description ?? "").toLowerCase().includes(q)
      );
    }

    return list.sort((a, b) => {
      // Grand Prix first, then alphabetical
      if (a.membership_role === "Grand Prix" && b.membership_role !== "Grand Prix") return -1;
      if (a.membership_role !== "Grand Prix" && b.membership_role === "Grand Prix") return 1;
      return (a.organizations?.name ?? "").localeCompare(b.organizations?.name ?? "");
    });
  }, [activeYear, byYear, domainFilter, roleFilter, search]);

  const uniqueOrgIds = new Set(members.map((m) => m.organization_id));

  // Decade groups for year selector
  const yearsByDecade = useMemo(() => {
    const decades = new Map<string, number[]>();
    for (const y of years) {
      const decade = `${Math.floor(y / 10) * 10}s`;
      const list = decades.get(decade) ?? [];
      list.push(y);
      decades.set(decade, list);
    }
    return decades;
  }, [years]);

  return (
    <div className="px-10 py-8">
      {/* Page Header */}
      <div className="flex items-end justify-between">
        <div>
          <h1 className="font-headline text-3xl font-semibold tracking-tight text-primary">
            i-Lab Laureates
          </h1>
          <p className="mt-1 max-w-2xl text-sm leading-relaxed text-on-surface-variant">
            France&apos;s national deep-tech startup competition, run by
            Bpifrance since 1999. Recognizes the most innovative technology
            ventures emerging from French research labs and universities.
          </p>
          <div className="mt-3 flex items-center gap-6 text-xs text-on-surface-variant">
            <span>
              <strong className="text-on-surface">{uniqueOrgIds.size}</strong>{" "}
              companies
            </span>
            <span className="text-outline-variant">·</span>
            <span>
              <strong className="text-on-surface">{years.length}</strong>{" "}
              editions ({years[years.length - 1]}–{years[0]})
            </span>
            <span className="text-outline-variant">·</span>
            <span>
              <strong className="text-on-surface">
                {members.filter((m) => m.membership_role === "Grand Prix").length}
              </strong>{" "}
              Grand Prix winners
            </span>
            <span className="text-outline-variant">·</span>
            <a
              href="https://www.bpifrance.fr/catalogue-offres/soutien-a-linnovation/concours-dinnovation-i-lab"
              target="_blank"
              rel="noopener noreferrer"
              className="text-primary hover:underline"
            >
              Official page ↗
            </a>
          </div>
        </div>
      </div>

      {error && (
        <div className="mt-6 bg-error-container p-4 text-sm text-on-error-container">
          {error}
        </div>
      )}

      {members.length === 0 && !error && (
        <div className="mt-16 py-20 text-center">
          <span className="material-symbols-outlined text-5xl text-on-surface-variant/40">
            science
          </span>
          <p className="mt-4 font-headline text-lg italic text-on-surface-variant">
            No i-Lab data imported yet.
          </p>
        </div>
      )}

      {members.length > 0 && (
        <>
          {/* Year Selector */}
          <div className="mt-8">
            {Array.from(yearsByDecade.entries()).map(([decade, decadeYears]) => (
              <div key={decade} className="flex items-center gap-1 mb-1">
                <span className="w-10 text-[0.6rem] text-outline-variant shrink-0">
                  {decade}
                </span>
                <div className="flex flex-wrap gap-1">
                  {decadeYears.map((year) => (
                    <button
                      key={year}
                      onClick={() => {
                        setSelectedYear(year);
                        setDomainFilter("all");
                        setRoleFilter("all");
                      }}
                      className={`px-2.5 py-1 text-xs font-medium transition-colors duration-150 ${
                        year === activeYear
                          ? "bg-primary text-on-primary"
                          : "bg-surface-container-low text-on-surface-variant hover:bg-surface-container hover:text-on-surface"
                      }`}
                    >
                      {year}
                    </button>
                  ))}
                </div>
              </div>
            ))}
          </div>

          {/* Year Summary */}
          <div className="mt-6 grid grid-cols-2 gap-3 sm:grid-cols-4 lg:grid-cols-6">
            <button
              onClick={() => { setRoleFilter("all"); setDomainFilter("all"); }}
              className={`p-4 text-left transition-colors ${
                roleFilter === "all" && domainFilter === "all"
                  ? "bg-surface-container-highest ring-1 ring-primary/30"
                  : "bg-surface-container-lowest hover:bg-surface-container-low"
              }`}
            >
              <p className="text-2xl font-semibold text-on-surface">
                {yearStats.total}
              </p>
              <p className="mt-0.5 text-xs text-on-surface-variant">
                Laureates in {activeYear}
              </p>
            </button>

            <button
              onClick={() => { setRoleFilter("Grand Prix"); setDomainFilter("all"); }}
              className={`p-4 text-left transition-colors ${
                roleFilter === "Grand Prix"
                  ? "bg-amber-50 ring-1 ring-amber-300"
                  : "bg-surface-container-lowest hover:bg-surface-container-low"
              }`}
            >
              <p className="text-2xl font-semibold text-amber-600">
                {yearStats.grandPrix}
              </p>
              <p className="mt-0.5 text-xs text-on-surface-variant">
                Grand Prix
              </p>
            </button>

            {yearStats.domainCounts.slice(0, 4).map(([domain, count]) => (
              <button
                key={domain}
                onClick={() => { setDomainFilter(domain); setRoleFilter("all"); }}
                className={`p-4 text-left transition-colors ${
                  domainFilter === domain
                    ? "bg-surface-container-highest ring-1 ring-primary/30"
                    : "bg-surface-container-lowest hover:bg-surface-container-low"
                }`}
              >
                <p className="text-2xl font-semibold text-on-surface">{count}</p>
                <p className="mt-0.5 text-xs text-on-surface-variant truncate">
                  {domain}
                </p>
              </button>
            ))}
          </div>

          {/* Filters */}
          <div className="mt-6 flex items-center gap-4">
            <div className="relative flex-1 max-w-xs">
              <span className="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-[18px] text-on-surface-variant">
                search
              </span>
              <input
                type="text"
                placeholder="Search companies..."
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                className="w-full bg-surface-container-lowest py-2.5 pl-10 pr-4 text-sm text-on-surface placeholder:text-on-surface-variant/50 border border-outline-variant/20 focus:border-primary focus:outline-none"
              />
            </div>

            {/* Domain filter dropdown */}
            <select
              value={domainFilter}
              onChange={(e) => setDomainFilter(e.target.value)}
              className="bg-surface-container-lowest px-3 py-2.5 text-xs text-on-surface border border-outline-variant/20 focus:border-primary focus:outline-none"
            >
              <option value="all">All domains</option>
              {domains.map((d) => (
                <option key={d} value={d}>
                  {d}
                </option>
              ))}
            </select>

            <span className="ml-auto text-xs text-on-surface-variant">
              {filtered.length}{" "}
              {filtered.length === 1 ? "company" : "companies"}
            </span>
          </div>

          {/* Company List */}
          <div className="mt-4 space-y-2">
            {filtered.map((entry) => {
              const org = entry.organizations;
              if (!org) return null;
              const isGrandPrix = entry.membership_role === "Grand Prix";

              return (
                <Link
                  key={entry.id}
                  href={`/entities/${org.slug}`}
                  className="group flex items-start gap-5 bg-surface-container-lowest p-4 transition-colors duration-200 hover:bg-surface-container-low"
                >
                  {/* Grand Prix indicator */}
                  <div
                    className={`flex shrink-0 items-center justify-center w-8 h-8 ${
                      isGrandPrix ? "bg-amber-50" : "bg-surface-container"
                    }`}
                  >
                    <span
                      className={`material-symbols-outlined text-[18px] ${
                        isGrandPrix ? "text-amber-600" : "text-on-surface-variant"
                      }`}
                    >
                      {isGrandPrix ? "emoji_events" : "science"}
                    </span>
                  </div>

                  {/* Identity */}
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2.5">
                      <h3 className="font-headline text-sm font-semibold text-on-surface group-hover:text-primary">
                        {org.name}
                      </h3>
                      {isGrandPrix && (
                        <span className="shrink-0 px-2 py-0.5 text-[0.6rem] font-semibold bg-amber-50 text-amber-700">
                          Grand Prix
                        </span>
                      )}
                      {entry.group_label && (
                        <span className="shrink-0 px-1.5 py-0.5 text-[0.6rem] font-medium bg-primary/8 text-primary">
                          {entry.group_label}
                        </span>
                      )}
                    </div>
                    <p className="mt-0.5 max-w-2xl truncate text-xs leading-relaxed text-on-surface-variant">
                      {org.short_description ?? org.description ?? "—"}
                    </p>
                    <div className="mt-1.5 flex items-center gap-3 text-[0.7rem] text-on-surface-variant">
                      <span>{getCityName(org)}</span>
                      {getRegion(org) !== "—" && (
                        <>
                          <span className="text-outline-variant">·</span>
                          <span>{getRegion(org)}</span>
                        </>
                      )}
                      {org.founded_year && (
                        <>
                          <span className="text-outline-variant">·</span>
                          <span>Est. {org.founded_year}</span>
                        </>
                      )}
                      {org.website && (
                        <>
                          <span className="text-outline-variant">·</span>
                          <span className="truncate max-w-[200px]">
                            {org.website.replace(/^https?:\/\/(www\.)?/, "").replace(/\/$/, "")}
                          </span>
                        </>
                      )}
                    </div>
                  </div>

                  {/* Metrics */}
                  <div className="flex shrink-0 items-center gap-6 text-right">
                    {org.total_raised_eur != null && org.total_raised_eur > 0 && (
                      <div>
                        <p className="text-[0.6rem] uppercase tracking-wider text-on-surface-variant/60">
                          Raised
                        </p>
                        <p className="mt-0.5 text-sm font-medium text-on-surface">
                          {formatEurFromDb(org.total_raised_eur)}
                        </p>
                      </div>
                    )}
                  </div>
                </Link>
              );
            })}

            {filtered.length === 0 && (
              <div className="py-12 text-center">
                <p className="text-sm italic text-on-surface-variant">
                  No companies match the current filters.
                </p>
              </div>
            )}
          </div>
        </>
      )}
    </div>
  );
}
