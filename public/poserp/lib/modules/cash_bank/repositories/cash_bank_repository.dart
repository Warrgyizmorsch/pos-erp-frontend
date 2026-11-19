import '../../../../core/api/api_exceptions.dart';
import '../models/bank_account.dart';
import '../models/cash_bank_summary.dart';
import '../services/cash_bank_service.dart';

class CashBankRepository {
  final CashBankService _service;

  CashBankRepository(this._service);

  Future<List<BankAccount>> fetchBankAccounts() async {
    try {
      return await _service.getBankAccounts();
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fetch Bank Accounts.');
    }
  }

  Future<BankAccount> createBankAccount(Map<String, dynamic> payload) async {
    try {
      return await _service.createBankAccount(payload);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to create Bank Account.');
    }
  }

  Future<BankAccount> updateBankAccount(
    String id,
    Map<String, dynamic> payload,
  ) async {
    try {
      return await _service.updateBankAccount(id, payload);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to update Bank Account.');
    }
  }

  Future<void> deleteBankAccount(String id) async {
    try {
      await _service.deleteBankAccount(id);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to delete Bank Account.');
    }
  }

  Future<CashBankSummary> fetchSummary() async {
    try {
      return await _service.getSummary();
    } catch (e) {
      return CashBankSummary(
        cashBalance: 0.0,
        totalBankBalance: 0.0,
        todayInflow: 0.0,
        todayOutflow: 0.0,
        netBalance: 0.0,
      );
    }
  }

  Future<CashBankFetchResult> fetchTransactions({
    int page = 1,
    int limit = 20,
    String? search,
    String? type,
    String? accountId,
  }) async {
    try {
      return await _service.getTransactions(
        page: page,
        limit: limit,
        search: search,
        type: type,
        accountId: accountId,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fetch Cash & Bank transactions.');
    }
  }

  Future<void> createCashEntry(Map<String, dynamic> payload) async {
    try {
      await _service.createCashEntry(payload);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to record cash entry.');
    }
  }

  Future<void> createBankTransfer(Map<String, dynamic> payload) async {
    try {
      await _service.createBankTransfer(payload);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to perform bank transfer.');
    }
  }

  Future<void> reverseTransaction(String id, String reason) async {
    try {
      await _service.reverseTransaction(id, reason);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to reverse transaction.');
    }
  }
}
