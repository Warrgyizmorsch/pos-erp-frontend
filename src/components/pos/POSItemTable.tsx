import React, { useState, useRef, useEffect, useCallback } from "react";
import { usePOSStore, WALK_IN_CUSTOMER, type POSItem } from "@/store/posStore";
import { formatCurrency, formatNumberInputValue, cn } from "@/lib/utils";
import { Trash2, Loader2, PackagePlus, ScanBarcode, X, Plus, ChevronDown, Calendar, User, ReceiptText, MoreVertical, Pencil, Percent, Ruler } from "lucide-react";
import { productService } from "@/services/productService";
import { customerService } from "@/services/customerService";
import { useDebounce } from "@/hooks/useDebounce";
import { useBarcodeScanner } from "@/hooks/useBarcodeScanner";
import type { Customer, Product, ProductPriceOption } from "@/types";
import { toast } from "sonner";
import { SimpleProductModal } from "@/components/shared/SimpleProductModal";
import { CustomerModal } from "@/components/shared/CustomerModal";
import { AddCustomItemModal } from "@/components/pos/AddCustomItemModal";
import { ModifyItemModal } from "@/components/pos/ModifyItemModal";
import { ActionModals, type ActionModalType } from "@/components/pos/ActionModals";
import { POSBillTopBar } from "@/components/pos/POSBillTopBar";


const getItemTypeLabel = (item: POSItem) => {
  if (item.itemType === "service") return "Service";
  if (item.itemType === "non_stock_product") return "Non-Stock";
  return "Inventory";
};

const getItemTypeClass = (item: POSItem) => {
  if (item.itemType === "service") return "bg-sky-500/10 text-sky-600 border-sky-500/20";
  if (item.itemType === "non_stock_product") return "bg-violet-500/10 text-violet-600 border-violet-500/20";
  return "bg-emerald-500/10 text-emerald-600 border-emerald-500/20";
};

const TableCellInput = React.forwardRef<HTMLInputElement, React.InputHTMLAttributes<HTMLInputElement>>(({ className, ...props }, ref) => {
  return (
    <input
      ref={ref}
      className={cn(
        "w-full bg-transparent border-none outline-none ring-0 shadow-none px-2 py-1 text-center font-semibold tabular-nums",
        "focus:outline-none focus:ring-0 focus:border-none focus-visible:ring-0 focus-visible:outline-none",
        className
      )}
      {...props}
    />
  );
});
TableCellInput.displayName = "TableCellInput";

const parseQuantityInput = (value: string) => {
  if (value === "") return 0;
  const quantity = Number(value);
  return Number.isFinite(quantity) ? Math.max(0, quantity) : 0;
};

type PendingPriceSelection = {
  product: Product;
  targetItemId: string;
  options: ProductPriceOption[];
};

// POSBillTopBar extracted to separate file


