import '../../../../core/api/api_exceptions.dart';
import '../models/accounting_health.dart';
import '../services/accounting_health_service.dart';

class AccountingHealthRepository {
  final AccountingHealthService _service;

  AccountingHealthRepository(this._service);

  Future<AccountingHealthCheck> fetchHealthCheck() async {
    try {
      return await _service.getHealthCheck();
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to run accounting health check.');
    }
  }

  Future<void> repostMissing(String module, String referenceId) async {
    try {
      await _service.repostMissingAccounting(module, referenceId);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to repost missing accounting entry.');
    }
  }

  Future<void> fixLedgers() async {
    try {
      await _service.fixLedgerReconciliation();
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to recalculate ledger balances.');
    }
  }
}
