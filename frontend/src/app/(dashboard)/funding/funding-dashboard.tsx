"use client";

import { useMemo, useState } from "react";
import Link from "next/link";
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  Tooltip,
  ResponsiveContainer,
  CartesianGrid,
  PieChart,
  Pie,
  Cell,
  AreaChart,
  Area,
} from "recharts";

// ─── Types ────────────────────────────────────────────────

interface Round {
  id: string;
  stage: string;
  amount_eur: number | null;
  announced_date: string | null;
  is_verified: boolean;
  is_estimated: boolean;
  organizations?: {
    name: string;
    slug: string;
    organization_type: string;
    organization_sectors?: {
      is_primary: boolean;
      sectors: { name: string; slug: string } | null;
    }[];
  } | null;
  funding_round_investors?: {
    is_lead: boolean;
    investor_name: string | null;
    organizations?: { name: string; slug: string } | null;
  }[];
}

interface Props {
  rounds: Record<string, unknown>[];
  error: string | null;
}

// ─── Helpers ──────────────────────────────────────────────

function formatEur(amount: number | null): string {
  if (amount == null) return "—";
  if (amount >= 1_000_000_000) return `€${(amount / 1_000_000_000).toFixed(1)}B`;
  if (amount >= 1_000_000) return `€${(amount / 1_000_000).toFixed(1)}M`;
  if (amount >= 1_000) return `€${(amount / 1_000).toFixed(0)}K`;
  return `€${amount.toLocaleString()}`;
}

function formatStage(stage: string): string {
  return stage.replace(/_/g, " ").replace(/\b\w/g, (c) => c.toUpperCase());
}

function getYear(dateStr: string | null): number | null {
  if (!dateStr) return null;
  return new Date(dateStr).getFullYear();
}

