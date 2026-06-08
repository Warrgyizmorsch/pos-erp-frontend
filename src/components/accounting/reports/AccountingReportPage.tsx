"use client";

import Link from "next/link";
import { useCallback, useEffect, useState } from "react";
import {
  ArrowLeft,
  BadgeIndianRupee,
  Banknote,
  BarChart3,
  BookOpen,
  Building2,
  Download,
  Landmark,
  Loader2,
  Printer,
  ReceiptText,
  RefreshCw,
  Scale,
  Users,
} from "lucide-react";
import { toast } from "sonner";
import {
  formatAccountingDate,
  formatAccountingMoney,
  getAccountingErrorMessage,
  LoadingPanel,
} from "@/components/accounting/accounting-ui";
import { EmptyState } from "@/components/shared/EmptyState";
import { PageHeader } from "@/components/shared/PageHeader";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import {
  Table,
  TableBody,
  TableCell,
  TableFooter,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { accountingService } from "@/services/accountingService";
import type {
  BalanceSheetReport,
  BookReport,
  GroupSummaryReport,
  LedgerSummaryReport,
  PartyOutstandingReport,
  ProfitLossReport,
  ReportGroupAmount,
  TrialBalanceReport,
} from "@/types/accounting";

export type AccountingReportKind =
  | "trial-balance"
  | "profit-loss"
  | "balance-sheet"
  | "cash-book"
  | "bank-book"
  | "receivables"
  | "payables"
  | "ledger-summary"
  | "group-summary";

const reportMeta: Record<AccountingReportKind, {
  title: string;
  description: string;
  icon: typeof BarChart3;
  mode: "period" | "asOn";
}> = {
  "trial-balance": {
    title: "Trial Balance",
    description: "Ledger-wise opening, period movement, and closing debit/credit balances.",
    icon: Scale,
    mode: "period",
  },
  "profit-loss": {
    title: "Profit & Loss",
    description: "Income and expense statement generated from posted accounting vouchers.",
    icon: BadgeIndianRupee,
    mode: "period",
  },
  "balance-sheet": {
    title: "Balance Sheet",
    description: "Assets and liabilities as on a selected date.",
    icon: Landmark,
    mode: "asOn",
  },
  "cash-book": {
    title: "Cash Book",
    description: "Cash receipts, payments, and running balance.",
    icon: Banknote,
    mode: "period",
  },
  "bank-book": {
    title: "Bank Book",
    description: "Bank deposits, withdrawals, and running balance.",
    icon: Building2,
    mode: "period",
  },
  receivables: {
    title: "Receivables",
    description: "Customer outstanding and advance balances.",
    icon: Users,
    mode: "asOn",
  },
  payables: {
    title: "Payables",
    description: "Supplier outstanding and debit/advance balances.",
    icon: ReceiptText,
    mode: "asOn",
  },
  "ledger-summary": {
    title: "Ledger Summary",
    description: "Quick review of all ledger openings, debits, credits, and closing balances.",
    icon: BookOpen,
    mode: "period",
  },
  "group-summary": {
    title: "Account Group Summary",
    description: "Account group totals rolled up from ledger balances.",
    icon: BarChart3,
    mode: "period",
  },
};

const today = () => new Date().toISOString().slice(0, 10);
const monthStart = () => {
  const date = new Date();
  date.setDate(1);
  return date.toISOString().slice(0, 10);
};

type ReportData =
  | TrialBalanceReport
  | ProfitLossReport
  | BalanceSheetReport
  | BookReport
  | PartyOutstandingReport
  | LedgerSummaryReport
  | GroupSummaryReport;

const fetchReport = (kind: AccountingReportKind, filters: Record<string, string>) => {
  if (kind === "trial-balance") return accountingService.getTrialBalanceReport(filters);
  if (kind === "profit-loss") return accountingService.getProfitLossReport(filters);
  if (kind === "balance-sheet") return accountingService.getBalanceSheetReport(filters);
  if (kind === "cash-book") return accountingService.getCashBookReport(filters);
  if (kind === "bank-book") return accountingService.getBankBookReport(filters);
  if (kind === "receivables") return accountingService.getReceivablesReport(filters);
  if (kind === "payables") return accountingService.getPayablesReport(filters);
  if (kind === "ledger-summary") return accountingService.getLedgerSummaryReport(filters);
  return accountingService.getGroupSummaryReport(filters);
};

function Amount({ value }: { value: number }) {
  return <span>{value ? formatAccountingMoney(value) : "-"}</span>;
}

function SummaryCard({ label, value, accent }: { label: string; value: number; accent?: string }) {
  return (
    <Card className="rounded-lg">
      <CardContent className="p-4">
        <p className="text-sm text-muted-foreground">{label}</p>
        <p className={["mt-2 text-2xl font-bold", accent].filter(Boolean).join(" ")}>
          {formatAccountingMoney(value)}
        </p>
      </CardContent>
    </Card>
  );
}

function GroupBlocks({ groups, emptyLabel }: { groups: ReportGroupAmount[]; emptyLabel: string }) {
  if (!groups.length) {
    return <p className="p-4 text-sm text-muted-foreground">{emptyLabel}</p>;
  }

  return (
    <div className="divide-y">
      {groups.map((group) => (
        <div key={group.groupName} className="p-4">
          <div className="mb-2 flex items-center justify-between font-semibold">
            <span>{group.groupName}</span>
            <span>{formatAccountingMoney(group.total)}</span>
          </div>
          <div className="space-y-1">
            {group.ledgers.map((ledger) => (
              <div key={`${group.groupName}-${ledger.ledgerId || ledger.ledgerName}`} className="flex items-center justify-between text-sm text-muted-foreground">
                <span>{ledger.ledgerName}</span>
                <span>{formatAccountingMoney(Math.abs(ledger.amount))}</span>
              </div>
            ))}
          </div>
        </div>
      ))}
    </div>
  );
}

function renderReport(kind: AccountingReportKind, data: ReportData) {
  if (kind === "trial-balance") {
    const report = data as TrialBalanceReport;
    return (
      <>
        <div className="grid gap-4 md:grid-cols-3">
          <SummaryCard label="Closing Debit" value={report.totals.closingDebit} />
          <SummaryCard label="Closing Credit" value={report.totals.closingCredit} />
          <Card className="rounded-lg">
            <CardContent className="p-4">
              <p className="text-sm text-muted-foreground">Status</p>
              <Badge className="mt-3" variant={report.isBalanced ? "success" : "warning"}>
                {report.isBalanced ? "Balanced" : `Difference ${formatAccountingMoney(Math.abs(report.totals.difference))}`}
              </Badge>
            </CardContent>
          </Card>
        </div>
        <Card className="rounded-lg">
          <CardContent className="p-0">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Ledger</TableHead>
                  <TableHead>Group</TableHead>
                  <TableHead>Nature</TableHead>
                  <TableHead className="text-right">Opening Dr</TableHead>
                  <TableHead className="text-right">Opening Cr</TableHead>
                  <TableHead className="text-right">Period Dr</TableHead>
                  <TableHead className="text-right">Period Cr</TableHead>
                  <TableHead className="text-right">Closing Dr</TableHead>
                  <TableHead className="text-right">Closing Cr</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {report.rows.map((row) => (
                  <TableRow key={row.ledgerId}>
                    <TableCell>
                      <p className="font-medium">{row.ledgerName}</p>
                      <p className="text-xs text-muted-foreground">{row.code}</p>
                    </TableCell>
                    <TableCell>{row.groupName || "-"}</TableCell>
                    <TableCell>{row.nature || "-"}</TableCell>
                    <TableCell className="text-right"><Amount value={row.openingDebit} /></TableCell>
                    <TableCell className="text-right"><Amount value={row.openingCredit} /></TableCell>
                    <TableCell className="text-right"><Amount value={row.periodDebit} /></TableCell>
                    <TableCell className="text-right"><Amount value={row.periodCredit} /></TableCell>
                    <TableCell className="text-right"><Amount value={row.closingDebit} /></TableCell>
                    <TableCell className="text-right"><Amount value={row.closingCredit} /></TableCell>
                  </TableRow>
                ))}
              </TableBody>
              <TableFooter>
                <TableRow>
                  <TableCell colSpan={3}>Total</TableCell>
                  <TableCell className="text-right">{formatAccountingMoney(report.totals.openingDebit)}</TableCell>
                  <TableCell className="text-right">{formatAccountingMoney(report.totals.openingCredit)}</TableCell>
                  <TableCell className="text-right">{formatAccountingMoney(report.totals.periodDebit)}</TableCell>
                  <TableCell className="text-right">{formatAccountingMoney(report.totals.periodCredit)}</TableCell>
                  <TableCell className="text-right">{formatAccountingMoney(report.totals.closingDebit)}</TableCell>
                  <TableCell className="text-right">{formatAccountingMoney(report.totals.closingCredit)}</TableCell>
                </TableRow>
              </TableFooter>
            </Table>
          </CardContent>
        </Card>
      </>
    );
  }

  if (kind === "profit-loss") {
    const report = data as ProfitLossReport;
    return (
      <>
        <div className="grid gap-4 md:grid-cols-3">
          <SummaryCard label="Total Income" value={report.totals.totalIncome} accent="text-emerald-600" />
          <SummaryCard label="Total Expenses" value={report.totals.totalExpenses} accent="text-red-600" />
          <SummaryCard label={report.totals.netProfit > 0 ? "Net Profit" : "Net Loss"} value={report.totals.netProfit || report.totals.netLoss} />
        </div>
        <div className="grid gap-4 lg:grid-cols-2">
          <Card className="rounded-lg">
            <CardHeader><CardTitle className="text-base">Income</CardTitle></CardHeader>
            <CardContent className="p-0"><GroupBlocks groups={report.income} emptyLabel="No income vouchers found." /></CardContent>
          </Card>
          <Card className="rounded-lg">
            <CardHeader><CardTitle className="text-base">Expenses</CardTitle></CardHeader>
            <CardContent className="p-0"><GroupBlocks groups={report.expenses} emptyLabel="No expense vouchers found." /></CardContent>
          </Card>
        </div>
      </>
    );
  }

  if (kind === "balance-sheet") {
    const report = data as BalanceSheetReport;
    return (
      <>
        <div className="grid gap-4 md:grid-cols-3">
          <SummaryCard label="Total Assets" value={report.totals.totalAssets} />
          <SummaryCard label="Total Liabilities" value={report.totals.totalLiabilities} />
          <Card className="rounded-lg">
            <CardContent className="p-4">
              <p className="text-sm text-muted-foreground">Status</p>
              <Badge className="mt-3" variant={report.isBalanced ? "success" : "warning"}>
                {report.isBalanced ? "Balanced" : `Difference ${formatAccountingMoney(Math.abs(report.totals.difference))}`}
              </Badge>
            </CardContent>
          </Card>
        </div>
        <div className="grid gap-4 lg:grid-cols-2">
          <Card className="rounded-lg">
            <CardHeader><CardTitle className="text-base">Assets</CardTitle></CardHeader>
            <CardContent className="p-0"><GroupBlocks groups={report.assets} emptyLabel="No asset balances found." /></CardContent>
          </Card>
          <Card className="rounded-lg">
            <CardHeader><CardTitle className="text-base">Liabilities</CardTitle></CardHeader>
            <CardContent className="p-0"><GroupBlocks groups={report.liabilities} emptyLabel="No liability balances found." /></CardContent>
          </Card>
        </div>
      </>
    );
  }

  if (kind === "cash-book" || kind === "bank-book") {
    const report = data as BookReport;
    const isBank = kind === "bank-book";
    return (
      <>
        <div className="grid gap-4 md:grid-cols-3">
          <SummaryCard label="Opening Balance" value={report.openingBalance} />
          <SummaryCard label={isBank ? "Deposits" : "Receipts"} value={isBank ? report.totals.totalDeposits || 0 : report.totals.totalReceipts || 0} />
          <SummaryCard label="Closing Balance" value={report.totals.closingBalance} />
        </div>
        <Card className="rounded-lg">
          <CardContent className="p-0">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Date</TableHead>
                  <TableHead>Voucher</TableHead>
                  {isBank && <TableHead>Bank Ledger</TableHead>}
                  <TableHead>Particulars</TableHead>
                  <TableHead>Reference</TableHead>
                  <TableHead className="text-right">{isBank ? "Deposit" : "Receipt"}</TableHead>
                  <TableHead className="text-right">{isBank ? "Withdrawal" : "Payment"}</TableHead>
                  <TableHead className="text-right">Balance</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {report.entries.map((entry) => (
                  <TableRow key={`${entry.voucherId}-${entry.ledgerId}-${entry.debit}-${entry.credit}`}>
                    <TableCell>{formatAccountingDate(entry.date)}</TableCell>
                    <TableCell>
                      <p className="font-medium">{entry.voucherNo}</p>
                      <p className="text-xs text-muted-foreground">{entry.voucherTypeCode}</p>
                    </TableCell>
                    {isBank && <TableCell>{entry.ledgerName}</TableCell>}
                    <TableCell>{entry.particulars}</TableCell>
                    <TableCell>{entry.referenceNo || "-"}</TableCell>
                    <TableCell className="text-right"><Amount value={entry.debit} /></TableCell>
                    <TableCell className="text-right"><Amount value={entry.credit} /></TableCell>
                    <TableCell className="text-right">{formatAccountingMoney(entry.balance)} {entry.balanceType === "CREDIT" ? "Cr" : "Dr"}</TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </CardContent>
        </Card>
      </>
    );
  }

  if (kind === "receivables" || kind === "payables") {
    const report = data as PartyOutstandingReport;
    const primary = kind === "receivables" ? "receivable" : "payable";
    return (
      <>
        <div className="grid gap-4 md:grid-cols-2">
          <SummaryCard label={kind === "receivables" ? "Total Receivable" : "Total Payable"} value={kind === "receivables" ? report.totals.totalReceivable || 0 : report.totals.totalPayable || 0} />
          <SummaryCard label="Advance / Debit Balance" value={report.totals.totalAdvance} />
        </div>
        <Card className="rounded-lg">
          <CardContent className="p-0">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Party Ledger</TableHead>
                  <TableHead className="text-right">Opening</TableHead>
                  <TableHead className="text-right">Debit</TableHead>
                  <TableHead className="text-right">Credit</TableHead>
                  <TableHead className="text-right">Closing</TableHead>
                  <TableHead className="text-right">Action</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {report.rows.map((row) => (
                  <TableRow key={row.ledgerId}>
                    <TableCell className="font-medium">{row.ledgerName}</TableCell>
                    <TableCell className="text-right">{formatAccountingMoney(row.openingBalance)} {row.openingBalanceType === "CREDIT" ? "Cr" : "Dr"}</TableCell>
                    <TableCell className="text-right"><Amount value={row.debit} /></TableCell>
                    <TableCell className="text-right"><Amount value={row.credit} /></TableCell>
                    <TableCell className="text-right">{formatAccountingMoney(row[primary] || row.advance)} {row.balanceType === "CREDIT" ? "Cr" : "Dr"}</TableCell>
                    <TableCell className="text-right">
                      <Button asChild variant="ghost" size="sm">
                        <Link href={`/accounting/ledgers/${row.ledgerId}`}>View Ledger</Link>
                      </Button>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </CardContent>
        </Card>
      </>
    );
  }

  if (kind === "ledger-summary") {
    const report = data as LedgerSummaryReport;
    return (
      <Card className="rounded-lg">
        <CardContent className="p-0">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Ledger</TableHead>
                <TableHead>Group</TableHead>
                <TableHead className="text-right">Opening</TableHead>
                <TableHead className="text-right">Debit</TableHead>
                <TableHead className="text-right">Credit</TableHead>
                <TableHead className="text-right">Closing</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {report.rows.map((row) => (
                <TableRow key={row.ledgerId}>
                  <TableCell>
                    <p className="font-medium">{row.ledgerName}</p>
                    <p className="text-xs text-muted-foreground">{row.code}</p>
                  </TableCell>
                  <TableCell>{row.groupName}</TableCell>
                  <TableCell className="text-right">{formatAccountingMoney(row.openingBalance)} {row.openingBalanceType === "CREDIT" ? "Cr" : "Dr"}</TableCell>
                  <TableCell className="text-right"><Amount value={row.periodDebit} /></TableCell>
                  <TableCell className="text-right"><Amount value={row.periodCredit} /></TableCell>
                  <TableCell className="text-right">{formatAccountingMoney(row.closingBalance)} {row.closingBalanceType === "CREDIT" ? "Cr" : "Dr"}</TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </CardContent>
      </Card>
    );
  }

  const report = data as GroupSummaryReport;
  return (
    <Card className="rounded-lg">
      <CardContent className="p-0">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Group</TableHead>
              <TableHead>Nature</TableHead>
              <TableHead className="text-right">Opening Dr</TableHead>
              <TableHead className="text-right">Opening Cr</TableHead>
              <TableHead className="text-right">Period Dr</TableHead>
              <TableHead className="text-right">Period Cr</TableHead>
              <TableHead className="text-right">Closing Dr</TableHead>
              <TableHead className="text-right">Closing Cr</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {report.rows.map((row) => (
              <TableRow key={row.groupId || row.groupName}>
                <TableCell>
                  <p className="font-medium">{row.groupName}</p>
                  <p className="text-xs text-muted-foreground">{row.groupCode}</p>
                </TableCell>
                <TableCell>{row.nature || "-"}</TableCell>
                <TableCell className="text-right"><Amount value={row.openingDebit} /></TableCell>
                <TableCell className="text-right"><Amount value={row.openingCredit} /></TableCell>
                <TableCell className="text-right"><Amount value={row.periodDebit} /></TableCell>
                <TableCell className="text-right"><Amount value={row.periodCredit} /></TableCell>
                <TableCell className="text-right"><Amount value={row.closingDebit} /></TableCell>
                <TableCell className="text-right"><Amount value={row.closingCredit} /></TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </CardContent>
    </Card>
  );
}

export function AccountingReportPage({ kind }: { kind: AccountingReportKind }) {
  const meta = reportMeta[kind];
  const [data, setData] = useState<ReportData | null>(null);
  const [loading, setLoading] = useState(true);
  const [startDate, setStartDate] = useState(monthStart());
  const [endDate, setEndDate] = useState(today());
  const [asOnDate, setAsOnDate] = useState(today());

  const load = useCallback(async () => {
    try {
      setLoading(true);
      const filters: Record<string, string> = meta.mode === "asOn" ? { asOnDate } : { startDate, endDate };
      setData(await fetchReport(kind, filters));
    } catch (error) {
      toast.error(getAccountingErrorMessage(error, "Failed to load accounting report"));
    } finally {
      setLoading(false);
    }
  }, [asOnDate, endDate, kind, meta.mode, startDate]);

  useEffect(() => {
    void load();
  }, [load]);

  return (
    <div className="space-y-6">
      <PageHeader title={meta.title} description={meta.description} icon={meta.icon}>
        <Button variant="outline" asChild>
          <Link href="/accounting/reports"><ArrowLeft className="h-4 w-4" /> Reports</Link>
        </Button>
        <Button variant="outline" disabled>
          <Download className="h-4 w-4" />
          Export
        </Button>
        <Button variant="outline" disabled>
          <Printer className="h-4 w-4" />
          Print
        </Button>
        <Button variant="outline" onClick={() => void load()} disabled={loading}>
          {loading ? <Loader2 className="h-4 w-4 animate-spin" /> : <RefreshCw className="h-4 w-4" />}
          Refresh
        </Button>
      </PageHeader>

      <Card className="rounded-lg">
        <CardContent className="grid gap-3 p-4 md:grid-cols-[180px_180px]">
          {meta.mode === "asOn" ? (
            <Input type="date" value={asOnDate} onChange={(event) => setAsOnDate(event.target.value)} />
          ) : (
            <>
              <Input type="date" value={startDate} onChange={(event) => setStartDate(event.target.value)} />
              <Input type="date" value={endDate} onChange={(event) => setEndDate(event.target.value)} />
            </>
          )}
        </CardContent>
      </Card>

      {loading ? (
        <LoadingPanel label={`Loading ${meta.title.toLowerCase()}...`} />
      ) : !data ? (
        <Card className="rounded-lg">
          <EmptyState icon={meta.icon} title="No report data found" description="Post accounting vouchers and refresh this report." />
        </Card>
      ) : (
        renderReport(kind, data)
      )}
    </div>
  );
}

export const accountingReportCards = Object.entries(reportMeta).map(([kind, meta]) => ({
  kind: kind as AccountingReportKind,
  ...meta,
}));
