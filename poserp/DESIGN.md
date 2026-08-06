# POSERP Flutter Application — Architecture & Design Specification

---

## 1. Product Overview

### Purpose
The **POSERP Flutter Application** is a multi-platform, cross-device Point of Sale (POS) and Enterprise Resource Planning (ERP) solution designed for retail and wholesale businesses. It translates the business capabilities of the existing Next.js web application (`pos-erp-frontend`) into a high-performance native desktop and mobile experience using Flutter and GetX.

The system manages end-to-end business operations including:
* **POS Billing & Checkout**: Rapid barcode-scanning cashier interface with cart management, discounts, multiple payment methods (Cash, Card, UPI), and thermal receipt printing.
* **Master Data Management**: Inventory items, categories, subcategories, opening stock, customers, suppliers, and transporters.
* **Sales & Purchases**: Sale invoices, purchase bills, payments (Payment-In / Payment-Out), credit notes (Sale Returns), and debit notes (Purchase Returns).
* **Cash & Bank Management**: Multi-account bank tracking, cash drawer monitoring, cheque clearance, and loan accounts.
* **Financial Accounting Engine**: Double-entry bookkeeping, chart of accounts, ledgers, journals, vouchers, day book, trial balance, and balance sheet.
* **Tax & Compliance**: GST reports (Summary, Output, Input, HSN, GSTR-1, GSTR-3B) and exceptions.
* **Operational Control**: Cashier shift management, system audit logs, barcode generation, data import/export, and cloud sync/backup.

### Supported User Roles
1. **Admin**:
   * Complete access to all application modules, system settings, accounting engine, shift monitoring, financial reports, activity logs, user management, and data backup/restore.
2. **Cashier**:
   * Access focused on POS billing, customer creation, sales invoices, shift management, stock lookups, and basic transaction entry. Protected views like system activity logs and core accounting overrides are hidden or restricted.

### Main Workflows
1. **Authentication & Session Init**: Token-based login with persistent state. Application fetches `/auth/me` on startup to synchronize updated user roles and permissions.
2. **POS Cashier Workflow**: Shift start -> Customer selection -> Barcode scan / product search -> Cart item adjustments -> Payment tender (Cash/Card/UPI) -> Invoice generation -> Print receipt -> Shift close with reconciliation.
3. **Inventory & Purchasing**: Add product -> Define tax rate & pricing -> Create Purchase Order / Bill from Supplier -> Update stock automatically -> Generate Payment-Out voucher.
4. **Party Ledger & Cash Flow**: Record Customer Payment-In / Supplier Payment-Out -> Update Cash/Bank account balances -> Automatically post double-entry vouchers to Accounting ledgers.
5. **Accounting & Tax Filing**: View Day Book -> Review Trial Balance & Balance Sheet -> Export GSTR-1 / GSTR-3B tax summaries -> Perform reconciliation & health checks.

### Target Flutter Platforms
* **Desktop**: Windows (Primary local deployment), macOS, Linux.
* **Mobile**: Android (Handheld POS scanners & smartphones), iOS (iPads & iPhones).
* **Web**: Flutter Web (Fallback / cloud access).

### Responsive Layout Strategy
The application employs an adaptive design layout responsive across three breakpoint ranges:
* **Compact / Mobile (`< 600dp`)**:
  * Single-column layouts.
  * Collapsible Drawer navigation or Bottom Navigation bar.
  * Full-width cards, modal sheets, and stacked form fields.
  * Data tables rendered as swipeable card lists or compact scrollable tables.
* **Medium / Tablet (`600dp – 1024dp`)**:
  * Two-column split layouts.
  * Collapsible left sidebar navigation.
  * Grid layouts with 2 columns for cards and stats.
* **Expanded / Desktop (`> 1024dp`)**:
  * Fixed multi-column layout with left navigation sidebar and top app header.
  * Data tables with inline action menus, filter bars, and quick-view side panels.
  * POS billing screen split into 60% product grid and 40% cart/checkout panel.

---

## 2. Application Architecture

### GetX Architecture & Responsibilities
The app adheres strictly to the **GetX Pattern** using clean architecture separation:

```text
View (UI) ──> Controller (State & Logic) ──> Repository (Data Mapping) ──> Service (API & Local Storage)
```

#### Layer Responsibilities
* **Views (`lib/modules/*/views/`)**:
  * Responsible **only** for layout rendering, widget composition, and binding observables via `Obx` or `GetX`.
  * **Strict Rule**: No business logic, direct API calls, or complex calculations inside views.
* **Widgets (`lib/modules/*/widgets/`, `lib/core/widgets/`)**:
  * Reusable, modular UI components (e.g., custom buttons, text fields, cards, dialogs).
  * Receive parameters, callbacks, or reactive objects from controllers.
* **Controllers (`lib/modules/*/controllers/`)**:
  * Manage reactive UI state (`RxBool`, `RxList`, `RxStatus`).
  * Process user input, trigger validation, call repository methods, and handle UI updates.
  * Control navigation via `Get.toNamed()` or `Get.offNamed()`.
  * Manage lifecycle (`onInit`, `onReady`, `onClose`).
