import 'package:get/get.dart';
import '../../../../core/api/api_client.dart';
import '../controllers/sale_controller.dart';
import '../repositories/sale_repository.dart';
import '../services/sale_service.dart';

class SaleBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    }
    Get.lazyPut<SaleService>(
      () => SaleService(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<SaleRepository>(
      () => SaleRepository(Get.find<SaleService>()),
      fenix: true,
    );
    Get.lazyPut<SaleController>(
      () => SaleController(Get.find<SaleRepository>()),
      fenix: true,
    );
  }
}
