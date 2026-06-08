"use client";

import Link from "next/link";
import { ArrowRight, BarChart3, Loader2, RefreshCw } from "lucide-react";
import { useCallback, useEffect, useState } from "react";
import { toast } from "sonner";
import {
  accountingReportCards,
} from "@/components/accounting/reports/AccountingReportPage";
import {
  formatAccountingMoney,
  getAccountingErrorMessage,
} from "@/components/accounting/accounting-ui";
import { PageHeader } from "@/components/shared/PageHeader";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { accountingService, type AccountingReportDashboard } from "@/services/accountingService";

const reportHref = (kind: string) => `/accounting/reports/${kind}`;

export default function AccountingReportsIndexPage() {
  const [dashboard, setDashboard] = useState<AccountingReportDashboard | null>(null);
  const [loading, setLoading] = useState(true);

  const load = useCallback(async () => {
    try {
      setLoading(true);
      setDashboard(await accountingService.getAccountingReportDashboard());
    } catch (error) {
      toast.error(getAccountingErrorMessage(error, "Failed to load report dashboard"));
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    void load();
  }, [load]);

  return (
    <div className="space-y-6">
      <PageHeader
        title="Accounting Reports"
        description="Trial balance, financial statements, books, and party outstanding reports."
        icon={BarChart3}
      >
        <Button variant="outline" onClick={() => void load()} disabled={loading}>
          {loading ? <Loader2 className="h-4 w-4 animate-spin" /> : <RefreshCw className="h-4 w-4" />}
          Refresh
        </Button>
      </PageHeader>

      <div className="grid gap-4 md:grid-cols-4">
        <Card className="rounded-lg"><CardContent className="p-4"><p className="text-sm text-muted-foreground">Income</p><p className="mt-2 text-2xl font-bold">{formatAccountingMoney(dashboard?.totalIncome || 0)}</p></CardContent></Card>
        <Card className="rounded-lg"><CardContent className="p-4"><p className="text-sm text-muted-foreground">Expenses</p><p className="mt-2 text-2xl font-bold">{formatAccountingMoney(dashboard?.totalExpenses || 0)}</p></CardContent></Card>
        <Card className="rounded-lg"><CardContent className="p-4"><p className="text-sm text-muted-foreground">Receivables</p><p className="mt-2 text-2xl font-bold">{formatAccountingMoney(dashboard?.receivables || 0)}</p></CardContent></Card>
        <Card className="rounded-lg"><CardContent className="p-4"><p className="text-sm text-muted-foreground">Payables</p><p className="mt-2 text-2xl font-bold">{formatAccountingMoney(dashboard?.payables || 0)}</p></CardContent></Card>
      </div>

      <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
        {accountingReportCards.map((report) => (
          <Link key={report.kind} href={reportHref(report.kind)} className="block">
            <Card className="h-full rounded-lg transition-colors hover:bg-muted/30">
              <CardContent className="flex h-full items-start gap-4 p-5">
                <div className="rounded-lg bg-primary/10 p-3 text-primary">
                  <report.icon className="h-5 w-5" />
                </div>
                <div className="min-w-0 flex-1">
                  <p className="font-semibold">{report.title}</p>
                  <p className="mt-1 text-sm text-muted-foreground">{report.description}</p>
                </div>
                <ArrowRight className="h-4 w-4 text-muted-foreground" />
              </CardContent>
            </Card>
          </Link>
        ))}
      </div>
    </div>
  );
}
