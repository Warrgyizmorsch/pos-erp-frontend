import 'package:get/get.dart';
import '../controllers/godown_controller.dart';
import '../repositories/godown_repository.dart';
import '../services/godown_service.dart';

class GodownBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GodownService>(() => GodownService(Get.find()));
    Get.lazyPut<GodownRepository>(() => GodownRepository(Get.find()));
    Get.lazyPut<GodownController>(() => GodownController(Get.find()));
  }
}
