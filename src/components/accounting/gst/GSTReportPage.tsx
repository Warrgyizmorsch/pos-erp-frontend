"use client";

import Link from "next/link";
import { useCallback, useEffect, useState } from "react";
import {
  AlertTriangle,
  ArrowLeft,
  BadgeIndianRupee,
  BookOpen,
  ChevronDown,
  Download,
  File,
  FileText,
  FileSpreadsheet,
  Landmark,
  Loader2,
  Printer,
  ReceiptText,
  RefreshCw,
  Sheet,
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
  formatReportValue,
  type ExportRow,
} from "@/lib/print/exportUtils";
import type { BusinessProfile } from "@/types";

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
const money = (value: number | undefined | null) => formatAccountingMoney(Number(value || 0));
const moneyOrDash = (value: number | undefined | null) => Number(value || 0) ? money(value) : "-";
const slug = (value: string) => value.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/(^-|-$)/g, "");
const label = (key: string) => key.replace(/([A-Z])/g, " $1").replace(/^./, (char) => char.toUpperCase()).trim();
const columns = (keys: string[]): ReportColumn[] => keys.map((key) => ({ key, label: label(key) }));

type PreparedGSTReport = {
  title: string;
  subtitle: string;
  filename: string;
  rows: ExportRow[];
  columns: ReportColumn[];
  totals?: ExportRow;
};

const normalizeExportRows = (rows: Array<Record<string, any>>) => {
  const keys = rows.length ? Object.keys(rows[0]).slice(0, 14) : [];
  return {
    keys,
    rows: rows.map((row) => Object.fromEntries(keys.map((key) => [key, formatReportValue(key, row[key])]))) as ExportRow[],
  };
};

