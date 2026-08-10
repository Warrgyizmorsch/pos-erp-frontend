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
    return DashboardSummary(
      todaySales: (json['todaySales'] as num?)?.toDouble() ?? 0.0,
      todayPurchases: (json['todayPurchases'] as num?)?.toDouble() ?? 0.0,
      totalReceivables: (json['totalReceivables'] as num?)?.toDouble() ?? 0.0,
      totalPayables: (json['totalPayables'] as num?)?.toDouble() ?? 0.0,
      cashBankBalance: (json['cashBankBalance'] as num?)?.toDouble() ?? 0.0,
      lowStockCount: (json['lowStockCount'] as num?)?.toInt() ?? 0,
      totalProducts: (json['totalProducts'] as num?)?.toInt() ?? 0,
    );
  }
}
