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
    │   ├── bindings/
    │   │   └── auth_binding.dart
    │   ├── controllers/
    │   │   └── auth_controller.dart
    │   ├── models/
    │   │   └── login_payload.dart
    │   ├── repositories/
    │   │   └── auth_repository.dart
    │   ├── views/
    │   │   ├── login_view.dart
    │   │   ├── register_view.dart
    │   │   └── forgot_password_view.dart
    │   └── widgets/
    │       └── auth_card.dart
    ├── dashboard/
    ├── parties/
    │   ├── customers/
    │   ├── suppliers/
    │   └── transporters/
    ├── products/
    │   ├── categories/
    │   ├── subcategories/
    │   └── opening_stock/
    ├── pos/
    ├── sales/
    │   ├── payment_in/
    │   └── return/
    ├── purchases/
    │   ├── payment_out/
    │   └── return/
    ├── cash_bank/
    │   ├── bank/
    │   ├── cash/
    │   ├── cheques/
    │   └── loans/
    ├── expenses/
    ├── accounting/
    │   ├── chart_of_accounts/
    │   ├── ledgers/
    │   ├── vouchers/
    │   ├── day_book/
    │   ├── trial_balance/
    │   ├── reports/
    │   └── gst/
    ├── reports/
    ├── shifts/
    ├── activity/
    ├── backup/
    ├── utilities/
    └── settings/
