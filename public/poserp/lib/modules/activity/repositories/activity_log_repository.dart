import '../../../../core/api/api_exceptions.dart';
import '../services/activity_log_service.dart';

class ActivityLogRepository {
  final ActivityLogService _service;

  ActivityLogRepository(this._service);

  Future<ActivityLogResponse> fetchActivityLogs({
    int page = 1,
    int limit = 15,
    String? user,
    String? action,
    String? module,
    String? startDate,
    String? endDate,
  }) async {
    try {
      return await _service.getActivityLogs(
        page: page,
        limit: limit,
        user: user,
        action: action,
        module: module,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fetch activity logs.');
    }
  }
}
