class CustomerPayload {
  final String name;
  final String phone;
  final String? email;
  final String? gstNumber;
  final String? address;
  final String? stateCode;
  final double openingBalance;
  final String openingBalanceType;
  final String? openingBalanceDate;
  final double creditLimit;

  CustomerPayload({
    required this.name,
    required this.phone,
    this.email,
    this.gstNumber,
    this.address,
    this.stateCode,
    this.openingBalance = 0,
    this.openingBalanceType = 'Receivable',
    this.openingBalanceDate,
    this.creditLimit = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      if (email != null && email!.isNotEmpty) 'email': email,
      if (gstNumber != null && gstNumber!.isNotEmpty) 'gstNumber': gstNumber,
      if (address != null && address!.isNotEmpty) 'address': address,
      if (stateCode != null && stateCode!.isNotEmpty) 'stateCode': stateCode,
      'openingBalance': openingBalance,
      'openingBalanceType': openingBalanceType,
      if (openingBalanceDate != null) 'openingBalanceDate': openingBalanceDate,
      'creditLimit': creditLimit,
    };
  }
}
