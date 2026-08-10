import 'package:get/get.dart';
import '../../core/middleware/role_middleware.dart';
import '../../core/permissions/permission_service.dart';
import '../../core/widgets/more_modules_view.dart';
import '../../modules/accounting/audit_logs/bindings/accounting_audit_log_binding.dart';
import '../../modules/accounting/audit_logs/views/accounting_audit_log_view.dart';
import '../../modules/accounting/bank_import/bindings/bank_import_binding.dart';
import '../../modules/accounting/bank_import/views/bank_import_settings_view.dart';
import '../../modules/accounting/bank_import/views/bank_mapping_rules_view.dart';
import '../../modules/accounting/bank_import/views/bank_statement_import_view.dart';
import '../../modules/accounting/coa/bindings/coa_binding.dart';
import '../../modules/accounting/coa/views/chart_of_accounts_view.dart';
import '../../modules/accounting/dashboard/bindings/accounting_dashboard_binding.dart';
import '../../modules/accounting/dashboard/views/accounting_dashboard_view.dart';
import '../../modules/accounting/health/bindings/accounting_health_binding.dart';
import '../../modules/accounting/health/views/accounting_health_view.dart';
import '../../modules/accounting/ledgers/bindings/ledger_binding.dart';
import '../../modules/accounting/ledgers/views/ledger_list_view.dart';
import '../../modules/accounting/ledgers/views/ledger_statement_view.dart';
import '../../modules/accounting/reconciliation/bindings/accounting_reconciliation_binding.dart';
import '../../modules/accounting/reconciliation/views/accounting_reconciliation_view.dart';
import '../../modules/accounting/reports/bindings/accounting_report_binding.dart';
import '../../modules/accounting/reports/views/day_book_view.dart';
import '../../modules/accounting/reports/views/financial_reports_view.dart';
import '../../modules/accounting/reports/views/trial_balance_view.dart';
import '../../modules/accounting/settings/bindings/accounting_settings_binding.dart';
import '../../modules/accounting/settings/views/accounting_settings_view.dart';
import '../../modules/accounting/vouchers/bindings/voucher_binding.dart';
import '../../modules/accounting/vouchers/views/journal_form_view.dart';
import '../../modules/accounting/vouchers/views/voucher_list_view.dart';
import '../../modules/activity/bindings/activity_log_binding.dart';
import '../../modules/activity/views/activity_log_view.dart';
import '../../modules/authentication/bindings/auth_binding.dart';
import '../../modules/authentication/views/forgot_password_view.dart';
import '../../modules/authentication/views/login_view.dart';
import '../../modules/authentication/views/register_view.dart';
import '../../modules/backup/bindings/backup_binding.dart';
import '../../modules/backup/views/backup_view.dart';
import '../../modules/cash_bank/bindings/cash_bank_binding.dart';
import '../../modules/cash_bank/views/bank_view.dart';
import '../../modules/cash_bank/views/cash_bank_list_view.dart';
import '../../modules/cash_bank/views/cash_view.dart';
import '../../modules/cheques/bindings/cheque_binding.dart';
import '../../modules/cheques/views/cheque_list_view.dart';
import '../../modules/dashboard/bindings/dashboard_binding.dart';
import '../../modules/dashboard/views/dashboard_view.dart';
import '../../modules/expenses/bindings/expense_binding.dart';
import '../../modules/expenses/views/expense_list_view.dart';
import '../../modules/expenses/views/income_view.dart';
import '../../modules/loans/bindings/loan_binding.dart';
import '../../modules/loans/views/loan_list_view.dart';
import '../../modules/notifications/bindings/notification_binding.dart';
import '../../modules/notifications/views/notification_view.dart';
import '../../modules/parties/customers/bindings/customer_binding.dart';
import '../../modules/parties/customers/views/customer_list_view.dart';
import '../../modules/parties/suppliers/bindings/supplier_binding.dart';
import '../../modules/parties/suppliers/views/supplier_list_view.dart';
import '../../modules/parties/transporters/bindings/transporter_binding.dart';
import '../../modules/parties/transporters/views/transporter_list_view.dart';
import '../../modules/pos/bindings/pos_binding.dart';
import '../../modules/pos/bindings/pos_checkout_binding.dart';
import '../../modules/pos/views/pos_checkout_view.dart';
import '../../modules/pos/views/pos_view.dart';
import '../../modules/products/bindings/product_binding.dart';
import '../../modules/products/categories/bindings/category_binding.dart';
import '../../modules/products/categories/views/category_list_view.dart';
import '../../modules/products/inventory/bindings/stock_binding.dart';
import '../../modules/products/inventory/views/inventory_view.dart';
import '../../modules/products/opening_stock/bindings/opening_stock_binding.dart';
import '../../modules/products/opening_stock/views/opening_stock_view.dart';
import '../../modules/products/subcategories/bindings/subcategory_binding.dart';
import '../../modules/products/subcategories/views/subcategory_list_view.dart';
import '../../modules/products/views/product_list_view.dart';
import '../../modules/purchases/bindings/purchase_binding.dart';
import '../../modules/purchases/payment_out/bindings/payment_out_binding.dart';
import '../../modules/purchases/payment_out/views/payment_out_list_view.dart';
import '../../modules/purchases/return/bindings/purchase_return_binding.dart';
import '../../modules/purchases/return/views/purchase_return_list_view.dart';
import '../../modules/purchases/views/purchase_detail_view.dart';
import '../../modules/purchases/views/purchase_form_view.dart';
import '../../modules/purchases/views/purchase_list_view.dart';
import '../../modules/reports/bindings/reports_binding.dart';
import '../../modules/reports/views/reports_view.dart';
import '../../modules/sales/bindings/sale_binding.dart';
import '../../modules/sales/payment_in/bindings/payment_in_binding.dart';
import '../../modules/sales/payment_in/views/payment_in_list_view.dart';
import '../../modules/sales/return/bindings/sale_return_binding.dart';
import '../../modules/sales/return/views/sale_return_form_view.dart';
import '../../modules/sales/return/views/sale_return_list_view.dart';
import '../../modules/sales/views/sale_list_view.dart';
import '../../modules/settings/bindings/settings_binding.dart';
import '../../modules/settings/views/settings_view.dart';
import '../../modules/shifts/bindings/shift_binding.dart';
import '../../modules/shifts/views/shift_management_view.dart';
import '../../modules/utilities/barcode/bindings/barcode_binding.dart';
import '../../modules/utilities/barcode/views/barcode_view.dart';
import '../../modules/utilities/import_export/bindings/import_export_binding.dart';
import '../../modules/utilities/import_export/views/import_export_view.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    // Authentication (Public)
    GetPage(
      name: Routes.login,
      page: () => LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.register,
      page: () => RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.forgotPassword,
      page: () => ForgotPasswordView(),
      binding: AuthBinding(),
    ),

    // Mobile Executive Dashboard (All Authenticated Roles)
    GetPage(
      name: Routes.dashboard,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
      middlewares: [RoleMiddleware(PermissionService.allRoles)],
    ),
    GetPage(
      name: Routes.more,
      page: () => const MoreModulesView(),
      middlewares: [RoleMiddleware(PermissionService.allRoles)],
    ),

    // Inventory Master (Admin, Manager, Stock Manager)
    GetPage(
      name: Routes.categories,
      page: () => const CategoryListView(),
      binding: CategoryBinding(),
      middlewares: [RoleMiddleware(PermissionService.inventoryRoles)],
    ),
    GetPage(
      name: Routes.subcategories,
      page: () => const SubcategoryListView(),
      binding: SubcategoryBinding(),
      middlewares: [RoleMiddleware(PermissionService.inventoryRoles)],
    ),
    GetPage(
      name: Routes.products,
      page: () => const ProductListView(),
      binding: ProductBinding(),
      middlewares: [RoleMiddleware(PermissionService.inventoryRoles)],
    ),
    GetPage(
      name: Routes.openingStock,
      page: () => const OpeningStockView(),
      binding: OpeningStockBinding(),
      middlewares: [RoleMiddleware(PermissionService.inventoryRoles)],
    ),
    GetPage(
      name: Routes.inventory,
      page: () => const InventoryView(),
      binding: StockBinding(),
      middlewares: [RoleMiddleware(PermissionService.inventoryRoles)],
    ),

    // Parties Master (Admin, Manager, Cashier)
    GetPage(
      name: Routes.customers,
      page: () => const CustomerListView(),
      binding: CustomerBinding(),
      middlewares: [RoleMiddleware(PermissionService.partiesRoles)],
    ),
    GetPage(
      name: Routes.suppliers,
      page: () => const SupplierListView(),
      binding: SupplierBinding(),
      middlewares: [RoleMiddleware(PermissionService.partiesRoles)],
    ),
    GetPage(
      name: Routes.transporters,
      page: () => const TransporterListView(),
      binding: TransporterBinding(),
      middlewares: [RoleMiddleware(PermissionService.partiesRoles)],
    ),

    // Sales & POS Billing (Admin, Manager, Cashier)
    GetPage(
      name: Routes.pos,
      page: () => const POSView(),
      binding: POSBinding(),
      middlewares: [RoleMiddleware(PermissionService.salesRoles)],
    ),
    GetPage(
      name: Routes.checkout,
      page: () => const POSCheckoutView(),
      binding: POSCheckoutBinding(),
      middlewares: [RoleMiddleware(PermissionService.salesRoles)],
    ),
    GetPage(
      name: Routes.sales,
      page: () => const SaleListView(),
      binding: SaleBinding(),
      middlewares: [RoleMiddleware(PermissionService.salesRoles)],
    ),
    GetPage(
      name: Routes.paymentIn,
      page: () => const PaymentInListView(),
      binding: PaymentInBinding(),
      middlewares: [RoleMiddleware(PermissionService.salesRoles)],
    ),
    GetPage(
      name: Routes.saleReturn,
      page: () => const SaleReturnListView(),
      binding: SaleReturnBinding(),
      middlewares: [RoleMiddleware(PermissionService.salesRoles)],
    ),
    GetPage(
      name: Routes.saleReturnCreate,
      page: () => const SaleReturnFormView(),
      binding: SaleReturnBinding(),
      middlewares: [RoleMiddleware(PermissionService.salesRoles)],
    ),

    // Purchase Management (Admin, Manager, Stock Manager)
    GetPage(
      name: Routes.purchases,
      page: () => const PurchaseListView(),
      binding: PurchaseBinding(),
      middlewares: [RoleMiddleware(PermissionService.purchaseRoles)],
    ),
    GetPage(
      name: Routes.purchaseCreate,
      page: () => const PurchaseFormView(),
      binding: PurchaseBinding(),
      middlewares: [RoleMiddleware(PermissionService.purchaseRoles)],
    ),
    GetPage(
      name: Routes.purchaseDetail,
      page: () => const PurchaseDetailView(),
      binding: PurchaseBinding(),
      middlewares: [RoleMiddleware(PermissionService.purchaseRoles)],
    ),
    GetPage(
      name: Routes.purchaseReturn,
      page: () => const PurchaseReturnListView(),
      binding: PurchaseReturnBinding(),
      middlewares: [RoleMiddleware(PermissionService.purchaseRoles)],
    ),
    GetPage(
      name: Routes.paymentOut,
      page: () => const PaymentOutListView(),
      binding: PaymentOutBinding(),
      middlewares: [RoleMiddleware(PermissionService.purchaseRoles)],
    ),

    // Expenses & Income (Admin, Manager, Accountant)
    GetPage(
      name: Routes.expenses,
      page: () => const ExpenseListView(),
      binding: ExpenseBinding(),
      middlewares: [RoleMiddleware(PermissionService.expenseRoles)],
    ),
    GetPage(
      name: Routes.income,
      page: () => const IncomeView(),
      binding: ExpenseBinding(),
      middlewares: [RoleMiddleware(PermissionService.expenseRoles)],
    ),

    // Cash & Bank (Admin, Accountant)
    GetPage(
      name: Routes.cash,
      page: () => const CashView(),
      binding: CashBankBinding(),
      middlewares: [RoleMiddleware(PermissionService.cashBankRoles)],
    ),
    GetPage(
      name: Routes.bank,
      page: () => const BankView(),
      binding: CashBankBinding(),
      middlewares: [RoleMiddleware(PermissionService.cashBankRoles)],
    ),
    GetPage(
      name: Routes.cashBank,
      page: () => const CashBankListView(),
      binding: CashBankBinding(),
      middlewares: [RoleMiddleware(PermissionService.cashBankRoles)],
    ),
    GetPage(
      name: Routes.cheques,
      page: () => const ChequeListView(),
      binding: ChequeBinding(),
      middlewares: [RoleMiddleware(PermissionService.cashBankRoles)],
    ),
    GetPage(
      name: Routes.loans,
      page: () => const LoanListView(),
      binding: LoanBinding(),
      middlewares: [RoleMiddleware(PermissionService.cashBankRoles)],
    ),

    // Cashier Shifts (Admin, Manager, Cashier)
    GetPage(
      name: Routes.shifts,
      page: () => const ShiftManagementView(),
      binding: ShiftBinding(),
      middlewares: [RoleMiddleware(PermissionService.shiftRoles)],
    ),

    // Accounting Engine (Admin, Accountant)
    GetPage(
      name: Routes.accounting,
      page: () => const AccountingDashboardView(),
      binding: AccountingDashboardBinding(),
      middlewares: [RoleMiddleware(PermissionService.accountingRoles)],
    ),
    GetPage(
      name: Routes.chartOfAccounts,
      page: () => const ChartOfAccountsView(),
      binding: COABinding(),
      middlewares: [RoleMiddleware(PermissionService.accountingRoles)],
    ),
    GetPage(
      name: Routes.ledgers,
      page: () => const LedgerListView(),
      binding: LedgerBinding(),
      middlewares: [RoleMiddleware(PermissionService.accountingRoles)],
    ),
    GetPage(
      name: Routes.ledgerStatement,
      page: () => const LedgerStatementView(),
      binding: LedgerBinding(),
      middlewares: [RoleMiddleware(PermissionService.accountingRoles)],
    ),
    GetPage(
      name: Routes.vouchers,
      page: () => const VoucherListView(),
      binding: VoucherBinding(),
      middlewares: [RoleMiddleware(PermissionService.accountingRoles)],
    ),
    GetPage(
      name: Routes.journalCreate,
      page: () => const JournalFormView(),
      binding: VoucherBinding(),
      middlewares: [RoleMiddleware(PermissionService.accountingRoles)],
    ),
    GetPage(
      name: Routes.dayBook,
      page: () => const DayBookView(),
      binding: AccountingReportBinding(),
      middlewares: [RoleMiddleware(PermissionService.accountingRoles)],
    ),
    GetPage(
      name: Routes.trialBalance,
      page: () => const TrialBalanceView(),
      binding: AccountingReportBinding(),
      middlewares: [RoleMiddleware(PermissionService.accountingRoles)],
    ),
    GetPage(
      name: Routes.financialReports,
      page: () => const FinancialReportsView(),
      binding: AccountingReportBinding(),
      middlewares: [RoleMiddleware(PermissionService.accountingRoles)],
    ),
    GetPage(
      name: Routes.gstReports,
      page: () => const FinancialReportsView(),
      binding: AccountingReportBinding(),
      middlewares: [RoleMiddleware(PermissionService.accountingRoles)],
    ),
    GetPage(
      name: Routes.accountingSettings,
      page: () => const AccountingSettingsView(),
      binding: AccountingSettingsBinding(),
      middlewares: [RoleMiddleware(PermissionService.accountingRoles)],
    ),
    GetPage(
      name: Routes.accountingHealth,
      page: () => const AccountingHealthView(),
      binding: AccountingHealthBinding(),
      middlewares: [RoleMiddleware(PermissionService.accountingRoles)],
    ),
    GetPage(
      name: Routes.accountingReconciliation,
      page: () => const AccountingReconciliationView(),
      binding: AccountingReconciliationBinding(),
      middlewares: [RoleMiddleware(PermissionService.accountingRoles)],
    ),
    GetPage(
      name: Routes.accountingAuditLogs,
      page: () => const AccountingAuditLogView(),
      binding: AccountingAuditLogBinding(),
      middlewares: [RoleMiddleware(PermissionService.accountingRoles)],
    ),
    GetPage(
      name: Routes.bankStatementImport,
      page: () => const BankStatementImportView(),
      binding: BankImportBinding(),
      middlewares: [RoleMiddleware(PermissionService.accountingRoles)],
    ),
    GetPage(
      name: Routes.bankMappingRules,
      page: () => const BankMappingRulesView(),
      binding: BankImportBinding(),
      middlewares: [RoleMiddleware(PermissionService.accountingRoles)],
    ),
    GetPage(
      name: Routes.bankImportSettings,
      page: () => const BankImportSettingsView(),
      binding: BankImportBinding(),
      middlewares: [RoleMiddleware(PermissionService.accountingRoles)],
    ),

    // Reports & BI (Admin, Manager, Accountant)
    GetPage(
      name: Routes.reports,
      page: () => const ReportsView(),
      binding: ReportsBinding(),
      middlewares: [RoleMiddleware(PermissionService.reportsRoles)],
    ),

    // Activity Audit Logs (Admin Only)
    GetPage(
      name: Routes.activity,
      page: () => const ActivityLogView(),
      binding: ActivityLogBinding(),
      middlewares: [RoleMiddleware(PermissionService.adminOnlyRoles)],
    ),

    // Sync & Backup (Admin Only)
    GetPage(
      name: Routes.backup,
      page: () => const BackupView(),
      binding: BackupBinding(),
      middlewares: [RoleMiddleware(PermissionService.adminOnlyRoles)],
    ),

    // Utilities (Admin, Manager)
    GetPage(
      name: Routes.barcode,
      page: () => const BarcodeView(),
      binding: BarcodeBinding(),
      middlewares: [RoleMiddleware(PermissionService.utilityRoles)],
    ),
    GetPage(
      name: Routes.importExport,
      page: () => const ImportExportView(),
      binding: ImportExportBinding(),
      middlewares: [RoleMiddleware(PermissionService.utilityRoles)],
    ),

    // System Settings (Admin Only)
    GetPage(
      name: Routes.settings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
      middlewares: [RoleMiddleware(PermissionService.adminOnlyRoles)],
    ),

    // Notifications (All Authenticated Roles)
    GetPage(
      name: Routes.notifications,
      page: () => const NotificationView(),
      binding: NotificationBinding(),
      middlewares: [RoleMiddleware(PermissionService.allRoles)],
    ),
  ];
}
