class Godown {
  final String id;
  final String name;
  final String code;
  final String? location;
  final double capacity;
  final bool isDefault;
  final bool isActive;
  final String? createdAt;

  Godown({
    required this.id,
    required this.name,
    required this.code,
    this.location,
    this.capacity = 0,
    this.isDefault = false,
    this.isActive = true,
    this.createdAt,
  });

  factory Godown.fromJson(Map<String, dynamic> json) {
    return Godown(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      location: json['location']?.toString(),
      capacity: (json['capacity'] as num?)?.toDouble() ?? 0.0,
      isDefault: json['isDefault'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'code': code,
      'location': location,
      'capacity': capacity,
      'isDefault': isDefault,
      'isActive': isActive,
      'createdAt': createdAt,
    };
  }
}
