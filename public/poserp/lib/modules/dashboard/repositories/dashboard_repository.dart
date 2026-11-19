import '../models/dashboard_summary.dart';
import '../services/dashboard_service.dart';

class DashboardRepository {
  final DashboardService _service;

  DashboardRepository(this._service);

  Future<DashboardSummary> fetchSummary() async {
    return await _service.getSummary();
  }
}