```

### Module Descriptions

| Module | Purpose | Main Screens | Dependencies | Scope |
|---|---|---|---|---|
| **`authentication`** | User login, registration, password recovery, session token handling. | Login, Register, Forgot Password | Core API, Storage Service | Shared / Core Module |
| **`dashboard`** | Summary metrics, daily/monthly sales, payment breakdown, low stock alerts, recent sales. | Dashboard View | Auth, Sales, Products | Feature Module |
| **`parties`** | Management of Customers, Suppliers, and Transporters with ledger balance tracking. | Customer List/Detail, Supplier List, Transporter List | Core Widgets, Storage | Feature Module |
| **`products`** | Catalog management: Products, Categories, Subcategories, Opening Stock initialization. | Product List/Form, Category List, Subcategory List, Opening Stock View | Core Widgets, Upload Service | Feature Module |
| **`pos`** | Fast touch-optimized cashier interface, cart state, barcode scanning, checkout modal. | POS View, Checkout Dialog | Products, Customers, Cart Store | Feature Module |
| **`sales`** | Sales invoice creation, Payment-In ledger collection, Sale Return (Credit Notes). | Sale List/Detail, Payment-In View, Credit Note Form | Parties, Products, POS | Feature Module |
| **`purchases`** | Purchase bills from suppliers, Payment-Out processing, Purchase Return (Debit Notes). | Purchase List/Form, Payment-Out View, Debit Note Form | Parties, Products | Feature Module |
| **`cash_bank`** | Bank accounts, Cash balances, Cheque tracking, Loan account management. | Transaction History, Bank Accounts, Cash View, Cheque List, Loans View | Core Widgets, Accounting | Feature Module |
| **`expenses`** | Direct/indirect expense logging, Income logging, receipt attachment. | Expense List/Form, Income List/Form | Cash & Bank, Categories | Feature Module |
| **`accounting`** | Double-entry bookkeeping engine, Chart of Accounts, Ledgers, Vouchers, Day Book, Reports, GST. | COA View, Ledger View, Journal Voucher Form, Trial Balance, GST Reports | Parties, Sales, Purchases | Feature Module |
| **`reports`** | Business analytics, sales reports, inventory turnover, profit/loss charts. | General Reports View | Sales, Purchases, Inventory | Feature Module |
| **`shifts`** | Cashier shift opening, shift closing, cash tallying, shift audit log. | Shift Manager View, Open/Close Shift Dialog | Auth, Cash & Bank, POS | Feature Module |
| **`activity`** | Audit trail of user actions, login/logout logs, stock adjustments. (Admin only) | Activity Logs View | Auth | Feature Module |
| **`backup`** | Database backup generation, JSON data export, restore from backup file. | Backup & Restore View | Storage, Core API | Feature Module |
| **`utilities`** | Barcode label generator, CSV/Excel data import/export tools. | Barcode Generator View, Import/Export View | Products, Sales | Feature Module |
| **`settings`** | Business profile configuration, tax settings, thermal printer preferences, app theme. | Settings View, Business Profile Form | Storage, Auth | Feature Module |

---

## 4. Design System Specification

Extracting design tokens directly from `pos-erp-frontend/src/app/globals.css`:

### Design Tokens

#### 1. Color Palette (`AppColors`)

| Token Name | Web Variable | Light Mode | Dark Mode | Usage |
|---|---|---|---|---|
| `primary` | `--primary` | `#14B8A6` (Teal 500) | `#14B8A6` (Teal 500) | Main action buttons, active states, active tab indicator |
| `primaryHover` | `--primary-hover` | `#0D9488` (Teal 600) | `#0D9488` (Teal 600) | Button hover & press states |
| `primarySoft` | `--primary-soft` | `#CCFBF1` (Teal 100) | `#042F2E` (Teal 950) | Active menu backgrounds, soft badge tiles |
| `secondary` | `--secondary` | `#F0FDFA` (Teal 50) | `#143636` | Table header fill, alternate card backgrounds |
| `secondaryForeground` | `--secondary-foreground` | `#0F172A` (Slate 900) | `#ECFEFF` (Cyan 50) | Text inside secondary containers |
| `accent` | `--accent` | `#F97316` (Orange 500) | `#F97316` (Orange 500) | Highlight badges, secondary callouts |
| `background` | `--background` | `#F8FAFC` (Slate 50) | `#071A1A` | Main page background |
| `card` | `--card` | `#FFFFFF` | `#0F2A2A` | Cards, dialogs, drawers, dropdown popups |
| `foreground` | `--foreground` | `#0F172A` (Slate 900) | `#ECFEFF` (Cyan 50) | Primary body text & headings |
| `muted` | `--muted` | `#F0FDFA` | `#143636` | Disabled element fills, subtle dividers |
| `mutedForeground` | `--muted-foreground` | `#64748B` (Slate 500) | `#7FA3A3` | Subtitles, placeholders, secondary text |
| `border` | `--border` | `#E2E8F0` (Slate 200) | `#245252` | Container borders, table grid lines |
| `input` | `--input` | `#E2E8F0` (Slate 200) | `#245252` | Form input field borders |
| `ring` | `--ring` | `#14B8A6` (Teal 500) | `#14B8A6` (Teal 500) | Focus ring outline |
| `success` | `--success` | `#22C55E` (Green 500) | `#22C55E` (Green 500) | Positive balances, paid status, profit |
| `danger` / `destructive` | `--danger` | `#F43F5E` (Rose 500) | `#F43F5E` (Rose 500) | Negative balances, overdue, delete actions |
| `warning` | `--warning` | `#F59E0B` (Amber 500) | `#F59E0B` (Amber 500) | Pending status, low stock alert |
| `info` | `--info` | `#38BDF8` (Sky 400) | `#38BDF8` (Sky 400) | Informational tags, system notices |

#### 2. Typography Scale (`AppTypography`)
* **Primary Font**: `Inter` (Sans-serif)
* **Monospace Font**: `JetBrains Mono` (For receipt numbers, currency amounts, SKUs, and barcodes)

| Text Style Name | Font Size | Weight | Line Height | Letter Spacing | Mapping / Usage |
|---|---|---|---|---|---|
| `pageTitle` | `24px` (`1.5rem`) | SemiBold (`w600`) | `1.2` | `-0.025em` | Main screen titles (`.page-title`) |
| `sectionTitle` | `15px` (`0.95rem`) | Bold (`w700`) | `1.3` | `0` | Card header, section titles (`.section-title`) |
| `sectionDescription` | `14px` (`0.875rem`) | Medium (`w500`) | `1.5` | `0` | Subtitle descriptions (`.section-description`) |
| `body` | `15px` | Regular (`w400`) | `1.5` | `0` | General body text, form input text |
| `bodyMedium` | `15px` | Medium (`w500`) | `1.5` | `0` | Form labels, button text |
| `tableHeading` | `12px` (`0.75rem`) | ExtraBold (`w800`) | `1.2` | `0.1em` | Table column headers (`.table-heading`, uppercase) |
| `caption` | `14px` (`0.875rem`) | Regular (`w400`) | `1.35` | `0` | Page description text (`.page-description`) |
| `amountPositive` | `15px` | Black (`w900`) | `1.5` | `0` | Monospace green currency (`.amount-positive`) |
| `amountNegative` | `15px` | Black (`w900`) | `1.5` | `0` | Monospace rose currency (`.amount-negative`) |
| `receiptCode` | `14px` | ExtraBold (`w800`) | `1.4` | `0` | Monospace code/invoice number (`.receipt-code`) |

