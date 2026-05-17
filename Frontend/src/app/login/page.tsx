"use client";

import Link from "next/link";
import { FormEvent, useState } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/components/AuthProvider";
import { FieldError } from "@/components/FieldError";
import { StatusMessage } from "@/components/StatusMessage";
import { ApiError } from "@/lib/api";

export default function LoginPage() {
  const router = useRouter();
  const { login } = useAuth();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [fieldErrors, setFieldErrors] = useState<Record<string, string>>({});
  const [submitting, setSubmitting] = useState(false);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setSubmitting(true);
    setError(null);
    setFieldErrors({});

    try {
      await login({ email, password });
      router.replace("/dashboard");
    } catch (caught) {
      if (caught instanceof ApiError) {
        setFieldErrors(caught.errors ?? {});
        setError(caught.message);
      } else {
        setError("Unable to sign in. Check the backend connection.");
      }
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <main className="auth-page">
      <section className="auth-panel">
        <div>
          <span className="eyebrow">FinTracker</span>
          <h1>Sign in</h1>
          <p>Use your account to manage assets and transactions.</p>
        </div>

        <StatusMessage message={error} />

        <form className="form-stack" onSubmit={handleSubmit}>
          <label>
            Email
            <input
              type="email"
              value={email}
              onChange={(event) => setEmail(event.target.value)}
              required
            />
            <FieldError message={fieldErrors.email} />
          </label>

          <label>
            Password
            <input
              type="password"
              value={password}
              onChange={(event) => setPassword(event.target.value)}
              required
            />
            <FieldError message={fieldErrors.password} />
          </label>

          <button className="primary-button" type="submit" disabled={submitting}>
            {submitting ? "Signing in..." : "Sign in"}
          </button>
        </form>

        <p className="auth-switch">
          New here? <Link href="/register">Create an account</Link>
        </p>
      </section>
    </main>
  );
}
