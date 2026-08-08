class BarcodeConfig {
  final String productName;
  final String barcodeValue;
  final double price;
  final String businessName;
  final int copies;
  final bool showPrice;
  final bool showBusinessName;
  final bool showProductName;
  final String labelSize; // e.g., '50mm x 25mm'

  BarcodeConfig({
    required this.productName,
    required this.barcodeValue,
    required this.price,
    required this.businessName,
    this.copies = 10,
    this.showPrice = true,
    this.showBusinessName = true,
    this.showProductName = true,
    this.labelSize = '50mm x 25mm',
  });

  BarcodeConfig copyWith({
    String? productName,
    String? barcodeValue,
    double? price,
    String? businessName,
    int? copies,
    bool? showPrice,
    bool? showBusinessName,
    bool? showProductName,
    String? labelSize,
  }) {
    return BarcodeConfig(
      productName: productName ?? this.productName,
      barcodeValue: barcodeValue ?? this.barcodeValue,
      price: price ?? this.price,
      businessName: businessName ?? this.businessName,
      copies: copies ?? this.copies,
      showPrice: showPrice ?? this.showPrice,
      showBusinessName: showBusinessName ?? this.showBusinessName,
      showProductName: showProductName ?? this.showProductName,
      labelSize: labelSize ?? this.labelSize,
    );
  }
}
