import '../../../../core/api/api_exceptions.dart';
import '../models/backup_info.dart';
import '../services/backup_service.dart';

class BackupRepository {
  final BackupService _service;

  BackupRepository(this._service);

  Future<List<BackupInfo>> fetchBackups() async {
    try {
      return await _service.getBackups();
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fetch backup history.');
    }
  }

  Future<BackupInfo> generateBackup({String type = 'local'}) async {
    try {
      return await _service.createBackup(type: type);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to generate ERP data backup.');
    }
  }

  Future<void> restoreBackup(String id) async {
    try {
      await _service.restoreBackup(id);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to restore backup snapshot.');
    }
  }
}
