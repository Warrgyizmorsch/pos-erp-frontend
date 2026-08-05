class SubcategoryPayload {
  final String name;
  final String parentCategoryId;
  final String? description;
  final String? image;
  final bool isActive;

  SubcategoryPayload({
    required this.name,
    required this.parentCategoryId,
    this.description,
    this.image,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'parentCategoryId': parentCategoryId,
      if (description != null) 'description': description,
      if (image != null) 'image': image,
      'isActive': isActive,
    };
  }
}
