import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/api/api_exceptions.dart';
import '../../../../core/constants/app_colors.dart';
import '../models/category.dart';
import '../models/category_payload.dart';
import '../repositories/category_repository.dart';

class CategoryController extends GetxController {
  final CategoryRepository _categoryRepository;

  CategoryController(this._categoryRepository);

  final RxList<Category> categories = <Category>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxString search = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();

    // Debounce search input
    debounce(search, (_) {
      currentPage.value = 1;
      fetchCategories();
    }, time: const Duration(milliseconds: 400));
  }

  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      final res = await _categoryRepository.getCategories(
        search: search.value,
        page: currentPage.value,
        limit: 15,
      );
      categories.value = res.data ?? [];
      totalPages.value = res.pagination?.pages ?? 1;
    } catch (e) {
      final msg = e is AppException ? e.message : 'Failed to load categories.';
      showErrorSnackbar(msg);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> saveCategory({
    Category? editCategory,
    required String name,
    String? description,
    String? image,
    required bool isActive,
  }) async {
    try {
      isSaving.value = true;
      final payload = CategoryPayload(
        name: name,
        description: description,
        image: image,
        isActive: isActive,
      );

      if (editCategory != null) {
        await _categoryRepository.updateCategory(editCategory.id, payload);
        Get.snackbar(
          'Updated successfully',
          'Category "$name" was updated.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      } else {
        await _categoryRepository.createCategory(payload);
        Get.snackbar(
          'Created successfully',
          'Category "$name" was added.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      }

      await fetchCategories();
      return true;
    } catch (e) {
      final msg = e is AppException ? e.message : 'Operation failed.';
      showErrorSnackbar(msg);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _categoryRepository.deleteCategory(id);
      Get.snackbar(
        'Deleted successfully',
        'Category removed.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      await fetchCategories();
    } catch (e) {
      final msg = e is AppException ? e.message : 'Failed to delete category.';
      showErrorSnackbar(msg);
    }
  }

  void changePage(int page) {
    if (page >= 1 && page <= totalPages.value) {
      currentPage.value = page;
      fetchCategories();
    }
  }

  void showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.danger,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }
}
