import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/api/api_exceptions.dart';
import '../../../core/constants/app_colors.dart';
import '../categories/models/category.dart';
import '../categories/repositories/category_repository.dart';
import '../models/product.dart';
import '../models/product_payload.dart';
import '../repositories/product_repository.dart';
import '../subcategories/models/subcategory.dart';
import '../subcategories/repositories/subcategory_repository.dart';

class ProductController extends GetxController {
  final ProductRepository _productRepository;
  final CategoryRepository _categoryRepository;
  final SubcategoryRepository _subcategoryRepository;

  ProductController(
    this._productRepository,
    this._categoryRepository,
    this._subcategoryRepository,
  );

  final RxList<Product> products = <Product>[].obs;
  final RxList<Category> categories = <Category>[].obs;
  final RxList<Subcategory> subcategories = <Subcategory>[].obs;

  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxString search = ''.obs;
  final RxString selectedCategoryFilter = 'all'.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;

  @override
  void onInit() {
    super.onInit();
    loadAllData();

    debounce(search, (_) {
      currentPage.value = 1;
      fetchProducts();
    }, time: const Duration(milliseconds: 400));

    ever(selectedCategoryFilter, (_) {
      currentPage.value = 1;
      fetchProducts();
    });
  }

  Future<void> loadAllData() async {
    try {
      isLoading.value = true;
      await Future.wait([fetchCategories(), fetchSubcategories()]);
      await fetchProducts();
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
      final res = await _subcategoryRepository.getSubcategories(limit: 200);
      subcategories.value = res.data ?? [];
    } catch (_) {}
  }

  Future<void> fetchProducts() async {
    try {
      final res = await _productRepository.getProducts(
        search: search.value,
        category: selectedCategoryFilter.value,
        page: currentPage.value,
        limit: 15,
      );
      products.value = res.data ?? [];
      totalPages.value = res.pagination?.pages ?? 1;
    } catch (e) {
      final msg = e is AppException ? e.message : 'Failed to load products.';
      showErrorSnackbar(msg);
    }
  }

  Future<bool> saveProduct({
    Product? editProduct,
    required String name,
    required String sku,
    String? barcode,
    String? description,
    required String categoryId,
    String? subcategoryId,
    required double stock,
    required double lowStockThreshold,
    required String unit,
    List<String> images = const [],
    String? hsnCode,
    required double salesPrice,
    required double purchasePrice,
    required double taxRate,
    required String salesTaxType,
    required String purchaseTaxType,
    required double openingStockPrice,
    String? openingStockDate,
  }) async {
    try {
      isSaving.value = true;
      final payload = ProductPayload(
        name: name,
        sku: sku,
        barcode: barcode,
        description: description,
        category: categoryId,
        subcategoryId: subcategoryId,
        stock: stock,
        lowStockThreshold: lowStockThreshold,
        unit: unit,
        images: images,
        image: images.isNotEmpty ? images.first : null,
        hsnCode: hsnCode,
        salesPrice: salesPrice,
        purchasePrice: purchasePrice,
        taxRate: taxRate,
        salesTaxType: salesTaxType,
        purchaseTaxType: purchaseTaxType,
        openingStockPrice: openingStockPrice,
        openingStockDate: openingStockDate,
      );

      if (editProduct != null) {
        await _productRepository.updateProduct(editProduct.id, payload);
        Get.snackbar(
          'Updated successfully',
          'Product "$name" was updated.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      } else {
        await _productRepository.createProduct(payload);
        Get.snackbar(
          'Created successfully',
          'Product "$name" was added.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      }

      await fetchProducts();
      return true;
    } catch (e) {
      final msg = e is AppException ? e.message : 'Operation failed.';
      showErrorSnackbar(msg);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _productRepository.deleteProduct(id);
      Get.snackbar(
        'Deleted successfully',
        'Product removed.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      await fetchProducts();
    } catch (e) {
      final msg = e is AppException ? e.message : 'Failed to delete product.';
      showErrorSnackbar(msg);
    }
  }

  void changePage(int page) {
    if (page >= 1 && page <= totalPages.value) {
      currentPage.value = page;
      fetchProducts();
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
