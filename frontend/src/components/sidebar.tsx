"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

const navigation = [
  {
    name: "Ecosystem Atlas",
    href: "/atlas",
    icon: "public",
  },
  {
    name: "Entity Explorer",
    href: "/entities",
    icon: "domain",
  },
  {
    name: "People",
    href: "/people",
    icon: "person",
  },
  {
    name: "Funding Tracker",
    href: "/funding",
    icon: "payments",
  },
  {
    name: "Institutions",
    href: "/institutions",
    icon: "school",
  },
  {
    name: "Research Intel",
    href: "/research",
    icon: "science",
  },
  {
    name: "Network Navigator",
    href: "/network",
    icon: "share",
  },
];

const secondaryNavigation = [
  { name: "Export", href: "/export", icon: "download" },
  { name: "Settings", href: "/settings", icon: "tune" },
  { name: "Support", href: "/support", icon: "help_outline" },
];

export function Sidebar() {
  const pathname = usePathname();

  return (
    <aside className="flex h-full w-[240px] shrink-0 flex-col bg-surface-container-low">
      {/* Masthead */}
      <div className="px-6 pt-6 pb-8">
        <Link href="/">
          <h1 className="font-headline text-xl font-semibold tracking-tight text-primary">
            The Navigator
          </h1>
        </Link>
        <p className="diplomatic-label mt-1">Institutional Intelligence</p>
      </div>

      {/* Primary Navigation */}
      <nav className="flex-1 px-3">
        <ul className="space-y-1">
          {navigation.map((item) => {
            const isActive = pathname.startsWith(item.href);
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

      {/* New Analysis CTA */}
      <div className="px-3 pb-4">
        <Link
          href="/analysis/new"
          className="institutional-gradient flex w-full items-center justify-center py-3 text-sm font-semibold text-on-primary transition-opacity duration-200 hover:opacity-90"
        >
          New Analysis
        </Link>
      </div>

      {/* Secondary Navigation */}
      <div className="border-t border-outline-variant/15 px-3 py-3">
        <ul className="space-y-0.5">
          {secondaryNavigation.map((item) => (
            <li key={item.name}>
              <Link
                href={item.href}
                className="flex items-center gap-3 px-3 py-2 text-sm text-on-surface-variant transition-colors duration-200 hover:text-on-surface"
              >
                <span className="material-symbols-outlined text-[18px]">
                  {item.icon}
                </span>
                {item.name}
              </Link>
            </li>
          ))}
        </ul>
      </div>
    </aside>
  );
}
