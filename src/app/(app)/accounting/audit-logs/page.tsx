"use client";

import { useCallback, useEffect, useState } from "react";
import { Eye, History, Loader2, RefreshCw } from "lucide-react";
import { toast } from "sonner";
import {
  formatAccountingDate,
  getAccountingErrorMessage,
  LoadingPanel,
} from "@/components/accounting/accounting-ui";
import { PageHeader } from "@/components/shared/PageHeader";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Sheet,
  SheetContent,
  SheetHeader,
  SheetTitle,
} from "@/components/ui/sheet";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { accountingService, type AccountingAuditLog } from "@/services/accountingService";

const pretty = (value?: Record<string, unknown>) => JSON.stringify(value || {}, null, 2);
const compact = (value?: Record<string, unknown>) => {
  if (!value || Object.keys(value).length === 0) return "-";
  const text = JSON.stringify(value);
  return text.length > 80 ? `${text.slice(0, 80)}...` : text;
};

export default function AccountingAuditLogsPage() {
  const [logs, setLogs] = useState<AccountingAuditLog[]>([]);
  const [selected, setSelected] = useState<AccountingAuditLog | null>(null);
  const [loading, setLoading] = useState(true);
  const [filters, setFilters] = useState({
    startDate: "",
    endDate: "",
    action: "",
    module: "",
    user: "",
    search: "",
  });

  const loadLogs = useCallback(async () => {
    try {
      setLoading(true);
      const result = await accountingService.getAccountingAuditLogs(filters);
      setLogs(result.logs);
    } catch (error) {
      toast.error(getAccountingErrorMessage(error, "Failed to load audit logs"));
    } finally {
      setLoading(false);
    }
  }, [filters]);

  useEffect(() => {
    const timer = window.setTimeout(() => {
      void loadLogs();
    }, 250);
    return () => window.clearTimeout(timer);
  }, [loadLogs]);

  if (loading && logs.length === 0) return <LoadingPanel label="Loading accounting audit logs..." />;

  return (
    <div className="space-y-6">
      <PageHeader
        title="Accounting Audit Logs"
        description="Track accounting settings, voucher, repost, and reconciliation activity."
        icon={History}
      >
        <Button variant="outline" onClick={() => void loadLogs()} disabled={loading}>
          {loading ? <Loader2 className="h-4 w-4 animate-spin" /> : <RefreshCw className="h-4 w-4" />}
          Refresh
        </Button>
      </PageHeader>

      <Card className="rounded-lg">
        <CardContent className="grid gap-3 p-4 md:grid-cols-3 xl:grid-cols-6">
          <div className="space-y-1">
            <Label>From</Label>
            <Input type="date" value={filters.startDate} onChange={(event) => setFilters((prev) => ({ ...prev, startDate: event.target.value }))} />
          </div>
          <div className="space-y-1">
            <Label>To</Label>
            <Input type="date" value={filters.endDate} onChange={(event) => setFilters((prev) => ({ ...prev, endDate: event.target.value }))} />
          </div>
          <div className="space-y-1">
            <Label>Action</Label>
            <Input value={filters.action} onChange={(event) => setFilters((prev) => ({ ...prev, action: event.target.value }))} placeholder="Action" />
          </div>
          <div className="space-y-1">
            <Label>Module</Label>
            <Input value={filters.module} onChange={(event) => setFilters((prev) => ({ ...prev, module: event.target.value }))} placeholder="Module" />
          </div>
          <div className="space-y-1">
            <Label>User</Label>
            <Input value={filters.user} onChange={(event) => setFilters((prev) => ({ ...prev, user: event.target.value }))} placeholder="User" />
          </div>
          <div className="space-y-1">
            <Label>Search</Label>
            <Input value={filters.search} onChange={(event) => setFilters((prev) => ({ ...prev, search: event.target.value }))} placeholder="Reference, description..." />
          </div>
        </CardContent>
      </Card>

      <Card className="rounded-lg">
        <CardContent className="overflow-x-auto p-0">
          <Table>
            <TableHeader className="sticky top-0 bg-card">
              <TableRow>
                <TableHead>Date & Time</TableHead>
                <TableHead>User</TableHead>
                <TableHead>Action</TableHead>
                <TableHead>Module</TableHead>
                <TableHead>Reference</TableHead>
                <TableHead>Old Value</TableHead>
                <TableHead>New Value</TableHead>
                <TableHead>IP / Device</TableHead>
                <TableHead>Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {logs.map((log) => (
                <TableRow key={log._id}>
                  <TableCell>{formatAccountingDate(log.createdAt)}</TableCell>
                  <TableCell>{log.user?.name || log.userName || "-"}</TableCell>
                  <TableCell><Badge variant="outline">{log.action}</Badge></TableCell>
                  <TableCell>{log.module}</TableCell>
                  <TableCell>
                    <p className="font-medium">{log.referenceNo || log.referenceId || "-"}</p>
                    <p className="max-w-[260px] truncate text-xs text-muted-foreground">{log.description || "-"}</p>
                  </TableCell>
                  <TableCell className="max-w-[240px] truncate font-mono text-xs">{compact(log.oldData)}</TableCell>
                  <TableCell className="max-w-[240px] truncate font-mono text-xs">{compact(log.newData)}</TableCell>
                  <TableCell>
                    <p>{log.ipAddress || "-"}</p>
                    <p className="max-w-[220px] truncate text-xs text-muted-foreground">{log.userAgent || "-"}</p>
                  </TableCell>
                  <TableCell>
                    <Button variant="outline" size="icon-sm" title="View details" onClick={() => setSelected(log)}>
                      <Eye className="h-4 w-4" />
                    </Button>
                  </TableCell>
                </TableRow>
              ))}
              {logs.length === 0 && (
                <TableRow>
                  <TableCell colSpan={9} className="h-32 text-center text-muted-foreground">No accounting audit logs found.</TableCell>
                </TableRow>
              )}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      <Sheet open={Boolean(selected)} onOpenChange={(open) => !open && setSelected(null)}>
        <SheetContent className="w-full overflow-y-auto sm:max-w-3xl">
          <SheetHeader>
            <SheetTitle>{selected?.action || "Audit Log Details"}</SheetTitle>
          </SheetHeader>
          {selected && (
            <div className="mt-6 space-y-4">
              <div className="grid gap-3 rounded-lg border border-border p-4 text-sm md:grid-cols-2">
                <div><p className="text-muted-foreground">IP Address</p><p className="font-medium">{selected.ipAddress || "-"}</p></div>
                <div><p className="text-muted-foreground">User Agent</p><p className="break-all font-medium">{selected.userAgent || "-"}</p></div>
              </div>
              <div>
                <Label>Old Data</Label>
                <pre className="mt-2 max-h-72 overflow-auto rounded-lg border border-border bg-muted/30 p-3 text-xs">{pretty(selected.oldData)}</pre>
              </div>
              <div>
                <Label>New Data</Label>
                <pre className="mt-2 max-h-72 overflow-auto rounded-lg border border-border bg-muted/30 p-3 text-xs">{pretty(selected.newData)}</pre>
              </div>
              <div>
                <Label>Details</Label>
                <pre className="mt-2 max-h-72 overflow-auto rounded-lg border border-border bg-muted/30 p-3 text-xs">{pretty(selected.details)}</pre>
              </div>
            </div>
          )}
        </SheetContent>
      </Sheet>
    </div>
  );
}