function prepareGSTReport(kind: GSTReportKind, data: any, info: typeof meta[GSTReportKind], startDate: string, endDate: string): PreparedGSTReport {
  const subtitle = `${formatAccountingDate(startDate)} to ${formatAccountingDate(endDate)}`;
  const filename = `${slug(info.title)}-${new Date().toISOString().slice(0, 10)}`;

  if (kind === "summary") {
    const rows = ["cgst", "sgst", "igst", "totalTax"].map((key) => ({
      taxHead: key === "totalTax" ? "Total" : key.toUpperCase(),
      outputGST: money(data.outputGST?.[key] || 0),
      inputGST: money(data.inputGST?.[key] || 0),
      netPayable: money(key === "totalTax" ? data.netGST?.totalPayable || 0 : data.netGST?.[`${key}Payable`] || 0),
    }));
    return {
      title: info.title,
      subtitle,
      filename,
      columns: columns(["taxHead", "outputGST", "inputGST", "netPayable"]),
      rows,
      totals: {
        taxHead: "TOTAL",
        outputGST: money(data.outputGST?.totalTax || 0),
        inputGST: money(data.inputGST?.totalTax || 0),
        netPayable: money(data.netGST?.totalPayable || 0),
      },
    };
  }

  if (kind === "payable") {
    const rows = ["cgst", "sgst", "igst", "total"].map((key) => ({
      taxHead: key.toUpperCase(),
      output: money(data.output?.[key] || 0),
      input: money(data.input?.[key] || 0),
      payable: money(data.payable?.[key] || 0),
      excessITC: money(data.excessITC?.[key] || 0),
    }));
    return { title: info.title, subtitle, filename, columns: columns(["taxHead", "output", "input", "payable", "excessITC"]), rows };
  }

  if (kind === "gstr1") {
    const merged = [
      ...(data.b2b || []).map((row: any) => ({ section: "B2B", ...row })),
      ...(data.b2c || []).map((row: any) => ({ section: "B2C", ...row })),
      ...(data.creditNotes || []).map((row: any) => ({ section: "Credit Note", ...row })),
    ];
    const normalized = normalizeExportRows(merged);
    return { title: info.title, subtitle: data.note ? `${subtitle} · ${data.note}` : subtitle, filename, columns: columns(normalized.keys), rows: normalized.rows };
  }

  if (kind === "gstr3b") {
    const rows = [
      { section: "Outward Supplies", ...(data.outwardSupplies || {}) },
      { section: "Inward ITC", ...(data.inwardITC || {}) },
      { section: "Net Tax Payable", ...(data.netTaxPayable || {}) },
    ];
    const normalized = normalizeExportRows(rows);
    return { title: info.title, subtitle: data.note ? `${subtitle} · ${data.note}` : subtitle, filename, columns: columns(normalized.keys), rows: normalized.rows };
  }

  if (kind === "exceptions") {
    const normalized = normalizeExportRows(data.rows || []);
    return {
      title: info.title,
      subtitle,
      filename,
      columns: columns(normalized.keys),
      rows: normalized.rows,
      totals: { severity: "TOTAL", type: "", module: "", message: `High ${data.counts?.high || 0} · Medium ${data.counts?.medium || 0} · Low ${data.counts?.low || 0}` },
    };
  }

  const normalized = normalizeExportRows(data.rows || []);
  return { title: info.title, subtitle, filename, columns: columns(normalized.keys), rows: normalized.rows };
}

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
  const [exporting, setExporting] = useState(false);
  const [printOpen, setPrintOpen] = useState(false);
  const [printReport, setPrintReport] = useState<PreparedGSTReport | null>(null);
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

  const prepareCurrentReport = () => data ? prepareGSTReport(kind, data, info, startDate, endDate) : null;

  const handleExport = async (format: "csv" | "excel" | "pdf" | "print") => {
    const prepared = prepareCurrentReport();
    if (!prepared) {
      toast.error("Load GST report data before exporting");
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
      toast.error(getAccountingErrorMessage(error, "Failed to export GST report"));
    } finally {
      setExporting(false);
    }
  };

  return (
    <div className="space-y-6">
      <PageHeader title={info.title} description={info.description} icon={info.icon}>
        <Button variant="outline" asChild><Link href="/accounting/gst"><ArrowLeft className="h-4 w-4" /> GST Reports</Link></Button>
        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <Button variant="outline" disabled={loading || exporting || !data}>
              {exporting ? <Loader2 className="h-4 w-4 animate-spin" /> : <Download className="h-4 w-4" />}
              Export
              <ChevronDown className="h-4 w-4" />
            </Button>
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end">
            <DropdownMenuItem onClick={() => void handleExport("excel")}><Sheet className="mr-2 h-4 w-4" /> Excel (.xlsx)</DropdownMenuItem>
            <DropdownMenuItem onClick={() => void handleExport("pdf")}><FileText className="mr-2 h-4 w-4" /> PDF</DropdownMenuItem>
            <DropdownMenuItem onClick={() => void handleExport("csv")}><File className="mr-2 h-4 w-4" /> CSV</DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
        <Button variant="outline" disabled={loading || !data} onClick={() => void handleExport("print")}><Printer className="h-4 w-4" /> Print</Button>
        <Button variant="outline" onClick={() => void load()} disabled={loading}>{loading ? <Loader2 className="h-4 w-4 animate-spin" /> : <RefreshCw className="h-4 w-4" />} Refresh</Button>
      </PageHeader>
      {data?.warning && <Card className="rounded-lg border-amber-300 bg-amber-50"><CardContent className="p-4 text-sm text-amber-800">{data.warning}</CardContent></Card>}
      <Card className="rounded-lg"><CardContent className="grid gap-3 p-4 md:grid-cols-[180px_180px]"><Input type="date" value={startDate} onChange={(event) => setStartDate(event.target.value)} /><Input type="date" value={endDate} onChange={(event) => setEndDate(event.target.value)} /></CardContent></Card>
      {loading ? <LoadingPanel label={`Loading ${info.title.toLowerCase()}...`} /> : data ? renderGST(kind, data) : null}
      <ReportPrintDialog
        open={printOpen}
        onOpenChange={setPrintOpen}
        title={printReport?.title || info.title}
        subtitle={printReport?.subtitle}
        columns={printReport?.columns || []}
        rows={(printReport?.rows || []) as Record<string, ReportCell>[]}
        totals={printReport?.totals as Record<string, ReportCell> | undefined}
      />
    </div>
  );
}

export const gstReportCards = Object.entries(meta).map(([kind, value]) => ({ kind: kind as GSTReportKind, ...value }));
