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
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'],
      phone: json['phone'] ?? '',
      address: json['address'],
      shippingAddress: json['shippingAddress'],
      gstNumber: json['gstNumber'],
      gstType: json['gstType'],
      stateCode: json['stateCode'],
      openingBalance: (json['openingBalance'] as num?)?.toDouble() ?? 0.0,
      openingBalanceType: json['openingBalanceType'] ?? 'Receivable',
      openingBalanceDate: json['openingBalanceDate'],
      creditLimit: (json['creditLimit'] as num?)?.toDouble() ?? 0.0,
      totalPurchases: json['totalPurchases'] ?? 0,
      totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0.0,
      walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 0.0,
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'],
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
