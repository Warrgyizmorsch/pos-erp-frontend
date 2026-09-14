import api from "@/services/api";

export interface KhaataParty {
  _id: string;
  name: string;
  phone: string;
  partyType: 'customer' | 'supplier';
  currentBalance: number;
  creditDays: number;
  isAutoReminderEnabled: boolean;
  lastReminderSentAt: string | null;
}

export interface KhaataTransaction {
  _id: string;
  partyId: string;
  partyType: string;
  type: string;
  debitAmount: number;
  creditAmount: number;
  balanceAfter: number;
  date: string;
  status: string;
}

export const khaataService = {
  getBalances: async () => {
    const response = await api.get<{ success: boolean; data: KhaataParty[] }>("/khaata/balances");
    return response.data.data;
  },

  addTransaction: async (partyId: string, payload: { amount: number; type: 'payment_in' | 'payment_out'; notes?: string; partyType: 'customer' | 'supplier' }) => {
    const response = await api.post<{ success: boolean; data: KhaataTransaction }>(`/khaata/${partyId}/transaction`, payload);
    return response.data.data;
  },

  logReminder: async (partyId: string, message: string) => {
    const response = await api.post(`/khaata/${partyId}/remind`, { message });
    return response.data;
  },
};

