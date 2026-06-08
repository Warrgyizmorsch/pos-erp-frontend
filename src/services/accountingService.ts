import api from "@/services/api";
import type {
  AccountingDashboard,
  AccountingInitializeResponse,
  AccountingReportDashboard,
  AccountingSettings,
  AccountingStatus,
  BasicTrialBalance,
  BalanceSheetReport,
  BookReport,
  ChartGroup,
  DayBook,
  GroupSummaryReport,
  JournalPayload,
  Ledger,
  LedgerSummaryReport,
  LedgerStatement,
  PartyOutstandingReport,
  ProfitLossReport,
  TestVoucherPayload,
  TrialBalanceReport,
  Voucher,
  VoucherDetail,
  VoucherType,
} from "@/types/accounting";

export type {
  AccountingDashboard,
  AccountingInitializeResponse,
  AccountingReportDashboard,
  AccountingSettings,
  AccountingStatus,
  BasicTrialBalance,
  BalanceSheetReport,
  BookReport,
  ChartGroup,
  ChartLedger,
  DayBook,
  DayBookEntry,
  GroupSummaryReport,
  JournalPayload,
  Ledger as AccountingLedger,
  Ledger,
  LedgerSummaryReport,
  LedgerStatement,
  LedgerStatementEntry,
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

  async getAccountingSettings(): Promise<AccountingSettings | null> {
    const response = await api.get<ApiResponse<AccountingSettings | null>>("/accounting/settings");
    return response.data.data;
  },

  async updateAccountingSettings(payload: Partial<AccountingSettings>): Promise<AccountingSettings> {
    const response = await api.put<ApiResponse<AccountingSettings>>("/accounting/settings", payload);
    return response.data.data;
  },
};
