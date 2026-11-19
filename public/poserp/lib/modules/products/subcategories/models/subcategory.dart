import '../../categories/models/category.dart';

class Subcategory {
  final String id;
  final String name;
  final String? customId;
  final String? description;
  final String? image;
  final dynamic parentCategoryId; // String or Category
  final bool isActive;
  final String createdAt;
  final int productCount;

  Subcategory({
    required this.id,
    required this.name,
    this.customId,
    this.description,
    this.image,
    required this.parentCategoryId,
    required this.isActive,
    required this.createdAt,
    this.productCount = 0,
  });

  factory Subcategory.fromJson(Map<String, dynamic> json) {
    dynamic parent;
    if (json['parentCategoryId'] != null) {
      if (json['parentCategoryId'] is Map<String, dynamic>) {
        parent = Category.fromJson(json['parentCategoryId']);
      } else {
        parent = json['parentCategoryId'].toString();
      }
    }

    return Subcategory(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      customId: json['customId'],
      description: json['description'],
      image: json['image'],
      parentCategoryId: parent,
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] ?? '',
      productCount: json['productCount'] ?? 0,
    );
  }

  String? get parentCategoryIdString {
    if (parentCategoryId is Category) {
      return (parentCategoryId as Category).id;
    } else if (parentCategoryId is String) {
      return parentCategoryId as String;
    }
    return null;
  }

  String get parentCategoryName {
    if (parentCategoryId is Category) {
      return (parentCategoryId as Category).name;
    }
    return 'Unassigned';
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'customId': customId,
      'description': description,
      'image': image,
      'parentCategoryId': parentCategoryId is Category
          ? (parentCategoryId as Category).toJson()
          : parentCategoryId,
      'isActive': isActive,
      'createdAt': createdAt,
      'productCount': productCount,
    };
  }
}
