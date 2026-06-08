"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import { ChevronDown, ChevronRight, Layers, Loader2, RefreshCw, Search } from "lucide-react";
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
import { accountingService, type ChartGroup, type ChartLedger } from "@/services/accountingService";

const natureOptions = [
  { value: "ALL", label: "All" },
  { value: "ASSET", label: "Assets" },
  { value: "LIABILITY", label: "Liabilities" },
  { value: "INCOME", label: "Income" },
  { value: "EXPENSE", label: "Expenses" },
];

const formatBalance = (amount: number, balanceType: string) =>
  `${formatAccountingMoney(amount)} ${balanceType === "CREDIT" ? "Cr" : "Dr"}`;

const filterGroup = (group: ChartGroup, search: string, nature: string): ChartGroup | null => {
  const normalizedSearch = search.trim().toLowerCase();
  const natureMatches = nature === "ALL" || group.nature === nature;
  const groupMatches = !normalizedSearch
    || group.groupName.toLowerCase().includes(normalizedSearch)
    || group.code.toLowerCase().includes(normalizedSearch);
  const ledgers = group.ledgers.filter((ledger) => (
    !normalizedSearch
    || ledger.ledgerName.toLowerCase().includes(normalizedSearch)
    || ledger.code.toLowerCase().includes(normalizedSearch)
  ));
  const childGroups = group.childGroups
    .map((child) => filterGroup(child, search, nature))
    .filter(Boolean) as ChartGroup[];

  if ((natureMatches && groupMatches) || ledgers.length > 0 || childGroups.length > 0) {
    return { ...group, ledgers, childGroups };
  }

  return null;
};

function LedgerLine({ ledger }: { ledger: ChartLedger }) {
  return (
    <div className="grid gap-3 rounded-lg border border-border bg-background px-4 py-3 text-sm md:grid-cols-[minmax(0,1fr)_120px_150px_130px_auto] md:items-center">
      <div className="min-w-0">
        <div className="flex flex-wrap items-center gap-2">
          <p className="truncate font-medium">{ledger.ledgerName}</p>
          {ledger.isSystemDefault && <Badge variant="secondary">System</Badge>}
        </div>
        <p className="mt-1 text-xs text-muted-foreground">{ledger.code}</p>
      </div>
      <Badge variant="outline" className="w-fit">{ledger.ledgerType}</Badge>
      <p className="font-medium">{formatBalance(ledger.currentBalance, ledger.currentBalanceType)}</p>
      <p className="text-xs text-muted-foreground">{ledger.isActive ? "Active" : "Inactive"}</p>
      <Badge variant={ledger.isActive ? "success" : "secondary"}>{ledger.isActive ? "Active" : "Inactive"}</Badge>
    </div>
  );
}

function GroupNode({
  group,
  depth = 0,
  expanded,
  toggleExpanded,
}: {
  group: ChartGroup;
  depth?: number;
  expanded: Set<string>;
  toggleExpanded: (id: string) => void;
}) {
  const isExpanded = expanded.has(group.groupId);
  const hasChildren = group.childGroups.length > 0 || group.ledgers.length > 0;

  return (
    <div className="space-y-3">
      <div
        className="rounded-lg border border-border bg-card"
        style={{ marginLeft: depth ? `${Math.min(depth * 18, 54)}px` : undefined }}
      >
        <button
          type="button"
          className="flex w-full items-start justify-between gap-4 border-b border-border p-4 text-left"
          onClick={() => toggleExpanded(group.groupId)}
        >
          <div className="min-w-0">
            <div className="flex flex-wrap items-center gap-2">
              {hasChildren && (
                isExpanded ? <ChevronDown className="h-4 w-4" /> : <ChevronRight className="h-4 w-4" />
              )}
              <h2 className="font-semibold">{group.groupName}</h2>
              {group.isSystemDefault && <Badge variant="secondary">System</Badge>}
              {group.affectsGrossProfit && <Badge variant="outline">Gross Profit</Badge>}
            </div>
            <p className="mt-1 text-sm text-muted-foreground">
              {group.code} · {group.nature} · Normal {group.normalBalance}
            </p>
          </div>
          <Badge variant={group.isActive ? "success" : "secondary"}>
            {group.isActive ? "Active" : "Inactive"}
          </Badge>
        </button>

        {isExpanded && (
          <div className="space-y-2 p-4">
            {group.ledgers.length === 0 && group.childGroups.length === 0 ? (
              <p className="rounded-lg bg-muted/40 px-4 py-3 text-sm text-muted-foreground">
                No ledgers in this group.
              </p>
            ) : (
              group.ledgers.map((ledger) => <LedgerLine key={ledger.ledgerId} ledger={ledger} />)
            )}
          </div>
        )}
      </div>

      {isExpanded && group.childGroups.map((child) => (
        <GroupNode
          key={child.groupId}
          group={child}
          depth={depth + 1}
          expanded={expanded}
          toggleExpanded={toggleExpanded}
        />
      ))}
    </div>
  );
}

