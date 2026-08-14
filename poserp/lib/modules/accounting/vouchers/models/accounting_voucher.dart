import 'accounting_voucher_entry.dart';

class AccountingVoucher {
  final String id;
  final String voucherNo;
  final String date;
  final String voucherTypeCode;
  final String voucherTypeName;
  final String? referenceModule;
  final String? referenceNo;
  final String? reversalVoucherId;
  final String? postedAt;
  final String? cancelledAt;
  final double totalAmount;
  final double totalDebit;
  final double totalCredit;
  final String? narration;
  final String status; // 'DRAFT', 'POSTED', 'CANCELLED', 'REVERSED'
  final List<AccountingVoucherEntry> entries;

  AccountingVoucher({
    required this.id,
    required this.voucherNo,
    required this.date,
    required this.voucherTypeCode,
    required this.voucherTypeName,
    this.referenceModule,
    this.referenceNo,
    this.reversalVoucherId,
    this.postedAt,
    this.cancelledAt,
    required this.totalAmount,
    required this.totalDebit,
    required this.totalCredit,
    this.narration,
    required this.status,
    required this.entries,
  });

  bool get canCancelOrReverse =>
      status == 'POSTED' &&
      (reversalVoucherId == null || reversalVoucherId!.isEmpty);

  factory AccountingVoucher.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> vData = json;
    List rawEntries = [];

    if (json['voucher'] is Map<String, dynamic>) {
      vData = json['voucher'] as Map<String, dynamic>;
    }

    if (json['entries'] != null && json['entries'] is List) {
      rawEntries = json['entries'] as List;
    } else if (vData['entries'] != null && vData['entries'] is List) {
      rawEntries = vData['entries'] as List;
    }

    final entryList = <AccountingVoucherEntry>[];
    for (final e in rawEntries) {
      if (e is Map<String, dynamic>) {
        try {
          entryList.add(AccountingVoucherEntry.fromJson(e));
        } catch (_) {}
      }
    }

    final double totAmt =
        (vData['totalAmount'] as num?)?.toDouble() ??
        (vData['amount'] as num?)?.toDouble() ??
        (vData['totalDebit'] as num?)?.toDouble() ??
        0.0;

    final double tDebit = (vData['totalDebit'] as num?)?.toDouble() ?? totAmt;
    final double tCredit = (vData['totalCredit'] as num?)?.toDouble() ?? totAmt;

    return AccountingVoucher(
      id: vData['_id']?.toString() ?? vData['id']?.toString() ?? '',
      voucherNo:
          vData['voucherNo']?.toString() ??
          vData['voucherNumber']?.toString() ??
          vData['referenceNo']?.toString() ??
          '',
      date:
          vData['date']?.toString() ??
          vData['createdAt']?.toString() ??
          DateTime.now().toIso8601String(),
      voucherTypeCode:
          vData['voucherTypeCode']?.toString() ??
          vData['typeCode']?.toString() ??
          'JV',
      voucherTypeName:
          vData['voucherTypeName']?.toString() ??
          vData['type']?.toString() ??
          'Journal Voucher',
      referenceModule: vData['referenceModule']?.toString(),
      referenceNo: vData['referenceNo']?.toString(),
      reversalVoucherId: vData['reversalVoucherId']?.toString(),
      postedAt: vData['postedAt']?.toString(),
      cancelledAt: vData['cancelledAt']?.toString(),
      totalAmount: totAmt,
      totalDebit: tDebit,
      totalCredit: tCredit,
      narration: vData['narration']?.toString() ?? vData['remarks']?.toString(),
      status: vData['status']?.toString().toUpperCase() ?? 'POSTED',
      entries: entryList,
    );
  }
}
