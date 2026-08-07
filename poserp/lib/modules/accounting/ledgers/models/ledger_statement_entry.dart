class LedgerStatementEntry {
  final String id;
  final String date;
  final String voucherNo;
  final String voucherTypeCode;
  final String voucherTypeName;
  final double debit;
  final double credit;
  final String? narration;
  final String? referenceNo;

  LedgerStatementEntry({
    required this.id,
    required this.date,
    required this.voucherNo,
    required this.voucherTypeCode,
    required this.voucherTypeName,
    required this.debit,
    required this.credit,
    this.narration,
    this.referenceNo,
  });

  factory LedgerStatementEntry.fromJson(Map<String, dynamic> json) {
    return LedgerStatementEntry(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      date:
          json['date']?.toString() ??
          json['createdAt']?.toString() ??
          DateTime.now().toIso8601String(),
      voucherNo:
          json['voucherNo']?.toString() ??
          json['referenceNo']?.toString() ??
          '',
      voucherTypeCode:
          json['voucherTypeCode']?.toString() ??
          json['typeCode']?.toString() ??
          'JV',
      voucherTypeName:
          json['voucherTypeName']?.toString() ??
          json['type']?.toString() ??
          'Journal Voucher',
      debit: (json['debit'] as num?)?.toDouble() ?? 0.0,
      credit: (json['credit'] as num?)?.toDouble() ?? 0.0,
      narration: json['narration']?.toString() ?? json['remarks']?.toString(),
      referenceNo: json['referenceNo']?.toString(),
    );
  }
}
