import '../../../../core/api/api_exceptions.dart';
import '../models/bank_import_models.dart';
import '../services/bank_import_service.dart';

class BankImportRepository {
  final BankImportService _service;

  BankImportRepository(this._service);

  Future<BankStatementImportSession> importStatement(
    String bankAccountId,
    List<Map<String, dynamic>> rawRows,
  ) async {
    try {
      return await _service.importStatement(bankAccountId, rawRows);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to parse bank statement.');
    }
  }

  Future<void> postEntries(
    String sessionId,
    List<String> transactionIds,
  ) async {
    try {
      await _service.postEntries(sessionId, transactionIds);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to post accounting entries.');
    }
  }

  Future<List<BankMappingRule>> fetchMappingRules() async {
    try {
      return await _service.getMappingRules();
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fetch mapping rules.');
    }
  }

  Future<BankMappingRule> createRule(Map<String, dynamic> data) async {
    try {
      return await _service.createMappingRule(data);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to create mapping rule.');
    }
  }

  Future<void> deleteRule(String id) async {
    try {
      await _service.deleteMappingRule(id);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to delete mapping rule.');
    }
  }

  Future<BankImportSettings> fetchSettings() async {
    try {
      return await _service.getSettings();
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fetch bank import settings.');
    }
  }

  Future<BankImportSettings> saveSettings(Map<String, dynamic> data) async {
    try {
      return await _service.updateSettings(data);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to save bank import settings.');
    }
  }
}
