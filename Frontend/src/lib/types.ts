export type User = {
  id: number;
  name: string;
  email: string;
};

export type Asset = {
  id: number;
  name: string;
  type: string;
  userId: number;
  transactionIds: number[];
};

export type Transaction = {
  id: number;
  quantity: number;
  price: number;
  type: string;
  date: string;
  assetId: number;
};

export type AuthResponse = User & {
  token: string;
  type: "Bearer";
};

export type ApiErrorBody = {
  message?: string;
  timestamp?: string;
  errors?: Record<string, string> | null;
};

export type LoginPayload = {
  email: string;
  password: string;
};

export type RegisterPayload = LoginPayload & {
  name: string;
};

export type AssetPayload = {
  name: string;
  type: string;
};

export type TransactionPayload = {
  quantity: number;
  price: number;
  type: string;
  date: string;
  assetId: number;
};
