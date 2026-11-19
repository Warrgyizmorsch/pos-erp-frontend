import '../categories/models/category.dart';
import '../subcategories/models/subcategory.dart';

class Product {
  final String id;
  final String name;
  final String sku;
  final String? barcode;
  final String? description;
  final dynamic category; // Category or String ID
  final dynamic subcategoryId; // Subcategory or String ID
  final double stock;
  final double lowStockThreshold;
  final String? image;
  final List<String> images;
  final String? hsnCode;
  final String unit;
  final double salesPrice;
  final double purchasePrice;
  final double taxRate;
  final String salesTaxType;
  final String purchaseTaxType;
  final double openingStockPrice;
  final String? openingStockDate;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.sku,
    this.barcode,
    this.description,
    required this.category,
    this.subcategoryId,
    this.stock = 0,
    this.lowStockThreshold = 10,
    this.image,
    this.images = const [],
    this.hsnCode,
    this.unit = 'piece',
    this.salesPrice = 0,
    this.purchasePrice = 0,
    this.taxRate = 0,
    this.salesTaxType = 'without',
    this.purchaseTaxType = 'without',
    this.openingStockPrice = 0,
    this.openingStockDate,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    dynamic cat;
    if (json['category'] != null) {
      if (json['category'] is Map<String, dynamic>) {
        cat = Category.fromJson(json['category']);
      } else {
        cat = json['category'].toString();
      }
    }

    dynamic subcat;
    if (json['subcategoryId'] != null) {
      if (json['subcategoryId'] is Map<String, dynamic>) {
        subcat = Subcategory.fromJson(json['subcategoryId']);
      } else {
        subcat = json['subcategoryId'].toString();
      }
    }

    List<String> imgList = [];
    if (json['images'] != null && json['images'] is List) {
      imgList = (json['images'] as List).map((e) => e.toString()).toList();
    } else if (json['image'] != null && json['image'].toString().isNotEmpty) {
      imgList = [json['image'].toString()];
    }

    return Product(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      sku: json['sku'] ?? '',
      barcode: json['barcode'],
      description: json['description'],
      category: cat,
      subcategoryId: subcat,
      stock: (json['stock'] as num?)?.toDouble() ?? 0.0,
      lowStockThreshold:
          (json['lowStockThreshold'] as num?)?.toDouble() ?? 10.0,
      image: json['image'],
      images: imgList,
      hsnCode: json['hsnCode'],
      unit: json['unit'] ?? 'piece',
      salesPrice: (json['salesPrice'] as num?)?.toDouble() ?? 0.0,
      purchasePrice: (json['purchasePrice'] as num?)?.toDouble() ?? 0.0,
      taxRate: (json['taxRate'] as num?)?.toDouble() ?? 0.0,
      salesTaxType: json['salesTaxType'] ?? 'without',
      purchaseTaxType: json['purchaseTaxType'] ?? 'without',
      openingStockPrice: (json['openingStockPrice'] as num?)?.toDouble() ?? 0.0,
      openingStockDate: json['openingStockDate'],
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  String get categoryIdString {
    if (category is Category) {
      return (category as Category).id;
    } else if (category is String) {
      return category as String;
    }
    return '';
  }

  String get categoryName {
    if (category is Category) {
      return (category as Category).name;
    }
    return 'Unassigned';
  }

  String? get subcategoryIdString {
    if (subcategoryId is Subcategory) {
      return (subcategoryId as Subcategory).id;
    } else if (subcategoryId is String) {
      return subcategoryId as String;
    }
    return null;
  }

  String get subcategoryName {
    if (subcategoryId is Subcategory) {
      return (subcategoryId as Subcategory).name;
    }
    return '—';
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'sku': sku,
      'barcode': barcode,
      'description': description,
      'category': category is Category
          ? (category as Category).toJson()
          : category,
      'subcategoryId': subcategoryId is Subcategory
          ? (subcategoryId as Subcategory).toJson()
          : subcategoryId,
      'stock': stock,
      'lowStockThreshold': lowStockThreshold,
      'image': image,
      'images': images,
      'hsnCode': hsnCode,
      'unit': unit,
      'salesPrice': salesPrice,
      'purchasePrice': purchasePrice,
      'taxRate': taxRate,
      'salesTaxType': salesTaxType,
      'purchaseTaxType': purchaseTaxType,
      'openingStockPrice': openingStockPrice,
      'openingStockDate': openingStockDate,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
