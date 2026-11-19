import '../../../../core/api/api_client.dart';
import '../models/dashboard_summary.dart';

class DashboardService {
  final ApiClient _apiClient;

  DashboardService(this._apiClient);

  Future<DashboardSummary> getSummary() async {
    try {
      final response = await _apiClient.get('/sales/stats/dashboard');
      final body = response.data is Map<String, dynamic> ? response.data : {};
      final data = body['data'] ?? body;
      return DashboardSummary.fromJson(Map<String, dynamic>.from(data));
    } catch (_) {
      // Return default empty structure on failure
      return DashboardSummary(
        todaySales: 0.0,
        todayPurchases: 0.0,
        totalReceivables: 0.0,
        totalPayables: 0.0,
        cashBankBalance: 0.0,
        lowStockCount: 0,
        totalProducts: 0,
      );
    }
  }
}
