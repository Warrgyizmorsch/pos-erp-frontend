import '../../models/product.dart';

class StockMovement {
  final String id;
  final Product? product;
  final String productName;
  final String
  type; // 'purchase', 'sale', 'return', 'adjustment', 'transfer', 'cancellation'
  final double quantity;
  final double previousStock;
  final double newStock;
  final String? reference;
  final String? referenceId;
  final String? notes;
  final String? createdBy;
  final String createdAt;

  StockMovement({
    required this.id,
    this.product,
    required this.productName,
    required this.type,
    required this.quantity,
    required this.previousStock,
    required this.newStock,
    this.reference,
    this.referenceId,
    this.notes,
    this.createdBy,
    required this.createdAt,
  });

  factory StockMovement.fromJson(Map<String, dynamic> json) {
    Product? p;
    String pName = json['productName']?.toString() ?? 'Product';

    if (json['product'] != null) {
      if (json['product'] is Map<String, dynamic>) {
        try {
          p = Product.fromJson(json['product'] as Map<String, dynamic>);
          pName = p.name;
        } catch (_) {
          pName = json['product']['name']?.toString() ?? pName;
        }
      }
    }

    String creatorName = 'System';
    if (json['createdBy'] != null) {
      if (json['createdBy'] is Map<String, dynamic>) {
        creatorName = json['createdBy']['name']?.toString() ?? 'System';
      } else {
        creatorName = json['createdBy'].toString();
      }
    }

    return StockMovement(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      product: p,
      productName: pName,
      type: json['type']?.toString() ?? 'adjustment',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      previousStock: (json['previousStock'] as num?)?.toDouble() ?? 0.0,
      newStock: (json['newStock'] as num?)?.toDouble() ?? 0.0,
      reference:
          json['reference']?.toString() ?? json['referenceNo']?.toString(),
      referenceId: json['referenceId']?.toString(),
      notes: json['notes']?.toString() ?? json['reason']?.toString(),
      createdBy: creatorName,
      createdAt:
          json['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }
}
