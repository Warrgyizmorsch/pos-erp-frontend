import 'package:get/get.dart';
import '../../../../core/api/api_client.dart';
import '../controllers/backup_controller.dart';
import '../repositories/backup_repository.dart';
import '../services/backup_service.dart';

class BackupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BackupService>(() => BackupService(Get.find<ApiClient>()));
    Get.lazyPut<BackupRepository>(
      () => BackupRepository(Get.find<BackupService>()),
    );
    Get.lazyPut<BackupController>(
      () => BackupController(Get.find<BackupRepository>()),
    );
  }
}
