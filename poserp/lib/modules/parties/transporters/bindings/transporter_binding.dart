import 'package:get/get.dart';
import '../../../../core/api/api_client.dart';
import '../controllers/transporter_controller.dart';
import '../repositories/transporter_repository.dart';
import '../services/transporter_service.dart';

class TransporterBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    }
    Get.lazyPut<TransporterService>(
      () => TransporterService(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<TransporterRepository>(
      () => TransporterRepository(Get.find<TransporterService>()),
      fenix: true,
    );
    Get.lazyPut<TransporterController>(
      () => TransporterController(Get.find<TransporterRepository>()),
      fenix: true,
    );
  }
}
