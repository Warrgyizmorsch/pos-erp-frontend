import 'package:get/get.dart';
import '../../../core/api/api_client.dart';
import '../controllers/business_profile_controller.dart';
import '../repositories/business_repository.dart';
import '../services/business_service.dart';

class BusinessProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BusinessService>(
      () => BusinessService(Get.find<ApiClient>()),
    );
    Get.lazyPut<BusinessRepository>(
      () => BusinessRepository(Get.find<BusinessService>()),
    );
    Get.lazyPut<BusinessProfileController>(
      () => BusinessProfileController(Get.find<BusinessRepository>()),
    );
  }
}
