class Supplier {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final String? shippingAddress;
  final String? gstNumber;
  final String? gstType;
  final String? stateCode;
  final double openingBalance;
  final String openingBalanceType; // 'Payable' or 'Receivable'
  final double creditLimit;
  final int totalPurchases;
  final double outstandingBalance;
  final String? bankName;
  final String? accountNumber;
  final String? ifscCode;
  final String? city;
  final String? state;
  final String? pincode;
  final bool isActive;
  final String? createdAt;

  Supplier({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.shippingAddress,
    this.gstNumber,
    this.gstType = 'Unregistered/Consumer',
    this.stateCode,
    this.openingBalance = 0,
    this.openingBalanceType = 'Payable',
    this.creditLimit = 0,
    this.totalPurchases = 0,
    this.outstandingBalance = 0,
    this.bankName,
    this.accountNumber,
    this.ifscCode,
    this.city,
    this.state,
    this.pincode,
    this.isActive = true,
    this.createdAt,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      address: json['address']?.toString(),
      shippingAddress: json['shippingAddress']?.toString(),
      gstNumber: json['gstNumber']?.toString(),
      gstType: json['gstType']?.toString() ?? 'Unregistered/Consumer',
      stateCode: json['stateCode']?.toString(),
      openingBalance: (json['openingBalance'] as num?)?.toDouble() ?? 0.0,
      openingBalanceType: json['openingBalanceType']?.toString() ?? 'Payable',
      creditLimit: (json['creditLimit'] as num?)?.toDouble() ?? 0.0,
      totalPurchases: (json['totalPurchases'] as num?)?.toInt() ?? 0,
      outstandingBalance:
          (json['outstandingBalance'] as num?)?.toDouble() ?? 0.0,
      bankName: json['bankName']?.toString(),
      accountNumber: json['accountNumber']?.toString(),
      ifscCode: json['ifscCode']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      pincode: json['pincode']?.toString(),
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
      'creditLimit': creditLimit,
      'totalPurchases': totalPurchases,
      'outstandingBalance': outstandingBalance,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'ifscCode': ifscCode,
      'city': city,
      'state': state,
      'pincode': pincode,
      'isActive': isActive,
      'createdAt': createdAt,
    };
  }
}