export default function ChartOfAccountsPage() {
  const [groups, setGroups] = useState<ChartGroup[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [nature, setNature] = useState("ALL");
  const [expanded, setExpanded] = useState<Set<string>>(new Set());

  const loadChart = useCallback(async () => {
    try {
      setLoading(true);
      const chart = await accountingService.getChartOfAccounts();
      setGroups(chart);
      setExpanded(new Set(chart.map((group) => group.groupId)));
    } catch (error) {
      toast.error(getAccountingErrorMessage(error, "Failed to load chart of accounts"));
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    const timer = window.setTimeout(() => {
      void loadChart();
    }, 0);
    return () => window.clearTimeout(timer);
  }, [loadChart]);

  const filteredGroups = useMemo(
    () => groups.map((group) => filterGroup(group, search, nature)).filter(Boolean) as ChartGroup[],
    [groups, nature, search],
  );

  const toggleExpanded = (id: string) => {
    setExpanded((current) => {
      const next = new Set(current);
      if (next.has(id)) next.delete(id);
      else next.add(id);
      return next;
    });
  };

  return (
    <div className="space-y-6">
      <PageHeader
        title="Chart of Accounts"
        description="View accounting groups and ledgers in a grouped tree."
        icon={Layers}
      >
        <Button variant="outline" onClick={() => void loadChart()} disabled={loading}>
          {loading ? <Loader2 className="h-4 w-4 animate-spin" /> : <RefreshCw className="h-4 w-4" />}
          Refresh
        </Button>
      </PageHeader>

      <Card className="rounded-lg">
        <CardContent className="grid gap-3 p-4 md:grid-cols-[minmax(0,1fr)_220px]">
          <div className="relative">
            <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
            <Input
              value={search}
              onChange={(event) => setSearch(event.target.value)}
              placeholder="Search group or ledger..."
              className="pl-9"
            />
          </div>
          <Select value={nature} onValueChange={setNature}>
            <SelectTrigger>
              <SelectValue placeholder="Filter nature" />
            </SelectTrigger>
            <SelectContent>
              {natureOptions.map((option) => (
                <SelectItem value={option.value} key={option.value}>{option.label}</SelectItem>
              ))}
            </SelectContent>
          </Select>
        </CardContent>
      </Card>

      {loading ? (
        <LoadingPanel label="Loading chart of accounts..." />
      ) : filteredGroups.length === 0 ? (
        <Card className="rounded-lg">
          <EmptyState
            icon={Layers}
            title="No account groups found"
            description="Try changing the search or nature filter."
          />
        </Card>
      ) : (
        <div className="space-y-4">
          {filteredGroups.map((group) => (
            <GroupNode
              key={group.groupId}
              group={group}
              expanded={expanded}
              toggleExpanded={toggleExpanded}
            />
          ))}
        </div>
      )}
    </div>
  );
}
