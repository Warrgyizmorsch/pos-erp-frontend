class AnalyticsReport {
  // Sales Metrics
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

  // Inventory Metrics
  final int totalProducts;
  final double inventoryValue;
  final double inventoryCost;
  final double potentialProfit;
  final int lowStockProducts;
  final int outOfStockProducts;

  // Purchase Metrics
  final int totalPurchases;
  final double totalPurchaseAmount;
  final int supplierCount;
  final double averagePurchaseValue;
  final double pendingPayments;

  // Cashflow Metrics
  final double totalCashIn;
  final double totalCashOut;
  final double netCashFlow;

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
    required this.totalProducts,
    required this.inventoryValue,
    required this.inventoryCost,
    required this.potentialProfit,
    required this.lowStockProducts,
    required this.outOfStockProducts,
    required this.totalPurchases,
    required this.totalPurchaseAmount,
    required this.supplierCount,
    required this.averagePurchaseValue,
    required this.pendingPayments,
    required this.totalCashIn,
    required this.totalCashOut,
    required this.netCashFlow,
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
          0,
      totalProducts: (summary['totalProducts'] as num?)?.toInt() ?? 0,
      inventoryValue:
          (summary['inventoryValue'] as num?)?.toDouble() ??
          (summary['currentInventoryValue'] as num?)?.toDouble() ??
          0.0,
      inventoryCost:
          (summary['inventoryCost'] as num?)?.toDouble() ??
          (summary['totalInventoryCost'] as num?)?.toDouble() ??
          0.0,
      potentialProfit: (summary['potentialProfit'] as num?)?.toDouble() ?? 0.0,
      lowStockProducts:
          (summary['lowStockProducts'] as num?)?.toInt() ??
          (summary['lowStock'] as num?)?.toInt() ??
          0,
      outOfStockProducts:
          (summary['outOfStockProducts'] as num?)?.toInt() ??
          (summary['outOfStock'] as num?)?.toInt() ??
          0,
      totalPurchases: (summary['totalPurchases'] as num?)?.toInt() ?? 0,
      totalPurchaseAmount:
          (summary['totalPurchaseAmount'] as num?)?.toDouble() ?? 0.0,
      supplierCount: (summary['supplierCount'] as num?)?.toInt() ?? 0,
      averagePurchaseValue:
          (summary['averagePurchaseValue'] as num?)?.toDouble() ?? 0.0,
      pendingPayments: (summary['pendingPayments'] as num?)?.toDouble() ?? 0.0,
      totalCashIn: (summary['totalCashIn'] as num?)?.toDouble() ?? 0.0,
      totalCashOut: (summary['totalCashOut'] as num?)?.toDouble() ?? 0.0,
      netCashFlow: (summary['netCashFlow'] as num?)?.toDouble() ?? 0.0,
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
