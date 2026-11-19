class PurchaseItem {
  final String? product;
  final String name;
  final String? sku;
  final String? barcode;
  final double quantity;
  final double purchasePrice;
  final double salesPrice;
  final double taxRate;
  final double taxAmount;
  final double total;

  PurchaseItem({
    this.product,
    required this.name,
    this.sku,
    this.barcode,
    this.quantity = 1,
    this.purchasePrice = 0,
    this.salesPrice = 0,
    this.taxRate = 0,
    this.taxAmount = 0,
    this.total = 0,
  });

  factory PurchaseItem.fromJson(Map<String, dynamic> json) {
    dynamic prod;
    if (json['product'] != null) {
      if (json['product'] is Map<String, dynamic>) {
        prod = json['product']['_id'] ?? json['product']['id'];
      } else {
        prod = json['product'].toString();
      }
    }

    final double q =
        (json['quantity'] as num?)?.toDouble() ??
        (json['qty'] as num?)?.toDouble() ??
        1.0;
    final double rate =
        (json['purchasePrice'] as num?)?.toDouble() ??
        (json['purchaseRate'] as num?)?.toDouble() ??
        (json['price'] as num?)?.toDouble() ??
        0.0;
    final double tot = (json['total'] as num?)?.toDouble() ?? (q * rate);

    return PurchaseItem(
      product: prod,
      name:
          json['name']?.toString() ??
          json['itemName']?.toString() ??
          'Product Item',
      sku: json['sku']?.toString(),
      barcode: json['barcode']?.toString(),
      quantity: q,
      purchasePrice: rate,
      salesPrice: (json['salesPrice'] as num?)?.toDouble() ?? 0.0,
      taxRate: (json['taxRate'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0.0,
      total: tot,
    );
  }
}
