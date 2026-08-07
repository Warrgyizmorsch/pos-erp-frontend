class ChartLedger {
  final String id;
  final String code;
  final String name;
  final String? group;
  final String balanceType; // 'debit' or 'credit'
  final double openingBalance;
  final double currentBalance;
  final bool isSystem;

  ChartLedger({
    required this.id,
    required this.code,
    required this.name,
    this.group,
    required this.balanceType,
    required this.openingBalance,
    required this.currentBalance,
    this.isSystem = false,
  });

  factory ChartLedger.fromJson(Map<String, dynamic> json) {
    return ChartLedger(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? json['ledgerCode']?.toString() ?? '',
      name:
          json['name']?.toString() ??
          json['ledgerName']?.toString() ??
          'Ledger',
      group: json['group']?.toString() ?? json['parentGroup']?.toString(),
      balanceType: json['balanceType']?.toString() ?? 'debit',
      openingBalance: (json['openingBalance'] as num?)?.toDouble() ?? 0.0,
      currentBalance:
          (json['currentBalance'] as num?)?.toDouble() ??
          (json['balance'] as num?)?.toDouble() ??
          (json['openingBalance'] as num?)?.toDouble() ??
          0.0,
      isSystem: json['isSystem'] == true || json['isSystemLedger'] == true,
    );
  }
}
