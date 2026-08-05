import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../data/models/api_response.dart';
import '../models/opening_stock_payload.dart';

class OpeningStockService {
  final ApiClient _apiClient;

  OpeningStockService(this._apiClient);

  Future<ApiResponse<dynamic>> submitOpeningStock(
    OpeningStockPayload payload,
  ) async {
    final response = await _apiClient.post(
      '${ApiEndpoints.inventory}/opening-stock',
      data: payload.toJson(),
    );

    return ApiResponse<dynamic>.fromJson(response.data, (json) => json);
  }
}
