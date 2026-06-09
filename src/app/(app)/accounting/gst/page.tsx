"use client";

import Link from "next/link";
import { ArrowRight, BadgeIndianRupee, Loader2, RefreshCw } from "lucide-react";
import { useCallback, useEffect, useState } from "react";
import { toast } from "sonner";
import { formatAccountingMoney, getAccountingErrorMessage } from "@/components/accounting/accounting-ui";
import { gstReportCards } from "@/components/accounting/gst/GSTReportPage";
import { PageHeader } from "@/components/shared/PageHeader";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { accountingService } from "@/services/accountingService";

export default function GSTReportsIndexPage() {
  const [summary, setSummary] = useState<any | null>(null);
  const [exceptions, setExceptions] = useState<any | null>(null);
  const [loading, setLoading] = useState(true);

  const load = useCallback(async () => {
    try {
      setLoading(true);
      const [nextSummary, nextExceptions] = await Promise.all([
        accountingService.getGSTSummary(),
        accountingService.getGSTExceptions(),
      ]);
      setSummary(nextSummary);
      setExceptions(nextExceptions);
    } catch (error) {
      toast.error(getAccountingErrorMessage(error, "Failed to load GST dashboard"));
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => { void load(); }, [load]);

  return (
    <div className="space-y-6">
      <PageHeader title="GST Reports" description="GST summaries, GSTR-style internal reports, HSN, ledger, and exceptions." icon={BadgeIndianRupee}>
        <Button variant="outline" onClick={() => void load()} disabled={loading}>{loading ? <Loader2 className="h-4 w-4 animate-spin" /> : <RefreshCw className="h-4 w-4" />} Refresh</Button>
      </PageHeader>
      {summary?.warning && <Card className="rounded-lg border-amber-300 bg-amber-50"><CardContent className="p-4 text-sm text-amber-800">{summary.warning}</CardContent></Card>}
      <div className="grid gap-4 md:grid-cols-4">
        <Card className="rounded-lg"><CardContent className="p-4"><p className="text-sm text-muted-foreground">Output GST</p><p className="mt-2 text-2xl font-bold">{formatAccountingMoney(summary?.outputGST?.totalTax || 0)}</p></CardContent></Card>
        <Card className="rounded-lg"><CardContent className="p-4"><p className="text-sm text-muted-foreground">Input GST</p><p className="mt-2 text-2xl font-bold">{formatAccountingMoney(summary?.inputGST?.totalTax || 0)}</p></CardContent></Card>
        <Card className="rounded-lg"><CardContent className="p-4"><p className="text-sm text-muted-foreground">Net Payable</p><p className="mt-2 text-2xl font-bold">{formatAccountingMoney(summary?.netGST?.totalPayable || 0)}</p></CardContent></Card>
        <Card className="rounded-lg"><CardContent className="p-4"><p className="text-sm text-muted-foreground">Exceptions</p><p className="mt-2 text-2xl font-bold">{exceptions?.rows?.length || 0}</p></CardContent></Card>
      </div>
      <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
        {gstReportCards.map((report) => (
          <Link key={report.kind} href={`/accounting/gst/${report.kind}`} className="block">
            <Card className="h-full rounded-lg transition-colors hover:bg-muted/30">
              <CardContent className="flex h-full items-start gap-4 p-5">
                <div className="rounded-lg bg-primary/10 p-3 text-primary"><report.icon className="h-5 w-5" /></div>
                <div className="min-w-0 flex-1"><p className="font-semibold">{report.title}</p><p className="mt-1 text-sm text-muted-foreground">{report.description}</p></div>
                <ArrowRight className="h-4 w-4 text-muted-foreground" />
              </CardContent>
            </Card>
          </Link>
        ))}
      </div>
    </div>
  );
}
