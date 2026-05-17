# FinTracker Frontend Guide

This guide explains what the frontend code does, why each part exists, and how to validate it locally.

## Tech Stack

The frontend is a Next.js, React, and TypeScript app.

Run it locally:

```cmd
cd Frontend
npm run dev
```

Open:

```text
http://localhost:3000
```

The frontend talks to the backend at:

```text
http://localhost:8081/api
```

That API base URL is configured in:

```text
src/lib/api.ts
```

## Main Folder Structure

```text
Frontend/
  package.json
  src/
    app/
    components/
    lib/
```

`package.json` contains scripts and dependencies.

Important scripts:

```json
"dev": "next dev",
"build": "next build",
"lint": "eslint"
```

Use these during validation:

```cmd
npm run lint
npm run build
npm run dev
```

## App Routes

The `src/app` folder uses Next.js file-based routing. Each folder becomes a route.

```text
src/app/page.tsx              -> /
src/app/login/page.tsx        -> /login
src/app/register/page.tsx     -> /register
src/app/dashboard/page.tsx    -> /dashboard
src/app/assets/page.tsx       -> /assets
src/app/transactions/page.tsx -> /transactions
src/app/profile/page.tsx      -> /profile
```

`src/app/page.tsx` redirects `/` to `/dashboard`.

## Root Layout

File:

```text
src/app/layout.tsx
```

This wraps the whole app.

It imports global styles:

```tsx
import "./globals.css";
```

It also wraps every page with:

```tsx
<Providers>{children}</Providers>
```

This is needed because every page should be able to access authentication state.

## Providers

File:

```text
src/app/providers.tsx
```

This adds:

```tsx
<AuthProvider>
```

`AuthProvider` stores the logged-in user, JWT token, login/logout functions, and session restore logic.

## Authentication

Main file:

```text
src/components/AuthProvider.tsx
```

It stores:

```ts
token
user
loading
```

Login flow:

```text
User submits login form
-> frontend calls api.login()
-> backend returns user + JWT token
-> frontend saves token/user in localStorage
-> redirects to /dashboard
```

The browser storage key is:

```text
fintracker.auth
```

The app uses `localStorage` so the user stays logged in after refreshing the page.

Refresh flow:

```text
AuthProvider checks localStorage
-> restores token
-> calls /users/me
-> if valid, user stays logged in
-> if invalid, token is removed
```

## Route Protection

File:

```text
src/components/AuthGuard.tsx
```

Protected pages use `AuthGuard`.

It checks:

```ts
if (!loading && !token) {
  router.replace("/login");
}
```

Protected pages:

```text
/dashboard
/assets
/transactions
/profile
```

Public pages:

```text
/login
/register
```

## API Layer

File:

```text
src/lib/api.ts
```

This file centralizes all backend calls.

Examples:

```ts
api.login()
api.register()
api.assets()
api.transactions()
api.createAsset()
api.createTransaction()
api.updateUser()
```

This is used so pages do not need to write raw `fetch()` logic repeatedly.

For protected requests, it adds:

```text
Authorization: Bearer <token>
```

That lets the backend identify the logged-in user.

## Types

File:

```text
src/lib/types.ts
```

This defines frontend data shapes:

```text
User
Asset
Transaction
AuthResponse
LoginPayload
RegisterPayload
AssetPayload
TransactionPayload
```

TypeScript uses these to catch mistakes when frontend data does not match backend response data.

Example:

```ts
export type Transaction = {
  id: number;
  quantity: number;
  price: number;
  type: string;
  date: string;
  assetId: number;
};
```

## Calculation Logic

File:

```text
src/lib/format.ts
```

This contains helper functions for:

```text
currency formatting
date formatting
asset name lookup
net worth calculation
asset holdings calculation
badge styling
```

Important net worth logic:

```text
BUY  -> adds quantity and amount
SELL -> reduces quantity and amount
```

Example:

```text
Buy 10 x $100 = +$1000
Sell 2 x $120 = -$240
Net amount = $760
Quantity = 8
```

## App Layout And Navigation

File:

```text
src/components/AppShell.tsx
```

This is the main logged-in layout.

It contains:

```text
brand
sidebar navigation
mobile hamburger menu
signed-in user
sign out button
main page content
```

Desktop behavior:

```text
sidebar navigation
```

Mobile behavior:

```text
hamburger menu with:
Dashboard
Assets
Transactions
Profile
Signed-in user
Sign out
```

## Pages

### Login

File:

```text
src/app/login/page.tsx
```

Handles the login form.

Validates:

```text
email required
password required
backend error messages
```

On success:

```text
redirects to /dashboard
```

### Register

File:

```text
src/app/register/page.tsx
```

Handles account creation.

On success:

```text
redirects to /login
```

### Dashboard

File:

```text
src/app/dashboard/page.tsx
```

Shows:

```text
Net worth
Assets count
Transactions count
Asset holdings table
Recent transactions
```

Uses `AuthGuard`, so login is required.

### Assets

File:

```text
src/app/assets/page.tsx
```

Shows:

```text
Create asset form
All assets table
Quantity
Amount
Transaction count
Delete asset
```

### Transactions

File:

```text
src/app/transactions/page.tsx
```

Shows:

```text
Create transaction form
Transaction history table
Buy/Sell/Dividend/Transfer options
Delete transaction
```

For net worth calculation, mainly `BUY` and `SELL` matter.

### Profile

File:

```text
src/app/profile/page.tsx
```

Shows:

```text
Update user profile
Delete account
```

## Reusable Components

```text
AuthProvider.tsx   -> stores auth state
AuthGuard.tsx      -> protects private pages
AppShell.tsx       -> app layout/nav
FieldError.tsx     -> field validation message
StatusMessage.tsx  -> error/success message
StatCard.tsx       -> dashboard stat card
EmptyState.tsx     -> empty table/message UI
```

These exist so repeated UI and behavior are not duplicated across pages.

## Styling

File:

```text
src/app/globals.css
```

This contains the full UI style:

```text
black theme
buttons
forms
tables
sidebar
hamburger menu
responsive layout
animations
mobile styling
```

The project uses one global CSS file because this is a small app and global styling is simple to manage.

## Frontend Validation Checklist

Run:

```cmd
cd C:\Users\jefy0\Desktop\works\FinTracker\Frontend
npm run lint
npm run build
npm run dev
```

Manual test:

```text
1. Open /register
2. Create account
3. Login
4. Create asset
5. Create BUY transaction
6. Check dashboard net worth increases
7. Create SELL transaction
8. Check dashboard net worth decreases
9. Check Assets page quantity and amount
10. Test mobile view and hamburger menu
11. Sign out
12. Try opening /dashboard directly, should redirect to /login
```

Main validation points:

```text
Auth works
Protected routes work
API calls include JWT
CORS works
Net worth calculation is correct
Mobile menu works
Tables are readable on mobile
Frontend builds successfully
```
