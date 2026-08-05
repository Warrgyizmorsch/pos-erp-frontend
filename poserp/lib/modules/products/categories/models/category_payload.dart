class CategoryPayload {
  final String name;
  final String? description;
  final String? image;
  final bool isActive;

  CategoryPayload({
    required this.name,
    this.description,
    this.image,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null) 'description': description,
      if (image != null) 'image': image,
      'isActive': isActive,
    };
  }
}
