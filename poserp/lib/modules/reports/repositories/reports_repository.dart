import '../../../../core/api/api_exceptions.dart';
import '../models/analytics_report.dart';
import '../services/reports_service.dart';

class ReportsRepository {
  final ReportsService _service;

  ReportsRepository(this._service);

  Future<AnalyticsReport> fetchReport(
    String type,
    String period, {
    String? startDate,
    String? endDate,
  }) async {
    try {
      return await _service.getAnalyticsReport(
        type,
        period,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fetch analytics report.');
    }
  }
}
