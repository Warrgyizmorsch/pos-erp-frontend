class VoucherType {
  final String id;
  final String code;
  final String name;
  final String? nature;
  final String? description;

  VoucherType({
    required this.id,
    required this.code,
    required this.name,
    this.nature,
    this.description,
  });

  factory VoucherType.fromJson(Map<String, dynamic> json) {
    return VoucherType(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Voucher',
      nature: json['nature']?.toString() ?? json['category']?.toString(),
      description: json['description']?.toString(),
    );
  }
}
