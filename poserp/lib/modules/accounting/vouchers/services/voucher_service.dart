import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/accounting_voucher.dart';
import '../models/voucher_type.dart';

class VoucherService {
  final ApiClient _apiClient;

  VoucherService(this._apiClient);

  Future<List<VoucherType>> getVoucherTypes() async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.accountingVoucherTypes,
      );
      dynamic responseData = response.data;
      List list = [];
      if (responseData is Map<String, dynamic>) {
        list = responseData['data'] ?? responseData['types'] ?? [];
      } else if (responseData is List) {
        list = responseData;
      }
      final result = <VoucherType>[];
      for (final item in list) {
        if (item is Map<String, dynamic>) {
          try {
            result.add(VoucherType.fromJson(item));
          } catch (_) {}
        }
      }
      return result;
    } catch (_) {
      return [
        VoucherType(
          id: '1',
          code: 'JV',
          name: 'Journal Voucher',
          nature: 'General',
          description: 'Double entry journal posting',
        ),
        VoucherType(
          id: '2',
          code: 'PV',
          name: 'Payment Voucher',
          nature: 'Payment',
          description: 'Outflow transaction',
        ),
        VoucherType(
          id: '3',
          code: 'RV',
          name: 'Receipt Voucher',
          nature: 'Receipt',
          description: 'Inflow transaction',
        ),
      ];
    }
  }

  Future<List<AccountingVoucher>> getVouchers({
    String? search,
    String? typeCode,
    String? status,
    String? startDate,
    String? endDate,
  }) async {
    final Map<String, dynamic> queryParams = {};
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }
    if (typeCode != null && typeCode != 'ALL') {
      queryParams['typeCode'] = typeCode;
    }
    if (status != null && status != 'ALL') {
      queryParams['status'] = status;
    }
    if (startDate != null && startDate.isNotEmpty) {
      queryParams['startDate'] = startDate;
    }
    if (endDate != null && endDate.isNotEmpty) {
      queryParams['endDate'] = endDate;
    }

    final response = await _apiClient.get(
      ApiEndpoints.accountingVouchers,
      queryParameters: queryParams,
    );

    dynamic responseData = response.data;
    List list = [];
    if (responseData is Map<String, dynamic>) {
      final Map<String, dynamic> body = responseData;
      if (body['data'] != null && body['data'] is List) {
        list = body['data'] as List;
      } else if (body['vouchers'] != null && body['vouchers'] is List) {
        list = body['vouchers'] as List;
      }
    } else if (responseData is List) {
      list = responseData;
    }

    final vouchers = <AccountingVoucher>[];
    for (final item in list) {
      if (item is Map<String, dynamic>) {
        try {
          vouchers.add(AccountingVoucher.fromJson(item));
        } catch (_) {}
      }
    }
    return vouchers;
  }

  Future<AccountingVoucher> getVoucherById(String id) async {
    final response = await _apiClient.get(
      '${ApiEndpoints.accountingVouchers}/$id',
    );
    final Map<String, dynamic> body = response.data is Map<String, dynamic>
        ? response.data
        : {};
    final data = body['data'] ?? body;
    return AccountingVoucher.fromJson(data as Map<String, dynamic>);
  }

  Future<AccountingVoucher> createJournalDraft(
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.accountingJournalDraft,
      data: payload,
    );
    final Map<String, dynamic> body = response.data is Map<String, dynamic>
        ? response.data
        : {};
    final data = body['data'] ?? body;
    return AccountingVoucher.fromJson(data as Map<String, dynamic>);
  }

  Future<AccountingVoucher> postJournal(Map<String, dynamic> payload) async {
    final response = await _apiClient.post(
      ApiEndpoints.accountingJournalPost,
      data: payload,
    );
    final Map<String, dynamic> body = response.data is Map<String, dynamic>
        ? response.data
        : {};
    final data = body['data'] ?? body;
    return AccountingVoucher.fromJson(data as Map<String, dynamic>);
  }

  Future<void> postVoucher(String id) async {
    await _apiClient.post('${ApiEndpoints.accountingVouchers}/$id/post');
  }

  Future<void> cancelVoucher(String id, String reason) async {
    await _apiClient.post(
      '${ApiEndpoints.accountingVouchers}/$id/cancel',
      data: {'reason': reason},
    );
  }
}
