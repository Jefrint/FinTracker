"use client";

import { createContext, useContext, useEffect, useMemo, useState } from "react";
import { api, ApiError } from "@/lib/api";
import type { AuthResponse, LoginPayload, RegisterPayload, User } from "@/lib/types";

type AuthContextValue = {
  token: string | null;
  user: User | null;
  loading: boolean;
  login: (payload: LoginPayload) => Promise<void>;
  register: (payload: RegisterPayload) => Promise<void>;
  logout: () => Promise<void>;
  setUser: (user: User | null) => void;
};

const AuthContext = createContext<AuthContextValue | null>(null);
const STORAGE_KEY = "fintracker.auth";

function authUser(response: AuthResponse): User {
  return {
    id: response.id,
    name: response.name,
    email: response.email,
  };
}

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [token, setToken] = useState<string | null>(null);
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let cancelled = false;

    async function restoreSession() {
      const raw = window.localStorage.getItem(STORAGE_KEY);

      if (!raw) {
        setLoading(false);
        return;
      }

      try {
        const saved = JSON.parse(raw) as { token: string; user: User };

        if (cancelled) {
          return;
        }

        setToken(saved.token);
        setUser(saved.user);

        const freshUser = await api.me(saved.token);

        if (cancelled) {
          return;
        }

        setUser(freshUser);
        window.localStorage.setItem(
          STORAGE_KEY,
          JSON.stringify({ token: saved.token, user: freshUser }),
        );
      } catch (error) {
        if (error instanceof ApiError && error.status === 401) {
          window.localStorage.removeItem(STORAGE_KEY);
          setToken(null);
          setUser(null);
        } else if (!(error instanceof SyntaxError)) {
          window.localStorage.removeItem(STORAGE_KEY);
        }
      } finally {
        if (!cancelled) {
          setLoading(false);
        }
      }
    }

    void restoreSession();

    return () => {
      cancelled = true;
    };
  }, []);

  const value = useMemo<AuthContextValue>(
    () => ({
      token,
      user,
      loading,
      setUser,
      login: async (payload) => {
        const response = await api.login(payload);
        const nextUser = authUser(response);
        setToken(response.token);
        setUser(nextUser);
        window.localStorage.setItem(
          STORAGE_KEY,
          JSON.stringify({ token: response.token, user: nextUser }),
        );
      },
      register: async (payload) => {
        await api.register(payload);
      },
      logout: async () => {
        const currentToken = token;
        setToken(null);
        setUser(null);
        window.localStorage.removeItem(STORAGE_KEY);

        if (currentToken) {
          try {
            await api.logout(currentToken);
          } catch {
            // Logout is client-side in this backend; a failed server call should not keep a stale token.
          }
        }
      },
    }),
    [loading, token, user],
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const value = useContext(AuthContext);

  if (!value) {
    throw new Error("useAuth must be used inside AuthProvider");
  }

  return value;
}
