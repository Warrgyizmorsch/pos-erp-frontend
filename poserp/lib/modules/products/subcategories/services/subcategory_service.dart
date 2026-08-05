import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../data/models/api_response.dart';
import '../models/subcategory.dart';
import '../models/subcategory_payload.dart';

class SubcategoryService {
  final ApiClient _apiClient;

  SubcategoryService(this._apiClient);

  Future<ApiResponse<List<Subcategory>>> getAll({
    String? search,
    String? parentCategoryId,
    int page = 1,
    int limit = 15,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.subcategories,
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (parentCategoryId != null &&
            parentCategoryId.isNotEmpty &&
            parentCategoryId != 'all')
          'parentCategoryId': parentCategoryId,
        'all': 'true',
        'page': page,
        'limit': limit,
      },
    );

    return ApiResponse<List<Subcategory>>.fromJson(
      response.data,
      (json) =>
          (json as List).map((item) => Subcategory.fromJson(item)).toList(),
    );
  }

  Future<ApiResponse<Subcategory>> create(SubcategoryPayload payload) async {
    final response = await _apiClient.post(
      ApiEndpoints.subcategories,
      data: payload.toJson(),
    );

    return ApiResponse<Subcategory>.fromJson(
      response.data,
      (json) => Subcategory.fromJson(json),
    );
  }

  Future<ApiResponse<Subcategory>> update(
    String id,
    SubcategoryPayload payload,
  ) async {
    final response = await _apiClient.put(
      '${ApiEndpoints.subcategories}/$id',
      data: payload.toJson(),
    );

    return ApiResponse<Subcategory>.fromJson(
      response.data,
      (json) => Subcategory.fromJson(json),
    );
  }

  Future<void> delete(String id) async {
    await _apiClient.delete('${ApiEndpoints.subcategories}/$id');
  }
}
