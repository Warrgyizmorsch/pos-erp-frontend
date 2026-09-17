import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/dashboard_summary.dart';

class DashboardService {
  final ApiClient _apiClient;

  DashboardService(this._apiClient);

  Future<DashboardSummary> getSummary() async {
    double todaySales = 0.0;
    double todayPurchases = 0.0;
    double totalReceivables = 0.0;
    double totalPayables = 0.0;
    double cashBankBalance = 0.0;
    int lowStockCount = 0;
    int totalProducts = 0;

    // 1. Fetch Sales & Inventory KPIs
    try {
      final response = await _apiClient.get('/sales/stats/dashboard');
      final body = response.data is Map<String, dynamic> ? response.data : {};
      final data = body['data'] is Map<String, dynamic> ? body['data'] : body;

      final summary = DashboardSummary.fromJson(Map<String, dynamic>.from(data));
      todaySales = summary.todaySales;
      lowStockCount = summary.lowStockCount;
      totalProducts = summary.totalProducts;
      cashBankBalance = summary.cashBankBalance;
      totalReceivables = summary.totalReceivables;
      totalPayables = summary.totalPayables;
      todayPurchases = summary.todayPurchases;
    } catch (_) {}

    // 2. Supplement Receivables & Payables if missing
    if (totalReceivables == 0.0 && totalPayables == 0.0) {
      try {
        final khaataRes = await _apiClient.get('/khaata/balances');
        final kBody = khaataRes.data is Map<String, dynamic> ? khaataRes.data : {};
        final kData = kBody['data'] is Map<String, dynamic> ? kBody['data'] : kBody;
        totalReceivables = (kData['totalReceivables'] as num?)?.toDouble() ?? 0.0;
        totalPayables = (kData['totalPayables'] as num?)?.toDouble() ?? 0.0;
      } catch (_) {
        try {
          final acctRes = await _apiClient.get(ApiEndpoints.accountingReportDashboard);
          final aBody = acctRes.data is Map<String, dynamic> ? acctRes.data : {};
          final aData = aBody['data'] is Map<String, dynamic> ? aBody['data'] : aBody;
          totalReceivables = (aData['receivables'] as num?)?.toDouble() ?? 0.0;
          totalPayables = (aData['payables'] as num?)?.toDouble() ?? 0.0;
          if (cashBankBalance == 0.0) {
            final cash = (aData['cashBalance'] as num?)?.toDouble() ?? 0.0;
            final bank = (aData['bankBalance'] as num?)?.toDouble() ?? 0.0;
            cashBankBalance = cash + bank;
          }
        } catch (_) {}
      }
    }

    // 3. Supplement Today's Purchases if missing
    if (todayPurchases == 0.0) {
      try {
        final todayStr = DateTime.now().toIso8601String().split('T')[0];
        final purRes = await _apiClient.get(
          ApiEndpoints.purchases,
          queryParameters: {'limit': 50, 'startDate': todayStr, 'endDate': todayStr},
        );
        final pBody = purRes.data is Map<String, dynamic> ? purRes.data : {};
        final pList = pBody['data'] as List? ?? [];
        todayPurchases = pList.fold(0.0, (sum, p) {
          final total = (p['totalAmount'] as num?)?.toDouble() ?? 0.0;
          return sum + total;
        });
      } catch (_) {}
    }

    return DashboardSummary(
      todaySales: todaySales,
      todayPurchases: todayPurchases,
      totalReceivables: totalReceivables,
      totalPayables: totalPayables,
      cashBankBalance: cashBankBalance,
      lowStockCount: lowStockCount,
      totalProducts: totalProducts,
    );
  }
}
