import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';

class POSCheckoutService {
  final ApiClient _apiClient;

  POSCheckoutService(this._apiClient);

  Future<Map<String, dynamic>> submitCheckout(
    Map<String, dynamic> salePayload,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.sales,
      data: salePayload,
    );
    final body = response.data is Map<String, dynamic> ? response.data : {};
    return body['data'] ?? body;
  }
}
