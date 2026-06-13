"use client";

import { useState, useRef, useEffect } from "react";
import { Settings, ScanBarcode, Trash2, Printer, ChevronDown } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Checkbox } from "@/components/ui/checkbox";
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { useReactToPrint } from "react-to-print";
import { productService } from "@/services/productService";
import { businessService } from "@/services/businessService";
import type { Product } from "@/types";
import { toast } from "sonner";
import { cn } from "@/lib/utils";
import { BarcodeLabelTemplate, type BarcodeDisplaySettings } from "@/lib/print/templates/BarcodeLabelTemplate";
import { barcodePageStyle, type BarcodeLabelSize, type BarcodePrinterType } from "@/lib/print/barcodePrintUtils";

type BarcodeRow = {
  id: string;
  productId: string | null;
  productName: string;
  productCode: string;
  barcode: string;
  price: number;
  printQty: number;
};

export default function BarcodeGeneratorPage() {
  const createBlankRow = (): BarcodeRow => ({
    id: Math.random().toString(36).substring(7),
    productId: null,
    productName: "",
    productCode: "",
    barcode: "",
    price: 0,
    printQty: 1,
  });

  const [rows, setRows] = useState<BarcodeRow[]>([createBlankRow()]);
  const [products, setProducts] = useState<Product[]>([]);
  const [businessName, setBusinessName] = useState("ROYAL COLLECTION");
  const [scannerInput, setScannerInput] = useState("");
  const [labelSize, setLabelSize] = useState<BarcodeLabelSize>("50x25");
  const [layoutColumns, setLayoutColumns] = useState<number>(2); // Default: 2UP (2 labels per row)
  const [printerType, setPrinterType] = useState<BarcodePrinterType>("label");
  
  const [displaySettings, setDisplaySettings] = useState<BarcodeDisplaySettings>({
    showHeader: true,
    showItemName: true,
    showPrice: true,
    showBarcodeNumber: true,
    showExtraLines: true,
  });

  const [settingsOpen, setSettingsOpen] = useState(false);
  const [rowSearchTerms, setRowSearchTerms] = useState<Record<string, string>>({});
  const [activeRowSearchIdx, setActiveRowSearchIdx] = useState<number | null>(null);

  const printRef = useRef<HTMLDivElement>(null);
  const scannerInputRef = useRef<HTMLInputElement>(null);
  const dropdownRef = useRef<HTMLDivElement>(null);

  const handlePrint = useReactToPrint({
    contentRef: printRef,
    documentTitle: "Barcode-Labels",
    pageStyle: barcodePageStyle(labelSize, printerType),
  });

  // Load products & business details on mount
  useEffect(() => {
    productService.getAll({ limit: 1000 }).then(res => {
      setProducts(res.data || []);
    }).catch(() => {});

    businessService.getProfile().then(profile => {
      if (profile && profile.businessName) {
        setBusinessName(profile.businessName);
      }
    }).catch(() => {});
  }, []);

  // Click outside listener for searchable dropdown
  useEffect(() => {
    const handleClickOutside = (e: MouseEvent) => {
      if (dropdownRef.current && !dropdownRef.current.contains(e.target as Node)) {
        setActiveRowSearchIdx(null);
      }
    };
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  // Keyboard shortcuts (F2 to add new line, F10 to print)
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === "F2") {
        e.preventDefault();
        handleAddBlankRow();
      } else if (e.key === "F10") {
        e.preventDefault();
        handlePrintLabels();
      }
    };
    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [rows, labelSize, printerType, displaySettings, layoutColumns, businessName]);

  const handleAddBlankRow = () => {
    setRows(prev => [...prev, createBlankRow()]);
    toast.success("New line added");
  };

  const handlePrintLabels = () => {
    const validCount = rows.filter(r => r.productId !== null && r.productName !== "").length;
    if (validCount === 0) {
      toast.error("Please add at least one valid product before printing");
      return;
    }
    handlePrint();
  };

  // Barcode Scanner logic
  const handleScannerKeyDown = async (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === "Enter") {
      e.preventDefault();
      const code = scannerInput.trim();
      if (!code) return;

      try {
        // Find locally first
        let foundProduct = products.find(p => p.barcode === code || p.sku === code);
        
        // Try fallback to API if not loaded
        if (!foundProduct) {
          try {
            foundProduct = await productService.getByBarcode(code);
          } catch (err) {
            // Ignore API error
          }
        }

        if (foundProduct) {
          // Check if already in table
          const existingIdx = rows.findIndex(r => r.productId === foundProduct._id);
          
          if (existingIdx !== -1) {
            setRows(prev => prev.map((r, i) => i === existingIdx ? { ...r, printQty: r.printQty + 1 } : r));
            toast.success(`Qty increased to ${rows[existingIdx].printQty + 1} for ${foundProduct.name}`);
          } else {
            // Add to first empty row or append new row
            const emptyIdx = rows.findIndex(r => r.productId === null && r.productName === "");
            if (emptyIdx !== -1) {
              setRows(prev => prev.map((r, i) => i === emptyIdx ? {
                ...r,
                productId: foundProduct._id,
                productName: foundProduct.name,
                productCode: foundProduct.barcode || foundProduct.sku,
                barcode: foundProduct.barcode || "",
                price: foundProduct.salesPrice || 0,
                printQty: 1,
              } : r));
              toast.success(`Selected product: ${foundProduct.name}`);
            } else {
              setRows(prev => [
                ...prev,
                {
                  id: Math.random().toString(36).substring(7),
                  productId: foundProduct._id,
                  productName: foundProduct.name,
                  productCode: foundProduct.barcode || foundProduct.sku,
                  barcode: foundProduct.barcode || "",
                  price: foundProduct.salesPrice || 0,
                  printQty: 1,
                }
              ]);
              toast.success(`Selected product: ${foundProduct.name}`);
            }
          }
        } else {
          toast.error(`Product not found for barcode: ${code}`);
        }
      } catch (err) {
        toast.error("Failed to lookup barcode product");
      }

      setScannerInput("");
      scannerInputRef.current?.focus();
    }
  };

  const selectProductForRow = (idx: number, product: Product) => {
    setRows(prev => prev.map((row, i) => {
      if (i !== idx) return row;
      return {
        ...row,
        productId: product._id,
        productName: product.name,
        productCode: product.barcode || product.sku,
        barcode: product.barcode || "",
        price: product.salesPrice || 0,
      };
    }));
    setActiveRowSearchIdx(null);
  };

  const removeRow = (idx: number) => {
    const updated = rows.filter((_, i) => i !== idx);
    setRows(updated.length === 0 ? [createBlankRow()] : updated);
  };

  // Build printing lines flat array
  const itemsToPrint = rows
    .filter(r => r.productId !== null && r.productName !== "")
    .flatMap(r => Array.from({ length: r.printQty }, () => r));

  const totalLabelsCount = itemsToPrint.length;

  return (
    <div className="flex flex-col space-y-3 lg:h-[calc(100vh-145px)] lg:max-h-[calc(100vh-145px)] overflow-hidden pt-2 lg:pt-0">
      {/* Global CSS style block for standard browser print (Cmd+P) alignment */}
      <style dangerouslySetInnerHTML={{ __html: `
        @media print {
          body * {
            visibility: hidden !important;
          }
          #barcode-print-container,
          #barcode-print-container * {
            visibility: visible !important;
          }
          #barcode-print-container {
            position: absolute !important;
            left: 0 !important;
            top: 0 !important;
            width: 100% !important;
            height: auto !important;
            background: white !important;
            color: black !important;
            padding: 0 !important;
            margin: 0 !important;
            box-shadow: none !important;
          }
        }
      `}} />

      {/* Top Header */}
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 border-b border-border pb-2 shrink-0">
        <div className="flex items-center gap-3">
          <div className="page-icon-tile">
            <ScanBarcode />
          </div>
          <h1 className="page-title flex items-center gap-2">
            Barcode Generator <span className="text-muted-foreground text-sm font-normal border rounded-full px-2 cursor-help" title="F2 for New Line, F10 to Print">i</span>
          </h1>
        </div>
        <div className="flex items-center gap-4 text-sm">
          <div className="flex items-center gap-2">
            <span className="text-muted-foreground">Printer</span>
            <span className="font-medium capitalize">{printerType === "label" ? "Label Printer" : `A4 (${printerType === "a4_30" ? "30" : "24"}-up)`}</span>
          </div>
          <div className="flex items-center gap-2">
            <span className="text-muted-foreground">Size</span>
            <span className="font-medium">{labelSize}mm</span>
          </div>
          <Button variant="ghost" size="icon" className="text-muted-foreground hover:bg-muted" onClick={() => setSettingsOpen(true)}>
            <Settings className="h-5 w-5" />
          </Button>
        </div>
      </div>

      {/* Main Layout Flex Container: Fits on single screen on desktop */}
      <div className="flex flex-col lg:flex-row gap-6 flex-1 min-h-0 overflow-hidden">
        {/* Left Column: Scanner and Table */}
        <div className="flex-1 lg:max-w-[58%] flex flex-col gap-3 min-h-0 overflow-hidden">
          {/* Scanner Card */}
          <Card className="p-3 bg-card shadow-sm border border-border/80 shrink-0">
            <div className="space-y-1.5">
              <Label className="text-[10px] font-bold uppercase tracking-wider text-muted-foreground">Barcode Scanner</Label>
              <Input
                ref={scannerInputRef}
                placeholder="Scan here and press Enter..."
                value={scannerInput}
                onChange={(e) => setScannerInput(e.target.value)}
                onKeyDown={handleScannerKeyDown}
                className="bg-card w-full h-9"
                autoFocus
              />
            </div>
          </Card>

          {/* Product Entry Table Card */}
          <Card className="flex-1 bg-card shadow-sm border border-border/80 flex flex-col min-h-0 overflow-hidden">
            <div className="flex-1 overflow-y-auto min-h-0">
              <table className="w-full text-sm">
                <thead className="sticky top-0 bg-card z-10">
                  <tr className="border-b bg-muted/40">
                    <th className="p-2 w-12 text-center text-xs font-bold text-muted-foreground uppercase">#</th>
                    <th className="text-left p-2 text-xs font-bold text-muted-foreground uppercase">Product Description</th>
                    <th className="text-center p-2 w-28 text-xs font-bold text-muted-foreground uppercase">Print Qty</th>
                    <th className="text-center p-2 w-16 text-xs font-bold text-muted-foreground uppercase">Action</th>
                  </tr>
                </thead>
                <tbody>
                  {rows.map((row, idx) => {
                    const searchStr = rowSearchTerms[row.id] ?? "";
                    const filteredProducts = products.filter(p => {
                      const q = searchStr.toLowerCase().trim();
                      if (!q) return true;
                      return (
                        p.name.toLowerCase().includes(q) ||
                        p.sku.toLowerCase().includes(q) ||
                        (p.barcode && p.barcode.toLowerCase().includes(q))
                      );
                    }).slice(0, 8);

                    return (
                      <tr key={row.id} className="border-b hover:bg-muted/10">
                        <td className="p-2 text-center font-medium text-muted-foreground">{idx + 1}</td>
                        <td className="p-2">
                          {/* Searchable select dropdown container */}
                          <div className="relative w-full" ref={activeRowSearchIdx === idx ? dropdownRef : null}>
                            {activeRowSearchIdx === idx ? (
                              <div className="relative w-full">
                                <Input
                                  className="w-full bg-card h-9"
                                  placeholder="Type name or code to search..."
                                  value={rowSearchTerms[row.id] ?? ""}
                                  autoFocus
                                  onChange={(e) => {
                                    const val = e.target.value;
                                    setRowSearchTerms(prev => ({ ...prev, [row.id]: val }));
                                  }}
                                  onKeyDown={(e) => {
                                    if (e.key === "Escape") {
                                      setActiveRowSearchIdx(null);
                                    }
                                  }}
                                />
                                <div className="absolute z-50 left-0 right-0 mt-1 max-h-48 overflow-y-auto bg-card border rounded-md shadow-lg py-1 border-border">
                                  {filteredProducts.length === 0 ? (
                                    <div className="px-3 py-2 text-xs text-muted-foreground">No products found</div>
                                  ) : (
                                    filteredProducts.map((p) => (
                                      <button
                                        key={p._id}
                                        type="button"
                                        className="w-full text-left px-3 py-1.5 text-xs hover:bg-accent hover:text-accent-foreground transition-colors cursor-pointer block"
                                        onClick={() => selectProductForRow(idx, p)}
                                      >
                                        <div className="font-semibold">{p.name}</div>
                                        <div className="text-[10px] text-muted-foreground">
                                          SKU: {p.sku} {p.barcode ? `| Barcode: ${p.barcode}` : ""}
                                        </div>
                                      </button>
                                    ))
                                  )}
                                </div>
                              </div>
                            ) : (
                              <button
                                type="button"
                                className="w-full flex items-center justify-between px-3 py-1.5 rounded-md border border-input bg-card text-xs text-left hover:bg-accent/30 cursor-pointer h-9"
                                onClick={() => {
                                  setActiveRowSearchIdx(idx);
                                  setRowSearchTerms(prev => ({ ...prev, [row.id]: row.productName }));
                                }}
                              >
                                <span className={cn("truncate", row.productName ? "text-foreground font-medium" : "text-muted-foreground")}>
                                  {row.productName
                                    ? `${row.productName}${row.productCode ? ` [${row.productCode}]` : ""}`
                                    : "-- Select Product --"}
                                </span>
                                <ChevronDown className="h-4 w-4 shrink-0 opacity-50" />
                              </button>
                            )}
                          </div>
                        </td>
                        <td className="p-2 text-center">
                          <Input
                            type="number"
                            min="1"
                            value={row.printQty}
                            onChange={(e) => {
                              const val = parseInt(e.target.value);
                              setRows(prev => prev.map((r, i) => i === idx ? { ...r, printQty: Number.isNaN(val) || val < 1 ? 1 : val } : r));
                            }}
                            className="w-20 h-9 text-center bg-card mx-auto"
                          />
                        </td>
                        <td className="p-2 text-center">
                          <Button variant="ghost" size="icon" className="h-8 w-8 text-red-500 hover:text-red-600 hover:bg-red-500/10" onClick={() => removeRow(idx)}>
                            <Trash2 className="h-4 w-4" />
                          </Button>
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>
            
            {/* Table Footer with New Line Button */}
            <div className="p-3 border-t bg-muted/10 flex justify-between items-center shrink-0">
              <Button onClick={handleAddBlankRow} variant="outline" size="sm" className="bg-card text-foreground font-semibold h-9">
                + New Line (F2)
              </Button>
            </div>
          </Card>
        </div>

        {/* Right Column: Live Preview & Print button */}
        <div className="w-full lg:w-[42%] flex flex-col min-h-0">
          <Card className="bg-card shadow-sm border border-border/80 flex flex-col h-full min-h-0 overflow-hidden">
            <div className="flex items-center justify-between p-3.5 border-b shrink-0">
              <h2 className="text-xs font-bold text-foreground uppercase tracking-wide">Live Preview</h2>
              <span className="text-[10px] font-bold bg-primary/20 text-primary px-2 py-1 rounded-full">
                Labels: {totalLabelsCount}
              </span>
            </div>

            {/* Preview Labels Sheet Wrapper */}
            <div className="flex-1 p-4 bg-slate-100 dark:bg-slate-900/60 overflow-y-auto min-h-0">
              <div className={cn(
                "grid gap-4 justify-center justify-items-center w-full",
                layoutColumns === 2 ? "grid-cols-2" : "grid-cols-1"
              )}>
                {itemsToPrint.map((item, idx) => (
                  <BarcodeLabelTemplate
                    key={idx}
                    size={labelSize}
                    settings={displaySettings}
                    item={{
                      itemName: item.productName,
                      itemCode: item.barcode || item.productCode,
                      sku: item.productCode,
                      price: item.price,
                      header: businessName,
                    }}
                  />
                ))}
                {itemsToPrint.length === 0 && (
                  <div className="col-span-full h-48 flex flex-col items-center justify-center text-muted-foreground text-center">
                    <ScanBarcode className="h-10 w-10 opacity-20 mb-2" />
                    <p className="text-[11px]">No active barcodes to display.<br />Select products to generate previews.</p>
                  </div>
                )}
              </div>
            </div>

            {/* Bottom Actions inside the card */}
            <div className="p-3 border-t shrink-0">
              <Button
                onClick={handlePrintLabels}
                disabled={totalLabelsCount === 0}
                className="w-full bg-primary text-primary-foreground hover:bg-primary/90 rounded-md font-semibold py-5 text-sm flex items-center justify-center gap-2 cursor-pointer h-10"
              >
                <Printer className="h-4 w-4" /> Print Labels (F10)
              </Button>
            </div>
          </Card>
        </div>
      </div>

      {/* Hidden print element container to avoid showing on page */}
      <div className="absolute left-[-9999px] top-[-9999px] pointer-events-none" aria-hidden="true">
        <div ref={printRef} id="barcode-print-container" className="bg-white text-black p-4">
          <div
            className="barcode-sheet"
            style={{
              display: "grid",
              gap: "3mm",
              gridTemplateColumns: layoutColumns === 2 ? "repeat(2, max-content)" : "1fr",
            }}
          >
            {itemsToPrint.map((item, idx) => (
              <BarcodeLabelTemplate
                key={idx}
                size={labelSize}
                settings={displaySettings}
                item={{
                  itemName: item.productName,
                  itemCode: item.barcode || item.productCode,
                  sku: item.productCode,
                  price: item.price,
                  header: businessName,
                }}
              />
            ))}
          </div>
        </div>
      </div>

      {/* Settings Dialog */}
      <Dialog open={settingsOpen} onOpenChange={setSettingsOpen}>
        <DialogContent className="sm:max-w-md bg-card border border-border max-h-[85vh] flex flex-col overflow-hidden">
          <DialogHeader className="shrink-0">
            <DialogTitle className="text-foreground font-bold">Barcode Label Settings</DialogTitle>
          </DialogHeader>
          <div className="flex-1 overflow-y-auto space-y-4 py-4 text-sm pr-1">
            {/* Label Size Option */}
            <div className="space-y-2">
              <Label className="text-foreground font-medium">Label Size</Label>
              <Select value={labelSize} onValueChange={(value) => setLabelSize(value as BarcodeLabelSize)}>
                <SelectTrigger className="bg-card border-border"><SelectValue /></SelectTrigger>
                <SelectContent className="bg-card border-border">
                  <SelectItem value="50x25">50mm × 25mm</SelectItem>
                  <SelectItem value="40x20">40mm × 20mm</SelectItem>
                  <SelectItem value="38x25">38mm × 25mm</SelectItem>
                </SelectContent>
              </Select>
            </div>

            {/* Layout Options */}
            <div className="space-y-2">
              <Label className="text-foreground font-medium">Layout</Label>
              <Select value={layoutColumns.toString()} onValueChange={(value) => setLayoutColumns(parseInt(value))}>
                <SelectTrigger className="bg-card border-border"><SelectValue /></SelectTrigger>
                <SelectContent className="bg-card border-border">
                  <SelectItem value="1">1 label per row</SelectItem>
                  <SelectItem value="2">2 labels per row (2 UP)</SelectItem>
                </SelectContent>
              </Select>
            </div>

            {/* Printer Type Option */}
            <div className="space-y-2">
              <Label className="text-foreground font-medium">Printer Type</Label>
              <Select value={printerType} onValueChange={(value) => setPrinterType(value as BarcodePrinterType)}>
                <SelectTrigger className="bg-card border-border"><SelectValue /></SelectTrigger>
                <SelectContent className="bg-card border-border">
                  <SelectItem value="label">Thermal Label Printer</SelectItem>
                  <SelectItem value="a4_30">A4 Sheet (30 labels/page)</SelectItem>
                  <SelectItem value="a4_24">A4 Sheet (24 labels/page)</SelectItem>
                </SelectContent>
              </Select>
            </div>

            {/* Display Options Toggles */}
            <div className="space-y-3 pt-2">
              <Label className="text-foreground font-semibold block border-b pb-1 text-xs uppercase tracking-wide text-muted-foreground">Display Options</Label>
              
              <div className="flex items-center justify-between rounded-lg border p-3 border-border">
                <Label htmlFor="toggle-header" className="text-foreground cursor-pointer">Show Header (Business Name)</Label>
                <Checkbox id="toggle-header" checked={displaySettings.showHeader} onCheckedChange={(checked) => setDisplaySettings(prev => ({ ...prev, showHeader: Boolean(checked) }))} />
              </div>

              <div className="flex items-center justify-between rounded-lg border p-3 border-border">
                <Label htmlFor="toggle-item-name" className="text-foreground cursor-pointer">Show Item Name</Label>
                <Checkbox id="toggle-item-name" checked={displaySettings.showItemName} onCheckedChange={(checked) => setDisplaySettings(prev => ({ ...prev, showItemName: Boolean(checked) }))} />
              </div>

              <div className="flex items-center justify-between rounded-lg border p-3 border-border">
                <Label htmlFor="toggle-price" className="text-foreground cursor-pointer">Show Price / MRP</Label>
                <Checkbox id="toggle-price" checked={displaySettings.showPrice} onCheckedChange={(checked) => setDisplaySettings(prev => ({ ...prev, showPrice: Boolean(checked) }))} />
              </div>

              <div className="flex items-center justify-between rounded-lg border p-3 border-border">
                <Label htmlFor="toggle-barcode-number" className="text-foreground cursor-pointer">Show Barcode Number</Label>
                <Checkbox id="toggle-barcode-number" checked={displaySettings.showBarcodeNumber} onCheckedChange={(checked) => setDisplaySettings(prev => ({ ...prev, showBarcodeNumber: Boolean(checked) }))} />
              </div>

              <div className="flex items-center justify-between rounded-lg border p-3 border-border">
                <Label htmlFor="toggle-extra-lines" className="text-foreground cursor-pointer">Show Extra Lines (SKU)</Label>
                <Checkbox id="toggle-extra-lines" checked={displaySettings.showExtraLines} onCheckedChange={(checked) => setDisplaySettings(prev => ({ ...prev, showExtraLines: Boolean(checked) }))} />
              </div>
            </div>
          </div>
          <div className="flex justify-end gap-2 pt-2 border-t border-border shrink-0">
            <Button onClick={() => setSettingsOpen(false)} className="bg-primary text-primary-foreground hover:bg-primary/90 font-semibold px-6">
              Save Settings
            </Button>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  );
}
