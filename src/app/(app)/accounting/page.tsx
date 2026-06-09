"use client";

import Link from "next/link";
import { useCallback, useEffect, useState } from "react";
import {
  BarChart3,
  BookOpen,
  CheckCircle2,
  Database,
  FileText,
  Landmark,
  Layers,
  ListCollapse,
  Loader2,
  RefreshCw,
  Settings,
  XCircle,
} from "lucide-react";
import { toast } from "sonner";
import {
  formatAccountingDate,
  formatAccountingMoney,
  getAccountingErrorMessage,
  getVoucherDisplayStatus,
  LoadingPanel,
  voucherStatusVariant,
} from "@/components/accounting/accounting-ui";
import { PageHeader } from "@/components/shared/PageHeader";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { accountingService, type AccountingDashboard } from "@/services/accountingService";
import { useAuthStore } from "@/store/authStore";

const quickActions = [
  { label: "Chart of Accounts", href: "/accounting/chart-of-accounts", icon: Layers },
  { label: "View Ledgers", href: "/accounting/ledgers", icon: ListCollapse },
  { label: "Create Journal", href: "/accounting/journal/create", icon: FileText },
  { label: "Day Book", href: "/accounting/day-book", icon: BookOpen },
  { label: "Trial Balance", href: "/accounting/trial-balance", icon: BarChart3 },
];

function SummaryCard({ label, value }: { label: string; value: number }) {
  return (
    <Card className="rounded-lg">
      <CardContent className="p-5">
        <p className="text-sm text-muted-foreground">{label}</p>
        <p className="mt-2 text-2xl font-semibold tracking-tight">{value}</p>
      </CardContent>
    </Card>
  );
}

