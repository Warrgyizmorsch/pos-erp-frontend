class BankAccount {
  final String id;
  final String accountName;
  final String accountNumber;
  final String ifscCode;
  final double openingBalance;
  final double currentBalance;
  final String? bankName;
  final String? branch;
  final String? qrCodeUrl;
  final bool isDefault;
  final String createdAt;

  BankAccount({
    required this.id,
    required this.accountName,
    required this.accountNumber,
    required this.ifscCode,
    required this.openingBalance,
    required this.currentBalance,
    this.bankName,
    this.branch,
    this.qrCodeUrl,
    this.isDefault = false,
    required this.createdAt,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      accountName:
          json['accountName']?.toString() ??
          json['name']?.toString() ??
          'Bank Account',
      accountNumber: json['accountNumber']?.toString() ?? '',
      ifscCode: json['ifscCode']?.toString() ?? '',
      openingBalance: (json['openingBalance'] as num?)?.toDouble() ?? 0.0,
      currentBalance:
          (json['currentBalance'] as num?)?.toDouble() ??
          (json['balance'] as num?)?.toDouble() ??
          (json['openingBalance'] as num?)?.toDouble() ??
          0.0,
      bankName: json['bankName']?.toString(),
      branch: json['branch']?.toString(),
      qrCodeUrl: json['qrCodeUrl']?.toString(),
      isDefault: json['isDefault'] == true,
      createdAt:
          json['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountName': accountName,
      'accountNumber': accountNumber,
      'ifscCode': ifscCode,
      'openingBalance': openingBalance,
      if (bankName != null && bankName!.isNotEmpty) 'bankName': bankName,
      if (branch != null && branch!.isNotEmpty) 'branch': branch,
      'isDefault': isDefault,
    };
  }
}
