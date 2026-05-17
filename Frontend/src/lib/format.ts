import type { Asset, Transaction } from "./types";

export type AssetHolding = {
  asset: Asset;
  quantity: number;
  amount: number;
  buyValue: number;
  sellValue: number;
  transactionCount: number;
};

export function currency(value: number) {
  return new Intl.NumberFormat("en-US", {
    style: "currency",
    currency: "USD",
    maximumFractionDigits: 2,
  }).format(value);
}

export function shortDate(value: string) {
  return new Intl.DateTimeFormat("en", {
    month: "short",
    day: "numeric",
    year: "numeric",
  }).format(new Date(`${value}T00:00:00`));
}

export function assetName(assets: Asset[], assetId: number) {
  return assets.find((asset) => asset.id === assetId)?.name ?? `Asset #${assetId}`;
}

export function quantity(value: number) {
  return new Intl.NumberFormat("en-US", {
    maximumFractionDigits: 6,
  }).format(value);
}

function transactionSign(type: string) {
  const normalized = type.toUpperCase();

  if (normalized === "BUY") {
    return 1;
  }

  if (normalized === "SELL") {
    return -1;
  }

  return 0;
}

export function transactionAmount(transaction: Transaction) {
  return transactionSign(transaction.type) * transaction.quantity * transaction.price;
}

export function assetHoldings(assets: Asset[], transactions: Transaction[]): AssetHolding[] {
  return assets.map((asset) => {
    const assetTransactions = transactions.filter((transaction) => transaction.assetId === asset.id);

    return assetTransactions.reduce<AssetHolding>(
      (holding, transaction) => {
        const sign = transactionSign(transaction.type);
        const value = transaction.quantity * transaction.price;

        return {
          ...holding,
          quantity: holding.quantity + sign * transaction.quantity,
          amount: holding.amount + sign * value,
          buyValue: holding.buyValue + (sign > 0 ? value : 0),
          sellValue: holding.sellValue + (sign < 0 ? value : 0),
          transactionCount: holding.transactionCount + 1,
        };
      },
      {
        asset,
        quantity: 0,
        amount: 0,
        buyValue: 0,
        sellValue: 0,
        transactionCount: 0,
      },
    );
  });
}

export function portfolioValue(assets: Asset[], transactions: Transaction[]) {
  return assetHoldings(assets, transactions).reduce((total, holding) => total + holding.amount, 0);
}

export function typeClass(type: string) {
  const normalized = type.toLowerCase();

  if (normalized.includes("buy") || normalized.includes("stock")) {
    return "badge badge-green";
  }

  if (normalized.includes("sell") || normalized.includes("crypto")) {
    return "badge badge-red";
  }

  return "badge";
}