export default function AccountingPage() {
  const [dashboard, setDashboard] = useState<AccountingDashboard | null>(null);
  const [loading, setLoading] = useState(true);
  const [initializing, setInitializing] = useState(false);
  const [restoring, setRestoring] = useState(false);
  const { user } = useAuthStore();

  const loadDashboard = useCallback(async () => {
    try {
      setLoading(true);
      const data = await accountingService.getAccountingDashboard();
      setDashboard(data);
    } catch (error) {
      toast.error(getAccountingErrorMessage(error, "Failed to load accounting dashboard"));
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    const timer = window.setTimeout(() => {
      void loadDashboard();
    }, 0);
    return () => window.clearTimeout(timer);
  }, [loadDashboard]);

  if (loading && !dashboard) {
    return <LoadingPanel label="Loading accounting dashboard..." />;
  }

  const status = dashboard?.status;
  const counts = dashboard?.counts;
  const isAdmin = user?.role === "admin";
  const confirmationText = "This will create missing default account groups, ledgers, voucher types, financial year, and settings. Existing records will not be duplicated.";

  const initializeAccounting = async () => {
    if (!window.confirm(confirmationText)) return;
    try {
      setInitializing(true);
      await accountingService.initialize();
      toast.success("Accounting initialized successfully");
      await loadDashboard();
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
      await loadDashboard();
    } catch (error) {
      toast.error(getAccountingErrorMessage(error, "Failed to restore default ledgers"));
    } finally {
      setRestoring(false);
    }
  };

  return (
    <div className="space-y-6">
      <PageHeader
        title="Accounting"
        description="Accounting dashboard for manual journals, ledgers, vouchers, day book, and validation reports."
        icon={Landmark}
      >
        {isAdmin && (
          <>
            <Button variant="outline" onClick={() => void initializeAccounting()} disabled={initializing || restoring}>
              {initializing ? <Loader2 className="h-4 w-4 animate-spin" /> : <Database className="h-4 w-4" />}
              Initialize Accounting
            </Button>
            <Button variant="outline" onClick={() => void restoreDefaultLedgers()} disabled={initializing || restoring}>
              {restoring ? <Loader2 className="h-4 w-4 animate-spin" /> : <RefreshCw className="h-4 w-4" />}
              Restore Missing Default Ledgers
            </Button>
          </>
        )}
        <Button variant="outline" onClick={() => void loadDashboard()} disabled={loading}>
          {loading ? <Loader2 className="h-4 w-4 animate-spin" /> : <RefreshCw className="h-4 w-4" />}
          Refresh
        </Button>
        <Button asChild>
          <Link href="/accounting/journal/create">
            <FileText className="h-4 w-4" />
            Create Journal
          </Link>
        </Button>
      </PageHeader>

      <Card className="rounded-lg">
        <CardHeader className="flex flex-col gap-3 md:flex-row md:items-start md:justify-between">
          <div>
            <CardTitle>Accounting Status</CardTitle>
            <CardDescription>
              Current foundation settings and active financial year.
            </CardDescription>
          </div>
          <Badge variant={status?.accountingEnabled ? "success" : "warning"} className="w-fit gap-1">
            {status?.accountingEnabled ? (
              <CheckCircle2 className="h-3.5 w-3.5" />
            ) : (
              <XCircle className="h-3.5 w-3.5" />
            )}
            {status?.accountingEnabled ? "Enabled" : "Disabled"}
          </Badge>
        </CardHeader>
        <CardContent className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
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
          <div className="rounded-lg border border-border bg-background p-4">
            <p className="text-xs text-muted-foreground">Active Financial Year</p>
            <p className="mt-2 font-semibold">{status?.activeFinancialYear?.name || "Not set"}</p>
            <p className="mt-1 text-xs text-muted-foreground">
              {status?.activeFinancialYear
                ? `${formatAccountingDate(status.activeFinancialYear.startDate)} - ${formatAccountingDate(status.activeFinancialYear.endDate)}`
                : "Initialize accounting first"}
            </p>
          </div>
          {[
            ["Auto Voucher Posting", status?.autoVoucherPosting],
            ["GST Accounting", status?.gstAccountingEnabled],
            ["Inventory Accounting", status?.inventoryAccountingEnabled],
            ["Accounting Enabled", status?.accountingEnabled],
          ].map(([label, enabled]) => (
            <div className="rounded-lg border border-border bg-background p-4" key={String(label)}>
              <p className="text-xs text-muted-foreground">{label}</p>
              <Badge className="mt-3" variant={enabled ? "success" : "secondary"}>
                {enabled ? "Enabled" : "Disabled"}
              </Badge>
            </div>
          ))}
        </CardContent>
      </Card>

      <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-6">
        <SummaryCard label="Account Groups" value={counts?.accountGroups ?? 0} />
        <SummaryCard label="Ledgers" value={counts?.ledgers ?? 0} />
        <SummaryCard label="Voucher Types" value={counts?.voucherTypes ?? 0} />
        <SummaryCard label="Posted Vouchers" value={counts?.postedVouchers ?? 0} />
        <SummaryCard label="Draft Vouchers" value={counts?.draftVouchers ?? 0} />
        <SummaryCard label="Cancelled Vouchers" value={counts?.cancelledVouchers ?? 0} />
      </div>

      <Card className="rounded-lg">
        <CardHeader>
          <CardTitle>Quick Actions</CardTitle>
          <CardDescription>Open the core accounting work areas.</CardDescription>
        </CardHeader>
        <CardContent className="grid gap-3 sm:grid-cols-2 lg:grid-cols-5">
          {quickActions.map((action) => (
            <Button asChild variant="outline" className="h-14 justify-start rounded-lg" key={action.href}>
              <Link href={action.href}>
                <action.icon className="h-4 w-4" />
                {action.label}
              </Link>
            </Button>
          ))}
          <Button asChild variant="outline" className="h-14 justify-start rounded-lg">
            <Link href="/accounting/settings">
              <Settings className="h-4 w-4" />
              Settings
            </Link>
          </Button>
        </CardContent>
      </Card>

      <Card className="rounded-lg">
        <CardHeader>
          <CardTitle>Recent Vouchers</CardTitle>
          <CardDescription>Latest accounting vouchers across draft, posted, cancelled, and reversed states.</CardDescription>
        </CardHeader>
        <CardContent className="p-0">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Date</TableHead>
                <TableHead>Voucher No</TableHead>
                <TableHead>Type</TableHead>
                <TableHead>Narration</TableHead>
                <TableHead className="text-right">Debit</TableHead>
                <TableHead className="text-right">Credit</TableHead>
                <TableHead>Status</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {(dashboard?.recentVouchers || []).map((voucher) => {
                const displayStatus = getVoucherDisplayStatus(voucher);

                return (
                  <TableRow key={voucher._id}>
                    <TableCell>{formatAccountingDate(voucher.date)}</TableCell>
                    <TableCell className="font-medium">{voucher.voucherNo}</TableCell>
                    <TableCell>{voucher.voucherTypeCode}</TableCell>
                    <TableCell className="max-w-[320px] truncate">{voucher.narration || "-"}</TableCell>
                    <TableCell className="text-right">{formatAccountingMoney(voucher.totalDebit)}</TableCell>
                    <TableCell className="text-right">{formatAccountingMoney(voucher.totalCredit)}</TableCell>
                    <TableCell>
                      <Badge variant={voucherStatusVariant(displayStatus)}>{displayStatus}</Badge>
                    </TableCell>
                  </TableRow>
                );
              })}
              {dashboard?.recentVouchers.length === 0 && (
                <TableRow>
                  <TableCell colSpan={7} className="h-28 text-center text-muted-foreground">
                    No vouchers created yet.
                  </TableCell>
                </TableRow>
              )}
            </TableBody>
          </Table>
        </CardContent>
      </Card>
    </div>
  );
}
