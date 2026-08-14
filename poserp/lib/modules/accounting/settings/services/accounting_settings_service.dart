import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../ledgers/models/accounting_ledger.dart';
import '../models/accounting_settings_model.dart';

class AccountingSettingsService {
  final ApiClient _apiClient;

  AccountingSettingsService(this._apiClient);

  Future<AccountingSettingsModel> getSettings() async {
    final response = await _apiClient.get(ApiEndpoints.accountingSettings);
    final body = response.data is Map<String, dynamic> ? response.data : {};
    final data = body['data'] ?? body;
    return AccountingSettingsModel.fromJson(data as Map<String, dynamic>);
  }

  Future<AccountingSettingsModel> updateSettings(
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.put(
      ApiEndpoints.accountingSettings,
      data: payload,
    );
    final body = response.data is Map<String, dynamic> ? response.data : {};
    final data = body['data'] ?? body;
    return AccountingSettingsModel.fromJson(data as Map<String, dynamic>);
  }

  Future<AccountingSettingsValidation> validateSettings() async {
    final response = await _apiClient.get(
      ApiEndpoints.accountingSettingsValidate,
    );
    final body = response.data is Map<String, dynamic> ? response.data : {};
    final data = body['data'] ?? body;
    return AccountingSettingsValidation.fromJson(data as Map<String, dynamic>);
  }

  Future<AccountingStatusModel> getStatus() async {
    final response = await _apiClient.get('/accounting/status');
    final body = response.data is Map<String, dynamic> ? response.data : {};
    final data = body['data'] ?? body;
    return AccountingStatusModel.fromJson(data as Map<String, dynamic>);
  }

  Future<List<AccountingLedger>> getLedgers() async {
    dynamic responseData;
    try {
      final response = await _apiClient.get(
        ApiEndpoints.accountingLedgers,
        queryParameters: {'isActive': true, 'status': 'ACTIVE'},
      );
      responseData = response.data;
    } catch (_) {
      try {
        final response = await _apiClient.get(ApiEndpoints.accountingLedgers);
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

  Future<void> initializeAccounting() async {
    await _apiClient.post('/accounting/initialize');
  }

  Future<void> restoreDefaultLedgers() async {
    await _apiClient.post('/accounting/restore-defaults');
  }

  Future<void> linkCashBankLedgers() async {
    await _apiClient.post('/accounting/reconciliation/cash-bank/link-ledgers');
  }

  Future<void> linkPartyLedgers() async {
    await _apiClient.post('/accounting/reconciliation/parties/link-ledgers');
  }

  Future<void> postOpeningBalances() async {
    await _apiClient.post('/accounting/opening-balances/post-all');
  }

  Future<void> postCashBankOpeningBalances() async {
    await _apiClient.post('/accounting/reconciliation/cash-bank/post-opening');
  }

  Future<void> fixLedgerReconciliation() async {
    await _apiClient.post('/accounting/reconciliation/ledgers/fix');
  }
}
