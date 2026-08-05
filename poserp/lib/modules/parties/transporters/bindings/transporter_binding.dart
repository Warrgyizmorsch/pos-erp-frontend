import 'package:get/get.dart';
import '../../../../core/api/api_client.dart';
import '../controllers/transporter_controller.dart';
import '../repositories/transporter_repository.dart';
import '../services/transporter_service.dart';

class TransporterBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient());
    }
    Get.lazyPut<TransporterService>(
      () => TransporterService(Get.find<ApiClient>()),
    );
    Get.lazyPut<TransporterRepository>(
      () => TransporterRepository(Get.find<TransporterService>()),
    );
    Get.lazyPut<TransporterController>(
      () => TransporterController(Get.find<TransporterRepository>()),
    );
  }
}
