import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/bank_import_models.dart';

class BankImportService {
  final ApiClient _apiClient;

  BankImportService(this._apiClient);

  Future<BankStatementImportSession> importStatement(
    String bankAccountId,
    List<Map<String, dynamic>> rawRows,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.bankStatementImport,
      data: {'bankAccountId': bankAccountId, 'rows': rawRows},
    );
    final body = response.data is Map<String, dynamic> ? response.data : {};
    final data = body['data'] ?? body;
    return BankStatementImportSession.fromJson(data as Map<String, dynamic>);
  }

  Future<void> postEntries(
    String sessionId,
    List<String> transactionIds,
  ) async {
    await _apiClient.post(
      ApiEndpoints.bankStatementPostEntries(sessionId),
      data: {'transactionIds': transactionIds},
    );
  }

  Future<List<BankMappingRule>> getMappingRules() async {
    final response = await _apiClient.get(ApiEndpoints.bankStatementMappings);
    final body = response.data is Map<String, dynamic> ? response.data : {};
    final data = body['data'] ?? body;
    final list = data is List ? data : [];
    return list
        .map((e) => BankMappingRule.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<BankMappingRule> createMappingRule(Map<String, dynamic> data) async {
    final response = await _apiClient.post(
      ApiEndpoints.bankStatementMappings,
      data: data,
    );
    final body = response.data is Map<String, dynamic> ? response.data : {};
    return BankMappingRule.fromJson(
      (body['data'] ?? body) as Map<String, dynamic>,
    );
  }

  Future<void> deleteMappingRule(String id) async {
    await _apiClient.delete('${ApiEndpoints.bankStatementMappings}/$id');
  }

  Future<BankImportSettings> getSettings() async {
    final response = await _apiClient.get(ApiEndpoints.bankStatementSettings);
    final body = response.data is Map<String, dynamic> ? response.data : {};
    final data = body['data'] ?? body;
    return BankImportSettings.fromJson(data as Map<String, dynamic>);
  }

  Future<BankImportSettings> updateSettings(Map<String, dynamic> data) async {
    final response = await _apiClient.put(
      ApiEndpoints.bankStatementSettings,
      data: data,
    );
    final body = response.data is Map<String, dynamic> ? response.data : {};
    return BankImportSettings.fromJson(
      (body['data'] ?? body) as Map<String, dynamic>,
    );
  }
}
