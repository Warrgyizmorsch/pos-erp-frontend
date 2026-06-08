"use client";

import Link from "next/link";
import { useCallback, useEffect, useMemo, useState } from "react";
import { Eye, ListCollapse, Loader2, RefreshCw, Search } from "lucide-react";
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
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { accountingService, type Ledger } from "@/services/accountingService";

const allValue = "ALL";

const formatBalance = (amount: number, balanceType: string) =>
  `${formatAccountingMoney(amount)} ${balanceType === "CREDIT" ? "Cr" : "Dr"}`;

export default function AccountingLedgersPage() {
  const [ledgers, setLedgers] = useState<Ledger[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [group, setGroup] = useState(allValue);
  const [ledgerType, setLedgerType] = useState(allValue);
  const [nature, setNature] = useState(allValue);
  const [status, setStatus] = useState(allValue);

  const loadLedgers = useCallback(async () => {
    try {
      setLoading(true);
      const nextLedgers = await accountingService.getLedgers();
      setLedgers(nextLedgers);
    } catch (error) {
      toast.error(getAccountingErrorMessage(error, "Failed to load ledgers"));
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    const timer = window.setTimeout(() => {
      void loadLedgers();
    }, 0);
    return () => window.clearTimeout(timer);
  }, [loadLedgers]);

  const groups = useMemo(() => {
    const values = new Map<string, string>();
    ledgers.forEach((ledger) => {
      if (ledger.groupId?._id) values.set(ledger.groupId._id, ledger.groupId.name);
    });
    return Array.from(values.entries()).sort((a, b) => a[1].localeCompare(b[1]));
  }, [ledgers]);

  const ledgerTypes = useMemo(
    () => Array.from(new Set(ledgers.map((ledger) => ledger.ledgerType))).sort(),
    [ledgers],
  );

  const filteredLedgers = useMemo(() => {
    const normalizedSearch = search.trim().toLowerCase();
    return ledgers.filter((ledger) => {
      const matchesSearch = !normalizedSearch
        || ledger.name.toLowerCase().includes(normalizedSearch)
        || ledger.code.toLowerCase().includes(normalizedSearch);
      const matchesGroup = group === allValue || ledger.groupId?._id === group;
      const matchesType = ledgerType === allValue || ledger.ledgerType === ledgerType;
      const matchesNature = nature === allValue || ledger.groupId?.nature === nature;
      const matchesStatus = status === allValue
        || (status === "ACTIVE" ? ledger.isActive : !ledger.isActive);

      return matchesSearch && matchesGroup && matchesType && matchesNature && matchesStatus;
    });
  }, [group, ledgerType, ledgers, nature, search, status]);

  return (
    <div className="space-y-6">
      <PageHeader
        title="Ledgers"
        description="Professional ledger list with balances and statement access."
        icon={ListCollapse}
      >
        <Button variant="outline" onClick={() => void loadLedgers()} disabled={loading}>
          {loading ? <Loader2 className="h-4 w-4 animate-spin" /> : <RefreshCw className="h-4 w-4" />}
          Refresh
        </Button>
      </PageHeader>

      <Card className="rounded-lg">
        <CardContent className="grid gap-3 p-4 md:grid-cols-2 xl:grid-cols-5">
          <div className="relative xl:col-span-1">
            <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
            <Input
              value={search}
              onChange={(event) => setSearch(event.target.value)}
              placeholder="Search name or code..."
              className="pl-9"
            />
          </div>
          <Select value={group} onValueChange={setGroup}>
            <SelectTrigger><SelectValue placeholder="Group" /></SelectTrigger>
            <SelectContent>
              <SelectItem value={allValue}>All Groups</SelectItem>
              {groups.map(([id, name]) => <SelectItem value={id} key={id}>{name}</SelectItem>)}
            </SelectContent>
          </Select>
          <Select value={ledgerType} onValueChange={setLedgerType}>
            <SelectTrigger><SelectValue placeholder="Ledger type" /></SelectTrigger>
            <SelectContent>
              <SelectItem value={allValue}>All Types</SelectItem>
              {ledgerTypes.map((type) => <SelectItem value={type} key={type}>{type}</SelectItem>)}
            </SelectContent>
          </Select>
          <Select value={nature} onValueChange={setNature}>
            <SelectTrigger><SelectValue placeholder="Nature" /></SelectTrigger>
            <SelectContent>
              <SelectItem value={allValue}>All Nature</SelectItem>
              <SelectItem value="ASSET">Assets</SelectItem>
              <SelectItem value="LIABILITY">Liabilities</SelectItem>
              <SelectItem value="INCOME">Income</SelectItem>
              <SelectItem value="EXPENSE">Expenses</SelectItem>
            </SelectContent>
          </Select>
          <Select value={status} onValueChange={setStatus}>
            <SelectTrigger><SelectValue placeholder="Status" /></SelectTrigger>
            <SelectContent>
              <SelectItem value={allValue}>All Status</SelectItem>
              <SelectItem value="ACTIVE">Active</SelectItem>
              <SelectItem value="INACTIVE">Inactive</SelectItem>
            </SelectContent>
          </Select>
        </CardContent>
      </Card>

      {loading ? (
        <LoadingPanel label="Loading ledgers..." />
      ) : filteredLedgers.length === 0 ? (
        <Card className="rounded-lg">
          <EmptyState
            icon={ListCollapse}
            title="No ledgers found"
            description="Try clearing filters or initialize accounting defaults."
          />
        </Card>
      ) : (
        <Card className="rounded-lg">
          <CardContent className="p-0">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Ledger Name</TableHead>
                  <TableHead>Code</TableHead>
                  <TableHead>Group</TableHead>
                  <TableHead>Nature</TableHead>
                  <TableHead>Ledger Type</TableHead>
                  <TableHead>Opening Balance</TableHead>
                  <TableHead>Current Balance</TableHead>
                  <TableHead>System</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead className="text-right">Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {filteredLedgers.map((ledger) => (
                  <TableRow key={ledger._id}>
                    <TableCell className="font-medium">{ledger.name}</TableCell>
                    <TableCell className="font-mono text-xs text-muted-foreground">{ledger.code}</TableCell>
                    <TableCell>{ledger.groupId?.name || "-"}</TableCell>
                    <TableCell>{ledger.groupId?.nature || "-"}</TableCell>
                    <TableCell><Badge variant="outline">{ledger.ledgerType}</Badge></TableCell>
                    <TableCell>{formatBalance(ledger.openingBalance, ledger.openingBalanceType)}</TableCell>
                    <TableCell className="font-medium">{formatBalance(ledger.currentBalance, ledger.currentBalanceType)}</TableCell>
                    <TableCell>
                      <Badge variant={ledger.isSystemDefault ? "secondary" : "outline"}>
                        {ledger.isSystemDefault ? "System" : "Custom"}
                      </Badge>
                    </TableCell>
                    <TableCell>
                      <Badge variant={ledger.isActive ? "success" : "secondary"}>
                        {ledger.isActive ? "Active" : "Inactive"}
                      </Badge>
                    </TableCell>
                    <TableCell>
                      <div className="flex justify-end gap-2">
                        <Button asChild variant="outline" size="sm">
                          <Link href={`/accounting/ledgers/${ledger._id}`}>
                            <Eye className="h-4 w-4" />
                            Statement
                          </Link>
                        </Button>
                      </div>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </CardContent>
        </Card>
      )}
    </div>
  );
}
