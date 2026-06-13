import Barcode from "react-barcode";
import { barcodeSizeMap, type BarcodeLabelSize } from "../barcodePrintUtils";

export interface PrintableBarcodeItem {
  itemName: string;
  itemCode: string;
  sku?: string;
  price?: string | number;
  header?: string;
}

export interface BarcodeDisplaySettings {
  showHeader: boolean;
  showItemName: boolean;
  showPrice: boolean;
  showBarcodeNumber: boolean;
  showExtraLines: boolean;
}

export function BarcodeLabelTemplate({
  item,
  size,
  settings,
}: {
  item: PrintableBarcodeItem;
  size: BarcodeLabelSize;
  settings: BarcodeDisplaySettings;
}) {
  const dimensions = barcodeSizeMap[size];
  const compact = size === "40x20";
  
  // Calculate vertical space constraints dynamically
  let finalBarcodeHeight = dimensions.barcodeHeight;
  let activeLinesCount = 0;
  if (settings.showHeader) activeLinesCount++;
  if (settings.showItemName) activeLinesCount++;
  if (settings.showBarcodeNumber) activeLinesCount++;
  if (settings.showPrice || settings.showExtraLines) activeLinesCount++;

  if (size === "50x25") {
    if (activeLinesCount >= 4) {
      finalBarcodeHeight = 20;
    } else if (activeLinesCount === 3) {
      finalBarcodeHeight = 25;
    } else {
      finalBarcodeHeight = 32;
    }
  } else if (size === "40x20") {
    if (activeLinesCount >= 4) {
      finalBarcodeHeight = 12;
    } else if (activeLinesCount === 3) {
      finalBarcodeHeight = 16;
    } else {
      finalBarcodeHeight = 22;
    }
  } else if (size === "38x25") {
    if (activeLinesCount >= 4) {
      finalBarcodeHeight = 20;
    } else if (activeLinesCount === 3) {
      finalBarcodeHeight = 24;
    } else {
      finalBarcodeHeight = 27;
    }
  }

  // Format price safely
  const formattedPrice = item.price !== undefined && item.price !== null
    ? `MRP: ₹${item.price}`
    : "";

  return (
    <div
      className="barcode-label flex flex-col items-center justify-between overflow-hidden border border-slate-300 dark:border-slate-700 bg-white p-1 text-black select-none box-border"
      style={{
        width: `${dimensions.width}mm`,
        height: `${dimensions.height}mm`,
      }}
    >
      {/* 1. Header (Business Name) */}
      {settings.showHeader && item.header && (
        <div className="w-full text-center leading-none truncate font-bold text-slate-950 uppercase tracking-wide" style={{ fontSize: compact ? "7px" : "9.5px" }}>
          {item.header}
        </div>
      )}
      
      {/* 2. Product Name */}
      {settings.showItemName && item.itemName && (
        <div className="w-full text-center leading-none truncate font-semibold text-slate-900" style={{ fontSize: compact ? "7px" : "9px" }}>
          {item.itemName}
        </div>
      )}

      {/* 3. Barcode SVG */}
      <div className="flex items-center justify-center overflow-hidden my-0.5 w-full max-h-full">
        {item.itemCode ? (
          <Barcode
            value={item.itemCode}
            format="CODE128"
            width={compact ? 1.05 : 1.35}
            height={finalBarcodeHeight}
            displayValue={false}
            margin={0}
            background="transparent"
          />
        ) : (
          <div className="text-slate-400 text-[8px] font-medium">No Code</div>
        )}
      </div>

      {/* 4. Barcode Number digits (if enabled) */}
      {settings.showBarcodeNumber && item.itemCode && (
        <div className="w-full text-center leading-none font-extrabold tracking-widest text-slate-950 font-mono" style={{ fontSize: compact ? "7px" : "8.5px" }}>
          {item.itemCode}
        </div>
      )}

      {/* 5. Bottom Extra / Price Line */}
      {(settings.showPrice || settings.showExtraLines) && (
        <div className="w-full flex justify-between items-center px-1 font-extrabold text-slate-950 leading-none" style={{ fontSize: compact ? "6.5px" : "8.5px" }}>
          {settings.showExtraLines && item.sku ? (
            <span className="truncate max-w-[50%]">{item.sku}</span>
          ) : (
            <span />
          )}
          {settings.showPrice && formattedPrice ? (
            <span className="shrink-0">{formattedPrice}</span>
          ) : (
            <span />
          )}
        </div>
      )}
    </div>
  );
}
