"use client";

import Link from "next/link";
import { useEffect, useState, useCallback } from "react";
import { supabase } from "@/lib/supabase";

interface PersonRow {
  id: string;
  full_name: string;
  slug: string;
  has_phd: boolean;
  is_repeat_founder: boolean;
  has_big_tech_background: boolean;
}

const PAGE_SIZE = 50;

export default function AdminPeoplePage() {
  const [rows, setRows] = useState<PersonRow[]>([]);
  const [loading, setLoading] = useState(true);
  const [total, setTotal] = useState<number | null>(null);
  const [page, setPage] = useState(0);
  const [search, setSearch] = useState("");
  const [debouncedSearch, setDebouncedSearch] = useState("");
  const [phdOnly, setPhdOnly] = useState(false);
  const [repeatFounderOnly, setRepeatFounderOnly] = useState(false);

  useEffect(() => {
    const t = setTimeout(() => setDebouncedSearch(search), 300);
    return () => clearTimeout(t);
  }, [search]);

  useEffect(() => {
    setPage(0);
  }, [debouncedSearch, phdOnly, repeatFounderOnly]);

  const load = useCallback(async () => {
    setLoading(true);
    let query = supabase
      .from("people")
      .select(
        "id, full_name, slug, has_phd, is_repeat_founder, has_big_tech_background",
        { count: "exact" }
      )
      .order("full_name", { ascending: true })
      .range(page * PAGE_SIZE, (page + 1) * PAGE_SIZE - 1);

    if (debouncedSearch.trim()) {
      query = query.ilike("full_name", `%${debouncedSearch.trim()}%`);
    }
    if (phdOnly) query = query.eq("has_phd", true);
    if (repeatFounderOnly) query = query.eq("is_repeat_founder", true);

    const { data, error, count } = await query;
    if (!error && data) {
      setRows(data as PersonRow[]);
      if (count != null) setTotal(count);
    }
    setLoading(false);
  }, [page, debouncedSearch, phdOnly, repeatFounderOnly]);

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
            People
          </h1>
          <p className="mt-1 text-sm text-on-surface-variant">
            {total != null ? `${total.toLocaleString()} records` : "Loading..."}
            {debouncedSearch || phdOnly || repeatFounderOnly ? " (filtered)" : ""}
          </p>
        </div>
        <Link
          href="/admin/people/new"
          className="institutional-gradient px-5 py-2 text-sm font-semibold text-on-primary transition-opacity hover:opacity-90"
        >
          + New Person
        </Link>
      </div>

      {/* Filters */}
      <div className="mt-6 flex items-center gap-4">
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
        <label className="flex items-center gap-2 text-xs text-on-surface-variant">
          <input
            type="checkbox"
            checked={phdOnly}
            onChange={(e) => setPhdOnly(e.target.checked)}
            className="accent-primary"
          />
          PhD only
        </label>
        <label className="flex items-center gap-2 text-xs text-on-surface-variant">
          <input
            type="checkbox"
            checked={repeatFounderOnly}
            onChange={(e) => setRepeatFounderOnly(e.target.checked)}
            className="accent-primary"
          />
          Repeat founders
        </label>
      </div>

      {/* Results */}
      {loading ? (
        <p className="mt-8 font-headline italic text-on-surface-variant">
          Loading...
        </p>
      ) : (
        <>
          <div className="mt-6 space-y-1">
            {rows.map((person) => (
              <Link
                key={person.id}
                href={`/admin/people/${person.id}`}
                className="flex items-center justify-between bg-surface-container-lowest px-5 py-4 transition-colors hover:bg-surface-container-low"
              >
                <div className="min-w-0 flex-1">
                  <p className="text-sm font-medium text-on-surface">
                    {person.full_name}
                  </p>
                  <p className="mt-0.5 text-xs text-on-surface-variant">
                    {person.slug}
                    {person.has_phd ? " · PhD" : ""}
                    {person.is_repeat_founder ? " · Repeat Founder" : ""}
                    {person.has_big_tech_background ? " · Big Tech" : ""}
                  </p>
                </div>
                <span className="material-symbols-outlined text-[18px] text-outline-variant">
                  edit
                </span>
              </Link>
            ))}
            {rows.length === 0 && (
              <p className="py-10 text-center font-headline italic text-on-surface-variant">
                No people match the current filters.
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
