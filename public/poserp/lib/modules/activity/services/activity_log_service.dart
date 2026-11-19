import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/activity_log.dart';

class ActivityLogResponse {
  final List<ActivityLog> logs;
  final int page;
  final int totalPages;
  final int totalRecords;

  ActivityLogResponse({
    required this.logs,
    required this.page,
    required this.totalPages,
    required this.totalRecords,
  });
}

class ActivityLogService {
  final ApiClient _apiClient;

  ActivityLogService(this._apiClient);

  Future<ActivityLogResponse> getActivityLogs({
    int page = 1,
    int limit = 15,
    String? user,
    String? action,
    String? module,
    String? startDate,
    String? endDate,
  }) async {
    final Map<String, dynamic> queryParams = {'page': page, 'limit': limit};

    if (user != null && user.trim().isNotEmpty) {
      queryParams['user'] = user.trim();
    }
    if (action != null && action != 'all') queryParams['action'] = action;
    if (module != null && module != 'all') queryParams['module'] = module;
    if (startDate != null && startDate.isNotEmpty) {
      queryParams['startDate'] = startDate;
    }
    if (endDate != null && endDate.isNotEmpty) {
      queryParams['endDate'] = endDate;
    }

    final response = await _apiClient.get(
      ApiEndpoints.activityLogs,
      queryParameters: queryParams,
    );

    final Map<String, dynamic> body = response.data is Map<String, dynamic>
        ? response.data
        : {};

    List list = [];
    if (body['data'] != null && body['data'] is List) {
      list = body['data'] as List;
    } else if (response.data is List) {
      list = response.data as List;
    }

    final logs = <ActivityLog>[];
    for (final item in list) {
      if (item is Map<String, dynamic>) {
        try {
          logs.add(ActivityLog.fromJson(item));
        } catch (_) {}
      }
    }

    int currentPage = page;
    int pages = 1;
    int total = logs.length;

    if (body['pagination'] != null &&
        body['pagination'] is Map<String, dynamic>) {
      final pag = body['pagination'] as Map<String, dynamic>;
      currentPage = (pag['page'] as num?)?.toInt() ?? page;
      pages =
          (pag['pages'] as num?)?.toInt() ??
          (pag['totalPages'] as num?)?.toInt() ??
          1;
      total =
          (pag['total'] as num?)?.toInt() ??
          (pag['totalRecords'] as num?)?.toInt() ??
          logs.length;
    }

    return ActivityLogResponse(
      logs: logs,
      page: currentPage,
      totalPages: pages,
      totalRecords: total,
    );
  }
}
