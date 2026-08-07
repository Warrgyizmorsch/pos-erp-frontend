import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../data/models/pagination.dart';
import '../models/bank_account.dart';
import '../models/cash_bank_summary.dart';
import '../models/cash_bank_transaction.dart';

class CashBankFetchResult {
  final List<CashBankTransaction> data;
  final Pagination? pagination;

  CashBankFetchResult({required this.data, this.pagination});
}

class CashBankService {
  final ApiClient _apiClient;

  CashBankService(this._apiClient);

  // Bank Accounts
  Future<List<BankAccount>> getBankAccounts() async {
    dynamic responseData;
    try {
      final response = await _apiClient.get(ApiEndpoints.bank);
      responseData = response.data;
    } catch (_) {
      try {
        final response = await _apiClient.get(ApiEndpoints.cashBankAccounts);
        responseData = response.data;
      } catch (_) {
        return [];
      }
    }

    List list = [];
    if (responseData is Map<String, dynamic>) {
      final Map<String, dynamic> body = responseData;
      list = body['data'] as List? ?? [];
    } else if (responseData is List) {
      list = responseData;
    }

    final accounts = <BankAccount>[];
    for (final item in list) {
      if (item is Map<String, dynamic>) {
        try {
          accounts.add(BankAccount.fromJson(item));
        } catch (_) {}
      }
    }
    return accounts;
  }

  Future<BankAccount> createBankAccount(Map<String, dynamic> payload) async {
    dynamic responseData;
    try {
      final response = await _apiClient.post(ApiEndpoints.bank, data: payload);
      responseData = response.data;
    } catch (_) {
      final response = await _apiClient.post(
        ApiEndpoints.cashBankAccounts,
        data: payload,
      );
      responseData = response.data;
    }

    final Map<String, dynamic> body = responseData is Map<String, dynamic>
        ? responseData
        : {};
    final data = body['data'] ?? body;
    return BankAccount.fromJson(data as Map<String, dynamic>);
  }

  Future<BankAccount> updateBankAccount(
    String id,
    Map<String, dynamic> payload,
  ) async {
    dynamic responseData;
    try {
      final response = await _apiClient.put(
        '${ApiEndpoints.bank}/$id',
        data: payload,
      );
      responseData = response.data;
    } catch (_) {
      final response = await _apiClient.put(
        '${ApiEndpoints.cashBankAccounts}/$id',
        data: payload,
      );
      responseData = response.data;
    }

    final Map<String, dynamic> body = responseData is Map<String, dynamic>
        ? responseData
        : {};
    final data = body['data'] ?? body;
    return BankAccount.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteBankAccount(String id) async {
    try {
      await _apiClient.delete('${ApiEndpoints.bank}/$id');
    } catch (_) {
      await _apiClient.delete('${ApiEndpoints.cashBankAccounts}/$id');
    }
  }

  // Cash & Bank Summary
  Future<CashBankSummary> getSummary() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.cashBankSummary);
      final Map<String, dynamic> body = response.data as Map<String, dynamic>;
      final data = body['data'] ?? body;
      return CashBankSummary.fromJson(data as Map<String, dynamic>);
    } catch (_) {
      final accounts = await getBankAccounts();
      final totalBank = accounts.fold(0.0, (sum, a) => sum + a.currentBalance);
      return CashBankSummary(
        cashBalance: 0.0,
        totalBankBalance: totalBank,
        todayInflow: 0.0,
        todayOutflow: 0.0,
        netBalance: totalBank,
      );
    }
  }

  // Transactions
  Future<CashBankFetchResult> getTransactions({
    int page = 1,
    int limit = 20,
    String? search,
    String? type,
    String? accountId,
  }) async {
    final Map<String, dynamic> queryParams = {'page': page, 'limit': limit};
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }
    if (type != null && type.trim().isNotEmpty && type != 'all') {
      queryParams['type'] = type;
    }
    if (accountId != null && accountId.trim().isNotEmpty) {
      queryParams['accountId'] = accountId;
    }

    dynamic responseData;
    try {
      final response = await _apiClient.get(
        ApiEndpoints.cashBankTransactions,
        queryParameters: queryParams,
      );
      responseData = response.data;
    } catch (_) {
      try {
        final response = await _apiClient.get(
          ApiEndpoints.bankTransactions,
          queryParameters: queryParams,
        );
        responseData = response.data;
      } catch (_) {
        return CashBankFetchResult(data: []);
      }
    }

    List list = [];
    Pagination? pagination;

    if (responseData is Map<String, dynamic>) {
      final Map<String, dynamic> body = responseData;
      if (body['data'] != null) {
        if (body['data'] is List) {
          list = body['data'] as List;
        } else if (body['data'] is Map<String, dynamic> &&
            body['data']['transactions'] is List) {
          list = body['data']['transactions'] as List;
        }
      } else if (body['transactions'] is List) {
        list = body['transactions'] as List;
      }

      if (body['pagination'] != null &&
          body['pagination'] is Map<String, dynamic>) {
        pagination = Pagination.fromJson(
          body['pagination'] as Map<String, dynamic>,
        );
      }
    } else if (responseData is List) {
      list = responseData;
    }

    final txs = <CashBankTransaction>[];
    for (final item in list) {
      if (item is Map<String, dynamic>) {
        try {
          txs.add(CashBankTransaction.fromJson(item));
        } catch (_) {}
      }
    }

    return CashBankFetchResult(data: txs, pagination: pagination);
  }

  Future<void> createCashEntry(Map<String, dynamic> payload) async {
    await _apiClient.post(ApiEndpoints.cashBankCashEntry, data: payload);
  }

  Future<void> createBankTransfer(Map<String, dynamic> payload) async {
    await _apiClient.post(ApiEndpoints.cashBankBankTransfer, data: payload);
  }

  Future<void> reverseTransaction(String id, String reason) async {
    await _apiClient.post(
      '${ApiEndpoints.cashBankTransactions}/$id/reverse',
      data: {'reversalReason': reason},
    );
  }
}
