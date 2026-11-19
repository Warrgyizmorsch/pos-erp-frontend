import '../../models/product.dart';

class OpeningStockItem {
  final String id;
  Product? product;
  String productSearch;
  String sku;
  String barcode;
  String? newProductName;
  double quantity;
  double purchaseRate;
  String purchaseTaxType; // 'with' or 'without'
  double salesPrice;
  String salesTaxType; // 'with' or 'without'
  double taxRate;
  String unit;

  OpeningStockItem({
    required this.id,
    this.product,
    this.productSearch = '',
    this.sku = '',
    this.barcode = '',
    this.newProductName,
    this.quantity = 1,
    this.purchaseRate = 0,
    this.purchaseTaxType = 'without',
    this.salesPrice = 0,
    this.salesTaxType = 'without',
    this.taxRate = 0,
    this.unit = 'piece',
  });

  double get basePurchaseRate {
    if (purchaseTaxType == 'with' && taxRate > 0) {
      final taxMultiplier = 1 + (taxRate / 100);
      return purchaseRate / taxMultiplier;
    }
    return purchaseRate;
  }

  double get valuation => quantity * basePurchaseRate;

  double get taxAmount => valuation * (taxRate / 100);
}
