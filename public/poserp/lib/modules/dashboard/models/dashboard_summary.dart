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
    // Handle /sales/stats/dashboard format as well as direct format
    final todayMap = json['today'] is Map<String, dynamic>
        ? json['today'] as Map<String, dynamic>
        : {};
    final lowStockList = json['lowStockProducts'] is List
        ? json['lowStockProducts'] as List
        : [];
    final acct = json['accounting'] is Map<String, dynamic>
        ? json['accounting'] as Map<String, dynamic>
        : {};

    final todayRev =
        (todayMap['totalRevenue'] as num?)?.toDouble() ??
        (json['todaySales'] as num?)?.toDouble() ??
        0.0;
    final lowStock = lowStockList.isNotEmpty
        ? lowStockList.length
        : (json['lowStockCount'] as num?)?.toInt() ?? 0;

    final cashBal = (acct['totalCashBalance'] as num?)?.toDouble() ?? 0.0;
    final bankBal = (acct['totalBankBalance'] as num?)?.toDouble() ?? 0.0;
    final parsedCashBank = (json['cashBankBalance'] as num?)?.toDouble() ??
        (cashBal + bankBal > 0 ? (cashBal + bankBal) : 0.0);

    final receivables = (json['totalReceivables'] as num?)?.toDouble() ??
        (json['receivables'] as num?)?.toDouble() ??
        (acct['totalReceivables'] as num?)?.toDouble() ??
        0.0;

    final payables = (json['totalPayables'] as num?)?.toDouble() ??
        (json['payables'] as num?)?.toDouble() ??
        (acct['totalPayables'] as num?)?.toDouble() ??
        0.0;

    final purchases = (json['todayPurchases'] as num?)?.toDouble() ??
        (json['purchases'] as num?)?.toDouble() ??
        0.0;

    final totalProds = (json['totalProducts'] as num?)?.toInt() ?? 0;

    return DashboardSummary(
      todaySales: todayRev,
      todayPurchases: purchases,
      totalReceivables: receivables,
      totalPayables: payables,
      cashBankBalance: parsedCashBank,
      lowStockCount: lowStock,
      totalProducts: totalProds,
    );
  }
}
