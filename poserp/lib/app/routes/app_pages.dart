import 'package:get/get.dart';
import '../../modules/accounting/coa/bindings/coa_binding.dart';
import '../../modules/accounting/coa/views/chart_of_accounts_view.dart';
import '../../modules/accounting/dashboard/bindings/accounting_dashboard_binding.dart';
import '../../modules/accounting/dashboard/views/accounting_dashboard_view.dart';
import '../../modules/accounting/ledgers/bindings/ledger_binding.dart';
import '../../modules/accounting/ledgers/views/ledger_list_view.dart';
import '../../modules/accounting/ledgers/views/ledger_statement_view.dart';
import '../../modules/accounting/reports/bindings/accounting_report_binding.dart';
import '../../modules/accounting/reports/views/day_book_view.dart';
import '../../modules/accounting/reports/views/financial_reports_view.dart';
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
import '../../modules/cash_bank/views/cash_bank_list_view.dart';
import '../../modules/cheques/bindings/cheque_binding.dart';
import '../../modules/cheques/views/cheque_list_view.dart';
import '../../modules/dashboard_placeholder/dashboard_placeholder_view.dart';
import '../../modules/expenses/bindings/expense_binding.dart';
import '../../modules/expenses/views/expense_list_view.dart';
import '../../modules/loans/bindings/loan_binding.dart';
import '../../modules/loans/views/loan_list_view.dart';
import '../../modules/parties/customers/bindings/customer_binding.dart';
import '../../modules/parties/customers/views/customer_list_view.dart';
import '../../modules/parties/suppliers/bindings/supplier_binding.dart';
import '../../modules/parties/suppliers/views/supplier_list_view.dart';
import '../../modules/parties/transporters/bindings/transporter_binding.dart';
import '../../modules/parties/transporters/views/transporter_list_view.dart';
import '../../modules/pos/bindings/pos_binding.dart';
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
    GetPage(
      name: Routes.dashboard,
      page: () => const DashboardPlaceholderView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.categories,
      page: () => const CategoryListView(),
      binding: CategoryBinding(),
    ),
    GetPage(
      name: Routes.subcategories,
      page: () => const SubcategoryListView(),
      binding: SubcategoryBinding(),
    ),
    GetPage(
      name: Routes.products,
      page: () => const ProductListView(),
      binding: ProductBinding(),
    ),
    GetPage(
      name: Routes.openingStock,
      page: () => const OpeningStockView(),
      binding: OpeningStockBinding(),
    ),
    GetPage(
      name: Routes.inventory,
      page: () => const InventoryView(),
      binding: StockBinding(),
    ),
    GetPage(
      name: Routes.customers,
      page: () => const CustomerListView(),
      binding: CustomerBinding(),
    ),
    GetPage(
      name: Routes.suppliers,
      page: () => const SupplierListView(),
      binding: SupplierBinding(),
    ),
    GetPage(
      name: Routes.transporters,
      page: () => const TransporterListView(),
      binding: TransporterBinding(),
    ),
    GetPage(
      name: Routes.pos,
      page: () => const POSView(),
      binding: POSBinding(),
    ),
    GetPage(
      name: Routes.sales,
      page: () => const SaleListView(),
      binding: SaleBinding(),
    ),
    GetPage(
      name: Routes.paymentIn,
      page: () => const PaymentInListView(),
      binding: PaymentInBinding(),
    ),
    GetPage(
      name: Routes.saleReturn,
      page: () => const SaleReturnListView(),
      binding: SaleReturnBinding(),
    ),
    GetPage(
      name: Routes.saleReturnCreate,
      page: () => const SaleReturnFormView(),
      binding: SaleReturnBinding(),
    ),
    GetPage(
      name: Routes.purchases,
      page: () => const PurchaseListView(),
      binding: PurchaseBinding(),
    ),
    GetPage(
      name: Routes.purchaseCreate,
      page: () => const PurchaseFormView(),
      binding: PurchaseBinding(),
    ),
    GetPage(
      name: Routes.purchaseDetail,
      page: () => const PurchaseDetailView(),
      binding: PurchaseBinding(),
    ),
    GetPage(
      name: Routes.purchaseReturn,
      page: () => const PurchaseReturnListView(),
      binding: PurchaseReturnBinding(),
    ),
    GetPage(
      name: Routes.paymentOut,
      page: () => const PaymentOutListView(),
      binding: PaymentOutBinding(),
    ),
    GetPage(
      name: Routes.expenses,
      page: () => const ExpenseListView(),
      binding: ExpenseBinding(),
    ),
    GetPage(
      name: Routes.cashBank,
      page: () => const CashBankListView(),
      binding: CashBankBinding(),
    ),
    GetPage(
      name: Routes.cheques,
      page: () => const ChequeListView(),
      binding: ChequeBinding(),
    ),
    GetPage(
      name: Routes.loans,
      page: () => const LoanListView(),
      binding: LoanBinding(),
    ),
    GetPage(
      name: Routes.shifts,
      page: () => const ShiftManagementView(),
      binding: ShiftBinding(),
    ),
    GetPage(
      name: Routes.accounting,
      page: () => const AccountingDashboardView(),
      binding: AccountingDashboardBinding(),
    ),
    GetPage(
      name: Routes.chartOfAccounts,
      page: () => const ChartOfAccountsView(),
      binding: COABinding(),
    ),
    GetPage(
      name: Routes.ledgers,
      page: () => const LedgerListView(),
      binding: LedgerBinding(),
    ),
    GetPage(
      name: Routes.ledgerStatement,
      page: () => const LedgerStatementView(),
      binding: LedgerBinding(),
    ),
    GetPage(
      name: Routes.vouchers,
      page: () => const VoucherListView(),
      binding: VoucherBinding(),
    ),
    GetPage(
      name: Routes.journalCreate,
      page: () => const JournalFormView(),
      binding: VoucherBinding(),
    ),
    GetPage(
      name: Routes.dayBook,
      page: () => const DayBookView(),
      binding: AccountingReportBinding(),
    ),
    GetPage(
      name: Routes.financialReports,
      page: () => const FinancialReportsView(),
      binding: AccountingReportBinding(),
    ),
    GetPage(
      name: Routes.gstReports,
      page: () => const FinancialReportsView(),
      binding: AccountingReportBinding(),
    ),
    GetPage(
      name: Routes.reports,
      page: () => const ReportsView(),
      binding: ReportsBinding(),
    ),
    GetPage(
      name: Routes.activity,
      page: () => const ActivityLogView(),
      binding: ActivityLogBinding(),
    ),
    GetPage(
      name: Routes.backup,
      page: () => const BackupView(),
      binding: BackupBinding(),
    ),
    GetPage(
      name: Routes.barcode,
      page: () => const BarcodeView(),
      binding: BarcodeBinding(),
    ),
    GetPage(
      name: Routes.importExport,
      page: () => const ImportExportView(),
      binding: ImportExportBinding(),
    ),
    GetPage(
      name: Routes.settings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
  ];
}