function getMonthKey(dateStr: string | null): string | null {
  if (!dateStr) return null;
  const d = new Date(dateStr);
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}`;
}

function formatMonthLabel(key: string): string {
  const [year, month] = key.split("-");
  const months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
  return `${months[parseInt(month) - 1]} ${year}`;
}

function getSector(r: Round): string {
  const sectors = r.organizations?.organization_sectors ?? [];
  const primary = sectors.find((s) => s.is_primary);
  return primary?.sectors?.name ?? sectors[0]?.sectors?.name ?? "Unknown";
}

const STAGE_ORDER = [
  "pre_seed", "seed", "series_a", "series_b", "series_c",
  "series_d", "series_e", "series_f", "growth", "bridge",
  "debt", "grant", "ipo", "secondary", "undisclosed", "other",
];

const CHART_COLORS = [
  "#114563", "#2f5d7c", "#3c6840", "#5E8C61", "#503863",
  "#684f7c", "#7C8C9E", "#9fccef", "#ba1a1a", "#C9C1B3",
  "#775a0f", "#a2d3a2",
];

// ─── Sort config ──────────────────────────────────────────

type SortKey = "date" | "amount" | "company" | "stage";
type SortDir = "asc" | "desc";

// ─── Component ────────────────────────────────────────────

export function FundingDashboard({ rounds: rawRounds, error }: Props) {
  const rounds = rawRounds as unknown as Round[];

  // Filters
  const [yearRange, setYearRange] = useState<[number, number]>([2000, 2026]);
  const [selectedStages, setSelectedStages] = useState<Set<string>>(new Set());
  const [searchQuery, setSearchQuery] = useState("");
  const [sortKey, setSortKey] = useState<SortKey>("date");
  const [sortDir, setSortDir] = useState<SortDir>("desc");
  const [activeView, setActiveView] = useState<"charts" | "table">("charts");

  // Available years
  const allYears = useMemo(() => {
    const years = rounds
      .map((r) => getYear(r.announced_date))
      .filter((y): y is number => y != null);
    if (years.length === 0) return [2000, 2026];
    return [Math.min(...years), Math.max(...years)];
  }, [rounds]);

  // Available stages
  const allStages = useMemo(() => {
    const stages = new Set(rounds.map((r) => r.stage));
    return STAGE_ORDER.filter((s) => stages.has(s));
  }, [rounds]);

  // Filtered rounds
  const filtered = useMemo(() => {
    return rounds.filter((r) => {
      const year = getYear(r.announced_date);
      if (year != null && (year < yearRange[0] || year > yearRange[1]))
        return false;
      if (selectedStages.size > 0 && !selectedStages.has(r.stage))
        return false;
      if (searchQuery) {
        const q = searchQuery.toLowerCase();
        const companyName = r.organizations?.name?.toLowerCase() ?? "";
        const investors = r.funding_round_investors ?? [];
        const investorMatch = investors.some(
          (i) =>
            i.investor_name?.toLowerCase().includes(q) ||
            i.organizations?.name?.toLowerCase().includes(q)
        );
        if (!companyName.includes(q) && !investorMatch) return false;
      }
      return true;
    });
  }, [rounds, yearRange, selectedStages, searchQuery]);

  // Sorted rounds
  const sorted = useMemo(() => {
    const arr = [...filtered];
    arr.sort((a, b) => {
      let cmp = 0;
      switch (sortKey) {
        case "date":
          cmp =
            (a.announced_date ?? "").localeCompare(b.announced_date ?? "");
          break;
        case "amount":
          cmp = (a.amount_eur ?? 0) - (b.amount_eur ?? 0);
          break;
        case "company":
          cmp = (a.organizations?.name ?? "").localeCompare(
            b.organizations?.name ?? ""
          );
          break;
        case "stage":
          cmp =
            STAGE_ORDER.indexOf(a.stage) - STAGE_ORDER.indexOf(b.stage);
          break;
      }
      return sortDir === "desc" ? -cmp : cmp;
    });
    return arr;
  }, [filtered, sortKey, sortDir]);

  // ─── Analytics ────────────────────────────────────────────

  const stats = useMemo(() => {
    const totalCapital = filtered.reduce(
      (s, r) => s + (r.amount_eur ?? 0), 0
    );
    const withAmount = filtered.filter((r) => r.amount_eur != null && r.amount_eur > 0);
    const avgRound = withAmount.length
      ? totalCapital / withAmount.length
      : 0;
    const sortedAmounts = withAmount
      .map((r) => r.amount_eur!)
      .sort((a, b) => a - b);
    const medianRound = sortedAmounts.length
      ? sortedAmounts[Math.floor(sortedAmounts.length / 2)]
      : 0;
    const verified = filtered.filter((r) => r.is_verified).length;
    return { totalCapital, avgRound, medianRound, roundCount: filtered.length, verified };
  }, [filtered]);

  // Annual timeline
  const annualData = useMemo(() => {
    const byYear: Record<number, { capital: number; count: number }> = {};
    filtered.forEach((r) => {
      const y = getYear(r.announced_date);
      if (y == null) return;
      if (!byYear[y]) byYear[y] = { capital: 0, count: 0 };
      byYear[y].capital += r.amount_eur ?? 0;
      byYear[y].count += 1;
    });
    return Object.entries(byYear)
      .map(([year, d]) => ({
        year: parseInt(year),
        capital: d.capital,
        count: d.count,
      }))
      .sort((a, b) => a.year - b.year);
  }, [filtered]);

  // Stage breakdown (by capital)
  const stageData = useMemo(() => {
    const byStage: Record<string, { capital: number; count: number }> = {};
    filtered.forEach((r) => {
      if (!byStage[r.stage]) byStage[r.stage] = { capital: 0, count: 0 };
      byStage[r.stage].capital += r.amount_eur ?? 0;
      byStage[r.stage].count += 1;
    });
    return STAGE_ORDER.filter((s) => byStage[s])
      .map((stage) => ({
        stage: formatStage(stage),
        rawStage: stage,
        capital: byStage[stage].capital,
        count: byStage[stage].count,
      }));
  }, [filtered]);

  // Top funded companies
  const topCompanies = useMemo(() => {
    const byCompany: Record<
      string,
      { name: string; slug: string; total: number; rounds: number }
    > = {};
    filtered.forEach((r) => {
      const org = r.organizations;
      if (!org) return;
      if (!byCompany[org.slug])
        byCompany[org.slug] = {
          name: org.name,
          slug: org.slug,
          total: 0,
          rounds: 0,
        };
      byCompany[org.slug].total += r.amount_eur ?? 0;
      byCompany[org.slug].rounds += 1;
    });
    return Object.values(byCompany)
      .sort((a, b) => b.total - a.total)
      .slice(0, 10);
  }, [filtered]);

  // Top investors
  const topInvestors = useMemo(() => {
    const byInvestor: Record<
      string,
      { name: string; slug: string | null; deals: number; asLead: number }
    > = {};
    filtered.forEach((r) => {
      (r.funding_round_investors ?? []).forEach((inv) => {
        const name = inv.organizations?.name ?? inv.investor_name ?? "Unknown";
        const slug = inv.organizations?.slug ?? null;
        const key = slug ?? name;
        if (!byInvestor[key])
          byInvestor[key] = { name, slug, deals: 0, asLead: 0 };
        byInvestor[key].deals += 1;
        if (inv.is_lead) byInvestor[key].asLead += 1;
      });
    });
    return Object.values(byInvestor)
      .sort((a, b) => b.deals - a.deals)
      .slice(0, 10);
  }, [filtered]);

  // Stage pie data
  const stagePieData = useMemo(() => {
    return stageData
      .filter((s) => s.count > 0)
      .map((s, i) => ({
        ...s,
        color: CHART_COLORS[i % CHART_COLORS.length],
      }));
  }, [stageData]);

  // Monthly timeline (recent 24 months)
  const monthlyData = useMemo(() => {
    const byMonth: Record<string, { capital: number; count: number }> = {};
    filtered.forEach((r) => {
      const mk = getMonthKey(r.announced_date);
      if (!mk) return;
      if (!byMonth[mk]) byMonth[mk] = { capital: 0, count: 0 };
      byMonth[mk].capital += r.amount_eur ?? 0;
      byMonth[mk].count += 1;
    });
    return Object.entries(byMonth)
      .map(([month, d]) => ({
        month,
        label: formatMonthLabel(month),
        capital: d.capital,
        count: d.count,
      }))
      .sort((a, b) => a.month.localeCompare(b.month))
      .slice(-24);
  }, [filtered]);

  // Sector breakdown
  const sectorData = useMemo(() => {
    const bySector: Record<string, { capital: number; count: number }> = {};
    filtered.forEach((r) => {
      const sector = getSector(r);
      if (!bySector[sector]) bySector[sector] = { capital: 0, count: 0 };
      bySector[sector].capital += r.amount_eur ?? 0;
      bySector[sector].count += 1;
    });
    return Object.entries(bySector)
      .map(([sector, d], i) => ({
        sector,
        capital: d.capital,
        count: d.count,
        color: CHART_COLORS[i % CHART_COLORS.length],
      }))
      .sort((a, b) => b.capital - a.capital)
      .slice(0, 12);
  }, [filtered]);

  // Toggle sort
  function toggleSort(key: SortKey) {
    if (sortKey === key) {
      setSortDir((d) => (d === "desc" ? "asc" : "desc"));
    } else {
      setSortKey(key);
      setSortDir("desc");
    }
  }

  function toggleStage(stage: string) {
    setSelectedStages((prev) => {
      const next = new Set(prev);
      if (next.has(stage)) next.delete(stage);
      else next.add(stage);
      return next;
    });
  }

  // Custom tooltip
  const ChartTooltip = ({
    active,
    payload,
    label,
  }: {
    active?: boolean;
    payload?: { value: number }[];
    label?: string;
  }) => {
    if (!active || !payload?.length) return null;
    return (
      <div className="bg-surface-container-lowest px-3 py-2 ambient-shadow">
        <p className="text-xs font-medium text-on-surface">{label}</p>
        <p className="text-xs text-primary">{formatEur(payload[0].value)}</p>
      </div>
    );
  };

  return (
    <div className="px-10 py-8">
      {/* Header */}
      <div className="flex items-start justify-between">
        <div>
          <h1 className="font-headline text-3xl font-semibold tracking-tight text-primary">
            Funding Tracker
          </h1>
          <p className="mt-1 text-sm text-on-surface-variant">
            French innovation ecosystem capital flows · 2000–2026
          </p>
        </div>

        {/* View Toggle */}
        <div className="flex items-center gap-1 bg-surface-container-low p-1">
          <button
            onClick={() => setActiveView("charts")}
            className={`px-3 py-1.5 text-xs font-medium transition-colors ${
              activeView === "charts"
                ? "bg-surface-container-lowest text-primary"
                : "text-on-surface-variant hover:text-on-surface"
            }`}
          >
            Dashboard
          </button>
          <button
            onClick={() => setActiveView("table")}
            className={`px-3 py-1.5 text-xs font-medium transition-colors ${
              activeView === "table"
                ? "bg-surface-container-lowest text-primary"
                : "text-on-surface-variant hover:text-on-surface"
            }`}
          >
            Table View
          </button>
        </div>
      </div>

      {error && (
        <div className="mt-6 bg-error-container p-4 text-sm text-on-error-container">
          {error}
        </div>
      )}

      {/* KPI Bar */}
      <div className="mt-6 flex items-center justify-between bg-surface-container-low px-8 py-6">
        <div>
          <p className="diplomatic-label">Total Capital</p>
          <p className="mt-1 font-headline text-3xl font-semibold tracking-tight text-on-surface">
            {formatEur(stats.totalCapital)}
          </p>
        </div>
        <div>
          <p className="diplomatic-label">Rounds</p>
          <p className="mt-1 font-headline text-3xl font-semibold tracking-tight text-on-surface">
            {stats.roundCount.toLocaleString()}
          </p>
        </div>
        <div>
          <p className="diplomatic-label">Average Round</p>
          <p className="mt-1 font-headline text-3xl font-semibold tracking-tight text-on-surface">
            {formatEur(stats.avgRound)}
          </p>
        </div>
        <div>
          <p className="diplomatic-label">Median Round</p>
          <p className="mt-1 font-headline text-3xl font-semibold tracking-tight text-on-surface">
            {formatEur(stats.medianRound)}
          </p>
        </div>
        <div>
          <p className="diplomatic-label">Verified</p>
          <p className="mt-1 font-headline text-3xl font-semibold tracking-tight text-on-surface">
            {stats.verified}
          </p>
        </div>
      </div>

      {/* Amount diagnostic — shows raw values to debug unit issues */}
      {stats.roundCount > 0 && stats.totalCapital < 100_000 && (
        <div className="mt-4 bg-secondary-container/30 px-6 py-3 text-xs text-on-surface-variant">
          <span className="font-semibold text-secondary">Data note:</span>{" "}
          Total capital appears low (raw sum: €{stats.totalCapital.toLocaleString()}).
          Amounts in the database may be stored in thousands or millions rather
          than raw euros. Check the <code className="font-mono">amount_eur</code> column
          in Supabase — e.g. if Mistral shows 2000 it likely means €2,000M
          (amounts stored in thousands).
        </div>
      )}

      {/* Filters */}
      <div className="mt-6 flex flex-wrap items-center gap-4">
        {/* Search */}
        <div className="flex items-center gap-2 bg-surface-container-lowest px-3 py-2">
          <span className="material-symbols-outlined text-[16px] text-outline">
            search
          </span>
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search company or investor..."
            className="w-56 bg-transparent text-sm text-on-surface placeholder:text-outline-variant focus:outline-none"
          />
        </div>

        {/* Year range */}
        <div className="flex items-center gap-2">
          <span className="text-xs text-on-surface-variant">From</span>
          <input
            type="number"
            min={2000}
            max={2026}
            value={yearRange[0]}
            onChange={(e) =>
              setYearRange([parseInt(e.target.value) || 2000, yearRange[1]])
            }
            className="w-16 border-b border-outline-variant/25 bg-transparent py-1 text-center text-sm text-on-surface focus:border-primary focus:outline-none"
          />
          <span className="text-xs text-on-surface-variant">to</span>
          <input
            type="number"
            min={2000}
            max={2026}
            value={yearRange[1]}
            onChange={(e) =>
              setYearRange([yearRange[0], parseInt(e.target.value) || 2026])
            }
            className="w-16 border-b border-outline-variant/25 bg-transparent py-1 text-center text-sm text-on-surface focus:border-primary focus:outline-none"
          />
        </div>

        {/* Stage chips */}
        <div className="flex flex-wrap gap-1.5">
          {allStages.map((stage) => (
            <button
              key={stage}
              onClick={() => toggleStage(stage)}
              className={`px-2 py-1 text-xs font-medium transition-colors ${
                selectedStages.has(stage)
                  ? "bg-primary text-on-primary"
                  : "bg-surface-container-lowest text-on-surface-variant hover:bg-surface-container-low"
              }`}
            >
              {formatStage(stage)}
            </button>
          ))}
          {selectedStages.size > 0 && (
            <button
              onClick={() => setSelectedStages(new Set())}
              className="px-2 py-1 text-xs text-error hover:text-on-error-container"
            >
              Clear
            </button>
          )}
        </div>
      </div>

      {/* ─── Dashboard View ──────────────────────────────────── */}
      {activeView === "charts" && (
        <div className="mt-8 space-y-8">
          {/* Row 1: Annual Timeline + Stage Breakdown */}
          <div className="grid grid-cols-3 gap-8">
            {/* Annual Capital Flow */}
            <div className="col-span-2 bg-surface-container-lowest p-6">
              <h2 className="diplomatic-label mb-4">
                Annual Capital Flow
              </h2>
              {annualData.length > 0 ? (
                <ResponsiveContainer width="100%" height={280}>
                  <AreaChart data={annualData}>
                    <defs>
                      <linearGradient id="capitalGrad" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="5%" stopColor="#114563" stopOpacity={0.15} />
                        <stop offset="95%" stopColor="#114563" stopOpacity={0} />
                      </linearGradient>
                    </defs>
                    <CartesianGrid strokeDasharray="3 3" stroke="#c1c7ce30" />
                    <XAxis
                      dataKey="year"
                      tick={{ fontSize: 11, fill: "#41474d" }}
                      axisLine={false}
                      tickLine={false}
                    />
                    <YAxis
                      tick={{ fontSize: 11, fill: "#41474d" }}
                      axisLine={false}
                      tickLine={false}
                      tickFormatter={(v) => formatEur(v)}
                    />
                    <Tooltip content={<ChartTooltip />} />
                    <Area
                      type="monotone"
                      dataKey="capital"
                      stroke="#114563"
                      strokeWidth={2}
                      fill="url(#capitalGrad)"
                    />
                  </AreaChart>
                </ResponsiveContainer>
              ) : (
                <div className="flex h-[280px] items-center justify-center">
                  <p className="font-headline italic text-on-surface-variant">
                    No annual data to display
                  </p>
                </div>
              )}
            </div>

            {/* Stage Distribution (Pie) */}
            <div className="bg-surface-container-lowest p-6">
              <h2 className="diplomatic-label mb-4">
                Stage Distribution
              </h2>
              {stagePieData.length > 0 ? (
                <>
                  <ResponsiveContainer width="100%" height={200}>
                    <PieChart>
                      <Pie
                        data={stagePieData}
                        dataKey="count"
                        nameKey="stage"
                        cx="50%"
                        cy="50%"
                        innerRadius={50}
                        outerRadius={80}
                        paddingAngle={2}
                      >
                        {stagePieData.map((entry, i) => (
                          <Cell key={i} fill={entry.color} />
                        ))}
                      </Pie>
                      <Tooltip
                        formatter={(value, name) => [
                          `${value} rounds`,
                          String(name),
                        ]}
                      />
                    </PieChart>
                  </ResponsiveContainer>
                  <div className="mt-2 space-y-1">
                    {stagePieData.slice(0, 6).map((s) => (
                      <div
                        key={s.stage}
                        className="flex items-center justify-between text-xs"
                      >
                        <div className="flex items-center gap-2">
                          <span
                            className="inline-block h-2 w-2"
                            style={{ backgroundColor: s.color }}
                          />
                          <span className="text-on-surface-variant">
                            {s.stage}
                          </span>
                        </div>
                        <span className="text-on-surface">{s.count}</span>
                      </div>
                    ))}
                  </div>
                </>
              ) : (
                <div className="flex h-[200px] items-center justify-center">
                  <p className="font-headline italic text-on-surface-variant">
                    No data
                  </p>
                </div>
              )}
            </div>
          </div>

          {/* Row 2: Monthly Timeline (recent 24 months) */}
          <div className="grid grid-cols-1 gap-8">
            <div className="bg-surface-container-lowest p-6">
              <h2 className="diplomatic-label mb-4">
                Monthly Capital Flow (Recent 24 Months)
              </h2>
              {monthlyData.length > 0 ? (
                <ResponsiveContainer width="100%" height={280}>
                  <BarChart data={monthlyData}>
                    <CartesianGrid strokeDasharray="3 3" stroke="#c1c7ce30" />
                    <XAxis
                      dataKey="label"
                      tick={{ fontSize: 10, fill: "#41474d" }}
                      axisLine={false}
                      tickLine={false}
                      interval={1}
                      angle={-45}
                      textAnchor="end"
                      height={60}
                    />
                    <YAxis
                      tick={{ fontSize: 11, fill: "#41474d" }}
                      axisLine={false}
                      tickLine={false}
                      tickFormatter={(v) => formatEur(v)}
                    />
                    <Tooltip content={<ChartTooltip />} />
                    <Bar dataKey="capital" fill="#2f5d7c" />
                  </BarChart>
                </ResponsiveContainer>
              ) : (
                <div className="flex h-[280px] items-center justify-center">
                  <p className="font-headline italic text-on-surface-variant">
                    No monthly data to display
                  </p>
                </div>
              )}
            </div>
          </div>

          {/* Row 3: Sector Breakdown + Capital by Stage */}
          <div className="grid grid-cols-2 gap-8">
            {/* Sector Breakdown */}
            <div className="bg-surface-container-lowest p-6">
              <h2 className="diplomatic-label mb-4">Funding by Sector</h2>
              {sectorData.length > 0 ? (
                <>
                  <ResponsiveContainer width="100%" height={260}>
                    <BarChart data={sectorData} layout="vertical">
                      <CartesianGrid
                        strokeDasharray="3 3"
                        stroke="#c1c7ce30"
                        horizontal={false}
                      />
                      <XAxis
                        type="number"
                        tick={{ fontSize: 11, fill: "#41474d" }}
                        axisLine={false}
                        tickLine={false}
                        tickFormatter={(v) => formatEur(v)}
                      />
                      <YAxis
                        type="category"
                        dataKey="sector"
                        tick={{ fontSize: 10, fill: "#41474d" }}
                        axisLine={false}
                        tickLine={false}
                        width={120}
                      />
                      <Tooltip content={<ChartTooltip />} />
                      <Bar dataKey="capital" fill="#503863" />
                    </BarChart>
                  </ResponsiveContainer>
                  <div className="mt-3 flex flex-wrap gap-2">
                    {sectorData.map((s) => (
                      <span
                        key={s.sector}
                        className="bg-primary-fixed/60 px-2 py-0.5 text-[0.6rem] text-on-primary-fixed"
                      >
                        {s.sector}: {s.count} rounds
                      </span>
                    ))}
                  </div>
                </>
              ) : (
                <div className="flex h-[260px] items-center justify-center">
                  <p className="font-headline italic text-on-surface-variant">
                    No sector data — link organizations to sectors
                  </p>
                </div>
              )}
            </div>

            {/* Capital by Stage */}
            <div className="bg-surface-container-lowest p-6">
              <h2 className="diplomatic-label mb-4">Capital by Stage</h2>
              {stageData.length > 0 ? (
                <ResponsiveContainer width="100%" height={280}>
                  <BarChart data={stageData} layout="vertical">
                    <CartesianGrid
                      strokeDasharray="3 3"
                      stroke="#c1c7ce30"
                      horizontal={false}
                    />
                    <XAxis
                      type="number"
                      tick={{ fontSize: 11, fill: "#41474d" }}
                      axisLine={false}
                      tickLine={false}
                      tickFormatter={(v) => formatEur(v)}
                    />
                    <YAxis
                      type="category"
                      dataKey="stage"
                      tick={{ fontSize: 11, fill: "#41474d" }}
                      axisLine={false}
                      tickLine={false}
                      width={90}
                    />
                    <Tooltip content={<ChartTooltip />} />
                    <Bar dataKey="capital" fill="#114563" radius={[0, 0, 0, 0]} />
                  </BarChart>
                </ResponsiveContainer>
              ) : (
                <div className="flex h-[280px] items-center justify-center">
                  <p className="font-headline italic text-on-surface-variant">
                    No data
                  </p>
                </div>
              )}
            </div>

          </div>

          {/* Row 4: Deal Count by Year */}
          <div className="grid grid-cols-1 gap-8">
            <div className="bg-surface-container-lowest p-6">
              <h2 className="diplomatic-label mb-4">Deal Count by Year</h2>
              {annualData.length > 0 ? (
                <ResponsiveContainer width="100%" height={280}>
                  <BarChart data={annualData}>
                    <CartesianGrid strokeDasharray="3 3" stroke="#c1c7ce30" />
                    <XAxis
                      dataKey="year"
                      tick={{ fontSize: 11, fill: "#41474d" }}
                      axisLine={false}
                      tickLine={false}
                    />
                    <YAxis
                      tick={{ fontSize: 11, fill: "#41474d" }}
                      axisLine={false}
                      tickLine={false}
                    />
                    <Tooltip
                      formatter={(value) => [
                        `${value} deals`,
                        "Count",
                      ]}
                    />
                    <Bar dataKey="count" fill="#3c6840" radius={[0, 0, 0, 0]} />
                  </BarChart>
                </ResponsiveContainer>
              ) : (
                <div className="flex h-[280px] items-center justify-center">
                  <p className="font-headline italic text-on-surface-variant">
                    No data
                  </p>
                </div>
              )}
            </div>
          </div>

          {/* Row 5: Top Companies + Top Investors */}
          <div className="grid grid-cols-2 gap-8">
            {/* Top Funded Companies */}
            <div className="bg-surface-container-lowest p-6">
              <h2 className="diplomatic-label mb-4">
                Top Funded Companies
              </h2>
              {topCompanies.length > 0 ? (
                <div className="space-y-3">
                  {topCompanies.map((c, i) => (
                    <div key={c.slug} className="flex items-center gap-3">
                      <span className="w-5 text-right text-xs text-outline">
                        {i + 1}
                      </span>
                      <div className="flex-1 min-w-0">
                        <div className="flex items-center justify-between">
                          <Link
                            href={`/entities/${c.slug}`}
                            className="truncate text-sm font-medium text-on-surface hover:text-primary"
                          >
                            {c.name}
                          </Link>
                          <span className="shrink-0 text-sm font-medium text-primary">
                            {formatEur(c.total)}
                          </span>
                        </div>
                        {/* Bar */}
                        <div className="mt-1 h-1.5 w-full bg-surface-container-low">
                          <div
                            className="h-full bg-primary"
                            style={{
                              width: `${
                                topCompanies[0]?.total
                                  ? (c.total / topCompanies[0].total) * 100
                                  : 0
                              }%`,
                            }}
                          />
                        </div>
                        <p className="mt-0.5 text-[0.6rem] text-on-surface-variant">
                          {c.rounds} round{c.rounds !== 1 ? "s" : ""}
                        </p>
                      </div>
                    </div>
                  ))}
                </div>
              ) : (
                <p className="font-headline italic text-on-surface-variant">
                  No data
                </p>
              )}
            </div>

            {/* Most Active Investors */}
            <div className="bg-surface-container-lowest p-6">
              <h2 className="diplomatic-label mb-4">
                Most Active Investors
              </h2>
              {topInvestors.length > 0 ? (
                <div className="space-y-3">
                  {topInvestors.map((inv, i) => (
                    <div key={inv.slug ?? inv.name} className="flex items-center gap-3">
                      <span className="w-5 text-right text-xs text-outline">
                        {i + 1}
                      </span>
                      <div className="flex-1 min-w-0">
                        <div className="flex items-center justify-between">
                          {inv.slug ? (
                            <Link
                              href={`/entities/${inv.slug}`}
                              className="truncate text-sm font-medium text-on-surface hover:text-primary"
                            >
                              {inv.name}
                            </Link>
                          ) : (
                            <span className="truncate text-sm text-on-surface">
                              {inv.name}
                            </span>
                          )}
                          <span className="shrink-0 text-sm font-medium text-secondary">
                            {inv.deals} deals
                          </span>
                        </div>
                        {/* Bar */}
                        <div className="mt-1 h-1.5 w-full bg-surface-container-low">
                          <div
                            className="h-full bg-secondary"
                            style={{
                              width: `${
                                topInvestors[0]?.deals
                                  ? (inv.deals / topInvestors[0].deals) * 100
                                  : 0
                              }%`,
                            }}
                          />
                        </div>
                        {inv.asLead > 0 && (
                          <p className="mt-0.5 text-[0.6rem] text-on-surface-variant">
                            {inv.asLead} as lead
                          </p>
                        )}
                      </div>
                    </div>
                  ))}
                </div>
              ) : (
                <p className="font-headline italic text-on-surface-variant">
                  No data
                </p>
              )}
            </div>
          </div>
        </div>
      )}

      {/* ─── Table View ──────────────────────────────────────── */}
      {activeView === "table" && (
        <div className="mt-8">
          {/* Sortable Header */}
          <div className="flex items-center gap-4 px-5 py-3 text-xs">
            <div className="flex-1">
              <SortButton
                label="Company"
                sortKey="company"
                currentKey={sortKey}
                dir={sortDir}
                onClick={toggleSort}
              />
            </div>
            <div className="w-28">
              <SortButton
                label="Stage"
                sortKey="stage"
                currentKey={sortKey}
                dir={sortDir}
                onClick={toggleSort}
              />
            </div>
            <div className="w-28 text-right">
              <SortButton
                label="Amount"
                sortKey="amount"
                currentKey={sortKey}
                dir={sortDir}
                onClick={toggleSort}
              />
            </div>
            <div className="w-28 text-right">
              <SortButton
                label="Date"
                sortKey="date"
                currentKey={sortKey}
                dir={sortDir}
                onClick={toggleSort}
              />
            </div>
            <div className="w-48">
              <span className="diplomatic-label">Lead Investor</span>
            </div>
            <div className="w-16 text-center">
              <span className="diplomatic-label">Status</span>
            </div>
          </div>

          <div className="space-y-1">
            {sorted.map((round) => {
              const company = round.organizations;
              const investors = round.funding_round_investors ?? [];
              const lead = investors.find((i) => i.is_lead);
              const leadOrg = lead?.organizations;
              const leadName = leadOrg?.name ?? lead?.investor_name ?? "—";

              return (
                <div
                  key={round.id}
                  className="flex items-center gap-4 bg-surface-container-lowest px-5 py-4 transition-colors duration-200 hover:bg-surface-container-low"
                >
                  <div className="flex-1 min-w-0">
                    {company ? (
                      <Link
                        href={`/entities/${company.slug}`}
                        className="text-sm font-medium text-on-surface hover:text-primary"
                      >
                        {company.name}
                      </Link>
                    ) : (
                      <span className="text-sm text-on-surface-variant">—</span>
                    )}
                  </div>

                  <div className="w-28">
                    <span className="text-sm text-on-surface">
                      {formatStage(round.stage)}
                    </span>
                  </div>

                  <div className="w-28 text-right">
                    <span className="text-sm font-medium text-on-surface">
                      {formatEur(round.amount_eur)}
                    </span>
                    {round.is_estimated && (
                      <span className="ml-1 text-[0.6rem] text-on-surface-variant">
                        est.
                      </span>
                    )}
                  </div>

                  <div className="w-28 text-right">
                    <span className="text-sm text-on-surface-variant">
                      {round.announced_date
                        ? new Date(round.announced_date).toLocaleDateString(
                            "en-GB",
                            { month: "short", year: "numeric" }
                          )
                        : "—"}
                    </span>
                  </div>

                  <div className="w-48 min-w-0">
                    {leadOrg ? (
                      <Link
                        href={`/entities/${leadOrg.slug}`}
                        className="truncate text-sm text-on-surface hover:text-primary"
                      >
                        {leadName}
                      </Link>
                    ) : (
                      <span className="truncate text-sm text-on-surface-variant">
                        {leadName}
                      </span>
                    )}
                    {investors.length > 1 && (
                      <span className="ml-1 text-[0.6rem] text-on-surface-variant">
                        +{investors.length - 1}
                      </span>
                    )}
                  </div>

                  <div className="w-16 text-center">
                    {round.is_verified ? (
                      <span className="material-symbols-outlined text-[16px] text-secondary">
                        verified
                      </span>
                    ) : (
                      <span className="material-symbols-outlined text-[16px] text-outline-variant">
                        pending
                      </span>
                    )}
                  </div>
                </div>
              );
            })}
          </div>

          {sorted.length === 0 && !error && (
            <div className="py-20 text-center">
              <p className="font-headline text-lg italic text-on-surface-variant">
                No funding rounds match the current filters.
              </p>
            </div>
          )}

          <div className="mt-4 text-xs text-on-surface-variant">
            Showing {sorted.length} of {rounds.length} rounds
          </div>
        </div>
      )}
    </div>
  );
}

// ─── Sort Button ──────────────────────────────────────────

function SortButton({
  label,
  sortKey,
  currentKey,
  dir,
  onClick,
}: {
  label: string;
  sortKey: SortKey;
  currentKey: SortKey;
  dir: SortDir;
  onClick: (key: SortKey) => void;
}) {
  const isActive = currentKey === sortKey;
  return (
    <button
      onClick={() => onClick(sortKey)}
      className="diplomatic-label flex items-center gap-1 hover:text-on-surface"
    >
      {label}
      {isActive && (
        <span className="material-symbols-outlined text-[12px]">
          {dir === "desc" ? "arrow_downward" : "arrow_upward"}
        </span>
      )}
    </button>
  );
}
