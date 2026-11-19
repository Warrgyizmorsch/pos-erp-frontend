import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/analytics_report.dart';

class ReportsService {
  final ApiClient _apiClient;

  ReportsService(this._apiClient);

  Future<AnalyticsReport> getAnalyticsReport(
    String type,
    String period, {
    String? startDate,
    String? endDate,
  }) async {
    String endpoint = ApiEndpoints.analyticsSales;
    if (type == 'inventory') endpoint = ApiEndpoints.analyticsInventory;
    if (type == 'purchases') endpoint = ApiEndpoints.analyticsPurchases;
    if (type == 'revenue') endpoint = ApiEndpoints.analyticsRevenue;
    if (type == 'cashflow') endpoint = ApiEndpoints.analyticsCashflow;

    final Map<String, dynamic> queryParams = {'period': period};
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;

    final response = await _apiClient.get(
      endpoint,
      queryParameters: queryParams,
    );
    final body = response.data is Map<String, dynamic> ? response.data : {};
    final data = body['data'] ?? body;
    return AnalyticsReport.fromJson(data as Map<String, dynamic>);
  }
}