#### 3. Spacing Scale (`AppSpacing`)
* Base unit: `4px`
* `xs`: `4px`
* `sm`: `8px`
* `md`: `12px`
* `lg`: `16px`
* `xl`: `20px`
* `xxl`: `24px`
* `3xl`: `32px`
* `4xl`: `48px`

#### 4. Border Radius Scale (`AppRadius`)
* `--radius`: `10px` (`0.625rem`)
* `sm`: `6px` (`var(--radius) - 4px`)
* `md`: `8px` (`var(--radius) - 2px`)
* `lg`: `10px` (`var(--radius)`)
* `xl`: `14px` (`var(--radius) + 4px`)
* `xxl`: `18px` (`var(--radius) + 8px`)
* `full`: `9999px`

#### 5. Elevation & Shadows (`AppShadows`)
* `cardLight`: `BoxShadow(color: Color(0x0F0F172A), blurRadius: 36, offset: Offset(0, 14))` (`0 14px 36px rgba(15,23,42,0.06)`)
* `cardDark`: `BoxShadow(color: Color(0x38000000), blurRadius: 48, offset: Offset(0, 18))` (`0 18px 48px rgba(0,0,0,0.22)`)
* `dropdown`: `BoxShadow(color: Color(0x1F0F172A), blurRadius: 20, offset: Offset(0, 8))`

#### 6. Component Dimensions (`AppSizes`)
* `buttonHeightSm`: `36px`
* `buttonHeightMd`: `44px`
* `buttonHeightLg`: `52px`
* `inputHeight`: `44px`
* `iconSm`: `16px`
* `iconMd`: `20px`
* `iconLg`: `24px`
* `sidebarWidthExpanded`: `260px`
* `sidebarWidthCollapsed`: `72px`

#### 7. Flutter Theme Mapping (`AppTheme`)
```dart
class AppTheme {
  static ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.backgroundLight,
        primaryColor: AppColors.primary,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.secondaryLight,
          surface: AppColors.cardLight,
          error: AppColors.danger,
        ),
        fontFamily: 'Inter',
        // Additional theme definitions...
      );

  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.backgroundDark,
        primaryColor: AppColors.primary,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.secondaryDark,
          surface: AppColors.cardDark,
          error: AppColors.danger,
        ),
        fontFamily: 'Inter',
        // Additional theme definitions...
      );
}
```

---

## 5. Shared Components Specification

The reusable Flutter widgets in `lib/core/widgets/` map directly to the Next.js component system (`src/components/ui` & `src/components/shared`):

1. **`AppShell`**:
   * **Behavior**: Adaptive scaffold container wrapping protected views. Renders `Sidebar` on desktop/tablet, `Drawer` on mobile, and `TopNavBar` across all viewports.
2. **`Sidebar`**:
   * **Behavior**: Vertical navigation list with accordion groups (Parties, Inventory, Sales, Purchases, Cash & Bank, Accounting, Utilities). Highlights active route, supports collapsed state (72px) with tooltip previews.
3. **`TopNavBar`**:
   * **Behavior**: Top bar rendering breadcrumbs/page title, global search shortcut trigger, cashier shift indicator pill, light/dark theme toggle, user profile menu, and notifications drawer trigger.
4. **`AppButton`**:
   * **Variants**: `Primary` (Teal fill), `Secondary` (Soft fill), `Outline` (Bordered), `Ghost` (Transparent), `Destructive` (Rose fill).
   * **States**: Normal, Hover, Focused, Disabled, Loading (renders inline spinner).
