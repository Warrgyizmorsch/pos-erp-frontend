import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../data/models/api_response.dart';
import '../models/supplier.dart';
import '../models/supplier_payload.dart';

class SupplierService {
  final ApiClient _apiClient;

  SupplierService(this._apiClient);

  Future<ApiResponse<List<Supplier>>> getAll({
    String? search,
    int page = 1,
    int limit = 15,
    bool? hasBalance,
  }) async {
    final Map<String, dynamic> queryParams = {'page': page, 'limit': limit};
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }
    if (hasBalance == true) {
      queryParams['hasBalance'] = 'true';
    }

    final response = await _apiClient.get(
      ApiEndpoints.suppliers,
      queryParameters: queryParams,
    );

    return ApiResponse<List<Supplier>>.fromJson(
      response.data,
      (json) => (json as List)
          .map((item) => Supplier.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<ApiResponse<Supplier>> getById(String id) async {
    final response = await _apiClient.get('${ApiEndpoints.suppliers}/$id');
    return ApiResponse<Supplier>.fromJson(
      response.data,
      (json) => Supplier.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<Supplier>> create(SupplierPayload payload) async {
    final response = await _apiClient.post(
      ApiEndpoints.suppliers,
      data: payload.toJson(),
    );

    return ApiResponse<Supplier>.fromJson(
      response.data,
      (json) => Supplier.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<Supplier>> update(
    String id,
    SupplierPayload payload,
  ) async {
    final response = await _apiClient.put(
      '${ApiEndpoints.suppliers}/$id',
      data: payload.toJson(),
    );

    return ApiResponse<Supplier>.fromJson(
      response.data,
      (json) => Supplier.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<void> delete(String id) async {
    await _apiClient.delete('${ApiEndpoints.suppliers}/$id');
  }
}
