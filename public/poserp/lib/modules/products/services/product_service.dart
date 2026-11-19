import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../data/models/api_response.dart';
import '../models/product.dart';
import '../models/product_payload.dart';

class ProductService {
  final ApiClient _apiClient;

  ProductService(this._apiClient);

  Future<ApiResponse<List<Product>>> getAll({
    String? search,
    String? category,
    int page = 1,
    int limit = 15,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.products,
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (category != null && category.isNotEmpty && category != 'all')
          'category': category,
        'page': page,
        'limit': limit,
      },
    );

    return ApiResponse<List<Product>>.fromJson(
      response.data,
      (json) => (json as List).map((item) => Product.fromJson(item)).toList(),
    );
  }

  Future<ApiResponse<Product>> getById(String id) async {
    final response = await _apiClient.get('${ApiEndpoints.products}/$id');
    return ApiResponse<Product>.fromJson(
      response.data,
      (json) => Product.fromJson(json),
    );
  }

  Future<ApiResponse<Product>> create(ProductPayload payload) async {
    final response = await _apiClient.post(
      ApiEndpoints.products,
      data: payload.toJson(),
    );

    return ApiResponse<Product>.fromJson(
      response.data,
      (json) => Product.fromJson(json),
    );
  }

  Future<ApiResponse<Product>> update(String id, ProductPayload payload) async {
    final response = await _apiClient.put(
      '${ApiEndpoints.products}/$id',
      data: payload.toJson(),
    );

    return ApiResponse<Product>.fromJson(
      response.data,
      (json) => Product.fromJson(json),
    );
  }

  Future<void> delete(String id) async {
    await _apiClient.delete('${ApiEndpoints.products}/$id');
  }
}
