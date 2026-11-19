class ChartLedger {
  final String id;
  final String code;
  final String name;
  final String group;
  final String ledgerType;
  final String balanceType;
  final double openingBalance;
  final double currentBalance;
  final String currentBalanceType;
  final bool isSystem;
  final bool isActive;

  ChartLedger({
    required this.id,
    required this.code,
    required this.name,
    this.group = '',
    this.ledgerType = 'GENERAL',
    this.balanceType = 'DEBIT',
    required this.openingBalance,
    required this.currentBalance,
    this.currentBalanceType = 'DEBIT',
    this.isSystem = false,
    this.isActive = true,
  });

  factory ChartLedger.fromJson(Map<String, dynamic> json) {
    return ChartLedger(
      id:
          json['ledgerId']?.toString() ??
          json['_id']?.toString() ??
          json['id']?.toString() ??
          '',
      code: json['code']?.toString() ?? json['ledgerCode']?.toString() ?? '',
      name:
          json['ledgerName']?.toString() ??
          json['name']?.toString() ??
          'Ledger',
      group: json['group']?.toString() ?? json['parentGroup']?.toString() ?? '',
      ledgerType: json['ledgerType']?.toString() ?? 'GENERAL',
      balanceType: json['balanceType']?.toString() ?? 'DEBIT',
      openingBalance: (json['openingBalance'] as num?)?.toDouble() ?? 0.0,
      currentBalance:
          (json['currentBalance'] as num?)?.toDouble() ??
          (json['balance'] as num?)?.toDouble() ??
          0.0,
      currentBalanceType:
          json['currentBalanceType']?.toString() ??
          json['balanceType']?.toString() ??
          'DEBIT',
      isSystem:
          json['isSystemDefault'] == true ||
          json['isSystem'] == true ||
          json['isSystemLedger'] == true,
      isActive: json['isActive'] != false,
    );
  }
}
