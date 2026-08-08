class ApiEndpoints {
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String me = '/auth/me';
  static const String profile = '/auth/profile';
  static const String changePassword = '/auth/change-password';

  // Master Data
  static const String categories = '/categories';
  static const String subcategories = '/subcategories';
  static const String products = '/products';
  static const String importProducts = '/products/bulk-import';
  static const String exportProducts = '/products/export';
  static const String customers = '/customers';
  static const String suppliers = '/suppliers';
  static const String transporters = '/transporters';

  // Inventory & Stock
  static const String inventory = '/inventory';
  static const String inventoryHistory = '/inventory/history';
  static const String inventoryOpeningStock = '/inventory/opening-stock';
  static const String stock = '/stock';
  static const String stockAdjustments = '/stock/adjustments';
  static const String stockAlerts = '/stock/alerts';
  static const String stockStats = '/stock/stats';

  // Sales & POS
  static const String sales = '/sales';
  static const String salesReturns = '/sales-returns';
  static const String paymentIn = '/sales/payment-in';

  // Cash & Bank
  static const String bank = '/bank';
  static const String bankTransactions = '/bank/transaction';
  static const String cashBankAccounts = '/cash-bank/accounts';
  static const String cashBankSummary = '/cash-bank/summary';
  static const String cashBankTransactions = '/cash-bank/transactions';
  static const String cashBankCashEntry = '/cash-bank/cash-entry';
  static const String cashBankBankTransfer = '/cash-bank/bank-transfer';

  // Purchases
  static const String purchases = '/purchases';
  static const String purchaseReturns = '/purchase-returns';
  static const String paymentOut = '/payment-out';
  static const String unpaidPurchases = '/purchases/unpaid';

  // Expenses & Income
  static const String expenses = '/expenses';
  static const String expenseCategories = '/expense-categories';
  static const String expenseReportsSummary = '/expenses/reports/summary';
  static const String expenseLedgers = '/expenses/ledgers';

  // Shifts
  static const String shiftsCurrent = '/shifts/current';
  static const String shiftsOpen = '/shifts/open';
  static const String shiftsClose = '/shifts/close';

  // Accounting Engine
  static const String accountingStatus = '/accounting/status';
  static const String accountingInitialize = '/accounting/initialize';
  static const String accountingChartOfAccounts =
      '/accounting/chart-of-accounts';
  static const String accountingDashboard = '/accounting/dashboard';
  static const String accountingLedgers = '/accounting/ledgers';
  static const String accountingVouchers = '/accounting/vouchers';
  static const String accountingVoucherTypes = '/accounting/voucher-types';
  static const String accountingJournalDraft = '/accounting/journal/draft';
  static const String accountingJournalPost = '/accounting/journal/post';
  static const String accountingDayBook = '/accounting/day-book';
  static const String accountingReportTrialBalance =
      '/accounting/reports/trial-balance';
  static const String accountingReportProfitLoss =
      '/accounting/reports/profit-loss';
  static const String accountingReportBalanceSheet =
      '/accounting/reports/balance-sheet';
  static const String accountingGstSummary = '/accounting/gst/summary';

  // Activity Logs, Backup & Utilities
  static const String activityLogs = '/activity-logs';
  static const String backup = '/backup';
  static const String barcode = '/utilities/barcode';
  static const String importExport = '/utilities/import-export';
  static const String settings = '/settings';
}
