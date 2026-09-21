import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/backup_info.dart';

class BackupService {
  final ApiClient _apiClient;

  BackupService(this._apiClient);

  Future<List<BackupInfo>> getBackups() async {
    final response = await _apiClient.get(ApiEndpoints.backup);
    dynamic responseData = response.data;
    List list = [];
    if (responseData is Map<String, dynamic>) {
      list = responseData['data'] ?? responseData['backups'] ?? [];
    } else if (responseData is List) {
      list = responseData;
    }

    final result = <BackupInfo>[];
    for (final item in list) {
      if (item is Map<String, dynamic>) {
        try {
          result.add(BackupInfo.fromJson(item));
        } catch (_) {}
      }
    }
    return result;
  }

  Future<BackupInfo> createBackup({String type = 'local'}) async {
    final response = await _apiClient.post(
      '${ApiEndpoints.backup}/export',
      data: {'type': type},
    );
    final Map<String, dynamic> body = response.data is Map<String, dynamic>
        ? response.data
        : {};
    final data = body['data'] ?? body;
    return BackupInfo.fromJson(data as Map<String, dynamic>);
  }

  Future<void> restoreBackup(String id) async {
    await _apiClient.post('${ApiEndpoints.backup}/restore/$id');
  }
}
