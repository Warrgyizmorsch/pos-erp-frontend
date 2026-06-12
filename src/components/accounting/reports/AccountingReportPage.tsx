"use client";

import Link from "next/link";
import { Fragment, useCallback, useEffect, useState, type ReactNode } from "react";
import {
  ArrowLeft,
  BadgeIndianRupee,
  Banknote,
  BarChart3,
  BookOpen,
  ChevronDown,
  Building2,
  Download,
  File,
  FileText,
  Landmark,
  Loader2,
  Printer,
  ReceiptText,
  RefreshCw,
  Scale,
  Sheet,
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
import { Card, CardContent } from "@/components/ui/card";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
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
import { businessService } from "@/services/businessService";
import { ReportPrintDialog } from "@/components/print/ReportPrintDialog";
import type { ReportCell, ReportColumn } from "@/lib/print/templates/ReportPrintTemplate";
import {
  exportReportCsv,
  exportReportExcel,
  exportReportPdf,
  type ExportRow,
} from "@/lib/print/exportUtils";
import type { BusinessProfile } from "@/types";
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

type PreparedReport = {
  title: string;
  subtitle: string;
  filename: string;
  rows: ExportRow[];
  columns: ReportColumn[];
  totals?: ExportRow;
};

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

function Amount({ value, strong = false }: { value: number | null | undefined; strong?: boolean }) {
  return <span className={strong ? "font-semibold tabular-nums" : "tabular-nums"}>{money(value)}</span>;
}

const money = (value: number | undefined | null) => formatAccountingMoney(Number(value || 0));
const moneyOrDash = (value: number | undefined | null) => Number(value || 0) ? money(value) : "-";
const balanceText = (value: number, type?: string) => `${money(value)} ${type === "CREDIT" ? "Cr" : "Dr"}`;
const slug = (value: string) => value.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/(^-|-$)/g, "");

const columns = (items: Array<[string, string]>): ReportColumn[] => items.map(([key, label]) => ({ key, label }));

const periodSubtitle = (meta: typeof reportMeta[AccountingReportKind], data: ReportData, startDate: string, endDate: string, asOnDate: string) => {
  if ("asOnDate" in data) return `As on ${formatAccountingDate(data.asOnDate)}`;
  if (meta.mode === "asOn") return `As on ${formatAccountingDate(asOnDate)}`;
  return `${formatAccountingDate(startDate)} to ${formatAccountingDate(endDate)}`;
};

function flattenGroupRows(section: string, groups: ReportGroupAmount[]) {
  return groups.flatMap((group) => [
    {
      section,
      group: group.groupName,
      ledger: "Group Total",
      amount: money(group.total),
    },
    ...group.ledgers.map((ledger) => ({
      section,
      group: group.groupName,
      ledger: ledger.ledgerName,
      amount: money(Math.abs(ledger.amount)),
    })),
  ]);
}

