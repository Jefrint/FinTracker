"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "./AuthProvider";

export function AuthGuard({ children }: { children: React.ReactNode }) {
  const { token, loading } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (!loading && !token) {
      router.replace("/login");
    }
  }, [loading, router, token]);

  if (loading) {
    return <div className="center-panel">Loading your workspace...</div>;
  }

  if (!token) {
    return <div className="center-panel">Redirecting to sign in...</div>;
  }

  return children;
}
