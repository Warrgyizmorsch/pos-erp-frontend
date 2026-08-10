import 'package:get/get.dart';
import '../../../../core/api/api_client.dart';
import '../controllers/coa_controller.dart';
import '../repositories/coa_repository.dart';
import '../services/coa_service.dart';

class COABinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<COAService>(
      () => COAService(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<COARepository>(
      () => COARepository(Get.find<COAService>()),
      fenix: true,
    );
    Get.lazyPut<COAController>(
      () => COAController(Get.find<COARepository>()),
      fenix: true,
    );
  }
}
