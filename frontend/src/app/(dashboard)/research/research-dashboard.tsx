"use client";

import { useMemo, useState } from "react";
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

interface Funding {
  id: string;
  type: string | null;
  year: number | null;
  acronym: string | null;
  label: string | null;
  call: string | null;
  startdate: string | null;
  keywords: string | null;
  participantcount: number | null;
}

interface ILabLaureate {
  annee_de_concours: number | null;
  nom_du_laureat: string | null;
  prenom_du_candidat: string | null;
  domaine_technologique: string | null;
  region: string | null;
  libelle_entreprise: string | null;
  site_web_entreprise: string | null;
  unite_de_recherche_liee_au_projet: string | null;
  structure_liee_au_projet: string | null;
  type_de_candidatura: string | null;
  grand_prix: string | null;
}

interface CirApproved {
  dispositif: string | null;
  siren: string | null;
  entreprise: string | null;
  sigle: string | null;
  categorie: string | null;
  activite: string | null;
  ville: string | null;
  reg_nom: string | null;
  annees: string | null;
  scanr: string | null;
}

interface Props {
  funding: Record<string, unknown>[];
  ilab: Record<string, unknown>[];
  cir: Record<string, unknown>[];
  fundingStats: Record<string, unknown>;
  error: string | null;
}

const COLORS = [
  "#114563", "#2f5d7c", "#3c6840", "#5E8C61", "#503863",
  "#684f7c", "#7C8C9E", "#9fccef", "#C9C1B3", "#775a0f",
];

