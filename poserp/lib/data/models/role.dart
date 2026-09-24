class Role {
  final String id;
  final String name;
  final List<String> permissions;
  final String? description;
  final bool isSystem;

  Role({
    required this.id,
    required this.name,
    required this.permissions,
    this.description,
    this.isSystem = false,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      permissions: (json['permissions'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      description: json['description'],
      isSystem: json['isSystem'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'permissions': permissions,
      'description': description,
      'isSystem': isSystem,
    };
  }

  Role copyWith({
    String? id,
    String? name,
    List<String>? permissions,
    String? description,
    bool? isSystem,
  }) {
    return Role(
      id: id ?? this.id,
      name: name ?? this.name,
      permissions: permissions ?? this.permissions,
      description: description ?? this.description,
      isSystem: isSystem ?? this.isSystem,
    );
  }
}
