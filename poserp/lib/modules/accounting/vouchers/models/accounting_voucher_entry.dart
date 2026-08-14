class AccountingVoucherEntry {
  final String id;
  final String ledgerId;
  final String ledgerName;
  final String ledgerCode;
  final String groupName;
  final double debit;
  final double credit;
  final String? narration;

  AccountingVoucherEntry({
    required this.id,
    required this.ledgerId,
    required this.ledgerName,
    required this.ledgerCode,
    required this.groupName,
    required this.debit,
    required this.credit,
    this.narration,
  });

  factory AccountingVoucherEntry.fromJson(Map<String, dynamic> json) {
    String lId = '';
    String lName = json['ledgerName']?.toString() ?? 'Ledger';
    String lCode = json['ledgerCode']?.toString() ?? '';
    String gName = json['groupName']?.toString() ?? '-';

    if (json['ledgerId'] != null) {
      if (json['ledgerId'] is Map<String, dynamic>) {
        final lObj = json['ledgerId'] as Map<String, dynamic>;
        lId = lObj['_id']?.toString() ?? lObj['id']?.toString() ?? '';
        lName =
            lObj['name']?.toString() ?? lObj['ledgerName']?.toString() ?? lName;
        lCode =
            lObj['code']?.toString() ?? lObj['ledgerCode']?.toString() ?? lCode;

        if (lObj['groupId'] is Map<String, dynamic>) {
          gName = lObj['groupId']['name']?.toString() ?? gName;
        } else if (lObj['group'] is Map<String, dynamic>) {
          gName = lObj['group']['name']?.toString() ?? gName;
        }
      } else {
        lId = json['ledgerId'].toString();
      }
    }

    if (json['ledger'] != null) {
      if (json['ledger'] is Map<String, dynamic>) {
        final lObj = json['ledger'] as Map<String, dynamic>;
        lId = lObj['_id']?.toString() ?? lObj['id']?.toString() ?? lId;
        lName =
            lObj['name']?.toString() ?? lObj['ledgerName']?.toString() ?? lName;
        lCode =
            lObj['code']?.toString() ?? lObj['ledgerCode']?.toString() ?? lCode;

        if (lObj['groupId'] is Map<String, dynamic>) {
          gName = lObj['groupId']['name']?.toString() ?? gName;
        } else if (lObj['group'] is Map<String, dynamic>) {
          gName = lObj['group']['name']?.toString() ?? gName;
        }
      }
    }

    return AccountingVoucherEntry(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      ledgerId: lId,
      ledgerName: lName,
      ledgerCode: lCode,
      groupName: gName,
      debit: (json['debit'] as num?)?.toDouble() ?? 0.0,
      credit: (json['credit'] as num?)?.toDouble() ?? 0.0,
      narration: json['narration']?.toString(),
    );
  }
}
