import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/accounting_reconciliation.dart';

class AccountingReconciliationService {
  final ApiClient _apiClient;

  AccountingReconciliationService(this._apiClient);

  Future<List<LedgerMismatchRow>> getLedgerReconciliation() async {
    final response = await _apiClient.get(
      ApiEndpoints.accountingReconciliationLedgers,
    );
    final body = response.data is Map<String, dynamic> ? response.data : {};
    final data = body['data'] ?? body;
    final list = (data is Map && data['mismatches'] is List)
        ? data['mismatches'] as List
        : (data is List ? data : []);
    return list
        .map((e) => LedgerMismatchRow.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> fixLedgerBalances() async {
    await _apiClient.post(ApiEndpoints.accountingReconciliationLedgersFix);
  }

  Future<List<CashBankReconciliationAccount>>
  getCashBankReconciliation() async {
    final response = await _apiClient.get(
      ApiEndpoints.accountingReconciliationCashBankDetails,
    );
    final body = response.data is Map<String, dynamic> ? response.data : {};
    final data = body['data'] ?? body;
    final list = (data is Map && data['accounts'] is List)
        ? data['accounts'] as List
        : (data is List ? data : []);
    return list
        .map(
          (e) => CashBankReconciliationAccount.fromJson(
            Map<String, dynamic>.from(e),
          ),
        )
        .toList();
  }

  Future<void> linkCashBankLedgers() async {
    await _apiClient.post('/accounting/reconciliation/cash-bank/link-ledgers');
  }

  Future<void> postCashBankOpeningBalances() async {
    await _apiClient.post('/accounting/reconciliation/cash-bank/post-opening');
  }

  Future<List<PartyReconciliationRow>> getPartyReconciliation() async {
    final response = await _apiClient.get(
      ApiEndpoints.accountingReconciliationParties,
    );
    final body = response.data is Map<String, dynamic> ? response.data : {};
    final data = body['data'] ?? body;
    List list = [];
    if (data is Map) {
      final cust = (data['customers'] as List?) ?? [];
      final supp = (data['suppliers'] as List?) ?? [];
      list = [...cust, ...supp];
    } else if (data is List) {
      list = data;
    }
    return list
        .map(
          (e) => PartyReconciliationRow.fromJson(Map<String, dynamic>.from(e)),
        )
        .toList();
  }

  Future<void> linkPartyLedgers() async {
    await _apiClient.post('/accounting/reconciliation/parties/link-ledgers');
  }

  Future<List<GSTReconciliationRow>> getGstReconciliation() async {
    final response = await _apiClient.get(
      ApiEndpoints.accountingReconciliationGst,
    );
    final body = response.data is Map<String, dynamic> ? response.data : {};
    final data = body['data'] ?? body;
    final list = (data is Map && data['rows'] is List)
        ? data['rows'] as List
        : (data is List ? data : []);
    return list
        .map((e) => GSTReconciliationRow.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
