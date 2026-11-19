class Category {
  final String id;
  final String name;
  final String? description;
  final String? customId;
  final String? image;
  final bool isActive;
  final String createdAt;
  final int productCount;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.customId,
    this.image,
    required this.isActive,
    required this.createdAt,
    this.productCount = 0,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      customId: json['customId'],
      image: json['image'],
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] ?? '',
      productCount: json['productCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'customId': customId,
      'image': image,
      'isActive': isActive,
      'createdAt': createdAt,
      'productCount': productCount,
    };
  }
}
