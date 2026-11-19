class OpeningStockPayload {
  final String openingStockDate;
  final String? notes;
  final List<OpeningStockPayloadItem> items;

  OpeningStockPayload({
    required this.openingStockDate,
    this.notes,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'openingStockDate': openingStockDate,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
      'items': items.map((i) => i.toJson()).toList(),
    };
  }
}

class OpeningStockPayloadItem {
  final String? product;
  final String? productId;
  final String itemName;
  final String productName;
  final String name;
  final String? sku;
  final String? barcode;
  final String unit;
  final double quantity;
  final double purchasePrice;
  final double salesPrice;
  final double taxRate;
  final String? hsnCode;
  final String openingStockDate;
  final bool isNewProduct;

  OpeningStockPayloadItem({
    this.product,
    this.productId,
    required this.itemName,
    required this.productName,
    required this.name,
    this.sku,
    this.barcode,
    required this.unit,
    required this.quantity,
    required this.purchasePrice,
    required this.salesPrice,
    required this.taxRate,
    this.hsnCode,
    required this.openingStockDate,
    required this.isNewProduct,
  });

  Map<String, dynamic> toJson() {
    return {
      'product': product,
      'productId': productId,
      'itemName': itemName,
      'productName': productName,
      'name': name,
      if (sku != null && sku!.isNotEmpty) 'sku': sku,
      if (barcode != null && barcode!.isNotEmpty) 'barcode': barcode,
      'unit': unit,
      'quantity': quantity,
      'purchasePrice': purchasePrice,
      'salesPrice': salesPrice,
      'taxRate': taxRate,
      'hsnCode': hsnCode,
      'openingStockDate': openingStockDate,
      'isNewProduct': isNewProduct,
    };
  }
}
