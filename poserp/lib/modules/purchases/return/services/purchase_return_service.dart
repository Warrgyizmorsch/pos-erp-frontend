import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_exceptions.dart';
import '../../../../data/models/api_response.dart';
import '../../../../data/models/pagination.dart';
import '../../../parties/suppliers/models/supplier.dart';
import '../../models/purchase.dart';
import '../models/purchase_return.dart';
import '../models/purchase_return_payload.dart';

class PurchaseReturnFetchResult {
  final List<PurchaseReturn> data;
  final Pagination? pagination;

  PurchaseReturnFetchResult({required this.data, this.pagination});
}

class PurchaseReturnService {
  final ApiClient _apiClient;

  PurchaseReturnService(this._apiClient);

  Future<PurchaseReturnFetchResult> getAll({
    int page = 1,
    int limit = 15,
    String? search,
    String? status,
    String? refundType,
    String? startDate,
    String? endDate,
  }) async {
    final Map<String, dynamic> queryParams = {'page': page, 'limit': limit};
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }
    if (status != null && status.trim().isNotEmpty && status != 'all') {
      queryParams['status'] = status;
    }
    if (refundType != null &&
        refundType.trim().isNotEmpty &&
        refundType != 'all') {
      queryParams['refundType'] = refundType;
    }
    if (startDate != null && startDate.trim().isNotEmpty) {
      queryParams['startDate'] = startDate;
    }
    if (endDate != null && endDate.trim().isNotEmpty) {
      queryParams['endDate'] = endDate;
    }

    dynamic responseData;
    try {
      final response = await _apiClient.get(
        ApiEndpoints.purchaseReturns, // /purchase-returns
        queryParameters: queryParams,
      );
      responseData = response.data;
    } catch (e) {
      if (e is AppException && e.statusCode == 404) {
        final response = await _apiClient.get(
          '/purchases-returns',
          queryParameters: queryParams,
        );
        responseData = response.data;
      } else {
        rethrow;
      }
    }

    List list = [];
    Pagination? pagination;

    if (responseData is Map<String, dynamic>) {
      final Map<String, dynamic> body = responseData;

      if (body['data'] != null) {
        if (body['data'] is List) {
          list = body['data'] as List;
        } else if (body['data'] is Map<String, dynamic>) {
          final mapData = body['data'] as Map<String, dynamic>;
          if (mapData['returns'] is List) {
            list = mapData['returns'] as List;
          } else if (mapData['data'] is List) {
            list = mapData['data'] as List;
          }
        }
      } else if (body['returns'] is List) {
        list = body['returns'] as List;
      }

      if (body['pagination'] != null &&
          body['pagination'] is Map<String, dynamic>) {
        pagination = Pagination.fromJson(
          body['pagination'] as Map<String, dynamic>,
        );
      } else if (body['data'] is Map<String, dynamic> &&
          body['data']['pagination'] is Map<String, dynamic>) {
        pagination = Pagination.fromJson(
          body['data']['pagination'] as Map<String, dynamic>,
        );
      }
    } else if (responseData is List) {
      list = responseData;
    }

    final returns = <PurchaseReturn>[];
    for (final item in list) {
      if (item is Map<String, dynamic>) {
        try {
          returns.add(PurchaseReturn.fromJson(item));
        } catch (_) {}
      }
    }

