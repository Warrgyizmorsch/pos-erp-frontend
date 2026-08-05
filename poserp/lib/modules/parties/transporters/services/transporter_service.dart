import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../data/models/api_response.dart';
import '../models/transporter.dart';
import '../models/transporter_payload.dart';

class TransporterService {
  final ApiClient _apiClient;

  TransporterService(this._apiClient);

  Future<ApiResponse<List<Transporter>>> getAll({
    String? search,
    int page = 1,
    int limit = 15,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.transporters,
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        'page': page,
        'limit': limit,
      },
    );

    return ApiResponse<List<Transporter>>.fromJson(
      response.data,
      (json) => (json as List)
          .map((item) => Transporter.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<ApiResponse<Transporter>> getById(String id) async {
    final response = await _apiClient.get('${ApiEndpoints.transporters}/$id');
    return ApiResponse<Transporter>.fromJson(
      response.data,
      (json) => Transporter.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<Transporter>> create(TransporterPayload payload) async {
    final response = await _apiClient.post(
      ApiEndpoints.transporters,
      data: payload.toJson(),
    );

    return ApiResponse<Transporter>.fromJson(
      response.data,
      (json) => Transporter.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<Transporter>> update(
    String id,
    TransporterPayload payload,
  ) async {
    final response = await _apiClient.put(
      '${ApiEndpoints.transporters}/$id',
      data: payload.toJson(),
    );

    return ApiResponse<Transporter>.fromJson(
      response.data,
      (json) => Transporter.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<void> delete(String id) async {
    await _apiClient.delete('${ApiEndpoints.transporters}/$id');
  }
}
