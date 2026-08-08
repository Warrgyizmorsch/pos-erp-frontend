import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withAlpha(40),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> triggerBackup({String type = 'local'}) async {
    try {
      isExporting.value = true;
      final newBackup = await _repository.generateBackup(type: type);
      backups.insert(0, newBackup);
      Get.snackbar(
        'Backup Created',
        'Data backup snapshot created successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withAlpha(40),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withAlpha(40),
      );
    } finally {
      isExporting.value = false;
    }
  }

  Future<void> restore(String id) async {
    try {
      isRestoring.value = true;
      await _repository.restoreBackup(id);
      Get.snackbar(
        'System Restored',
        'System state restored successfully from backup.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withAlpha(40),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withAlpha(40),
      );
    } finally {
      isRestoring.value = false;
    }
  }
}
