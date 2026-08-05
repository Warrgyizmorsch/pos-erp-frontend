import 'package:get/get.dart';
import '../../../../core/api/api_client.dart';
import '../controllers/payment_in_controller.dart';
import '../repositories/payment_in_repository.dart';
import '../services/payment_in_service.dart';

class PaymentInBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient());
    }
    Get.lazyPut<PaymentInService>(
      () => PaymentInService(Get.find<ApiClient>()),
    );
    Get.lazyPut<PaymentInRepository>(
      () => PaymentInRepository(Get.find<PaymentInService>()),
    );
    Get.lazyPut<PaymentInController>(
      () => PaymentInController(Get.find<PaymentInRepository>()),
    );
  }
}
