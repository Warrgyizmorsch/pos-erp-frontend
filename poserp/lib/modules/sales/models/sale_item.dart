class SaleItem {
  final String? product;
  final String? productId;
  final String itemType;
  final bool affectsInventory;
  final String itemName;
  final String? name;
  final String? description;
  final String? sku;
  final double quantity;
  final double rate;
  final double unitPrice;
  final double purchasePrice;
  final double discount;
  final double taxRate;
  final double gstRate;
  final double taxableAmount;
  final double taxAmount;
  final double totalAmount;
  final double total;

  SaleItem({
    this.product,
    this.productId,
    this.itemType = 'inventory',
    this.affectsInventory = true,
    required this.itemName,
    this.name,
    this.description,
    this.sku,
    this.quantity = 1,
    this.rate = 0,
    this.unitPrice = 0,
    this.purchasePrice = 0,
    this.discount = 0,
    this.taxRate = 0,
    this.gstRate = 0,
    this.taxableAmount = 0,
    this.taxAmount = 0,
    this.totalAmount = 0,
    this.total = 0,
  });

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    dynamic prod;
    if (json['product'] != null) {
      if (json['product'] is Map<String, dynamic>) {
        prod = json['product']['_id'] ?? json['product']['id'];
      } else {
        prod = json['product'].toString();
      }
    }

    final String nameStr =
        json['itemName']?.toString() ??
        json['name']?.toString() ??
        'Custom Item';

    final double rateVal =
        (json['rate'] as num?)?.toDouble() ??
        (json['unitPrice'] as num?)?.toDouble() ??
        0.0;

    final double totVal =
        (json['totalAmount'] as num?)?.toDouble() ??
        (json['total'] as num?)?.toDouble() ??
        0.0;

    return SaleItem(
      product: prod,
      productId: json['productId']?.toString() ?? prod,
      itemType: json['itemType']?.toString() ?? 'inventory',
      affectsInventory: json['affectsInventory'] as bool? ?? true,
      itemName: nameStr,
      name: json['name']?.toString(),
      description: json['description']?.toString(),
      sku: json['sku']?.toString(),
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1.0,
      rate: rateVal,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? rateVal,
      purchasePrice: (json['purchasePrice'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      taxRate:
          (json['taxRate'] as num?)?.toDouble() ??
          (json['gstRate'] as num?)?.toDouble() ??
          0.0,
      gstRate: (json['gstRate'] as num?)?.toDouble() ?? 0.0,
      taxableAmount: (json['taxableAmount'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: totVal,
      total: totVal,
    );
  }
}
