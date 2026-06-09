"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import { AlertTriangle, CheckCircle2, Database, Loader2, RefreshCw, Save, Settings, SlidersHorizontal } from "lucide-react";
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
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Switch } from "@/components/ui/switch";
import {
  accountingService,
  type AccountingSettings,
  type AccountingSettingsValidation,
  type AccountingStatus,
  type Ledger,
} from "@/services/accountingService";
import { useAuthStore } from "@/store/authStore";

type BooleanSetting = {
  key: keyof Pick<
    AccountingSettings,
    | "accountingEnabled"
    | "gstAccountingEnabled"
    | "inventoryAccountingEnabled"
    | "autoVoucherPosting"
    | "allowManualJournalEntry"
    | "allowBackdatedVouchers"
  >;
  label: string;
  description: string;
};

type LedgerSetting = {
  key: keyof Pick<
    AccountingSettings,
    | "defaultCashLedgerId"
    | "defaultBankLedgerId"
    | "defaultSalesLedgerId"
    | "defaultPurchaseLedgerId"
    | "defaultSalesReturnLedgerId"
    | "defaultPurchaseReturnLedgerId"
    | "defaultRoundOffLedgerId"
    | "defaultDiscountGivenLedgerId"
    | "defaultDiscountReceivedLedgerId"
    | "defaultStockLedgerId"
    | "defaultCOGSLedgerId"
  >;
  label: string;
  ledgerType?: string;
};

const booleanSettings: BooleanSetting[] = [
  {
    key: "accountingEnabled",
    label: "Enable Accounting",
    description: "Master switch for accounting posting and reports.",
  },
  {
    key: "autoVoucherPosting",
    label: "Auto Voucher Posting",
    description: "Create accounting vouchers automatically from business transactions.",
  },
  {
    key: "gstAccountingEnabled",
    label: "GST Accounting",
    description: "Use GST ledgers for tax accounting where modules support it.",
  },
  {
    key: "inventoryAccountingEnabled",
    label: "Inventory Accounting",
    description: "Reserved for stock/COGS accounting phases.",
  },
  {
    key: "allowManualJournalEntry",
    label: "Manual Journal Entry",
    description: "Allow users to create accounting journal vouchers manually.",
  },
  {
    key: "allowBackdatedVouchers",
    label: "Backdated Vouchers",
    description: "Allow voucher dates before the current date.",
  },
];

const ledgerSettings: LedgerSetting[] = [
  { key: "defaultCashLedgerId", label: "Default Cash Ledger", ledgerType: "CASH" },
  { key: "defaultBankLedgerId", label: "Default Bank Ledger", ledgerType: "BANK" },
  { key: "defaultSalesLedgerId", label: "Default Sales Ledger", ledgerType: "SALES" },
  { key: "defaultPurchaseLedgerId", label: "Default Purchase Ledger", ledgerType: "PURCHASE" },
  { key: "defaultSalesReturnLedgerId", label: "Default Sales Return Ledger", ledgerType: "SALES_RETURN" },
  { key: "defaultPurchaseReturnLedgerId", label: "Default Purchase Return Ledger", ledgerType: "PURCHASE_RETURN" },
  { key: "defaultRoundOffLedgerId", label: "Default Round Off Ledger", ledgerType: "ROUND_OFF" },
  { key: "defaultDiscountGivenLedgerId", label: "Discount Given Ledger", ledgerType: "DISCOUNT" },
  { key: "defaultDiscountReceivedLedgerId", label: "Discount Received Ledger", ledgerType: "DISCOUNT" },
  { key: "defaultStockLedgerId", label: "Default Stock Ledger", ledgerType: "STOCK" },
  { key: "defaultCOGSLedgerId", label: "Default COGS Ledger", ledgerType: "EXPENSE" },
];

const emptyValue = "NONE";

const defaultAccountingForm: Partial<AccountingSettings> = {
  accountingEnabled: true,
  autoVoucherPosting: true,
  gstAccountingEnabled: false,
  inventoryAccountingEnabled: false,
  allowManualJournalEntry: false,
  allowBackdatedVouchers: true,
};

const getLedgerValue = (settings: Partial<AccountingSettings>, key: LedgerSetting["key"]) => {
  const value = settings[key];
  if (!value) return "";
  return typeof value === "string" ? value : value._id;
};

const normalizeDate = (value?: string) => (value ? new Date(value).toISOString().slice(0, 10) : "");

