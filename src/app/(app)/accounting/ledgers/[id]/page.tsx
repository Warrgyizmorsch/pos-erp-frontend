"use client";

import { useParams, useRouter } from "next/navigation";
import { useCallback, useEffect, useState } from "react";
import { ArrowLeft, FileText, ListCollapse, Loader2, RefreshCw, Search } from "lucide-react";
import { toast } from "sonner";
import {
  formatAccountingMoney,
  formatAccountingDate,
  getAccountingErrorMessage,
  LoadingPanel,
} from "@/components/accounting/accounting-ui";
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
import { accountingService, type LedgerStatement } from "@/services/accountingService";

const formatBalance = (amount: number, type: string) =>
  `${formatAccountingMoney(amount)} ${type === "CREDIT" ? "Cr" : "Dr"}`;

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
          <Table>
            <TableHeader className="sticky top-0 bg-card">
              <TableRow>
                <TableHead>Date</TableHead>
                <TableHead>Voucher No</TableHead>
                <TableHead>Voucher Type</TableHead>
                <TableHead>Particulars</TableHead>
                <TableHead>Narration</TableHead>
                <TableHead className="text-right">Debit</TableHead>
                <TableHead className="text-right">Credit</TableHead>
                <TableHead className="text-right">Running Balance</TableHead>
                <TableHead>Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {statement && (
                <TableRow className="bg-muted/40 font-semibold">
                  <TableCell>{startDate ? formatAccountingDate(startDate) : "-"}</TableCell>
                  <TableCell>Opening</TableCell>
                  <TableCell>-</TableCell>
                  <TableCell>Opening Balance</TableCell>
                  <TableCell>-</TableCell>
                  <TableCell className="text-right">₹0.00</TableCell>
                  <TableCell className="text-right">₹0.00</TableCell>
                  <TableCell className="text-right">{formatBalance(statement.ledger.openingBalance, statement.ledger.openingBalanceType)}</TableCell>
                  <TableCell></TableCell>
                </TableRow>
              )}
              {(statement?.entries || []).map((entry, index) => (
                <TableRow key={entry.entryId || `${entry.voucherId}-${index}`}>
                  <TableCell>{formatAccountingDate(entry.date)}</TableCell>
                  <TableCell className="font-medium">{entry.voucherNo}</TableCell>
                  <TableCell><Badge variant="outline">{entry.voucherTypeCode}</Badge></TableCell>
                  <TableCell>{entry.referenceNo || entry.voucherTypeName || "-"}</TableCell>
                  <TableCell className="max-w-[300px] truncate">{entry.narration || "-"}</TableCell>
                  <TableCell className="text-right">{formatAccountingMoney(entry.debit || 0)}</TableCell>
                  <TableCell className="text-right">{formatAccountingMoney(entry.credit || 0)}</TableCell>
                  <TableCell className="text-right font-medium">
                    {formatBalance(entry.runningBalance, entry.runningBalanceType)}
                  </TableCell>
                  <TableCell>
                    <Button variant="outline" size="icon-sm" title="View voucher">
                      <FileText className="h-4 w-4" />
                    </Button>
                  </TableCell>
                </TableRow>
              ))}
              {statement?.entries.length === 0 && (
                <TableRow>
                  <TableCell colSpan={9} className="h-28 text-center text-muted-foreground">
                    No posted voucher entries found for this ledger.
                  </TableCell>
                </TableRow>
              )}
            </TableBody>
            {statement && (
              <TableFooter>
                <TableRow>
                  <TableCell colSpan={5}>Closing Balance</TableCell>
                  <TableCell className="text-right">{formatAccountingMoney(statement.totals.totalDebit || 0)}</TableCell>
                  <TableCell className="text-right">{formatAccountingMoney(statement.totals.totalCredit || 0)}</TableCell>
                  <TableCell className="text-right">{formatBalance(statement.totals.closingBalance, statement.totals.closingBalanceType)}</TableCell>
                  <TableCell></TableCell>
                </TableRow>
              </TableFooter>
            )}
          </Table>
        </CardContent>
      </Card>
    </div>
  );
}
