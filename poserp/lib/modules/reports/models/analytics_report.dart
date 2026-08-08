class AnalyticsReport {
  final double totalRevenue;
  final double totalExpenses;
  final double netProfit;
  final int totalOrders;
  final double averageOrderValue;
  final List<Map<String, dynamic>> topProducts;
  final List<Map<String, dynamic>> reportRows;

  AnalyticsReport({
    required this.totalRevenue,
    required this.totalExpenses,
    required this.netProfit,
    required this.totalOrders,
    required this.averageOrderValue,
    required this.topProducts,
    required this.reportRows,
  });

  factory AnalyticsReport.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] is Map<String, dynamic>
        ? json['summary']
        : json;

    return AnalyticsReport(
      totalRevenue:
          (summary['totalRevenue'] as num?)?.toDouble() ??
          (summary['totalSales'] as num?)?.toDouble() ??
          0.0,
      totalExpenses:
          (summary['totalExpenses'] as num?)?.toDouble() ??
          (summary['totalCost'] as num?)?.toDouble() ??
          0.0,
      netProfit: (summary['netProfit'] as num?)?.toDouble() ?? 0.0,
      totalOrders:
          (summary['totalOrders'] as num?)?.toInt() ??
          (summary['count'] as num?)?.toInt() ??
          0,
      averageOrderValue:
          (summary['averageOrderValue'] as num?)?.toDouble() ?? 0.0,
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