export default function AccountingSettingsPage() {
  const [settings, setSettings] = useState<AccountingSettings | null>(null);
  const [form, setForm] = useState<Partial<AccountingSettings>>({});
  const [ledgers, setLedgers] = useState<Ledger[]>([]);
  const [validation, setValidation] = useState<AccountingSettingsValidation | null>(null);
  const [status, setStatus] = useState<AccountingStatus | null>(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [initializing, setInitializing] = useState(false);
  const [restoring, setRestoring] = useState(false);
  const { user } = useAuthStore();

  const loadSettings = useCallback(async () => {
    try {
      setLoading(true);
      const [nextSettings, nextLedgers, nextValidation, nextStatus] = await Promise.all([
        accountingService.getAccountingSettings(),
        accountingService.getLedgers({ isActive: true }),
        accountingService.validateAccountingSettings(),
        accountingService.getStatus(),
      ]);
      setSettings(nextSettings);
      setForm({ ...defaultAccountingForm, ...(nextSettings || {}) });
      setLedgers(nextLedgers);
      setValidation(nextValidation);
      setStatus(nextStatus);
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

  const ledgersByType = useMemo(() => {
    const map = new Map<string, Ledger[]>();
    ledgers.forEach((ledger) => {
      const type = ledger.ledgerType || "OTHER";
      map.set(type, [...(map.get(type) || []), ledger]);
    });
    return map;
  }, [ledgers]);

  const setBoolean = (key: BooleanSetting["key"], value: boolean) => {
    setForm((prev) => ({ ...prev, [key]: value }));
  };

  const setLedger = (key: LedgerSetting["key"], value: string) => {
    setForm((prev) => ({ ...prev, [key]: value === emptyValue ? undefined : value }));
  };

  const saveSettings = async () => {
    try {
      setSaving(true);
      const payload: Record<string, unknown> = {};

      booleanSettings.forEach(({ key }) => {
        payload[key] = Boolean(form[key]);
      });
      ledgerSettings.forEach(({ key }) => {
        const value = getLedgerValue(form, key);
        payload[key] = value || null;
      });
      payload.lockBooksTillDate = form.lockBooksTillDate || null;

      const saved = await accountingService.updateAccountingSettings(payload as Partial<AccountingSettings>);
      setSettings(saved);
      setForm({ ...defaultAccountingForm, ...saved });
      toast.success("Accounting settings saved");
      setValidation(await accountingService.validateAccountingSettings());
      await loadSettings();
    } catch (error) {
      toast.error(getAccountingErrorMessage(error, "Failed to save accounting settings"));
    } finally {
      setSaving(false);
    }
  };

  const confirmationText = "This will create missing default account groups, ledgers, voucher types, financial year, and settings. Existing records will not be duplicated.";
  const isAdmin = user?.role === "admin";

  const initializeAccounting = async () => {
    if (!window.confirm(confirmationText)) return;
    try {
      setInitializing(true);
      await accountingService.initialize();
      toast.success("Accounting initialized successfully");
      await loadSettings();
    } catch (error) {
      toast.error(getAccountingErrorMessage(error, "Failed to initialize accounting"));
    } finally {
      setInitializing(false);
    }
  };

  const restoreDefaultLedgers = async () => {
    if (!window.confirm(confirmationText)) return;
    try {
      setRestoring(true);
      await accountingService.restoreDefaultLedgers();
      toast.success("Accounting initialized successfully");
      await loadSettings();
    } catch (error) {
      toast.error(getAccountingErrorMessage(error, "Failed to restore default ledgers"));
    } finally {
      setRestoring(false);
    }
  };

  if (loading && !settings) {
    return <LoadingPanel label="Loading accounting settings..." />;
  }

  const accountingEnabled = Boolean(form.accountingEnabled);

  return (
    <div className="space-y-6">
      <PageHeader
        title="Accounting Settings"
        description="Enable accounting, control posting behavior, and map default ledgers."
        icon={Settings}
      >
        <Badge variant={accountingEnabled ? "success" : "secondary"}>
          {accountingEnabled ? "Accounting Enabled" : "Accounting Disabled"}
        </Badge>
        {isAdmin && (
          <>
            <Button variant="outline" onClick={() => void initializeAccounting()} disabled={loading || saving || initializing || restoring}>
              {initializing ? <Loader2 className="h-4 w-4 animate-spin" /> : <Database className="h-4 w-4" />}
              Initialize Accounting
            </Button>
            <Button variant="outline" onClick={() => void restoreDefaultLedgers()} disabled={loading || saving || initializing || restoring}>
              {restoring ? <Loader2 className="h-4 w-4 animate-spin" /> : <RefreshCw className="h-4 w-4" />}
              Restore Missing Default Ledgers
            </Button>
          </>
        )}
        <Button variant="outline" onClick={() => void loadSettings()} disabled={loading || saving}>
          {loading ? <Loader2 className="h-4 w-4 animate-spin" /> : <RefreshCw className="h-4 w-4" />}
          Refresh
        </Button>
        <Button onClick={() => void saveSettings()} disabled={saving}>
          {saving ? <Loader2 className="h-4 w-4 animate-spin" /> : <Save className="h-4 w-4" />}
          Save Settings
        </Button>
      </PageHeader>

      <Card className="rounded-lg">
        <CardHeader>
          <CardTitle className="flex items-center gap-2 text-base">
            <SlidersHorizontal className="h-4 w-4" />
            Feature Controls
          </CardTitle>
        </CardHeader>
        <CardContent className="grid gap-3 md:grid-cols-2 xl:grid-cols-3">
          {booleanSettings.map((setting) => {
            const checked = Boolean(form[setting.key]);
            return (
              <div className="flex min-h-28 items-start justify-between gap-4 rounded-lg border border-border bg-background p-4" key={setting.key}>
                <div>
                  <Label className="text-sm font-semibold">{setting.label}</Label>
                  <p className="mt-1 text-sm text-muted-foreground">{setting.description}</p>
                  <Badge className="mt-3" variant={checked ? "success" : "secondary"}>
                    {checked ? "Enabled" : "Disabled"}
                  </Badge>
                </div>
                <Switch checked={checked} onCheckedChange={(value) => setBoolean(setting.key, value)} />
              </div>
            );
          })}
          <div className="rounded-lg border border-border bg-background p-4">
            <Label className="text-sm font-semibold">Lock Books Till Date</Label>
            <p className="mt-1 text-sm text-muted-foreground">Prevent accounting changes before this date where supported.</p>
            <Input
              type="date"
              className="mt-3"
              value={normalizeDate(form.lockBooksTillDate)}
              onChange={(event) => setForm((prev) => ({ ...prev, lockBooksTillDate: event.target.value }))}
            />
            <p className="mt-2 text-xs text-muted-foreground">
              Current: {formatAccountingDate(settings?.lockBooksTillDate)}
            </p>
          </div>
        </CardContent>
      </Card>

      <Card className="rounded-lg">
        <CardHeader>
          <CardTitle className="flex items-center gap-2 text-base">
            {validation?.valid ? <CheckCircle2 className="h-4 w-4 text-emerald-600" /> : <AlertTriangle className="h-4 w-4 text-amber-600" />}
            Settings Validation
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-3">
          <div className="grid gap-3 md:grid-cols-3">
            <div className="rounded-lg border border-border bg-background p-4">
              <p className="text-xs text-muted-foreground">Accounting Foundation</p>
              <Badge className="mt-3" variant={status?.initialized ? "success" : "warning"}>
                {status?.initialized ? "Accounting Initialized" : "Not Initialized"}
              </Badge>
            </div>
            <div className="rounded-lg border border-border bg-background p-4">
              <p className="text-xs text-muted-foreground">Missing Default Ledgers</p>
              <p className="mt-2 text-xl font-semibold">{status?.missingDefaultLedgersCount ?? 0}</p>
            </div>
            <div className="rounded-lg border border-border bg-background p-4">
              <p className="text-xs text-muted-foreground">Missing Default Groups</p>
              <p className="mt-2 text-xl font-semibold">{status?.missingDefaultGroupsCount ?? 0}</p>
            </div>
          </div>
          <Badge variant={validation?.valid ? "success" : "warning"}>
            {validation?.valid ? "Valid configuration" : `${validation?.missingLedgers.length || 0} missing ledger mapping(s)`}
          </Badge>
          {validation?.warnings.map((warning) => (
            <div className="rounded-lg border border-amber-200 bg-amber-50 p-3 text-sm text-amber-800" key={warning}>
              {warning}
            </div>
          ))}
          {validation?.missingLedgers.length ? (
            <div className="grid gap-2 md:grid-cols-2 xl:grid-cols-3">
              {validation.missingLedgers.map((ledger) => (
                <div className="rounded-lg border border-border p-3 text-sm" key={`${ledger.field}-${ledger.reason}`}>
                  <p className="font-medium">{ledger.label}</p>
                  <p className="text-muted-foreground">{ledger.reason}</p>
                </div>
              ))}
            </div>
          ) : null}
        </CardContent>
      </Card>

      <Card className="rounded-lg">
        <CardHeader>
          <CardTitle className="text-base">Default Ledger Mapping</CardTitle>
        </CardHeader>
        <CardContent className="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
          {ledgerSettings.map((setting) => {
            const preferredLedgers = setting.ledgerType ? ledgersByType.get(setting.ledgerType) || [] : [];
            const options = preferredLedgers.length ? preferredLedgers : ledgers;
            const selectedValue = getLedgerValue(form, setting.key) || emptyValue;

            return (
              <div className="space-y-2 rounded-lg border border-border bg-background p-4" key={setting.key}>
                <Label className="text-sm font-semibold">{setting.label}</Label>
                <Select value={selectedValue} onValueChange={(value) => setLedger(setting.key, value)}>
                  <SelectTrigger>
                    <SelectValue placeholder="Select ledger" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value={emptyValue}>Not configured</SelectItem>
                    {options.map((ledger) => (
                      <SelectItem key={ledger._id} value={ledger._id}>
                        {ledger.name} ({ledger.code})
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
                <p className="text-xs text-muted-foreground">
                  {setting.ledgerType ? `Filtered by ${setting.ledgerType}` : "All ledgers"}
                </p>
              </div>
            );
          })}
        </CardContent>
      </Card>
    </div>
  );
}
