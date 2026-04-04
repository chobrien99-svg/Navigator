"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { supabase } from "@/lib/supabase";

interface FundingRow {
  id: string;
  stage: string;
  amount_eur: number | null;
  announced_date: string | null;
  organization_id: string;
  organizations?: { name: string; slug: string } | null;
}

const AMOUNT_MULTIPLIER = 1_000_000;

function formatEur(amountInMillions: number | null): string {
  if (amountInMillions == null) return "—";
  const raw = amountInMillions * AMOUNT_MULTIPLIER;
  if (raw >= 1_000_000_000) return `€${(raw / 1_000_000_000).toFixed(1)}B`;
  if (raw >= 1_000_000) return `€${(raw / 1_000_000).toFixed(1)}M`;
  if (raw >= 1_000) return `€${(raw / 1_000).toFixed(0)}K`;
  return `€${raw.toLocaleString()}`;
}

export default function AdminFundingPage() {
  const [rounds, setRounds] = useState<FundingRow[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [page, setPage] = useState(0);
  const PAGE_SIZE = 50;

  useEffect(() => {
    async function load() {
      const { data, error } = await supabase
        .from("funding_rounds")
        .select("id, stage, amount_eur, announced_date, organization_id, organizations:organization_id(name, slug)")
        .order("announced_date", { ascending: false })
        .range(page * PAGE_SIZE, (page + 1) * PAGE_SIZE - 1);

      if (!error && data) {
        setRounds(data as unknown as FundingRow[]);
      }
      setLoading(false);
    }
    load();
  }, [page]);

  const filtered = search.trim()
    ? rounds.filter((r) =>
        (r.organizations?.name ?? "").toLowerCase().includes(search.toLowerCase())
      )
    : rounds;

  return (
    <div className="px-10 py-8">
      <div className="flex items-end justify-between">
        <div>
          <h1 className="font-headline text-3xl font-semibold tracking-tight text-primary">
            Funding Rounds
          </h1>
          <p className="mt-1 text-sm text-on-surface-variant">
            {loading ? "Loading..." : `Showing ${filtered.length} rounds`}
          </p>
        </div>
      </div>

      {/* Search + Pagination */}
      <div className="mt-6 flex items-center gap-4">
        <div className="relative flex-1 max-w-sm">
          <span className="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-[18px] text-on-surface-variant">
            search
          </span>
          <input
            type="text"
            placeholder="Filter by company name..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full bg-surface-container-lowest py-2.5 pl-10 pr-4 text-sm text-on-surface placeholder:text-on-surface-variant/50 border border-outline-variant/20 focus:border-primary focus:outline-none"
          />
        </div>
        <div className="ml-auto flex items-center gap-2">
          <button
            onClick={() => setPage(Math.max(0, page - 1))}
            disabled={page === 0}
            className="px-3 py-1.5 text-xs text-on-surface-variant hover:text-on-surface disabled:opacity-30"
          >
            ← Previous
          </button>
          <span className="text-xs text-on-surface-variant">Page {page + 1}</span>
          <button
            onClick={() => setPage(page + 1)}
            disabled={rounds.length < PAGE_SIZE}
            className="px-3 py-1.5 text-xs text-on-surface-variant hover:text-on-surface disabled:opacity-30"
          >
            Next →
          </button>
        </div>
      </div>

      {/* Rounds List */}
      <div className="mt-6 space-y-1">
        {filtered.map((round) => (
          <Link
            key={round.id}
            href={`/admin/organizations/${round.organization_id}`}
            className="group flex items-center gap-6 bg-surface-container-lowest px-5 py-3 transition-colors hover:bg-surface-container-low"
          >
            <div className="flex-1 min-w-0">
              <div className="flex items-center gap-3">
                <span className="font-headline text-sm font-semibold text-on-surface group-hover:text-primary">
                  {round.organizations?.name ?? "Unknown"}
                </span>
                <span className="px-2 py-0.5 text-[0.65rem] font-semibold bg-primary/10 text-primary">
                  {round.stage?.replace(/_/g, " ") ?? "—"}
                </span>
              </div>
            </div>
            <div className="text-right">
              <p className="text-sm font-medium text-on-surface">
                {formatEur(round.amount_eur)}
              </p>
            </div>
            <div className="w-24 text-right">
              <p className="text-xs text-on-surface-variant">
                {round.announced_date ?? "—"}
              </p>
            </div>
            <span className="material-symbols-outlined text-[16px] text-outline-variant group-hover:text-primary">
              edit
            </span>
          </Link>
        ))}

        {filtered.length === 0 && !loading && (
          <div className="py-12 text-center">
            <p className="text-sm italic text-on-surface-variant">
              No funding rounds found.
            </p>
          </div>
        )}
      </div>
    </div>
  );
}