5. **`AppTextField`**:
   * **Behavior**: Wrapped `TextFormField` styled with `AppColors.input` border, focus ring in `AppColors.primary`, label with optional red asterisk, helper text, error message, clear button, and suffix icon.
6. **`AppDropdown<T>`**:
   * **Behavior**: Custom dropdown menu with search filter capability, supporting single/multi-selection and custom item rendering.
7. **`AppSearchField`**:
   * **Behavior**: Debounced input field (300ms delay) with search icon, clear button, and automatic query callback.
8. **`AppCard`**:
   * **Behavior**: Styled container with `AppColors.card` fill, `AppColors.border` stroke, `AppRadius.lg` rounded corners, and shadow matching `AppShadows.cardLight` / `cardDark`. Supports optional glassmorphic backdrop blur.
9. **`AppDataTable<T>`**:
   * **Behavior**: Responsive data table with fixed/sticky headers (`AppColors.secondary` fill, uppercase bold header text), sorting arrows, row selection checkboxes, action menu dropdowns, and empty/loading states.
10. **`AppPagination`**:
    * **Behavior**: Pagination bar displaying total item count, current range ("Showing 1 to 10 of 120 items"), page number selector, and Previous/Next page controls.
11. **`AppFilterChip`**:
    * **Behavior**: Selectable filter pills used above tables (e.g., Status: All, Paid, Pending, Overdue).
12. **`AppDialog`**:
    * **Behavior**: Modal dialog wrapper with header, title, close button (`X`), scrollable body, and action footer buttons.
13. **`ConfirmDialog`**:
    * **Behavior**: Specialized confirmation alert modal for destructive actions (e.g., delete product, void invoice, cancel shift).
14. **`LoadingIndicator` / `Skeleton`**:
    * **Behavior**: Shimmering card and table row skeletons (`.skeleton` shimmer animation) for async data fetching.
15. **`EmptyState`**:
    * **Behavior**: Empty data view rendering an icon tile, title, descriptive message, and call-to-action button (e.g., "No customers found. Add Customer").
16. **`ErrorState`**:
    * **Behavior**: Rendered when API call fails. Displays error alert icon, user-friendly message, and "Retry" button.
17. **`FormFieldWrapper`**:
    * **Behavior**: Structural container for label, required asterisk, child input widget, and field validation error string.

---

## 6. API Mapping & Environment Configuration

### Base URL Configuration
* **Environment Variable**: `API_BASE_URL` (Defaults to `http://localhost:5500/api`).
* **Flutter Implementation**: Managed via `AppConfig` class in `lib/core/constants/app_config.dart`.

### Headers & Authentication
```text
Content-Type: application/json
Authorization: Bearer <token>
```
* Multi-part requests (`FormData`) automatically strip `Content-Type` so boundary parameters are set by the HTTP client.

### Standard Request & Response Structure
All API endpoints return JSON conforming to `ApiResponse<T>`:

```json
{
  "success": true,
  "data": {},
  "message": "Operation completed successfully",
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 42,
    "pages": 5
  }
}
```

### Error Response Mapping
When an API error occurs, response payload conforms to:
```json
{
  "success": false,
  "message": "Detailed error message",
  "errors": ["Specific field error 1", "Specific field error 2"]
}
```
Mapped in Flutter into `AppException.fromResponse(statusCode, json)`.

---

## API Source of Truth & Integration Contract

The POSERP Flutter application uses two root-level specification documents:

* `design.md` — source of truth for Flutter architecture, UI, modules, navigation, state management, repositories, services, models, and implementation order.
* `pos-erp-api-curl-guide.md` — source of truth for backend API endpoints, HTTP methods, authentication requirements, path parameters, request payload examples, and available backend operations.

### API Priority

For all API-related implementation, `pos-erp-api-curl-guide.md` takes precedence over endpoint assumptions or examples written in this document.

Flutter screen routes must never be treated as backend API routes.

Example:

Flutter route:

```text
/purchases/return
```

does not imply:

```text
/api/purchases/return
```

