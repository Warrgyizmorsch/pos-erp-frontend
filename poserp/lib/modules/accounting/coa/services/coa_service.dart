import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/accounting_status.dart';
import '../models/chart_group.dart';

class COAService {
  final ApiClient _apiClient;

  COAService(this._apiClient);

  Future<AccountingStatus> getStatus() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.accountingStatus);
      final Map<String, dynamic> body = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : {};
      final data = body['data'] ?? body;
      return AccountingStatus.fromJson(data as Map<String, dynamic>);
    } catch (_) {
      return AccountingStatus(
        isInitialized: false,
        companyName: 'Active Workspace',
        accountCount: 0,
      );
    }
  }

  Future<void> initialize() async {
    await _apiClient.post(ApiEndpoints.accountingInitialize);
  }

  Future<List<ChartGroup>> getChartOfAccounts() async {
    final response = await _apiClient.get(
      ApiEndpoints.accountingChartOfAccounts,
    );

    List list = [];
    if (response.data is Map<String, dynamic>) {
      final Map<String, dynamic> body = response.data as Map<String, dynamic>;
      if (body['data'] != null && body['data'] is List) {
        list = body['data'] as List;
      } else if (body['chart'] != null && body['chart'] is List) {
        list = body['chart'] as List;
      } else if (body['groups'] != null && body['groups'] is List) {
        list = body['groups'] as List;
      }
    } else if (response.data is List) {
      list = response.data as List;
    }

    final groups = <ChartGroup>[];
    for (final item in list) {
      if (item is Map<String, dynamic>) {
        try {
          groups.add(ChartGroup.fromJson(item));
        } catch (_) {}
      }
    }
    return groups;
  }
}
