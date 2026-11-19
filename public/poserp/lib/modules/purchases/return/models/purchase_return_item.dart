class PurchaseReturnItem {
  final String id;
  final dynamic product; // Product ID string or Map
  final String barcode;
  final String itemName;
  final double purchasedQty;
  final double alreadyReturnedQty;
  final double returnQty;
  final String unit;
  final double purchasePrice;
  final double discountAmount; // Original unit discount
  final double taxPercent;
  final double taxAmount;
  final double returnAmount;
  final String reason;

  PurchaseReturnItem({
    required this.id,
    this.product,
    required this.barcode,
    required this.itemName,
    required this.purchasedQty,
    required this.alreadyReturnedQty,
    required this.returnQty,
    required this.unit,
    required this.purchasePrice,
    required this.discountAmount,
    required this.taxPercent,
    required this.taxAmount,
    required this.returnAmount,
    required this.reason,
  });

  factory PurchaseReturnItem.fromJson(Map<String, dynamic> json) {
    dynamic p;
    if (json['product'] != null) {
      if (json['product'] is Map<String, dynamic>) {
        p = json['product']['_id'] ?? json['product']['id'];
      } else {
        p = json['product'].toString();
      }
    }

    final double pQty = (json['purchasedQty'] as num?)?.toDouble() ?? 0.0;
    final double rQty =
        (json['returnQty'] as num?)?.toDouble() ??
        (json['returnableQty'] as num?)?.toDouble() ??
        0.0;
    final double price = (json['purchasePrice'] as num?)?.toDouble() ?? 0.0;
    final double taxPct = (json['taxPercent'] as num?)?.toDouble() ?? 0.0;
    final double disc = (json['discountAmount'] as num?)?.toDouble() ?? 0.0;

    double taxAmt = (json['taxAmount'] as num?)?.toDouble() ?? 0.0;
    double totAmt = (json['returnAmount'] as num?)?.toDouble() ?? 0.0;

    if (totAmt == 0.0 && rQty > 0) {
      final base = (rQty * price) - disc;
      taxAmt = (base * taxPct) / 100;
      totAmt = base + taxAmt;
    }

    return PurchaseReturnItem(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      product: p,
      barcode: json['barcode']?.toString() ?? '',
      itemName:
          json['itemName']?.toString() ?? json['name']?.toString() ?? 'Item',
      purchasedQty: pQty,
      alreadyReturnedQty:
          (json['alreadyReturnedQty'] as num?)?.toDouble() ?? 0.0,
      returnQty: rQty,
      unit: json['unit']?.toString() ?? 'piece',
      purchasePrice: price,
      discountAmount: disc,
      taxPercent: taxPct,
      taxAmount: taxAmt,
      returnAmount: totAmt,
      reason: json['reason']?.toString() ?? 'Other',
    );
  }

  Map<String, dynamic> toJson() {
    String prodId = '';
    if (product != null) {
      if (product is Map) {
        prodId = product['_id']?.toString() ?? product['id']?.toString() ?? '';
      } else {
        prodId = product.toString();
      }
    }

    return {
      if (prodId.isNotEmpty) 'product': prodId,
      'barcode': barcode,
      'itemName': itemName,
      'purchasedQty': purchasedQty,
      'alreadyReturnedQty': alreadyReturnedQty,
      'returnQty': returnQty,
      'unit': unit,
      'purchasePrice': purchasePrice,
      'discountAmount': discountAmount * returnQty,
      'taxPercent': taxPercent,
      'reason': reason,
    };
  }
}