The actual backend API must be taken from `pos-erp-api-curl-guide.md`.

### API Base URL

The production backend base URL is:

```text
https://pos-erp-backend.onrender.com/api
```

The Flutter app must use one centralized base URL configuration through `AppConfig`.

Example:

```dart
class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://pos-erp-backend.onrender.com/api',
  );
}
```

Do not hardcode complete backend URLs inside controllers, repositories, or views.

### Endpoint Organization

`ApiEndpoints` should contain relative paths only.

Example:

```dart
class ApiEndpoints {
  static const purchases = '/purchases';
  static const purchaseReturns = '/purchase-returns';

  static String purchase(String id) => '/purchases/$id';

  static String purchaseReturn(String id) =>
      '/purchase-returns/$id';

  static String supplierUnreturnedPurchases(String supplierId) =>
      '/purchase-returns/supplier/$supplierId';

  static String purchaseReturnableItems(String billId) =>
      '/purchase-returns/bill/$billId/returnable-items';
}
```

### API Implementation Flow

Every backend-connected module must follow:

```text
View
  ↓
Controller
  ↓
Repository
  ↓
Service / ApiClient
  ↓
Backend API
```

Views must never make direct HTTP requests.

### API Verification Requirement

Before implementing a module:

1. Read its functional and UI requirements from `design.md`.
2. Read all relevant endpoints from `pos-erp-api-curl-guide.md`.
3. Verify HTTP methods and endpoint paths.
4. Verify request field names.
5. Verify path and query parameters.
6. Add or reuse endpoint constants.
7. Implement Service -> Repository -> Controller -> View.
8. Verify the complete runtime workflow before marking the module complete.

### Incomplete API Documentation

Some entries in `pos-erp-api-curl-guide.md` may contain placeholder payloads such as:

```json
{
  "sampleKey": "value"
}
```

A placeholder payload must never be used as the production request body.

When the exact request or response schema is not documented:

1. Inspect the existing Next.js implementation.
2. Match its endpoint, payload, query parameters, and response handling.
3. If still unclear, inspect the backend route/controller/schema.
4. Do not invent API fields.

### Definition of API-Complete

A module is not considered complete merely because Flutter analysis passes.

A backend-connected module is complete only when:

* Endpoint paths are verified.
* HTTP methods are verified.
* Authentication works.
* Request payloads match the backend.
* Response parsing matches runtime responses.
* Loading states work.
* Error states work.
* Empty states work.
* Create/update/delete/cancel operations work where applicable.
* Lists refresh correctly after mutations.
* No runtime API errors remain.
* `flutter analyze` passes.


## 7. Recommended Module Implementation Order

To ensure systematic progress, implementation is broken down into 7 incremental phases. **Phase 1 is the mandatory foundation and must be approved before proceeding to subsequent modules.**

### Phase 1: Shared Foundation & Authentication Module (Current Target Scope)
* **Scope**:
  * Set up core architecture: `AppColors`, `AppTypography`, `AppSpacing`, `AppRadius`, `AppShadows`, `AppTheme`.
  * Set up API layer: `ApiClient`, `ApiEndpoints`, `ApiInterceptors`, `AppException`.
  * Set up Local Storage: `StorageService` (`GetStorage`).
  * Core Shared Widgets: `AppButton`, `AppTextField`, `AppCard`, `LoadingIndicator`, `ConfirmDialog`.
  * Authentication Module (`lib/modules/authentication/`):
    * `AuthBinding`, `AuthController`, `AuthRepository`, `AuthService`.
    * Models: `User`, `LoginPayload`, `RegisterPayload`, `AuthResponse`.
    * Views: `LoginView`, `RegisterView`, `ForgotPasswordView`.
    * App startup route check (`/login` vs `/dashboard` based on token validity).
* **Acceptance Criteria**:
  * App compiles cleanly without errors or warnings.
  * User can log in with valid credentials via API, receiving and storing JWT token and User model in `GetStorage`.
  * User is navigated to placeholder Dashboard upon successful authentication.
  * Session persists across app restarts (auto-login via `/auth/me`).
  * Handled errors (invalid credentials, network error) display structured alert notifications.
  * Logout clears storage and returns user to `/login`.
