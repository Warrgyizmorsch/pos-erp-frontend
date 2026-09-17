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

    return DashboardSummary(
      todaySales: todayRev,
      todayPurchases: (json['todayPurchases'] as num?)?.toDouble() ?? 0.0,
      totalReceivables: (json['totalReceivables'] as num?)?.toDouble() ?? 0.0,
      totalPayables: (json['totalPayables'] as num?)?.toDouble() ?? 0.0,
      cashBankBalance: (json['cashBankBalance'] as num?)?.toDouble() ?? 0.0,
      lowStockCount: lowStock,
      totalProducts: (json['totalProducts'] as num?)?.toInt() ?? 0,
    );
  }
}
