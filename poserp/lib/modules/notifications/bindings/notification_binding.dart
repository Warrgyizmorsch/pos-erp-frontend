import 'package:get/get.dart';
import '../../../../core/api/api_client.dart';
import '../controllers/notification_controller.dart';
import '../repositories/notification_repository.dart';
import '../services/notification_service.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationService>(
      () => NotificationService(Get.find<ApiClient>()),
    );
    Get.lazyPut<NotificationRepository>(
      () => NotificationRepository(Get.find<NotificationService>()),
    );
    Get.lazyPut<NotificationController>(
      () => NotificationController(Get.find<NotificationRepository>()),
    );
  }
}
