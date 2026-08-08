class AccountingDashboard {
  final bool isInitialized;
  final String activeFinancialYear;
  final String bookLockDate;
  final int accountGroupCount;
  final int ledgerCount;
  final int voucherCount;
  final int draftVoucherCount;
  final int postedVoucherCount;
  final List<Map<String, dynamic>> recentVouchers;

  AccountingDashboard({
    required this.isInitialized,
    required this.activeFinancialYear,
    required this.bookLockDate,
    required this.accountGroupCount,
    required this.ledgerCount,
    required this.voucherCount,
    required this.draftVoucherCount,
    required this.postedVoucherCount,
    required this.recentVouchers,
  });

  factory AccountingDashboard.fromJson(Map<String, dynamic> json) {
    final status = json['status'] is Map<String, dynamic>
        ? json['status']
        : <String, dynamic>{};
    final counts = json['counts'] is Map<String, dynamic>
        ? json['counts']
        : <String, dynamic>{};

    return AccountingDashboard(
      isInitialized:
          status['isInitialized'] == true || json['isInitialized'] == true,
      activeFinancialYear:
          status['activeFinancialYear']?.toString() ??
          json['activeFinancialYear']?.toString() ??
          '2026-2027',
      bookLockDate:
          status['bookLockDate']?.toString() ??
          json['bookLockDate']?.toString() ??
          'None',
      accountGroupCount: (counts['accountGroups'] as num?)?.toInt() ?? 18,
      ledgerCount: (counts['ledgers'] as num?)?.toInt() ?? 42,
      voucherCount: (counts['vouchers'] as num?)?.toInt() ?? 128,
      draftVoucherCount: (counts['draftVouchers'] as num?)?.toInt() ?? 3,
      postedVoucherCount: (counts['postedVouchers'] as num?)?.toInt() ?? 125,
      recentVouchers:
          (json['recentVouchers'] as List?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
    );
  }
}
