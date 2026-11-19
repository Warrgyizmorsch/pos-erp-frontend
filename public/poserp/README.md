# POS ERP — Cross-Platform Enterprise POS & Accounting Application 🛒💼

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![GetX](https://img.shields.io/badge/State_Management-GetX-8A2BE2)](https://pub.dev/packages/get)
[![Dio](https://img.shields.io/badge/HTTP_Client-Dio-0052CC)](https://pub.dev/packages/dio)
[![License](https://img.shields.io/badge/License-Proprietary-green)]()

**POS ERP** is a modern, high-performance, cross-platform Point of Sale (POS) and Enterprise Resource Planning (ERP) application built with **Flutter** and **GetX**. Designed for retail stores, wholesale distributors, and multi-branch businesses, it delivers fast billing, hardware barcode scanning, live camera barcode capture, inventory management, cashier shift reconciliation, and complete financial accounting.

---

## 🎯 Project Goals & Architecture

### Core Objectives
1. **Ultra-Fast Checkout**: Enable cashiers to scan barcodes, apply line-item discounts, and complete sales transactions in seconds.
2. **Multi-Platform Support**: Deploy seamlessly on **Windows Desktop**, **Android POS Terminals & Phones**, **iOS/iPads**, **macOS**, **Linux**, and **Web Browsers** from a single codebase.
3. **Offline & Remote Resiliency**: Local caching and API synchronization for uninterrupted retail billing.
4. **Comprehensive Financial Compliance**: Integrated GST returns (GSTR-1, GSTR-3B), Chart of Accounts (COA), Journal Entries, and Financial Statements.

### Architectural Overview
The codebase follows a **Feature-First / Modular Architecture** leveraging **GetX** for dependency injection, route management, and reactive state management:

```text
poserp/
├── android/                   # Native Android configuration (Permissions, Intents)
├── ios/                       # Native iOS configuration (Info.plist, Camera permissions)
├── lib/
│   ├── main.dart              # Application entry point & GetMaterialApp initialization
│   ├── core/                  # Shared framework infrastructure
│   │   ├── api/               # Dio HTTP client wrapper & API exception handlers
│   │   ├── constants/         # AppColors, AppRadius, AppSizes design tokens
│   │   ├── theme/             # Light & Dark Material Theme definitions
│   │   └── widgets/           # Reusable UI primitives (AppButton, AppCard, AppTextField, AppTopBar)
│   └── modules/               # Feature-First Business Modules
│       ├── accounting/        # COA, Journal Vouchers, Ledgers, P&L, Balance Sheet, GST
│       ├── activity/          # System Activity Audit Logs & Detail Viewer
│       ├── authentication/    # Login, Quick Role Switcher, Auth Tokens
│       ├── cash_bank/          # Cash-in-Hand, Bank Accounts & Statements
│       ├── cheques/           # Cheque Register & Settlement tracking
│       ├── dashboard/         # Role-based Executive Analytics Dashboard
│       ├── expenses/          # Direct/Indirect Expenses & Indirect Income
│       ├── loans/             # Loan Accounts & Borrowing Records
│       ├── parties/           # Customers, Suppliers, and Transporters
│       ├── pos/               # POS Terminal, Multi-Bill Tabs, Barcode Suite, Thermal Print
│       ├── products/          # Catalog, Opening Stock, Stock Adjustments, Categories
│       ├── purchases/         # Purchase Bills, GST State of Supply, Orders
│       ├── reports/           # Sales & Purchase Analytics, Tax Summaries
│       ├── sales/             # Sales Invoices, Payments In, Sales Returns
│       ├── settings/          # Store Profile, Tax Rates, App Preferences
│       ├── shifts/            # Cashier Register Shifts, Opening Float, Reconciliation
│       └── utilities/         # Barcode Label Batch Generator, Unit Conversion, Tax Calc
├── test/                      # Unit & Widget Tests
└── pubspec.yaml               # Project dependencies & assets manifest
```

---

## ⚡ Core Features & Modules

### 1. 🛒 Fast POS Billing & Multi-Bill Order Tabs
- **Multi-Bill Tabs**: Work on multiple active billing tabs concurrently (`Bill #1`, `Bill #2`) without losing cart state.
- **Custom Line Items & Discounts**: Adjust item quantities, unit rates, item discounts (%), tax rates, and inclusive/exclusive GST.
- **Payment Modes**: Supports Cash, Bank/UPI, Card, Cheque, Credit, and Split Multi-Pay settlements.
- **Thermal Receipt Printing**: Instant 80mm thermal receipt preview and print commands.

### 2. 📦 Multi-Option Barcode Scanner Suite
- **USB & Bluetooth Scanner Guns (HID)**: Automatic high-speed character stream listener (`< 50ms` keypress deltas) with `KeyboardListener`. Plug & play on Windows, Mac, and Android.
- **Live Mobile Camera Scanner**: Integrated `mobile_scanner` viewfinder modal (`CameraScannerDialog`) with live video stream, target laser frame, flashlight toggle, and continuous batch scan mode.
- **Handheld POS Terminal Support**: Direct intent/barcode submission support for Sunmi, Zebra, and Honeywell devices.
- **Autocomplete Search Bar**: Instant search by product name, SKU, or barcode with `Enter` submission.

### 3. ⏰ Cashier Shift Management & Cash Reconciliation
- **Opening Float Tracking**: Record cashier name and initial cash float when starting a shift.
- **Drawer Settlement & Variance**: Calculate expected drawer cash vs. actual physical cash, log discrepancy variances, and generate shift closing reports.

### 4. 📊 Financial Accounting & GST Compliance
- **Chart of Accounts (COA)**: Hierarchical account group structures.
- **Journal Entries & Ledgers**: Double-entry bookkeeping with debit/credit validation.
- **Financial Statements**: Real-time Profit & Loss, Balance Sheet, and Trial Balance reports.
- **GST Returns**: Automated GSTR-1 sales summaries, GSTR-3B tax liabilities, and HSN-wise tax breakdowns.

### 5. 👥 Role-Based Access Control (RBAC)
Quick role switching and UI navigation guards for 5 default user personas:
1. **Admin**: Unrestricted access to all modules, settings, and activity logs.
2. **Manager**: Inventory management, purchase approvals, sales, and reporting.
3. **Accountant**: Financial vouchers, COA, bank reconciliation, and tax returns.
4. **Stock Manager**: Opening stock entry, inventory adjustments, and barcode generation.
5. **Cashier**: Focused POS terminal view, shift open/close, and receipt printing.

---

## 🚀 Getting Started for Developers

### Prerequisites
- **Flutter SDK**: `^3.11.0` or higher
- **Dart SDK**: `^3.11.0` or higher
- **IDE**: VS Code (with Flutter extension) or Android Studio
- **Platform Tools**:
  - Windows: Visual Studio C++ Build Tools (for Windows desktop builds)
  - Android: Android SDK (API 34+)
  - iOS/Mac: Xcode 15+ (Mac required)

### Installation & Setup

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/Warrgyizmorsch/pos-erp-frontend.git
   cd pos-erp-frontend/poserp
   ```

2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure Environment Variables**:
   Ensure `.env` or API base URL in `lib/core/api/` points to your backend instance (default: `http://localhost:5000/api/v1`).

4. **Launch the Application**:
   - **Windows Desktop**:
     ```bash
     flutter run -d windows
     ```
   - **Web (Chrome)**:
     ```bash
     flutter run -d chrome
     ```
   - **Android Device / Emulator**:
     ```bash
     flutter run -d android
     ```

---

## 🧪 Testing & Code Quality Standards

### Static Analysis & Code Formatting
To maintain strict codebase health, always run static analysis and formatting before submitting pull requests:

```bash
# Format code according to official Dart guidelines
dart format .

# Run static analysis (0 errors expected)
flutter analyze
```

### Running Unit & Widget Tests
```bash
flutter test
```

---

## 🎨 UI Guidelines & Responsive Design Standards

When creating or modifying views in `poserp`, strictly adhere to these 4 UI guidelines:

1. **Responsive Breakpoints**: Always use `LayoutBuilder` with `constraints.maxWidth < 700` to handle mobile vs. desktop layouts gracefully.
2. **Dropdown Safety**: Always set `isExpanded: true` on `DropdownButtonFormField` instances to prevent horizontal RenderFlex overflows inside flex containers.
3. **Text Truncation**: Wrap header title strings in `Expanded` or `Flexible` with `maxLines: 1` and `overflow: TextOverflow.ellipsis`.
4. **Data Table Scrolling**: Wrap `DataTable` widgets in a `Scrollbar(thumbVisibility: true, trackVisibility: true)` over `SingleChildScrollView(scrollDirection: Axis.horizontal)`.

---

## 📄 License & Attribution

Copyright © 2026 POS ERP Team. All Rights Reserved.
