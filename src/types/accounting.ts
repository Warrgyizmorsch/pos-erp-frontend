export type VoucherStatus = "DRAFT" | "POSTED" | "CANCELLED" | "REVERSED";
export type BalanceType = "DEBIT" | "CREDIT";
export type AccountNature = "ASSET" | "LIABILITY" | "INCOME" | "EXPENSE";

export interface IdNameCode {
  _id: string;
  name: string;
  code: string;
}

export interface FinancialYear {
  _id: string;
  name: string;
  startDate: string;
  endDate: string;
  isActive: boolean;
  isClosed: boolean;
}

export interface AccountGroup {
  _id: string;
  name: string;
  code: string;
  nature: AccountNature;
  normalBalance: BalanceType;
  parentGroupId?: string | IdNameCode;
  affectsGrossProfit: boolean;
  isSystemDefault: boolean;
  isActive: boolean;
}

export interface Ledger {
  _id: string;
  name: string;
  code: string;
  groupId?: (IdNameCode & {
    nature?: AccountNature;
    normalBalance?: BalanceType;
  }) | null;
  ledgerType: string;
  openingBalance: number;
  openingBalanceType: BalanceType;
  currentBalance: number;
  currentBalanceType: BalanceType;
  isSystemDefault: boolean;
  isActive: boolean;
}

export interface ChartLedger {
  ledgerId: string;
  ledgerName: string;
  name: string;
  code: string;
  ledgerType: string;
  openingBalance: number;
  openingBalanceType: BalanceType;
  currentBalance: number;
  currentBalanceType: BalanceType;
  isSystemDefault: boolean;
  isActive: boolean;
}

export interface ChartGroup {
  groupId: string;
  groupName: string;
  name: string;
  code: string;
  nature: AccountNature;
  normalBalance: BalanceType;
  affectsGrossProfit: boolean;
  isSystemDefault: boolean;
  isActive: boolean;
  childGroups: ChartGroup[];
  ledgers: ChartLedger[];
}

export interface VoucherType {
  _id: string;
  name: string;
  code: string;
  prefix?: string;
  isActive: boolean;
}

export interface Voucher {
  _id: string;
  voucherNo: string;
  voucherTypeId?: IdNameCode;
  voucherTypeCode: string;
  date: string;
  referenceModule?: string;
  referenceNo?: string;
  narration?: string;
  totalDebit: number;
  totalCredit: number;
  status: VoucherStatus;
  createdBy?: string | IdNameCode;
  postedAt?: string;
  cancelledAt?: string;
  cancellationReason?: string;
  reversalReason?: string;
  originalVoucherId?: string | Pick<Voucher, "_id" | "voucherNo" | "status">;
  reversalVoucherId?: string | Pick<Voucher, "_id" | "voucherNo" | "status">;
  createdAt: string;
}

export interface VoucherEntry {
  _id: string;
  ledgerId?: (IdNameCode & {
    ledgerType?: string;
    groupId?: IdNameCode & {
      nature?: AccountNature;
      normalBalance?: BalanceType;
    };
  }) | null;
  ledgerName: string;
  debit: number;
  credit: number;
  narration?: string;
}

export interface VoucherDetail {
  voucher: Voucher;
  entries: VoucherEntry[];
}

export interface AccountingDashboard {
  status: {
    accountingEnabled: boolean;
    gstAccountingEnabled: boolean;
    inventoryAccountingEnabled: boolean;
    autoVoucherPosting: boolean;
    initialized?: boolean;
    missingDefaultGroupsCount?: number;
    missingDefaultLedgersCount?: number;
    missingDefaultVoucherTypesCount?: number;
    activeFinancialYear?: FinancialYear | null;
  };
  counts: {
    accountGroups: number;
    ledgers: number;
    voucherTypes: number;
    postedVouchers: number;
    draftVouchers: number;
    cancelledVouchers: number;
    reversedVouchers?: number;
  };
  recentVouchers: Voucher[];
}

