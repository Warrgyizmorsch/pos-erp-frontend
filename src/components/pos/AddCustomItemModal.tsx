"use client";

import { useMemo, useState } from "react";
import { Plus, ReceiptText, X } from "lucide-react";
import { toast } from "sonner";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Textarea } from "@/components/ui/textarea";
import { formatCurrency } from "@/lib/utils";
import type { POSItem } from "@/store/posStore";

type CustomItemType = "non_stock_product" | "service";

interface AddCustomItemModalProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  onAdd: (item: Partial<POSItem>) => void;
}

const taxOptions = [0, 5, 12, 18, 28];

const roundMoney = (value: number) => Number((Math.round((value + Number.EPSILON) * 100) / 100).toFixed(2));

const initialForm = {
  itemType: "non_stock_product" as CustomItemType,
  itemName: "",
  description: "",
  quantity: "1",
  rate: "",
  discount: "0",
  taxRate: "0",
};

export function AddCustomItemModal({ open, onOpenChange, onAdd }: AddCustomItemModalProps) {
  const [form, setForm] = useState(initialForm);

  const handleOpenChange = (nextOpen: boolean) => {
    if (!nextOpen) setForm(initialForm);
    onOpenChange(nextOpen);
  };

  const quantity = Math.max(0, Number(form.quantity || 0));
  const rate = Math.max(0, Number(form.rate || 0));
  const discount = Math.max(0, Number(form.discount || 0));
  const taxRate = Math.max(0, Number(form.taxRate || 0));
  const grossAmount = quantity * rate;
  const discountAmount = grossAmount * (discount / 100);
  const taxableAmount = Math.max(0, grossAmount - discountAmount);
  const taxAmount = taxableAmount * (taxRate / 100);
  const totalAmount = taxableAmount + taxAmount;

  const preview = useMemo(() => ({
    grossAmount: roundMoney(grossAmount),
    taxableAmount: roundMoney(taxableAmount),
    taxAmount: roundMoney(taxAmount),
    totalAmount: roundMoney(totalAmount),
  }), [grossAmount, taxableAmount, taxAmount, totalAmount]);

  const handleAdd = () => {
    const itemName = form.itemName.trim();
    if (!itemName) {
      toast.error("Item name is required");
      return;
    }
    if (quantity <= 0) {
      toast.error("Quantity must be greater than zero");
      return;
    }
    if (rate < 0) {
      toast.error("Rate cannot be negative");
      return;
    }
    if (discount < 0 || discount > 100) {
      toast.error("Discount must be between 0 and 100%");
      return;
    }
    if (taxRate < 0) {
      toast.error("GST rate cannot be negative");
      return;
    }

    onAdd({
      productId: null,
      productRef: null,
      product: undefined,
      itemType: form.itemType,
      affectsInventory: false,
      customItem: true,
      itemCode: form.itemType === "service" ? "SERVICE" : "NON-STOCK",
      itemName,
      name: itemName,
      description: form.description.trim(),
      barcode: "",
      quantity,
      unit: "Pcs",
      pricePerUnit: rate,
      rate,
      purchasePrice: 0,
      discount,
      taxPercent: taxRate,
      taxRate,
      taxableAmount: preview.taxableAmount,
      taxAmount: preview.taxAmount,
      total: preview.totalAmount,
      totalAmount: preview.totalAmount,
      isInclusive: false,
      incomeLedger: null,
    });
    toast.success("Custom item added");
    handleOpenChange(false);
  };

  return (
    <Dialog open={open} onOpenChange={handleOpenChange}>
      <DialogContent className="max-w-2xl">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-2">
            <ReceiptText className="h-5 w-5 text-primary" />
            Add Custom Item
          </DialogTitle>
          <DialogDescription>
            Add a non-inventory line that appears on the invoice and does not affect stock.
          </DialogDescription>
        </DialogHeader>

        <div className="grid gap-4 py-2 sm:grid-cols-2">
          <div className="space-y-1.5">
            <Label>Custom Item Type</Label>
            <Select value={form.itemType} onValueChange={(value: CustomItemType) => setForm((prev) => ({ ...prev, itemType: value }))}>
              <SelectTrigger>
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="non_stock_product">Non-Stock Product</SelectItem>
                <SelectItem value="service">Service / Charge</SelectItem>
              </SelectContent>
            </Select>
            <p className="text-xs text-muted-foreground">
              {form.itemType === "service"
                ? "Posts to Service Income / Indirect Income and does not affect stock."
                : "Posts to Sales A/c and does not affect stock."}
            </p>
          </div>

          <div className="space-y-1.5">
            <Label>GST %</Label>
            <Select value={form.taxRate} onValueChange={(value) => setForm((prev) => ({ ...prev, taxRate: value }))}>
              <SelectTrigger>
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                {taxOptions.map((rateOption) => (
                  <SelectItem key={rateOption} value={String(rateOption)}>{rateOption}%</SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          <div className="space-y-1.5 sm:col-span-2">
            <Label>Item Name</Label>
            <Input
              value={form.itemName}
              onChange={(e) => setForm((prev) => ({ ...prev, itemName: e.target.value }))}
              placeholder="Example: Special Product / Mill Charge"
              autoFocus
            />
          </div>

          <div className="space-y-1.5 sm:col-span-2">
            <Label>Description</Label>
            <Textarea
              value={form.description}
              onChange={(e) => setForm((prev) => ({ ...prev, description: e.target.value }))}
              placeholder="Optional"
              rows={2}
            />
          </div>

          <div className="space-y-1.5">
            <Label>Quantity</Label>
            <Input
              type="number"
              min="0.01"
              step="any"
              value={form.quantity}
              onChange={(e) => setForm((prev) => ({ ...prev, quantity: e.target.value }))}
            />
          </div>

          <div className="space-y-1.5">
            <Label>Rate</Label>
            <Input
              type="number"
              min="0"
              step="0.01"
              value={form.rate}
              onChange={(e) => setForm((prev) => ({ ...prev, rate: e.target.value }))}
              placeholder="0.00"
            />
          </div>

          <div className="space-y-1.5">
            <Label>Discount %</Label>
            <Input
              type="number"
              min="0"
              max="100"
              step="0.5"
              value={form.discount}
              onChange={(e) => setForm((prev) => ({ ...prev, discount: e.target.value }))}
            />
          </div>

          <div className="rounded-lg border bg-muted/25 p-3 text-sm">
            <div className="flex justify-between"><span className="text-muted-foreground">Taxable</span><span className="font-semibold">{formatCurrency(preview.taxableAmount)}</span></div>
            <div className="mt-1 flex justify-between"><span className="text-muted-foreground">GST</span><span className="font-semibold">{formatCurrency(preview.taxAmount)}</span></div>
            <div className="mt-2 flex justify-between border-t pt-2 font-bold"><span>Total</span><span>{formatCurrency(preview.totalAmount)}</span></div>
          </div>
        </div>

        <DialogFooter>
          <Button type="button" variant="outline" onClick={() => handleOpenChange(false)} className="gap-2">
            <X className="h-4 w-4" /> Cancel
          </Button>
          <Button type="button" onClick={handleAdd} className="gap-2">
            <Plus className="h-4 w-4" /> Add Item
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
