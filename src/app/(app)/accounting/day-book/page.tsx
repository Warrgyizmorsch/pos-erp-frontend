"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import { BookOpen, FileText, Loader2, RefreshCw, Search } from "lucide-react";
import { toast } from "sonner";
import {
  formatAccountingDate,
  formatAccountingMoney,
  getAccountingErrorMessage,
  LoadingPanel,
  voucherStatusVariant,
} from "@/components/accounting/accounting-ui";
import { AccountingExportActions } from "@/components/accounting/AccountingExportActions";
import { PageHeader } from "@/components/shared/PageHeader";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  Table,
  TableBody,
  TableCell,
  TableFooter,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { accountingService, type DayBook, type Ledger, type VoucherType } from "@/services/accountingService";

const allValue = "ALL";

export default function DayBookPage() {
  const [dayBook, setDayBook] = useState<DayBook | null>(null);
  const [ledgers, setLedgers] = useState<Ledger[]>([]);
  const [voucherTypes, setVoucherTypes] = useState<VoucherType[]>([]);
  const [loading, setLoading] = useState(true);
  const [startDate, setStartDate] = useState("");
  const [endDate, setEndDate] = useState("");
  const [voucherTypeCode, setVoucherTypeCode] = useState(allValue);
  const [ledgerId, setLedgerId] = useState(allValue);
  const [search, setSearch] = useState("");

  const loadDayBook = useCallback(async () => {
    try {
      setLoading(true);
      const data = await accountingService.getDayBook({
        startDate,
        endDate,
        voucherTypeCode: voucherTypeCode === allValue ? undefined : voucherTypeCode,
        ledgerId: ledgerId === allValue ? undefined : ledgerId,
        search,
      });
      setDayBook(data);
    } catch (error) {
      toast.error(getAccountingErrorMessage(error, "Failed to load day book"));
    } finally {
      setLoading(false);
    }
  }, [endDate, ledgerId, search, startDate, voucherTypeCode]);

  useEffect(() => {
    const timer = window.setTimeout(() => {
      void loadDayBook();
    }, 0);
    return () => window.clearTimeout(timer);
  }, [loadDayBook]);

  useEffect(() => {
    const loadFilters = async () => {
      try {
        const [nextLedgers, nextTypes] = await Promise.all([
          accountingService.getLedgers({ isActive: true }),
          accountingService.getVoucherTypes(),
        ]);
        setLedgers(nextLedgers);
        setVoucherTypes(nextTypes);
      } catch {
        setLedgers([]);
        setVoucherTypes([]);
      }
    };
    void loadFilters();
  }, []);

  const entriesByDate = useMemo(() => {
    const groups = new Map<string, DayBook["entries"]>();
    (dayBook?.entries || []).forEach((entry) => {
      const key = entry.date.slice(0, 10);
      groups.set(key, [...(groups.get(key) || []), entry]);
    });
    return Array.from(groups.entries()).map(([date, entries]) => ({
      date,
      entries,
      debit: entries.reduce((sum, entry) => sum + Number(entry.debit || 0), 0),
      credit: entries.reduce((sum, entry) => sum + Number(entry.credit || 0), 0),
    }));
  }, [dayBook]);

  const exportRows = useMemo(() => (dayBook?.entries || []).map((entry) => ({
    date: formatAccountingDate(entry.date),
    voucherType: entry.voucherTypeCode,
    voucherNo: entry.voucherNo,
    ledger: entry.ledgerName,
    referenceNo: entry.referenceNo || "-",
    narration: entry.narration || "-",
    debit: entry.debit ? formatAccountingMoney(entry.debit) : "-",
    credit: entry.credit ? formatAccountingMoney(entry.credit) : "-",
    status: entry.status,
  })), [dayBook]);

  const exportColumns = [
    { key: "date", label: "Date" },
    { key: "voucherType", label: "Voucher Type" },
    { key: "voucherNo", label: "Voucher No" },
    { key: "ledger", label: "Ledger / Party" },
    { key: "referenceNo", label: "Reference No" },
    { key: "narration", label: "Narration" },
    { key: "debit", label: "Debit" },
    { key: "credit", label: "Credit" },
    { key: "status", label: "Status" },
  ];

  return (
    <div className="space-y-6">
      <PageHeader
        title="Day Book"
        description="Posted accounting voucher entries date-wise."
        icon={BookOpen}
      >
        <AccountingExportActions
          title="Day Book"
          subtitle={`${startDate ? formatAccountingDate(startDate) : "Beginning"} to ${endDate ? formatAccountingDate(endDate) : "Today"}`}
          filename={`day-book-${new Date().toISOString().slice(0, 10)}`}
          columns={exportColumns}
          rows={exportRows}
          totals={{
            date: "TOTAL",
            voucherType: "",
            voucherNo: "",
            ledger: "",
            referenceNo: "",
            narration: "",
            debit: formatAccountingMoney(dayBook?.totals.totalDebit || 0),
            credit: formatAccountingMoney(dayBook?.totals.totalCredit || 0),
            status: "",
          }}
          disabled={loading}
        />
        <Button variant="outline" onClick={() => void loadDayBook()} disabled={loading}>
          {loading ? <Loader2 className="h-4 w-4 animate-spin" /> : <RefreshCw className="h-4 w-4" />}
          Refresh
        </Button>
      </PageHeader>

      <Card className="rounded-lg">
        <CardContent className="grid gap-3 p-4 md:grid-cols-3 xl:grid-cols-6">
          <Input type="date" value={startDate} onChange={(event) => setStartDate(event.target.value)} />
          <Input type="date" value={endDate} onChange={(event) => setEndDate(event.target.value)} />
          <Select value={voucherTypeCode} onValueChange={setVoucherTypeCode}>
            <SelectTrigger><SelectValue placeholder="Voucher Type" /></SelectTrigger>
            <SelectContent>
              <SelectItem value={allValue}>All Types</SelectItem>
              {voucherTypes.map((type) => <SelectItem value={type.code} key={type._id}>{type.name}</SelectItem>)}
            </SelectContent>
          </Select>
          <Select value={ledgerId} onValueChange={setLedgerId}>
            <SelectTrigger><SelectValue placeholder="Ledger" /></SelectTrigger>
            <SelectContent>
              <SelectItem value={allValue}>All Ledgers</SelectItem>
              {ledgers.map((ledger) => <SelectItem value={ledger._id} key={ledger._id}>{ledger.name}</SelectItem>)}
            </SelectContent>
          </Select>
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

      {loading ? (
        <LoadingPanel label="Loading day book..." />
      ) : (
        <Card className="rounded-lg">
          <CardHeader>
            <CardTitle>Posted Entries</CardTitle>
          </CardHeader>
          <CardContent className="overflow-x-auto p-0">
            <Table>
              <TableHeader className="sticky top-0 bg-card">
                <TableRow>
                  <TableHead>Date</TableHead>
                  <TableHead>Voucher No</TableHead>
                  <TableHead>Voucher Type</TableHead>
                  <TableHead>Party / Ledger</TableHead>
                  <TableHead>Narration</TableHead>
                  <TableHead className="text-right">Debit</TableHead>
                  <TableHead className="text-right">Credit</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead>Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {entriesByDate.flatMap((group) => [
                  <TableRow key={`date-${group.date}`} className="bg-muted/40">
                    <TableCell colSpan={9} className="font-semibold">{formatAccountingDate(group.date)}</TableCell>
                  </TableRow>,
                  ...group.entries.map((entry) => (
                    <TableRow key={`${entry.voucherId}-${entry.ledgerId || entry.ledgerName}-${entry.debit}-${entry.credit}`}>
                      <TableCell>{formatAccountingDate(entry.date)}</TableCell>
                      <TableCell className="font-medium">{entry.voucherNo}</TableCell>
                      <TableCell><Badge variant="outline">{entry.voucherTypeCode}</Badge></TableCell>
                      <TableCell>{entry.ledgerName}</TableCell>
                      <TableCell className="max-w-[280px] truncate">{entry.narration || entry.referenceNo || "-"}</TableCell>
                      <TableCell className="text-right">{formatAccountingMoney(entry.debit || 0)}</TableCell>
                      <TableCell className="text-right">{formatAccountingMoney(entry.credit || 0)}</TableCell>
                      <TableCell><Badge variant={voucherStatusVariant(entry.status)}>{entry.status}</Badge></TableCell>
                      <TableCell>
                        <Button variant="outline" size="icon-sm" title="View voucher">
                          <FileText className="h-4 w-4" />
                        </Button>
                      </TableCell>
                    </TableRow>
                  )),
                  <TableRow key={`total-${group.date}`} className="bg-muted/20 font-semibold">
                    <TableCell colSpan={5}>Day Total</TableCell>
                    <TableCell className="text-right">{formatAccountingMoney(group.debit)}</TableCell>
                    <TableCell className="text-right">{formatAccountingMoney(group.credit)}</TableCell>
                    <TableCell colSpan={2}></TableCell>
                  </TableRow>,
                ])}
                {dayBook?.entries.length === 0 && (
                  <TableRow>
                    <TableCell colSpan={9} className="h-28 text-center text-muted-foreground">
                      No posted day book entries found.
                    </TableCell>
                  </TableRow>
                )}
              </TableBody>
              <TableFooter>
                <TableRow>
                  <TableCell colSpan={5}>Grand Total</TableCell>
                  <TableCell className="text-right">{formatAccountingMoney(dayBook?.totals.totalDebit || 0)}</TableCell>
                  <TableCell className="text-right">{formatAccountingMoney(dayBook?.totals.totalCredit || 0)}</TableCell>
                  <TableCell colSpan={2} />
                </TableRow>
              </TableFooter>
            </Table>
          </CardContent>
        </Card>
      )}
    </div>
  );
}
