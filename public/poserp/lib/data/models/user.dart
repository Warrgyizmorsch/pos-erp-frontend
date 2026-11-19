class User {
  final String id;
  final String name;
  final String email;
  final String
  role; // "admin" | "manager" | "accountant" | "stock_manager" | "cashier"
  final String? phone;
  final String? avatar;
  final bool isActive;
  final List<String> permissions;
  final String createdAt;
  final String updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.avatar,
    required this.isActive,
    this.permissions = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'cashier',
      phone: json['phone'],
      avatar: json['avatar'],
      isActive: json['isActive'] ?? true,
      permissions: (json['permissions'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'avatar': avatar,
      'isActive': isActive,
      'permissions': permissions,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  bool get isAdmin => role == 'admin';
  bool get isManager => role == 'manager';
  bool get isAccountant => role == 'accountant';
  bool get isStockManager => role == 'stock_manager';
  bool get isCashier => role == 'cashier';
}