* **Explicit Exclusions**:
  * Business modules (POS, Products, Customers, Sales, Accounting, Reports).

### Phase 2: Master Data & Parties Module
* **Scope**: Customers, Suppliers, Transporters, Categories, Subcategories, Products, Opening Stock.

### Phase 3: POS Billing & Sales Module
* **Scope**: POS Cashier Interface, Cart State Management, Checkout Modal, Sales Invoices, Payment-In, Sale Return (Credit Notes).

### Phase 4: Purchasing & Inventory Management Module
* **Scope**: Purchase Bills, Payment-Out, Stock Manager, Stock Adjustments, Purchase Return (Debit Notes).

### Phase 5: Cash, Bank, Expenses & Shift Management Module
* **Scope**: Bank Accounts, Cash Ledger, Cheques, Loans, Expense Logging, Income Logging, Cashier Shifts.

### Phase 6: Accounting Engine & Tax Reports Module
* **Scope**: Chart of Accounts, Ledgers, Vouchers, Journal Creation, Day Book, Trial Balance, Balance Sheet, GST Reports (GSTR-1, GSTR-3B).

### Phase 7: Utilities, Activity Logs, Backup & Settings Module
* **Scope**: Barcode Generator, Import/Export, Audit Activity Logs, Data Backup & Restore, Business Profile Settings.

---

## 8. Web-to-Flutter Navigation & Module Mapping

