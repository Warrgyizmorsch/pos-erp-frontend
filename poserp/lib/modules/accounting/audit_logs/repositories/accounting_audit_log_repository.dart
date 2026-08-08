import '../../../../core/api/api_exceptions.dart';
import '../models/accounting_audit_log.dart';
import '../services/accounting_audit_log_service.dart';

class AccountingAuditLogRepository {
  final AccountingAuditLogService _service;

  AccountingAuditLogRepository(this._service);

  Future<List<AccountingAuditLog>> fetchLogs(
    Map<String, dynamic> filters,
  ) async {
    try {
      return await _service.getAuditLogs(filters);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fetch accounting audit logs.');
    }
  }
}
