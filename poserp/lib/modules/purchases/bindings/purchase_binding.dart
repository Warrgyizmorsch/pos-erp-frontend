import 'package:get/get.dart';
import '../../../../core/api/api_client.dart';
import '../controllers/purchase_controller.dart';
import '../repositories/purchase_repository.dart';
import '../services/purchase_service.dart';

class PurchaseBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    }
    Get.lazyPut<PurchaseService>(
      () => PurchaseService(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<PurchaseRepository>(
      () => PurchaseRepository(Get.find<PurchaseService>()),
      fenix: true,
    );
    Get.lazyPut<PurchaseController>(
      () => PurchaseController(Get.find<PurchaseRepository>()),
      fenix: true,
    );
  }
}
