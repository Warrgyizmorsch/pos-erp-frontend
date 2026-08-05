class Transporter {
  final String id;
  final String name;
  final String phone;
  final String? vehicleNumber;
  final String? address;
  final bool isActive;
  final String? createdAt;

  Transporter({
    required this.id,
    required this.name,
    required this.phone,
    this.vehicleNumber,
    this.address,
    this.isActive = true,
    this.createdAt,
  });

  factory Transporter.fromJson(Map<String, dynamic> json) {
    return Transporter(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      vehicleNumber: json['vehicleNumber']?.toString(),
      address: json['address']?.toString(),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'phone': phone,
      'vehicleNumber': vehicleNumber,
      'address': address,
      'isActive': isActive,
      'createdAt': createdAt,
    };
  }
}
