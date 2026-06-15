"use client";

import { useParams, useRouter } from "next/navigation";
import { useCallback, useEffect, useState } from "react";
import { ArrowLeft, ListCollapse, Loader2, RefreshCw, Search } from "lucide-react";
import { toast } from "sonner";
import {
  formatAccountingMoney,
  formatAccountingDate,
  getAccountingErrorMessage,
  LoadingPanel,
} from "@/components/accounting/accounting-ui";
import { PageHeader } from "@/components/shared/PageHeader";
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
import { accountingService, type LedgerStatement } from "@/services/accountingService";

const formatBalance = (amount: number, type: string) =>
  `${formatAccountingMoney(amount)} ${type === "CREDIT" ? "Cr" : "Dr"}`;

type LedgerSideLine = {
  date: string;
  particulars: string;
  amount: number;
  meta?: string;
  kind?: "opening" | "entry" | "closing";
};

const hasAmount = (amount: number | null | undefined) => Math.abs(Number(amount || 0)) > 0.009;

const entryParticulars = (entry: LedgerStatement["entries"][number]) =>
  entry.referenceNo || entry.voucherTypeName || entry.narration || entry.voucherNo || "-";

function buildLedgerSides(statement: LedgerStatement, startDate: string) {
  const debit: LedgerSideLine[] = [];
  const credit: LedgerSideLine[] = [];
  const openingDate = startDate || statement.entries[0]?.date || "";

  if (hasAmount(statement.ledger.openingBalance)) {
    const openingLine = {
      date: openingDate,
      particulars: "Opening Balance",
      amount: statement.ledger.openingBalance,
      kind: "opening" as const,
    };

    if (statement.ledger.openingBalanceType === "CREDIT") credit.push(openingLine);
    else debit.push(openingLine);
  }

  statement.entries.forEach((entry) => {
    const base = {
      date: entry.date,
      particulars: entryParticulars(entry),
      meta: `${entry.voucherNo} · ${entry.voucherTypeCode}`,
      kind: "entry" as const,
    };

    if (hasAmount(entry.debit)) debit.push({ ...base, amount: entry.debit });
    if (hasAmount(entry.credit)) credit.push({ ...base, amount: entry.credit });
  });

  if (hasAmount(statement.totals.closingBalance)) {
    const closingLine = {
      date: endOfStatementDate(statement),
      particulars: "Closing Balance",
      amount: statement.totals.closingBalance,
      kind: "closing" as const,
    };

    if (statement.totals.closingBalanceType === "DEBIT") credit.push(closingLine);
    else debit.push(closingLine);
  }

  const debitTotal = debit.reduce((total, line) => total + Number(line.amount || 0), 0);
  const creditTotal = credit.reduce((total, line) => total + Number(line.amount || 0), 0);

  return {
    debit,
    credit,
    debitTotal,
    creditTotal,
  };
}

function endOfStatementDate(statement: LedgerStatement) {
  return statement.entries.at(-1)?.date || "";
}

function LedgerSideCell({ line }: { line?: LedgerSideLine }) {
  if (!line) return null;

  return (
    <div className={line.kind === "entry" ? "" : "font-semibold"}>
      <p>{line.particulars}</p>
      {line.meta && <p className="text-xs text-muted-foreground">{line.meta}</p>}
    </div>
  );
}

