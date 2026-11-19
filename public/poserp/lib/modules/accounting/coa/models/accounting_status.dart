class AccountingStatus {
  final bool isInitialized;
  final String companyName;
  final int accountCount;

  AccountingStatus({
    required this.isInitialized,
    required this.companyName,
    required this.accountCount,
  });

  factory AccountingStatus.fromJson(Map<String, dynamic> json) {
    return AccountingStatus(
      isInitialized:
          json['isInitialized'] == true || json['status'] == 'initialized',
      companyName: json['companyName']?.toString() ?? 'Active Company',
      accountCount:
          (json['accountCount'] as num?)?.toInt() ??
          (json['totalLedgers'] as num?)?.toInt() ??
          0,
    );
  }
}
