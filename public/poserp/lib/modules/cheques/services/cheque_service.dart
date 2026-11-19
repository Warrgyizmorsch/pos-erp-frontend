import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/cheque.dart';

class ChequeService {
  final ApiClient _apiClient;

  ChequeService(this._apiClient);

  Future<List<Cheque>> getCheques() async {
    final response = await _apiClient.get(ApiEndpoints.cheques);
    dynamic body = response.data;
    List list = [];
    if (body is Map<String, dynamic>) {
      list = body['data'] ?? body['cheques'] ?? [];
    } else if (body is List) {
      list = body;
    }

    final result = <Cheque>[];
    for (final item in list) {
      if (item is Map<String, dynamic>) {
        try {
          result.add(Cheque.fromJson(item));
        } catch (_) {}
      }
    }
    return result;
  }

  Future<Cheque> createCheque(Map<String, dynamic> payload) async {
    final response = await _apiClient.post(ApiEndpoints.cheques, data: payload);
    final body = response.data is Map<String, dynamic> ? response.data : {};
    final data = body['data'] ?? body;
    return Cheque.fromJson(data as Map<String, dynamic>);
  }

  Future<Cheque> updateCheque(String id, Map<String, dynamic> payload) async {
    final response = await _apiClient.put(
      '${ApiEndpoints.cheques}/$id',
      data: payload,
    );
    final body = response.data is Map<String, dynamic> ? response.data : {};
    final data = body['data'] ?? body;
    return Cheque.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteCheque(String id) async {
    await _apiClient.delete('${ApiEndpoints.cheques}/$id');
  }
}
