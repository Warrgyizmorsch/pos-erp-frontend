"use client";

import { useCallback, useEffect, useState } from "react";
import { Loader2, RefreshCw, Settings } from "lucide-react";
import { toast } from "sonner";
import {
  formatAccountingDate,
  getAccountingErrorMessage,
  LoadingPanel,
} from "@/components/accounting/accounting-ui";
import { PageHeader } from "@/components/shared/PageHeader";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { accountingService, type AccountingSettings } from "@/services/accountingService";

const flags: Array<[keyof AccountingSettings, string]> = [
  ["accountingEnabled", "Accounting Enabled"],
  ["gstAccountingEnabled", "GST Accounting Enabled"],
  ["inventoryAccountingEnabled", "Inventory Accounting Enabled"],
  ["autoVoucherPosting", "Auto Voucher Posting"],
  ["allowManualJournalEntry", "Allow Manual Journal Entry"],
  ["allowBackdatedVouchers", "Allow Backdated Vouchers"],
];

const defaultLedgers: Array<[keyof AccountingSettings, string]> = [
  ["defaultCashLedgerId", "Default Cash Ledger"],
  ["defaultBankLedgerId", "Default Bank Ledger"],
  ["defaultSalesLedgerId", "Default Sales Ledger"],
  ["defaultPurchaseLedgerId", "Default Purchase Ledger"],
  ["defaultRoundOffLedgerId", "Default Round Off Ledger"],
  ["defaultDiscountGivenLedgerId", "Default Discount Given Ledger"],
  ["defaultDiscountReceivedLedgerId", "Default Discount Received Ledger"],
  ["defaultStockLedgerId", "Default Stock Ledger"],
  ["defaultCOGSLedgerId", "Default COGS Ledger"],
];

export default function AccountingSettingsPage() {
  const [settings, setSettings] = useState<AccountingSettings | null>(null);
  const [loading, setLoading] = useState(true);

  const loadSettings = useCallback(async () => {
    try {
      setLoading(true);
      setSettings(await accountingService.getAccountingSettings());
    } catch (error) {
      toast.error(getAccountingErrorMessage(error, "Failed to load accounting settings"));
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    const timer = window.setTimeout(() => {
      void loadSettings();
    }, 0);
    return () => window.clearTimeout(timer);
  }, [loadSettings]);

  if (loading && !settings) {
    return <LoadingPanel label="Loading accounting settings..." />;
  }

  return (
    <div className="space-y-6">
      <PageHeader
        title="Accounting Settings"
        description="Accounting flags and default ledger references."
        icon={Settings}
      >
        <Button variant="outline" onClick={() => void loadSettings()} disabled={loading}>
          {loading ? <Loader2 className="h-4 w-4 animate-spin" /> : <RefreshCw className="h-4 w-4" />}
          Refresh
        </Button>
      </PageHeader>

      <Card className="rounded-lg">
        <CardHeader><CardTitle>Settings</CardTitle></CardHeader>
        <CardContent className="grid gap-3 md:grid-cols-2 xl:grid-cols-3">
          {flags.map(([key, label]) => {
            const enabled = Boolean(settings?.[key]);
            return (
              <div className="flex items-center justify-between rounded-lg border border-border bg-background p-4" key={key}>
                <span className="text-sm font-medium">{label}</span>
                <Badge variant={enabled ? "success" : "secondary"}>{enabled ? "Enabled" : "Disabled"}</Badge>
              </div>
            );
          })}
          <div className="flex items-center justify-between rounded-lg border border-border bg-background p-4">
            <span className="text-sm font-medium">Lock Books Till Date</span>
            <span className="text-sm text-muted-foreground">{formatAccountingDate(settings?.lockBooksTillDate)}</span>
          </div>
        </CardContent>
      </Card>

      <Card className="rounded-lg">
        <CardHeader><CardTitle>Default Ledgers</CardTitle></CardHeader>
        <CardContent className="grid gap-3 md:grid-cols-2">
          {defaultLedgers.map(([key, label]) => {
            const ledger = settings?.[key];
            const ledgerObject = ledger && typeof ledger === "object" && "_id" in ledger ? ledger : null;
            return (
              <div className="rounded-lg border border-border bg-background p-4" key={key}>
                <p className="text-sm text-muted-foreground">{label}</p>
                <p className="mt-1 font-semibold">{ledgerObject?.name || "Not configured"}</p>
                <p className="mt-1 text-xs text-muted-foreground">{ledgerObject?.code || "-"}</p>
              </div>
            );
          })}
        </CardContent>
      </Card>
    </div>
  );
}
