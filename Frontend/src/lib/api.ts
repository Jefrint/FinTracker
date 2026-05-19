import type {
  ApiErrorBody,
  Asset,
  AssetPayload,
  AuthResponse,
  LoginPayload,
  RegisterPayload,
  Transaction,
  TransactionPayload,
  User,
} from "./types";

const API_BASE_URL =
  process.env.NEXT_PUBLIC_API_BASE_URL ?? "http://16.171.41.13:8081/api";

export class ApiError extends Error {
  status: number;
  errors: Record<string, string> | null;

  constructor(status: number, message: string, errors: Record<string, string> | null = null) {
    super(message);
    this.name = "ApiError";
    this.status = status;
    this.errors = errors;
  }
}

async function parseResponse(response: Response) {
  const text = await response.text();
  const contentType = response.headers.get("content-type") ?? "";

  if (!text) {
    return null;
  }

  if (contentType.includes("application/json")) {
    return JSON.parse(text);
  }

  try {
    return JSON.parse(text);
  } catch {
    return text;
  }
}

async function request<T>(
  path: string,
  options: RequestInit = {},
  token?: string | null,
): Promise<T> {
  const headers = new Headers(options.headers);

  if (options.body && !headers.has("Content-Type")) {
    headers.set("Content-Type", "application/json");
  }

  if (token) {
    headers.set("Authorization", `Bearer ${token}`);
  }

  const response = await fetch(`${API_BASE_URL}${path}`, {
    ...options,
    headers,
  });
  const body = await parseResponse(response);

  if (!response.ok) {
    if (typeof body === "string") {
      throw new ApiError(response.status, body);
    }

    const errorBody = body as ApiErrorBody | null;
    throw new ApiError(
      response.status,
      errorBody?.message ?? `Request failed with status ${response.status}`,
      errorBody?.errors ?? null,
    );
  }

  return body as T;
}

export const api = {
  login: (payload: LoginPayload) =>
    request<AuthResponse>("/auth/login", {
      method: "POST",
      body: JSON.stringify(payload),
    }),
  register: (payload: RegisterPayload) =>
    request<User>("/auth/register", {
      method: "POST",
      body: JSON.stringify(payload),
    }),
  logout: (token: string) =>
    request<string>("/auth/logout", { method: "POST" }, token),
  me: (token: string) => request<User>("/users/me", {}, token),
  updateUser: (id: number, payload: RegisterPayload, token: string) =>
    request<User>(
      `/users/${id}`,
      {
        method: "PUT",
        body: JSON.stringify(payload),
      },
      token,
    ),
  deleteUser: (id: number, token: string) =>
    request<null>(`/users/${id}`, { method: "DELETE" }, token),
  assets: (token: string) => request<Asset[]>("/assets", {}, token),
  createAsset: (payload: AssetPayload, token: string) =>
    request<Asset>(
      "/assets",
      {
        method: "POST",
        body: JSON.stringify(payload),
      },
      token,
    ),
  deleteAsset: (id: number, token: string) =>
    request<null>(`/assets/${id}`, { method: "DELETE" }, token),
  transactions: (token: string) =>
    request<Transaction[]>("/transactions", {}, token),
  createTransaction: (payload: TransactionPayload, token: string) =>
    request<Transaction>(
      "/transactions",
      {
        method: "POST",
        body: JSON.stringify(payload),
      },
      token,
    ),
  deleteTransaction: (id: number, token: string) =>
    request<null>(`/transactions/${id}`, { method: "DELETE" }, token),
};
