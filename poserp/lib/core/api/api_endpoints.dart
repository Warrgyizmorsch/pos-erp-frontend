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
  static const String paymentIn = '/payment-in';

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
}
