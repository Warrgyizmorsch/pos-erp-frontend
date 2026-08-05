import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../data/models/api_response.dart';
import '../../parties/customers/models/customer.dart';
import '../../products/models/product.dart';
import '../models/pos_sale_payload.dart';

class POSService {
  final ApiClient _apiClient;

  POSService(this._apiClient);

  Future<ApiResponse<List<Product>>> getProducts({String? search}) async {
    final response = await _apiClient.get(
      ApiEndpoints.products,
      queryParameters: {
        'limit': 100,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );

    return ApiResponse<List<Product>>.fromJson(
      response.data,
      (json) => (json as List)
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<ApiResponse<List<Customer>>> getCustomers() async {
    final response = await _apiClient.get(
      ApiEndpoints.customers,
      queryParameters: {'limit': 200},
    );

    return ApiResponse<List<Customer>>.fromJson(
      response.data,
      (json) => (json as List)
          .map((item) => Customer.fromJson(item as Map<String, dynamic>))
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

  Future<ApiResponse<Map<String, dynamic>>> createSale(
    POSSalePayload payload,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.sales,
      data: payload.toJson(),
    );

    return ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> updateSale(
    String id,
    POSSalePayload payload,
  ) async {
    final response = await _apiClient.put(
      '${ApiEndpoints.sales}/$id',
      data: payload.toJson(),
    );

    return ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );
  }
}
