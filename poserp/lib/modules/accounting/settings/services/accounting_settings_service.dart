import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
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