export interface AccountingSettings {
  _id?: string;
  accountingEnabled: boolean;
  gstAccountingEnabled: boolean;
  inventoryAccountingEnabled: boolean;
  autoVoucherPosting: boolean;
  allowManualJournalEntry: boolean;
  allowBackdatedVouchers: boolean;
  lockBooksTillDate?: string;
  defaultCashLedgerId?: IdNameCode;
  defaultBankLedgerId?: IdNameCode;
  defaultSalesLedgerId?: IdNameCode;
  defaultPurchaseLedgerId?: IdNameCode;
  defaultSalesReturnLedgerId?: IdNameCode;
  defaultPurchaseReturnLedgerId?: IdNameCode;
  defaultRoundOffLedgerId?: IdNameCode;
  defaultDiscountGivenLedgerId?: IdNameCode;
  defaultDiscountReceivedLedgerId?: IdNameCode;
  defaultStockLedgerId?: IdNameCode;
  defaultCOGSLedgerId?: IdNameCode;
}

export interface AccountingSettingsValidation {
  valid: boolean;
  missingLedgers: Array<{
    field: string;
    label: string;
    reason: string;
  }>;
  warnings: string[];
}

export interface AccountingStatus {
  accountingEnabled: boolean;
  initialized?: boolean;
  groupsCount: number;
  ledgersCount: number;
  voucherTypesCount: number;
  missingDefaultGroupsCount?: number;
  missingDefaultLedgersCount?: number;
  missingDefaultVoucherTypesCount?: number;
  activeFinancialYear?: FinancialYear | null;
  settingsConfigured: boolean;
  foundationReady: boolean;
  gstAccountingEnabled: boolean;
  inventoryAccountingEnabled: boolean;
  autoVoucherPosting: boolean;
  settings?: AccountingSettings;
}

export interface AccountingSummary {
  created: number;
  updated: number;
  unchanged: number;
  records: Array<{
    action: "created" | "updated" | "unchanged";
    id: string;
    name: string;
    code: string;
  }>;
}

export interface AccountingInitializeResponse {
  success: boolean;
  message: string;
  data: {
    groupsCreated: AccountingSummary;
    ledgersCreated: AccountingSummary;
    voucherTypesCreated: AccountingSummary;
    financialYear?: FinancialYear;
    settings?: unknown;
  };
}

export interface JournalEntryPayload {
  ledgerId: string;
  debit: number;
  credit: number;
  narration?: string;
}

export interface JournalPayload {
  date?: string;
  narration?: string;
  entries: JournalEntryPayload[];
}

export interface LedgerStatementEntry {
  entryId?: string;
  date: string;
  voucherId: string;
  voucherNo: string;
  voucherTypeCode: string;
  voucherTypeName: string;
  referenceNo?: string;
  narration?: string;
  debit: number;
  credit: number;
  runningBalance: number;
  runningBalanceType: BalanceType;
}

export interface LedgerStatement {
  ledger: {
    id: string;
    name: string;
    code: string;
    group?: IdNameCode & {
      nature?: AccountNature;
      normalBalance?: BalanceType;
    };
    nature?: AccountNature;
    openingBalance: number;
    openingBalanceType: BalanceType;
    currentBalance: number;
    currentBalanceType: BalanceType;
  };
  entries: LedgerStatementEntry[];
  totals: {
    totalDebit: number;
    totalCredit: number;
    closingBalance: number;
    closingBalanceType: BalanceType;
  };
}

export interface AccountingHealthIssue {
  id: string;
  type: string;
  severity: "critical" | "warning" | "info" | string;
  module: string;
  referenceId?: string;
  referenceNo?: string;
  voucherId?: string;
  message: string;
  suggestedFix?: string;
  suggestedApi?: string;
  details?: Record<string, unknown>;
}

