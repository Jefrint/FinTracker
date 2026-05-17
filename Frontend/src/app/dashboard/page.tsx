"use client";

import { useEffect, useMemo, useState } from "react";
import { AppShell } from "@/components/AppShell";
import { AuthGuard } from "@/components/AuthGuard";
import { EmptyState } from "@/components/EmptyState";
import { StatCard } from "@/components/StatCard";
import { StatusMessage } from "@/components/StatusMessage";
import { api, ApiError } from "@/lib/api";
import {
  assetHoldings,
  assetName,
  currency,
  portfolioValue,
  quantity,
  shortDate,
  transactionAmount,
  typeClass,
} from "@/lib/format";
import type { Asset, Transaction } from "@/lib/types";
import { useAuth } from "@/components/AuthProvider";

export default function DashboardPage() {
  const { token } = useAuth();
  const [assets, setAssets] = useState<Asset[]>([]);
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!token) {
      return;
    }

    Promise.all([api.assets(token), api.transactions(token)])
      .then(([assetData, transactionData]) => {
        setAssets(assetData);
        setTransactions(transactionData);
      })
      .catch((caught) => {
        setError(caught instanceof ApiError ? caught.message : "Unable to load dashboard data.");
      })
      .finally(() => setLoading(false));
  }, [token]);

  const recentTransactions = useMemo(
    () => [...transactions].sort((a, b) => b.date.localeCompare(a.date)).slice(0, 5),
    [transactions],
  );
  const holdings = useMemo(() => assetHoldings(assets, transactions), [assets, transactions]);
  const activeHoldings = useMemo(
    () => holdings.filter((holding) => holding.quantity !== 0 || holding.amount !== 0),
    [holdings],
  );
  const netWorth = useMemo(() => portfolioValue(assets, transactions), [assets, transactions]);

  return (
    <AuthGuard>
      <AppShell>
        <div className="page-header">
          <div>
            <span className="eyebrow">Overview</span>
            <h1>Dashboard</h1>
          </div>
          <p>Track portfolio activity from your secured Spring Boot API.</p>
        </div>

        <StatusMessage message={error} />

        <section className="stats-grid">
          <StatCard label="Net worth" value={currency(netWorth)} detail="Buys minus sells" />
          <StatCard label="Assets" value={String(assets.length)} detail="Tracked instruments" />
          <StatCard label="Transactions" value={String(transactions.length)} detail="Recorded movements" />
        </section>

        <section className="panel">
          <div className="section-heading">
            <h2>Asset holdings</h2>
            <span>{activeHoldings.length} active</span>
          </div>

          {loading ? (
            <div className="table-placeholder">Loading holdings...</div>
          ) : activeHoldings.length === 0 ? (
            <EmptyState title="No holdings yet" message="Buy transactions add to net worth. Sell transactions reduce it." />
          ) : (
            <div className="table-wrap">
              <table>
                <thead>
                  <tr>
                    <th>Asset</th>
                    <th>Type</th>
                    <th>Quantity</th>
                    <th>Buy value</th>
                    <th>Sell value</th>
                    <th>Amount</th>
                  </tr>
                </thead>
                <tbody>
                  {activeHoldings.map((holding) => (
                    <tr key={holding.asset.id}>
                      <td>{holding.asset.name}</td>
                      <td><span className={typeClass(holding.asset.type)}>{holding.asset.type}</span></td>
                      <td>{quantity(holding.quantity)}</td>
                      <td>{currency(holding.buyValue)}</td>
                      <td>{currency(holding.sellValue)}</td>
                      <td>{currency(holding.amount)}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </section>

        <section className="panel">
          <div className="section-heading">
            <h2>Recent transactions</h2>
          </div>

          {loading ? (
            <div className="table-placeholder">Loading activity...</div>
          ) : recentTransactions.length === 0 ? (
            <EmptyState title="No transactions yet" message="Create an asset, then add your first buy or sell transaction." />
          ) : (
            <div className="table-wrap">
              <table>
                <thead>
                  <tr>
                    <th>Asset</th>
                    <th>Type</th>
                    <th>Date</th>
                    <th>Quantity</th>
                    <th>Value</th>
                  </tr>
                </thead>
                <tbody>
                  {recentTransactions.map((transaction) => (
                    <tr key={transaction.id}>
                      <td>{assetName(assets, transaction.assetId)}</td>
                      <td><span className={typeClass(transaction.type)}>{transaction.type}</span></td>
                      <td>{shortDate(transaction.date)}</td>
                      <td>{transaction.quantity}</td>
                      <td>{currency(transactionAmount(transaction))}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </section>
      </AppShell>
    </AuthGuard>
  );
}
