import '../../products/models/product.dart';

class POSItem {
  final String id;
  final String? productId;
  final Product? product;
  final String itemType; // "inventory", "non_stock_product", "service"
  final bool affectsInventory;
  final String itemCode;
  final String itemName;
  final String? description;
  final bool customItem;
  final double quantity;
  final String unit;
  final double pricePerUnit;
  final double rate;
  final double purchasePrice;
  final double taxPercent;
  final double taxableAmount;
  final double taxAmount;
  final double total;
  final double discount;
  final bool isInclusive;
  final String? incomeLedger;

  POSItem({
    required this.id,
    this.productId,
    this.product,
    this.itemType = 'inventory',
    this.affectsInventory = true,
    this.itemCode = '',
    this.itemName = '',
    this.description,
    this.customItem = true,
    this.quantity = 1,
    this.unit = 'Pcs',
    this.pricePerUnit = 0,
    this.rate = 0,
    this.purchasePrice = 0,
    this.taxPercent = 0,
    this.taxableAmount = 0,
    this.taxAmount = 0,
    this.total = 0,
    this.discount = 0,
    this.isInclusive = false,
    this.incomeLedger,
  });

  POSItem copyWith({
    String? id,
    String? productId,
    Product? product,
    String? itemType,
    bool? affectsInventory,
    String? itemCode,
    String? itemName,
    String? description,
    bool? customItem,
    double? quantity,
    String? unit,
    double? pricePerUnit,
    double? rate,
    double? purchasePrice,
    double? taxPercent,
    double? taxableAmount,
    double? taxAmount,
    double? total,
    double? discount,
    bool? isInclusive,
    String? incomeLedger,
  }) {
    return POSItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      product: product ?? this.product,
      itemType: itemType ?? this.itemType,
      affectsInventory: affectsInventory ?? this.affectsInventory,
      itemCode: itemCode ?? this.itemCode,
      itemName: itemName ?? this.itemName,
      description: description ?? this.description,
      customItem: customItem ?? this.customItem,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      rate: rate ?? this.rate,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      taxPercent: taxPercent ?? this.taxPercent,
      taxableAmount: taxableAmount ?? this.taxableAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      total: total ?? this.total,
      discount: discount ?? this.discount,
      isInclusive: isInclusive ?? this.isInclusive,
      incomeLedger: incomeLedger ?? this.incomeLedger,
    );
  }

  static POSItem calculateAmounts(POSItem item) {
    final qty = item.quantity < 0 ? 0.0 : item.quantity;
    final rate = item.pricePerUnit < 0 ? 0.0 : item.pricePerUnit;
    final disc = item.discount.clamp(0.0, 100.0);
    final taxPct = item.taxPercent < 0 ? 0.0 : item.taxPercent;

    final gross = qty * rate;
    final discAmt = gross * (disc / 100.0);
    final taxable = (gross - discAmt).clamp(0.0, double.infinity);

    double tax = 0.0;
    double tot = 0.0;

    if (item.isInclusive && taxPct > 0) {
      final baseNoTax = taxable / (1.0 + (taxPct / 100.0));
      tax = taxable - baseNoTax;
      tot = taxable;
    } else {
      tax = taxable * (taxPct / 100.0);
      tot = taxable + tax;
    }

    return item.copyWith(
      quantity: qty,
      pricePerUnit: rate,
      rate: rate,
      discount: disc,
      taxPercent: taxPct,
      taxableAmount: double.parse(taxable.toStringAsFixed(2)),
      taxAmount: double.parse(tax.toStringAsFixed(2)),
      total: double.parse(tot.toStringAsFixed(2)),
    );
  }
}