function prepareAccountingReport(
  kind: AccountingReportKind,
  data: ReportData,
  meta: typeof reportMeta[AccountingReportKind],
  dates: { startDate: string; endDate: string; asOnDate: string },
): PreparedReport {
  const subtitle = periodSubtitle(meta, data, dates.startDate, dates.endDate, dates.asOnDate);
  const filename = `${slug(meta.title)}-${new Date().toISOString().slice(0, 10)}`;

  if (kind === "trial-balance") {
    const report = data as TrialBalanceReport;
    const reportColumns = columns([
      ["ledger", "Ledger"],
      ["code", "Code"],
      ["group", "Group"],
      ["nature", "Nature"],
      ["openingDebit", "Opening Dr"],
      ["openingCredit", "Opening Cr"],
      ["periodDebit", "Period Dr"],
      ["periodCredit", "Period Cr"],
      ["closingDebit", "Closing Dr"],
      ["closingCredit", "Closing Cr"],
    ]);
    return {
      title: meta.title,
      subtitle,
      filename,
      columns: reportColumns,
      rows: report.rows.map((row) => ({
        ledger: row.ledgerName,
        code: row.code,
        group: row.groupName || "-",
        nature: row.nature || "-",
        openingDebit: moneyOrDash(row.openingDebit),
        openingCredit: moneyOrDash(row.openingCredit),
        periodDebit: moneyOrDash(row.periodDebit),
        periodCredit: moneyOrDash(row.periodCredit),
        closingDebit: moneyOrDash(row.closingDebit),
        closingCredit: moneyOrDash(row.closingCredit),
      })),
      totals: {
        ledger: "TOTAL",
        code: "",
        group: "",
        nature: report.isBalanced ? "Balanced" : `Difference ${money(Math.abs(report.totals.difference))}`,
        openingDebit: money(report.totals.openingDebit),
        openingCredit: money(report.totals.openingCredit),
        periodDebit: money(report.totals.periodDebit),
        periodCredit: money(report.totals.periodCredit),
        closingDebit: money(report.totals.closingDebit),
        closingCredit: money(report.totals.closingCredit),
      },
    };
  }

  if (kind === "profit-loss") {
    const report = data as ProfitLossReport;
    const reportColumns = columns([["section", "Section"], ["group", "Group"], ["ledger", "Ledger"], ["amount", "Amount"]]);
    return {
      title: meta.title,
      subtitle,
      filename,
      columns: reportColumns,
      rows: [
        ...flattenGroupRows("Income", report.income),
        ...flattenGroupRows("Expenses", report.expenses),
      ],
      totals: {
        section: "TOTAL",
        group: `Income ${money(report.totals.totalIncome)}`,
        ledger: `Expenses ${money(report.totals.totalExpenses)}`,
        amount: report.totals.netProfit > 0 ? `Net Profit ${money(report.totals.netProfit)}` : `Net Loss ${money(report.totals.netLoss)}`,
      },
    };
  }

  if (kind === "balance-sheet") {
    const report = data as BalanceSheetReport;
    const reportColumns = columns([["section", "Section"], ["group", "Group"], ["ledger", "Ledger"], ["amount", "Amount"]]);
    return {
      title: meta.title,
      subtitle,
      filename,
      columns: reportColumns,
      rows: [
        ...flattenGroupRows("Assets", report.assets),
        ...flattenGroupRows("Liabilities", report.liabilities),
      ],
      totals: {
        section: "TOTAL",
        group: `Assets ${money(report.totals.totalAssets)}`,
        ledger: `Liabilities ${money(report.totals.totalLiabilities)}`,
        amount: report.isBalanced ? "Balanced" : `Difference ${money(Math.abs(report.totals.difference))}`,
      },
    };
  }

  if (kind === "cash-book" || kind === "bank-book") {
    const report = data as BookReport;
    const isBank = kind === "bank-book";
    const reportColumns = columns([
      ["date", "Date"],
      ["voucher", "Voucher"],
      ...(isBank ? [["bankLedger", "Bank Ledger"] as [string, string]] : []),
      ["particulars", "Particulars"],
      ["reference", "Reference"],
      ["debit", isBank ? "Deposit" : "Receipt"],
      ["credit", isBank ? "Withdrawal" : "Payment"],
      ["balance", "Balance"],
    ]);
    return {
      title: meta.title,
      subtitle,
      filename,
      columns: reportColumns,
      rows: report.entries.map((entry) => ({
        date: formatAccountingDate(entry.date),
        voucher: `${entry.voucherNo} (${entry.voucherTypeCode})`,
        ...(isBank ? { bankLedger: entry.ledgerName } : {}),
        particulars: entry.particulars,
        reference: entry.referenceNo || "-",
        debit: moneyOrDash(entry.debit),
        credit: moneyOrDash(entry.credit),
        balance: balanceText(entry.balance, entry.balanceType),
      })),
      totals: {
        date: "TOTAL",
        voucher: "",
        ...(isBank ? { bankLedger: "" } : {}),
        particulars: `Opening ${balanceText(report.openingBalance, report.openingBalanceType)}`,
        reference: "",
        debit: money(isBank ? report.totals.totalDeposits || 0 : report.totals.totalReceipts || 0),
        credit: money(isBank ? report.totals.totalWithdrawals || 0 : report.totals.totalPayments || 0),
        balance: balanceText(report.totals.closingBalance, report.totals.closingBalanceType),
      },
    };
  }

  if (kind === "receivables" || kind === "payables") {
    const report = data as PartyOutstandingReport;
    const primary = kind === "receivables" ? "receivable" : "payable";
    const reportColumns = columns([
      ["ledger", "Party Ledger"],
      ["opening", "Opening"],
      ["debit", "Debit"],
      ["credit", "Credit"],
      ["closing", "Closing"],
      ["advance", "Advance / Debit Balance"],
    ]);
    return {
      title: meta.title,
      subtitle,
      filename,
      columns: reportColumns,
      rows: report.rows.map((row) => ({
        ledger: row.ledgerName,
        opening: balanceText(row.openingBalance, row.openingBalanceType),
        debit: moneyOrDash(row.debit),
        credit: moneyOrDash(row.credit),
        closing: balanceText(row[primary] || row.advance, row.balanceType),
        advance: moneyOrDash(row.advance),
      })),
      totals: {
        ledger: "TOTAL",
        opening: "",
        debit: "",
        credit: "",
        closing: money(kind === "receivables" ? report.totals.totalReceivable || 0 : report.totals.totalPayable || 0),
        advance: money(report.totals.totalAdvance),
      },
    };
  }

  if (kind === "ledger-summary") {
    const report = data as LedgerSummaryReport;
    const reportColumns = columns([
      ["ledger", "Ledger"],
      ["code", "Code"],
      ["group", "Group"],
      ["opening", "Opening"],
      ["debit", "Debit"],
      ["credit", "Credit"],
      ["closing", "Closing"],
    ]);
    return {
      title: meta.title,
      subtitle,
      filename,
      columns: reportColumns,
      rows: report.rows.map((row) => ({
        ledger: row.ledgerName,
        code: row.code,
        group: row.groupName || "-",
        opening: balanceText(row.openingBalance, row.openingBalanceType),
        debit: moneyOrDash(row.periodDebit),
        credit: moneyOrDash(row.periodCredit),
        closing: balanceText(row.closingBalance, row.closingBalanceType),
      })),
    };
  }

  const report = data as GroupSummaryReport;
  return {
    title: meta.title,
    subtitle,
    filename,
    columns: columns([
      ["group", "Group"],
      ["code", "Code"],
      ["nature", "Nature"],
      ["openingDebit", "Opening Dr"],
      ["openingCredit", "Opening Cr"],
      ["periodDebit", "Period Dr"],
      ["periodCredit", "Period Cr"],
      ["closingDebit", "Closing Dr"],
      ["closingCredit", "Closing Cr"],
    ]),
    rows: report.rows.map((row) => ({
      group: row.groupName,
      code: row.groupCode || "-",
      nature: row.nature || "-",
      openingDebit: moneyOrDash(row.openingDebit),
      openingCredit: moneyOrDash(row.openingCredit),
      periodDebit: moneyOrDash(row.periodDebit),
      periodCredit: moneyOrDash(row.periodCredit),
      closingDebit: moneyOrDash(row.closingDebit),
      closingCredit: moneyOrDash(row.closingCredit),
    })),
  };
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

const rowTone = {
  group: "bg-muted/40 font-semibold",
  subtotal: "bg-muted/20 font-semibold",
  total: "bg-muted/60 font-bold",
  result: "bg-primary/5 font-bold",
};

function rightCell(value: number | null | undefined, strong = false) {
  return <TableCell className="text-right"><Amount value={value} strong={strong} /></TableCell>;
}

function ReportTableCard({ children }: { children: ReactNode }) {
  return (
    <Card className="rounded-lg">
      <CardContent className="overflow-x-auto p-0">
        {children}
      </CardContent>
    </Card>
  );
}

function EmptyReportCard({ title }: { title: string }) {
  return (
    <Card className="rounded-lg">
      <EmptyState icon={FileText} title={title} description="No accounting rows found for the selected period." />
    </Card>
  );
}

type StatementLine = {
  label: string;
  amount: number;
  code?: string;
  kind?: "group" | "ledger" | "subtotal" | "result";
};

function statementLines(groups: ReportGroupAmount[], result?: StatementLine) {
  const lines: StatementLine[] = [];
  groups.forEach((group) => {
    lines.push({ label: group.groupName || "Unmapped Group", amount: group.total, kind: "group" });
    group.ledgers.forEach((ledger) => {
      lines.push({
        label: ledger.ledgerName || "Unmapped Ledger",
        code: ledger.code,
        amount: Math.abs(Number(ledger.amount || 0)),
        kind: "ledger",
      });
    });
    lines.push({ label: `Subtotal ${group.groupName || "Group"}`, amount: group.total, kind: "subtotal" });
  });
  if (result) lines.push(result);
  return lines;
}

function TwoColumnStatement({
  leftTitle,
  rightTitle,
  left,
  right,
  leftTotal,
  rightTotal,
}: {
  leftTitle: string;
  rightTitle: string;
  left: StatementLine[];
  right: StatementLine[];
  leftTotal: number;
  rightTotal: number;
}) {
  const maxRows = Math.max(left.length, right.length);
  const rows = Array.from({ length: maxRows }, (_, index) => ({ left: left[index], right: right[index] }));

  return (
    <ReportTableCard>
      <Table>
        <TableHeader className="sticky top-0 bg-card">
          <TableRow>
            <TableHead>{leftTitle}</TableHead>
            <TableHead className="text-right">Amount</TableHead>
            <TableHead>{rightTitle}</TableHead>
            <TableHead className="text-right">Amount</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {rows.length === 0 ? (
            <TableRow><TableCell colSpan={4} className="py-8 text-center text-muted-foreground">No statement rows found.</TableCell></TableRow>
          ) : rows.map((row, index) => (
            <TableRow key={index}>
              <TableCell className={[
                row.left?.kind === "group" ? rowTone.group : "",
                row.left?.kind === "subtotal" ? rowTone.subtotal : "",
                row.left?.kind === "result" ? rowTone.result : "",
              ].filter(Boolean).join(" ")}>
                {row.left ? (
                  <div className={row.left.kind === "ledger" ? "pl-5" : ""}>
                    <p className={row.left.kind === "ledger" ? "font-medium" : ""}>{row.left.label}</p>
                    {row.left.code && <p className="text-xs text-muted-foreground">{row.left.code}</p>}
                  </div>
                ) : null}
              </TableCell>
              <TableCell className={[
                "text-right",
                row.left?.kind === "group" ? rowTone.group : "",
                row.left?.kind === "subtotal" ? rowTone.subtotal : "",
                row.left?.kind === "result" ? rowTone.result : "",
              ].filter(Boolean).join(" ")}>{row.left ? <Amount value={row.left.amount} strong={row.left.kind !== "ledger"} /> : null}</TableCell>
              <TableCell className={[
                row.right?.kind === "group" ? rowTone.group : "",
                row.right?.kind === "subtotal" ? rowTone.subtotal : "",
                row.right?.kind === "result" ? rowTone.result : "",
              ].filter(Boolean).join(" ")}>
                {row.right ? (
                  <div className={row.right.kind === "ledger" ? "pl-5" : ""}>
                    <p className={row.right.kind === "ledger" ? "font-medium" : ""}>{row.right.label}</p>
                    {row.right.code && <p className="text-xs text-muted-foreground">{row.right.code}</p>}
                  </div>
                ) : null}
              </TableCell>
              <TableCell className={[
                "text-right",
                row.right?.kind === "group" ? rowTone.group : "",
                row.right?.kind === "subtotal" ? rowTone.subtotal : "",
                row.right?.kind === "result" ? rowTone.result : "",
              ].filter(Boolean).join(" ")}>{row.right ? <Amount value={row.right.amount} strong={row.right.kind !== "ledger"} /> : null}</TableCell>
            </TableRow>
          ))}
        </TableBody>
        <TableFooter>
          <TableRow>
            <TableCell>Total {leftTitle}</TableCell>
            <TableCell className="text-right">{money(leftTotal)}</TableCell>
            <TableCell>Total {rightTitle}</TableCell>
            <TableCell className="text-right">{money(rightTotal)}</TableCell>
          </TableRow>
        </TableFooter>
      </Table>
    </ReportTableCard>
  );
}

function groupTrialRows(rows: TrialBalanceReport["rows"]) {
  const groups = new Map<string, TrialBalanceReport["rows"]>();
  rows.forEach((row) => {
    const key = row.groupName || "Unmapped Group";
    groups.set(key, [...(groups.get(key) || []), row]);
  });
  return Array.from(groups.entries()).map(([groupName, ledgers]) => ({
    groupName,
    ledgers,
    totals: ledgers.reduce((acc, row) => ({
      openingDebit: acc.openingDebit + Number(row.openingDebit || 0),
      openingCredit: acc.openingCredit + Number(row.openingCredit || 0),
      periodDebit: acc.periodDebit + Number(row.periodDebit || 0),
      periodCredit: acc.periodCredit + Number(row.periodCredit || 0),
      closingDebit: acc.closingDebit + Number(row.closingDebit || 0),
      closingCredit: acc.closingCredit + Number(row.closingCredit || 0),
    }), { openingDebit: 0, openingCredit: 0, periodDebit: 0, periodCredit: 0, closingDebit: 0, closingCredit: 0 }),
  }));
}

function renderReport(kind: AccountingReportKind, data: ReportData) {
  if (kind === "trial-balance") {
    const report = data as TrialBalanceReport;
    const groups = groupTrialRows(report.rows);
    if (!report.rows.length) return <EmptyReportCard title="No trial balance rows found" />;
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
        <ReportTableCard>
            <Table>
              <TableHeader className="sticky top-0 bg-card">
                <TableRow>
                  <TableHead>Particulars</TableHead>
                  <TableHead className="text-right">Opening Dr</TableHead>
                  <TableHead className="text-right">Opening Cr</TableHead>
                  <TableHead className="text-right">Transaction Dr</TableHead>
                  <TableHead className="text-right">Transaction Cr</TableHead>
                  <TableHead className="text-right">Closing Dr</TableHead>
                  <TableHead className="text-right">Closing Cr</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {groups.map((group) => (
                  <Fragment key={group.groupName}>
                    <TableRow className={rowTone.group}>
                      <TableCell>{group.groupName}</TableCell>
                      {rightCell(group.totals.openingDebit, true)}
                      {rightCell(group.totals.openingCredit, true)}
                      {rightCell(group.totals.periodDebit, true)}
                      {rightCell(group.totals.periodCredit, true)}
                      {rightCell(group.totals.closingDebit, true)}
                      {rightCell(group.totals.closingCredit, true)}
                    </TableRow>
                    {group.ledgers.map((row) => (
                      <TableRow key={row.ledgerId}>
                        <TableCell className="pl-8">
                          <p className="font-medium">{row.ledgerName || "Unmapped Ledger"}</p>
                          <p className="text-xs text-muted-foreground">{row.code || "-"} · {row.nature || "-"}</p>
                        </TableCell>
                        {rightCell(row.openingDebit)}
                        {rightCell(row.openingCredit)}
                        {rightCell(row.periodDebit)}
                        {rightCell(row.periodCredit)}
                        {rightCell(row.closingDebit)}
                        {rightCell(row.closingCredit)}
                      </TableRow>
                    ))}
                    <TableRow className={rowTone.subtotal}>
                      <TableCell>Subtotal {group.groupName}</TableCell>
                      {rightCell(group.totals.openingDebit, true)}
                      {rightCell(group.totals.openingCredit, true)}
                      {rightCell(group.totals.periodDebit, true)}
                      {rightCell(group.totals.periodCredit, true)}
                      {rightCell(group.totals.closingDebit, true)}
                      {rightCell(group.totals.closingCredit, true)}
                    </TableRow>
                  </Fragment>
                ))}
              </TableBody>
              <TableFooter>
                <TableRow>
                  <TableCell>Grand Total</TableCell>
                  <TableCell className="text-right">{formatAccountingMoney(report.totals.openingDebit)}</TableCell>
                  <TableCell className="text-right">{formatAccountingMoney(report.totals.openingCredit)}</TableCell>
                  <TableCell className="text-right">{formatAccountingMoney(report.totals.periodDebit)}</TableCell>
                  <TableCell className="text-right">{formatAccountingMoney(report.totals.periodCredit)}</TableCell>
                  <TableCell className="text-right">{formatAccountingMoney(report.totals.closingDebit)}</TableCell>
                  <TableCell className="text-right">{formatAccountingMoney(report.totals.closingCredit)}</TableCell>
                </TableRow>
                {!report.isBalanced && (
                  <TableRow>
                    <TableCell>Difference</TableCell>
                    <TableCell colSpan={5}></TableCell>
                    <TableCell className="text-right">{formatAccountingMoney(Math.abs(report.totals.difference))}</TableCell>
                  </TableRow>
                )}
              </TableFooter>
            </Table>
        </ReportTableCard>
      </>
    );
  }

  if (kind === "profit-loss") {
    const report = data as ProfitLossReport;
    const expenses = statementLines(report.expenses, report.totals.netProfit > 0 ? { label: "Net Profit", amount: report.totals.netProfit, kind: "result" } : undefined);
    const income = statementLines(report.income, report.totals.netLoss > 0 ? { label: "Net Loss", amount: report.totals.netLoss, kind: "result" } : undefined);
    return (
      <>
        <div className="grid gap-4 md:grid-cols-3">
          <SummaryCard label="Total Income" value={report.totals.totalIncome} accent="text-emerald-600" />
          <SummaryCard label="Total Expenses" value={report.totals.totalExpenses} accent="text-red-600" />
          <SummaryCard label={report.totals.netProfit > 0 ? "Net Profit" : "Net Loss"} value={report.totals.netProfit || report.totals.netLoss} />
        </div>
        <TwoColumnStatement
          leftTitle="Expenses"
          rightTitle="Income"
          left={expenses}
          right={income}
          leftTotal={report.totals.totalExpenses + Math.max(report.totals.netProfit || 0, 0)}
          rightTotal={report.totals.totalIncome + Math.max(report.totals.netLoss || 0, 0)}
        />
      </>
    );
  }

  if (kind === "balance-sheet") {
    const report = data as BalanceSheetReport;
    const liabilities = statementLines(report.liabilities);
    const assets = statementLines(report.assets);
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
        <TwoColumnStatement
          leftTitle="Liabilities"
          rightTitle="Assets"
          left={liabilities}
          right={assets}
          leftTotal={report.totals.totalLiabilities}
          rightTotal={report.totals.totalAssets}
        />
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
        <ReportTableCard>
            <Table>
              <TableHeader className="sticky top-0 bg-card">
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
                <TableRow className={rowTone.group}>
                  <TableCell>{formatAccountingDate(report.period.startDate || "")}</TableCell>
                  <TableCell>Opening</TableCell>
                  {isBank && <TableCell>{report.ledgers?.[0]?.ledgerName || "All Bank Accounts"}</TableCell>}
                  <TableCell>Opening Balance</TableCell>
                  <TableCell>-</TableCell>
                  <TableCell className="text-right">-</TableCell>
                  <TableCell className="text-right">-</TableCell>
                  <TableCell className="text-right">{balanceText(report.openingBalance, report.openingBalanceType)}</TableCell>
                </TableRow>
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
                <TableRow className={rowTone.total}>
                  <TableCell colSpan={isBank ? 5 : 4}>Closing Balance</TableCell>
                  <TableCell className="text-right">{money(isBank ? report.totals.totalDeposits || 0 : report.totals.totalReceipts || 0)}</TableCell>
                  <TableCell className="text-right">{money(isBank ? report.totals.totalWithdrawals || 0 : report.totals.totalPayments || 0)}</TableCell>
                  <TableCell className="text-right">{balanceText(report.totals.closingBalance, report.totals.closingBalanceType)}</TableCell>
                </TableRow>
              </TableBody>
            </Table>
        </ReportTableCard>
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
        <ReportTableCard>
            <Table>
              <TableHeader className="sticky top-0 bg-card">
                <TableRow>
                  <TableHead>{kind === "receivables" ? "Customer" : "Supplier"}</TableHead>
                  <TableHead className="text-right">Opening</TableHead>
                  <TableHead className="text-right">{kind === "receivables" ? "Sales" : "Purchases"}</TableHead>
                  <TableHead className="text-right">{kind === "receivables" ? "Receipts" : "Payments"}</TableHead>
                  <TableHead className="text-right">Returns / Adjustments</TableHead>
                  <TableHead className="text-right">{kind === "receivables" ? "Closing Receivable" : "Closing Payable"}</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead className="text-right">Action</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {report.rows.map((row) => (
                  <TableRow key={row.ledgerId}>
                    <TableCell className="font-medium">{row.ledgerName}</TableCell>
                    <TableCell className="text-right">{formatAccountingMoney(row.openingBalance)} {row.openingBalanceType === "CREDIT" ? "Cr" : "Dr"}</TableCell>
                    <TableCell className="text-right"><Amount value={kind === "receivables" ? row.debit : row.credit} /></TableCell>
                    <TableCell className="text-right"><Amount value={kind === "receivables" ? row.credit : row.debit} /></TableCell>
                    <TableCell className="text-right">₹0.00</TableCell>
                    <TableCell className="text-right">{formatAccountingMoney(row[primary] || row.advance)} {row.balanceType === "CREDIT" ? "Cr" : "Dr"}</TableCell>
                    <TableCell>
                      <Badge variant={row.advance > 0 ? "secondary" : "outline"}>{row.advance > 0 ? "Advance" : row[primary] ? "Due" : "Clear"}</Badge>
                    </TableCell>
                    <TableCell className="text-right">
                      <Button asChild variant="ghost" size="sm">
                        <Link href={`/accounting/ledgers/${row.ledgerId}`}>View Ledger</Link>
                      </Button>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
              <TableFooter>
                <TableRow>
                  <TableCell>Total</TableCell>
                  <TableCell></TableCell>
                  <TableCell></TableCell>
                  <TableCell></TableCell>
                  <TableCell></TableCell>
                  <TableCell className="text-right">{money(kind === "receivables" ? report.totals.totalReceivable || 0 : report.totals.totalPayable || 0)}</TableCell>
                  <TableCell>Advance {money(report.totals.totalAdvance)}</TableCell>
                  <TableCell></TableCell>
                </TableRow>
              </TableFooter>
            </Table>
        </ReportTableCard>
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
  const [exporting, setExporting] = useState(false);
  const [printOpen, setPrintOpen] = useState(false);
  const [printReport, setPrintReport] = useState<PreparedReport | null>(null);
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
    const timer = window.setTimeout(() => {
      void load();
    }, 0);
    return () => window.clearTimeout(timer);
  }, [load]);

  const prepareCurrentReport = () => {
    if (!data) return null;
    return prepareAccountingReport(kind, data, meta, { startDate, endDate, asOnDate });
  };

  const handleExport = async (format: "csv" | "excel" | "pdf" | "print") => {
    const prepared = prepareCurrentReport();
    if (!prepared) {
      toast.error("Load report data before exporting");
      return;
    }

    try {
      setExporting(true);
      if (format === "print") {
        setPrintReport(prepared);
        setPrintOpen(true);
        return;
      }

      const business: BusinessProfile | undefined = await businessService.getProfile().catch(() => undefined);
      const context = {
        title: prepared.title,
        filename: prepared.filename,
        dateRange: prepared.subtitle,
        business,
        totals: prepared.totals,
      };

      if (format === "csv") exportReportCsv(prepared.rows, context);
      if (format === "excel") await exportReportExcel(prepared.rows, context);
      if (format === "pdf") await exportReportPdf(prepared.rows, context);
      toast.success(`${prepared.title} exported as ${format.toUpperCase()}`);
    } catch (error) {
      toast.error(getAccountingErrorMessage(error, "Failed to export report"));
    } finally {
      setExporting(false);
    }
  };

  return (
    <div className="space-y-6">
      <PageHeader title={meta.title} description={meta.description} icon={meta.icon}>
        <Button variant="outline" asChild>
          <Link href="/accounting/reports"><ArrowLeft className="h-4 w-4" /> Reports</Link>
        </Button>
        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <Button variant="outline" disabled={loading || exporting || !data}>
              {exporting ? <Loader2 className="h-4 w-4 animate-spin" /> : <Download className="h-4 w-4" />}
              Export
              <ChevronDown className="h-4 w-4" />
            </Button>
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end">
            <DropdownMenuItem onClick={() => void handleExport("excel")}>
              <Sheet className="mr-2 h-4 w-4" /> Excel (.xlsx)
            </DropdownMenuItem>
            <DropdownMenuItem onClick={() => void handleExport("pdf")}>
              <FileText className="mr-2 h-4 w-4" /> PDF
            </DropdownMenuItem>
            <DropdownMenuItem onClick={() => void handleExport("csv")}>
              <File className="mr-2 h-4 w-4" /> CSV
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
        <Button variant="outline" disabled={loading || !data} onClick={() => void handleExport("print")}>
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
      <ReportPrintDialog
        open={printOpen}
        onOpenChange={setPrintOpen}
        title={printReport?.title || meta.title}
        subtitle={printReport?.subtitle}
        columns={printReport?.columns || []}
        rows={(printReport?.rows || []) as Record<string, ReportCell>[]}
        totals={printReport?.totals as Record<string, ReportCell> | undefined}
      />
    </div>
  );
}

export const accountingReportCards = Object.entries(reportMeta).map(([kind, meta]) => ({
  kind: kind as AccountingReportKind,
  ...meta,
}));
