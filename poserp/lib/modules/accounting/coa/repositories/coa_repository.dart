import '../../../../core/api/api_exceptions.dart';
import '../models/accounting_status.dart';
import '../models/chart_group.dart';
import '../services/coa_service.dart';

class COARepository {
  final COAService _service;

  COARepository(this._service);

  Future<AccountingStatus> fetchStatus() async {
    try {
      return await _service.getStatus();
    } catch (e) {
      return AccountingStatus(
        isInitialized: false,
        companyName: 'Active Workspace',
        accountCount: 0,
      );
    }
  }

  Future<void> initializeEngine() async {
    try {
      await _service.initialize();
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to initialize Accounting Engine.');
    }
  }

  Future<List<ChartGroup>> fetchChartOfAccounts() async {
    try {
      return await _service.getChartOfAccounts();
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fetch Chart of Accounts.');
    }
  }
}