* **Bindings (`lib/modules/*/bindings/`, `lib/app/bindings/`)**:
  * Instantiate controllers, repositories, and services using dependency injection (`Get.lazyPut`, `Get.put`).
  * Ensure controllers are initialized when a route is accessed and disposed of when the route is removed.
* **Models (`lib/data/models/`, `lib/modules/*/models/`)**:
  * Strongly-typed Dart classes with `fromJson` and `toJson` serialization methods.
  * Enforce Dart null-safety.
* **Repositories (`lib/data/repositories/`, `lib/modules/*/repositories/`)**:
  * Abstraction layer between raw data sources (services) and domain logic (controllers).
  * Transform API JSON responses into strongly-typed Dart model objects or domain entities.
  * Handle data caching or offline fallbacks if required.
* **Services (`lib/data/services/`, `lib/core/api/`)**:
  * Low-level platform & infrastructure implementations.
  * `ApiService`: Handles HTTP requests (GET, POST, PUT, DELETE, Multipart) with headers and token authorization.
  * `StorageService`: Persistent key-value storage (`GetStorage` / `SharedPreferences`).
  * `AuthService`: Manages token lifecycle and user context.

### Route Management & Route Guards
* Named routes managed via `AppRoutes` constants and registered in `AppPages.pages`.
* Middlewares (`AuthMiddleware`, `RoleMiddleware`) validate session tokens and user roles before navigating to protected routes.

### API & Authentication Architecture
* **Base URL**: Configurable via environment configuration (`API_BASE_URL`, defaulting to `http://localhost:5500/api`).
* **Authentication Header**: Requests include `Authorization: Bearer <token>` supplied automatically by `ApiInterceptor`.
* **Token Storage**: JWT Token stored persistently in local storage under key `pos-token`, and user profile under `pos-user`.
* **401 Session Expiration**: Interceptor detects `401 Unauthorized` response, clears local storage (`pos-token`, `pos-user`), resets `AuthController` state, and redirects user to `/login`.

### Error-Handling Strategy
* Unified error representation via `AppException` (e.g., `NetworkException`, `UnauthorizedException`, `ValidationException`, `ServerException`).
* Repository calls return an `ApiResult<T>` sealed result (Success / Failure).
* Controllers update `RxStatus` state (`RxStatus.error(message)`) to render error views or display user-friendly snackbars (`Get.snackbar`) with rose/destructive styling.

---

## 3. Recommended Folder Structure

```text
lib/
├── app/
│   ├── bindings/
│   │   └── initial_binding.dart
│   ├── routes/
│   │   ├── app_pages.dart
│   │   └── app_routes.dart
│   └── app.dart
├── core/
│   ├── api/
│   │   ├── api_client.dart
│   │   ├── api_endpoints.dart
│   │   ├── api_exceptions.dart
│   │   └── api_interceptors.dart
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_radius.dart
│   │   ├── app_shadows.dart
│   │   ├── app_sizes.dart
│   │   ├── app_spacing.dart
│   │   └── app_typography.dart
│   ├── theme/
│   │   └── app_theme.dart
│   ├── utils/
│   │   ├── formatters.dart
│   │   ├── helpers.dart
│   │   └── validators.dart
│   └── widgets/
│       ├── app_button.dart
│       ├── app_card.dart
│       ├── app_data_table.dart
│       ├── app_dialog.dart
│       ├── app_dropdown.dart
│       ├── app_filter_chip.dart
│       ├── app_pagination.dart
│       ├── app_search_field.dart
│       ├── app_shell.dart
│       ├── app_text_field.dart
│       ├── confirm_dialog.dart
│       ├── empty_state.dart
│       ├── error_state.dart
│       ├── form_field_wrapper.dart
│       ├── loading_indicator.dart
│       ├── sidebar.dart
│       └── top_nav_bar.dart
├── data/
│   ├── models/
│   │   ├── api_response.dart
│   │   ├── pagination.dart
│   │   └── user.dart
│   ├── repositories/
│   │   └── auth_repository.dart
│   └── services/
│       ├── auth_service.dart
│       └── storage_service.dart
└── modules/
    ├── authentication/
    ├── dashboard/
    ├── parties/
    ├── products/
    ├── pos/
    ├── sales/
    ├── purchases/
    ├── cash_bank/
    ├── expenses/
    ├── accounting/
    ├── reports/
    ├── shifts/
    ├── activity/
    ├── backup/
    ├── utilities/
    └── settings/
```

---

## 4. Deferred Tasks & Known Issues

| Module | Issue Description | Status | Target Action |
|---|---|---|---|
| **Payment-Out (`purchases/payment_out`)** | Deferred per user instruction for deeper runtime inspection. | Temporarily Deferred | Revisit after completing Phase 4 remaining submodules. |

---