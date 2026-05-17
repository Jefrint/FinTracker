"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { useState } from "react";
import { useAuth } from "./AuthProvider";

const navItems = [
  { href: "/dashboard", label: "Dashboard" },
  { href: "/assets", label: "Assets" },
  { href: "/transactions", label: "Transactions" },
  { href: "/profile", label: "Profile" },
];

export function AppShell({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const router = useRouter();
  const { user, logout } = useAuth();
  const [mobileNavOpen, setMobileNavOpen] = useState(false);
  const currentPage = navItems.find((item) => item.href === pathname)?.label ?? "Menu";

  async function handleLogout() {
    await logout();
    setMobileNavOpen(false);
    router.replace("/login");
  }

  return (
    <div className="app-frame">
      <aside className="sidebar">
        <Link href="/dashboard" className="brand">
          <span className="brand-mark">F</span>
          <span>
            <strong>FinTracker</strong>
            <small>Portfolio control</small>
          </span>
        </Link>

        <button
          className="mobile-nav-toggle"
          type="button"
          aria-label="Open navigation menu"
          aria-expanded={mobileNavOpen}
          aria-controls="mobile-navigation-panel"
          onClick={() => setMobileNavOpen((open) => !open)}
        >
          <span className="mobile-nav-label">{currentPage}</span>
          <span className="hamburger-icon" aria-hidden="true">
            <span></span>
            <span></span>
            <span></span>
          </span>
        </button>

        <div
          id="mobile-navigation-panel"
          className={mobileNavOpen ? "sidebar-menu open" : "sidebar-menu"}
        >
          <nav id="primary-navigation" className="nav-list" aria-label="Primary navigation">
            {navItems.map((item) => (
              <Link
                key={item.href}
                href={item.href}
                className={pathname === item.href ? "nav-link active" : "nav-link"}
                onClick={() => setMobileNavOpen(false)}
              >
                {item.label}
              </Link>
            ))}
          </nav>

          <div className="sidebar-footer">
            <span>{user?.name ?? "Signed in"}</span>
            <button className="ghost-button" type="button" onClick={handleLogout}>
              Sign out
            </button>
          </div>
        </div>
      </aside>

      <main className="workspace">{children}</main>
    </div>
  );
}
