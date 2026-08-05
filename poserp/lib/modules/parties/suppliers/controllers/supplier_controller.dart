import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/api/api_exceptions.dart';
import '../../../../core/constants/app_colors.dart';
import '../models/supplier.dart';
import '../models/supplier_payload.dart';
import '../repositories/supplier_repository.dart';

class SupplierController extends GetxController {
  final SupplierRepository _repository;

  SupplierController(this._repository);

  final RxList<Supplier> suppliers = <Supplier>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isSubmitting = false.obs;

  final RxString searchQuery = ''.obs;
  final RxBool filterBalance = false.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxInt totalItems = 0.obs;
  final int itemsPerPage = 15;

  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    loadSuppliers();

    debounce(searchQuery, (_) {
      currentPage.value = 1;
      loadSuppliers();
    }, time: const Duration(milliseconds: 400));
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  Future<void> loadSuppliers() async {
    try {
      isLoading.value = true;
      final response = await _repository.getSuppliers(
        search: searchQuery.value,
        page: currentPage.value,
        limit: itemsPerPage,
        hasBalance: filterBalance.value ? true : null,
      );

      suppliers.value = response.data ?? [];
      if (response.pagination != null) {
        totalPages.value = response.pagination!.pages;
        totalItems.value = response.pagination!.total;
      }
    } catch (e) {
      showErrorSnackbar(
        e is AppException ? e.message : 'Failed to load suppliers',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  void toggleFilterBalance() {
    filterBalance.value = !filterBalance.value;
    currentPage.value = 1;
    loadSuppliers();
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages.value) {
      currentPage.value = page;
      loadSuppliers();
    }
  }

  Future<bool> createSupplier(SupplierPayload payload) async {
    try {
      isSubmitting.value = true;
      await _repository.createSupplier(payload);
      Get.snackbar(
        'Success',
        'Supplier created successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      loadSuppliers();
      return true;
    } catch (e) {
      showErrorSnackbar(
        e is AppException ? e.message : 'Failed to create supplier',
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> updateSupplier(String id, SupplierPayload payload) async {
    try {
      isSubmitting.value = true;
      await _repository.updateSupplier(id, payload);
      Get.snackbar(
        'Success',
        'Supplier updated successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      loadSuppliers();
      return true;
    } catch (e) {
      showErrorSnackbar(
        e is AppException ? e.message : 'Failed to update supplier',
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> deleteSupplier(String id) async {
    try {
      await _repository.deleteSupplier(id);
      Get.snackbar(
        'Success',
        'Supplier deleted successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      loadSuppliers();
    } catch (e) {
      showErrorSnackbar(
        e is AppException ? e.message : 'Failed to delete supplier',
      );
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
