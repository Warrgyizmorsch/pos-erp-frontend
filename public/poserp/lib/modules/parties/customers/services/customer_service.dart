import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../data/models/api_response.dart';
import '../models/customer.dart';
import '../models/customer_payload.dart';

class CustomerService {
  final ApiClient _apiClient;

  CustomerService(this._apiClient);

  Future<ApiResponse<List<Customer>>> getAll({
    String? search,
    int page = 1,
    int limit = 15,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.customers,
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        'page': page,
        'limit': limit,
      },
    );

    return ApiResponse<List<Customer>>.fromJson(
      response.data,
      (json) => (json as List).map((item) => Customer.fromJson(item)).toList(),
    );
  }

  Future<ApiResponse<Customer>> getById(String id) async {
    final response = await _apiClient.get('${ApiEndpoints.customers}/$id');
    return ApiResponse<Customer>.fromJson(
      response.data,
      (json) => Customer.fromJson(json),
    );
  }

  Future<ApiResponse<Customer>> create(CustomerPayload payload) async {
    final response = await _apiClient.post(
      ApiEndpoints.customers,
      data: payload.toJson(),
    );

    return ApiResponse<Customer>.fromJson(
      response.data,
      (json) => Customer.fromJson(json),
    );
  }

  Future<ApiResponse<Customer>> update(
    String id,
    CustomerPayload payload,
  ) async {
    final response = await _apiClient.put(
      '${ApiEndpoints.customers}/$id',
      data: payload.toJson(),
    );

    return ApiResponse<Customer>.fromJson(
      response.data,
      (json) => Customer.fromJson(json),
    );
  }

  Future<void> delete(String id) async {
    await _apiClient.delete('${ApiEndpoints.customers}/$id');
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getLedger(
    String partyId,
  ) async {
    final response = await _apiClient.get(ApiEndpoints.partyLedger(partyId));
    return ApiResponse<List<Map<String, dynamic>>>.fromJson(
      response.data,
      (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }
}
