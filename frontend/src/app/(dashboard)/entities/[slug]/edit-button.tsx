"use client";

import Link from "next/link";
import { useEffect, useState } from "react";
import { getUser } from "@/lib/auth";

/**
 * Shown only to signed-in users: a shortcut from the public dossier to the
 * admin editor for this organization. Auth is resolved client-side because
 * the Supabase session lives in the browser (same pattern as the admin layout).
 */
export function EntityEditButton({ orgId }: { orgId: string }) {
  const [authed, setAuthed] = useState(false);

  useEffect(() => {
    let active = true;
    getUser().then((u) => {
      if (active) setAuthed(Boolean(u));
    });
    return () => {
      active = false;
    };
  }, []);

  if (!authed) return null;

  return (
    <Link
      href={`/admin/organizations/${orgId}`}
      className="inline-flex items-center gap-1.5 border border-outline-variant px-3 py-1.5 text-xs font-medium text-on-surface-variant transition-colors hover:bg-surface-container hover:text-on-surface"
    >
      <span className="material-symbols-outlined text-[16px]">edit</span>
      Edit
    </Link>
  );
}
