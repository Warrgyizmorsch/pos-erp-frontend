import 'package:get/get.dart';
import '../../../../core/api/api_client.dart';
import '../../../products/repositories/product_repository.dart';
import '../../../products/services/product_service.dart';
import '../controllers/barcode_controller.dart';

class BarcodeBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ProductService>()) {
      Get.lazyPut<ProductService>(() => ProductService(Get.find<ApiClient>()));
    }
    if (!Get.isRegistered<ProductRepository>()) {
      Get.lazyPut<ProductRepository>(
        () => ProductRepository(Get.find<ProductService>()),
      );
    }
    Get.lazyPut<BarcodeController>(
      () => BarcodeController(Get.find<ProductRepository>()),
    );
  }
}
