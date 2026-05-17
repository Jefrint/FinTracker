"use client";

import { FormEvent, useState } from "react";
import { useRouter } from "next/navigation";
import { AppShell } from "@/components/AppShell";
import { AuthGuard } from "@/components/AuthGuard";
import { FieldError } from "@/components/FieldError";
import { StatusMessage } from "@/components/StatusMessage";
import { useAuth } from "@/components/AuthProvider";
import { api, ApiError } from "@/lib/api";

export default function ProfilePage() {
  const router = useRouter();
  const { token, user, setUser, logout } = useAuth();
  const [message, setMessage] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [fieldErrors, setFieldErrors] = useState<Record<string, string>>({});
  const [submitting, setSubmitting] = useState(false);

  async function handleUpdate(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    if (!token || !user) {
      return;
    }

    setSubmitting(true);
    setError(null);
    setMessage(null);
    setFieldErrors({});

    try {
      const form = event.currentTarget;
      const formData = new FormData(form);
      const payload = {
        name: String(formData.get("name") ?? ""),
        email: String(formData.get("email") ?? ""),
        password: String(formData.get("password") ?? ""),
      };
      const updated = await api.updateUser(user.id, payload, token);
      setUser(updated);
      form.reset();
      setMessage("Profile updated.");
    } catch (caught) {
      if (caught instanceof ApiError) {
        setError(caught.message);
        setFieldErrors(caught.errors ?? {});
      } else {
        setError("Unable to update profile.");
      }
    } finally {
      setSubmitting(false);
    }
  }

  async function handleDelete() {
    if (!token || !user) {
      return;
    }

    await api.deleteUser(user.id, token);
    await logout();
    router.replace("/register");
  }

  return (
    <AuthGuard>
      <AppShell>
        <div className="page-header">
          <div>
            <span className="eyebrow">Account</span>
            <h1>Profile</h1>
          </div>
          <p>Manage the authenticated user returned by the backend.</p>
        </div>

        <section className="panel narrow-panel">
          <div className="section-heading">
            <h2>Account details</h2>
          </div>

          <StatusMessage message={error} />
          <StatusMessage message={message} tone="success" />

          <form className="form-stack" onSubmit={handleUpdate} key={user?.id ?? "profile"}>
            <label>
              Name
              <input name="name" defaultValue={user?.name ?? ""} required />
              <FieldError message={fieldErrors.name} />
            </label>

            <label>
              Email
              <input name="email" type="email" defaultValue={user?.email ?? ""} required />
              <FieldError message={fieldErrors.email} />
            </label>

            <label>
              New password
              <input name="password" type="password" minLength={6} required />
              <FieldError message={fieldErrors.password} />
            </label>

            <div className="button-row">
              <button className="primary-button" type="submit" disabled={submitting}>
                {submitting ? "Saving..." : "Save changes"}
              </button>
              <button className="danger-button" type="button" onClick={handleDelete}>
                Delete account
              </button>
            </div>
          </form>
        </section>
      </AppShell>
    </AuthGuard>
  );
}
