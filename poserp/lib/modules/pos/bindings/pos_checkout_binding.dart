import 'package:get/get.dart';
import '../../../../core/api/api_client.dart';
import '../controllers/pos_checkout_controller.dart';
import '../repositories/pos_checkout_repository.dart';
import '../services/pos_checkout_service.dart';

class POSCheckoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<POSCheckoutService>(
      () => POSCheckoutService(Get.find<ApiClient>()),
    );
    Get.lazyPut<POSCheckoutRepository>(
      () => POSCheckoutRepository(Get.find<POSCheckoutService>()),
    );
    Get.lazyPut<POSCheckoutController>(
      () => POSCheckoutController(Get.find<POSCheckoutRepository>()),
    );
  }
}