export function ResearchDashboard({
  funding: rawFunding,
  ilab: rawIlab,
  cir: rawCir,
  fundingStats,
  error,
}: Props) {
  const funding = rawFunding as unknown as Funding[];
  const ilab = rawIlab as unknown as ILabLaureate[];
  const cir = rawCir as unknown as CirApproved[];
  const byType = (fundingStats.byType ?? []) as { type: string; count: number }[];
  const byYear = (fundingStats.byYear ?? []) as { year: number; count: number }[];
  const fundingTotal = (fundingStats.total ?? 0) as number;

  const [activeTab, setActiveTab] = useState<"grants" | "ilab" | "cir">("grants");
  const [searchQuery, setSearchQuery] = useState("");

  // ─── Grant Analytics ─────────────────────────────────────

  const typePieData = useMemo(() => {
    return byType.slice(0, 10).map((t, i) => ({
      name: t.type || "Other",
      value: t.count,
      color: COLORS[i % COLORS.length],
    }));
  }, [byType]);

  const yearAreaData = useMemo(() => {
    return [...byYear]
      .filter((y) => y.year)
      .sort((a, b) => a.year - b.year)
      .slice(-25);
  }, [byYear]);

  const filteredFunding = useMemo(() => {
    if (!searchQuery) return funding;
    const q = searchQuery.toLowerCase();
    return funding.filter(
      (f) =>
        f.label?.toLowerCase().includes(q) ||
        f.acronym?.toLowerCase().includes(q) ||
        f.keywords?.toLowerCase().includes(q)
    );
  }, [funding, searchQuery]);

  // ─── i-Lab Analytics ─────────────────────────────────────

  const ilabByYear = useMemo(() => {
    const acc: Record<number, number> = {};
    ilab.forEach((l) => {
      if (l.annee_de_concours) {
        acc[l.annee_de_concours] = (acc[l.annee_de_concours] ?? 0) + 1;
      }
    });
    return Object.entries(acc)
      .map(([year, count]) => ({ year: Number(year), count }))
      .sort((a, b) => a.year - b.year);
  }, [ilab]);

  const ilabByDomain = useMemo(() => {
    const acc: Record<string, number> = {};
    ilab.forEach((l) => {
      const d = l.domaine_technologique ?? "Other";
      acc[d] = (acc[d] ?? 0) + 1;
    });
    return Object.entries(acc)
      .map(([domain, count], i) => ({
        name: domain,
        value: count,
        color: COLORS[i % COLORS.length],
      }))
      .sort((a, b) => b.value - a.value)
      .slice(0, 10);
  }, [ilab]);

  const filteredIlab = useMemo(() => {
    if (!searchQuery) return ilab;
    const q = searchQuery.toLowerCase();
    return ilab.filter(
      (l) =>
        l.nom_du_laureat?.toLowerCase().includes(q) ||
        l.libelle_entreprise?.toLowerCase().includes(q) ||
        l.domaine_technologique?.toLowerCase().includes(q) ||
        l.unite_de_recherche_liee_au_projet?.toLowerCase().includes(q)
    );
  }, [ilab, searchQuery]);

  // ─── CIR/CII Analytics ──────────────────────────────────

  const cirByActivity = useMemo(() => {
    const acc: Record<string, number> = {};
    cir.forEach((c) => {
      const a = c.activite ?? "Other";
      acc[a] = (acc[a] ?? 0) + 1;
    });
    return Object.entries(acc)
      .map(([activity, count]) => ({ activity, count }))
      .sort((a, b) => b.count - a.count)
      .slice(0, 12);
  }, [cir]);

  const filteredCir = useMemo(() => {
    if (!searchQuery) return cir;
    const q = searchQuery.toLowerCase();
    return cir.filter(
      (c) =>
        c.entreprise?.toLowerCase().includes(q) ||
        c.activite?.toLowerCase().includes(q) ||
        c.ville?.toLowerCase().includes(q)
    );
  }, [cir, searchQuery]);

  return (
    <div className="px-10 py-8">
      {/* Header */}
      <div className="flex items-start justify-between">
        <div>
          <p className="diplomatic-label">
            Research Funding & Innovation Programs · Live Open Data
          </p>
          <h1 className="mt-2 font-headline text-3xl font-semibold tracking-tight text-primary">
            Research Intelligence
          </h1>
          <p className="mt-1 text-sm text-on-surface-variant">
            EU grants, national innovation competitions, and research tax credits
          </p>
        </div>
        <div className="flex gap-8 text-right">
          <div>
            <p className="diplomatic-label">Research Grants</p>
            <p className="mt-1 font-headline text-3xl font-semibold tracking-tight text-on-surface">
              {fundingTotal.toLocaleString()}
            </p>
          </div>
          <div>
            <p className="diplomatic-label">i-Lab Laureates</p>
            <p className="mt-1 font-headline text-3xl font-semibold tracking-tight text-on-surface">
              {ilab.length}
            </p>
          </div>
          <div>
            <p className="diplomatic-label">CIR/CII Orgs</p>
            <p className="mt-1 font-headline text-3xl font-semibold tracking-tight text-on-surface">
              {cir.length}
            </p>
          </div>
        </div>
      </div>

      {error && (
        <div className="mt-6 bg-error-container p-4 text-sm text-on-error-container">
          {error}
        </div>
      )}

      {/* Tabs + Search */}
      <div className="mt-6 flex items-center justify-between">
        <div className="flex items-center gap-1 bg-surface-container-low p-1">
          <TabBtn active={activeTab === "grants"} onClick={() => setActiveTab("grants")}>
            EU Research Grants
          </TabBtn>
          <TabBtn active={activeTab === "ilab"} onClick={() => setActiveTab("ilab")}>
            i-Lab / Innovation
          </TabBtn>
          <TabBtn active={activeTab === "cir"} onClick={() => setActiveTab("cir")}>
            CIR / CII Tax Credits
          </TabBtn>
        </div>

        <div className="flex items-center gap-2 bg-surface-container-lowest px-3 py-2">
          <span className="material-symbols-outlined text-[16px] text-outline">
            search
          </span>
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search grants, laureates, companies..."
            className="w-64 bg-transparent text-sm text-on-surface placeholder:text-outline-variant focus:outline-none"
          />
        </div>
      </div>

      {/* ─── EU Research Grants Tab ──────────────────────── */}
      {activeTab === "grants" && (
        <>
          <div className="mt-6 grid grid-cols-3 gap-8">
            <div className="col-span-2 bg-surface-container-lowest p-6">
              <h2 className="diplomatic-label mb-4">Grants per Year</h2>
              {yearAreaData.length > 0 ? (
                <ResponsiveContainer width="100%" height={250}>
                  <AreaChart data={yearAreaData}>
                    <defs>
                      <linearGradient id="grantGrad" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="5%" stopColor="#114563" stopOpacity={0.15} />
                        <stop offset="95%" stopColor="#114563" stopOpacity={0} />
                      </linearGradient>
                    </defs>
                    <CartesianGrid strokeDasharray="3 3" stroke="#c1c7ce30" />
                    <XAxis dataKey="year" tick={{ fontSize: 11, fill: "#41474d" }} axisLine={false} tickLine={false} />
                    <YAxis tick={{ fontSize: 11, fill: "#41474d" }} axisLine={false} tickLine={false} />
                    <Tooltip />
                    <Area type="monotone" dataKey="count" stroke="#114563" strokeWidth={2} fill="url(#grantGrad)" />
                  </AreaChart>
                </ResponsiveContainer>
              ) : <EmptyChart />}
            </div>
            <div className="bg-surface-container-lowest p-6">
              <h2 className="diplomatic-label mb-4">Program Type</h2>
              {typePieData.length > 0 ? (
                <>
                  <ResponsiveContainer width="100%" height={160}>
                    <PieChart>
                      <Pie data={typePieData} dataKey="value" nameKey="name" cx="50%" cy="50%" innerRadius={40} outerRadius={65} paddingAngle={2}>
                        {typePieData.map((e, i) => <Cell key={i} fill={e.color} />)}
                      </Pie>
                      <Tooltip />
                    </PieChart>
                  </ResponsiveContainer>
                  <Legend items={typePieData} />
                </>
              ) : <EmptyChart />}
            </div>
          </div>

          <DataList>
            <ListHeader>
              <div className="flex-1"><span className="diplomatic-label">Project</span></div>
              <div className="w-24"><span className="diplomatic-label">Type</span></div>
              <div className="w-20 text-right"><span className="diplomatic-label">Year</span></div>
              <div className="w-64"><span className="diplomatic-label">Call / Program</span></div>
              <div className="w-20 text-right"><span className="diplomatic-label">Partners</span></div>
            </ListHeader>
            {filteredFunding.map((f, i) => (
              <ListRow key={i}>
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-medium text-on-surface">{f.acronym ?? f.label ?? "—"}</p>
                  {f.label && f.acronym && <p className="mt-0.5 truncate text-xs text-on-surface-variant">{f.label}</p>}
                </div>
                <div className="w-24"><span className="text-xs text-on-surface-variant">{f.type ?? "—"}</span></div>
                <div className="w-20 text-right"><span className="text-xs text-on-surface">{f.year ?? "—"}</span></div>
                <div className="w-64 min-w-0"><span className="truncate text-xs text-on-surface-variant">{f.call ?? "—"}</span></div>
                <div className="w-20 text-right"><span className="text-xs text-on-surface">{f.participantcount ?? "—"}</span></div>
              </ListRow>
            ))}
            <p className="mt-2 text-xs text-on-surface-variant">
              Showing {filteredFunding.length} of {fundingTotal.toLocaleString()} grants
            </p>
          </DataList>
        </>
      )}

      {/* ─── i-Lab / Innovation Tab ──────────────────────── */}
      {activeTab === "ilab" && (
        <>
          <div className="mt-6 grid grid-cols-3 gap-8">
            <div className="col-span-2 bg-surface-container-lowest p-6">
              <h2 className="diplomatic-label mb-4">i-Lab Laureates per Year</h2>
              {ilabByYear.length > 0 ? (
                <ResponsiveContainer width="100%" height={250}>
                  <BarChart data={ilabByYear}>
                    <CartesianGrid strokeDasharray="3 3" stroke="#c1c7ce30" />
                    <XAxis dataKey="year" tick={{ fontSize: 11, fill: "#41474d" }} axisLine={false} tickLine={false} />
                    <YAxis tick={{ fontSize: 11, fill: "#41474d" }} axisLine={false} tickLine={false} />
                    <Tooltip />
                    <Bar dataKey="count" fill="#3c6840" />
                  </BarChart>
                </ResponsiveContainer>
              ) : <EmptyChart />}
            </div>
            <div className="bg-surface-container-lowest p-6">
              <h2 className="diplomatic-label mb-4">Technology Domain</h2>
              {ilabByDomain.length > 0 ? (
                <>
                  <ResponsiveContainer width="100%" height={160}>
                    <PieChart>
                      <Pie data={ilabByDomain} dataKey="value" nameKey="name" cx="50%" cy="50%" innerRadius={40} outerRadius={65} paddingAngle={2}>
                        {ilabByDomain.map((e, i) => <Cell key={i} fill={e.color} />)}
                      </Pie>
                      <Tooltip />
                    </PieChart>
                  </ResponsiveContainer>
                  <Legend items={ilabByDomain} />
                </>
              ) : <EmptyChart />}
            </div>
          </div>

          <DataList>
            <ListHeader>
              <div className="flex-1"><span className="diplomatic-label">Laureate</span></div>
              <div className="w-20 text-right"><span className="diplomatic-label">Year</span></div>
              <div className="w-44"><span className="diplomatic-label">Domain</span></div>
              <div className="w-40"><span className="diplomatic-label">Company</span></div>
              <div className="w-44"><span className="diplomatic-label">Research Unit</span></div>
            </ListHeader>
            {filteredIlab.map((l, i) => (
              <ListRow key={i}>
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-medium text-on-surface">
                    {l.prenom_du_candidat} {l.nom_du_laureat}
                  </p>
                  {l.grand_prix && (
                    <span className="text-[0.6rem] font-semibold text-secondary">
                      GRAND PRIX
                    </span>
                  )}
                </div>
                <div className="w-20 text-right"><span className="text-xs text-on-surface">{l.annee_de_concours ?? "—"}</span></div>
                <div className="w-44"><span className="text-xs text-on-surface-variant">{l.domaine_technologique ?? "—"}</span></div>
                <div className="w-40 min-w-0">
                  {l.libelle_entreprise ? (
                    <span className="truncate text-xs text-on-surface">{l.libelle_entreprise}</span>
                  ) : (
                    <span className="text-xs text-outline-variant">—</span>
                  )}
                </div>
                <div className="w-44 min-w-0">
                  <span className="truncate text-xs text-on-surface-variant">
                    {l.unite_de_recherche_liee_au_projet ?? l.structure_liee_au_projet ?? "—"}
                  </span>
                </div>
              </ListRow>
            ))}
            <p className="mt-2 text-xs text-on-surface-variant">
              Showing {filteredIlab.length} laureates
            </p>
          </DataList>
        </>
      )}

      {/* ─── CIR/CII Tab ────────────────────────────────── */}
      {activeTab === "cir" && (
        <>
          <div className="mt-6 grid grid-cols-3 gap-8">
            <div className="col-span-2 bg-surface-container-lowest p-6">
              <h2 className="diplomatic-label mb-4">CIR/CII by Industry Sector</h2>
              {cirByActivity.length > 0 ? (
                <ResponsiveContainer width="100%" height={280}>
                  <BarChart data={cirByActivity} layout="vertical">
                    <CartesianGrid strokeDasharray="3 3" stroke="#c1c7ce30" horizontal={false} />
                    <XAxis type="number" tick={{ fontSize: 11, fill: "#41474d" }} axisLine={false} tickLine={false} />
                    <YAxis type="category" dataKey="activity" tick={{ fontSize: 10, fill: "#41474d" }} axisLine={false} tickLine={false} width={130} />
                    <Tooltip />
                    <Bar dataKey="count" fill="#503863" />
                  </BarChart>
                </ResponsiveContainer>
              ) : <EmptyChart />}
            </div>
            <div className="bg-surface-container-low p-6">
              <h2 className="diplomatic-label mb-3">About CIR / CII</h2>
              <p className="text-sm leading-relaxed text-on-surface-variant">
                <strong className="text-on-surface">CIR</strong> (Crédit d&apos;Impôt Recherche) —
                France&apos;s research tax credit allows companies to deduct 30% of R&amp;D spending.
                Approved organizations can receive CIR-eligible subcontracting.
              </p>
              <p className="mt-3 text-sm leading-relaxed text-on-surface-variant">
                <strong className="text-on-surface">CII</strong> (Crédit d&apos;Impôt Innovation) —
                Innovation tax credit for SMEs, covering 20% of innovation expenses up to €400K.
              </p>
              <p className="mt-3 text-sm leading-relaxed text-on-surface-variant">
                These connections reveal which companies are actively investing in R&amp;D
                and which labs/institutions they partner with.
              </p>
            </div>
          </div>

          <DataList>
            <ListHeader>
              <div className="flex-1"><span className="diplomatic-label">Company</span></div>
              <div className="w-16"><span className="diplomatic-label">Type</span></div>
              <div className="w-28"><span className="diplomatic-label">Category</span></div>
              <div className="w-32"><span className="diplomatic-label">Sector</span></div>
              <div className="w-28"><span className="diplomatic-label">City</span></div>
              <div className="w-28"><span className="diplomatic-label">Region</span></div>
              <div className="w-20"><span className="diplomatic-label">Years</span></div>
            </ListHeader>
            {filteredCir.map((c, i) => (
              <ListRow key={i}>
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-medium text-on-surface">
                    {c.entreprise ?? "—"}
                  </p>
                  {c.sigle && <span className="text-xs text-on-surface-variant">{c.sigle}</span>}
                  {c.scanr && (
                    <a href={c.scanr} target="_blank" rel="noopener noreferrer" className="ml-2 text-xs text-primary hover:underline">
                      scanR
                    </a>
                  )}
                </div>
                <div className="w-16"><span className="text-[0.65rem] font-semibold text-primary">{c.dispositif ?? "—"}</span></div>
                <div className="w-28"><span className="text-xs text-on-surface-variant">{c.categorie ?? "—"}</span></div>
                <div className="w-32"><span className="text-xs text-on-surface-variant">{c.activite ?? "—"}</span></div>
                <div className="w-28"><span className="text-xs text-on-surface-variant">{c.ville ?? "—"}</span></div>
                <div className="w-28"><span className="text-xs text-on-surface-variant">{c.reg_nom ?? "—"}</span></div>
                <div className="w-20"><span className="text-xs text-on-surface-variant">{c.annees ?? "—"}</span></div>
              </ListRow>
            ))}
            <p className="mt-2 text-xs text-on-surface-variant">
              Showing {filteredCir.length} approved organizations
            </p>
          </DataList>
        </>
      )}
    </div>
  );
}

