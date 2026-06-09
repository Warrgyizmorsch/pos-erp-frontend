"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import { Database, Loader2, RefreshCw, ShieldCheck, Wrench } from "lucide-react";
import { toast } from "sonner";
import {
  formatAccountingMoney,
  getAccountingErrorMessage,
  LoadingPanel,
} from "@/components/accounting/accounting-ui";
import { PageHeader } from "@/components/shared/PageHeader";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import {
  accountingService,
  type CashBankReconciliation,
  type GSTReconciliation,
  type LedgerReconciliation,
  type PartyReconciliation,
} from "@/services/accountingService";

const statusBadge = (status: string) => (
  <Badge variant={status === "ok" ? "success" : status === "missing_ledger" || status === "missing_accounting_ledger" ? "warning" : "destructive"}>
    {status}
  </Badge>
);

function BalanceMetric({
  label,
  value,
  muted,
}: {
  label: string;
  value: string;
  muted?: boolean;
}) {
  return (
    <div className="min-w-0 rounded-lg border border-border bg-background p-3">
      <p className="text-xs font-medium uppercase tracking-normal text-muted-foreground">{label}</p>
      <p className={muted ? "mt-1 truncate text-sm font-semibold text-muted-foreground" : "mt-1 truncate text-sm font-semibold"}>
        {value}
      </p>
    </div>
  );
}

