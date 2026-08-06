import 'package:get/get.dart';
import '../../../../core/api/api_client.dart';
import '../controllers/purchase_controller.dart';
import '../repositories/purchase_repository.dart';
import '../services/purchase_service.dart';

class PurchaseBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient());
    }
    Get.lazyPut<PurchaseService>(() => PurchaseService(Get.find<ApiClient>()));
    Get.lazyPut<PurchaseRepository>(
      () => PurchaseRepository(Get.find<PurchaseService>()),
    );
    Get.lazyPut<PurchaseController>(
      () => PurchaseController(Get.find<PurchaseRepository>()),
    );
  }
}
