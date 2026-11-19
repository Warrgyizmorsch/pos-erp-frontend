import 'package:get/get.dart';
import '../../../../core/api/api_client.dart';
import '../controllers/sale_return_controller.dart';
import '../repositories/sale_return_repository.dart';
import '../services/sale_return_service.dart';

class SaleReturnBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    }
    Get.lazyPut<SaleReturnService>(
      () => SaleReturnService(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<SaleReturnRepository>(
      () => SaleReturnRepository(Get.find<SaleReturnService>()),
      fenix: true,
    );
    Get.lazyPut<SaleReturnController>(
      () => SaleReturnController(Get.find<SaleReturnRepository>()),
      fenix: true,
    );
  }
}
