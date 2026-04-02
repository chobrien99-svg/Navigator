"use client";

import Link from "next/link";
import { useEffect, useState } from "react";
import { getOrganizations } from "@/lib/queries";
import type { Organization } from "@/lib/types";

export default function AdminOrganizationsPage() {
  const [orgs, setOrgs] = useState<Organization[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    getOrganizations()
      .then(setOrgs)
      .catch(() => {})
      .finally(() => setLoading(false));
  }, []);

  return (
    <div className="px-10 py-8">
      <div className="flex items-end justify-between">
        <div>
          <h1 className="font-headline text-3xl font-semibold tracking-tight text-primary">
            Organizations
          </h1>
          <p className="mt-1 text-sm text-on-surface-variant">
            {orgs.length} records
          </p>
        </div>
      </div>

      {loading ? (
        <p className="mt-8 font-headline italic text-on-surface-variant">
          Loading...
        </p>
      ) : (
        <div className="mt-8 space-y-2">
          {orgs.map((org) => (
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
          {orgs.length === 0 && (
            <p className="py-10 text-center font-headline italic text-on-surface-variant">
              No organizations in the database yet.
            </p>
          )}
        </div>
      )}
    </div>
  );
}
