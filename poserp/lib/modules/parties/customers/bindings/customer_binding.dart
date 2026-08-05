import 'package:get/get.dart';
import '../../../../core/api/api_client.dart';
import '../controllers/customer_controller.dart';
import '../repositories/customer_repository.dart';
import '../services/customer_service.dart';

class CustomerBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient());
    }
    Get.lazyPut<CustomerService>(() => CustomerService(Get.find<ApiClient>()));
    Get.lazyPut<CustomerRepository>(
      () => CustomerRepository(Get.find<CustomerService>()),
    );
    Get.lazyPut<CustomerController>(
      () => CustomerController(Get.find<CustomerRepository>()),
    );
  }
}
