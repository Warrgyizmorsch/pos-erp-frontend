class SaleReturnItem {
  final String? product;
  final String? saleItemId;
  final String itemType;
  final bool affectsInventory;
  final String barcode;
  final String itemName;
  final double soldQty;
  final double alreadyReturnedQty;
  final double returnQty;
  final String unit;
  final double pricePerUnit;
  final double discountAmount;
  final double taxPercent;
  final String reason;
  final String stockAction;

  SaleReturnItem({
    this.product,
    this.saleItemId,
    this.itemType = 'inventory',
    this.affectsInventory = true,
    this.barcode = '',
    required this.itemName,
    this.soldQty = 0,
    this.alreadyReturnedQty = 0,
    this.returnQty = 0,
    this.unit = 'Pcs',
    this.pricePerUnit = 0,
    this.discountAmount = 0,
    this.taxPercent = 0,
    this.reason = 'Other',
    this.stockAction = 'restore_stock',
  });

  factory SaleReturnItem.fromJson(Map<String, dynamic> json) {
    dynamic prod;
    if (json['product'] != null) {
      if (json['product'] is Map<String, dynamic>) {
        prod = json['product']['_id'] ?? json['product']['id'];
      } else {
        prod = json['product'].toString();
      }
    }

    return SaleReturnItem(
      product: prod,
      saleItemId: json['saleItemId']?.toString(),
      itemType: json['itemType']?.toString() ?? 'inventory',
      affectsInventory: json['affectsInventory'] as bool? ?? true,
      barcode: json['barcode']?.toString() ?? '',
      itemName: json['itemName']?.toString() ?? 'Item',
      soldQty: (json['soldQty'] as num?)?.toDouble() ?? 0.0,
      alreadyReturnedQty:
          (json['alreadyReturnedQty'] as num?)?.toDouble() ?? 0.0,
      returnQty: (json['returnQty'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit']?.toString() ?? 'Pcs',
      pricePerUnit: (json['pricePerUnit'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
      taxPercent: (json['taxPercent'] as num?)?.toDouble() ?? 0.0,
      reason: json['reason']?.toString() ?? 'Other',
      stockAction: json['stockAction']?.toString() ?? 'restore_stock',
    );
  }

  double get returnableQty =>
      (soldQty - alreadyReturnedQty).clamp(0.0, double.infinity);

  double get lineTaxable =>
      (returnQty * pricePerUnit) - (discountAmount * returnQty);

  double get lineTax => (lineTaxable * taxPercent) / 100.0;

  double get lineTotal => lineTaxable + lineTax;
}
