"use client";

import Link from "next/link";
import { useEffect, useState } from "react";
import { getPeople } from "@/lib/queries";
import type { Person } from "@/lib/types";

export default function AdminPeoplePage() {
  const [people, setPeople] = useState<Person[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    getPeople()
      .then(setPeople)
      .catch(() => {})
      .finally(() => setLoading(false));
  }, []);

  return (
    <div className="px-10 py-8">
      <div className="flex items-end justify-between">
        <div>
          <h1 className="font-headline text-3xl font-semibold tracking-tight text-primary">
            People
          </h1>
          <p className="mt-1 text-sm text-on-surface-variant">
            {people.length} records
          </p>
        </div>
      </div>

      {loading ? (
        <p className="mt-8 font-headline italic text-on-surface-variant">
          Loading...
        </p>
      ) : (
        <div className="mt-8 space-y-2">
          {people.map((person) => (
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
                </p>
              </div>
              <span className="material-symbols-outlined text-[18px] text-outline-variant">
                edit
              </span>
            </Link>
          ))}
          {people.length === 0 && (
            <p className="py-10 text-center font-headline italic text-on-surface-variant">
              No people in the database yet.
            </p>
          )}
        </div>
      )}
    </div>
  );
}
