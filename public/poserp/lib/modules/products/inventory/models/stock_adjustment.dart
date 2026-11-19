class StockAdjustment {
  final String id;
  final String adjustmentNumber;
  final String productId;
  final String productName;
  final double previousStock;
  final double adjustedStock;
  final double difference;
  final String reason;
  final String? notes;
  final String? createdBy;
  final String createdAt;

  StockAdjustment({
    required this.id,
    required this.adjustmentNumber,
    required this.productId,
    required this.productName,
    required this.previousStock,
    required this.adjustedStock,
    required this.difference,
    required this.reason,
    this.notes,
    this.createdBy,
    required this.createdAt,
  });

  factory StockAdjustment.fromJson(Map<String, dynamic> json) {
    String pId = '';
    String pName = json['productName']?.toString() ?? 'Product';

    if (json['product'] != null) {
      if (json['product'] is Map<String, dynamic>) {
        pId =
            json['product']['_id']?.toString() ??
            json['product']['id']?.toString() ??
            '';
        pName = json['product']['name']?.toString() ?? pName;
      } else {
        pId = json['product'].toString();
      }
    } else if (json['productId'] != null) {
      pId = json['productId'].toString();
    }

    String creatorName = 'System';
    if (json['createdBy'] != null) {
      if (json['createdBy'] is Map<String, dynamic>) {
        creatorName = json['createdBy']['name']?.toString() ?? 'System';
      } else {
        creatorName = json['createdBy'].toString();
      }
    }

    return StockAdjustment(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      adjustmentNumber:
          json['adjustmentNumber']?.toString() ??
          json['referenceNo']?.toString() ??
          '',
      productId: pId,
      productName: pName,
      previousStock: (json['previousStock'] as num?)?.toDouble() ?? 0.0,
      adjustedStock: (json['adjustedStock'] as num?)?.toDouble() ?? 0.0,
      difference: (json['difference'] as num?)?.toDouble() ?? 0.0,
      reason: json['reason']?.toString() ?? 'Manual Adjustment',
      notes: json['notes']?.toString(),
      createdBy: creatorName,
      createdAt:
          json['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }
}
