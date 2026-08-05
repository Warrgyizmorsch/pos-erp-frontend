import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../data/models/api_response.dart';
import '../models/category.dart';
import '../models/category_payload.dart';

class CategoryService {
  final ApiClient _apiClient;

  CategoryService(this._apiClient);

  Future<ApiResponse<List<Category>>> getAll({
    String? search,
    int page = 1,
    int limit = 15,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.categories,
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        'all': 'true',
        'page': page,
        'limit': limit,
      },
    );

    return ApiResponse<List<Category>>.fromJson(
      response.data,
      (json) => (json as List).map((item) => Category.fromJson(item)).toList(),
    );
  }

  Future<ApiResponse<Category>> create(CategoryPayload payload) async {
    final response = await _apiClient.post(
      ApiEndpoints.categories,
      data: payload.toJson(),
    );

    return ApiResponse<Category>.fromJson(
      response.data,
      (json) => Category.fromJson(json),
    );
  }

  Future<ApiResponse<Category>> update(
    String id,
    CategoryPayload payload,
  ) async {
    final response = await _apiClient.put(
      '${ApiEndpoints.categories}/$id',
      data: payload.toJson(),
    );

    return ApiResponse<Category>.fromJson(
      response.data,
      (json) => Category.fromJson(json),
    );
  }

  Future<void> delete(String id) async {
    await _apiClient.delete('${ApiEndpoints.categories}/$id');
  }
}