export interface AccountingHealthCheck {
  status: "healthy" | "warning" | "critical" | string;
  checkedAt: string;
  summary: {
    totalIssues: number;
    criticalIssues: number;
    warningIssues: number;
    infoIssues: number;
    missingPostings: number;
    ledgerMismatches: number;
    duplicateVouchers: number;
  };
  issues: AccountingHealthIssue[];
}

export interface LedgerReconciliation {
  checkedAt: string;
  fixed?: boolean;
  count: number;
  mismatches: Array<{
    ledgerId: string;
    ledgerName: string;
    code: string;
    groupName?: string;
    storedBalance: number;
    storedBalanceType: BalanceType;
    expectedBalance: number;
    expectedBalanceType: BalanceType;
    difference: number;
    status: string;
  }>;
}

export interface CashBankReconciliation {
  checkedAt: string;
  accounts: CashBankReconciliationAccount[];
}

export interface CashBankReconciliationAccount {
    accountId: string;
    accountName: string;
    accountType: string;
    currentBalance: number;
    cashBankBalance?: number;
    openingBalance: number;
    transactionNet: number;
    ledgerBalance: number | null;
    ledgerBalanceType?: BalanceType | null;
    transactionBalance: number;
    difference: number;
    transactionDifference: number | null;
    openingBalanceDifference: number | null;
    status: string;
    suggestedFix: string;
    mappedLedger: {
      ledgerId: string;
      name: string;
      code: string;
      ledgerType: string;
      openingBalance: number;
      openingBalanceType: BalanceType;
    } | null;
}

export interface PartyReconciliation {
  checkedAt: string;
  customers: PartyReconciliationRow[];
  suppliers: PartyReconciliationRow[];
}

export interface PartyReconciliationRow {
  partyId: string;
  partyType: string;
  partyName: string;
  businessBalance: number;
  partyLedgerBalance: number | null;
  accountingBalance: number | null;
  difference: number;
  status: string;
  suggestedFix: string;
}

export interface GSTReconciliation {
  checkedAt: string;
  rows: Array<{
    ledgerCode: string;
    expected: number;
    actual: number | null;
    difference: number;
    status: string;
  }>;
  mismatches: Array<{
    ledgerCode: string;
    expected: number;
    actual: number | null;
    difference: number;
    status: string;
  }>;
  outputGST?: Record<string, number>;
  inputGST?: Record<string, number>;
}

export interface AccountingAuditLog {
  _id: string;
  createdAt: string;
  user?: IdNameCode & { role?: string; email?: string };
  userName: string;
  action: string;
  module: string;
  referenceId?: string;
  referenceNo?: string;
  description: string;
  oldData?: Record<string, unknown>;
  newData?: Record<string, unknown>;
  details?: Record<string, unknown>;
  ipAddress?: string;
  userAgent?: string;
}

export interface DayBookEntry {
  date: string;
  voucherId: string;
  voucherNo: string;
  voucherTypeName: string;
  voucherTypeCode: string;
  ledgerId?: string;
  ledgerName: string;
  referenceNo?: string;
  narration?: string;
  debit: number;
  credit: number;
  status: VoucherStatus;
}

export interface DayBook {
  entries: DayBookEntry[];
  totals: {
    totalDebit: number;
    totalCredit: number;
  };
}

export interface TrialBalanceRow {
  ledgerId: string;
  ledgerName: string;
  code: string;
  groupName?: string;
  debitBalance: number;
  creditBalance: number;
}

export interface BasicTrialBalance {
  rows: TrialBalanceRow[];
  totalDebit: number;
  totalCredit: number;
  difference: number;
  isBalanced: boolean;
}

export interface ReportPeriod {
  startDate?: string | null;
  endDate?: string | null;
  financialYear?: FinancialYear | null;
}

export interface TrialBalanceReportRow {
  ledgerId: string;
  ledgerName: string;
  code: string;
  groupName?: string;
  nature?: AccountNature;
  openingDebit: number;
  openingCredit: number;
  periodDebit: number;
  periodCredit: number;
  closingDebit: number;
  closingCredit: number;
}

