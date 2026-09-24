import 'package:get/get.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/services/storage_service.dart';
import '../controllers/user_management_controller.dart';

class UserManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserManagementController>(
      () => UserManagementController(
        Get.find<AuthRepository>(),
        Get.find<StorageService>(),
      ),
    );
  }
}
