"use client";

import { FormEvent, useEffect, useMemo, useState } from "react";
import { AppShell } from "@/components/AppShell";
import { AuthGuard } from "@/components/AuthGuard";
import { EmptyState } from "@/components/EmptyState";
import { FieldError } from "@/components/FieldError";
import { StatusMessage } from "@/components/StatusMessage";
import { useAuth } from "@/components/AuthProvider";
import { api, ApiError } from "@/lib/api";
import { assetHoldings, currency, quantity, typeClass } from "@/lib/format";
import type { Asset, Transaction } from "@/lib/types";

export default function AssetsPage() {
  const { token } = useAuth();
  const [assets, setAssets] = useState<Asset[]>([]);
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [name, setName] = useState("");
  const [type, setType] = useState("STOCK");
  const [error, setError] = useState<string | null>(null);
  const [fieldErrors, setFieldErrors] = useState<Record<string, string>>({});
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    if (!token) {
      return;
    }

    Promise.all([api.assets(token), api.transactions(token)])
      .then(([assetData, transactionData]) => {
        setAssets(assetData);
        setTransactions(transactionData);
      })
      .catch((caught) =>
        setError(caught instanceof ApiError ? caught.message : "Unable to load assets."),
      )
      .finally(() => setLoading(false));
  }, [token]);

  const holdings = useMemo(() => assetHoldings(assets, transactions), [assets, transactions]);

  async function handleCreate(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    if (!token) {
      return;
    }

    setSubmitting(true);
    setError(null);
    setFieldErrors({});

    try {
      const asset = await api.createAsset({ name, type }, token);
      setAssets((current) => [asset, ...current]);
      setName("");
      setType("STOCK");
    } catch (caught) {
      if (caught instanceof ApiError) {
        setError(caught.message);
        setFieldErrors(caught.errors ?? {});
      } else {
        setError("Unable to create asset.");
      }
    } finally {
      setSubmitting(false);
    }
  }

  async function handleDelete(id: number) {
    if (!token) {
      return;
    }

    await api.deleteAsset(id, token);
    setAssets((current) => current.filter((asset) => asset.id !== id));
  }

  return (
    <AuthGuard>
      <AppShell>
        <div className="page-header">
          <div>
            <span className="eyebrow">Holdings</span>
            <h1>Assets</h1>
          </div>
          <p>Create and monitor every asset attached to your account.</p>
        </div>

        <div className="content-grid">
          <section className="panel">
            <div className="section-heading">
              <h2>Create asset</h2>
            </div>

            <StatusMessage message={error} />

            <form className="form-stack" onSubmit={handleCreate}>
              <label>
                Name
                <input value={name} onChange={(event) => setName(event.target.value)} required />
                <FieldError message={fieldErrors.name} />
              </label>

              <label>
                Type
                <select value={type} onChange={(event) => setType(event.target.value)} required>
                  <option value="STOCK">Stock</option>
                  <option value="CRYPTO">Crypto</option>
                  <option value="ETF">ETF</option>
                  <option value="CASH">Cash</option>
                  <option value="OTHER">Other</option>
                </select>
                <FieldError message={fieldErrors.type} />
              </label>

              <button className="primary-button" type="submit" disabled={submitting}>
                {submitting ? "Creating..." : "Add asset"}
              </button>
            </form>
          </section>

          <section className="panel span-wide">
            <div className="section-heading">
              <h2>Tracked assets</h2>
              <span>{assets.length} total</span>
            </div>

            {loading ? (
              <div className="table-placeholder">Loading assets...</div>
            ) : assets.length === 0 ? (
              <EmptyState title="No assets yet" message="Add a stock, crypto holding, ETF, or cash position to begin." />
            ) : (
              <div className="table-wrap">
                <table>
                  <thead>
                    <tr>
                      <th>Name</th>
                      <th>Type</th>
                      <th>Quantity</th>
                      <th>Amount</th>
                      <th>Transactions</th>
                      <th></th>
                    </tr>
                  </thead>
                  <tbody>
                    {holdings.map((holding) => {
                      const { asset } = holding;

                      return (
                        <tr key={asset.id}>
                          <td>{asset.name}</td>
                          <td><span className={typeClass(asset.type)}>{asset.type}</span></td>
                          <td>{quantity(holding.quantity)}</td>
                          <td>{currency(holding.amount)}</td>
                          <td>{holding.transactionCount}</td>
                          <td className="table-action">
                            <button className="danger-button" type="button" onClick={() => handleDelete(asset.id)}>
                              Delete
                            </button>
                          </td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>
            )}
          </section>
        </div>
      </AppShell>
    </AuthGuard>
  );
}
