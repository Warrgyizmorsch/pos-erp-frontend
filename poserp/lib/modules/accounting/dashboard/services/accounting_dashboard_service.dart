import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/accounting_dashboard.dart';

class AccountingDashboardService {
  final ApiClient _apiClient;

  AccountingDashboardService(this._apiClient);

  Future<AccountingDashboard> getDashboard() async {
    final response = await _apiClient.get(ApiEndpoints.accountingDashboard);
    final body = response.data is Map<String, dynamic> ? response.data : {};
    final data = body['data'] ?? body;
    return AccountingDashboard.fromJson(data as Map<String, dynamic>);
  }

  Future<void> initializeAccounting() async {
    await _apiClient.post(ApiEndpoints.accountingInitialize);
  }
}
