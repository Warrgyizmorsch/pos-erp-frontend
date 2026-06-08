"use client";

import { CheckCircle2, FileText, Loader2 } from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
} from "@/components/ui/sheet";
import {
  Table,
  TableBody,
  TableCell,
  TableFooter,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import type { VoucherDetail, VoucherStatus } from "@/types/accounting";

export const formatAccountingMoney = (value: number) =>
  new Intl.NumberFormat("en-IN", {
    style: "currency",
    currency: "INR",
    minimumFractionDigits: 2,
  }).format(Number(value || 0));

export const formatAccountingDate = (value?: string) => {
  if (!value) return "-";
  return new Intl.DateTimeFormat("en-IN", {
    day: "2-digit",
    month: "short",
    year: "numeric",
  }).format(new Date(value));
};

export const getAccountingErrorMessage = (error: unknown, fallback = "Accounting request failed") => {
  if (
    error
    && typeof error === "object"
    && "response" in error
    && error.response
    && typeof error.response === "object"
    && "data" in error.response
    && error.response.data
    && typeof error.response.data === "object"
    && "message" in error.response.data
    && typeof error.response.data.message === "string"
  ) {
    return error.response.data.message;
  }

  if (error instanceof Error) return error.message;
  return fallback;
};

export const getVoucherDisplayStatus = (voucher: {
  status: VoucherStatus;
  reversalVoucherId?: unknown;
}): VoucherStatus => {
  if (voucher.status === "POSTED" && voucher.reversalVoucherId) {
    return "REVERSED";
  }

  return voucher.status;
};

export const voucherStatusVariant = (status: VoucherStatus) => {
  if (status === "POSTED") return "success";
  if (status === "DRAFT") return "warning";
  return "secondary";
};

export function LoadingPanel({ label }: { label: string }) {
  return (
    <Card className="rounded-lg">
      <CardContent className="flex min-h-52 items-center justify-center gap-2 p-6 text-muted-foreground">
        <Loader2 className="h-4 w-4 animate-spin" />
        {label}
      </CardContent>
    </Card>
  );
}

export function VoucherDetailsDrawer({
  detail,
  open,
  onOpenChange,
}: {
  detail: VoucherDetail | null;
  open: boolean;
  onOpenChange: (open: boolean) => void;
}) {
  const voucher = detail?.voucher;
  const displayStatus = voucher ? getVoucherDisplayStatus(voucher) : "DRAFT";
  const balanced = detail
    ? Number(detail.voucher.totalDebit || 0).toFixed(2) === Number(detail.voucher.totalCredit || 0).toFixed(2)
    : false;

  return (
    <Sheet open={open} onOpenChange={onOpenChange}>
      <SheetContent className="w-full overflow-y-auto sm:max-w-3xl">
        <SheetHeader>
          <SheetTitle>{voucher ? `Voucher ${voucher.voucherNo}` : "Voucher Details"}</SheetTitle>
          <SheetDescription>
            Header and double-entry ledger lines for this voucher.
          </SheetDescription>
        </SheetHeader>

        {detail && (
          <div className="mt-6 space-y-5">
            <div className="grid gap-3 rounded-lg border border-border bg-muted/20 p-4 text-sm md:grid-cols-3">
              <div>
                <p className="text-muted-foreground">Date</p>
                <p className="mt-1 font-medium">{formatAccountingDate(detail.voucher.date)}</p>
              </div>
              <div>
                <p className="text-muted-foreground">Voucher Type</p>
                <p className="mt-1 font-medium">{detail.voucher.voucherTypeCode}</p>
              </div>
              <div>
                <p className="text-muted-foreground">Status</p>
                <Badge className="mt-1" variant={voucherStatusVariant(displayStatus)}>
                  {displayStatus}
                </Badge>
              </div>
              <div>
                <p className="text-muted-foreground">Reference Module</p>
                <p className="mt-1 font-medium">{detail.voucher.referenceModule || "-"}</p>
              </div>
              <div>
                <p className="text-muted-foreground">Reference No</p>
                <p className="mt-1 font-medium">{detail.voucher.referenceNo || "-"}</p>
              </div>
              <div>
                <p className="text-muted-foreground">Posted At</p>
                <p className="mt-1 font-medium">{formatAccountingDate(detail.voucher.postedAt)}</p>
              </div>
              <div className="md:col-span-3">
                <p className="text-muted-foreground">Narration</p>
                <p className="mt-1 font-medium">{detail.voucher.narration || "-"}</p>
              </div>
              {detail.voucher.cancelledAt && (
                <div className="md:col-span-3">
                  <p className="text-muted-foreground">Cancelled At</p>
                  <p className="mt-1 font-medium">{formatAccountingDate(detail.voucher.cancelledAt)}</p>
                </div>
              )}
            </div>

            <div className="overflow-hidden rounded-lg border border-border">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Ledger</TableHead>
                    <TableHead>Group</TableHead>
                    <TableHead className="text-right">Debit</TableHead>
                    <TableHead className="text-right">Credit</TableHead>
                    <TableHead>Narration</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {detail.entries.map((entry) => (
                    <TableRow key={entry._id}>
                      <TableCell>
                        <p className="font-medium">{entry.ledgerId?.name || entry.ledgerName}</p>
                        <p className="text-xs text-muted-foreground">{entry.ledgerId?.code}</p>
                      </TableCell>
                      <TableCell>{entry.ledgerId?.groupId?.name || "-"}</TableCell>
                      <TableCell className="text-right">
                        {entry.debit ? formatAccountingMoney(entry.debit) : "-"}
                      </TableCell>
                      <TableCell className="text-right">
                        {entry.credit ? formatAccountingMoney(entry.credit) : "-"}
                      </TableCell>
                      <TableCell>{entry.narration || "-"}</TableCell>
                    </TableRow>
                  ))}
                </TableBody>
                <TableFooter>
                  <TableRow>
                    <TableCell colSpan={2}>Total</TableCell>
                    <TableCell className="text-right">{formatAccountingMoney(detail.voucher.totalDebit)}</TableCell>
                    <TableCell className="text-right">{formatAccountingMoney(detail.voucher.totalCredit)}</TableCell>
                    <TableCell>
                      <Badge variant={balanced ? "success" : "warning"} className="gap-1">
                        {balanced && <CheckCircle2 className="h-3.5 w-3.5" />}
                        {balanced ? "Balanced" : "Not Balanced"}
                      </Badge>
                    </TableCell>
                  </TableRow>
                </TableFooter>
              </Table>
            </div>
          </div>
        )}
      </SheetContent>
    </Sheet>
  );
}

export function VoucherViewButton({
  loading,
  onClick,
}: {
  loading?: boolean;
  onClick: () => void;
}) {
  return (
    <Button variant="outline" size="icon-sm" title="View voucher" onClick={onClick} disabled={loading}>
      {loading ? <Loader2 className="h-4 w-4 animate-spin" /> : <FileText className="h-4 w-4" />}
    </Button>
  );
}
