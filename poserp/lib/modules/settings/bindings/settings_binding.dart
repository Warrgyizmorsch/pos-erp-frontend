import 'package:get/get.dart';
import '../../../core/api/api_client.dart';
import '../controllers/settings_controller.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingsController>(
      () => SettingsController(Get.find<ApiClient>()),
    );
  }
}
