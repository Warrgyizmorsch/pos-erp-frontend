import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_exceptions.dart';
import '../../../../data/models/pagination.dart';
import '../../models/product.dart';
import '../models/stock_adjustment.dart';
import '../models/stock_movement.dart';

class StockFetchResult<T> {
  final List<T> data;
  final Pagination? pagination;

  StockFetchResult({required this.data, this.pagination});
}

class StockService {
  final ApiClient _apiClient;

  StockService(this._apiClient);

  Future<StockFetchResult<Product>> getCurrentStock({
    int page = 1,
    int limit = 100,
    String? search,
    String? category,
    String? status,
  }) async {
    final Map<String, dynamic> queryParams = {'page': page, 'limit': limit};
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }
    if (category != null && category.trim().isNotEmpty) {
      queryParams['category'] = category;
    }
    if (status != null && status.trim().isNotEmpty && status != 'all') {
      queryParams['status'] = status;
    }

    try {
      final response = await _apiClient.get(
        ApiEndpoints.products,
        queryParameters: queryParams,
      );

      List list = [];
      Pagination? pagination;

      if (response.data is Map<String, dynamic>) {
        final body = response.data as Map<String, dynamic>;
        if (body['data'] != null) {
          if (body['data'] is List) {
            list = body['data'] as List;
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

      final products = <Product>[];
      for (final item in list) {
        if (item is Map<String, dynamic>) {
          try {
            products.add(Product.fromJson(item));
          } catch (_) {}
        }
      }

      return StockFetchResult(data: products, pagination: pagination);
    } catch (e) {
      if (e is AppException &&
          (e.statusCode == 404 ||
              e.message.toLowerCase().contains('not found'))) {
        return StockFetchResult(data: [], pagination: null);
      }
      rethrow;
    }
  }

  Future<StockFetchResult<StockMovement>> getMovements({
    int page = 1,
    int limit = 100,
    String? search,
    String? type,
    String? productId,
  }) async {
    final Map<String, dynamic> queryParams = {'page': page, 'limit': limit};
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }
    if (type != null && type.trim().isNotEmpty && type != 'all') {
      queryParams['type'] = type;
    }
    if (productId != null && productId.trim().isNotEmpty) {
      queryParams['productId'] = productId;
    }

    try {
      final response = await _apiClient.get(
        ApiEndpoints.inventoryHistory,
        queryParameters: queryParams,
      );

      List list = [];
      Pagination? pagination;

      if (response.data is Map<String, dynamic>) {
        final body = response.data as Map<String, dynamic>;
        if (body['data'] != null) {
          if (body['data'] is List) {
            list = body['data'] as List;
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

      final movements = <StockMovement>[];
      for (final item in list) {
        if (item is Map<String, dynamic>) {
          try {
            movements.add(StockMovement.fromJson(item));
          } catch (_) {}
        }
      }

      return StockFetchResult(data: movements, pagination: pagination);
    } catch (e) {
      if (e is AppException &&
          (e.statusCode == 404 ||
              e.message.toLowerCase().contains('not found'))) {
        return StockFetchResult(data: [], pagination: null);
      }
      rethrow;
    }
  }

  Future<StockFetchResult<StockAdjustment>> getAdjustments({
    int page = 1,
    int limit = 100,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.stockAdjustments,
        queryParameters: {'page': page, 'limit': limit},
      );

      List list = [];
      Pagination? pagination;

      if (response.data is Map<String, dynamic>) {
        final body = response.data as Map<String, dynamic>;
        if (body['data'] != null && body['data'] is List) {
          list = body['data'] as List;
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

      final adjustments = <StockAdjustment>[];
      for (final item in list) {
        if (item is Map<String, dynamic>) {
          try {
            adjustments.add(StockAdjustment.fromJson(item));
          } catch (_) {}
        }
      }

      return StockFetchResult(data: adjustments, pagination: pagination);
    } catch (e) {
      if (e is AppException &&
          (e.statusCode == 404 ||
              e.message.toLowerCase().contains('not found'))) {
        return StockFetchResult(data: [], pagination: null);
      }
      rethrow;
    }
  }

  Future<StockAdjustment> createAdjustment({
    required String productId,
    required double adjustedStock,
    required String reason,
    String? notes,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.stockAdjustments,
      data: {
        'product': productId,
        'productId': productId,
        'adjustedStock': adjustedStock,
        'reason': reason,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    );

    final body = response.data as Map<String, dynamic>;
    final data = body['data'] ?? body;
    return StockAdjustment.fromJson(data as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> createOpeningStock(
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.inventoryOpeningStock,
      data: payload,
    );
    final body = response.data as Map<String, dynamic>;
    return body;
  }
}
