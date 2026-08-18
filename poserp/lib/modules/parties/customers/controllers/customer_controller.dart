import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/api/api_exceptions.dart';
import '../../../../core/constants/app_colors.dart';
import '../models/customer.dart';
import '../models/customer_payload.dart';
import '../repositories/customer_repository.dart';

class CustomerController extends GetxController {
  final CustomerRepository _repository;

  CustomerController(this._repository);

  CustomerRepository get repository => _repository;

  final RxList<Customer> customers = <Customer>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isSubmitting = false.obs;

  final RxString searchQuery = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxInt totalItems = 0.obs;
  final int itemsPerPage = 15;

  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    loadCustomers();

    debounce(searchQuery, (_) {
      currentPage.value = 1;
      loadCustomers();
    }, time: const Duration(milliseconds: 400));
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  Future<void> loadCustomers() async {
    try {
      isLoading.value = true;
      final response = await _repository.getCustomers(
        search: searchQuery.value,
        page: currentPage.value,
        limit: itemsPerPage,
      );

      customers.value = response.data ?? [];
      if (response.pagination != null) {
        totalPages.value = response.pagination!.pages;
        totalItems.value = response.pagination!.total;
      }
    } catch (e) {
      showErrorSnackbar(
        e is AppException ? e.message : 'Failed to load customers',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages.value) {
      currentPage.value = page;
      loadCustomers();
    }
  }

  Future<bool> createCustomer(CustomerPayload payload) async {
    try {
      isSubmitting.value = true;
      await _repository.createCustomer(payload);
      Get.snackbar(
        'Success',
        'Customer created successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      loadCustomers();
      return true;
    } catch (e) {
      showErrorSnackbar(
        e is AppException ? e.message : 'Failed to create customer',
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> updateCustomer(String id, CustomerPayload payload) async {
    try {
      isSubmitting.value = true;
      await _repository.updateCustomer(id, payload);
      Get.snackbar(
        'Success',
        'Customer updated successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      loadCustomers();
      return true;
    } catch (e) {
      showErrorSnackbar(
        e is AppException ? e.message : 'Failed to update customer',
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> deleteCustomer(String id) async {
    try {
      await _repository.deleteCustomer(id);
      Get.snackbar(
        'Success',
        'Customer deleted successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      loadCustomers();
    } catch (e) {
      showErrorSnackbar(
        e is AppException ? e.message : 'Failed to delete customer',
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
