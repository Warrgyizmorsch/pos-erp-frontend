import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../data/models/api_response.dart';
import '../../../../data/models/pagination.dart';
import '../../parties/suppliers/models/supplier.dart';
import '../../parties/transporters/models/transporter.dart';
import '../../products/models/product.dart';
import '../models/purchase.dart';
import '../models/purchase_payload.dart';

class PurchaseFetchResult {
  final List<Purchase> data;
  final Pagination? pagination;

  PurchaseFetchResult({required this.data, this.pagination});
}

class PurchaseService {
  final ApiClient _apiClient;

  PurchaseService(this._apiClient);

  Future<PurchaseFetchResult> getAll({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    String? paymentStatus,
    String? startDate,
    String? endDate,
  }) async {
    final Map<String, dynamic> queryParams = {'page': page, 'limit': limit};
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }
    if (status != null && status != 'all' && status.isNotEmpty) {
      queryParams['status'] = status;
    }
    if (paymentStatus != null &&
        paymentStatus != 'all' &&
        paymentStatus.isNotEmpty) {
      queryParams['paymentStatus'] = paymentStatus;
    }
    if (startDate != null && startDate.isNotEmpty) {
      queryParams['startDate'] = startDate;
    }
    if (endDate != null && endDate.isNotEmpty) {
      queryParams['endDate'] = endDate;
    }

    final response = await _apiClient.get(
      ApiEndpoints.purchases,
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
            body['data']['purchases'] is List) {
          list = body['data']['purchases'] as List;
        }
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

    final purchases = <Purchase>[];
    for (final item in list) {
      if (item is Map<String, dynamic>) {
        try {
          purchases.add(Purchase.fromJson(item));
        } catch (_) {}
      }
    }

    return PurchaseFetchResult(data: purchases, pagination: pagination);
  }

  Future<Purchase> getById(String id) async {
    final response = await _apiClient.get('${ApiEndpoints.purchases}/$id');
    final body = response.data as Map<String, dynamic>;
    final data = body['data'] ?? body;
    return Purchase.fromJson(data as Map<String, dynamic>);
  }

  Future<Purchase> create(PurchasePayload payload) async {
    final response = await _apiClient.post(
      ApiEndpoints.purchases,
      data: payload.toJson(),
    );
    final body = response.data as Map<String, dynamic>;
    final data = body['data'] ?? body;
    return Purchase.fromJson(data as Map<String, dynamic>);
  }

  Future<Purchase> update(String id, PurchasePayload payload) async {
    final response = await _apiClient.put(
      '${ApiEndpoints.purchases}/$id',
      data: payload.toJson(),
    );
    final body = response.data as Map<String, dynamic>;
    final data = body['data'] ?? body;
    return Purchase.fromJson(data as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    await _apiClient.delete('${ApiEndpoints.purchases}/$id');
  }

  Future<void> repostAccounting(String id) async {
    await _apiClient.post('/accounting/repost/purchase/$id');
  }

  Future<ApiResponse<List<Supplier>>> getSuppliers() async {
    final response = await _apiClient.get(
      ApiEndpoints.suppliers,
      queryParameters: {'limit': 200},
    );
    return ApiResponse<List<Supplier>>.fromJson(
      response.data,
      (json) => (json as List)
          .map((item) => Supplier.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<ApiResponse<List<Transporter>>> getTransporters() async {
    final response = await _apiClient.get(
      ApiEndpoints.transporters,
      queryParameters: {'limit': 200},
    );
    return ApiResponse<List<Transporter>>.fromJson(
      response.data,
      (json) => (json as List)
          .map((item) => Transporter.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<ApiResponse<List<Product>>> getProducts() async {
    final response = await _apiClient.get(
      ApiEndpoints.products,
      queryParameters: {'limit': 500},
    );
    return ApiResponse<List<Product>>.fromJson(
      response.data,
      (json) => (json as List)
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getBankAccounts() async {
    final response = await _apiClient.get(ApiEndpoints.cashBankAccounts);
    return ApiResponse<List<Map<String, dynamic>>>.fromJson(
      response.data,
      (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }
}