export function POSItemTable() {

  const qtyRefs = useRef<Record<string, HTMLInputElement | null>>({});
  const priceRefs = useRef<Record<string, HTMLInputElement | null>>({});
  const discountRefs = useRef<Record<string, HTMLInputElement | null>>({});
  const nextBarcodeRefs = useRef<Record<string, HTMLInputElement | null>>({});

  const focusCell = (itemId: string, field: "quantity" | "price" | "discount" | "barcode") => {
    setTimeout(() => {
      let input: HTMLInputElement | null = null;
      if (field === "quantity") input = qtyRefs.current[itemId];
      if (field === "price") input = priceRefs.current[itemId];
      if (field === "discount") input = discountRefs.current[itemId];
      if (field === "barcode") input = nextBarcodeRefs.current[itemId];
      
      if (input) {
        input.focus();
        input.select();
      }
    }, 50);
  };

  const { activeBillId, getActiveBill, updateItem, updateItemProduct, removeItem, selectRow, addItem, setActiveModal, activeModal } = usePOSStore();
  const bill = getActiveBill();
  const [editItem, setEditItem] = useState<POSItem | null>(null);
  const tableViewportRef = useRef<HTMLDivElement>(null);

  // Barcode editing state
  const [editingBarcodeId, setEditingBarcodeId] = useState<string | null>(null);
  const [barcodeQuery, setBarcodeQuery] = useState("");
  const [barcodeResults, setBarcodeResults] = useState<Product[]>([]);
  const [barcodeLoading, setBarcodeLoading] = useState(false);
  const [barcodeDropdownOpen, setBarcodeDropdownOpen] = useState(false);
  const [barcodeHlIdx, setBarcodeHlIdx] = useState(0);
  const barcodeResultsRef = useRef<Product[]>([]);
  const barcodeHlIdxRef = useRef(0);
  const barcodeInputRef = useRef<HTMLInputElement>(null);
  const barcodeDropdownRef = useRef<HTMLDivElement>(null);
  const resetBarcodeScannerRef = useRef<(() => void) | null>(null);

  const [showProductModal, setShowProductModal] = useState(false);
  const [showCustomItemModal, setShowCustomItemModal] = useState(false);
  const [scannedBarcode, setScannedBarcode] = useState("");
  const [pendingPriceSelection, setPendingPriceSelection] = useState<PendingPriceSelection | null>(null);

  const debouncedBarcodeQuery = useDebounce(barcodeQuery, 250);

  const focusBarcode = (item: POSItem, index: number) => {
    selectRow(index);
    setEditingBarcodeId(item.id);
    setBarcodeQuery(item.itemName === "" ? "" : (item.barcode || item.itemCode || ""));
    // The useEffect will automatically focus the barcode input
  };

  const handleCustomTab = (
    e: React.KeyboardEvent, 
    itemId: string, 
    currentField: "barcode" | "quantity" | "price" | "discount",
    idx: number
  ) => {
    if (e.key === "Tab") {
      e.preventDefault();
      const prevItem = bill?.items[idx - 1];
      const nextItem = bill?.items[idx + 1];

      if (!e.shiftKey) {
        if (currentField === "barcode") focusCell(itemId, "quantity");
        else if (currentField === "quantity") focusCell(itemId, "price");
        else if (currentField === "price") focusCell(itemId, "discount");
        else if (currentField === "discount") {
          if (nextItem) focusBarcode(nextItem, idx + 1);
        }
      } else {
        if (currentField === "quantity") {
           const currentItem = bill?.items[idx];
           if (currentItem) focusBarcode(currentItem, idx);
        }
        else if (currentField === "price") focusCell(itemId, "quantity");
        else if (currentField === "discount") focusCell(itemId, "price");
        else if (currentField === "barcode") {
          if (prevItem) focusCell(prevItem.id, "discount");
        }
      }
    }
  };

  const handleRowClick = (item: POSItem, idx: number) => {
    selectRow(idx);
    // Only open modify modal for non-placeholder items
    if (item.itemName !== "") {
      setEditItem(item);
    }
  };

  const applyProductPrice = useCallback((product: Product, targetItemId: string, priceOption?: ProductPriceOption | null, requiresSelection = false) => {
    const price = Number(priceOption?.salePrice ?? priceOption?.salesPrice ?? product.salesPrice ?? 0);
    const tax = product.taxRate || 0;
    const incl = (product as any).salesTaxType === "with";
    updateItemProduct(targetItemId, {
      productId: product._id,
      productRef: product._id,
      batchId: priceOption?.batchId || null,
      selectedPriceType: priceOption?.label || null,
      priceLabel: priceOption?.label || "",
      mrp: Number(priceOption?.mrp ?? price),
      availableQty: Number(priceOption?.availableQty || 0),
      priceSelectionRequired: requiresSelection,
      product,
      itemType: "inventory",
      affectsInventory: true,
      itemCode: product.sku,
      itemName: product.name,
      name: product.name,
      description: product.description || "",
      barcode: priceOption?.barcode || product.barcode,
      pricePerUnit: price,
      rate: price,
      purchasePrice: Number(priceOption?.purchasePrice || product.purchasePrice || 0),
      taxPercent: Number(priceOption?.taxPercent ?? priceOption?.taxRate ?? tax),
      taxRate: Number(priceOption?.taxPercent ?? priceOption?.taxRate ?? tax),
      unit: product.unit || "Pcs",
      isInclusive: incl,
      customItem: false,
    });
    focusCell(targetItemId, "quantity");
    setEditingBarcodeId(null);
    setBarcodeQuery("");
    setBarcodeResults([]);
    barcodeResultsRef.current = [];
    setBarcodeDropdownOpen(false);
    resetBarcodeScannerRef.current?.();
  }, [updateItemProduct]);

  const handleAddProduct = useCallback(async (product: Product, targetItemId: string) => {
    try {
      const pricing = await productService.getPriceOptions(product._id);
      const options = pricing.priceOptions || [];
      if (options.length > 1) {
        setPendingPriceSelection({ product: pricing.product || product, targetItemId, options });
        setBarcodeDropdownOpen(false);
        return;
      }
      applyProductPrice(pricing.product || product, targetItemId, options[0] || pricing.defaultPrice || null, false);
    } catch {
      applyProductPrice(product, targetItemId, null, false);
    }
  }, [applyProductPrice, setPendingPriceSelection]);

  const handleSelectPrice = (option: ProductPriceOption) => {
    if (!pendingPriceSelection) return;
    applyProductPrice(pendingPriceSelection.product, pendingPriceSelection.targetItemId, option, true);
    setPendingPriceSelection(null);
  };

  // Barcode scanner hook — scans fill the active placeholder row
  const { reset: resetBarcodeScanner } = useBarcodeScanner({
    onScan: async (barcode) => {
      try {
        const { data } = await productService.getAll({ search: barcode, limit: 1 });
        const match = data.find(p => p.barcode === barcode || p.sku === barcode);
        if (match && bill) {
          // Find the last placeholder row to fill
          const placeholderItem = bill.items.find(i => i.itemName === "");
          if (placeholderItem) {
            await handleAddProduct(match, placeholderItem.id);
            toast.success(`Scanned: ${match.name}`);
          } else {
            // All rows filled, add a new item
            addItem({
              productId: match._id,
              productRef: match._id,
              product: match,
              itemType: "inventory",
              affectsInventory: true,
              itemCode: match.sku,
              itemName: match.name,
              name: match.name,
              description: match.description || "",
              barcode: match.barcode,
              pricePerUnit: match.salesPrice || 0,
              rate: match.salesPrice || 0,
              taxPercent: match.taxRate || 0,
              taxRate: match.taxRate || 0,
              unit: match.unit || "Pcs",
            });
            toast.success(`Scanned: ${match.name}`);
          }
        } else {
          toast.error("Product not found for barcode: " + barcode);
          // Don't automatically open the modal - let the user explicitly click "Add New Product"
          // setScannedBarcode(barcode);
          // setShowProductModal(true);
        }
      } catch {
        toast.error("Failed to lookup barcode");
      }
    },
    onError: (err) => toast.error(err)
  });
  resetBarcodeScannerRef.current = resetBarcodeScanner;

  // Search products when barcode query changes
  useEffect(() => {
    if (!debouncedBarcodeQuery.trim()) {
      setBarcodeResults([]);
      barcodeResultsRef.current = [];
      setBarcodeDropdownOpen(false);
      return;
    }
    (async () => {
      setBarcodeLoading(true);
      try {
        const { data } = await productService.getAll({ search: debouncedBarcodeQuery, limit: 8 });
        setBarcodeResults(data);
        barcodeResultsRef.current = data;
        setBarcodeHlIdx(0);
        barcodeHlIdxRef.current = 0;
        setBarcodeDropdownOpen(true);
        // Exact barcode match — auto-select
        const exact = data.find(p => p.barcode === debouncedBarcodeQuery || p.sku === debouncedBarcodeQuery);
        if (exact && data.length === 1 && editingBarcodeId) {
          handleAddProduct(exact, editingBarcodeId);
        }
      } catch {} finally {
        setBarcodeLoading(false);
      }
    })();
  }, [debouncedBarcodeQuery]);


  // Auto-focus barcode input when editingBarcodeId changes
  useEffect(() => {
    if (editingBarcodeId) {
      setTimeout(() => barcodeInputRef.current?.focus({ preventScroll: true }), 50);
    }
  }, [editingBarcodeId]);

  useEffect(() => {
    requestAnimationFrame(() => {
      tableViewportRef.current?.scrollTo({ top: 0, left: 0 });
    });
  }, [activeBillId]);

  // Auto-focus selected placeholder row, or clear editing state for non-placeholders
  useEffect(() => {
    if (bill) {
      const selectedItem = bill.items[bill.selectedRowIndex];
      if (selectedItem) {
        if (selectedItem.itemName === "") {
          setEditingBarcodeId(selectedItem.id);
        } else if (editingBarcodeId !== selectedItem.id) {
          setEditingBarcodeId(null);
        }
      }
    }
  }, [bill?.selectedRowIndex, bill?.items?.[bill.selectedRowIndex]?.id]);

  // Click outside to close barcode dropdown
  useEffect(() => {
    const h = (e: MouseEvent) => {
      if (barcodeDropdownRef.current && !barcodeDropdownRef.current.contains(e.target as Node)) {
        setBarcodeDropdownOpen(false);
      }
    };
    document.addEventListener("mousedown", h);
    return () => document.removeEventListener("mousedown", h);
  }, []);

  const handleBarcodeKeyDown = (e: React.KeyboardEvent, itemId: string) => {
    if (e.key === "ArrowDown") {
      e.preventDefault();
      e.stopPropagation();
      setBarcodeHlIdx(p => { const n = Math.min(p + 1, barcodeResultsRef.current.length - 1); barcodeHlIdxRef.current = n; return n; });
    } else if (e.key === "ArrowUp") {
      e.preventDefault();
      e.stopPropagation();
      setBarcodeHlIdx(p => { const n = Math.max(p - 1, 0); barcodeHlIdxRef.current = n; return n; });
    } else if (e.key === "Enter") {
      e.preventDefault();
      e.stopPropagation();
      const cur = barcodeResultsRef.current[barcodeHlIdxRef.current];
      if (cur) {
        handleAddProduct(cur, itemId);
      }
    } else if (e.key === "Escape" || e.key === "Tab") {
      setBarcodeDropdownOpen(false);
      setEditingBarcodeId(null);
      setBarcodeQuery("");
    }
  };

  // Handle inline discount change
  const handleDiscountChange = (itemId: string, value: string) => {
    const discount = Math.max(0, Math.min(100, Number(value) || 0));
    updateItem(itemId, { discount });
  };

  if (!bill) return null;

  const realItems = bill.items.filter(i => i.itemName !== "");
  const EMPTY_ROWS = Math.max(0, 18 - bill.items.length);

  return (
    <div ref={barcodeDropdownRef} className="flex flex-col flex-1 min-h-0 overflow-hidden relative">
      <POSBillTopBar onAddCustomItem={() => setShowCustomItemModal(true)} />

      {/* Mobile Card-based Cart List */}
      <div className="flex flex-1 flex-col gap-3 overflow-y-auto bg-background p-3 lg:hidden">
        {bill.items.filter(i => i.itemName !== "").map((item, idx) => {
          const actualIdx = bill.items.indexOf(item);
          const sel = bill.selectedRowIndex === actualIdx;
          return (
            <div
              key={item.id}
              onClick={() => handleRowClick(item, actualIdx)}
              className={cn(
                "relative cursor-pointer space-y-3 rounded-lg border p-4 transition-all",
                sel 
                  ? "bg-primary/[0.06] border-primary/40 shadow-sm" 
                  : "bg-card border-border/50 hover:bg-muted/10"
              )}
            >
              <div className="flex items-start justify-between gap-2">
                <div>
                  <div className="flex items-center gap-2">
                    <span className={cn(
                      "text-[10px] font-black px-2 py-0.5 rounded transition-colors",
                      sel ? "bg-primary text-primary-foreground" : "bg-muted text-muted-foreground"
                    )}>
                      #{idx + 1}
                    </span>
                    <span className="text-xs font-mono font-semibold text-muted-foreground">
                      {item.barcode || item.itemCode || "—"}
                    </span>
                  </div>
                  <div className="mt-1.5 flex flex-wrap items-center gap-2">
                    <h4 className="text-sm font-bold text-foreground">{item.itemName || "—"}</h4>
                    <span className={cn("rounded-full border px-2 py-0.5 text-[9px] font-black uppercase", getItemTypeClass(item))}>
                      {getItemTypeLabel(item)}
                    </span>
                    {item.priceLabel && (
                      <span className={cn(
                        "rounded-full border px-2 py-0.5 text-[9px] font-black uppercase",
                        item.priceLabel.toLowerCase().includes("old")
                          ? "border-amber-500/25 bg-amber-500/10 text-amber-600"
                          : "border-primary/25 bg-primary/10 text-primary"
                      )}>
                        {item.priceLabel}
                      </span>
                    )}
                  </div>
                  {item.description && <p className="mt-1 line-clamp-2 text-xs text-muted-foreground">{item.description}</p>}
                </div>
                
                <button
                  onClick={(e) => { e.stopPropagation(); removeItem(item.id); }}
                  className="p-2 rounded-lg hover:bg-destructive/10 text-muted-foreground hover:text-destructive transition-colors shrink-0"
                >
                  <Trash2 className="h-4 w-4" />
                </button>
              </div>
              
              <div className="grid grid-cols-4 gap-2 pt-2 border-t border-border/10 text-xs">
                <div>
                  <span className="text-muted-foreground block text-[10px] uppercase font-bold tracking-wider mb-0.5">Qty</span>
                  <span className="font-bold text-sm text-foreground">{item.quantity} {item.unit}</span>
                </div>
                <div>
                  <span className="text-muted-foreground block text-[10px] uppercase font-bold tracking-wider mb-0.5">Price</span>
                  <span className="font-semibold text-sm text-foreground">{formatCurrency(item.pricePerUnit)}</span>
                </div>
                <div>
                  <span className="text-muted-foreground block text-[10px] uppercase font-bold tracking-wider mb-0.5">Disc%</span>
                  <span className="font-semibold text-sm text-foreground">{item.discount}%</span>
                </div>
                <div className="text-right">
                  <span className="text-muted-foreground block text-[10px] uppercase font-bold tracking-wider mb-0.5">Total</span>
                  <span className="font-black text-sm text-primary">{formatCurrency(item.total)}</span>
                </div>
              </div>
              
              {item.taxPercent > 0 && (
                <div className="text-[10px] text-muted-foreground flex items-center justify-between pt-1 opacity-70">
                  <span>Tax ({item.taxPercent}% GST):</span>
                  <span className="font-medium">{formatCurrency(item.taxAmount)}</span>
                </div>
              )}
            </div>
          );
        })}
        {realItems.length === 0 && (
          <div className="flex flex-1 flex-col items-center justify-center rounded-lg border border-dashed border-border/70 bg-card px-6 py-12 text-center text-muted-foreground">
            <ScanBarcode className="h-9 w-9 opacity-45" />
            <p className="mt-3 text-sm font-bold text-foreground">Start billing</p>
            <p className="mt-1 text-xs">Scan barcode or search product to add items</p>
          </div>
        )}
      </div>

      {/* Desktop Table View */}
      <div ref={tableViewportRef} className="hidden flex-1 min-h-0 overflow-hidden bg-background lg:block">
        <table className="w-full table-fixed border-collapse">
          <thead className="sticky top-0 z-10">
            <tr className="whitespace-nowrap border-b border-border/80 bg-muted/60 backdrop-blur-md dark:bg-muted/35">
              <th className="w-[34px] border-r border-border/70 px-1.5 py-2 text-center text-[10px] font-black uppercase tracking-wider text-muted-foreground">#</th>
              <th className="w-[12%] border-r border-border/70 px-2 py-2 text-left text-[10px] font-black uppercase tracking-wider text-muted-foreground">
                Barcode
              </th>
              <th className="w-[25%] border-r border-border/70 px-2 py-2 text-left text-[10px] font-black uppercase tracking-wider text-muted-foreground">Item Name</th>
              <th className="w-[7%] border-r border-border/70 px-1.5 py-2 text-center text-[10px] font-black uppercase tracking-wider text-muted-foreground">Qty</th>
              <th className="w-[6%] border-r border-border/70 px-1.5 py-2 text-center text-[10px] font-black uppercase tracking-wider text-muted-foreground">Unit</th>
              <th className="w-[10%] border-r border-border/70 px-2 py-2 text-right text-[10px] font-black uppercase tracking-wider text-muted-foreground">
                Price(₹)
              </th>
              <th className="w-[7%] border-r border-border/70 px-1.5 py-2 text-center text-[10px] font-black uppercase tracking-wider text-muted-foreground">
                Disc%
              </th>
              <th className="w-[10%] border-r border-border/70 px-2 py-2 text-right text-[10px] font-black uppercase tracking-wider text-muted-foreground">
                Tax(₹)
              </th>
              <th className="w-[11%] border-r border-border/70 px-2 py-2 text-right text-[10px] font-black uppercase tracking-wider text-muted-foreground">
                Total(₹)
              </th>
              <th className="w-[44px] px-1.5 py-2 text-center text-[10px] font-black uppercase tracking-wider text-muted-foreground">Action</th>
            </tr>
          </thead>
          <tbody>
            {bill.items.map((item, idx) => {
              const sel = bill.selectedRowIndex === idx;
              const isPlaceholder = item.itemName === "";
              const isEditingBarcode = editingBarcodeId === item.id;

              return (
                <tr
                  key={item.id}
                  onClick={() => {
                    selectRow(idx);
                    if (isPlaceholder) {
                      setEditingBarcodeId(item.id);
                      setBarcodeQuery("");
                    }
                  }}
                  className={cn(
                    "group h-9 cursor-pointer border-b border-border/70 transition-all duration-150",
                    "hover:bg-muted/20 dark:hover:bg-muted/15",
                    sel && "bg-primary/10 dark:bg-primary/15",
                    isPlaceholder && "bg-muted/5 dark:bg-muted/5"
                  )}
                >
                  {/* # */}
                  <td className="border-r border-border/60 px-1.5 py-1 text-center">
                    <span className={cn(
                      "inline-flex h-5 w-5 items-center justify-center rounded-full text-[8px] font-bold transition-colors",
                      sel ? "bg-primary text-primary-foreground" : "bg-muted/60 dark:bg-muted/50 text-muted-foreground"
                    )}>
                      {idx + 1}
                    </span>
                  </td>

                  {/* Barcode — Editable */}
                  <td className="relative border-r border-border/60 px-1.5 py-1" onClick={(e) => {
                    e.stopPropagation();
                    selectRow(idx);
                    setEditingBarcodeId(item.id);
                    setBarcodeQuery(isPlaceholder ? "" : (item.barcode || item.itemCode || ""));
                  }}>
                    {isEditingBarcode ? (
                      <div className="relative">
                        <TableCellInput
                          ref={(el) => { 
                            barcodeInputRef.current = el; 
                            if (el) nextBarcodeRefs.current[item.id] = el; 
                          }}
                          data-barcode-input="true"
                          value={barcodeQuery}
                          onChange={(e) => setBarcodeQuery(e.target.value)}
                          onKeyDown={(e) => {
                            handleCustomTab(e, item.id, "barcode", bill.items.indexOf(item));
                            if (e.key !== "Tab") handleBarcodeKeyDown(e, item.id);
                          }}
                          onFocus={() => { if (barcodeQuery.trim() && barcodeResults.length > 0) setBarcodeDropdownOpen(true); }}
                          placeholder="Scan/Type..."
                          className="h-6 w-full rounded bg-primary/5 px-1.5 text-[11px] font-mono font-semibold transition-all placeholder:text-muted-foreground/40"
                        />
                        <div className="absolute right-1.5 top-1/2 -translate-y-1/2">
                          {barcodeLoading ? (
                            <Loader2 className="h-3 w-3 animate-spin text-muted-foreground" />
                          ) : (
                            <ScanBarcode className="h-3 w-3 text-muted-foreground opacity-40" />
                          )}
                        </div>

                        {/* Suggestions dropdown */}
                        {barcodeDropdownOpen && (
                          <div className="absolute left-0 top-full z-50 mt-1 w-[520px] overflow-hidden rounded-lg border border-border bg-card shadow-2xl shadow-black/25">
                            <div className="grid grid-cols-12 border-b border-border/50 bg-muted/50 px-3 py-2 text-[9px] font-black uppercase tracking-[0.1em] text-muted-foreground">
                              <div className="col-span-3">Barcode</div>
                              <div className="col-span-5">Item Name</div>
                              <div className="col-span-2 text-center">Stock</div>
                              <div className="col-span-2 text-right">Price (₹)</div>
                            </div>
                            <div className="max-h-[200px] overflow-y-auto">
                              {barcodeResults.length > 0 ? barcodeResults.map((p, i) => (
                                <div
                                  key={p._id}
                                  onClick={(e) => { e.stopPropagation(); handleAddProduct(p, item.id); }}
                                  onMouseEnter={() => { setBarcodeHlIdx(i); barcodeHlIdxRef.current = i; }}
                                  className={cn(
                                    "grid cursor-pointer grid-cols-12 items-center border-b border-border/10 px-3 py-2 transition-colors last:border-0",
                                    i === barcodeHlIdx ? "bg-primary/10" : "hover:bg-muted/40"
                                  )}
                                >
                                  <div className="col-span-3 text-xs font-mono font-semibold truncate">{p.barcode || p.sku}</div>
                                  <div className="col-span-5 text-xs font-medium truncate">{p.name}</div>
                                  <div className="col-span-2 text-center text-xs">
                                    <span className={cn("font-bold", (p.stock || 0) <= 0 ? "text-destructive" : "text-emerald-500")}>{p.stock || 0}</span>
                                    <span className="text-[9px] text-muted-foreground ml-1">{p.unit || "Pcs"}</span>
                                  </div>
                                  <div className="col-span-2 text-right text-xs font-bold">{formatCurrency(p.salesPrice || 0)}</div>
                                </div>
                              )) : (
                                <div className="space-y-2 p-4 text-center">
                                  <p className="text-xs font-semibold text-foreground">No product found</p>
                                  <p className="text-[10px] text-muted-foreground">No match for "<strong>{barcodeQuery}</strong>"</p>
                                  <div className="flex items-center justify-center gap-3">
                                    <button onClick={(e) => { 
                                      e.stopPropagation();
                                      setScannedBarcode(barcodeQuery); 
                                      setShowProductModal(true); 
                                      setBarcodeDropdownOpen(false); 
                                      setEditingBarcodeId(null);
                                      setBarcodeQuery("");
                                    }} className="flex items-center gap-1 text-[10px] font-semibold text-emerald-500 hover:underline">
                                      <PackagePlus className="h-3 w-3" /> Add New Product
                                    </button>
                                  </div>
                                </div>
                              )}
                            </div>
                          </div>
                        )}
                      </div>
                    ) : (
                      <span className={cn(
                        "block truncate text-[11px] font-mono font-semibold",
                        isPlaceholder ? "text-muted-foreground/40 italic" : ""
                      )}>
                        {isPlaceholder ? "Click to scan..." : (item.barcode || item.itemCode || "—")}
                      </span>
                    )}
                  </td>

                  {/* Item Name */}
                  <td className="border-r border-border/60 px-2 py-1" title={isPlaceholder ? "" : (item.itemName || "—")}>
                    <span className={cn(
                      "block truncate text-[12px] font-semibold leading-tight text-foreground",
                      isPlaceholder ? "text-muted-foreground/30 italic" : ""
                    )}>
                      {isPlaceholder ? "" : (item.itemName || "—")}
                    </span>
                    {!isPlaceholder && (
                      <div className="mt-0.5 flex items-center gap-1.5">
                        <span className={cn("rounded-full border px-1.5 py-0.5 text-[8px] font-black uppercase leading-none", getItemTypeClass(item))}>
                          {getItemTypeLabel(item)}
                        </span>
                        {item.priceLabel && (
                          <span className={cn(
                            "rounded-full border px-1.5 py-0.5 text-[8px] font-black uppercase leading-none",
                            item.priceLabel.toLowerCase().includes("old")
                              ? "border-amber-500/25 bg-amber-500/10 text-amber-600"
                              : "border-primary/25 bg-primary/10 text-primary"
                          )}>
                            {item.priceLabel}
                          </span>
                        )}
                        {item.description && <span className="truncate text-[9px] text-muted-foreground">{item.description}</span>}
                      </div>
                    )}
                  </td>

                  {/* Qty */}
                  <td className="border-r border-border/60 px-1 py-1 text-center" onClick={(e) => e.stopPropagation()}>
                    {!isPlaceholder ? (
                      <TableCellInput
                        id={`qty-${item.id}`}
                        ref={(el) => { if (el) qtyRefs.current[item.id] = el; }}
                        onKeyDown={(e) => handleCustomTab(e, item.id, "quantity", bill.items.indexOf(item))}
                        type="number"
                        min="0.01"
                        step="any"
                        value={item.quantity || ""}
                        onChange={(e) => updateItem(item.id, { quantity: parseQuantityInput(e.target.value) })}
                        onBlur={(e) => {
                          if (parseQuantityInput(e.currentTarget.value) <= 0) updateItem(item.id, { quantity: 1 });
                        }}
                        className="h-6 rounded bg-muted/20 text-[12px]"
                      />
                    ) : null}
                  </td>

                  {/* Unit */}
                  <td className="border-r border-border/60 px-1 py-1 text-center text-[11px] font-semibold text-muted-foreground">
                    {isPlaceholder ? "" : item.unit}
                  </td>

                  {/* Price */}
                  <td className="border-r border-border/60 px-1 py-1 text-right" onClick={(e) => e.stopPropagation()}>
                    {!isPlaceholder ? (
                      <TableCellInput
                        type="number"
                        min="0"
                        step="0.01"
                        value={formatNumberInputValue(item.pricePerUnit)}
                        ref={(el) => { if (el) priceRefs.current[item.id] = el; }}
                        onKeyDown={(e) => handleCustomTab(e, item.id, "price", bill.items.indexOf(item))}
                        onChange={(e) => updateItem(item.id, { pricePerUnit: Math.max(0, Number(e.target.value)) })}
                        className="h-6 rounded bg-muted/20 text-right text-[12px] font-semibold"
                      />
                    ) : null}
                  </td>

                  {/* Discount % — Editable for real items */}
                  <td className="border-r border-border/60 px-1 py-1 text-center" onClick={(e) => e.stopPropagation()}>
                    {!isPlaceholder ? (
                      <TableCellInput
                        type="number"
                        min="0"
                        max="100"
                        step="0.5"
                        value={item.discount || ""}
                        ref={(el) => { if (el) discountRefs.current[item.id] = el; }}
                        onKeyDown={(e) => handleCustomTab(e, item.id, "discount", bill.items.indexOf(item))}
                        onChange={(e) => handleDiscountChange(item.id, e.target.value)}
                        placeholder="0"
                        className="h-6 rounded bg-muted/20 text-[12px]"
                      />
                    ) : null}
                  </td>

                  {/* Tax */}
                  <td className="border-r border-border/60 px-1.5 py-1 text-right">
                    {!isPlaceholder && (
                      <>
                        <span className="text-[12px] tabular-nums">{formatCurrency(item.taxAmount)}</span>
                        {item.taxPercent > 0 && (
                          <span className="block text-[9px] text-muted-foreground">{item.taxPercent}% GST</span>
                        )}
                      </>
                    )}
                  </td>

                  {/* Total */}
                  <td className="border-r border-border/60 px-1.5 py-1 text-right">
                    {!isPlaceholder && (
                      <span className="whitespace-nowrap text-[12px] font-black tabular-nums tracking-tight">{formatCurrency(item.total)}</span>
                    )}
                  </td>
                  <td className="px-1 py-1 text-center">
                    {!isPlaceholder && (
                      <div className="relative inline-flex group/actions">
                        <button
                          type="button"
                          onClick={(e) => e.stopPropagation()}
                          className="flex h-6 w-6 items-center justify-center rounded text-muted-foreground transition-colors hover:bg-muted hover:text-foreground"
                        >
                          <MoreVertical className="h-3.5 w-3.5" />
                        </button>
                        <div className="invisible absolute right-0 top-full z-40 mt-1 min-w-[150px] overflow-hidden rounded-md border border-border bg-card p-1 text-left opacity-0 shadow-xl transition-all group-hover/actions:visible group-hover/actions:opacity-100">
                          <button onClick={(e) => { e.stopPropagation(); setEditItem(item); }} className="flex w-full items-center gap-2 rounded px-2.5 py-2 text-xs font-semibold hover:bg-muted">
                            <Pencil className="h-3.5 w-3.5" /> Edit item
                          </button>
                          <button onClick={(e) => { e.stopPropagation(); selectRow(idx); setActiveModal("itemDisc"); }} className="flex w-full items-center gap-2 rounded px-2.5 py-2 text-xs font-semibold hover:bg-muted">
                            <Percent className="h-3.5 w-3.5" /> Add discount
                          </button>
                          <button onClick={(e) => { e.stopPropagation(); selectRow(idx); setActiveModal("unit"); }} className="flex w-full items-center gap-2 rounded px-2.5 py-2 text-xs font-semibold hover:bg-muted">
                            <Ruler className="h-3.5 w-3.5" /> Change unit
                          </button>
                          <button onClick={(e) => { e.stopPropagation(); removeItem(item.id); }} className="flex w-full items-center gap-2 rounded px-2.5 py-2 text-xs font-semibold text-destructive hover:bg-destructive/10">
                            <Trash2 className="h-3.5 w-3.5" /> Remove item
                          </button>
                        </div>
                      </div>
                    )}
                  </td>
                </tr>
              );
            })}

            {/* Empty filler rows */}
            {Array.from({ length: EMPTY_ROWS }).map((_, i) => (
              <tr key={`e-${i}`} className="h-9 border-b border-border/30">
                <td className="border-r border-border/30" />
                <td className="border-r border-border/30" />
                <td className="border-r border-border/30" />
                <td className="border-r border-border/30" />
                <td className="border-r border-border/30" />
                <td className="border-r border-border/30" />
                <td className="border-r border-border/30" />
                <td className="border-r border-border/30" />
                <td className="border-r border-border/30" />
                <td />
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* Modify Item Modal */}
      <ModifyItemModal
        item={editItem}
        onClose={() => setEditItem(null)}
      />

      {/* Product Modal */}
      <SimpleProductModal 
        open={showProductModal} 
        onOpenChange={setShowProductModal}
        initialBarcode={scannedBarcode}
        initialSku={scannedBarcode.length > 5 ? `SKU-${scannedBarcode.slice(-4)}` : undefined}
        onSuccess={(product) => {
          // Add to the last placeholder if available
          if (bill) {
            const placeholder = bill.items.find(i => i.itemName === "");
            if (placeholder) {
              handleAddProduct(product, placeholder.id);
            } else {
              addItem({
                productId: product._id,
                productRef: product._id,
                product,
                itemType: "inventory",
                affectsInventory: true,
                itemCode: product.sku,
                itemName: product.name,
                name: product.name,
                description: product.description || "",
                barcode: product.barcode,
                pricePerUnit: product.salesPrice || 0,
                rate: product.salesPrice || 0,
                taxPercent: product.taxRate || 0,
                taxRate: product.taxRate || 0,
                unit: product.unit || "Pcs",
              });
            }
          }
          toast.success("Product created and added to cart!");
        }}
      />

      <AddCustomItemModal
        open={showCustomItemModal}
        onOpenChange={setShowCustomItemModal}
        onAdd={(item) => addItem(item)}
      />

      {pendingPriceSelection && (
        <div className="fixed inset-0 z-[100] flex items-center justify-center">
          <div
            className="absolute inset-0 bg-black/55 backdrop-blur-sm"
            onClick={() => setPendingPriceSelection(null)}
          />
          <div className="relative mx-4 w-full max-w-2xl overflow-hidden rounded-lg border border-border bg-card shadow-2xl shadow-black/30">
            <div className="flex items-start justify-between gap-4 border-b border-border/60 px-5 py-4">
              <div>
                <h2 className="text-lg font-black tracking-tight text-foreground">Select Selling Price</h2>
                <p className="mt-1 text-xs text-muted-foreground">
                  This product has multiple stock prices. Select the price for billing.
                </p>
                <p className="mt-2 text-sm font-semibold text-foreground">
                  {pendingPriceSelection.product.name}
                  <span className="ml-2 font-mono text-xs text-muted-foreground">
                    {pendingPriceSelection.product.barcode || pendingPriceSelection.product.sku}
                  </span>
                </p>
              </div>
              <button
                type="button"
                onClick={() => setPendingPriceSelection(null)}
                className="rounded-md p-1 text-muted-foreground transition-colors hover:bg-muted hover:text-foreground"
              >
                <X className="h-4 w-4" />
              </button>
            </div>
            <div className="max-h-[420px] overflow-y-auto p-4">
              <div className="grid gap-3">
                {pendingPriceSelection.options.map((option) => {
                  const disabled = Number(option.availableQty || 0) <= 0;
                  return (
                    <button
                      key={option.batchId || `${option.salePrice}-${option.createdAt}`}
                      type="button"
                      disabled={disabled}
                      onClick={() => handleSelectPrice(option)}
                      className={cn(
                        "grid grid-cols-[1fr_auto] items-center gap-4 rounded-lg border p-4 text-left transition-all",
                        option.isCurrent ? "border-primary/50 bg-primary/5" : "border-border bg-muted/10 hover:bg-muted/25",
                        disabled && "cursor-not-allowed opacity-50"
                      )}
                    >
                      <div className="min-w-0">
                        <div className="flex flex-wrap items-center gap-2">
                          <span className="text-sm font-black text-foreground">{option.label}</span>
                          {option.isCurrent && (
                            <span className="rounded-full bg-primary/15 px-2 py-0.5 text-[10px] font-bold uppercase text-primary">
                              Current
                            </span>
                          )}
                          {!option.isCurrent && (
                            <span className="rounded-full bg-amber-500/10 px-2 py-0.5 text-[10px] font-bold uppercase text-amber-600">
                              Old Price
                            </span>
                          )}
                        </div>
                        <div className="mt-2 grid gap-2 text-xs text-muted-foreground sm:grid-cols-3">
                          <span>Available: <strong className="text-foreground">{option.availableQty}</strong></span>
                          <span>Purchase: <strong className="text-foreground">{formatCurrency(option.purchasePrice || 0)}</strong></span>
                          <span>Batch: <strong className="text-foreground">{option.batchNo || "-"}</strong></span>
                        </div>
                      </div>
                      <div className="text-right">
                        <div className="text-lg font-black text-foreground">{formatCurrency(option.salePrice || 0)}</div>
                        <div className="text-[10px] font-bold uppercase text-muted-foreground">Select price</div>
                      </div>
                    </button>
                  );
                })}
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Action Modals for keyboard shortcuts */}
      <ActionModals
        type={activeModal}
        onClose={() => setActiveModal(null)}
      />
    </div>
  );
}

// Extracted models have been moved to separate files.
