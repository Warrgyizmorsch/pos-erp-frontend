import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/api/api_exceptions.dart';
import '../../../../core/constants/app_colors.dart';
import '../../categories/models/category.dart';
import '../../categories/repositories/category_repository.dart';
import '../models/subcategory.dart';
import '../models/subcategory_payload.dart';
import '../repositories/subcategory_repository.dart';

class SubcategoryController extends GetxController {
  final SubcategoryRepository _subcategoryRepository;
  final CategoryRepository _categoryRepository;

  SubcategoryController(this._subcategoryRepository, this._categoryRepository);

  final RxList<Subcategory> subcategories = <Subcategory>[].obs;
  final RxList<Category> categories = <Category>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxString search = ''.obs;
  final RxString selectedParentCategoryId = 'all'.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;

  @override
  void onInit() {
    super.onInit();
    loadAllData();

    // Debounce search and parent category filter
    debounce(search, (_) {
      currentPage.value = 1;
      fetchSubcategories();
    }, time: const Duration(milliseconds: 400));

    ever(selectedParentCategoryId, (_) {
      currentPage.value = 1;
      fetchSubcategories();
    });
  }

  Future<void> loadAllData() async {
    try {
      isLoading.value = true;
      await fetchCategories();
      await fetchSubcategories();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCategories() async {
    try {
      final res = await _categoryRepository.getCategories(limit: 100);
      categories.value = res.data ?? [];
    } catch (_) {}
  }

  Future<void> fetchSubcategories() async {
    try {
      final res = await _subcategoryRepository.getSubcategories(
        search: search.value,
        parentCategoryId: selectedParentCategoryId.value,
        page: currentPage.value,
        limit: 15,
      );
      subcategories.value = res.data ?? [];
      totalPages.value = res.pagination?.pages ?? 1;
    } catch (e) {
      final msg = e is AppException
          ? e.message
          : 'Failed to load subcategories.';
      showErrorSnackbar(msg);
    }
  }

  Future<bool> saveSubcategory({
    Subcategory? editSubcategory,
    required String name,
    required String parentCategoryId,
    String? description,
    String? image,
    required bool isActive,
  }) async {
    try {
      isSaving.value = true;
      final payload = SubcategoryPayload(
        name: name,
        parentCategoryId: parentCategoryId,
        description: description,
        image: image,
        isActive: isActive,
      );

      if (editSubcategory != null) {
        await _subcategoryRepository.updateSubcategory(
          editSubcategory.id,
          payload,
        );
        Get.snackbar(
          'Updated successfully',
          'Subcategory "$name" was updated.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      } else {
        await _subcategoryRepository.createSubcategory(payload);
        Get.snackbar(
          'Created successfully',
          'Subcategory "$name" was added.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      }

      await fetchSubcategories();
      return true;
    } catch (e) {
      final msg = e is AppException ? e.message : 'Operation failed.';
      showErrorSnackbar(msg);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteSubcategory(String id) async {
    try {
      await _subcategoryRepository.deleteSubcategory(id);
      Get.snackbar(
        'Deleted successfully',
        'Subcategory removed.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      await fetchSubcategories();
    } catch (e) {
      final msg = e is AppException
          ? e.message
          : 'Failed to delete subcategory.';
      showErrorSnackbar(msg);
    }
  }

  void changePage(int page) {
    if (page >= 1 && page <= totalPages.value) {
      currentPage.value = page;
      fetchSubcategories();
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
