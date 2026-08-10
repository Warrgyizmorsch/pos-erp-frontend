import 'package:get/get.dart';
import '../../../../core/api/api_client.dart';
import '../controllers/payment_out_controller.dart';
import '../repositories/payment_out_repository.dart';
import '../services/payment_out_service.dart';

class PaymentOutBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    }
    Get.lazyPut<PaymentOutService>(
      () => PaymentOutService(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<PaymentOutRepository>(
      () => PaymentOutRepository(Get.find<PaymentOutService>()),
      fenix: true,
    );
    Get.lazyPut<PaymentOutController>(
      () => PaymentOutController(Get.find<PaymentOutRepository>()),
      fenix: true,
    );
  }
}
