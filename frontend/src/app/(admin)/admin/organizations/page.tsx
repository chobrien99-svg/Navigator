"use client";

import Link from "next/link";
import { useEffect, useState, useCallback } from "react";
import { supabase } from "@/lib/supabase";

interface OrgRow {
  id: string;
  name: string;
  slug: string;
  organization_type: string;
  status: string;
  country: string;
}

const PAGE_SIZE = 50;

const TYPE_OPTIONS = [
  "",
  "startup",
  "corporate",
  "investor",
  "accelerator",
  "incubator",
  "university",
  "research_lab",
  "public_agency",
  "nonprofit",
  "media",
  "other",
];

const STATUS_OPTIONS = [
  "",
  "active",
  "inactive",
  "acquired",
  "closed",
  "ipo",
  "stealth",
  "unknown",
];

export default function AdminOrganizationsPage() {
  const [rows, setRows] = useState<OrgRow[]>([]);
  const [loading, setLoading] = useState(true);
  const [total, setTotal] = useState<number | null>(null);
  const [page, setPage] = useState(0);
  const [search, setSearch] = useState("");
  const [debouncedSearch, setDebouncedSearch] = useState("");
  const [typeFilter, setTypeFilter] = useState("");
  const [statusFilter, setStatusFilter] = useState("");

  // Debounce search input
  useEffect(() => {
    const t = setTimeout(() => setDebouncedSearch(search), 300);
    return () => clearTimeout(t);
  }, [search]);

  // Reset to page 0 when filters change
  useEffect(() => {
    setPage(0);
  }, [debouncedSearch, typeFilter, statusFilter]);

  const load = useCallback(async () => {
    setLoading(true);
    let query = supabase
      .from("organizations")
      .select("id, name, slug, organization_type, status, country", {
        count: "exact",
      })
      .order("name", { ascending: true })
      .range(page * PAGE_SIZE, (page + 1) * PAGE_SIZE - 1);

    if (debouncedSearch.trim()) {
      query = query.ilike("name", `%${debouncedSearch.trim()}%`);
    }
    if (typeFilter) {
      query = query.eq("organization_type", typeFilter);
    }
    if (statusFilter) {
      query = query.eq("status", statusFilter);
    }

    const { data, error, count } = await query;
    if (!error && data) {
      setRows(data as OrgRow[]);
      if (count != null) setTotal(count);
    }
    setLoading(false);
  }, [page, debouncedSearch, typeFilter, statusFilter]);

  useEffect(() => {
    load();
  }, [load]);

  const totalPages = total != null ? Math.ceil(total / PAGE_SIZE) : 0;

  return (
    <div className="px-10 py-8">
      {/* Header */}
      <div className="flex items-end justify-between">
        <div>
          <h1 className="font-headline text-3xl font-semibold tracking-tight text-primary">
            Organizations
          </h1>
          <p className="mt-1 text-sm text-on-surface-variant">
            {total != null ? `${total.toLocaleString()} records` : "Loading..."}
            {debouncedSearch || typeFilter || statusFilter
              ? " (filtered)"
              : ""}
          </p>
        </div>
        <Link
          href="/admin/organizations/new"
          className="institutional-gradient px-5 py-2 text-sm font-semibold text-on-primary transition-opacity hover:opacity-90"
        >
          + New Organization
        </Link>
      </div>

      {/* Filters */}
      <div className="mt-6 flex items-center gap-3">
        <div className="relative flex-1 max-w-md">
          <span className="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-[18px] text-on-surface-variant">
            search
          </span>
          <input
            type="text"
            placeholder="Search by name..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full bg-surface-container-lowest py-2.5 pl-10 pr-4 text-sm text-on-surface placeholder:text-on-surface-variant/50 border border-outline-variant/20 focus:border-primary focus:outline-none"
          />
        </div>
        <select
          value={typeFilter}
          onChange={(e) => setTypeFilter(e.target.value)}
          className="bg-surface-container-lowest px-3 py-2.5 text-xs text-on-surface border border-outline-variant/20 focus:border-primary focus:outline-none"
        >
          {TYPE_OPTIONS.map((t) => (
            <option key={t} value={t}>
              {t ? t.replace(/_/g, " ") : "All types"}
            </option>
          ))}
        </select>
        <select
          value={statusFilter}
          onChange={(e) => setStatusFilter(e.target.value)}
          className="bg-surface-container-lowest px-3 py-2.5 text-xs text-on-surface border border-outline-variant/20 focus:border-primary focus:outline-none"
        >
          {STATUS_OPTIONS.map((s) => (
            <option key={s} value={s}>
              {s || "All statuses"}
            </option>
          ))}
        </select>
      </div>

      {/* Results */}
      {loading ? (
        <p className="mt-8 font-headline italic text-on-surface-variant">
          Loading...
        </p>
      ) : (
        <>
          <div className="mt-6 space-y-1">
            {rows.map((org) => (
              <Link
                key={org.id}
                href={`/admin/organizations/${org.id}`}
                className="flex items-center justify-between bg-surface-container-lowest px-5 py-4 transition-colors hover:bg-surface-container-low"
              >
                <div className="min-w-0 flex-1">
                  <p className="text-sm font-medium text-on-surface">
                    {org.name}
                  </p>
                  <p className="mt-0.5 text-xs text-on-surface-variant">
                    {org.organization_type.replace(/_/g, " ")} · {org.status} ·{" "}
                    {org.slug}
                  </p>
                </div>
                <span className="material-symbols-outlined text-[18px] text-outline-variant">
                  edit
                </span>
              </Link>
            ))}
            {rows.length === 0 && (
              <p className="py-10 text-center font-headline italic text-on-surface-variant">
                No organizations match the current filters.
              </p>
            )}
          </div>

          {/* Pagination */}
          {total != null && total > PAGE_SIZE && (
            <div className="mt-6 flex items-center justify-between">
              <p className="text-xs text-on-surface-variant">
                Showing {page * PAGE_SIZE + 1}-
                {Math.min((page + 1) * PAGE_SIZE, total)} of{" "}
                {total.toLocaleString()}
              </p>
              <div className="flex items-center gap-2">
                <button
                  onClick={() => setPage(0)}
                  disabled={page === 0}
                  className="px-3 py-1.5 text-xs text-on-surface-variant hover:text-on-surface disabled:opacity-30"
                >
                  ← First
                </button>
                <button
                  onClick={() => setPage(Math.max(0, page - 1))}
                  disabled={page === 0}
                  className="px-3 py-1.5 text-xs text-on-surface-variant hover:text-on-surface disabled:opacity-30"
                >
                  Previous
                </button>
                <span className="text-xs text-on-surface-variant px-2">
                  Page {page + 1} of {totalPages}
                </span>
                <button
                  onClick={() => setPage(Math.min(totalPages - 1, page + 1))}
                  disabled={page >= totalPages - 1}
                  className="px-3 py-1.5 text-xs text-on-surface-variant hover:text-on-surface disabled:opacity-30"
                >
                  Next
                </button>
                <button
                  onClick={() => setPage(totalPages - 1)}
                  disabled={page >= totalPages - 1}
                  className="px-3 py-1.5 text-xs text-on-surface-variant hover:text-on-surface disabled:opacity-30"
                >
                  Last →
                </button>
              </div>
            </div>
          )}
        </>
      )}
    </div>
  );
}
