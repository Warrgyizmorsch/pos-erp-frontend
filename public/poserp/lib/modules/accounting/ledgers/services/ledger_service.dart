import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/accounting_ledger.dart';
import '../models/ledger_statement.dart';

class LedgerService {
  final ApiClient _apiClient;

  LedgerService(this._apiClient);

  Future<List<AccountingLedger>> getLedgers({
    String? search,
    String? group,
    String? nature,
    String? ledgerType,
    String? status,
  }) async {
    final Map<String, dynamic> queryParams = {};
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }
    if (group != null && group != 'ALL') queryParams['group'] = group;
    if (nature != null && nature != 'ALL') queryParams['nature'] = nature;
    if (ledgerType != null && ledgerType != 'ALL') {
      queryParams['ledgerType'] = ledgerType;
    }
    if (status != null && status != 'ALL') queryParams['status'] = status;

    dynamic responseData;
    try {
      final response = await _apiClient.get(
        ApiEndpoints.accountingLedgers,
        queryParameters: queryParams,
      );
      responseData = response.data;
    } catch (_) {
      try {
        final response = await _apiClient.get(
          ApiEndpoints.expenseLedgers,
          queryParameters: queryParams,
        );
        responseData = response.data;
      } catch (_) {
        return [];
      }
    }

    List list = [];
    if (responseData is Map<String, dynamic>) {
      final Map<String, dynamic> body = responseData;
      if (body['data'] != null && body['data'] is List) {
        list = body['data'] as List;
      } else if (body['ledgers'] != null && body['ledgers'] is List) {
        list = body['ledgers'] as List;
      }
    } else if (responseData is List) {
      list = responseData;
    }

    final ledgers = <AccountingLedger>[];
    for (final item in list) {
      if (item is Map<String, dynamic>) {
        try {
          ledgers.add(AccountingLedger.fromJson(item));
        } catch (_) {}
      }
    }
    return ledgers;
  }

  Future<LedgerStatement?> getLedgerStatement(
    String id, {
    String? startDate,
    String? endDate,
    String? voucherTypeCode,
    String? search,
  }) async {
    final Map<String, dynamic> queryParams = {};
    if (startDate != null && startDate.isNotEmpty) {
      queryParams['startDate'] = startDate;
    }
    if (endDate != null && endDate.isNotEmpty) {
      queryParams['endDate'] = endDate;
    }
    if (voucherTypeCode != null && voucherTypeCode.isNotEmpty) {
      queryParams['voucherTypeCode'] = voucherTypeCode;
    }
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }

    dynamic responseData;
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.accountingLedgers}/$id/statement',
        queryParameters: queryParams,
      );
      responseData = response.data;
    } catch (_) {
      try {
        final response = await _apiClient.get(
          '/ledger/$id',
          queryParameters: queryParams,
        );
        responseData = response.data;
      } catch (_) {
        return null;
      }
    }

    if (responseData == null) return null;
    final Map<String, dynamic> body = responseData is Map<String, dynamic>
        ? responseData
        : {};
    final data = body['data'] ?? body;
    if (data == null || (data is Map && data.isEmpty)) return null;

    return LedgerStatement.fromJson(data as Map<String, dynamic>);
  }

  Future<void> restoreDefaultLedgers() async {
    await _apiClient.post('${ApiEndpoints.accountingLedgers}/restore-defaults');
  }
}
