import 'package:get/get.dart';
import '../../../../core/api/api_client.dart';
import '../../repositories/product_repository.dart';
import '../../services/product_service.dart';
import '../controllers/opening_stock_controller.dart';
import '../repositories/opening_stock_repository.dart';
import '../services/opening_stock_service.dart';

class OpeningStockBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient());
    }
    if (!Get.isRegistered<ProductService>()) {
      Get.lazyPut<ProductService>(() => ProductService(Get.find<ApiClient>()));
    }
    if (!Get.isRegistered<ProductRepository>()) {
      Get.lazyPut<ProductRepository>(
        () => ProductRepository(Get.find<ProductService>()),
      );
    }
    Get.lazyPut<OpeningStockService>(
      () => OpeningStockService(Get.find<ApiClient>()),
    );
    Get.lazyPut<OpeningStockRepository>(
      () => OpeningStockRepository(Get.find<OpeningStockService>()),
    );
    Get.lazyPut<OpeningStockController>(
      () => OpeningStockController(
        Get.find<OpeningStockRepository>(),
        Get.find<ProductRepository>(),
      ),
    );
  }
}
