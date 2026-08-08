import '../../../../core/api/api_exceptions.dart';
import '../models/accounting_dashboard.dart';
import '../services/accounting_dashboard_service.dart';

class AccountingDashboardRepository {
  final AccountingDashboardService _service;

  AccountingDashboardRepository(this._service);

  Future<AccountingDashboard> fetchDashboard() async {
    try {
      return await _service.getDashboard();
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to load accounting dashboard.');
    }
  }

  Future<void> initializeEngine() async {
    try {
      await _service.initializeAccounting();
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(
        message: 'Failed to initialize accounting foundation.',
      );
    }
  }
}
