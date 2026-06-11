"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import Link from "next/link";
import { AlertTriangle, CheckCircle2, FileText, HeartPulse, Loader2, RefreshCw, RotateCw, Wrench } from "lucide-react";
import { toast } from "sonner";
import {
  formatAccountingDate,
  getAccountingErrorMessage,
  LoadingPanel,
} from "@/components/accounting/accounting-ui";
import { AccountingExportActions } from "@/components/accounting/AccountingExportActions";
import { PageHeader } from "@/components/shared/PageHeader";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { accountingService, type AccountingHealthCheck, type AccountingHealthIssue } from "@/services/accountingService";

const severityVariant = (severity: string) => {
  if (severity === "critical") return "destructive";
  if (severity === "warning") return "warning";
  return "secondary";
};

const sourceHref = (issue: AccountingHealthIssue) => {
  if (!issue.referenceId) return "";
  if (issue.module === "sale" || issue.module === "sale_invoice") return `/sales/${issue.referenceId}`;
  if (issue.module === "purchase") return `/purchases/${issue.referenceId}`;
  if (issue.module === "ledger") return `/accounting/ledgers/${issue.referenceId}`;
  return "";
};

function SummaryCard({ label, value, tone }: { label: string; value: number | string; tone?: "bad" | "warn" | "ok" }) {
  return (
    <Card className="rounded-lg">
      <CardContent className="p-5">
        <p className="text-sm text-muted-foreground">{label}</p>
        <p className={tone === "bad" ? "mt-2 text-2xl font-bold text-destructive" : tone === "warn" ? "mt-2 text-2xl font-bold text-amber-600" : "mt-2 text-2xl font-bold"}>
          {value}
        </p>
      </CardContent>
    </Card>
  );
}