export default function LedgerStatementPage() {
  const router = useRouter();
  const params = useParams<{ id: string }>();
  const ledgerId = params.id;
  const [statement, setStatement] = useState<LedgerStatement | null>(null);
  const [loading, setLoading] = useState(true);
  const [startDate, setStartDate] = useState("");
  const [endDate, setEndDate] = useState("");
  const [voucherTypeCode, setVoucherTypeCode] = useState("");
  const [search, setSearch] = useState("");

  const loadStatement = useCallback(async () => {
    try {
      setLoading(true);
      const data = await accountingService.getLedgerStatement(ledgerId, {
        startDate,
        endDate,
        voucherTypeCode,
        search,
      });
      setStatement(data);
    } catch (error) {
      toast.error(getAccountingErrorMessage(error, "Failed to load ledger statement"));
    } finally {
      setLoading(false);
    }
  }, [endDate, ledgerId, search, startDate, voucherTypeCode]);

  useEffect(() => {
    const timer = window.setTimeout(() => {
      void loadStatement();
    }, 0);
    return () => window.clearTimeout(timer);
  }, [loadStatement]);

  if (loading && !statement) {
    return <LoadingPanel label="Loading ledger statement..." />;
  }

  const ledger = statement?.ledger;
  const ledgerSides = statement ? buildLedgerSides(statement, startDate) : null;
  const ledgerRows = ledgerSides
    ? Array.from(
      { length: Math.max(ledgerSides.debit.length, ledgerSides.credit.length) },
      (_, index) => ({ debit: ledgerSides.debit[index], credit: ledgerSides.credit[index] }),
    )
    : [];

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <Button variant="ghost" onClick={() => router.back()} className="gap-2">
          <ArrowLeft className="h-4 w-4" /> Back to Ledgers
        </Button>
      </div>
      <PageHeader
        title="Ledger Statement"
        description={ledger ? `${ledger.name} · ${ledger.code}` : "Ledger entries and running balance"}
        icon={ListCollapse}
      >
        <Button variant="outline" onClick={() => void loadStatement()} disabled={loading}>
          {loading ? <Loader2 className="h-4 w-4 animate-spin" /> : <RefreshCw className="h-4 w-4" />}
          Refresh
        </Button>
      </PageHeader>

      {ledger && (
        <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-5">
          <Card className="rounded-lg xl:col-span-2">
            <CardHeader><CardTitle>{ledger.name}</CardTitle></CardHeader>
            <CardContent className="space-y-2 text-sm">
              <p><span className="text-muted-foreground">Code:</span> {ledger.code}</p>
              <p><span className="text-muted-foreground">Group:</span> {ledger.group?.name || "-"}</p>
              <p><span className="text-muted-foreground">Nature:</span> {ledger.nature || ledger.group?.nature || "-"}</p>
            </CardContent>
          </Card>
          <Card className="rounded-lg">
            <CardContent className="p-5">
              <p className="text-sm text-muted-foreground">Opening Balance</p>
              <p className="mt-2 font-semibold">{formatBalance(ledger.openingBalance, ledger.openingBalanceType)}</p>
            </CardContent>
          </Card>
          <Card className="rounded-lg">
            <CardContent className="p-5">
              <p className="text-sm text-muted-foreground">Current Balance</p>
              <p className="mt-2 font-semibold">{formatBalance(ledger.currentBalance, ledger.currentBalanceType)}</p>
            </CardContent>
          </Card>
          <Card className="rounded-lg">
            <CardContent className="p-5">
              <p className="text-sm text-muted-foreground">Closing Balance</p>
              <p className="mt-2 font-semibold">
                {statement ? formatBalance(statement.totals.closingBalance, statement.totals.closingBalanceType) : "-"}
              </p>
            </CardContent>
          </Card>
        </div>
      )}

      <Card className="rounded-lg">
        <CardContent className="grid gap-3 p-4 md:grid-cols-5">
          <Input type="date" value={startDate} onChange={(event) => setStartDate(event.target.value)} />
          <Input type="date" value={endDate} onChange={(event) => setEndDate(event.target.value)} />
          <Input
            value={voucherTypeCode}
            onChange={(event) => setVoucherTypeCode(event.target.value.toUpperCase())}
            placeholder="Voucher type"
          />
          <div className="relative md:col-span-2">
            <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
            <Input
              value={search}
              onChange={(event) => setSearch(event.target.value)}
              placeholder="Search voucher, reference, narration..."
              className="pl-9"
            />
          </div>
        </CardContent>
      </Card>

      <Card className="rounded-lg">
        <CardContent className="overflow-x-auto p-0">
          <Table className="min-w-[920px] table-fixed">
            <TableHeader className="sticky top-0 bg-card">
              <TableRow>
                <TableHead colSpan={3} className="border-r border-border text-center font-semibold text-foreground">
                  Debit
                </TableHead>
                <TableHead colSpan={3} className="text-center font-semibold text-foreground">
                  Credit
                </TableHead>
              </TableRow>
              <TableRow>
                <TableHead className="w-[12%]">Date</TableHead>
                <TableHead className="w-[28%]">Particulars</TableHead>
                <TableHead className="w-[10%] border-r border-border text-right">Amount</TableHead>
                <TableHead className="w-[12%]">Date</TableHead>
                <TableHead className="w-[28%]">Particulars</TableHead>
                <TableHead className="w-[10%] text-right">Amount</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {ledgerRows.map((row, index) => (
                <TableRow key={`${row.debit?.date || "debit"}-${row.credit?.date || "credit"}-${index}`}>
                  <TableCell className={[
                    "px-4 py-2 align-top",
                    row.debit?.kind === "opening" ? "bg-muted/40 font-semibold" : "",
                    row.debit?.kind === "closing" ? "border-t border-border bg-muted/20 font-semibold" : "",
                  ].filter(Boolean).join(" ")}
                  >
                    {row.debit ? formatAccountingDate(row.debit.date) : null}
                  </TableCell>
                  <TableCell className={[
                    "px-4 py-2 align-top",
                    row.debit?.kind === "opening" ? "bg-muted/40 font-semibold" : "",
                    row.debit?.kind === "closing" ? "border-t border-border bg-muted/20 font-semibold" : "",
                  ].filter(Boolean).join(" ")}
                  >
                    <LedgerSideCell line={row.debit} />
                  </TableCell>
                  <TableCell className={[
                    "border-r border-border px-4 py-2 text-right align-top tabular-nums",
                    row.debit?.kind === "opening" ? "bg-muted/40 font-semibold" : "",
                    row.debit?.kind === "closing" ? "border-t border-border bg-muted/20 font-semibold" : "",
                  ].filter(Boolean).join(" ")}
                  >
                    {row.debit ? formatAccountingMoney(row.debit.amount) : null}
                  </TableCell>
                  <TableCell className={[
                    "px-4 py-2 align-top",
                    row.credit?.kind === "opening" ? "bg-muted/40 font-semibold" : "",
                    row.credit?.kind === "closing" ? "border-t border-border bg-muted/20 font-semibold" : "",
                  ].filter(Boolean).join(" ")}
                  >
                    {row.credit ? formatAccountingDate(row.credit.date) : null}
                  </TableCell>
                  <TableCell className={[
                    "px-4 py-2 align-top",
                    row.credit?.kind === "opening" ? "bg-muted/40 font-semibold" : "",
                    row.credit?.kind === "closing" ? "border-t border-border bg-muted/20 font-semibold" : "",
                  ].filter(Boolean).join(" ")}
                  >
                    <LedgerSideCell line={row.credit} />
                  </TableCell>
                  <TableCell className={[
                    "px-4 py-2 text-right align-top tabular-nums",
                    row.credit?.kind === "opening" ? "bg-muted/40 font-semibold" : "",
                    row.credit?.kind === "closing" ? "border-t border-border bg-muted/20 font-semibold" : "",
                  ].filter(Boolean).join(" ")}
                  >
                    {row.credit ? formatAccountingMoney(row.credit.amount) : null}
                  </TableCell>
                </TableRow>
              ))}
              {statement && ledgerRows.length === 0 && (
                <TableRow>
                  <TableCell colSpan={6} className="h-28 text-center text-muted-foreground">
                    No posted voucher entries found for this ledger.
                  </TableCell>
                </TableRow>
              )}
            </TableBody>
            {statement && ledgerSides && (
              <TableFooter>
                <TableRow className="border-t-2 border-border font-bold">
                  <TableCell colSpan={2}>Total Debit</TableCell>
                  <TableCell className="border-r border-border text-right tabular-nums">
                    {formatAccountingMoney(ledgerSides.debitTotal)}
                  </TableCell>
                  <TableCell colSpan={2}>Total Credit</TableCell>
                  <TableCell className="text-right tabular-nums">
                    {formatAccountingMoney(ledgerSides.creditTotal)}
                  </TableCell>
                </TableRow>
                {hasAmount(Math.abs(ledgerSides.debitTotal - ledgerSides.creditTotal)) && (
                  <TableRow>
                    <TableCell colSpan={5}>Difference</TableCell>
                    <TableCell className="text-right tabular-nums">
                      {formatAccountingMoney(Math.abs(ledgerSides.debitTotal - ledgerSides.creditTotal))}
                    </TableCell>
                  </TableRow>
                )}
              </TableFooter>
            )}
          </Table>
        </CardContent>
      </Card>
    </div>
  );
}
