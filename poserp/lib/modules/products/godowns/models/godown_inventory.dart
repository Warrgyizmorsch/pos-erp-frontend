class GodownInventoryBatch {
  final double purchasePrice;
  final double salePrice;
  final double quantity;

  GodownInventoryBatch({
    required this.purchasePrice,
    required this.salePrice,
    required this.quantity,
  });

  factory GodownInventoryBatch.fromJson(Map<String, dynamic> json) {
    return GodownInventoryBatch(
      purchasePrice: (json['purchasePrice'] as num?)?.toDouble() ?? 0.0,
      salePrice: (json['salePrice'] as num?)?.toDouble() ??
          (json['salesPrice'] as num?)?.toDouble() ??
          0.0,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'purchasePrice': purchasePrice,
      'salePrice': salePrice,
      'quantity': quantity,
    };
  }
}

class GodownInventoryProduct {
  final String id;
  final String name;
  final String sku;
  final String? image;
  final String unit;

  GodownInventoryProduct({
    required this.id,
    required this.name,
    required this.sku,
    this.image,
    this.unit = 'Pcs',
  });

  factory GodownInventoryProduct.fromJson(Map<String, dynamic> json) {
    return GodownInventoryProduct(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Product',
      sku: json['sku']?.toString() ?? '',
      image: json['image']?.toString(),
      unit: json['unit']?.toString() ?? 'Pcs',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'sku': sku,
      'image': image,
      'unit': unit,
    };
  }
}

class GodownInventoryItem {
  final GodownInventoryProduct product;
  final double totalQuantity;
  final List<GodownInventoryBatch> batches;

  GodownInventoryItem({
    required this.product,
    required this.totalQuantity,
    required this.batches,
  });

  factory GodownInventoryItem.fromJson(Map<String, dynamic> json) {
    GodownInventoryProduct prod;
    if (json['product'] is Map<String, dynamic>) {
      prod = GodownInventoryProduct.fromJson(
        json['product'] as Map<String, dynamic>,
      );
    } else {
      prod = GodownInventoryProduct(
        id: json['product']?.toString() ?? json['productId']?.toString() ?? '',
        name: json['productName']?.toString() ??
            json['name']?.toString() ??
            'Product',
        sku: json['sku']?.toString() ?? '',
        unit: json['unit']?.toString() ?? 'Pcs',
      );
    }

    final batchList = <GodownInventoryBatch>[];
    if (json['batches'] != null && json['batches'] is List) {
      for (final b in json['batches'] as List) {
        if (b is Map<String, dynamic>) {
          try {
            batchList.add(GodownInventoryBatch.fromJson(b));
          } catch (_) {}
        }
      }
    }

    return GodownInventoryItem(
      product: prod,
      totalQuantity: (json['totalQuantity'] as num?)?.toDouble() ??
          (json['quantity'] as num?)?.toDouble() ??
          batchList.fold(0.0, (sum, b) => sum + b.quantity),
      batches: batchList,
    );
  }
}
