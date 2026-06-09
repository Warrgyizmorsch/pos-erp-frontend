import { create } from "zustand";
import { accountingService } from "@/services/accountingService";

interface AccountingPreferenceState {
  accountingEnabled: boolean | null;
  isLoading: boolean;
  isSaving: boolean;
  error: string | null;
  fetchAccountingPreference: () => Promise<void>;
  syncAccountingEnabled: (enabled: boolean | null) => void;
  setAccountingEnabled: (enabled: boolean) => Promise<void>;
}

const getErrorMessage = (error: unknown, fallback: string) => {
  if (
    error
    && typeof error === "object"
    && "response" in error
    && error.response
    && typeof error.response === "object"
    && "data" in error.response
    && error.response.data
    && typeof error.response.data === "object"
    && "message" in error.response.data
    && typeof error.response.data.message === "string"
  ) {
    return error.response.data.message;
  }

  return error instanceof Error ? error.message : fallback;
};

export const useAccountingPreferenceStore = create<AccountingPreferenceState>((set) => ({
  accountingEnabled: null,
  isLoading: false,
  isSaving: false,
  error: null,

  syncAccountingEnabled: (enabled) => set({ accountingEnabled: enabled }),

  fetchAccountingPreference: async () => {
    try {
      set({ isLoading: true, error: null });
      const status = await accountingService.getStatus();
      set({
        accountingEnabled: Boolean(status.accountingEnabled),
        isLoading: false,
      });
    } catch (error) {
      set({
        isLoading: false,
        error: getErrorMessage(error, "Failed to load accounting setting"),
      });
    }
  },

  setAccountingEnabled: async (enabled) => {
    const previous = useAccountingPreferenceStore.getState().accountingEnabled;
    try {
      set({ accountingEnabled: enabled, isSaving: true, error: null });
      const settings = await accountingService.updateAccountingSettings({ accountingEnabled: enabled });
      set({
        accountingEnabled: Boolean(settings.accountingEnabled),
        isSaving: false,
      });
    } catch (error) {
      set({
        accountingEnabled: previous,
        isSaving: false,
        error: getErrorMessage(error, "Failed to update accounting setting"),
      });
      throw error;
    }
  },
}));
