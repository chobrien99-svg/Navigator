"use client";

import Link from "next/link";
import { useEffect, useState } from "react";
import { getDashboardStats, formatEur } from "@/lib/queries";

export default function AdminDashboard() {
  const [stats, setStats] = useState({
    organizations: 0,
    people: 0,
    fundingRounds: 0,
    totalRaised: 0,
  });

  useEffect(() => {
    getDashboardStats().then(setStats).catch(() => {});
  }, []);

  return (
    <div className="px-10 py-8">
      <h1 className="font-headline text-3xl font-semibold tracking-tight text-primary">
        Admin Dashboard
      </h1>
      <p className="mt-1 text-sm text-on-surface-variant">
        Manage the intelligence database
      </p>

      {/* Stats */}
      <div className="mt-8 grid grid-cols-4 gap-6">
        <div className="bg-surface-container-lowest p-6">
          <p className="diplomatic-label">Organizations</p>
          <p className="mt-2 font-headline text-3xl font-semibold text-on-surface">
            {stats.organizations}
          </p>
        </div>
        <div className="bg-surface-container-lowest p-6">
          <p className="diplomatic-label">People</p>
          <p className="mt-2 font-headline text-3xl font-semibold text-on-surface">
            {stats.people}
          </p>
        </div>
        <div className="bg-surface-container-lowest p-6">
          <p className="diplomatic-label">Funding Rounds</p>
          <p className="mt-2 font-headline text-3xl font-semibold text-on-surface">
            {stats.fundingRounds}
          </p>
        </div>
        <div className="bg-surface-container-lowest p-6">
          <p className="diplomatic-label">Capital Tracked</p>
          <p className="mt-2 font-headline text-3xl font-semibold text-on-surface">
            {formatEur(stats.totalRaised)}
          </p>
        </div>
      </div>

      {/* Quick Actions */}
      <div className="mt-10">
        <h2 className="diplomatic-label mb-4">Quick Actions</h2>
        <div className="grid grid-cols-3 gap-6">
          <Link
            href="/admin/organizations"
            className="group bg-surface-container-lowest p-6 transition-colors hover:bg-surface-container-low"
          >
            <span className="material-symbols-outlined text-[24px] text-primary">
              domain
            </span>
            <h3 className="mt-3 font-headline text-base font-semibold text-on-surface">
              Manage Organizations
            </h3>
            <p className="mt-1 text-sm text-on-surface-variant">
              Edit startup profiles, investor details, descriptions, and
              metadata.
            </p>
          </Link>
          <Link
            href="/admin/people"
            className="group bg-surface-container-lowest p-6 transition-colors hover:bg-surface-container-low"
          >
            <span className="material-symbols-outlined text-[24px] text-primary">
              person
            </span>
            <h3 className="mt-3 font-headline text-base font-semibold text-on-surface">
              Manage People
            </h3>
            <p className="mt-1 text-sm text-on-surface-variant">
              Edit person profiles, bios, roles, and background attributes.
            </p>
          </Link>
          <div className="bg-surface-container-lowest p-6 opacity-60">
            <span className="material-symbols-outlined text-[24px] text-outline">
              payments
            </span>
            <h3 className="mt-3 font-headline text-base font-semibold text-on-surface">
              Manage Funding
            </h3>
            <p className="mt-1 text-sm text-on-surface-variant">
              Edit funding rounds, investors, and amounts.
            </p>
            <p className="mt-2 text-xs italic text-outline">Coming soon</p>
          </div>
        </div>
      </div>
    </div>
  );
}
