import 'package:get/get.dart';
import '../../../../core/api/api_client.dart';
import '../controllers/purchase_return_controller.dart';
import '../repositories/purchase_return_repository.dart';
import '../services/purchase_return_service.dart';

class PurchaseReturnBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PurchaseReturnService>(
      () => PurchaseReturnService(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<PurchaseReturnRepository>(
      () => PurchaseReturnRepository(Get.find<PurchaseReturnService>()),
      fenix: true,
    );
    Get.lazyPut<PurchaseReturnController>(
      () => PurchaseReturnController(Get.find<PurchaseReturnRepository>()),
      fenix: true,
    );
  }
}
