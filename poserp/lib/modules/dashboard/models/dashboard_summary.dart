class DashboardSummary {
  final double todaySales;
  final double todayPurchases;
  final double totalReceivables;
  final double totalPayables;
  final double cashBankBalance;
  final int lowStockCount;
  final int totalProducts;

  DashboardSummary({
    required this.todaySales,
    required this.todayPurchases,
    required this.totalReceivables,
    required this.totalPayables,
    required this.cashBankBalance,
    required this.lowStockCount,
    required this.totalProducts,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    // Handle /sales/stats/dashboard format as well as legacy/direct format
    final todayMap = json['today'] is Map<String, dynamic>
        ? json['today'] as Map<String, dynamic>
        : {};
    final lowStockList = json['lowStockProducts'] is List
        ? json['lowStockProducts'] as List
        : [];

    final todayRev =
        (todayMap['totalRevenue'] as num?)?.toDouble() ??
        (json['todaySales'] as num?)?.toDouble() ??
        0.0;
    final lowStock = lowStockList.isNotEmpty
        ? lowStockList.length
        : (json['lowStockCount'] as num?)?.toInt() ?? 0;

    double cashBank = (json['cashBankBalance'] as num?)?.toDouble() ?? 0.0;
    if (cashBank == 0.0 && json['accounting'] is Map<String, dynamic>) {
      final acct = json['accounting'] as Map<String, dynamic>;
      final cash = (acct['totalCashBalance'] as num?)?.toDouble() ?? 0.0;
      final bank = (acct['totalBankBalance'] as num?)?.toDouble() ?? 0.0;
      cashBank = cash + bank;
    }

    final receivables =
        (json['totalReceivables'] as num?)?.toDouble() ??
        (json['receivables'] as num?)?.toDouble() ??
        0.0;
    final payables =
        (json['totalPayables'] as num?)?.toDouble() ??
        (json['payables'] as num?)?.toDouble() ??
        0.0;
    final purchases =
        (json['todayPurchases'] as num?)?.toDouble() ??
        (json['purchases'] as num?)?.toDouble() ??
        0.0;

    return DashboardSummary(
      todaySales: todayRev,
      todayPurchases: purchases,
      totalReceivables: receivables,
      totalPayables: payables,
      cashBankBalance: cashBank,
      lowStockCount: lowStock,
      totalProducts: (json['totalProducts'] as num?)?.toInt() ?? 0,
    );
  }
}
