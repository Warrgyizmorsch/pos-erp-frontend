import 'package:get/get.dart';
import '../../../../core/api/api_client.dart';
import '../controllers/activity_log_controller.dart';
import '../repositories/activity_log_repository.dart';
import '../services/activity_log_service.dart';

class ActivityLogBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ActivityLogService>(
      () => ActivityLogService(Get.find<ApiClient>()),
    );
    Get.lazyPut<ActivityLogRepository>(
      () => ActivityLogRepository(Get.find<ActivityLogService>()),
    );
    Get.lazyPut<ActivityLogController>(
      () => ActivityLogController(Get.find<ActivityLogRepository>()),
    );
  }
}
