# FinTracker Backend Context for Next.js Frontend Generation

## Overview

This project is a Spring Boot backend for a finance tracking app.

- Base URL: `http://localhost:8081/api`
- Database: PostgreSQL
- Authentication: JWT Bearer token
- Password storage: BCrypt-hashed passwords
- Token expiry: configured by `JWT_EXPIRATION`

The frontend should consume the backend as it currently exists.

## Runtime and Backend Notes

- Server port is `8081`
- Global context path is `/api`
- All routes are prefixed with `/api`
- JPA schema mode is `update`
- JWT secret is configured with `JWT_SECRET`
- JWT expiration is configured with `JWT_EXPIRATION`
- There is a global exception handler using `ErrorResponseDTO`
- There is no visible CORS configuration in the backend

Because CORS is not configured, a browser-based Next.js app may need backend CORS configuration before API calls from a different origin will work.

## Authentication Model

### Public endpoints

- `POST /api/auth/register`
- `POST /api/auth/login`
- `POST /api/auth/logout`

### Protected endpoints

Every route outside `/auth/**` requires a valid JWT.

### Authorization header

```http
Authorization: Bearer <token>
```

### JWT behavior

- The JWT subject is the user's email
- The backend validates the JWT on protected requests
- The JWT filter stores the authenticated email in Spring Security context
- Protected service methods derive the current user from that authenticated email
- Logout does not invalidate the token server-side
- There is no refresh token flow

## Current Data Model

### User

```ts
type User = {
  id: number;
  name: string;
  email: string;
};
```

### Asset

```ts
type Asset = {
  id: number;
  name: string;
  type: string;
  userId: number;
  transactionIds: number[];
};
```

### Transaction

```ts
type Transaction = {
  id: number;
  quantity: number;
  price: number;
  type: string;
  date: string; // LocalDate, format: YYYY-MM-DD
  assetId: number;
};
```

### Auth response

```ts
type AuthResponse = {
  token: string;
  type: "Bearer";
  id: number;
  name: string;
  email: string;
};
```

### Error response

```ts
type ErrorResponse = {
  message: string;
  timestamp: string;
  errors: Record<string, string> | null;
};
```

Validation errors use `message: "Validation failed"` and put field-specific messages in `errors`.

## Validation Rules

### Register and create/update user

- `name`: required, non-blank
- `email`: required, non-blank, valid email format
- `password`: required, non-blank, minimum 6 characters

### Login

- `email`: required, non-blank, valid email format
- `password`: required, non-blank

### Asset

- `name`: required, non-blank
- `type`: required, non-blank

### Transaction

- `quantity`: required, greater than 0
- `price`: required, greater than 0
- `type`: required, non-blank
- `date`: required, `YYYY-MM-DD`
- `assetId`: required

## API Reference

## 1. Auth APIs

### `POST /api/auth/register`

Creates a new user account.

Request body:

```json
{
  "name": "Alice",
  "email": "alice@example.com",
  "password": "secret123"
}
```

Success response: `201 Created`

```json
{
  "id": 1,
  "name": "Alice",
  "email": "alice@example.com"
}
```

Frontend notes:

- Registration does not return a token
- After registration, redirect to login or call login

### `POST /api/auth/login`

Authenticates a user and returns a JWT token.

Request body:

```json
{
  "email": "alice@example.com",
  "password": "secret123"
}
```

Success response: `200 OK`

```json
{
  "token": "<jwt-token>",
  "type": "Bearer",
  "id": 1,
  "name": "Alice",
  "email": "alice@example.com"
}
```

Failure response: `401 Unauthorized`

```json
"Invalid email or password"
```

### `POST /api/auth/logout`

Returns a success message, but token removal is still client-side.

Success response: `200 OK`

```json
"Logged out successfully"
```

## 2. User APIs

All `/api/users/**` endpoints require JWT authentication.

### `GET /api/users`

Returns the authenticated user as a one-item list.

### `GET /api/users/me`

Returns the current authenticated user.

Success response: `200 OK`

```json
{
  "id": 1,
  "name": "Alice",
  "email": "alice@example.com"
}
```

### `GET /api/users/{id}`

Returns the user only if `{id}` belongs to the authenticated user.

Failure response:

- `404 Not Found` if the user is missing or does not belong to the authenticated email

### `PUT /api/users/{id}`

