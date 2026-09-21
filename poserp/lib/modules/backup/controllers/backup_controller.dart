import 'package:get/get.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../models/backup_info.dart';
import '../repositories/backup_repository.dart';

class BackupController extends GetxController {
  final BackupRepository _repository;

  BackupController(this._repository);

  final RxList<BackupInfo> backups = <BackupInfo>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isExporting = false.obs;
  final RxBool isRestoring = false.obs;

  final RxBool autoSyncEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadBackups();
  }

  Future<void> loadBackups() async {
    try {
      isLoading.value = true;
      final res = await _repository.fetchBackups();
      backups.assignAll(res);
    } catch (e) {
      AppSnackbar.error(e.toString(), title: 'Error');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> triggerBackup({String type = 'local'}) async {
    try {
      isExporting.value = true;
      final newBackup = await _repository.generateBackup(type: type);
      backups.insert(0, newBackup);
      AppSnackbar.success(
        'Data backup snapshot created successfully.',
        title: 'Backup Created',
      );
    } catch (e) {
      AppSnackbar.error(e.toString(), title: 'Error');
    } finally {
      isExporting.value = false;
    }
  }

  Future<void> restore(String id) async {
    try {
      isRestoring.value = true;
      await _repository.restoreBackup(id);
      AppSnackbar.success(
        'System state restored successfully from backup.',
        title: 'System Restored',
      );
    } catch (e) {
      AppSnackbar.error(e.toString(), title: 'Error');
    } finally {
      isRestoring.value = false;
    }
  }
}
