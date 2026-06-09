import api from "@/services/api";
import type {
  AccountingAuditLog,
  AccountingDashboard,
  AccountingHealthCheck,
  AccountingInitializeResponse,
  AccountingReportDashboard,
  AccountingSettings,
  AccountingSettingsValidation,
  AccountingStatus,
  BasicTrialBalance,
  BalanceSheetReport,
  BookReport,
  CashBankReconciliation,
  ChartGroup,
  DayBook,
  GSTReconciliation,
  GroupSummaryReport,
  JournalPayload,
  Ledger,
  LedgerReconciliation,
  LedgerSummaryReport,
  LedgerStatement,
  PartyReconciliation,
  PartyOutstandingReport,
  ProfitLossReport,
  TestVoucherPayload,
  TrialBalanceReport,
  Voucher,
  VoucherDetail,
  VoucherType,
} from "@/types/accounting";

export type {
  AccountingAuditLog,
  AccountingDashboard,
  AccountingHealthCheck,
  AccountingHealthIssue,
  AccountingInitializeResponse,
  AccountingReportDashboard,
  AccountingSettings,
  AccountingSettingsValidation,
  AccountingStatus,
  BasicTrialBalance,
  BalanceSheetReport,
  BookReport,
  CashBankReconciliation,
  ChartGroup,
  ChartLedger,
  DayBook,
  DayBookEntry,
  GroupSummaryReport,
  GSTReconciliation,
  JournalPayload,
  Ledger as AccountingLedger,
  Ledger,
  LedgerReconciliation,
  LedgerSummaryReport,
  LedgerStatement,
  LedgerStatementEntry,
  PartyReconciliation,
  PartyOutstandingReport,
  ProfitLossReport,
  TestVoucherPayload,
  TrialBalanceReport,
  Voucher as AccountingVoucherSummary,
  Voucher,
  VoucherDetail as AccountingVoucherDetail,
  VoucherDetail,
  VoucherEntry as AccountingVoucherEntry,
  VoucherEntry,
  VoucherStatus,
  VoucherType,
} from "@/types/accounting";

type FilterValue = string | number | boolean | undefined | null;
type Filters = Record<string, FilterValue>;

interface ApiResponse<T> {
  success: boolean;
  data: T;
  count?: number;
  message?: string;
  pagination?: {
    page: number;
    limit: number;
    total: number;
    pages: number;
  };
}

const withFilters = (url: string, filters?: Filters) => {
  if (!filters) return url;

  const params = new URLSearchParams();
  Object.entries(filters).forEach(([key, value]) => {
    if (value !== undefined && value !== null && value !== "") {
      params.set(key, String(value));
    }
  });

  const query = params.toString();
  return query ? `${url}?${query}` : url;
};

