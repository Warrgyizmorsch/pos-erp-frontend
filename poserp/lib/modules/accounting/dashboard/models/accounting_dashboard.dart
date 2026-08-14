class AccountingReportDashboard {
  final double cashBalance;
  final double bankBalance;
  final double receivables;
  final double payables;
  final double totalIncome;
  final double totalExpenses;
  final double netProfit;
  final double netLoss;
  final double trialBalanceDifference;

  AccountingReportDashboard({
    this.cashBalance = 0.0,
    this.bankBalance = 0.0,
    this.receivables = 0.0,
    this.payables = 0.0,
    this.totalIncome = 0.0,
    this.totalExpenses = 0.0,
    this.netProfit = 0.0,
    this.netLoss = 0.0,
    this.trialBalanceDifference = 0.0,
  });

  factory AccountingReportDashboard.fromJson(Map<String, dynamic> json) {
    return AccountingReportDashboard(
      cashBalance: (json['cashBalance'] as num?)?.toDouble() ?? 0.0,
      bankBalance: (json['bankBalance'] as num?)?.toDouble() ?? 0.0,
      receivables: (json['receivables'] as num?)?.toDouble() ?? 0.0,
      payables: (json['payables'] as num?)?.toDouble() ?? 0.0,
      totalIncome: (json['totalIncome'] as num?)?.toDouble() ?? 0.0,
      totalExpenses: (json['totalExpenses'] as num?)?.toDouble() ?? 0.0,
      netProfit: (json['netProfit'] as num?)?.toDouble() ?? 0.0,
      netLoss: (json['netLoss'] as num?)?.toDouble() ?? 0.0,
      trialBalanceDifference:
          (json['trialBalanceDifference'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class AccountingDashboard {
  final bool accountingEnabled;
  final bool gstAccountingEnabled;
  final bool inventoryAccountingEnabled;
  final bool autoVoucherPosting;
  final bool isInitialized;
  final int missingDefaultGroupsCount;
  final int missingDefaultLedgersCount;
  final int missingDefaultVoucherTypesCount;
  final String activeFinancialYearName;
  final String activeFinancialYearDates;

  final int accountGroupCount;
  final int ledgerCount;
  final int voucherTypeCount;
  final int postedVoucherCount;
  final int draftVoucherCount;
  final int cancelledVoucherCount;
  final List<Map<String, dynamic>> recentVouchers;

  AccountingDashboard({
    required this.accountingEnabled,
    required this.gstAccountingEnabled,
    required this.inventoryAccountingEnabled,
    required this.autoVoucherPosting,
    required this.isInitialized,
    required this.missingDefaultGroupsCount,
    required this.missingDefaultLedgersCount,
    required this.missingDefaultVoucherTypesCount,
    required this.activeFinancialYearName,
    required this.activeFinancialYearDates,
    required this.accountGroupCount,
    required this.ledgerCount,
    required this.voucherTypeCount,
    required this.postedVoucherCount,
    required this.draftVoucherCount,
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

    final fy = status['activeFinancialYear'];
    String fyName = 'Not set';
    String fyDates = 'Initialize accounting first';
    if (fy is Map) {
      fyName = fy['name']?.toString() ?? 'FY 2026-2027';
      final sDate = fy['startDate']?.toString().split('T')[0] ?? '';
      final eDate = fy['endDate']?.toString().split('T')[0] ?? '';
      if (sDate.isNotEmpty && eDate.isNotEmpty) {
        fyDates = '$sDate - $eDate';
      }
    } else if (fy != null) {
      fyName = fy.toString();
    }

    final rawVouchers = json['recentVouchers'] as List? ?? [];
    final List<Map<String, dynamic>> vouchers = rawVouchers.map((e) {
      final item = Map<String, dynamic>.from(e as Map);

      final vNo =
          item['voucherNo']?.toString() ??
          item['voucherNumber']?.toString() ??
          item['code']?.toString() ??
          item['_id']?.toString().substring(0, 8) ??
          'JV-0001';

      dynamic vType =
          item['voucherTypeCode'] ??
          (item['voucherTypeId'] is Map
              ? item['voucherTypeId']['code']
              : null) ??
          (item['voucherType'] is Map ? item['voucherType']['name'] : null) ??
          item['type'];
      String typeStr = vType?.toString() ?? 'JOURNAL';

      final rawDate =
          item['date']?.toString() ?? item['voucherDate']?.toString() ?? '';
      final dateStr = rawDate.contains('T') ? rawDate.split('T')[0] : rawDate;

      final totalDebit =
          (item['totalDebit'] as num?)?.toDouble() ??
          (item['totalAmount'] as num?)?.toDouble() ??
          (item['amount'] as num?)?.toDouble() ??
          0.0;
      final totalCredit =
          (item['totalCredit'] as num?)?.toDouble() ??
          (item['totalAmount'] as num?)?.toDouble() ??
          (item['amount'] as num?)?.toDouble() ??
          0.0;

      final statusStr = item['status']?.toString().toUpperCase() ?? 'POSTED';
      final narration =
          item['narration']?.toString() ??
          item['narrative']?.toString() ??
          item['description']?.toString() ??
          '';

      return {
        'id': item['_id']?.toString() ?? '',
        'voucherNo': vNo,
        'type': typeStr,
        'date': dateStr.isEmpty ? '2026-08-14' : dateStr,
        'totalDebit': totalDebit,
        'totalCredit': totalCredit,
        'status': statusStr,
        'narration': narration,
      };
    }).toList();

    return AccountingDashboard(
      accountingEnabled: status['accountingEnabled'] ?? true,
      gstAccountingEnabled: status['gstAccountingEnabled'] ?? true,
      inventoryAccountingEnabled: status['inventoryAccountingEnabled'] ?? true,
      autoVoucherPosting: status['autoVoucherPosting'] ?? true,
      isInitialized:
          status['initialized'] == true ||
          status['isInitialized'] == true ||
          json['initialized'] == true,
      missingDefaultGroupsCount:
          (status['missingDefaultGroupsCount'] as num?)?.toInt() ?? 0,
      missingDefaultLedgersCount:
          (status['missingDefaultLedgersCount'] as num?)?.toInt() ?? 0,
      missingDefaultVoucherTypesCount:
          (status['missingDefaultVoucherTypesCount'] as num?)?.toInt() ?? 0,
      activeFinancialYearName: fyName,
      activeFinancialYearDates: fyDates,
      accountGroupCount: (counts['accountGroups'] as num?)?.toInt() ?? 0,
      ledgerCount: (counts['ledgers'] as num?)?.toInt() ?? 0,
      voucherTypeCount: (counts['voucherTypes'] as num?)?.toInt() ?? 0,
      postedVoucherCount: (counts['postedVouchers'] as num?)?.toInt() ?? 0,
      draftVoucherCount: (counts['draftVouchers'] as num?)?.toInt() ?? 0,
      cancelledVoucherCount:
          (counts['cancelledVouchers'] as num?)?.toInt() ?? 0,
      recentVouchers: vouchers,
    );
  }
}
