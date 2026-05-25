"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

const scopeTabs = [
  { name: "National", href: "/" },
  { name: "Regional", href: "/regional" },
  { name: "Cluster", href: "/clusters" },
  { name: "Entity", href: "/entities" },
];

export function TopBar() {
  const pathname = usePathname();

  return (
    <header className="flex h-12 items-center justify-between bg-surface px-6 ghost-border-bottom">
      {/* Scope Tabs */}
      <nav className="flex items-center gap-1">
        {scopeTabs.map((tab) => {
          const isActive =
            tab.href === "/"
              ? pathname === "/"
              : pathname.startsWith(tab.href);
          return (
            <Link
              key={tab.name}
              href={tab.href}
              className={`px-3 py-1.5 text-sm font-medium transition-colors duration-200 ${
                isActive
                  ? "text-primary ghost-border-bottom"
                  : "text-on-surface-variant hover:text-on-surface"
              }`}
            >
              {tab.name}
            </Link>
          );
        })}
      </nav>

      {/* Right Actions */}
      <div className="flex items-center gap-3">
        <button
          type="button"
          className="flex items-center gap-2 bg-surface-container-low px-3 py-1.5 text-sm text-on-surface-variant transition-colors duration-200 hover:bg-surface-container"
        >
          <span className="material-symbols-outlined text-[18px]">search</span>
          <span className="text-xs">Search entities...</span>
        </button>
        <button
          type="button"
          className="material-symbols-outlined text-[20px] text-on-surface-variant transition-colors duration-200 hover:text-on-surface"
        >
          notifications
        </button>
        <button
          type="button"
          className="material-symbols-outlined text-[20px] text-on-surface-variant transition-colors duration-200 hover:text-on-surface"
        >
          account_circle
        </button>
      </div>
    </header>
  );
}
