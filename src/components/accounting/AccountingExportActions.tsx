"use client";

import { useState } from "react";
import { ChevronDown, Download, File, FileText, Loader2, Printer, Sheet } from "lucide-react";
import { toast } from "sonner";
import { Button } from "@/components/ui/button";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { ReportPrintDialog } from "@/components/print/ReportPrintDialog";
import type { ReportCell, ReportColumn } from "@/lib/print/templates/ReportPrintTemplate";
import {
  exportReportCsv,
  exportReportExcel,
  exportReportPdf,
  type ExportRow,
} from "@/lib/print/exportUtils";
import { businessService } from "@/services/businessService";
import type { BusinessProfile } from "@/types";

interface AccountingExportActionsProps {
  title: string;
  subtitle?: string;
  filename: string;
  columns: ReportColumn[];
  rows: ExportRow[];
  totals?: ExportRow;
  disabled?: boolean;
}

export function AccountingExportActions({
  title,
  subtitle,
  filename,
  columns,
  rows,
  totals,
  disabled,
}: AccountingExportActionsProps) {
  const [exporting, setExporting] = useState(false);
  const [printOpen, setPrintOpen] = useState(false);

  const runExport = async (format: "csv" | "excel" | "pdf" | "print") => {
    if (!rows.length) {
      toast.error("No rows available to export");
      return;
    }

    try {
      setExporting(true);
      if (format === "print") {
        setPrintOpen(true);
        return;
      }

      const business: BusinessProfile | undefined = await businessService.getProfile().catch(() => undefined);
      const context = { title, filename, dateRange: subtitle, business, totals };
      if (format === "csv") exportReportCsv(rows, context);
      if (format === "excel") await exportReportExcel(rows, context);
      if (format === "pdf") await exportReportPdf(rows, context);
      toast.success(`${title} exported as ${format.toUpperCase()}`);
    } catch (error) {
      toast.error(error instanceof Error ? error.message : "Failed to export report");
    } finally {
      setExporting(false);
    }
  };

  return (
    <>
      <DropdownMenu>
        <DropdownMenuTrigger asChild>
          <Button variant="outline" disabled={disabled || exporting || !rows.length}>
            {exporting ? <Loader2 className="h-4 w-4 animate-spin" /> : <Download className="h-4 w-4" />}
            Export
            <ChevronDown className="h-4 w-4" />
          </Button>
        </DropdownMenuTrigger>
        <DropdownMenuContent align="end">
          <DropdownMenuItem onClick={() => void runExport("excel")}><Sheet className="mr-2 h-4 w-4" /> Excel (.xlsx)</DropdownMenuItem>
          <DropdownMenuItem onClick={() => void runExport("pdf")}><FileText className="mr-2 h-4 w-4" /> PDF</DropdownMenuItem>
          <DropdownMenuItem onClick={() => void runExport("csv")}><File className="mr-2 h-4 w-4" /> CSV</DropdownMenuItem>
        </DropdownMenuContent>
      </DropdownMenu>
      <Button variant="outline" disabled={disabled || !rows.length} onClick={() => void runExport("print")}>
        <Printer className="h-4 w-4" />
        Print
      </Button>
      <ReportPrintDialog
        open={printOpen}
        onOpenChange={setPrintOpen}
        title={title}
        subtitle={subtitle}
        columns={columns}
        rows={rows as Record<string, ReportCell>[]}
        totals={totals as Record<string, ReportCell> | undefined}
      />
    </>
  );
}
