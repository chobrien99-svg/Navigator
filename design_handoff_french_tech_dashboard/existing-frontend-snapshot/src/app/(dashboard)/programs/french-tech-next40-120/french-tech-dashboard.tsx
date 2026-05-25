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
  program_editions?: { id: string; year: number | null; cohort_label: string | null; slug: string | null; source_url: string | null } | null;
  organizations?: OrgData | null;
}

interface Props {
  members: MemberEntry[];
  error: string | null;
}

type MovementType = "new" | "promoted" | "demoted" | "retained" | "exited";
type TierFilter = "all" | "Next 40" | "FT 120";
type MovementFilter = "all" | MovementType;

interface CompanyYearInfo {
  entry: MemberEntry;
  org: OrgData;
  groupLabel: string;
  movement: MovementType;
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

function getPrimarySector(org: OrgData): string {
  const sectors = org.organization_sectors ?? [];
  const primary = sectors.find((s) => s.is_primary);
  const sector = primary ?? sectors[0];
  return sector?.sectors?.name ?? "—";
}

function getCityName(org: OrgData): string {
  return org.cities?.name ?? org.country ?? "—";
}

const movementConfig: Record<
  MovementType,
  { label: string; icon: string; color: string; bgColor: string }
> = {
  new: {
    label: "New",
    icon: "add_circle",
    color: "text-green-700",
    bgColor: "bg-green-50",
  },
  promoted: {
    label: "Promoted to Next 40",
    icon: "arrow_upward",
    color: "text-primary",
    bgColor: "bg-primary/10",
  },
  demoted: {
    label: "Moved to FT 120",
    icon: "arrow_downward",
    color: "text-orange-600",
    bgColor: "bg-orange-50",
  },
  retained: {
    label: "Retained",
    icon: "check_circle",
    color: "text-on-surface-variant",
    bgColor: "bg-surface-container",
  },
  exited: {
    label: "Exited",
    icon: "remove_circle",
    color: "text-red-600",
    bgColor: "bg-red-50",
  },
};

const groupLabels: Record<string, { label: string; color: string }> = {
  "Next 40": { label: "Next 40", color: "bg-primary/15 text-primary" },
  "FT 120": { label: "FT 120", color: "bg-secondary/10 text-secondary" },
};

// ─── Component ────────────────────────────────────────────

export function FrenchTechDashboard({ members, error }: Props) {
  const [selectedYear, setSelectedYear] = useState<number | null>(null);
  const [tierFilter, setTierFilter] = useState<TierFilter>("all");
  const [movementFilter, setMovementFilter] = useState<MovementFilter>("all");
  const [search, setSearch] = useState("");

  // Build year → org lookup maps
  const { years, byYear, byYearByOrg } = useMemo(() => {
    const byYear = new Map<number, MemberEntry[]>();
    for (const m of members) {
      const year = m.program_editions?.year ?? 0;
      const list = byYear.get(year) ?? [];
      list.push(m);
      byYear.set(year, list);
    }
    const years = Array.from(byYear.keys()).sort((a, b) => b - a);

    // year → orgId → group_label
    const byYearByOrg = new Map<number, Map<string, string>>();
    for (const [year, entries] of byYear) {
      const orgMap = new Map<string, string>();
      for (const e of entries) {
        orgMap.set(e.organization_id, e.group_label ?? "—");
      }
      byYearByOrg.set(year, orgMap);
    }

    return { years, byYear, byYearByOrg };
  }, [members]);

  // Default to most recent year
  const activeYear = selectedYear ?? years[0] ?? 0;

  // Compute movement for each company in the active year
  const { companies, exitedCompanies, stats } = useMemo(() => {
    const cohort = byYear.get(activeYear) ?? [];
    const prevYear = years.find((y) => y < activeYear);
    const prevOrgMap = prevYear ? byYearByOrg.get(prevYear) : undefined;
    const currentOrgMap = byYearByOrg.get(activeYear);

    const companies: CompanyYearInfo[] = cohort
      .filter((e) => e.organizations)
      .map((e) => {
        const org = e.organizations!;
        const groupLabel = e.group_label ?? "—";
        let movement: MovementType = "new";

        if (prevOrgMap) {
          const prevTier = prevOrgMap.get(e.organization_id);
          if (!prevTier) {
            movement = "new";
          } else if (prevTier === "FT 120" && groupLabel === "Next 40") {
            movement = "promoted";
          } else if (prevTier === "Next 40" && groupLabel === "FT 120") {
            movement = "demoted";
          } else {
            movement = "retained";
          }
        }

        return { entry: e, org, groupLabel, movement };
      });

    // Find exited companies (were in prev year, not in current)
    const exitedCompanies: CompanyYearInfo[] = [];
    if (prevOrgMap && currentOrgMap) {
      for (const [orgId, prevTier] of prevOrgMap) {
        if (!currentOrgMap.has(orgId)) {
          // Find the org data from the previous year's entries
          const prevEntry = (byYear.get(prevYear!) ?? []).find(
            (e) => e.organization_id === orgId
          );
          if (prevEntry?.organizations) {
            exitedCompanies.push({
              entry: prevEntry,
              org: prevEntry.organizations,
              groupLabel: prevTier,
              movement: "exited",
            });
          }
        }
      }
    }

    const stats = {
      total: companies.length,
      next40: companies.filter((c) => c.groupLabel === "Next 40").length,
      ft120: companies.filter((c) => c.groupLabel === "FT 120").length,
      new: companies.filter((c) => c.movement === "new").length,
      promoted: companies.filter((c) => c.movement === "promoted").length,
      demoted: companies.filter((c) => c.movement === "demoted").length,
      retained: companies.filter((c) => c.movement === "retained").length,
      exited: exitedCompanies.length,
    };

    return { companies, exitedCompanies, stats };
  }, [activeYear, years, byYear, byYearByOrg]);

  // Apply filters
  const filteredCompanies = useMemo(() => {
    let list =
      movementFilter === "exited"
        ? exitedCompanies
        : companies;

    if (tierFilter !== "all" && movementFilter !== "exited") {
      list = list.filter((c) => c.groupLabel === tierFilter);
    }
    if (movementFilter !== "all" && movementFilter !== "exited") {
      list = list.filter((c) => c.movement === movementFilter);
    }
    if (search.trim()) {
      const q = search.toLowerCase();
      list = list.filter((c) => c.org.name.toLowerCase().includes(q));
    }

    // Sort: Next 40 first, then alphabetical
    return list.sort((a, b) => {
      const aIs40 = a.groupLabel === "Next 40";
      const bIs40 = b.groupLabel === "Next 40";
      if (aIs40 && !bIs40) return -1;
      if (!aIs40 && bIs40) return 1;
      return a.org.name.localeCompare(b.org.name);
    });
  }, [companies, exitedCompanies, tierFilter, movementFilter, search]);

  const uniqueOrgIds = new Set(members.map((m) => m.organization_id));

  return (
    <div className="px-10 py-8">
      {/* Page Header */}
      <div className="flex items-end justify-between">
        <div>
          <h1 className="font-headline text-3xl font-semibold tracking-tight text-primary">
            French Tech Next 40/120
          </h1>
          <p className="mt-1 max-w-2xl text-sm leading-relaxed text-on-surface-variant">
            The French government&apos;s flagship program highlighting the
            nation&apos;s most promising and high-growth tech companies. The{" "}
            <strong>Next 40</strong> recognizes the top-tier scale-ups, while
            the <strong>FT 120</strong> captures the broader cohort of rising
            champions.
          </p>
          <div className="mt-3 flex items-center gap-6 text-xs text-on-surface-variant">
            <span>
              <strong className="text-on-surface">{uniqueOrgIds.size}</strong>{" "}
              companies tracked
            </span>
            <span className="text-outline-variant">·</span>
            <span>
              <strong className="text-on-surface">{years.length}</strong> cohort{" "}
              {years.length === 1 ? "year" : "years"}
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

      {members.length === 0 && !error && (
        <div className="mt-16 py-20 text-center">
          <span className="material-symbols-outlined text-5xl text-on-surface-variant/40">
            emoji_events
          </span>
          <p className="mt-4 font-headline text-lg italic text-on-surface-variant">
            No French Tech Next 40/120 data imported yet.
          </p>
        </div>
      )}

      {members.length > 0 && (
        <>
          {/* Year Selector */}
          <div className="mt-8 flex items-center gap-2">
            {years.map((year) => (
              <button
                key={year}
                onClick={() => {
                  setSelectedYear(year);
                  setMovementFilter("all");
                }}
                className={`px-4 py-2 text-sm font-medium transition-colors duration-150 ${
                  year === activeYear
                    ? "bg-primary text-on-primary"
                    : "bg-surface-container-low text-on-surface-variant hover:bg-surface-container hover:text-on-surface"
                }`}
              >
                {year}
              </button>
            ))}
          </div>

          {/* Movement Summary Cards */}
          <div className="mt-6 grid grid-cols-2 gap-3 sm:grid-cols-4 lg:grid-cols-6">
            <button
              onClick={() => setMovementFilter("all")}
              className={`p-4 text-left transition-colors ${
                movementFilter === "all"
                  ? "bg-surface-container-highest ring-1 ring-primary/30"
                  : "bg-surface-container-lowest hover:bg-surface-container-low"
              }`}
            >
              <p className="text-2xl font-semibold text-on-surface">
                {stats.total}
              </p>
              <p className="mt-0.5 text-xs text-on-surface-variant">
                Total companies
              </p>
              <div className="mt-2 flex gap-3 text-xs text-on-surface-variant">
                <span>
                  <strong className="text-primary">{stats.next40}</strong> Next
                  40
                </span>
                <span>
                  <strong className="text-secondary">{stats.ft120}</strong> FT
                  120
                </span>
              </div>
            </button>

            <button
              onClick={() => setMovementFilter("new")}
              className={`p-4 text-left transition-colors ${
                movementFilter === "new"
                  ? "bg-green-50 ring-1 ring-green-300"
                  : "bg-surface-container-lowest hover:bg-surface-container-low"
              }`}
            >
              <p className="text-2xl font-semibold text-green-700">
                {stats.new}
              </p>
              <p className="mt-0.5 text-xs text-on-surface-variant">
                New entrants
              </p>
            </button>

            <button
              onClick={() => setMovementFilter("promoted")}
              className={`p-4 text-left transition-colors ${
                movementFilter === "promoted"
                  ? "bg-primary/10 ring-1 ring-primary/30"
                  : "bg-surface-container-lowest hover:bg-surface-container-low"
              }`}
            >
              <p className="text-2xl font-semibold text-primary">
                {stats.promoted}
              </p>
              <p className="mt-0.5 text-xs text-on-surface-variant">
                Promoted to 40
              </p>
            </button>

            <button
              onClick={() => setMovementFilter("demoted")}
              className={`p-4 text-left transition-colors ${
                movementFilter === "demoted"
                  ? "bg-orange-50 ring-1 ring-orange-300"
                  : "bg-surface-container-lowest hover:bg-surface-container-low"
              }`}
            >
              <p className="text-2xl font-semibold text-orange-600">
                {stats.demoted}
              </p>
              <p className="mt-0.5 text-xs text-on-surface-variant">
                Moved to 120
              </p>
            </button>

            <button
              onClick={() => setMovementFilter("retained")}
              className={`p-4 text-left transition-colors ${
                movementFilter === "retained"
                  ? "bg-surface-container-highest ring-1 ring-outline-variant/30"
                  : "bg-surface-container-lowest hover:bg-surface-container-low"
              }`}
            >
              <p className="text-2xl font-semibold text-on-surface-variant">
                {stats.retained}
              </p>
              <p className="mt-0.5 text-xs text-on-surface-variant">
                Retained
              </p>
            </button>

            <button
              onClick={() => setMovementFilter("exited")}
              className={`p-4 text-left transition-colors ${
                movementFilter === "exited"
                  ? "bg-red-50 ring-1 ring-red-300"
                  : "bg-surface-container-lowest hover:bg-surface-container-low"
              }`}
            >
              <p className="text-2xl font-semibold text-red-600">
                {stats.exited}
              </p>
              <p className="mt-0.5 text-xs text-on-surface-variant">
                Exited program
              </p>
            </button>
          </div>

          {/* Filters Row */}
          <div className="mt-6 flex items-center gap-4">
            {/* Search */}
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

            {/* Tier Filter */}
            {movementFilter !== "exited" && (
              <div className="flex items-center gap-1">
                {(["all", "Next 40", "FT 120"] as TierFilter[]).map(
                  (filter) => (
                    <button
                      key={filter}
                      onClick={() => setTierFilter(filter)}
                      className={`px-3 py-1.5 text-xs font-medium transition-colors ${
                        tierFilter === filter
                          ? "bg-primary/10 text-primary"
                          : "text-on-surface-variant hover:text-on-surface"
                      }`}
                    >
                      {filter === "all" ? "All tiers" : filter}
                    </button>
                  )
                )}
              </div>
            )}

            {/* Count */}
            <span className="ml-auto text-xs text-on-surface-variant">
              {filteredCompanies.length}{" "}
              {filteredCompanies.length === 1 ? "company" : "companies"}
            </span>
          </div>

          {/* Company List */}
          <div className="mt-4 space-y-2">
            {filteredCompanies.map((item) => {
              const { org, groupLabel, movement, entry } = item;
              const mv = movementConfig[movement];
              const tierInfo = groupLabels[groupLabel] ?? {
                label: groupLabel,
                color: "bg-surface-container-high text-on-surface-variant",
              };

              return (
                <Link
                  key={entry.id}
                  href={`/entities/${org.slug}`}
                  className="group flex items-start gap-5 bg-surface-container-lowest p-4 transition-colors duration-200 hover:bg-surface-container-low"
                >
                  {/* Movement indicator */}
                  <div
                    className={`flex shrink-0 items-center justify-center w-8 h-8 ${mv.bgColor}`}
                  >
                    <span
                      className={`material-symbols-outlined text-[18px] ${mv.color}`}
                    >
                      {mv.icon}
                    </span>
                  </div>

                  {/* Identity */}
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2.5">
                      <h3 className="font-headline text-sm font-semibold text-on-surface group-hover:text-primary">
                        {org.name}
                      </h3>
                      <span
                        className={`shrink-0 px-1.5 py-0.5 text-[0.65rem] font-semibold ${tierInfo.color}`}
                      >
                        {tierInfo.label}
                      </span>
                      {movement !== "retained" && (
                        <span
                          className={`shrink-0 px-1.5 py-0.5 text-[0.6rem] font-medium ${mv.bgColor} ${mv.color}`}
                        >
                          {mv.label}
                        </span>
                      )}
                      <span
                        className={`shrink-0 px-1.5 py-0.5 text-[0.55rem] font-semibold ${
                          org.status === "active"
                            ? "bg-secondary/10 text-secondary"
                            : "bg-outline/10 text-outline"
                        }`}
                      >
                        {org.status}
                      </span>
                    </div>
                    <p className="mt-0.5 max-w-2xl truncate text-xs leading-relaxed text-on-surface-variant">
                      {org.short_description ?? org.description ?? "—"}
                    </p>
                    <div className="mt-1.5 flex items-center gap-3 text-[0.7rem] text-on-surface-variant">
                      <span>{getCityName(org)}</span>
                      <span className="text-outline-variant">·</span>
                      <span>{getPrimarySector(org)}</span>
                      {org.employee_range && (
                        <>
                          <span className="text-outline-variant">·</span>
                          <span>{org.employee_range}</span>
                        </>
                      )}
                      {org.founded_year && (
                        <>
                          <span className="text-outline-variant">·</span>
                          <span>Est. {org.founded_year}</span>
                        </>
                      )}
                    </div>
                  </div>

                  {/* Metrics */}
                  <div className="flex shrink-0 items-center gap-6 text-right">
                    <div>
                      <p className="text-[0.6rem] uppercase tracking-wider text-on-surface-variant/60">
                        Raised
                      </p>
                      <p className="mt-0.5 text-sm font-medium text-on-surface">
                        {formatEurFromDb(org.total_raised_eur)}
                      </p>
                    </div>
                  </div>
                </Link>
              );
            })}

            {filteredCompanies.length === 0 && (
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
