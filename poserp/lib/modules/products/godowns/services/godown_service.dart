import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/godown.dart';

class GodownService {
  final ApiClient _apiClient;

  GodownService(this._apiClient);

  Future<List<Godown>> getAll() async {
    final response = await _apiClient.get(ApiEndpoints.godowns);
    final body = response.data as Map<String, dynamic>;
    final list = body['data'] as List? ?? [];
    return list.map((e) => Godown.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Godown> getById(String id) async {
    final response = await _apiClient.get('/godowns/$id');
    final body = response.data as Map<String, dynamic>;
    final data = body['data'] ?? body;
    return Godown.fromJson(data as Map<String, dynamic>);
  }

  Future<Godown> create(Map<String, dynamic> data) async {
    final response = await _apiClient.post('/godowns', data: data);
    final body = response.data as Map<String, dynamic>;
    final resData = body['data'] ?? body;
    return Godown.fromJson(resData as Map<String, dynamic>);
  }

  Future<Godown> update(String id, Map<String, dynamic> data) async {
    final response = await _apiClient.put('/godowns/$id', data: data);
    final body = response.data as Map<String, dynamic>;
    final resData = body['data'] ?? body;
    return Godown.fromJson(resData as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    await _apiClient.delete('/godowns/$id');
  }

  Future<void> transferStock({
    required String sourceGodownId,
    required String destinationGodownId,
    required List<Map<String, dynamic>> items,
    String? notes,
  }) async {
    await _apiClient.post(
      '/inventory/transfer',
      data: {
        'sourceGodownId': sourceGodownId,
        'destinationGodownId': destinationGodownId,
        'items': items,
        'notes': notes ?? '',
      },
    );
  }
}