| Next.js Route / Page | Flutter Route | Proposed Flutter Module | Main Controller | Required Repository / Service | Responsive Layout | Status |
|---|---|---|---|---|---|---|
| `/login` | `/login` | `authentication` | `AuthController` | `AuthRepository`, `AuthService` | Single Card Center Layout | **Planned (Phase 1)** |
| `/register` | `/register` | `authentication` | `AuthController` | `AuthRepository`, `AuthService` | Single Card Center Layout | **Planned (Phase 1)** |
| `/forgot-password` | `/forgot-password` | `authentication` | `AuthController` | `AuthRepository`, `AuthService` | Single Card Center Layout | **Planned (Phase 1)** |
| `/dashboard` | `/dashboard` | `dashboard` | `DashboardController` | `DashboardRepository` | Grid Stats + Table View | Pending |
| `/customers` | `/customers` | `parties/customers` | `CustomerController` | `CustomerRepository` | Table + Detail Drawer | Pending |
| `/customers/[id]` | `/customers/:id` | `parties/customers` | `CustomerDetailController` | `CustomerRepository` | Tabbed Profile View | Pending |
| `/suppliers` | `/suppliers` | `parties/suppliers` | `SupplierController` | `SupplierRepository` | Table + Form Modal | Pending |
| `/transporters` | `/transporters` | `parties/transporters` | `TransporterController` | `TransporterRepository` | Compact Table View | Pending |
| `/products` | `/products` | `products` | `ProductController` | `ProductRepository` | Grid / Table + Filter Bar | Pending |
| `/categories` | `/categories` | `products/categories` | `CategoryController` | `CategoryRepository` | List + Create Dialog | Pending |
| `/subcategories` | `/subcategories` | `products/subcategories` | `SubcategoryController` | `SubcategoryRepository` | List + Parent Dropdown | Pending |
| `/inventory/opening-stock` | `/inventory/opening-stock` | `products/opening_stock` | `OpeningStockController` | `StockRepository` | Data Entry Table | Pending |
| `/inventory` | `/inventory` | `products/inventory` | `InventoryController` | `StockRepository` | Stock Adjustment Table | Pending |
| `/pos` | `/pos` | `pos` | `PosController` | `PosRepository`, `CartService` | 60/40 Split Grid / Cart | Pending |
| `/sales` | `/sales` | `sales` | `SalesController` | `SalesRepository` | Filtered Invoice Table | Pending |
| `/sales/payment-in` | `/sales/payment-in` | `sales/payment_in` | `PaymentInController` | `PaymentInRepository` | Voucher Form + History | Pending |
| `/sales/return` | `/sales/return` | `sales/return` | `SaleReturnController` | `SaleReturnRepository` | Credit Note Table / Form | Pending |
| `/purchases` | `/purchases` | `purchases` | `PurchaseController` | `PurchaseRepository` | Purchase Bill Table | Pending |
| `/purchases/payment-out` | `/purchases/payment-out` | `purchases/payment_out` | `PaymentOutController` | `PaymentOutRepository` | Voucher Form + History | Pending |
| `/purchases/return` | `/purchases/return` | `purchases/return` | `PurchaseReturnController` | `PurchaseReturnRepository` | Debit Note Table / Form | Pending |
| `/cash-bank/transaction-history` | `/cash-bank/history` | `cash_bank` | `CashBankController` | `CashBankRepository` | Transaction Table | **Completed (Phase 5)** |
| `/bank` | `/bank` | `cash_bank` | `CashBankController` | `CashBankRepository` | Account Cards + List | **Completed (Phase 5)** |
| `/cash` | `/cash` | `cash_bank` | `CashBankController` | `CashBankRepository` | Cash Ledger Table | **Completed (Phase 5)** |
| `/cheques` | `/cheques` | `cash_bank` | `CashBankController` | `CashBankRepository` | Status Filtered Table | Pending |
| `/loans` | `/loans` | `cash_bank` | `CashBankController` | `CashBankRepository` | Loan Account Cards | Pending |
| `/expenses` | `/expenses` | `expenses` | `ExpenseController` | `ExpenseRepository` | Category Filtered Table | **Completed (Phase 5)** |
| `/expenses/income` | `/expenses/income` | `expenses` | `ExpenseController` | `ExpenseRepository` | Income Entry Table | **Completed (Phase 5)** |
| `/accounting` | `/accounting` | `accounting` | `AccountingDashboardController` | `AccountingRepository` | Financial Overview Grid | Pending |
| `/accounting/chart-of-accounts` | `/accounting/coa` | `accounting/coa` | `COAController` | `COARepository` | Tree View / Accordion | **Completed (Phase 6)** |
| `/accounting/ledgers` | `/accounting/ledgers` | `accounting/ledgers` | `LedgerListController` | `LedgerRepository` | Searchable Ledger Table | **Completed (Phase 6)** |
| `/accounting/vouchers` | `/accounting/vouchers` | `accounting/vouchers` | `VoucherListController` | `VoucherRepository` | Voucher History Table | **Completed (Phase 6)** |
| `/accounting/journal/create` | `/accounting/journal/create` | `accounting/vouchers` | `JournalFormController` | `VoucherRepository` | Double-Entry Grid Form | **Completed (Phase 6)** |
| `/accounting/day-book` | `/accounting/day-book` | `accounting/reports` | `DayBookController` | `AccountingReportRepository` | Chronological Journal Table | **Completed (Phase 6)** |
| `/accounting/trial-balance` | `/accounting/trial-balance` | `accounting/reports` | `FinancialReportsController` | `AccountingReportRepository` | Debit/Credit Summary Table | **Completed (Phase 6)** |
| `/accounting/gst` | `/accounting/gst` | `accounting/reports` | `FinancialReportsController` | `AccountingReportRepository` | Tax Summary Dashboard | **Completed (Phase 6)** |
| `/reports` | `/reports` | `reports` | `ReportsController` | `ReportsRepository` | Report Selection & Charts | Pending |
| `/shifts` | `/shifts` | `shifts` | `ShiftController` | `ShiftRepository` | Shift Status + Register | **Completed (Phase 5)** |
| `/activity` | `/activity` | `activity` | `ActivityController` | `ActivityRepository` | System Audit Table | Pending |
| `/backup` | `/backup` | `backup` | `BackupController` | `BackupRepository` | Backup Action Cards | Pending |
| `/utilities/barcode` | `/utilities/barcode` | `utilities/barcode` | `BarcodeController` | `ProductRepository` | Label Print Preview Grid | Pending |
| `/utilities/import-export` | `/utilities/import-export` | `utilities/import_export` | `ImportExportController` | `UtilityRepository` | File Upload / Export View | Pending |
| `/settings` | `/settings` | `settings` | `SettingsController` | `SettingsRepository` | Form Sections / Tabs | Pending |

---