export default function AccountingReconciliationPage() {
  const [ledger, setLedger] = useState<LedgerReconciliation | null>(null);
  const [cashBank, setCashBank] = useState<CashBankReconciliation | null>(null);
  const [parties, setParties] = useState<PartyReconciliation | null>(null);
  const [gst, setGst] = useState<GSTReconciliation | null>(null);
  const [loading, setLoading] = useState(true);
  const [fixing, setFixing] = useState(false);
  const [linkingCashBank, setLinkingCashBank] = useState(false);
  const [linkingParties, setLinkingParties] = useState(false);
  const [postingCashBankOpening, setPostingCashBankOpening] = useState(false);

  const loadAll = useCallback(async () => {
    try {
      setLoading(true);
      const [nextLedger, nextCashBank, nextParties, nextGst] = await Promise.all([
        accountingService.getLedgerReconciliation(),
        accountingService.getCashBankReconciliationDetails(),
        accountingService.getPartyReconciliation(),
        accountingService.getGSTReconciliation(),
      ]);
      setLedger(nextLedger);
      setCashBank(nextCashBank);
      setParties(nextParties);
      setGst(nextGst);
    } catch (error) {
      toast.error(getAccountingErrorMessage(error, "Failed to load reconciliation"));
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    const timer = window.setTimeout(() => {
      void loadAll();
    }, 0);
    return () => window.clearTimeout(timer);
  }, [loadAll]);

  const partyRows = useMemo(() => [...(parties?.customers || []), ...(parties?.suppliers || [])], [parties]);

  const fixLedgerBalances = async () => {
    const confirmed = window.confirm("Recalculate stored ledger balances from posted vouchers? Voucher entries will not be changed.");
    if (!confirmed) return;
    try {
      setFixing(true);
      await accountingService.fixLedgerReconciliation();
      toast.success("Ledger balances recalculated");
      await loadAll();
    } catch (error) {
      toast.error(getAccountingErrorMessage(error, "Ledger reconciliation fix failed"));
    } finally {
      setFixing(false);
    }
  };

  const linkCashBankLedgers = async () => {
    try {
      setLinkingCashBank(true);
      await accountingService.linkCashBankLedgers();
      toast.success("Cash/bank accounts linked to accounting ledgers");
      await loadAll();
    } catch (error) {
      toast.error(getAccountingErrorMessage(error, "Cash/bank ledger linking failed"));
    } finally {
      setLinkingCashBank(false);
    }
  };

  const postCashBankOpeningBalances = async () => {
    const confirmed = window.confirm("Post missing cash/bank opening balance vouchers? Existing opening vouchers will not be duplicated.");
    if (!confirmed) return;
    try {
      setPostingCashBankOpening(true);
      await accountingService.postCashBankOpeningBalances();
      toast.success("Cash/bank opening balances posted");
      await loadAll();
    } catch (error) {
      toast.error(getAccountingErrorMessage(error, "Cash/bank opening balance posting failed"));
    } finally {
      setPostingCashBankOpening(false);
    }
  };

  const linkPartyLedgers = async () => {
    try {
      setLinkingParties(true);
      await accountingService.linkPartyLedgers();
      toast.success("Party accounts linked to accounting ledgers");
      await loadAll();
    } catch (error) {
      toast.error(getAccountingErrorMessage(error, "Party ledger linking failed"));
    } finally {
      setLinkingParties(false);
    }
  };

  if (loading && !ledger) return <LoadingPanel label="Loading reconciliation..." />;

  return (
    <div className="space-y-6">
      <PageHeader
        title="Accounting Reconciliation"
        description="Compare posted vouchers with ledger, cash/bank, party, and GST records."
        icon={ShieldCheck}
      >
        <Button variant="outline" onClick={() => void loadAll()} disabled={loading}>
          {loading ? <Loader2 className="h-4 w-4 animate-spin" /> : <RefreshCw className="h-4 w-4" />}
          Refresh
        </Button>
      </PageHeader>

      <Tabs defaultValue="ledgers" className="space-y-4">
        <TabsList>
          <TabsTrigger value="ledgers">Ledger Balances</TabsTrigger>
          <TabsTrigger value="cash-bank">Cash & Bank</TabsTrigger>
          <TabsTrigger value="parties">Parties</TabsTrigger>
          <TabsTrigger value="gst">GST</TabsTrigger>
        </TabsList>

        <TabsContent value="ledgers">
          <Card className="rounded-lg">
            <CardContent className="p-0">
              <div className="flex items-center justify-between p-4">
                <Badge variant={ledger?.count ? "destructive" : "success"}>{ledger?.count || 0} mismatches</Badge>
                <Button variant="outline" onClick={() => void fixLedgerBalances()} disabled={fixing || !ledger?.count}>
                  {fixing ? <Loader2 className="h-4 w-4 animate-spin" /> : <Wrench className="h-4 w-4" />}
                  Fix Ledger Balances
                </Button>
              </div>
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Ledger</TableHead>
                    <TableHead>Stored</TableHead>
                    <TableHead>Expected</TableHead>
                    <TableHead>Difference</TableHead>
                    <TableHead>Status</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {(ledger?.mismatches || []).map((row) => (
                    <TableRow key={row.ledgerId}>
                      <TableCell><p className="font-medium">{row.ledgerName}</p><p className="text-xs text-muted-foreground">{row.code}</p></TableCell>
                      <TableCell>{formatAccountingMoney(row.storedBalance)} {row.storedBalanceType}</TableCell>
                      <TableCell>{formatAccountingMoney(row.expectedBalance)} {row.expectedBalanceType}</TableCell>
                      <TableCell>{formatAccountingMoney(Math.abs(row.difference))}</TableCell>
                      <TableCell>{statusBadge(row.status)}</TableCell>
                    </TableRow>
                  ))}
                  {(ledger?.mismatches || []).length === 0 && <TableRow><TableCell colSpan={5} className="h-28 text-center text-muted-foreground">Ledger balances match posted vouchers.</TableCell></TableRow>}
                </TableBody>
              </Table>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="cash-bank">
          <Card className="rounded-lg">
            <CardContent className="space-y-4 p-4">
              <div className="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
                <div className="min-w-0">
                  <p className="text-sm font-medium">Cash & Bank Ledger Mapping</p>
                  <p className="mt-1 text-sm text-muted-foreground">
                    Link missing accounts first. Recalculate ledger balances only after mappings are correct.
                  </p>
                </div>
                <div className="flex shrink-0 flex-col gap-2 sm:flex-row">
                  <Button variant="outline" onClick={() => void linkCashBankLedgers()} disabled={linkingCashBank || postingCashBankOpening}>
                    {linkingCashBank ? <Loader2 className="h-4 w-4 animate-spin" /> : <Wrench className="h-4 w-4" />}
                    Link Cash/Bank Ledgers
                  </Button>
                  <Button variant="outline" onClick={() => void postCashBankOpeningBalances()} disabled={linkingCashBank || postingCashBankOpening}>
                    {postingCashBankOpening ? <Loader2 className="h-4 w-4 animate-spin" /> : <Database className="h-4 w-4" />}
                    Post Opening Balances
                  </Button>
                </div>
              </div>

              <div className="space-y-3">
                {(cashBank?.accounts || []).map((row) => (
                  <div className="rounded-lg border border-border bg-muted/10 p-4" key={row.accountId}>
                    <div className="flex flex-col gap-3 lg:flex-row lg:items-start lg:justify-between">
                      <div className="min-w-0">
                        <div className="flex flex-wrap items-center gap-2">
                          <p className="text-base font-semibold">{row.accountName}</p>
                          <Badge variant="outline">{row.accountType}</Badge>
                          {statusBadge(row.status)}
                        </div>
                        {row.mappedLedger ? (
                          <p className="mt-2 text-sm text-muted-foreground">
                            Mapped to <span className="font-medium text-foreground">{row.mappedLedger.name}</span>
                            <span className="mx-1">·</span>
                            {row.mappedLedger.code}
                          </p>
                        ) : (
                          <p className="mt-2 text-sm text-amber-600">No accounting ledger linked.</p>
                        )}
                      </div>
                      <div className="rounded-lg bg-background px-3 py-2 text-sm">
                        <p className="text-xs font-medium uppercase tracking-normal text-muted-foreground">Difference</p>
                        <p className={Math.abs(row.difference || 0) > 0.01 ? "mt-1 font-semibold text-destructive" : "mt-1 font-semibold text-emerald-600"}>
                          {formatAccountingMoney(Math.abs(row.difference || 0))}
                        </p>
                      </div>
                    </div>

                    <div className="mt-4 grid gap-3 sm:grid-cols-2 xl:grid-cols-5">
                      <BalanceMetric label="Opening Balance" value={formatAccountingMoney(row.openingBalance)} />
                      <BalanceMetric label="Cash/Bank Balance" value={formatAccountingMoney(row.currentBalance)} />
                      <BalanceMetric label="Transaction Balance" value={formatAccountingMoney(row.transactionBalance)} />
                      <BalanceMetric
                        label="Ledger Balance"
                        value={row.ledgerBalance === null ? "Not linked" : formatAccountingMoney(row.ledgerBalance)}
                        muted={row.ledgerBalance === null}
                      />
                      <BalanceMetric
                        label="Ledger Opening"
                        value={row.mappedLedger ? formatAccountingMoney(row.mappedLedger.openingBalance) : "Not linked"}
                        muted={!row.mappedLedger}
                      />
                    </div>

                    <div className="mt-4 rounded-lg border border-border bg-background p-3">
                      <p className="text-xs font-medium uppercase tracking-normal text-muted-foreground">Suggested Fix</p>
                      <p className="mt-1 text-sm leading-6 text-foreground">{row.suggestedFix}</p>
                      {row.openingBalanceDifference !== null && Math.abs(row.openingBalanceDifference) > 0.01 ? (
                        <Badge className="mt-3" variant="warning">
                          Opening difference {formatAccountingMoney(Math.abs(row.openingBalanceDifference))}
                        </Badge>
                      ) : null}
                    </div>
                  </div>
                ))}
                {(cashBank?.accounts || []).length === 0 && (
                  <div className="rounded-lg border border-border p-8 text-center text-muted-foreground">
                    No active cash or bank accounts found.
                  </div>
                )}
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="parties">
          <Card className="rounded-lg">
            <CardContent className="space-y-4 p-4">
              <div className="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
                <div className="min-w-0">
                  <p className="text-sm font-medium">Party Ledger Mapping</p>
                  <p className="mt-1 text-sm text-muted-foreground">
                    Ensure every active customer and supplier has a matching accounting ledger.
                  </p>
                </div>
                <Button className="shrink-0" variant="outline" onClick={() => void linkPartyLedgers()} disabled={linkingParties}>
                  {linkingParties ? <Loader2 className="h-4 w-4 animate-spin" /> : <Wrench className="h-4 w-4" />}
                  Link Party Ledgers
                </Button>
              </div>
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Party</TableHead>
                    <TableHead>Business Balance</TableHead>
                    <TableHead>Party Ledger</TableHead>
                    <TableHead>Accounting Ledger</TableHead>
                    <TableHead>Difference</TableHead>
                    <TableHead>Status</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {partyRows.map((row) => (
                    <TableRow key={`${row.partyType}-${row.partyId}`}>
                      <TableCell><p className="font-medium">{row.partyName}</p><p className="text-xs text-muted-foreground">{row.partyType}</p></TableCell>
                      <TableCell>{formatAccountingMoney(row.businessBalance)}</TableCell>
                      <TableCell>{row.partyLedgerBalance === null ? "-" : formatAccountingMoney(row.partyLedgerBalance)}</TableCell>
                      <TableCell>{row.accountingBalance === null ? "-" : formatAccountingMoney(row.accountingBalance)}</TableCell>
                      <TableCell>{formatAccountingMoney(Math.abs(row.difference || 0))}</TableCell>
                      <TableCell>{statusBadge(row.status)}</TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="gst">
          <Card className="rounded-lg">
            <CardContent className="p-0">
              <div className="p-4 text-sm text-muted-foreground">GST reconciliation is view-only.</div>
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>GST Ledger</TableHead>
                    <TableHead>Report Amount</TableHead>
                    <TableHead>Ledger Amount</TableHead>
                    <TableHead>Difference</TableHead>
                    <TableHead>Status</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {(gst?.rows || []).map((row) => (
                    <TableRow key={row.ledgerCode}>
                      <TableCell className="font-medium">{row.ledgerCode}</TableCell>
                      <TableCell>{formatAccountingMoney(Math.abs(row.expected))}</TableCell>
                      <TableCell>{row.actual === null ? "-" : formatAccountingMoney(Math.abs(row.actual))}</TableCell>
                      <TableCell>{formatAccountingMoney(Math.abs(row.difference || 0))}</TableCell>
                      <TableCell>{statusBadge(row.status)}</TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  );
}