export const accountingService = {
  async getStatus(): Promise<AccountingStatus> {
    const response = await api.get<ApiResponse<AccountingStatus>>("/accounting/status");
    return response.data.data;
  },

  async initialize(): Promise<AccountingInitializeResponse> {
    const response = await api.post<AccountingInitializeResponse>("/accounting/initialize");
    return response.data;
  },

  async restoreDefaultLedgers(): Promise<AccountingInitializeResponse> {
    const response = await api.post<AccountingInitializeResponse>("/accounting/ledgers/restore-defaults");
    return response.data;
  },

  async getAccountingDashboard(): Promise<AccountingDashboard> {
    const response = await api.get<ApiResponse<AccountingDashboard>>("/accounting/dashboard");
    return response.data.data;
  },

  async getChartOfAccounts(): Promise<ChartGroup[]> {
    const response = await api.get<ApiResponse<ChartGroup[]>>("/accounting/chart-of-accounts");
    return response.data.data;
  },

  async getVoucherTypes(): Promise<VoucherType[]> {
    const response = await api.get<ApiResponse<VoucherType[]>>("/accounting/voucher-types");
    return response.data.data;
  },

  async getDefaultLedgers(): Promise<Ledger[]> {
    const response = await api.get<ApiResponse<Ledger[]>>("/accounting/ledgers/defaults");
    return response.data.data;
  },

  async getLedgers(filters?: Filters): Promise<Ledger[]> {
    const response = await api.get<ApiResponse<Ledger[]>>(withFilters("/accounting/ledgers", filters));
    return response.data.data;
  },

  async getLedgerStatement(id: string, filters?: Filters): Promise<LedgerStatement> {
    const response = await api.get<ApiResponse<LedgerStatement>>(
      withFilters(`/accounting/ledgers/${id}/statement`, filters),
    );
    return response.data.data;
  },

  async getVouchers(filters?: Filters): Promise<Voucher[]> {
    const response = await api.get<ApiResponse<Voucher[]>>(withFilters("/accounting/vouchers", filters));
    return response.data.data;
  },

  async getVoucherById(id: string): Promise<VoucherDetail> {
    const response = await api.get<ApiResponse<VoucherDetail>>(`/accounting/vouchers/${id}`);
    return response.data.data;
  },

  async getVoucher(id: string): Promise<VoucherDetail> {
    return this.getVoucherById(id);
  },

  async createJournalDraft(payload: JournalPayload): Promise<VoucherDetail> {
    const response = await api.post<ApiResponse<VoucherDetail>>("/accounting/journal/draft", payload);
    return response.data.data;
  },

  async postJournal(payload: JournalPayload): Promise<VoucherDetail> {
    const response = await api.post<ApiResponse<VoucherDetail>>("/accounting/journal/post", payload);
    return response.data.data;
  },

  async postDraftVoucher(id: string): Promise<VoucherDetail> {
    const response = await api.post<ApiResponse<VoucherDetail>>(`/accounting/vouchers/${id}/post`);
    return response.data.data;
  },

  async postVoucher(id: string): Promise<VoucherDetail> {
    return this.postDraftVoucher(id);
  },

  async cancelVoucher(id: string, reason: string): Promise<VoucherDetail> {
    const response = await api.post<ApiResponse<VoucherDetail>>(`/accounting/vouchers/${id}/cancel`, { reason });
    return response.data.data;
  },

  async reverseVoucher(id: string, reason: string): Promise<VoucherDetail> {
    const response = await api.post<ApiResponse<VoucherDetail>>(`/accounting/vouchers/${id}/reverse`, { reason });
    return response.data.data;
  },

  async createTestVoucher(payload: TestVoucherPayload): Promise<VoucherDetail> {
    const response = await api.post<ApiResponse<VoucherDetail>>("/accounting/test-voucher", payload);
    return response.data.data;
  },

  async repostSaleAccounting(saleId: string) {
    const response = await api.post<ApiResponse<unknown>>(`/accounting/repost/sale/${saleId}`);
    return response.data;
  },

  async repostPurchaseAccounting(purchaseId: string) {
    const response = await api.post<ApiResponse<unknown>>(`/accounting/repost/purchase/${purchaseId}`);
    return response.data;
  },

  async repostSaleReturnAccounting(returnId: string) {
    const response = await api.post<ApiResponse<unknown>>(`/accounting/repost/sale-return/${returnId}`);
    return response.data;
  },

  async repostPurchaseReturnAccounting(returnId: string) {
    const response = await api.post<ApiResponse<unknown>>(`/accounting/repost/purchase-return/${returnId}`);
    return response.data;
  },

  async repostExpenseAccounting(expenseId: string) {
    const response = await api.post<ApiResponse<unknown>>(`/accounting/repost/expense/${expenseId}`);
    return response.data;
  },

  async repostCashBankTransactionAccounting(transactionId: string) {
    const response = await api.post<ApiResponse<unknown>>(`/accounting/repost/cash-bank-transaction/${transactionId}`);
    return response.data;
  },

  async repostBankTransferAccounting(transferId: string) {
    const response = await api.post<ApiResponse<unknown>>(`/accounting/repost/bank-transfer/${transferId}`);
    return response.data;
  },

  async repostMissingAccounting(payload: { module: string; referenceId: string }) {
    const response = await api.post<ApiResponse<unknown>>("/accounting/repost/missing", payload);
    return response.data;
  },

  async repostMissingAccountingBatch(items: Array<{ module: string; referenceId: string }>) {
    const response = await api.post<ApiResponse<unknown[]>>("/accounting/repost/missing/batch", { items });
    return response.data;
  },

  async getDayBook(filters?: Filters): Promise<DayBook> {
    const response = await api.get<ApiResponse<DayBook>>(withFilters("/accounting/day-book", filters));
    return response.data.data;
  },

  async getBasicTrialBalance(filters?: Filters): Promise<BasicTrialBalance> {
    const response = await api.get<ApiResponse<BasicTrialBalance>>(
      withFilters("/accounting/trial-balance/basic", filters),
    );
    return response.data.data;
  },

  async getTrialBalance(filters?: Filters): Promise<BasicTrialBalance> {
    return this.getBasicTrialBalance(filters);
  },

  async getAccountingReportDashboard(filters?: Filters): Promise<AccountingReportDashboard> {
    const response = await api.get<ApiResponse<AccountingReportDashboard>>(
      withFilters("/accounting/reports/dashboard", filters),
    );
    return response.data.data;
  },

  async getTrialBalanceReport(filters?: Filters): Promise<TrialBalanceReport> {
    const response = await api.get<ApiResponse<TrialBalanceReport>>(
      withFilters("/accounting/reports/trial-balance", filters),
    );
    return response.data.data;
  },

  async getProfitLossReport(filters?: Filters): Promise<ProfitLossReport> {
    const response = await api.get<ApiResponse<ProfitLossReport>>(
      withFilters("/accounting/reports/profit-loss", filters),
    );
    return response.data.data;
  },

  async getBalanceSheetReport(filters?: Filters): Promise<BalanceSheetReport> {
    const response = await api.get<ApiResponse<BalanceSheetReport>>(
      withFilters("/accounting/reports/balance-sheet", filters),
    );
    return response.data.data;
  },

  async getCashBookReport(filters?: Filters): Promise<BookReport> {
    const response = await api.get<ApiResponse<BookReport>>(
      withFilters("/accounting/reports/cash-book", filters),
    );
    return response.data.data;
  },

  async getBankBookReport(filters?: Filters): Promise<BookReport> {
    const response = await api.get<ApiResponse<BookReport>>(
      withFilters("/accounting/reports/bank-book", filters),
    );
    return response.data.data;
  },

  async getReceivablesReport(filters?: Filters): Promise<PartyOutstandingReport> {
    const response = await api.get<ApiResponse<PartyOutstandingReport>>(
      withFilters("/accounting/reports/receivables", filters),
    );
    return response.data.data;
  },

  async getPayablesReport(filters?: Filters): Promise<PartyOutstandingReport> {
    const response = await api.get<ApiResponse<PartyOutstandingReport>>(
      withFilters("/accounting/reports/payables", filters),
    );
    return response.data.data;
  },

  async getLedgerSummaryReport(filters?: Filters): Promise<LedgerSummaryReport> {
    const response = await api.get<ApiResponse<LedgerSummaryReport>>(
      withFilters("/accounting/reports/ledger-summary", filters),
    );
    return response.data.data;
  },

  async getGroupSummaryReport(filters?: Filters): Promise<GroupSummaryReport> {
    const response = await api.get<ApiResponse<GroupSummaryReport>>(
      withFilters("/accounting/reports/group-summary", filters),
    );
    return response.data.data;
  },

  async getGSTSummary(filters?: Filters) {
    const response = await api.get<ApiResponse<unknown>>(withFilters("/accounting/gst/summary", filters));
    return response.data.data;
  },

  async getOutputGSTReport(filters?: Filters) {
    const response = await api.get<ApiResponse<unknown>>(withFilters("/accounting/gst/output", filters));
    return response.data.data;
  },

  async getInputGSTReport(filters?: Filters) {
    const response = await api.get<ApiResponse<unknown>>(withFilters("/accounting/gst/input", filters));
    return response.data.data;
  },

  async getGSTPayableSummary(filters?: Filters) {
    const response = await api.get<ApiResponse<unknown>>(withFilters("/accounting/gst/payable-summary", filters));
    return response.data.data;
  },

  async getHSNSummary(filters?: Filters) {
    const response = await api.get<ApiResponse<unknown>>(withFilters("/accounting/gst/hsn-summary", filters));
    return response.data.data;
  },

  async getGSTR1Report(filters?: Filters) {
    const response = await api.get<ApiResponse<unknown>>(withFilters("/accounting/gst/gstr1", filters));
    return response.data.data;
  },

  async getGSTR3BSummary(filters?: Filters) {
    const response = await api.get<ApiResponse<unknown>>(withFilters("/accounting/gst/gstr3b-summary", filters));
    return response.data.data;
  },

  async getGSTLedgerReport(filters?: Filters) {
    const response = await api.get<ApiResponse<unknown>>(withFilters("/accounting/gst/ledger", filters));
    return response.data.data;
  },

  async getGSTPartyWiseReport(filters?: Filters) {
    const response = await api.get<ApiResponse<unknown>>(withFilters("/accounting/gst/party-wise", filters));
    return response.data.data;
  },

  async getGSTExceptions(filters?: Filters) {
    const response = await api.get<ApiResponse<unknown>>(withFilters("/accounting/gst/exceptions", filters));
    return response.data.data;
  },

  async getAccountingSettings(): Promise<AccountingSettings | null> {
    const response = await api.get<ApiResponse<AccountingSettings | null>>("/accounting/settings");
    return response.data.data;
  },

  async updateAccountingSettings(payload: Partial<AccountingSettings>): Promise<AccountingSettings> {
    const response = await api.put<ApiResponse<AccountingSettings>>("/accounting/settings", payload);
    return response.data.data;
  },

  async validateAccountingSettings(): Promise<AccountingSettingsValidation> {
    const response = await api.get<ApiResponse<AccountingSettingsValidation>>("/accounting/settings/validate");
    return response.data.data;
  },

  async getAccountingHealthCheck(): Promise<AccountingHealthCheck> {
    const response = await api.get<ApiResponse<AccountingHealthCheck>>("/accounting/health-check");
    return response.data.data;
  },

  async getLedgerReconciliation(): Promise<LedgerReconciliation> {
    const response = await api.get<ApiResponse<LedgerReconciliation>>("/accounting/reconciliation/ledgers");
    return response.data.data;
  },

  async fixLedgerReconciliation(): Promise<{ before: LedgerReconciliation; after: LedgerReconciliation }> {
    const response = await api.post<ApiResponse<{ before: LedgerReconciliation; after: LedgerReconciliation }>>(
      "/accounting/reconciliation/ledgers/fix",
    );
    return response.data.data;
  },

  async getCashBankReconciliation(): Promise<CashBankReconciliation> {
    const response = await api.get<ApiResponse<CashBankReconciliation>>("/accounting/reconciliation/cash-bank");
    return response.data.data;
  },

  async getCashBankReconciliationDetails(): Promise<CashBankReconciliation> {
    const response = await api.get<ApiResponse<CashBankReconciliation>>("/accounting/reconciliation/cash-bank/details");
    return response.data.data;
  },

  async linkCashBankLedgers() {
    const response = await api.post<ApiResponse<unknown>>("/accounting/reconciliation/cash-bank/link-ledgers");
    return response.data;
  },

  async linkPartyLedgers() {
    const response = await api.post<ApiResponse<unknown>>("/accounting/reconciliation/parties/link-ledgers");
    return response.data;
  },

  async getPartyReconciliation(): Promise<PartyReconciliation> {
    const response = await api.get<ApiResponse<PartyReconciliation>>("/accounting/reconciliation/parties");
    return response.data.data;
  },

  async getGSTReconciliation(filters?: Filters): Promise<GSTReconciliation> {
    const response = await api.get<ApiResponse<GSTReconciliation>>(
      withFilters("/accounting/reconciliation/gst", filters),
    );
    return response.data.data;
  },

  async getAccountingAuditLogs(filters?: Filters): Promise<{
    logs: AccountingAuditLog[];
    pagination?: ApiResponse<AccountingAuditLog[]>["pagination"];
  }> {
    const response = await api.get<ApiResponse<AccountingAuditLog[]>>(withFilters("/accounting/audit-logs", filters));
    return { logs: response.data.data, pagination: response.data.pagination };
  },
};
