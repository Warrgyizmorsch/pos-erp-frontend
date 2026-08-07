import 'package:get/get.dart';
import '../../../../core/api/api_client.dart';
import '../controllers/shift_controller.dart';
import '../repositories/shift_repository.dart';
import '../services/shift_service.dart';

class ShiftBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShiftService>(() => ShiftService(Get.find<ApiClient>()));
    Get.lazyPut<ShiftRepository>(
      () => ShiftRepository(Get.find<ShiftService>()),
    );
    Get.lazyPut<ShiftController>(
      () => ShiftController(Get.find<ShiftRepository>()),
    );
  }
}
