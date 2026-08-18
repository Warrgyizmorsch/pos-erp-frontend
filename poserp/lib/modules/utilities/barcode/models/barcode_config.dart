class BarcodeRow {
  final String id;
  String? productId;
  String productName;
  String productCode;
  String barcode;
  double price;
  int printQty;

  BarcodeRow({
    required this.id,
    this.productId,
    this.productName = '',
    this.productCode = '',
    this.barcode = '',
    this.price = 0.0,
    this.printQty = 1,
  });
}

class BarcodeDisplaySettings {
  final String labelSize; // '50x25', '40x20', '38x25'
  final int layoutColumns; // 1 or 2
  final String printerType; // 'label', 'a4_30', 'a4_24'
  final bool showHeader; // Business Name
  final bool showItemName;
  final bool showPrice;
  final bool showBarcodeNumber;
  final bool showExtraLines; // SKU

  BarcodeDisplaySettings({
    this.labelSize = '50x25',
    this.layoutColumns = 2,
    this.printerType = 'label',
    this.showHeader = true,
    this.showItemName = true,
    this.showPrice = true,
    this.showBarcodeNumber = true,
    this.showExtraLines = true,
  });

  BarcodeDisplaySettings copyWith({
    String? labelSize,
    int? layoutColumns,
    String? printerType,
    bool? showHeader,
    bool? showItemName,
    bool? showPrice,
    bool? showBarcodeNumber,
    bool? showExtraLines,
  }) {
    return BarcodeDisplaySettings(
      labelSize: labelSize ?? this.labelSize,
      layoutColumns: layoutColumns ?? this.layoutColumns,
      printerType: printerType ?? this.printerType,
      showHeader: showHeader ?? this.showHeader,
      showItemName: showItemName ?? this.showItemName,
      showPrice: showPrice ?? this.showPrice,
      showBarcodeNumber: showBarcodeNumber ?? this.showBarcodeNumber,
      showExtraLines: showExtraLines ?? this.showExtraLines,
    );
  }
}
