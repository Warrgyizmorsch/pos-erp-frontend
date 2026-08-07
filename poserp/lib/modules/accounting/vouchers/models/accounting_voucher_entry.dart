class AccountingVoucherEntry {
  final String id;
  final String ledgerId;
  final String ledgerName;
  final String ledgerCode;
  final double debit;
  final double credit;
  final String? narration;

  AccountingVoucherEntry({
    required this.id,
    required this.ledgerId,
    required this.ledgerName,
    required this.ledgerCode,
    required this.debit,
    required this.credit,
    this.narration,
  });

  factory AccountingVoucherEntry.fromJson(Map<String, dynamic> json) {
    String lId = '';
    String lName = 'Ledger';
    String lCode = '';

    if (json['ledgerId'] != null) {
      if (json['ledgerId'] is Map<String, dynamic>) {
        lId =
            json['ledgerId']['_id']?.toString() ??
            json['ledgerId']['id']?.toString() ??
            '';
        lName = json['ledgerId']['name']?.toString() ?? 'Ledger';
        lCode = json['ledgerId']['code']?.toString() ?? '';
      } else {
        lId = json['ledgerId'].toString();
      }
    }

    if (json['ledger'] != null && lName == 'Ledger') {
      if (json['ledger'] is Map<String, dynamic>) {
        lId =
            json['ledger']['_id']?.toString() ??
            json['ledger']['id']?.toString() ??
            lId;
        lName = json['ledger']['name']?.toString() ?? lName;
        lCode = json['ledger']['code']?.toString() ?? lCode;
      } else {
        lName = json['ledger'].toString();
      }
    }

    return AccountingVoucherEntry(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      ledgerId: lId,
      ledgerName: lName,
      ledgerCode: lCode,
      debit: (json['debit'] as num?)?.toDouble() ?? 0.0,
      credit: (json['credit'] as num?)?.toDouble() ?? 0.0,
      narration: json['narration']?.toString(),
    );
  }
}
