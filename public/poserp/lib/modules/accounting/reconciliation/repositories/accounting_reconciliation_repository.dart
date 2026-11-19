import '../../../../core/api/api_exceptions.dart';
import '../models/accounting_reconciliation.dart';
import '../services/accounting_reconciliation_service.dart';

class AccountingReconciliationRepository {
  final AccountingReconciliationService _service;

  AccountingReconciliationRepository(this._service);

  Future<List<LedgerMismatchRow>> fetchLedgerReconciliation() async {
    try {
      return await _service.getLedgerReconciliation();
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fetch ledger reconciliation.');
    }
  }

  Future<void> fixLedgerBalances() async {
    try {
      await _service.fixLedgerBalances();
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fix ledger balances.');
    }
  }

  Future<List<CashBankReconciliationAccount>>
  fetchCashBankReconciliation() async {
    try {
      return await _service.getCashBankReconciliation();
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fetch cash/bank reconciliation.');
    }
  }

  Future<void> linkCashBankLedgers() async {
    try {
      await _service.linkCashBankLedgers();
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to link cash/bank ledgers.');
    }
  }

  Future<void> postCashBankOpeningBalances() async {
    try {
      await _service.postCashBankOpeningBalances();
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to post cash/bank opening balances.');
    }
  }

  Future<List<PartyReconciliationRow>> fetchPartyReconciliation() async {
    try {
      return await _service.getPartyReconciliation();
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fetch party reconciliation.');
    }
  }

  Future<void> linkPartyLedgers() async {
    try {
      await _service.linkPartyLedgers();
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to link party ledgers.');
    }
  }

  Future<List<GSTReconciliationRow>> fetchGstReconciliation() async {
    try {
      return await _service.getGstReconciliation();
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fetch GST reconciliation.');
    }
  }
}
