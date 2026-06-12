import api from "./api";
import type { Expense, ExpenseCategory, ApiResponse, Pagination } from "@/types";

export interface LedgerOption {
  _id: string;
  name: string;
  code: string;
  ledgerType: string;
}

export const expenseService = {
  // Expenses & Income
  getAll: async (params?: {
    page?: number;
    limit?: number;
    search?: string;
    category?: string;
    startDate?: string;
    endDate?: string;
    paymentMethod?: string;
    entryType?: string;
    nature?: string;
    status?: string;
    ledgerId?: string;
  }): Promise<{ data: Expense[]; pagination: Pagination }> => {
    const { data } = await api.get<ApiResponse<Expense[]>>("/expenses", { params });
    return { data: data.data, pagination: data.pagination! };
  },

  getById: async (id: string): Promise<Expense> => {
    const { data } = await api.get<ApiResponse<Expense>>(`/expenses/${id}`);
    return data.data;
  },

  create: async (payload: Record<string, unknown>): Promise<Expense> => {
    const { data } = await api.post<ApiResponse<Expense>>("/expenses", payload);
    return data.data;
  },

  update: async (id: string, payload: Record<string, unknown>): Promise<Expense> => {
    const { data } = await api.put<ApiResponse<Expense>>(`/expenses/${id}`, payload);
    return data.data;
  },

  delete: async (id: string): Promise<void> => {
    await api.delete(`/expenses/${id}`);
  },

  // Ledger helpers
  getLedgersByGroup: async (groupCode: string): Promise<LedgerOption[]> => {
    const { data } = await api.get<ApiResponse<LedgerOption[]>>("/expenses/ledgers", {
      params: { group: groupCode },
    });
    return data.data;
  },

  quickCreateLedger: async (payload: {
    name: string;
    entryType: string;
    nature: string;
  }): Promise<LedgerOption> => {
    const { data } = await api.post<ApiResponse<LedgerOption>>("/expenses/ledgers/quick-create", payload);
    return data.data;
  },

  // Expense Categories
  getCategories: async (): Promise<ExpenseCategory[]> => {
    const { data } = await api.get<ApiResponse<ExpenseCategory[]>>("/expense-categories");
    return data.data;
  },

  createCategory: async (payload: { name: string; description?: string; color?: string }): Promise<ExpenseCategory> => {
    const { data } = await api.post<ApiResponse<ExpenseCategory>>("/expense-categories", payload);
    return data.data;
  },

  updateCategory: async (id: string, payload: { name: string; description?: string; color?: string }): Promise<ExpenseCategory> => {
    const { data } = await api.put<ApiResponse<ExpenseCategory>>(`/expense-categories/${id}`, payload);
    return data.data;
  },

  deleteCategory: async (id: string): Promise<void> => {
    await api.delete(`/expense-categories/${id}`);
  },

  // Reports
  getReport: async (params?: {
    startDate?: string;
    endDate?: string;
    groupBy?: string;
    entryType?: string;
  }) => {
    const { data } = await api.get("/expenses/reports/summary", { params });
    return data.data;
  },
};
