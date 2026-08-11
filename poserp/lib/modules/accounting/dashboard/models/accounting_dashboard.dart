class AccountingDashboard {
  final bool isInitialized;
  final bool accountingEnabled;
  final bool gstAccountingEnabled;
  final bool autoVoucherPosting;
  final int missingDefaultLedgersCount;
  final String activeFinancialYear;
  final String bookLockDate;
  final int accountGroupCount;
  final int ledgerCount;
  final int voucherCount;
  final int draftVoucherCount;
  final int postedVoucherCount;
  final int cancelledVoucherCount;
  final List<Map<String, dynamic>> recentVouchers;

  AccountingDashboard({
    required this.isInitialized,
    required this.accountingEnabled,
    required this.gstAccountingEnabled,
    required this.autoVoucherPosting,
    required this.missingDefaultLedgersCount,
    required this.activeFinancialYear,
    required this.bookLockDate,
    required this.accountGroupCount,
    required this.ledgerCount,
    required this.voucherCount,
    required this.draftVoucherCount,
    required this.postedVoucherCount,
    required this.cancelledVoucherCount,
    required this.recentVouchers,
  });

  factory AccountingDashboard.fromJson(Map<String, dynamic> json) {
    final status = json['status'] is Map<String, dynamic>
        ? json['status'] as Map<String, dynamic>
        : <String, dynamic>{};
    final counts = json['counts'] is Map<String, dynamic>
        ? json['counts'] as Map<String, dynamic>
        : <String, dynamic>{};

    String parseFy(dynamic fy) {
      if (fy == null) return 'FY 2026-2027';
      if (fy is Map) {
        return fy['name']?.toString() ??
            fy['yearName']?.toString() ??
            fy['code']?.toString() ??
            'FY 2026-2027';
      }
      return fy.toString();
    }

    String resolveSpecificVoucherType(Map<String, dynamic> item) {
      final code =
          (item['voucherTypeCode'] ??
                  (item['voucherTypeId'] is Map
                      ? item['voucherTypeId']['code']
                      : null) ??
                  (item['voucherType'] is Map
                      ? item['voucherType']['code']
                      : null) ??
                  item['code'] ??
                  item['type'] ??
                  '')
              .toString()
              .toUpperCase();

      final rawName =
          (item['voucherTypeId'] is Map
              ? item['voucherTypeId']['name']
              : null) ??
          (item['voucherType'] is Map ? item['voucherType']['name'] : null) ??
          item['type']?.toString() ??
          '';

      final refModule = (item['referenceModule'] ?? '')
          .toString()
          .toUpperCase();

      if (code == 'SALES_INVOICE' ||
          code == 'SALE' ||
          refModule == 'SALES' ||
          refModule == 'POS') {
        return 'Sales Invoice Voucher';
      }
      if (code == 'CREDIT_NOTE' ||
          code == 'SALE_RETURN' ||
          refModule == 'SALE_RETURN') {
        return 'Credit Note (Sale Return)';
      }
      if (code == 'PURCHASE_BILL' ||
          code == 'PURCHASE' ||
          refModule == 'PURCHASES') {
        return 'Purchase Bill Voucher';
      }
      if (code == 'DEBIT_NOTE' ||
          code == 'PURCHASE_RETURN' ||
          refModule == 'PURCHASE_RETURN') {
        return 'Debit Note (Purchase Return)';
      }
      if (code == 'PAYMENT_IN' ||
          code == 'RECEIPT' ||
          refModule == 'PAYMENT_IN') {
        return 'Receipt Voucher (Payment-In)';
      }
      if (code == 'PAYMENT_OUT' ||
          code == 'PAYMENT' ||
          refModule == 'PAYMENT_OUT') {
        return 'Payment Voucher (Payment-Out)';
      }
      if (code == 'CONTRA' || refModule == 'CASH_BANK') {
        return 'Bank/Cash Contra Voucher';
      }
      if (code == 'EXPENSE' || refModule == 'EXPENSES') {
        return 'Expense Entry Voucher';
      }
      if (code == 'JOURNAL' || code == 'JV') {
        return 'Journal Entry Voucher';
      }
      if (rawName.isNotEmpty && rawName != 'null') {
        return rawName;
      }
      return 'Journal Entry Voucher';
    }

    final rawVouchers = json['recentVouchers'] as List? ?? [];
    final List<Map<String, dynamic>> vouchers = rawVouchers.map((e) {
      final item = Map<String, dynamic>.from(e as Map);

      final vNo =
          item['voucherNumber']?.toString() ??
          item['voucherNo']?.toString() ??
          item['code']?.toString() ??
          item['_id']?.toString().substring(0, 8) ??
          'JV-0001';

      final typeStr = resolveSpecificVoucherType(item);

      final rawDate =
          item['voucherDate']?.toString() ?? item['date']?.toString() ?? '';
      final dateStr = rawDate.contains('T') ? rawDate.split('T')[0] : rawDate;

      final amountNum =
          (item['totalDebit'] as num?)?.toDouble() ??
          (item['totalAmount'] as num?)?.toDouble() ??
          (item['amount'] as num?)?.toDouble() ??
          0.0;

      final statusStr = item['status']?.toString().toUpperCase() ?? 'POSTED';
      final narration =
          item['narration']?.toString() ??
          item['narrative']?.toString() ??
          item['description']?.toString() ??
          'Double-entry accounting transaction';

      return {
        'voucherNo': vNo,
        'type': typeStr,
        'date': dateStr.isEmpty ? '2026-08-10' : dateStr,
        'amount': amountNum,
        'status': statusStr,
        'narration': narration,
      };
    }).toList();

    return AccountingDashboard(
      isInitialized:
          status['initialized'] == true ||
          status['isInitialized'] == true ||
          json['initialized'] == true,
      accountingEnabled: status['accountingEnabled'] ?? true,
      gstAccountingEnabled: status['gstAccountingEnabled'] ?? true,
      autoVoucherPosting: status['autoVoucherPosting'] ?? true,
      missingDefaultLedgersCount:
          (status['missingDefaultLedgersCount'] as num?)?.toInt() ?? 0,
      activeFinancialYear: parseFy(
        status['activeFinancialYear'] ?? json['activeFinancialYear'],
      ),
      bookLockDate: status['bookLockDate']?.toString() ?? 'None',
      accountGroupCount: (counts['accountGroups'] as num?)?.toInt() ?? 18,
      ledgerCount: (counts['ledgers'] as num?)?.toInt() ?? 42,
      voucherCount:
          (counts['postedVouchers'] as num?)?.toInt() ??
          (counts['vouchers'] as num?)?.toInt() ??
          128,
      draftVoucherCount: (counts['draftVouchers'] as num?)?.toInt() ?? 0,
      postedVoucherCount: (counts['postedVouchers'] as num?)?.toInt() ?? 0,
      cancelledVoucherCount:
          (counts['cancelledVouchers'] as num?)?.toInt() ?? 0,
      recentVouchers: vouchers,
    );
  }
}
