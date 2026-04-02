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
} from "recharts";

interface Institution {
  uo_lib: string;
  nom_court: string | null;
  sigle: string | null;
  type_d_etablissement: string | null;
  secteur_d_etablissement: string | null;
  url: string | null;
  uai: string | null;
  siren: string | null;
  com_nom: string | null;
  dep_nom: string | null;
  reg_nom: string | null;
  coordonnees: { lat: number; lon: number } | null;
  inscrits: number | null;
}

interface Lab {
  libelle: string;
  sigle: string | null;
  annee_de_creation: number | null;
  type_de_structure: string | null;
  commune: string | null;
  nom_du_responsable: string | null;
  prenom_du_responsable: string | null;
  tutelles: string | null;
  domaine_scientifique: string | null;
  panel_erc: string | null;
  site_web: string | null;
}

interface Props {
  institutions: Record<string, unknown>[];
  labs: Record<string, unknown>[];
  instStats: Record<string, unknown>;
  labStats: Record<string, unknown>;
  error: string | null;
}

const COLORS = [
  "#114563", "#2f5d7c", "#3c6840", "#5E8C61", "#503863",
  "#684f7c", "#7C8C9E", "#9fccef", "#C9C1B3", "#775a0f",
];

export function InstitutionsDashboard({
  institutions: rawInst,
  labs: rawLabs,
  instStats,
  labStats,
  error,
}: Props) {
  const institutions = rawInst as unknown as Institution[];
  const labs = rawLabs as unknown as Lab[];
  const byType = (instStats.byType ?? []) as { type_d_etablissement: string; count: number }[];
  const byRegion = (instStats.byRegion ?? []) as { reg_nom: string; count: number }[];
  const byDomain = (labStats.byDomain ?? []) as { domaine_scientifique: string; count: number }[];
  const instTotal = (instStats.total ?? 0) as number;
  const labTotal = (labStats.total ?? 0) as number;

  const [activeTab, setActiveTab] = useState<"institutions" | "labs">("institutions");
  const [searchQuery, setSearchQuery] = useState("");

  const filteredInst = useMemo(() => {
    if (!searchQuery) return institutions;
    const q = searchQuery.toLowerCase();
    return institutions.filter(
      (i) =>
        i.uo_lib?.toLowerCase().includes(q) ||
        i.sigle?.toLowerCase().includes(q) ||
        i.com_nom?.toLowerCase().includes(q)
    );
  }, [institutions, searchQuery]);

  const filteredLabs = useMemo(() => {
    if (!searchQuery) return labs;
    const q = searchQuery.toLowerCase();
    return labs.filter(
      (l) =>
        l.libelle?.toLowerCase().includes(q) ||
        l.sigle?.toLowerCase().includes(q) ||
        l.commune?.toLowerCase().includes(q) ||
        l.domaine_scientifique?.toLowerCase().includes(q)
    );
  }, [labs, searchQuery]);

  // Pie data for institution types
  const typePieData = useMemo(() => {
    return byType.slice(0, 10).map((t, i) => ({
      name: t.type_d_etablissement || "Other",
      value: t.count,
      color: COLORS[i % COLORS.length],
    }));
  }, [byType]);

  // Pie data for lab domains
  const domainPieData = useMemo(() => {
    return byDomain.slice(0, 8).map((d, i) => ({
      name: d.domaine_scientifique || "Other",
      value: d.count,
      color: COLORS[i % COLORS.length],
    }));
  }, [byDomain]);

  // Region bar data
  const regionBarData = useMemo(() => {
    return byRegion
      .filter((r) => r.reg_nom)
      .slice(0, 15)
      .map((r) => ({
        region: r.reg_nom.length > 20 ? r.reg_nom.slice(0, 18) + "…" : r.reg_nom,
        count: r.count,
      }));
  }, [byRegion]);

  return (
    <div className="px-10 py-8">
      {/* Header */}
      <div className="flex items-start justify-between">
        <div>
          <p className="diplomatic-label">
            Ministère de l&apos;Enseignement supérieur, de la Recherche et de
            l&apos;Espace · Open Data
          </p>
          <h1 className="mt-2 font-headline text-3xl font-semibold tracking-tight text-primary">
            Institutions & Research
          </h1>
          <p className="mt-1 text-sm text-on-surface-variant">
            Live data from 211 open datasets via the MESR Explore API
          </p>
        </div>
        <div className="flex gap-8 text-right">
          <div>
            <p className="diplomatic-label">HE Institutions</p>
            <p className="mt-1 font-headline text-3xl font-semibold tracking-tight text-on-surface">
              {instTotal.toLocaleString()}
            </p>
          </div>
          <div>
            <p className="diplomatic-label">Research Structures</p>
            <p className="mt-1 font-headline text-3xl font-semibold tracking-tight text-on-surface">
              {labTotal.toLocaleString()}
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
          <button
            onClick={() => setActiveTab("institutions")}
            className={`px-4 py-1.5 text-xs font-medium transition-colors ${
              activeTab === "institutions"
                ? "bg-surface-container-lowest text-primary"
                : "text-on-surface-variant hover:text-on-surface"
            }`}
          >
            Institutions
          </button>
          <button
            onClick={() => setActiveTab("labs")}
            className={`px-4 py-1.5 text-xs font-medium transition-colors ${
              activeTab === "labs"
                ? "bg-surface-container-lowest text-primary"
                : "text-on-surface-variant hover:text-on-surface"
            }`}
          >
            Research Labs
          </button>
        </div>

        <div className="flex items-center gap-2 bg-surface-container-lowest px-3 py-2">
          <span className="material-symbols-outlined text-[16px] text-outline">
            search
          </span>
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search institutions or labs..."
            className="w-64 bg-transparent text-sm text-on-surface placeholder:text-outline-variant focus:outline-none"
          />
        </div>
      </div>

      {/* ─── Institutions Tab ─────────────────────────────── */}
      {activeTab === "institutions" && (
        <>
          {/* Charts Row */}
          <div className="mt-6 grid grid-cols-3 gap-8">
            {/* Type Distribution */}
            <div className="bg-surface-container-lowest p-6">
              <h2 className="diplomatic-label mb-4">By Type</h2>
              {typePieData.length > 0 ? (
                <>
                  <ResponsiveContainer width="100%" height={180}>
                    <PieChart>
                      <Pie
                        data={typePieData}
                        dataKey="value"
                        nameKey="name"
                        cx="50%"
                        cy="50%"
                        innerRadius={45}
                        outerRadius={70}
                        paddingAngle={2}
                      >
                        {typePieData.map((entry, i) => (
                          <Cell key={i} fill={entry.color} />
                        ))}
                      </Pie>
                      <Tooltip />
                    </PieChart>
                  </ResponsiveContainer>
                  <div className="mt-2 space-y-1">
                    {typePieData.map((t) => (
                      <div
                        key={t.name}
                        className="flex items-center justify-between text-xs"
                      >
                        <div className="flex items-center gap-2">
                          <span
                            className="inline-block h-2 w-2"
                            style={{ backgroundColor: t.color }}
                          />
                          <span className="truncate text-on-surface-variant">
                            {t.name}
                          </span>
                        </div>
                        <span className="text-on-surface">{t.value}</span>
                      </div>
                    ))}
                  </div>
                </>
              ) : (
                <p className="font-headline italic text-on-surface-variant">
                  No data
                </p>
              )}
            </div>

            {/* By Region */}
            <div className="col-span-2 bg-surface-container-lowest p-6">
              <h2 className="diplomatic-label mb-4">By Region</h2>
              {regionBarData.length > 0 ? (
                <ResponsiveContainer width="100%" height={300}>
                  <BarChart data={regionBarData} layout="vertical">
                    <CartesianGrid strokeDasharray="3 3" stroke="#c1c7ce30" horizontal={false} />
                    <XAxis
                      type="number"
                      tick={{ fontSize: 11, fill: "#41474d" }}
                      axisLine={false}
                      tickLine={false}
                    />
                    <YAxis
                      type="category"
                      dataKey="region"
                      tick={{ fontSize: 11, fill: "#41474d" }}
                      axisLine={false}
                      tickLine={false}
                      width={140}
                    />
                    <Tooltip />
                    <Bar dataKey="count" fill="#114563" />
                  </BarChart>
                </ResponsiveContainer>
              ) : (
                <p className="font-headline italic text-on-surface-variant">
                  No data
                </p>
              )}
            </div>
          </div>

          {/* Institution List */}
          <div className="mt-8 space-y-2">
            <div className="flex items-center gap-4 px-5 py-2 text-xs">
              <div className="flex-1"><span className="diplomatic-label">Institution</span></div>
              <div className="w-40"><span className="diplomatic-label">Type</span></div>
              <div className="w-32"><span className="diplomatic-label">Location</span></div>
              <div className="w-28"><span className="diplomatic-label">Region</span></div>
              <div className="w-24 text-right"><span className="diplomatic-label">Students</span></div>
            </div>
            {filteredInst.map((inst, i) => (
              <Link
                key={i}
                href={`/institutions/${inst.uai ?? inst.siren ?? i}`}
                className="flex items-center gap-4 bg-surface-container-lowest px-5 py-4 transition-colors hover:bg-surface-container-low"
              >
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-medium text-on-surface">
                    {inst.nom_court ?? inst.uo_lib}
                  </p>
                  {inst.sigle && (
                    <span className="text-xs text-on-surface-variant">
                      {inst.sigle}
                    </span>
                  )}
                  {inst.url && (
                    <a
                      href={inst.url}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="ml-2 text-xs text-primary hover:underline"
                    >
                      website
                    </a>
                  )}
                </div>
                <div className="w-40">
                  <span className="text-xs text-on-surface-variant">
                    {inst.type_d_etablissement ?? "—"}
                  </span>
                </div>
                <div className="w-32">
                  <span className="text-xs text-on-surface-variant">
                    {inst.com_nom ?? "—"}
                  </span>
                </div>
                <div className="w-28">
                  <span className="text-xs text-on-surface-variant">
                    {inst.reg_nom ?? "—"}
                  </span>
                </div>
                <div className="w-24 text-right">
                  <span className="text-xs text-on-surface">
                    {inst.inscrits?.toLocaleString() ?? "—"}
                  </span>
                </div>
              </Link>
            ))}
            <p className="mt-2 text-xs text-on-surface-variant">
              Showing {filteredInst.length} of {instTotal.toLocaleString()} institutions
            </p>
          </div>
        </>
      )}

      {/* ─── Labs Tab ─────────────────────────────────────── */}
      {activeTab === "labs" && (
        <>
          {/* Domain Distribution */}
          <div className="mt-6 grid grid-cols-3 gap-8">
            <div className="bg-surface-container-lowest p-6">
              <h2 className="diplomatic-label mb-4">Scientific Domain</h2>
              {domainPieData.length > 0 ? (
                <>
                  <ResponsiveContainer width="100%" height={180}>
                    <PieChart>
                      <Pie
                        data={domainPieData}
                        dataKey="value"
                        nameKey="name"
                        cx="50%"
                        cy="50%"
                        innerRadius={45}
                        outerRadius={70}
                        paddingAngle={2}
                      >
                        {domainPieData.map((entry, i) => (
                          <Cell key={i} fill={entry.color} />
                        ))}
                      </Pie>
                      <Tooltip />
                    </PieChart>
                  </ResponsiveContainer>
                  <div className="mt-2 space-y-1">
                    {domainPieData.map((d) => (
                      <div
                        key={d.name}
                        className="flex items-center justify-between text-xs"
                      >
                        <div className="flex items-center gap-2">
                          <span
                            className="inline-block h-2 w-2"
                            style={{ backgroundColor: d.color }}
                          />
                          <span className="truncate text-on-surface-variant">
                            {d.name}
                          </span>
                        </div>
                        <span className="text-on-surface">{d.value}</span>
                      </div>
                    ))}
                  </div>
                </>
              ) : (
                <p className="font-headline italic text-on-surface-variant">
                  No data
                </p>
              )}
            </div>
            <div className="col-span-2 bg-surface-container-low p-8">
              <h2 className="diplomatic-label mb-3">Data Source</h2>
              <p className="text-sm leading-relaxed text-on-surface-variant">
                Research structures sourced live from the RNSR (Répertoire National des
                Structures de Recherche), maintained by the MESR. Includes
                laboratories, research units, internal teams, federations, and
                networks across all scientific domains.
              </p>
              <p className="mt-4 text-sm leading-relaxed text-on-surface-variant">
                Each structure is linked to its governing institutions (tutelles) —
                universities, CNRS, INSERM, INRIA, CEA, etc. — enabling full lineage
                mapping.
              </p>
            </div>
          </div>

          {/* Lab List */}
          <div className="mt-8 space-y-2">
            <div className="flex items-center gap-4 px-5 py-2 text-xs">
              <div className="flex-1"><span className="diplomatic-label">Laboratory</span></div>
              <div className="w-40"><span className="diplomatic-label">Type</span></div>
              <div className="w-44"><span className="diplomatic-label">Domain</span></div>
              <div className="w-32"><span className="diplomatic-label">Location</span></div>
              <div className="w-44"><span className="diplomatic-label">Governing Body</span></div>
            </div>
            {filteredLabs.map((lab, i) => (
              <div
                key={i}
                className="flex items-center gap-4 bg-surface-container-lowest px-5 py-4 transition-colors hover:bg-surface-container-low"
              >
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-medium text-on-surface">
                    {lab.libelle}
                  </p>
                  {lab.sigle && (
                    <span className="text-xs text-on-surface-variant">
                      {lab.sigle}
                    </span>
                  )}
                  {lab.nom_du_responsable && (
                    <span className="ml-2 text-xs text-outline">
                      Dir: {lab.prenom_du_responsable} {lab.nom_du_responsable}
                    </span>
                  )}
                </div>
                <div className="w-40">
                  <span className="text-xs text-on-surface-variant">
                    {lab.type_de_structure ?? "—"}
                  </span>
                </div>
                <div className="w-44">
                  <span className="text-xs text-on-surface-variant">
                    {lab.domaine_scientifique ?? "—"}
                  </span>
                </div>
                <div className="w-32">
                  <span className="text-xs text-on-surface-variant">
                    {lab.commune ?? "—"}
                  </span>
                </div>
                <div className="w-44 min-w-0">
                  <span className="truncate text-xs text-on-surface-variant">
                    {lab.tutelles ?? "—"}
                  </span>
                </div>
              </div>
            ))}
            <p className="mt-2 text-xs text-on-surface-variant">
              Showing {filteredLabs.length} of {labTotal.toLocaleString()} structures
            </p>
          </div>
        </>
      )}
    </div>
  );
}