// ─── Shared UI ────────────────────────────────────────────

function TabBtn({ active, onClick, children }: { active: boolean; onClick: () => void; children: React.ReactNode }) {
  return (
    <button
      onClick={onClick}
      className={`px-4 py-1.5 text-xs font-medium transition-colors ${
        active
          ? "bg-surface-container-lowest text-primary"
          : "text-on-surface-variant hover:text-on-surface"
      }`}
    >
      {children}
    </button>
  );
}

function EmptyChart() {
  return (
    <div className="flex h-[200px] items-center justify-center">
      <p className="font-headline italic text-on-surface-variant">No data available</p>
    </div>
  );
}

function Legend({ items }: { items: { name: string; value: number; color: string }[] }) {
  return (
    <div className="mt-2 space-y-1">
      {items.slice(0, 6).map((item) => (
        <div key={item.name} className="flex items-center justify-between text-xs">
          <div className="flex items-center gap-2">
            <span className="inline-block h-2 w-2" style={{ backgroundColor: item.color }} />
            <span className="truncate text-on-surface-variant">{item.name}</span>
          </div>
          <span className="text-on-surface">{item.value}</span>
        </div>
      ))}
    </div>
  );
}

function DataList({ children }: { children: React.ReactNode }) {
  return <div className="mt-8 space-y-2">{children}</div>;
}

function ListHeader({ children }: { children: React.ReactNode }) {
  return <div className="flex items-center gap-4 px-5 py-2 text-xs">{children}</div>;
}

function ListRow({ children }: { children: React.ReactNode }) {
  return (
    <div className="flex items-center gap-4 bg-surface-container-lowest px-5 py-4 transition-colors hover:bg-surface-container-low">
      {children}
    </div>
  );
}
