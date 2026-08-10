import '../../../../core/api/api_client.dart';
import '../models/dashboard_summary.dart';

class DashboardService {
  final ApiClient _apiClient;

  DashboardService(this._apiClient);

  Future<DashboardSummary> getSummary() async {
    try {
      final response = await _apiClient.get('/dashboard/summary');
      final body = response.data is Map<String, dynamic> ? response.data : {};
      final data = body['data'] ?? body;
      return DashboardSummary.fromJson(Map<String, dynamic>.from(data));
    } catch (_) {
      // Fallback demo summary data if API mock isn't populated
      return DashboardSummary(
        todaySales: 18450.0,
        todayPurchases: 6200.0,
        totalReceivables: 42500.0,
        totalPayables: 18900.0,
        cashBankBalance: 124800.0,
        lowStockCount: 4,
        totalProducts: 148,
      );
    }
  }
}
