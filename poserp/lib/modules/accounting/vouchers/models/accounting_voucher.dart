import 'accounting_voucher_entry.dart';

class AccountingVoucher {
  final String id;
  final String voucherNo;
  final String date;
  final String voucherTypeCode;
  final String voucherTypeName;
  final double totalAmount;
  final String? narration;
  final String status; // 'DRAFT', 'POSTED', 'CANCELLED', 'REVERSED'
  final List<AccountingVoucherEntry> entries;

  AccountingVoucher({
    required this.id,
    required this.voucherNo,
    required this.date,
    required this.voucherTypeCode,
    required this.voucherTypeName,
    required this.totalAmount,
    this.narration,
    required this.status,
    required this.entries,
  });

  factory AccountingVoucher.fromJson(Map<String, dynamic> json) {
    final entryList = <AccountingVoucherEntry>[];
    if (json['entries'] != null && json['entries'] is List) {
      for (final e in json['entries']) {
        if (e is Map<String, dynamic>) {
          try {
            entryList.add(AccountingVoucherEntry.fromJson(e));
          } catch (_) {}
        }
      }
    }

    return AccountingVoucher(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      voucherNo:
          json['voucherNo']?.toString() ??
          json['voucherNumber']?.toString() ??
          json['referenceNo']?.toString() ??
          '',
      date:
          json['date']?.toString() ??
          json['createdAt']?.toString() ??
          DateTime.now().toIso8601String(),
      voucherTypeCode:
          json['voucherTypeCode']?.toString() ??
          json['typeCode']?.toString() ??
          'JV',
      voucherTypeName:
          json['voucherTypeName']?.toString() ??
          json['type']?.toString() ??
          'Journal Voucher',
      totalAmount:
          (json['totalAmount'] as num?)?.toDouble() ??
          (json['amount'] as num?)?.toDouble() ??
          0.0,
      narration: json['narration']?.toString() ?? json['remarks']?.toString(),
      status: json['status']?.toString().toUpperCase() ?? 'POSTED',
      entries: entryList,
    );
  }
}
