class AccountingLedger {
  final String id;
  final String code;
  final String name;
  final String groupName;
  final String groupId;
  final String nature;
  final String ledgerType;
  final double openingBalance;
  final String openingBalanceType; // 'DEBIT' or 'CREDIT'
  final double currentBalance;
  final String currentBalanceType; // 'DEBIT' or 'CREDIT'
  final bool isSystemDefault;
  final bool isActive;

  AccountingLedger({
    required this.id,
    required this.code,
    required this.name,
    required this.groupName,
    required this.groupId,
    required this.nature,
    required this.ledgerType,
    required this.openingBalance,
    required this.openingBalanceType,
    required this.currentBalance,
    required this.currentBalanceType,
    this.isSystemDefault = false,
    this.isActive = true,
  });

  factory AccountingLedger.fromJson(Map<String, dynamic> json) {
    String gName = '-';
    String gId = '';
    String gNature = '-';

    if (json['groupId'] != null) {
      if (json['groupId'] is Map<String, dynamic>) {
        gId =
            json['groupId']['_id']?.toString() ??
            json['groupId']['id']?.toString() ??
            '';
        gName = json['groupId']['name']?.toString() ?? '-';
        gNature = json['groupId']['nature']?.toString() ?? '-';
      } else {
        gId = json['groupId'].toString();
      }
    }

    if (json['group'] != null && gName == '-') {
      if (json['group'] is Map<String, dynamic>) {
        gName = json['group']['name']?.toString() ?? '-';
        gNature = json['group']['nature']?.toString() ?? gNature;
      } else {
        gName = json['group'].toString();
      }
    }

    return AccountingLedger(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? json['ledgerCode']?.toString() ?? '',
      name:
          json['name']?.toString() ??
          json['ledgerName']?.toString() ??
          'Ledger',
      groupName: gName,
      groupId: gId,
      nature: json['nature']?.toString() ?? gNature,
      ledgerType:
          json['ledgerType']?.toString() ??
          json['type']?.toString() ??
          'GENERAL',
      openingBalance: (json['openingBalance'] as num?)?.toDouble() ?? 0.0,
      openingBalanceType:
          json['openingBalanceType']?.toString().toUpperCase() ??
          json['balanceType']?.toString().toUpperCase() ??
          'DEBIT',
      currentBalance:
          (json['currentBalance'] as num?)?.toDouble() ??
          (json['balance'] as num?)?.toDouble() ??
          (json['openingBalance'] as num?)?.toDouble() ??
          0.0,
      currentBalanceType:
          json['currentBalanceType']?.toString().toUpperCase() ??
          json['balanceType']?.toString().toUpperCase() ??
          'DEBIT',
      isSystemDefault:
          json['isSystemDefault'] == true || json['isSystem'] == true,
      isActive: json['isActive'] != false,
    );
  }
}
