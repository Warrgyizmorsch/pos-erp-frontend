class ProductPayload {
  final String name;
  final String sku;
  final String? barcode;
  final String? description;
  final String category;
  final String? subcategoryId;
  final double stock;
  final double lowStockThreshold;
  final String unit;
  final List<String> images;
  final String? image;
  final String? hsnCode;
  final double salesPrice;
  final double purchasePrice;
  final double taxRate;
  final String salesTaxType;
  final String purchaseTaxType;
  final double openingStockPrice;
  final String? openingStockDate;

  ProductPayload({
    required this.name,
    required this.sku,
    this.barcode,
    this.description,
    required this.category,
    this.subcategoryId,
    this.stock = 0,
    this.lowStockThreshold = 10,
    this.unit = 'piece',
    this.images = const [],
    this.image,
    this.hsnCode,
    this.salesPrice = 0,
    this.purchasePrice = 0,
    this.taxRate = 0,
    this.salesTaxType = 'without',
    this.purchaseTaxType = 'without',
    this.openingStockPrice = 0,
    this.openingStockDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sku': sku,
      if (barcode != null && barcode!.isNotEmpty) 'barcode': barcode,
      if (description != null && description!.isNotEmpty)
        'description': description,
      'category': category,
      if (subcategoryId != null && subcategoryId!.isNotEmpty)
        'subcategoryId': subcategoryId,
      'stock': stock,
      'lowStockThreshold': lowStockThreshold,
      'unit': unit,
      'images': images,
      if (image != null) 'image': image,
      if (hsnCode != null && hsnCode!.isNotEmpty) 'hsnCode': hsnCode,
      'salesPrice': salesPrice,
      'purchasePrice': purchasePrice,
      'taxRate': taxRate,
      'salesTaxType': salesTaxType,
      'purchaseTaxType': purchaseTaxType,
      'openingStockPrice': openingStockPrice,
      if (openingStockDate != null) 'openingStockDate': openingStockDate,
    };
  }
}
