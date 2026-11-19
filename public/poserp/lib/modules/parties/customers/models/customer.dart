class Customer {
  final String id;
  final String name;
  final String? email;
  final String phone;
  final String? address;
  final String? shippingAddress;
  final String? gstNumber;
  final String? gstType;
  final String? stateCode;
  final double openingBalance;
  final String openingBalanceType; // 'Receivable' or 'Payable'
  final String? openingBalanceDate;
  final double creditLimit;
  final int totalPurchases;
  final double totalSpent;
  final double walletBalance;
  final bool isActive;
  final String? createdAt;

  Customer({
    required this.id,
    required this.name,
    this.email,
    required this.phone,
    this.address,
    this.shippingAddress,
    this.gstNumber,
    this.gstType,
    this.stateCode,
    this.openingBalance = 0,
    this.openingBalanceType = 'Receivable',
    this.openingBalanceDate,
    this.creditLimit = 0,
    this.totalPurchases = 0,
    this.totalSpent = 0,
    this.walletBalance = 0,
    this.isActive = true,
    this.createdAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString(),
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString(),
      shippingAddress: json['shippingAddress']?.toString(),
      gstNumber: json['gstNumber']?.toString(),
      gstType: json['gstType']?.toString(),
      stateCode: json['stateCode']?.toString(),
      openingBalance: (json['openingBalance'] as num?)?.toDouble() ?? 0.0,
      openingBalanceType:
          json['openingBalanceType']?.toString() ?? 'Receivable',
      openingBalanceDate: json['openingBalanceDate']?.toString(),
      creditLimit: (json['creditLimit'] as num?)?.toDouble() ?? 0.0,
      totalPurchases: (json['totalPurchases'] as num?)?.toInt() ?? 0,
      totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0.0,
      walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 0.0,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'shippingAddress': shippingAddress,
      'gstNumber': gstNumber,
      'gstType': gstType,
      'stateCode': stateCode,
      'openingBalance': openingBalance,
      'openingBalanceType': openingBalanceType,
      'openingBalanceDate': openingBalanceDate,
      'creditLimit': creditLimit,
      'totalPurchases': totalPurchases,
      'totalSpent': totalSpent,
      'walletBalance': walletBalance,
      'isActive': isActive,
      'createdAt': createdAt,
    };
  }
}
