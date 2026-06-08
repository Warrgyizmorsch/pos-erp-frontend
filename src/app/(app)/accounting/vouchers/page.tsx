"use client";

import Link from "next/link";
import { useCallback, useEffect, useMemo, useState } from "react";
import { Eye, FileText, Loader2, RefreshCw, RotateCcw, Search, XCircle } from "lucide-react";
import { toast } from "sonner";
import {
  formatAccountingDate,
  formatAccountingMoney,
  getAccountingErrorMessage,
  getVoucherDisplayStatus,
  LoadingPanel,
  voucherStatusVariant,
  VoucherDetailsDrawer,
} from "@/components/accounting/accounting-ui";
import { ConfirmDialog } from "@/components/shared/ConfirmDialog";
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
import {
  accountingService,
  type Voucher,
  type VoucherDetail,
  type VoucherType,
} from "@/services/accountingService";

type VoucherAction = "post" | "cancel" | "reverse";

const allValue = "ALL";

const canCancelOrReverseVoucher = (voucher: Voucher) =>
  voucher.status === "POSTED" && !voucher.reversalVoucherId;

export default function AccountingVouchersPage() {
  const [vouchers, setVouchers] = useState<Voucher[]>([]);
  const [voucherTypes, setVoucherTypes] = useState<VoucherType[]>([]);
  const [selectedVoucher, setSelectedVoucher] = useState<VoucherDetail | null>(null);
  const [detailsOpen, setDetailsOpen] = useState(false);
  const [loading, setLoading] = useState(true);
  const [actionLoading, setActionLoading] = useState<string | null>(null);
  const [pendingAction, setPendingAction] = useState<{ id: string; action: VoucherAction } | null>(null);
  const [search, setSearch] = useState("");
  const [voucherType, setVoucherType] = useState(allValue);
  const [status, setStatus] = useState(allValue);
  const [referenceModule, setReferenceModule] = useState("");
  const [startDate, setStartDate] = useState("");
  const [endDate, setEndDate] = useState("");

  const loadVouchers = useCallback(async () => {
    try {
      setLoading(true);
      const nextVouchers = await accountingService.getVouchers({
        search,
        voucherTypeCode: voucherType === allValue ? undefined : voucherType,
        status: status === allValue ? undefined : status,
        referenceModule,
        startDate,
        endDate,
      });
      setVouchers(nextVouchers);
    } catch (error) {
      toast.error(getAccountingErrorMessage(error, "Failed to load vouchers"));
    } finally {
      setLoading(false);
    }
  }, [endDate, referenceModule, search, startDate, status, voucherType]);

  useEffect(() => {
    const timer = window.setTimeout(() => {
      void loadVouchers();
    }, 0);
    return () => window.clearTimeout(timer);
  }, [loadVouchers]);

  useEffect(() => {
    const loadVoucherTypes = async () => {
      try {
        setVoucherTypes(await accountingService.getVoucherTypes());
      } catch {
        setVoucherTypes([]);
      }
    };
    void loadVoucherTypes();
  }, []);

  const viewVoucher = async (id: string) => {
    try {
      setActionLoading(`view-${id}`);
      const detail = await accountingService.getVoucherById(id);
      setSelectedVoucher(detail);
      setDetailsOpen(true);
    } catch (error) {
      toast.error(getAccountingErrorMessage(error, "Failed to load voucher details"));
    } finally {
      setActionLoading(null);
    }
  };

  const runVoucherAction = async (id: string, action: VoucherAction) => {
    try {
      setActionLoading(`${action}-${id}`);
      if (action === "post") {
        await accountingService.postDraftVoucher(id);
        toast.success("Voucher posted");
      }
      if (action === "cancel") {
        await accountingService.cancelVoucher(id, "Cancelled from accounting voucher list");
        toast.success("Voucher cancelled");
      }
      if (action === "reverse") {
        await accountingService.reverseVoucher(id, "Reversed from accounting voucher list");
        toast.success("Reversal voucher created");
      }
      await loadVouchers();
    } catch (error) {
      toast.error(getAccountingErrorMessage(error, "Voucher action failed"));
    } finally {
      setActionLoading(null);
    }
  };

  const pendingVoucher = useMemo(
    () => vouchers.find((voucher) => voucher._id === pendingAction?.id),
    [pendingAction?.id, vouchers],
  );

  return (
    <div className="space-y-6">
      <PageHeader
        title="Vouchers"
        description="Accounting vouchers with filtering, posting, cancellation, reversal, and details view."
        icon={FileText}
      >
        <Button variant="outline" onClick={() => void loadVouchers()} disabled={loading}>
          {loading ? <Loader2 className="h-4 w-4 animate-spin" /> : <RefreshCw className="h-4 w-4" />}
          Refresh
        </Button>
        <Button asChild>
          <Link href="/accounting/journal/create">
            <FileText className="h-4 w-4" />
            Create Journal
          </Link>
        </Button>
      </PageHeader>

      <Card className="rounded-lg">
        <CardContent className="grid gap-3 p-4 md:grid-cols-3 xl:grid-cols-6">
          <div className="relative md:col-span-2 xl:col-span-2">
            <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
            <Input
              value={search}
              onChange={(event) => setSearch(event.target.value)}
              placeholder="Search voucher, reference, narration..."
              className="pl-9"
            />
          </div>
          <Select value={voucherType} onValueChange={setVoucherType}>
            <SelectTrigger><SelectValue placeholder="Voucher Type" /></SelectTrigger>
            <SelectContent>
              <SelectItem value={allValue}>All Types</SelectItem>
              {voucherTypes.map((type) => <SelectItem value={type.code} key={type._id}>{type.name}</SelectItem>)}
            </SelectContent>
          </Select>
          <Select value={status} onValueChange={setStatus}>
            <SelectTrigger><SelectValue placeholder="Status" /></SelectTrigger>
            <SelectContent>
              <SelectItem value={allValue}>All Status</SelectItem>
              <SelectItem value="DRAFT">Draft</SelectItem>
              <SelectItem value="POSTED">Posted</SelectItem>
              <SelectItem value="CANCELLED">Cancelled</SelectItem>
              <SelectItem value="REVERSED">Reversed</SelectItem>
            </SelectContent>
          </Select>
          <Input
            value={referenceModule}
            onChange={(event) => setReferenceModule(event.target.value)}
            placeholder="Reference module"
          />
          <div className="grid grid-cols-2 gap-3 md:col-span-3 xl:col-span-1">
            <Input type="date" value={startDate} onChange={(event) => setStartDate(event.target.value)} />
            <Input type="date" value={endDate} onChange={(event) => setEndDate(event.target.value)} />
          </div>
        </CardContent>
      </Card>

      {loading ? (
        <LoadingPanel label="Loading vouchers..." />
      ) : vouchers.length === 0 ? (
        <Card className="rounded-lg">
          <EmptyState
            icon={FileText}
            title="No accounting vouchers found"
            description="Create a manual journal voucher or change filters."
          />
        </Card>
      ) : (
        <Card className="rounded-lg">
          <CardContent className="p-0">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Date</TableHead>
                  <TableHead>Voucher No</TableHead>
                  <TableHead>Voucher Type</TableHead>
                  <TableHead>Reference Module</TableHead>
                  <TableHead>Reference No</TableHead>
                  <TableHead>Narration</TableHead>
                  <TableHead className="text-right">Total Debit</TableHead>
                  <TableHead className="text-right">Total Credit</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead className="text-right">Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {vouchers.map((voucher) => {
                  const displayStatus = getVoucherDisplayStatus(voucher);
                  const canCancelOrReverse = canCancelOrReverseVoucher(voucher);

                  return (
                    <TableRow key={voucher._id}>
                      <TableCell>{formatAccountingDate(voucher.date)}</TableCell>
                      <TableCell className="font-medium">{voucher.voucherNo}</TableCell>
                      <TableCell>{voucher.voucherTypeCode}</TableCell>
                      <TableCell>{voucher.referenceModule || "-"}</TableCell>
                      <TableCell>{voucher.referenceNo || "-"}</TableCell>
                      <TableCell className="max-w-[280px] truncate">{voucher.narration || "-"}</TableCell>
                      <TableCell className="text-right">{formatAccountingMoney(voucher.totalDebit)}</TableCell>
                      <TableCell className="text-right">{formatAccountingMoney(voucher.totalCredit)}</TableCell>
                      <TableCell>
                        <Badge variant={voucherStatusVariant(displayStatus)}>{displayStatus}</Badge>
                      </TableCell>
                      <TableCell>
                        <div className="flex justify-end gap-2">
                          <Button
                            variant="outline"
                            size="icon-sm"
                            title="View voucher"
                            onClick={() => void viewVoucher(voucher._id)}
                            disabled={Boolean(actionLoading)}
                          >
                            {actionLoading === `view-${voucher._id}` ? (
                              <Loader2 className="h-4 w-4 animate-spin" />
                            ) : (
                              <Eye className="h-4 w-4" />
                            )}
                          </Button>
                          {voucher.status === "DRAFT" && (
                            <Button
                              variant="outline"
                              size="sm"
                              onClick={() => setPendingAction({ id: voucher._id, action: "post" })}
                              disabled={Boolean(actionLoading)}
                            >
                              Post
                            </Button>
                          )}
                          {canCancelOrReverse && (
                            <>
                              <Button
                                variant="outline"
                                size="icon-sm"
                                title="Cancel voucher"
                                onClick={() => setPendingAction({ id: voucher._id, action: "cancel" })}
                                disabled={Boolean(actionLoading)}
                              >
                                <XCircle className="h-4 w-4" />
                              </Button>
                              <Button
                                variant="outline"
                                size="icon-sm"
                                title="Reverse voucher"
                                onClick={() => setPendingAction({ id: voucher._id, action: "reverse" })}
                                disabled={Boolean(actionLoading)}
                              >
                                <RotateCcw className="h-4 w-4" />
                              </Button>
                            </>
                          )}
                        </div>
                      </TableCell>
                    </TableRow>
                  );
                })}
              </TableBody>
            </Table>
          </CardContent>
        </Card>
      )}

      <VoucherDetailsDrawer detail={selectedVoucher} open={detailsOpen} onOpenChange={setDetailsOpen} />

      <ConfirmDialog
        open={Boolean(pendingAction)}
        onOpenChange={(open) => {
          if (!open) setPendingAction(null);
        }}
        title={`${pendingAction?.action === "post" ? "Post" : pendingAction?.action === "cancel" ? "Cancel" : "Reverse"} voucher?`}
        description={`Voucher ${pendingVoucher?.voucherNo || ""} will be ${
          pendingAction?.action === "post" ? "posted" : pendingAction?.action === "cancel" ? "cancelled" : "reversed"
        }.`}
        confirmLabel={pendingAction?.action === "post" ? "Post" : pendingAction?.action === "cancel" ? "Cancel" : "Reverse"}
        variant={pendingAction?.action === "post" ? "default" : "destructive"}
        loading={Boolean(actionLoading)}
        onConfirm={() => {
          if (pendingAction) void runVoucherAction(pendingAction.id, pendingAction.action);
        }}
      />
    </div>
  );
}
