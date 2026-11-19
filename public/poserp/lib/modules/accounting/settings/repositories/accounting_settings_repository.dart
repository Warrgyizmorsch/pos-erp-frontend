import '../../../../core/api/api_exceptions.dart';
import '../../ledgers/models/accounting_ledger.dart';
import '../models/accounting_settings_model.dart';
import '../services/accounting_settings_service.dart';

class AccountingSettingsRepository {
  final AccountingSettingsService _service;

  AccountingSettingsRepository(this._service);

  Future<AccountingSettingsModel> fetchSettings() async {
    try {
      return await _service.getSettings();
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fetch accounting settings.');
    }
  }

  Future<AccountingSettingsModel> saveSettings(
    Map<String, dynamic> payload,
  ) async {
    try {
      return await _service.updateSettings(payload);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to save accounting settings.');
    }
  }

  Future<AccountingSettingsValidation> validateSettings() async {
    try {
      return await _service.validateSettings();
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to validate accounting settings.');
    }
  }

  Future<AccountingStatusModel> fetchStatus() async {
    try {
      return await _service.getStatus();
    } catch (_) {
      return AccountingStatusModel(
        initialized: true,
        accountingEnabled: true,
        missingDefaultLedgersCount: 0,
        missingDefaultGroupsCount: 0,
      );
    }
  }

  Future<List<AccountingLedger>> fetchAvailableLedgers() async {
    try {
      return await _service.getLedgers();
    } catch (_) {
      return [];
    }
  }

  Future<void> initializeAccounting() async {
    try {
      await _service.initializeAccounting();
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to initialize accounting.');
    }
  }

  Future<void> restoreDefaultLedgers() async {
    try {
      await _service.restoreDefaultLedgers();
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to restore default ledgers.');
    }
  }

  Future<void> runRepair(String actionKey) async {
    try {
      if (actionKey == 'cash-bank') await _service.linkCashBankLedgers();
      if (actionKey == 'parties') await _service.linkPartyLedgers();
      if (actionKey == 'opening') await _service.postOpeningBalances();
      if (actionKey == 'cash-bank-opening') {
        await _service.postCashBankOpeningBalances();
      }
      if (actionKey == 'recalculate') {
        await _service.fixLedgerReconciliation();
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Repair action failed.');
    }
  }
}
