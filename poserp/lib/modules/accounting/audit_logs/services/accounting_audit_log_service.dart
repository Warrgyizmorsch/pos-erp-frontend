import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/accounting_audit_log.dart';

class AccountingAuditLogService {
  final ApiClient _apiClient;

  AccountingAuditLogService(this._apiClient);

  Future<List<AccountingAuditLog>> getAuditLogs(
    Map<String, dynamic> filters,
  ) async {
    final response = await _apiClient.get(
      ApiEndpoints.accountingAuditLogs,
      queryParameters: filters,
    );
    final body = response.data is Map<String, dynamic> ? response.data : {};
    final data = body['data'] ?? body;
    final list = data is List ? data : [];
    return list
        .map((e) => AccountingAuditLog.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
