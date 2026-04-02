"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { useEffect, useState } from "react";
import { getUser, signOut } from "@/lib/auth";
import type { User } from "@supabase/supabase-js";

const adminNav = [
  { name: "Dashboard", href: "/admin", icon: "dashboard" },
  { name: "Organizations", href: "/admin/organizations", icon: "domain" },
  { name: "People", href: "/admin/people", icon: "person" },
];

export default function AdminLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const router = useRouter();
  const pathname = usePathname();
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    getUser().then((u) => {
      if (!u) {
        router.push("/login");
      } else {
        setUser(u);
      }
      setLoading(false);
    });
  }, [router]);

  async function handleSignOut() {
    await signOut();
    router.push("/login");
  }

  if (loading) {
    return (
      <div className="flex h-full items-center justify-center bg-surface">
        <p className="font-headline text-lg italic text-on-surface-variant">
          Loading...
        </p>
      </div>
    );
  }

  if (!user) return null;

  return (
    <div className="flex h-full">
      {/* Admin Sidebar */}
      <aside className="flex h-full w-[240px] shrink-0 flex-col bg-surface-container-low">
        <div className="px-6 pt-6 pb-6">
          <Link href="/">
            <h1 className="font-headline text-xl font-semibold tracking-tight text-primary">
              The Navigator
            </h1>
          </Link>
          <p className="diplomatic-label mt-1">Admin Console</p>
        </div>

        <nav className="flex-1 px-3">
          <ul className="space-y-1">
            {adminNav.map((item) => {
              const isActive =
                item.href === "/admin"
                  ? pathname === "/admin"
                  : pathname.startsWith(item.href);
              return (
                <li key={item.name}>
                  <Link
                    href={item.href}
                    className={`flex items-center gap-3 px-3 py-2.5 text-sm font-medium transition-colors duration-200 ${
                      isActive
                        ? "bg-surface-container-highest text-primary"
                        : "text-on-surface-variant hover:bg-surface-container hover:text-on-surface"
                    }`}
                  >
                    <span className="material-symbols-outlined text-[20px]">
                      {item.icon}
                    </span>
                    {item.name}
                  </Link>
                </li>
              );
            })}
          </ul>
        </nav>

        {/* User + Sign Out */}
        <div className="border-t border-outline-variant/15 px-4 py-4">
          <p className="truncate text-xs text-on-surface-variant">
            {user.email}
          </p>
          <div className="mt-3 flex gap-2">
            <Link
              href="/entities"
              className="flex-1 py-1.5 text-center text-xs text-on-surface-variant transition-colors hover:text-on-surface"
            >
              View Site
            </Link>
            <button
              onClick={handleSignOut}
              className="flex-1 py-1.5 text-center text-xs text-error transition-colors hover:text-on-error-container"
            >
              Sign Out
            </button>
          </div>
        </div>
      </aside>

      {/* Main Content */}
      <div className="flex flex-1 flex-col overflow-hidden">
        <header className="flex h-12 items-center justify-between bg-surface px-6 ghost-border-bottom">
          <p className="text-sm font-medium text-on-surface">
            Admin Console
          </p>
        </header>
        <main className="flex-1 overflow-y-auto bg-surface">{children}</main>
      </div>
    </div>
  );
}
