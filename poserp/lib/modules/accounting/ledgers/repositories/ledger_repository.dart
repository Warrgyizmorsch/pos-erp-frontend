import '../../../../core/api/api_exceptions.dart';
import '../models/accounting_ledger.dart';
import '../models/ledger_statement.dart';
import '../services/ledger_service.dart';

class LedgerRepository {
  final LedgerService _service;

  LedgerRepository(this._service);

  Future<List<AccountingLedger>> fetchLedgers({
    String? search,
    String? group,
    String? nature,
    String? ledgerType,
    String? status,
  }) async {
    try {
      return await _service.getLedgers(
        search: search,
        group: group,
        nature: nature,
        ledgerType: ledgerType,
        status: status,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fetch Ledgers.');
    }
  }

  Future<LedgerStatement?> fetchLedgerStatement(
    String id, {
    String? startDate,
    String? endDate,
    String? voucherTypeCode,
    String? search,
  }) async {
    try {
      return await _service.getLedgerStatement(
        id,
        startDate: startDate,
        endDate: endDate,
        voucherTypeCode: voucherTypeCode,
        search: search,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fetch Ledger Statement.');
    }
  }

  Future<void> restoreDefaults() async {
    try {
      await _service.restoreDefaultLedgers();
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to restore default ledgers.');
    }
  }
}
