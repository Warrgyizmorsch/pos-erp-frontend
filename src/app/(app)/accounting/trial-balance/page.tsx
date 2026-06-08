"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import { BarChart3, Loader2, RefreshCw } from "lucide-react";
import { toast } from "sonner";
import {
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
import { accountingService, type BasicTrialBalance } from "@/services/accountingService";

const allValue = "ALL";

export default function BasicTrialBalancePage() {
  const [trialBalance, setTrialBalance] = useState<BasicTrialBalance | null>(null);
  const [loading, setLoading] = useState(true);
  const [asOnDate, setAsOnDate] = useState(new Date().toISOString().slice(0, 10));
  const [groupFilter, setGroupFilter] = useState(allValue);

  const loadTrialBalance = useCallback(async () => {
    try {
      setLoading(true);
      const result = await accountingService.getTrialBalance({ asOnDate });
      setTrialBalance(result);
    } catch (error) {
      toast.error(getAccountingErrorMessage(error, "Failed to load trial balance"));
    } finally {
      setLoading(false);
    }
  }, [asOnDate]);

  useEffect(() => {
    const timer = window.setTimeout(() => {
      void loadTrialBalance();
    }, 0);
    return () => window.clearTimeout(timer);
  }, [loadTrialBalance]);

  const groups = useMemo(
    () => Array.from(new Set((trialBalance?.rows || []).map((row) => row.groupName).filter(Boolean))).sort(),
    [trialBalance],
  );

  const rows = useMemo(() => {
    if (!trialBalance) return [];
    return trialBalance.rows.filter((row) => groupFilter === allValue || row.groupName === groupFilter);
  }, [groupFilter, trialBalance]);

  const filteredTotals = useMemo(() => {
    const totalDebit = rows.reduce((sum, row) => sum + row.debitBalance, 0);
    const totalCredit = rows.reduce((sum, row) => sum + row.creditBalance, 0);
    return {
      totalDebit,
      totalCredit,
      difference: totalDebit - totalCredit,
      isBalanced: totalDebit === totalCredit,
    };
  }, [rows]);

  return (
    <div className="space-y-6">
      <PageHeader
        title="Basic Trial Balance"
        description="Validation-level trial balance by ledger."
        icon={BarChart3}
      >
        <Button variant="outline" onClick={() => void loadTrialBalance()} disabled={loading}>
          {loading ? <Loader2 className="h-4 w-4 animate-spin" /> : <RefreshCw className="h-4 w-4" />}
          Refresh
        </Button>
        {trialBalance && (
          <Badge variant={filteredTotals.isBalanced ? "success" : "warning"}>
            {filteredTotals.isBalanced ? "Balanced" : "Difference Found"}
          </Badge>
        )}
      </PageHeader>

      <Card className="rounded-lg">
        <CardContent className="grid gap-3 p-4 md:grid-cols-[220px_260px]">
          <Input type="date" value={asOnDate} onChange={(event) => setAsOnDate(event.target.value)} />
          <Select value={groupFilter} onValueChange={setGroupFilter}>
            <SelectTrigger><SelectValue placeholder="Group" /></SelectTrigger>
            <SelectContent>
              <SelectItem value={allValue}>All Groups</SelectItem>
              {groups.map((group) => <SelectItem value={group || ""} key={group}>{group}</SelectItem>)}
            </SelectContent>
          </Select>
        </CardContent>
      </Card>

      {loading ? (
        <LoadingPanel label="Loading trial balance..." />
      ) : !trialBalance || rows.length === 0 ? (
        <Card className="rounded-lg">
          <EmptyState
            icon={BarChart3}
            title="No ledger balances found"
            description="Initialize accounting and post manual vouchers to verify the trial balance."
          />
        </Card>
      ) : (
        <Card className="rounded-lg">
          <CardContent className="p-0">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Ledger</TableHead>
                  <TableHead>Group</TableHead>
                  <TableHead className="text-right">Debit Balance</TableHead>
                  <TableHead className="text-right">Credit Balance</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {rows.map((row) => (
                  <TableRow key={row.ledgerId}>
                    <TableCell>
                      <p className="font-medium">{row.ledgerName}</p>
                      <p className="text-xs text-muted-foreground">{row.code}</p>
                    </TableCell>
                    <TableCell>{row.groupName || "-"}</TableCell>
                    <TableCell className="text-right">
                      {row.debitBalance ? formatAccountingMoney(row.debitBalance) : "-"}
                    </TableCell>
                    <TableCell className="text-right">
                      {row.creditBalance ? formatAccountingMoney(row.creditBalance) : "-"}
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
              <TableFooter>
                <TableRow>
                  <TableCell colSpan={2}>Total</TableCell>
                  <TableCell className="text-right">{formatAccountingMoney(filteredTotals.totalDebit)}</TableCell>
                  <TableCell className="text-right">{formatAccountingMoney(filteredTotals.totalCredit)}</TableCell>
                </TableRow>
                <TableRow>
                  <TableCell colSpan={2}>Difference</TableCell>
                  <TableCell className="text-right" colSpan={2}>
                    {formatAccountingMoney(Math.abs(filteredTotals.difference))}
                  </TableCell>
                </TableRow>
              </TableFooter>
            </Table>
          </CardContent>
        </Card>
      )}
    </div>
  );
}
