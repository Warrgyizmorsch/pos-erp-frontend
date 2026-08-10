import 'package:get/get.dart';
import '../../../../core/api/api_client.dart';
import '../../categories/repositories/category_repository.dart';
import '../../categories/services/category_service.dart';
import '../controllers/subcategory_controller.dart';
import '../repositories/subcategory_repository.dart';
import '../services/subcategory_service.dart';

class SubcategoryBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    }
    if (!Get.isRegistered<CategoryService>()) {
      Get.lazyPut<CategoryService>(
        () => CategoryService(Get.find<ApiClient>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<CategoryRepository>()) {
      Get.lazyPut<CategoryRepository>(
        () => CategoryRepository(Get.find<CategoryService>()),
        fenix: true,
      );
    }
    Get.lazyPut<SubcategoryService>(
      () => SubcategoryService(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<SubcategoryRepository>(
      () => SubcategoryRepository(Get.find<SubcategoryService>()),
      fenix: true,
    );
    Get.lazyPut<SubcategoryController>(
      () => SubcategoryController(
        Get.find<SubcategoryRepository>(),
        Get.find<CategoryRepository>(),
      ),
      fenix: true,
    );
  }
}
