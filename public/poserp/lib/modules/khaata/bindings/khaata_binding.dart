import 'package:get/get.dart';
import '../controllers/khaata_controller.dart';
import '../repositories/khaata_repository.dart';
import '../services/khaata_service.dart';

class KhaataBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KhaataService>(() => KhaataService(Get.find()));
    Get.lazyPut<KhaataRepository>(() => KhaataRepository(Get.find()));
    Get.lazyPut<KhaataController>(() => KhaataController(Get.find()));
  }
}