Updates the user only if `{id}` belongs to the authenticated user.

Request body:

```json
{
  "name": "Alice Updated",
  "email": "alice.updated@example.com",
  "password": "newsecret123"
}
```

Important backend behavior:

- The update expects all three fields
- Password is always re-encoded from the incoming request
- The controller currently does not use `@Valid` on this update endpoint

### `DELETE /api/users/{id}`

Deletes the user only if `{id}` belongs to the authenticated user.

Success response:

- `204 No Content`

## 3. Asset APIs

All `/api/assets/**` endpoints require JWT authentication.

Assets are scoped on the backend to the authenticated user.

### `POST /api/assets`

Creates an asset for the authenticated user. Do not send `userId`.

Request body:

```json
{
  "name": "Bitcoin",
  "type": "CRYPTO"
}
```

Success response: `200 OK`

```json
{
  "id": 1,
  "name": "Bitcoin",
  "type": "CRYPTO",
  "userId": 1,
  "transactionIds": []
}
```

### `GET /api/assets`

Returns only the authenticated user's assets.

### `GET /api/assets/{id}`

Returns an asset only if it belongs to the authenticated user.

### `DELETE /api/assets/{id}`

Deletes an asset only if it belongs to the authenticated user.

Success response:

- `204 No Content`

There are currently no update APIs for assets.

## 4. Transaction APIs

All `/api/transactions/**` endpoints require JWT authentication.

Transactions are scoped on the backend through assets owned by the authenticated user.

### `POST /api/transactions`

Creates a transaction for an asset owned by the authenticated user.

Request body:

```json
{
  "quantity": 0.5,
  "price": 62000,
  "type": "BUY",
  "date": "2026-04-13",
  "assetId": 1
}
```

Success response: `200 OK`

```json
{
  "id": 1,
  "quantity": 0.5,
  "price": 62000.0,
  "type": "BUY",
  "date": "2026-04-13",
  "assetId": 1
}
```

If the asset is missing or belongs to another user, the backend returns `404 Not Found`.

### `GET /api/transactions`

Returns only transactions belonging to assets owned by the authenticated user.

### `GET /api/transactions/{id}`

Returns a transaction only if it belongs to an asset owned by the authenticated user.

### `DELETE /api/transactions/{id}`

Deletes a transaction only if it belongs to an asset owned by the authenticated user.

Success response:

- `204 No Content`

There are currently no update APIs for transactions.

## Recommended Frontend Auth Flow

1. User signs up through `POST /api/auth/register`
2. User signs in through `POST /api/auth/login`
3. Save the returned JWT token and user object
4. Send the token in `Authorization` header for all protected APIs
5. On app startup, restore auth state from storage if token exists
6. Optionally call `GET /api/users/me` to refresh the current user
7. On `401`, clear auth state and redirect to login
8. On logout, clear token locally and optionally call `POST /api/auth/logout`

## Recommended Frontend Pages

- Login page
- Register page
- Dashboard page
- Assets list page
- Create asset form
- Transactions list page
- Create transaction form
- Profile or account page using `/users/me`

## Suggested API Client Behavior

The frontend should:

- Centralize API calls in one client module
- Use `http://localhost:8081/api` as the base URL during local development
- Automatically attach `Authorization: Bearer <token>` for protected calls
- Parse JSON success responses
- Handle plain string responses from login failure and logout success
- Handle `ErrorResponseDTO` for validation, not-found, bad-request, and unexpected errors
- Treat `401 Unauthorized` as an expired or invalid session
- Trust backend filtering for assets and transactions
- Avoid sending `userId` when creating assets

## Important Backend Limitations

- No refresh token support
- No server-side token invalidation on logout
- No update endpoints for assets
- No update endpoints for transactions
- No visible CORS configuration
- Asset and transaction `type` fields are plain strings, not enums
- Duplicate email handling is not explicitly implemented in service code or entity constraints

## Source Summary

This document was updated from the current Spring Boot code in:

- `src/main/resources/application.properties`
- `src/main/java/com/fintracker/config/*`
- `src/main/java/com/fintracker/controller/*`
- `src/main/java/com/fintracker/service/*`
- `src/main/java/com/fintracker/dto/request/*`
- `src/main/java/com/fintracker/dto/response/*`
- `src/main/java/com/fintracker/exception/*`
