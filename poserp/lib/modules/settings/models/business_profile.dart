class BusinessProfile {
  final String? id;
  final String businessName;
  final String? tagline;
  final String? phone;
  final String? email;
  final String? gstin;
  final String? address;
  final String? businessType;
  final String? category;
  final String? state;
  final String? stateCode;
  final String? pincode;
  final String? logo;
  final String? signature;
  final String? beginningDate;
  final String? bankName;
  final String? accountNumber;
  final String? ifscCode;
  final String? branch;
  final String? upiId;
  final String? invoiceTerms;

  const BusinessProfile({
    this.id,
    required this.businessName,
    this.tagline,
    this.phone,
    this.email,
    this.gstin,
    this.address,
    this.businessType,
    this.category,
    this.state,
    this.stateCode,
    this.pincode,
    this.logo,
    this.signature,
    this.beginningDate,
    this.bankName,
    this.accountNumber,
    this.ifscCode,
    this.branch,
    this.upiId,
    this.invoiceTerms,
  });

  factory BusinessProfile.fromJson(Map<String, dynamic> json) {
    return BusinessProfile(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      businessName: json['businessName']?.toString() ?? '',
      tagline: json['tagline']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      gstin: json['gstin']?.toString(),
      address: json['address']?.toString(),
      businessType: json['businessType']?.toString() ?? 'Retail',
      category: json['category']?.toString(),
      state: json['state']?.toString(),
      stateCode: json['stateCode']?.toString(),
      pincode: json['pincode']?.toString(),
      logo: json['logo']?.toString(),
      signature: json['signature']?.toString(),
      beginningDate: json['beginningDate']?.toString(),
      bankName: json['bankName']?.toString(),
      accountNumber: json['accountNumber']?.toString(),
      ifscCode: json['ifscCode']?.toString(),
      branch: json['branch']?.toString(),
      upiId: json['upiId']?.toString(),
      invoiceTerms: json['invoiceTerms']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'businessName': businessName,
      'tagline': tagline ?? '',
      'phone': phone ?? '',
      'email': email ?? '',
      'gstin': gstin ?? '',
      'address': address ?? '',
      'businessType': businessType ?? 'Retail',
      'category': category ?? '',
      'state': state ?? '',
      'stateCode': stateCode ?? '',
      'pincode': pincode ?? '',
      'logo': logo ?? '',
      'signature': signature ?? '',
      if (beginningDate != null) 'beginningDate': beginningDate,
      'bankName': bankName ?? '',
      'accountNumber': accountNumber ?? '',
      'ifscCode': ifscCode ?? '',
      'branch': branch ?? '',
      'upiId': upiId ?? '',
      'invoiceTerms': invoiceTerms ?? '',
    };
  }

  BusinessProfile copyWith({
    String? id,
    String? businessName,
    String? tagline,
    String? phone,
    String? email,
    String? gstin,
    String? address,
    String? businessType,
    String? category,
    String? state,
    String? stateCode,
    String? pincode,
    String? logo,
    String? signature,
    String? beginningDate,
    String? bankName,
    String? accountNumber,
    String? ifscCode,
    String? branch,
    String? upiId,
    String? invoiceTerms,
  }) {
    return BusinessProfile(
      id: id ?? this.id,
      businessName: businessName ?? this.businessName,
      tagline: tagline ?? this.tagline,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      gstin: gstin ?? this.gstin,
      address: address ?? this.address,
      businessType: businessType ?? this.businessType,
      category: category ?? this.category,
      state: state ?? this.state,
      stateCode: stateCode ?? this.stateCode,
      pincode: pincode ?? this.pincode,
      logo: logo ?? this.logo,
      signature: signature ?? this.signature,
      beginningDate: beginningDate ?? this.beginningDate,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
      branch: branch ?? this.branch,
      upiId: upiId ?? this.upiId,
      invoiceTerms: invoiceTerms ?? this.invoiceTerms,
    );
  }
}
