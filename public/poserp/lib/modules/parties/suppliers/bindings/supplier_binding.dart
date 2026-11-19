import 'package:get/get.dart';
import '../../../../core/api/api_client.dart';
import '../controllers/supplier_controller.dart';
import '../repositories/supplier_repository.dart';
import '../services/supplier_service.dart';

class SupplierBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    }
    Get.lazyPut<SupplierService>(
      () => SupplierService(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<SupplierRepository>(
      () => SupplierRepository(Get.find<SupplierService>()),
      fenix: true,
    );
    Get.lazyPut<SupplierController>(
      () => SupplierController(Get.find<SupplierRepository>()),
      fenix: true,
    );
  }
}