export interface TrialBalanceReport {
  reportName: string;
  period: ReportPeriod;
  rows: TrialBalanceReportRow[];
  totals: {
    openingDebit: number;
    openingCredit: number;
    periodDebit: number;
    periodCredit: number;
    closingDebit: number;
    closingCredit: number;
    difference: number;
  };
  isBalanced: boolean;
}

export interface ReportLedgerAmount {
  ledgerId?: string;
  ledgerName: string;
  code?: string;
  amount: number;
  balanceType?: BalanceType;
}

export interface ReportGroupAmount {
  groupId?: string;
  groupName: string;
  ledgers: ReportLedgerAmount[];
  total: number;
}

export interface ProfitLossReport {
  reportName: string;
  period: ReportPeriod;
  income: ReportGroupAmount[];
  expenses: ReportGroupAmount[];
  totals: {
    totalIncome: number;
    totalExpenses: number;
    grossProfit: number;
    netProfit: number;
    netLoss: number;
  };
}

export interface BalanceSheetReport {
  reportName: string;
  asOnDate: string;
  assets: ReportGroupAmount[];
  liabilities: ReportGroupAmount[];
  totals: {
    totalAssets: number;
    totalLiabilities: number;
    difference: number;
  };
  isBalanced: boolean;
}

export interface BookEntry {
  date: string;
  voucherId: string;
  voucherTypeCode: string;
  voucherNo: string;
  ledgerId: string;
  ledgerName: string;
  particulars: string;
  referenceNo?: string;
  debit: number;
  credit: number;
  receipt?: number;
  payment?: number;
  deposit?: number;
  withdrawal?: number;
  balance: number;
  balanceType: BalanceType;
}

export interface BookReport {
  reportName: string;
  period: ReportPeriod;
  ledgers: Array<{ ledgerId: string; ledgerName: string; code: string }>;
  openingBalance: number;
  openingBalanceType: BalanceType;
  entries: BookEntry[];
  totals: {
    totalReceipts?: number;
    totalPayments?: number;
    totalDeposits?: number;
    totalWithdrawals?: number;
    closingBalance: number;
    closingBalanceType: BalanceType;
  };
}

export interface PartyOutstandingRow {
  ledgerId: string;
  ledgerName: string;
  openingBalance: number;
  openingBalanceType: BalanceType;
  debit: number;
  credit: number;
  closingBalance: number;
  balanceType: BalanceType;
  receivable?: number;
  payable?: number;
  advance: number;
}

export interface PartyOutstandingReport {
  reportName: string;
  asOnDate: string;
  rows: PartyOutstandingRow[];
  totals: {
    totalReceivable?: number;
    totalPayable?: number;
    totalAdvance: number;
  };
}

export interface LedgerSummaryReport {
  reportName: string;
  period: ReportPeriod;
  rows: Array<TrialBalanceReportRow & {
    openingBalance: number;
    openingBalanceType: BalanceType;
    closingBalance: number;
    closingBalanceType: BalanceType;
    ledgerType: string;
  }>;
}

export interface GroupSummaryReport {
  reportName: string;
  period: ReportPeriod;
  rows: Array<{
    groupId?: string;
    groupName: string;
    groupCode?: string;
    nature?: AccountNature;
    openingDebit: number;
    openingCredit: number;
    periodDebit: number;
    periodCredit: number;
    closingDebit: number;
    closingCredit: number;
    closingBalance: number;
  }>;
}

export interface AccountingReportDashboard {
  reportName: string;
  period: ReportPeriod;
  totalIncome: number;
  totalExpenses: number;
  netProfit: number;
  netLoss: number;
  cashBalance: number;
  bankBalance: number;
  receivables: number;
  payables: number;
  totalAssets: number;
  totalLiabilities: number;
  trialBalanceDifference: number;
  recentVouchers: Voucher[];
}

export interface TestVoucherPayload {
  date?: string;
  narration?: string;
  entries: Array<{
    ledgerCode: string;
    debit: number;
    credit: number;
  }>;
}