export default function AccountingHealthPage() {
  const [health, setHealth] = useState<AccountingHealthCheck | null>(null);
  const [loading, setLoading] = useState(true);
  const [fixingId, setFixingId] = useState<string | null>(null);

  const loadHealth = useCallback(async () => {
    try {
      setLoading(true);
      setHealth(await accountingService.getAccountingHealthCheck());
    } catch (error) {
      toast.error(getAccountingErrorMessage(error, "Failed to load accounting health"));
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    const timer = window.setTimeout(() => {
      void loadHealth();
    }, 0);
    return () => window.clearTimeout(timer);
  }, [loadHealth]);

  const repost = async (issue: AccountingHealthIssue) => {
    if (!issue.referenceId) return;
    try {
      setFixingId(issue.id);
      await accountingService.repostMissingAccounting({ module: issue.module, referenceId: issue.referenceId });
      toast.success("Accounting repost completed");
      await loadHealth();
    } catch (error) {
      toast.error(getAccountingErrorMessage(error, "Repost failed"));
    } finally {
      setFixingId(null);
    }
  };

  const fixLedgers = async () => {
    try {
      setFixingId("ledger-fix");
      await accountingService.fixLedgerReconciliation();
      toast.success("Ledger balances recalculated");
      await loadHealth();
    } catch (error) {
      toast.error(getAccountingErrorMessage(error, "Ledger fix failed"));
    } finally {
      setFixingId(null);
    }
  };

  if (loading && !health) return <LoadingPanel label="Running accounting health check..." />;

  const summary = health?.summary;
  const issues = health?.issues || [];
  const hasLedgerMismatch = issues.some((issue) => issue.type === "LEDGER_BALANCE_MISMATCH");
  const hasGSTMismatch = issues.some((issue) => issue.type === "GST_MISMATCH");
  const exportRows = useMemo(() => [
    {
      section: "Summary",
      severity: health?.status || "-",
      type: "SYSTEM_STATUS",
      module: "accounting",
      referenceNo: "",
      message: `Total ${summary?.totalIssues || 0}, Critical ${summary?.criticalIssues || 0}, Warnings ${summary?.warningIssues || 0}`,
      suggestedFix: health?.status === "healthy" ? "No action required." : "Review listed issues.",
    },
    ...issues.map((issue) => ({
      section: "Issue",
      severity: issue.severity,
      type: issue.type,
      module: issue.module,
      referenceNo: issue.referenceNo || "-",
      message: issue.message,
      suggestedFix: issue.suggestedFix || "-",
    })),
  ], [health?.status, issues, summary]);

  const exportColumns = [
    { key: "section", label: "Section" },
    { key: "severity", label: "Severity" },
    { key: "type", label: "Type" },
    { key: "module", label: "Module" },
    { key: "referenceNo", label: "Reference No" },
    { key: "message", label: "Message" },
    { key: "suggestedFix", label: "Suggested Fix" },
  ];

  return (
    <div className="space-y-6">
      <PageHeader
        title="Accounting Health"
        description="Final validation for postings, balances, GST, audit, and reconciliation readiness."
        icon={HeartPulse}
      >
        <Badge variant={health?.status === "healthy" ? "success" : health?.status === "critical" ? "destructive" : "warning"}>
          {health?.status || "Unknown"}
        </Badge>
        <AccountingExportActions
          title="Accounting Health"
          subtitle={`Checked ${health?.checkedAt ? formatAccountingDate(health.checkedAt) : new Date().toLocaleString()}`}
          filename={`accounting-health-${new Date().toISOString().slice(0, 10)}`}
          columns={exportColumns}
          rows={exportRows}
          disabled={loading}
        />
        <Button variant="outline" onClick={() => void loadHealth()} disabled={loading}>
          {loading ? <Loader2 className="h-4 w-4 animate-spin" /> : <RefreshCw className="h-4 w-4" />}
          Refresh
        </Button>
      </PageHeader>

      <div className="grid gap-4 md:grid-cols-3 xl:grid-cols-7">
        <SummaryCard label="System Status" value={health?.status || "-"} tone={health?.status === "healthy" ? "ok" : "warn"} />
        <SummaryCard label="Total Issues" value={summary?.totalIssues || 0} />
        <SummaryCard label="Critical" value={summary?.criticalIssues || 0} tone="bad" />
        <SummaryCard label="Warnings" value={summary?.warningIssues || 0} tone="warn" />
        <SummaryCard label="Missing Postings" value={summary?.missingPostings || 0} tone="warn" />
        <SummaryCard label="Ledger Mismatches" value={summary?.ledgerMismatches || 0} tone="bad" />
        <SummaryCard label="Duplicate Vouchers" value={summary?.duplicateVouchers || 0} tone="bad" />
      </div>

      <Card className="rounded-lg">
        <CardHeader className="flex flex-row items-center justify-between">
          <CardTitle className="text-base">Quick Fix Actions</CardTitle>
          <div className="flex flex-wrap items-center gap-2">
            {hasGSTMismatch && (
              <Button variant="outline" asChild>
                <Link href="/accounting/reconciliation">
                  <FileText className="h-4 w-4" />
                  Review GST
                </Link>
              </Button>
            )}
            {hasLedgerMismatch && (
              <Button variant="outline" onClick={() => void fixLedgers()} disabled={fixingId === "ledger-fix"}>
                {fixingId === "ledger-fix" ? <Loader2 className="h-4 w-4 animate-spin" /> : <Wrench className="h-4 w-4" />}
                Recalculate Ledger Balances
              </Button>
            )}
          </div>
        </CardHeader>
        <CardContent className="flex flex-wrap gap-2 text-sm text-muted-foreground">
          <Badge variant="outline">Repost missing accounting one document at a time</Badge>
          {hasGSTMismatch && <Badge variant="outline">GST reconciliation is view-only</Badge>}
          {hasLedgerMismatch && <Badge variant="outline">Ledger fix does not modify voucher entries</Badge>}
        </CardContent>
      </Card>

      <Card className="rounded-lg">
        <CardHeader>
          <CardTitle className="flex items-center gap-2 text-base">
            {health?.status === "healthy" ? <CheckCircle2 className="h-4 w-4" /> : <AlertTriangle className="h-4 w-4" />}
            Issues
          </CardTitle>
        </CardHeader>
        <CardContent className="p-0">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Severity</TableHead>
                <TableHead>Type</TableHead>
                <TableHead>Module</TableHead>
                <TableHead>Reference No</TableHead>
                <TableHead>Message</TableHead>
                <TableHead>Suggested Fix</TableHead>
                <TableHead>Action</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {issues.map((issue) => (
                <TableRow key={issue.id}>
                  <TableCell><Badge variant={severityVariant(issue.severity)}>{issue.severity}</Badge></TableCell>
                  <TableCell className="font-medium">{issue.type}</TableCell>
                  <TableCell>{issue.module}</TableCell>
                  <TableCell>{issue.referenceNo || "-"}</TableCell>
                  <TableCell className="max-w-[340px]">{issue.message}</TableCell>
                  <TableCell className="max-w-[320px] text-muted-foreground">{issue.suggestedFix || "-"}</TableCell>
                  <TableCell>
                    <div className="flex items-center gap-2">
                      {sourceHref(issue) && (
                        <Button asChild variant="outline" size="icon-sm" title="View source">
                          <Link href={sourceHref(issue)}><FileText className="h-4 w-4" /></Link>
                        </Button>
                      )}
                      {issue.voucherId && (
                        <Button asChild variant="outline" size="icon-sm" title="View voucher">
                          <Link href={`/accounting/vouchers?voucherId=${issue.voucherId}`}><FileText className="h-4 w-4" /></Link>
                        </Button>
                      )}
                      {issue.type === "MISSING_POSTING" && (
                        <Button variant="outline" size="icon-sm" title="Repost accounting" onClick={() => void repost(issue)} disabled={fixingId === issue.id}>
                          {fixingId === issue.id ? <Loader2 className="h-4 w-4 animate-spin" /> : <RotateCw className="h-4 w-4" />}
                        </Button>
                      )}
                      {issue.type === "GST_MISMATCH" && (
                        <Button asChild variant="outline" size="icon-sm" title="Review GST reconciliation">
                          <Link href="/accounting/reconciliation"><FileText className="h-4 w-4" /></Link>
                        </Button>
                      )}
                    </div>
                  </TableCell>
                </TableRow>
              ))}
              {issues.length === 0 && (
                <TableRow>
                  <TableCell colSpan={7} className="h-32 text-center text-muted-foreground">
                    No accounting health issues found. Last checked {formatAccountingDate(health?.checkedAt)}
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