    return PurchaseReturnFetchResult(data: returns, pagination: pagination);
  }

  Future<PurchaseReturn> getById(String id) async {
    dynamic responseData;
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.purchaseReturns}/$id',
      );
      responseData = response.data;
    } catch (e) {
      if (e is AppException && e.statusCode == 404) {
        final response = await _apiClient.get('/purchases-returns/$id');
        responseData = response.data;
      } else {
        rethrow;
      }
    }
    final Map<String, dynamic> body = responseData is Map<String, dynamic>
        ? responseData
        : {};
    final data = body['data'] ?? body;
    return PurchaseReturn.fromJson(data as Map<String, dynamic>);
  }

  Future<PurchaseReturn> create(PurchaseReturnPayload payload) async {
    dynamic responseData;
    try {
      final response = await _apiClient.post(
        ApiEndpoints.purchaseReturns,
        data: payload.toJson(),
      );
      responseData = response.data;
    } catch (e) {
      if (e is AppException && e.statusCode == 404) {
        final response = await _apiClient.post(
          '/purchases-returns',
          data: payload.toJson(),
        );
        responseData = response.data;
      } else {
        rethrow;
      }
    }
    final Map<String, dynamic> body = responseData is Map<String, dynamic>
        ? responseData
        : {};
    final data = body['data'] ?? body;
    return PurchaseReturn.fromJson(data as Map<String, dynamic>);
  }

  Future<PurchaseReturn> update(
    String id,
    PurchaseReturnPayload payload,
  ) async {
    dynamic responseData;
    try {
      final response = await _apiClient.put(
        '${ApiEndpoints.purchaseReturns}/$id',
        data: payload.toJson(),
      );
      responseData = response.data;
    } catch (e) {
      if (e is AppException && e.statusCode == 404) {
        final response = await _apiClient.put(
          '/purchases-returns/$id',
          data: payload.toJson(),
        );
        responseData = response.data;
      } else {
        rethrow;
      }
    }
    final Map<String, dynamic> body = responseData is Map<String, dynamic>
        ? responseData
        : {};
    final data = body['data'] ?? body;
    return PurchaseReturn.fromJson(data as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    try {
      await _apiClient.delete('${ApiEndpoints.purchaseReturns}/$id');
    } catch (e) {
      if (e is AppException && e.statusCode == 404) {
        await _apiClient.delete('/purchases-returns/$id');
      } else {
        rethrow;
      }
    }
  }

  Future<PurchaseReturn> cancel(String id) async {
    dynamic responseData;
    try {
      final response = await _apiClient.post(
        '${ApiEndpoints.purchaseReturns}/$id/cancel',
      );
      responseData = response.data;
    } catch (e) {
      if (e is AppException && e.statusCode == 404) {
        final response = await _apiClient.post('/purchases-returns/$id/cancel');
        responseData = response.data;
      } else {
        rethrow;
      }
    }
    final Map<String, dynamic> body = responseData is Map<String, dynamic>
        ? responseData
        : {};
    final data = body['data'] ?? body;
    return PurchaseReturn.fromJson(data as Map<String, dynamic>);
  }

  Future<List<Purchase>> getUnreturnedPurchasesForSupplier(
    String supplierId,
  ) async {
    if (supplierId.trim().isEmpty) return [];

    dynamic responseData;
    try {
      // Documented in cURL guide line 1027: /api/purchases/supplier/:supplierId/unreturned
      final response = await _apiClient.get(
        '${ApiEndpoints.purchases}/supplier/$supplierId/unreturned',
      );
      responseData = response.data;
    } catch (_) {
      try {
        // Documented in cURL guide line 1274: /api/purchase-returns/supplier/:supplierId/unreturned
        final response = await _apiClient.get(
          '${ApiEndpoints.purchaseReturns}/supplier/$supplierId/unreturned',
        );
        responseData = response.data;
      } catch (_) {
        try {
          final response = await _apiClient.get(
            '/purchases-returns/supplier/$supplierId/unreturned',
          );
          responseData = response.data;
        } catch (_) {
          return [];
        }
      }
    }

    List list = [];
    if (responseData is Map<String, dynamic>) {
      final Map<String, dynamic> body = responseData;
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
    } else if (responseData is List) {
      list = responseData;
    }

    final bills = <Purchase>[];
    for (final item in list) {
      if (item is Map<String, dynamic>) {
        try {
          bills.add(Purchase.fromJson(item));
        } catch (_) {}
      }
    }
    return bills;
  }

  Future<Map<String, dynamic>> getReturnableItemsFromBill(String billId) async {
    dynamic responseData;
    try {
      // Documented in cURL guide line 1041: /api/purchases/:id/returnable-items
      final response = await _apiClient.get(
        '${ApiEndpoints.purchases}/$billId/returnable-items',
      );
      responseData = response.data;
    } catch (_) {
      try {
        // Documented in cURL guide line 1288: /api/purchase-returns/bill/:id/returnable-items
        final response = await _apiClient.get(
          '${ApiEndpoints.purchaseReturns}/bill/$billId/returnable-items',
        );
        responseData = response.data;
      } catch (_) {
        try {
          final response = await _apiClient.get(
            '/purchases-returns/bill/$billId/returnable-items',
          );
          responseData = response.data;
        } catch (_) {
          return {};
        }
      }
    }

    if (responseData is Map<String, dynamic>) {
      final Map<String, dynamic> body = responseData;
      if (body['data'] != null && body['data'] is Map<String, dynamic>) {
        return body['data'] as Map<String, dynamic>;
      }
      return body;
    }
    return {};
  }

  Future<ApiResponse<List<Supplier>>> getSuppliers() async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.suppliers,
        queryParameters: {'limit': 500},
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
