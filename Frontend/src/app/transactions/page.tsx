"use client";

import { FormEvent, useEffect, useState } from "react";
import { AppShell } from "@/components/AppShell";
import { AuthGuard } from "@/components/AuthGuard";
import { EmptyState } from "@/components/EmptyState";
import { FieldError } from "@/components/FieldError";
import { StatusMessage } from "@/components/StatusMessage";
import { useAuth } from "@/components/AuthProvider";
import { api, ApiError } from "@/lib/api";
import { assetName, currency, shortDate, typeClass } from "@/lib/format";
import type { Asset, Transaction } from "@/lib/types";

export default function TransactionsPage() {
  const { token } = useAuth();
  const [assets, setAssets] = useState<Asset[]>([]);
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [assetId, setAssetId] = useState("");
  const [type, setType] = useState("BUY");
  const [quantity, setQuantity] = useState("");
  const [price, setPrice] = useState("");
  const [date, setDate] = useState(new Date().toISOString().slice(0, 10));
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
        setAssetId(assetData[0]?.id.toString() ?? "");
      })
      .catch((caught) => setError(caught instanceof ApiError ? caught.message : "Unable to load transactions."))
      .finally(() => setLoading(false));
  }, [token]);

  async function handleCreate(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    if (!token) {
      return;
    }

    setSubmitting(true);
    setError(null);
    setFieldErrors({});

    try {
      const transaction = await api.createTransaction(
        {
          assetId: Number(assetId),
          type,
          quantity: Number(quantity),
          price: Number(price),
          date,
        },
        token,
      );
      setTransactions((current) => [transaction, ...current]);
      setQuantity("");
      setPrice("");
      setType("BUY");
    } catch (caught) {
      if (caught instanceof ApiError) {
        setError(caught.message);
        setFieldErrors(caught.errors ?? {});
      } else {
        setError("Unable to create transaction.");
      }
    } finally {
      setSubmitting(false);
    }
  }

  async function handleDelete(id: number) {
    if (!token) {
      return;
    }

    await api.deleteTransaction(id, token);
    setTransactions((current) => current.filter((transaction) => transaction.id !== id));
  }

  return (
    <AuthGuard>
      <AppShell>
        <div className="page-header">
          <div>
            <span className="eyebrow">Activity</span>
            <h1>Transactions</h1>
          </div>
          <p>Record buys, sells, and other asset movements.</p>
        </div>

        <div className="content-grid">
          <section className="panel">
            <div className="section-heading">
              <h2>Create transaction</h2>
            </div>

            <StatusMessage message={error} />

            <form className="form-stack" onSubmit={handleCreate}>
              <label>
                Asset
                <select value={assetId} onChange={(event) => setAssetId(event.target.value)} required>
                  <option value="" disabled>Select asset</option>
                  {assets.map((asset) => (
                    <option key={asset.id} value={asset.id}>
                      {asset.name}
                    </option>
                  ))}
                </select>
                <FieldError message={fieldErrors.assetId} />
              </label>

              <label>
                Type
                <select value={type} onChange={(event) => setType(event.target.value)} required>
                  <option value="BUY">Buy</option>
                  <option value="SELL">Sell</option>
                  <option value="DIVIDEND">Dividend</option>
                  <option value="TRANSFER">Transfer</option>
                </select>
                <FieldError message={fieldErrors.type} />
              </label>

              <div className="split-fields">
                <label>
                  Quantity
                  <input type="number" min="0.000001" step="any" value={quantity} onChange={(event) => setQuantity(event.target.value)} required />
                  <FieldError message={fieldErrors.quantity} />
                </label>
                <label>
                  Price
                  <input type="number" min="0.01" step="any" value={price} onChange={(event) => setPrice(event.target.value)} required />
                  <FieldError message={fieldErrors.price} />
                </label>
              </div>

              <label>
                Date
                <input type="date" value={date} onChange={(event) => setDate(event.target.value)} required />
                <FieldError message={fieldErrors.date} />
              </label>

              <button className="primary-button" type="submit" disabled={submitting || assets.length === 0}>
                {submitting ? "Recording..." : "Add transaction"}
              </button>
            </form>
          </section>

          <section className="panel span-wide">
            <div className="section-heading">
              <h2>Transaction history</h2>
              <span>{transactions.length} entries</span>
            </div>

            {loading ? (
              <div className="table-placeholder">Loading transactions...</div>
            ) : transactions.length === 0 ? (
              <EmptyState title="No transactions yet" message="Transactions appear here after you create an asset and record activity." />
            ) : (
              <div className="table-wrap">
                <table>
                  <thead>
                    <tr>
                      <th>Asset</th>
                      <th>Type</th>
                      <th>Date</th>
                      <th>Quantity</th>
                      <th>Price</th>
                      <th>Total</th>
                      <th></th>
                    </tr>
                  </thead>
                  <tbody>
                    {transactions.map((transaction) => (
                      <tr key={transaction.id}>
                        <td>{assetName(assets, transaction.assetId)}</td>
                        <td><span className={typeClass(transaction.type)}>{transaction.type}</span></td>
                        <td>{shortDate(transaction.date)}</td>
                        <td>{transaction.quantity}</td>
                        <td>{currency(transaction.price)}</td>
                        <td>{currency(transaction.quantity * transaction.price)}</td>
                        <td className="table-action">
                          <button className="danger-button" type="button" onClick={() => handleDelete(transaction.id)}>
                            Delete
                          </button>
                        </td>
                      </tr>
                    ))}
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
