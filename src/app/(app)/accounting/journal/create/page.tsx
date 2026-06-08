"use client";

import { useRouter } from "next/navigation";
import { useCallback, useEffect, useMemo, useState } from "react";
import { FileText, Loader2, Plus, Trash2 } from "lucide-react";
import { toast } from "sonner";
import {
  formatAccountingMoney,
  getAccountingErrorMessage,
} from "@/components/accounting/accounting-ui";
import { PageHeader } from "@/components/shared/PageHeader";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
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
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { accountingService, type Ledger } from "@/services/accountingService";

interface JournalRow {
  id: string;
  ledgerId: string;
  debit: string;
  credit: string;
  narration: string;
}

const createRow = (): JournalRow => ({
  id: `${Date.now()}-${Math.random().toString(36).slice(2)}`,
  ledgerId: "",
  debit: "",
  credit: "",
  narration: "",
});

const todayInputValue = () => new Date().toISOString().slice(0, 10);
const toNumber = (value: string) => Number(value || 0);

export default function CreateJournalVoucherPage() {
  const router = useRouter();
  const [ledgers, setLedgers] = useState<Ledger[]>([]);
  const [date, setDate] = useState(todayInputValue());
  const [narration, setNarration] = useState("");
  const [rows, setRows] = useState<JournalRow[]>([createRow(), createRow()]);
  const [loading, setLoading] = useState(false);
  const [ledgersLoading, setLedgersLoading] = useState(true);

  const loadLedgers = useCallback(async () => {
    try {
      setLedgersLoading(true);
      setLedgers(await accountingService.getLedgers({ isActive: true }));
    } catch (error) {
      toast.error(getAccountingErrorMessage(error, "Failed to load ledgers"));
    } finally {
      setLedgersLoading(false);
    }
  }, []);

  useEffect(() => {
    const timer = window.setTimeout(() => {
      void loadLedgers();
    }, 0);
    return () => window.clearTimeout(timer);
  }, [loadLedgers]);

  const totals = useMemo(() => {
    const totalDebit = rows.reduce((sum, row) => sum + toNumber(row.debit), 0);
    const totalCredit = rows.reduce((sum, row) => sum + toNumber(row.credit), 0);
    const difference = totalDebit - totalCredit;
    return { totalDebit, totalCredit, difference, isBalanced: totalDebit > 0 && totalDebit === totalCredit };
  }, [rows]);

  const updateRow = (id: string, updates: Partial<JournalRow>) => {
    setRows((current) => current.map((row) => (row.id === id ? { ...row, ...updates } : row)));
  };

  const validateRows = () => {
    if (rows.length < 2) return "At least two entries are required";
    for (const row of rows) {
      if (!row.ledgerId) return "Please select ledger";
      if (!toNumber(row.debit) && !toNumber(row.credit)) return "Each row needs debit or credit";
      if (toNumber(row.debit) && toNumber(row.credit)) return "Debit and credit cannot both be entered in the same row";
    }
    if (!totals.isBalanced) return "Voucher is not balanced";
    return null;
  };

  const submit = async (mode: "draft" | "post") => {
    const error = validateRows();
    if (error) {
      toast.error(error);
      return;
    }

    try {
      setLoading(true);
      const payload = {
        date,
        narration,
        entries: rows.map((row) => ({
          ledgerId: row.ledgerId,
          debit: toNumber(row.debit),
          credit: toNumber(row.credit),
          narration: row.narration,
        })),
      };
      const detail = mode === "draft"
        ? await accountingService.createJournalDraft(payload)
        : await accountingService.postJournal(payload);
      toast.success(mode === "draft" ? "Draft voucher saved successfully" : "Journal voucher posted successfully");
      router.push(`/accounting/vouchers?created=${detail.voucher._id}`);
    } catch (requestError) {
      toast.error(getAccountingErrorMessage(requestError, "Journal voucher request failed"));
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="space-y-6">
      <PageHeader
        title="Create Journal Voucher"
        description="Manually post debit and credit ledger entries."
        icon={FileText}
      />

      <Card className="rounded-lg">
        <CardHeader><CardTitle>Voucher Details</CardTitle></CardHeader>
        <CardContent className="grid gap-4 md:grid-cols-[220px_minmax(0,1fr)]">
          <Input type="date" value={date} onChange={(event) => setDate(event.target.value)} />
          <Textarea
            value={narration}
            onChange={(event) => setNarration(event.target.value)}
            placeholder="Narration"
            className="min-h-10"
          />
        </CardContent>
      </Card>

      <Card className="rounded-lg">
        <CardHeader className="flex flex-row items-center justify-between">
          <CardTitle>Entries</CardTitle>
          <Button variant="outline" onClick={() => setRows((current) => [...current, createRow()])}>
            <Plus className="h-4 w-4" />
            Add Row
          </Button>
        </CardHeader>
        <CardContent className="p-0">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Ledger</TableHead>
                <TableHead className="w-36 text-right">Debit</TableHead>
                <TableHead className="w-36 text-right">Credit</TableHead>
                <TableHead>Narration</TableHead>
                <TableHead className="w-16" />
              </TableRow>
            </TableHeader>
            <TableBody>
              {rows.map((row) => (
                <TableRow key={row.id}>
                  <TableCell>
                    <Select value={row.ledgerId} onValueChange={(ledgerId) => updateRow(row.id, { ledgerId })}>
                      <SelectTrigger>
                        <SelectValue placeholder={ledgersLoading ? "Loading..." : "Select ledger"} />
                      </SelectTrigger>
                      <SelectContent>
                        {ledgers.map((ledger) => (
                          <SelectItem value={ledger._id} key={ledger._id}>
                            {ledger.name} · {ledger.code}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </TableCell>
                  <TableCell>
                    <Input
                      type="number"
                      min="0"
                      value={row.debit}
                      onChange={(event) => updateRow(row.id, { debit: event.target.value, credit: "" })}
                      className="text-right"
                    />
                  </TableCell>
                  <TableCell>
                    <Input
                      type="number"
                      min="0"
                      value={row.credit}
                      onChange={(event) => updateRow(row.id, { credit: event.target.value, debit: "" })}
                      className="text-right"
                    />
                  </TableCell>
                  <TableCell>
                    <Input
                      value={row.narration}
                      onChange={(event) => updateRow(row.id, { narration: event.target.value })}
                      placeholder="Line narration"
                    />
                  </TableCell>
                  <TableCell>
                    <Button
                      variant="outline"
                      size="icon-sm"
                      onClick={() => setRows((current) => current.filter((item) => item.id !== row.id))}
                      disabled={rows.length <= 2}
                      title="Remove row"
                    >
                      <Trash2 className="h-4 w-4" />
                    </Button>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      <Card className="rounded-lg">
        <CardContent className="flex flex-col gap-4 p-5 md:flex-row md:items-center md:justify-between">
          <div className="grid gap-3 sm:grid-cols-4">
            <div>
              <p className="text-xs text-muted-foreground">Total Debit</p>
              <p className="font-semibold">{formatAccountingMoney(totals.totalDebit)}</p>
            </div>
            <div>
              <p className="text-xs text-muted-foreground">Total Credit</p>
              <p className="font-semibold">{formatAccountingMoney(totals.totalCredit)}</p>
            </div>
            <div>
              <p className="text-xs text-muted-foreground">Difference</p>
              <p className="font-semibold">{formatAccountingMoney(Math.abs(totals.difference))}</p>
            </div>
            <div>
              <p className="text-xs text-muted-foreground">Status</p>
              <Badge variant={totals.isBalanced ? "success" : "warning"}>
                {totals.isBalanced ? "Balanced" : "Not Balanced"}
              </Badge>
            </div>
          </div>
          <div className="flex flex-col gap-3 sm:flex-row">
            <Button variant="outline" onClick={() => router.push("/accounting/vouchers")} disabled={loading}>
              Cancel
            </Button>
            <Button variant="outline" onClick={() => void submit("draft")} disabled={loading || !totals.isBalanced}>
              {loading ? <Loader2 className="h-4 w-4 animate-spin" /> : <FileText className="h-4 w-4" />}
              Save Draft
            </Button>
            <Button onClick={() => void submit("post")} disabled={loading || !totals.isBalanced}>
              {loading ? <Loader2 className="h-4 w-4 animate-spin" /> : <FileText className="h-4 w-4" />}
              Post Voucher
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
