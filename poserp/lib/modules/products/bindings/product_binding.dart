import 'package:get/get.dart';
import '../../../core/api/api_client.dart';
import '../categories/repositories/category_repository.dart';
import '../categories/services/category_service.dart';
import '../controllers/product_controller.dart';
import '../repositories/product_repository.dart';
import '../services/product_service.dart';
import '../subcategories/repositories/subcategory_repository.dart';
import '../subcategories/services/subcategory_service.dart';

class ProductBinding extends Bindings {
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
    if (!Get.isRegistered<SubcategoryService>()) {
      Get.lazyPut<SubcategoryService>(
        () => SubcategoryService(Get.find<ApiClient>()),
        fenix: true,
      );
    }
    if (!Get.isRegistered<SubcategoryRepository>()) {
      Get.lazyPut<SubcategoryRepository>(
        () => SubcategoryRepository(Get.find<SubcategoryService>()),
        fenix: true,
      );
    }
    Get.lazyPut<ProductService>(
      () => ProductService(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<ProductRepository>(
      () => ProductRepository(Get.find<ProductService>()),
      fenix: true,
    );
    Get.lazyPut<ProductController>(
      () => ProductController(
        Get.find<ProductRepository>(),
        Get.find<CategoryRepository>(),
        Get.find<SubcategoryRepository>(),
      ),
      fenix: true,
    );
  }
}
