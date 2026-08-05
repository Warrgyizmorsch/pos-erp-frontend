import 'package:get/get.dart';
import '../../../../core/api/api_client.dart';
import '../controllers/sale_return_controller.dart';
import '../repositories/sale_return_repository.dart';
import '../services/sale_return_service.dart';

class SaleReturnBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient());
    }
    Get.lazyPut<SaleReturnService>(
      () => SaleReturnService(Get.find<ApiClient>()),
    );
    Get.lazyPut<SaleReturnRepository>(
      () => SaleReturnRepository(Get.find<SaleReturnService>()),
    );
    Get.lazyPut<SaleReturnController>(
      () => SaleReturnController(Get.find<SaleReturnRepository>()),
    );
  }
}
