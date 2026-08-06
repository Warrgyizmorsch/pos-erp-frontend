import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_exceptions.dart';
import '../../../../data/models/api_response.dart';
import '../../../../data/models/pagination.dart';
import '../../../parties/suppliers/models/supplier.dart';
import '../../models/purchase.dart';
import '../models/payment_out.dart';
import '../models/payment_out_payload.dart';

class PaymentOutFetchResult {
  final List<PaymentOut> data;
  final Pagination? pagination;

  PaymentOutFetchResult({required this.data, this.pagination});
}

class PaymentOutService {
  final ApiClient _apiClient;

  PaymentOutService(this._apiClient);

  Future<PaymentOutFetchResult> getAll({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    final Map<String, dynamic> queryParams = {'page': page, 'limit': limit};
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }

    try {
      final response = await _apiClient.get(
        ApiEndpoints.paymentOut,
        queryParameters: queryParams,
      );

      List list = [];
      Pagination? pagination;

      if (response.data is Map<String, dynamic>) {
        final Map<String, dynamic> body = response.data as Map<String, dynamic>;
        if (body['data'] != null) {
          if (body['data'] is List) {
            list = body['data'] as List;
          } else if (body['data'] is Map<String, dynamic> &&
              body['data']['payments'] is List) {
            list = body['data']['payments'] as List;
          }
        } else if (body['payments'] is List) {
          list = body['payments'] as List;
        }
        if (body['pagination'] != null &&
            body['pagination'] is Map<String, dynamic>) {
          pagination = Pagination.fromJson(
            body['pagination'] as Map<String, dynamic>,
          );
        }
      } else if (response.data is List) {
        list = response.data as List;
      }

      final payments = <PaymentOut>[];
      for (final item in list) {
        if (item is Map<String, dynamic>) {
          try {
            payments.add(PaymentOut.fromJson(item));
          } catch (_) {}
        }
      }

      return PaymentOutFetchResult(data: payments, pagination: pagination);
    } catch (e) {
      if (e is AppException &&
          (e.statusCode == 404 ||
              e.message.toLowerCase().contains('not found'))) {
        return PaymentOutFetchResult(data: [], pagination: null);
      }
      rethrow;
    }
  }

  Future<PaymentOut> getById(String id) async {
    final response = await _apiClient.get('${ApiEndpoints.paymentOut}/$id');
    final body = response.data as Map<String, dynamic>;
    final data = body['data'] ?? body;
    return PaymentOut.fromJson(data as Map<String, dynamic>);
  }

  Future<PaymentOut> create(PaymentOutPayload payload) async {
    final response = await _apiClient.post(
      ApiEndpoints.paymentOut,
      data: payload.toJson(),
    );
    final body = response.data as Map<String, dynamic>;
    final data = body['data'] ?? body;
    return PaymentOut.fromJson(data as Map<String, dynamic>);
  }

  Future<PaymentOut> update(String id, PaymentOutPayload payload) async {
    final response = await _apiClient.put(
      '${ApiEndpoints.paymentOut}/$id',
      data: payload.toJson(),
    );
    final body = response.data as Map<String, dynamic>;
    final data = body['data'] ?? body;
    return PaymentOut.fromJson(data as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    await _apiClient.delete('${ApiEndpoints.paymentOut}/$id');
  }

  Future<List<Purchase>> getUnpaidPurchases(String supplierId) async {
    if (supplierId.trim().isEmpty) return [];

    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.unpaidPurchases}/$supplierId',
      );
      List list = [];
      if (response.data is Map<String, dynamic>) {
        final body = response.data as Map<String, dynamic>;
        if (body['data'] != null) {
          if (body['data'] is List) {
            list = body['data'] as List;
          } else if (body['data'] is Map<String, dynamic> &&
              body['data']['purchases'] is List) {
            list = body['data']['purchases'] as List;
          }
        } else if (body['purchases'] is List) {
          list = body['purchases'] as List;
        }
      } else if (response.data is List) {
        list = response.data as List;
      }

      final result = <Purchase>[];
      for (final i in list) {
        if (i is Map<String, dynamic>) {
          try {
            result.add(Purchase.fromJson(i));
          } catch (_) {}
        }
      }
      return result;
    } catch (_) {
      return [];
    }
  }

  Future<ApiResponse<List<Supplier>>> getSuppliers() async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.suppliers,
        queryParameters: {'limit': 200},
      );
      List list = [];
      if (response.data is Map<String, dynamic>) {
        final body = response.data as Map<String, dynamic>;
        list = body['data'] as List? ?? [];
      } else if (response.data is List) {
        list = response.data as List;
      }

      final supps = <Supplier>[];
      for (final item in list) {
        if (item is Map<String, dynamic>) {
          try {
            supps.add(Supplier.fromJson(item));
          } catch (_) {}
        }
      }
      return ApiResponse<List<Supplier>>(success: true, data: supps);
    } catch (_) {
      return ApiResponse<List<Supplier>>(success: true, data: []);
    }
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getBankAccounts() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.bank);
      List list = [];
      if (response.data is Map<String, dynamic>) {
        final body = response.data as Map<String, dynamic>;
        list = body['data'] as List? ?? [];
      } else if (response.data is List) {
        list = response.data as List;
      }
      return ApiResponse<List<Map<String, dynamic>>>(
        success: true,
        data: list.whereType<Map<String, dynamic>>().toList(),
      );
    } catch (_) {
      try {
        final response = await _apiClient.get(ApiEndpoints.cashBankAccounts);
        List list = [];
        if (response.data is Map<String, dynamic>) {
          final body = response.data as Map<String, dynamic>;
          list = body['data'] as List? ?? [];
        } else if (response.data is List) {
          list = response.data as List;
        }
        return ApiResponse<List<Map<String, dynamic>>>(
          success: true,
          data: list.whereType<Map<String, dynamic>>().toList(),
        );
      } catch (_) {
        return ApiResponse<List<Map<String, dynamic>>>(success: true, data: []);
      }
    }
  }
}
