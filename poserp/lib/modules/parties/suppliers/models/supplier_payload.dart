class SupplierPayload {
  final String name;
  final String? phone;
  final String? email;
  final String? gstNumber;
  final String gstType;
  final String? stateCode;
  final String? address;
  final String? shippingAddress;
  final double openingBalance;
  final String openingBalanceType;
  final double creditLimit;
  final String? bankName;
  final String? accountNumber;
  final String? ifscCode;
  final String? city;
  final String? state;
  final String? pincode;

  SupplierPayload({
    required this.name,
    this.phone,
    this.email,
    this.gstNumber,
    this.gstType = 'Unregistered/Consumer',
    this.stateCode,
    this.address,
    this.shippingAddress,
    this.openingBalance = 0,
    this.openingBalanceType = 'Payable',
    this.creditLimit = 0,
    this.bankName,
    this.accountNumber,
    this.ifscCode,
    this.city,
    this.state,
    this.pincode,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (phone != null && phone!.isNotEmpty) 'phone': phone,
      if (email != null && email!.isNotEmpty) 'email': email,
      if (gstNumber != null && gstNumber!.isNotEmpty) 'gstNumber': gstNumber,
      'gstType': gstType,
      if (stateCode != null && stateCode!.isNotEmpty) 'stateCode': stateCode,
      if (address != null && address!.isNotEmpty) 'address': address,
      if (shippingAddress != null && shippingAddress!.isNotEmpty)
        'shippingAddress': shippingAddress,
      'openingBalance': openingBalance,
      'openingBalanceType': openingBalanceType,
      'creditLimit': creditLimit,
      if (bankName != null && bankName!.isNotEmpty) 'bankName': bankName,
      if (accountNumber != null && accountNumber!.isNotEmpty)
        'accountNumber': accountNumber,
      if (ifscCode != null && ifscCode!.isNotEmpty) 'ifscCode': ifscCode,
      if (city != null && city!.isNotEmpty) 'city': city,
      if (state != null && state!.isNotEmpty) 'state': state,
      if (pincode != null && pincode!.isNotEmpty) 'pincode': pincode,
    };
  }
}
