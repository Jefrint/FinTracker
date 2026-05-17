"use client";

import Link from "next/link";
import { FormEvent, useState } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/components/AuthProvider";
import { FieldError } from "@/components/FieldError";
import { StatusMessage } from "@/components/StatusMessage";
import { ApiError } from "@/lib/api";

export default function RegisterPage() {
  const router = useRouter();
  const { register } = useAuth();
  const [name, setName] = useState("");
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
      await register({ name, email, password });
      router.replace("/login");
    } catch (caught) {
      if (caught instanceof ApiError) {
        setFieldErrors(caught.errors ?? {});
        setError(caught.message);
      } else {
        setError("Unable to create the account. Check the backend connection.");
      }
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <main className="auth-page">
      <section className="auth-panel wide">
        <div>
          <span className="eyebrow">FinTracker</span>
          <h1>Create account</h1>
          <p>Registration creates your profile. Sign in after account creation.</p>
        </div>

        <StatusMessage message={error} />

        <form className="form-stack" onSubmit={handleSubmit}>
          <label>
            Name
            <input value={name} onChange={(event) => setName(event.target.value)} required />
            <FieldError message={fieldErrors.name} />
          </label>

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
              minLength={6}
              value={password}
              onChange={(event) => setPassword(event.target.value)}
              required
            />
            <FieldError message={fieldErrors.password} />
          </label>

          <button className="primary-button" type="submit" disabled={submitting}>
            {submitting ? "Creating..." : "Create account"}
          </button>
        </form>

        <p className="auth-switch">
          Already registered? <Link href="/login">Sign in</Link>
        </p>
      </section>
    </main>
  );
}
