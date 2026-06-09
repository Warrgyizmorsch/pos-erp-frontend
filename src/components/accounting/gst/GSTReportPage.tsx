"use client";

import Link from "next/link";
import { useCallback, useEffect, useState } from "react";
import {
  AlertTriangle,
  ArrowLeft,
  BadgeIndianRupee,
  BookOpen,
  Download,
  FileSpreadsheet,
  Landmark,
  Loader2,
  Printer,
  ReceiptText,
  RefreshCw,
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
import { Input } from "@/components/ui/input";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { accountingService } from "@/services/accountingService";

export type GSTReportKind =
  | "summary"
  | "output"
  | "input"
  | "payable"
  | "hsn-summary"
  | "gstr1"
  | "gstr3b"
  | "ledger"
  | "party-wise"
  | "exceptions";

const meta: Record<GSTReportKind, { title: string; description: string; icon: typeof BadgeIndianRupee }> = {
  summary: { title: "GST Summary", description: "Output GST, input GST, returns, and net payable.", icon: BadgeIndianRupee },
  output: { title: "Output GST", description: "GST collected on sales invoices.", icon: ReceiptText },
  input: { title: "Input GST", description: "GST paid on purchase bills and available ITC.", icon: FileSpreadsheet },
  payable: { title: "GST Payable / ITC", description: "GST liability and excess ITC by tax head.", icon: Landmark },
  "hsn-summary": { title: "HSN Summary", description: "HSN-wise quantity, taxable value, and tax.", icon: FileSpreadsheet },
  gstr1: { title: "GSTR-1 Style", description: "Internal sales breakup for B2B, B2C, credit notes, and HSN.", icon: BookOpen },
  gstr3b: { title: "GSTR-3B Summary", description: "Internal monthly GST summary for review.", icon: BookOpen },
  ledger: { title: "GST Ledger", description: "Voucher entry movement for GST ledgers.", icon: Landmark },
  "party-wise": { title: "GST Party-wise", description: "GST grouped by customers and suppliers.", icon: ReceiptText },
  exceptions: { title: "GST Exceptions", description: "Missing HSN, GSTIN, state, and tax mismatch issues.", icon: AlertTriangle },
};

const today = () => new Date().toISOString().slice(0, 10);
const monthStart = () => {
  const date = new Date();
  date.setDate(1);
  return date.toISOString().slice(0, 10);
};

const fetchGST = (kind: GSTReportKind, filters: Record<string, string>) => {
  if (kind === "summary") return accountingService.getGSTSummary(filters);
  if (kind === "output") return accountingService.getOutputGSTReport(filters);
  if (kind === "input") return accountingService.getInputGSTReport(filters);
  if (kind === "payable") return accountingService.getGSTPayableSummary(filters);
  if (kind === "hsn-summary") return accountingService.getHSNSummary(filters);
  if (kind === "gstr1") return accountingService.getGSTR1Report(filters);
  if (kind === "gstr3b") return accountingService.getGSTR3BSummary(filters);
  if (kind === "ledger") return accountingService.getGSTLedgerReport(filters);
  if (kind === "party-wise") return accountingService.getGSTPartyWiseReport(filters);
  return accountingService.getGSTExceptions(filters);
};

function SummaryCard({ label, value }: { label: string; value: number }) {
  return (
    <Card className="rounded-lg">
      <CardContent className="p-4">
        <p className="text-sm text-muted-foreground">{label}</p>
        <p className="mt-2 text-2xl font-bold">{formatAccountingMoney(value || 0)}</p>
      </CardContent>
    </Card>
  );
}

const amount = (value: number) => (value ? formatAccountingMoney(value) : "-");

function GenericTable({ rows }: { rows: Array<Record<string, any>> }) {
  if (!rows?.length) {
    return (
      <Card className="rounded-lg">
        <EmptyState icon={FileSpreadsheet} title="No GST rows found" description="Try a different period or create GST transactions." />
      </Card>
    );
  }
  const keys = Object.keys(rows[0]).slice(0, 12);
  return (
    <Card className="rounded-lg">
      <CardContent className="overflow-x-auto p-0">
        <Table>
          <TableHeader>
            <TableRow>
              {keys.map((key) => <TableHead key={key}>{key.replace(/([A-Z])/g, " $1")}</TableHead>)}
            </TableRow>
          </TableHeader>
          <TableBody>
            {rows.map((row, index) => (
              <TableRow key={index}>
                {keys.map((key) => {
                  const value = row[key];
                  const isMoney = ["amount", "tax", "total", "value", "cgst", "sgst", "igst", "debit", "credit", "balance", "payable", "itc"].some((part) => key.toLowerCase().includes(part));
                  const isDate = key.toLowerCase().includes("date");
                  return (
                    <TableCell key={key} className={isMoney ? "text-right" : ""}>
                      {isDate ? formatAccountingDate(value) : isMoney && typeof value === "number" ? amount(value) : String(value ?? "-")}
                    </TableCell>
                  );
                })}
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </CardContent>
    </Card>
  );
}

function renderGST(kind: GSTReportKind, data: any) {
  if (kind === "summary") {
    const rows = ["cgst", "sgst", "igst", "totalTax"].map((key) => ({
      taxHead: key === "totalTax" ? "Total" : key.toUpperCase(),
      output: data.outputGST?.[key] || 0,
      input: data.inputGST?.[key] || 0,
      payable: key === "totalTax" ? data.netGST?.totalPayable || 0 : data.netGST?.[`${key}Payable`] || 0,
    }));
    return (
      <>
        <div className="grid gap-4 md:grid-cols-4">
          <SummaryCard label="Output GST" value={data.outputGST?.totalTax || 0} />
          <SummaryCard label="Input GST" value={data.inputGST?.totalTax || 0} />
          <SummaryCard label="Net Payable" value={data.netGST?.totalPayable || 0} />
          <SummaryCard label="Total ITC" value={data.netGST?.totalITC || 0} />
        </div>
        <GenericTable rows={rows} />
      </>
    );
  }
  if (kind === "payable") {
    return <GenericTable rows={["cgst", "sgst", "igst", "total"].map((key) => ({ taxHead: key.toUpperCase(), output: data.output?.[key] || 0, input: data.input?.[key] || 0, payable: data.payable?.[key] || 0, excessITC: data.excessITC?.[key] || 0 }))} />;
  }
  if (kind === "gstr1") {
    return (
      <div className="space-y-4">
        {data.note && <Card className="rounded-lg"><CardContent className="p-4 text-sm text-muted-foreground">{data.note}</CardContent></Card>}
        <GenericTable rows={[...(data.b2b || []).map((row: any) => ({ section: "B2B", ...row })), ...(data.b2c || []).map((row: any) => ({ section: "B2C", ...row })), ...(data.creditNotes || []).map((row: any) => ({ section: "Credit Note", ...row }))]} />
      </div>
    );
  }
  if (kind === "gstr3b") {
    return (
      <>
        {data.note && <Card className="rounded-lg"><CardContent className="p-4 text-sm text-muted-foreground">{data.note}</CardContent></Card>}
        <GenericTable rows={[
          { section: "Outward Supplies", ...(data.outwardSupplies || {}) },
          { section: "Inward ITC", ...(data.inwardITC || {}) },
          { section: "Net Tax Payable", ...(data.netTaxPayable || {}) },
        ]} />
      </>
    );
  }
  if (kind === "exceptions") {
    return (
      <>
        <div className="grid gap-4 md:grid-cols-3">
          <SummaryCard label="High Severity" value={data.counts?.high || 0} />
          <SummaryCard label="Medium Severity" value={data.counts?.medium || 0} />
          <SummaryCard label="Low Severity" value={data.counts?.low || 0} />
        </div>
        <GenericTable rows={data.rows || []} />
      </>
    );
  }
  return <GenericTable rows={data.rows || []} />;
}

export function GSTReportPage({ kind }: { kind: GSTReportKind }) {
  const info = meta[kind];
  const [data, setData] = useState<any | null>(null);
  const [loading, setLoading] = useState(true);
  const [startDate, setStartDate] = useState(monthStart());
  const [endDate, setEndDate] = useState(today());

  const load = useCallback(async () => {
    try {
      setLoading(true);
      setData(await fetchGST(kind, { startDate, endDate }));
    } catch (error) {
      toast.error(getAccountingErrorMessage(error, "Failed to load GST report"));
    } finally {
      setLoading(false);
    }
  }, [endDate, kind, startDate]);

  useEffect(() => {
    void load();
  }, [load]);

  return (
    <div className="space-y-6">
      <PageHeader title={info.title} description={info.description} icon={info.icon}>
        <Button variant="outline" asChild><Link href="/accounting/gst"><ArrowLeft className="h-4 w-4" /> GST Reports</Link></Button>
        <Button variant="outline" disabled><Download className="h-4 w-4" /> Export</Button>
        <Button variant="outline" disabled><Printer className="h-4 w-4" /> Print</Button>
        <Button variant="outline" onClick={() => void load()} disabled={loading}>{loading ? <Loader2 className="h-4 w-4 animate-spin" /> : <RefreshCw className="h-4 w-4" />} Refresh</Button>
      </PageHeader>
      {data?.warning && <Card className="rounded-lg border-amber-300 bg-amber-50"><CardContent className="p-4 text-sm text-amber-800">{data.warning}</CardContent></Card>}
      <Card className="rounded-lg"><CardContent className="grid gap-3 p-4 md:grid-cols-[180px_180px]"><Input type="date" value={startDate} onChange={(event) => setStartDate(event.target.value)} /><Input type="date" value={endDate} onChange={(event) => setEndDate(event.target.value)} /></CardContent></Card>
      {loading ? <LoadingPanel label={`Loading ${info.title.toLowerCase()}...`} /> : data ? renderGST(kind, data) : null}
    </div>
  );
}

export const gstReportCards = Object.entries(meta).map(([kind, value]) => ({ kind: kind as GSTReportKind, ...value }));
