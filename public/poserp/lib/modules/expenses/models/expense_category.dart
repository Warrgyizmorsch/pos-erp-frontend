class ExpenseCategory {
  final String id;
  final String name;
  final String? description;
  final String? color;

  ExpenseCategory({
    required this.id,
    required this.name,
    this.description,
    this.color,
  });

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseCategory(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Category',
      description: json['description']?.toString(),
      color: json['color']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null && description!.isNotEmpty)
        'description': description,
      if (color != null && color!.isNotEmpty) 'color': color,
    };
  }
}
