import 'package:get/get.dart';
import '../../../../core/api/api_client.dart';
import '../controllers/category_controller.dart';
import '../repositories/category_repository.dart';
import '../services/category_service.dart';

class CategoryBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    }
    Get.lazyPut<CategoryService>(
      () => CategoryService(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<CategoryRepository>(
      () => CategoryRepository(Get.find<CategoryService>()),
      fenix: true,
    );
    Get.lazyPut<CategoryController>(
      () => CategoryController(Get.find<CategoryRepository>()),
      fenix: true,
    );
  }
}
