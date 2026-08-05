import 'package:get/get.dart';
import '../../../../core/api/api_client.dart';
import '../controllers/pos_controller.dart';
import '../repositories/pos_repository.dart';
import '../services/pos_service.dart';

class POSBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient());
    }
    Get.lazyPut<POSService>(() => POSService(Get.find<ApiClient>()));
    Get.lazyPut<POSRepository>(() => POSRepository(Get.find<POSService>()));
    Get.lazyPut<POSController>(() => POSController(Get.find<POSRepository>()));
  }
}
