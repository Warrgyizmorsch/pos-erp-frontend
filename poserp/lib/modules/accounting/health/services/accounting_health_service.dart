import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/accounting_health.dart';

class AccountingHealthService {
  final ApiClient _apiClient;

  AccountingHealthService(this._apiClient);

  Future<AccountingHealthCheck> getHealthCheck() async {
    final response = await _apiClient.get(ApiEndpoints.accountingHealth);
    final body = response.data is Map<String, dynamic> ? response.data : {};
    final data = body['data'] ?? body;
    return AccountingHealthCheck.fromJson(data as Map<String, dynamic>);
  }

  Future<void> repostMissingAccounting(
    String module,
    String referenceId,
  ) async {
    await _apiClient.post(
      '/accounting/repost-missing',
      data: {'module': module, 'referenceId': referenceId},
    );
  }

  Future<void> fixLedgerReconciliation() async {
    await _apiClient.post(ApiEndpoints.accountingReconciliationLedgersFix);
  }
}
