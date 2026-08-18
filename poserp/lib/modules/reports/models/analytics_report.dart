class AnalyticsReport {
  final double totalSales;
  final double totalRevenue;
  final double grossProfit;
  final double netProfit;
  final double averageOrderValue;
  final double totalDiscounts;
  final double totalTax;
  final double purchaseCost;
  final double totalExpenses;
  final int totalOrders;
  final List<Map<String, dynamic>> topProducts;
  final List<Map<String, dynamic>> reportRows;

  AnalyticsReport({
    required this.totalSales,
    required this.totalRevenue,
    required this.grossProfit,
    required this.netProfit,
    required this.averageOrderValue,
    required this.totalDiscounts,
    required this.totalTax,
    required this.purchaseCost,
    required this.totalExpenses,
    required this.totalOrders,
    required this.topProducts,
    required this.reportRows,
  });

  double get profitMargin =>
      totalSales > 0 ? (netProfit / totalSales) * 100 : 0.0;
  double get grossProfitMargin =>
      totalSales > 0 ? (grossProfit / totalSales) * 100 : 0.0;

  factory AnalyticsReport.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] is Map<String, dynamic>
        ? json['summary']
        : json;

    return AnalyticsReport(
      totalSales: (summary['totalSales'] as num?)?.toDouble() ?? 0.0,
      totalRevenue:
          (summary['totalRevenue'] as num?)?.toDouble() ??
          (summary['totalSales'] as num?)?.toDouble() ??
          0.0,
      grossProfit: (summary['grossProfit'] as num?)?.toDouble() ?? 0.0,
      netProfit: (summary['netProfit'] as num?)?.toDouble() ?? 0.0,
      averageOrderValue:
          (summary['averageOrderValue'] as num?)?.toDouble() ?? 0.0,
      totalDiscounts: (summary['totalDiscounts'] as num?)?.toDouble() ?? 0.0,
      totalTax: (summary['totalTax'] as num?)?.toDouble() ?? 0.0,
      purchaseCost: (summary['purchaseCost'] as num?)?.toDouble() ?? 0.0,
      totalExpenses:
          (summary['totalExpenses'] as num?)?.toDouble() ??
          (summary['expenses'] as num?)?.toDouble() ??
          0.0,
      totalOrders:
          (summary['totalOrders'] as num?)?.toInt() ??
          (summary['orderCount'] as num?)?.toInt() ??
          (summary['count'] as num?)?.toInt() ??
          0,
      topProducts:
          (json['topProducts'] as List?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
      reportRows:
          (json['table'] as List?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
    );
  }
}
