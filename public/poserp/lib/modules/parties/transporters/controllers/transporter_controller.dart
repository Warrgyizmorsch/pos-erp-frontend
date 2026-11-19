import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/api/api_exceptions.dart';
import '../../../../core/constants/app_colors.dart';
import '../models/transporter.dart';
import '../models/transporter_payload.dart';
import '../repositories/transporter_repository.dart';

class TransporterController extends GetxController {
  final TransporterRepository _repository;

  TransporterController(this._repository);

  final RxList<Transporter> transporters = <Transporter>[].obs;
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
    loadTransporters();

    debounce(searchQuery, (_) {
      currentPage.value = 1;
      loadTransporters();
    }, time: const Duration(milliseconds: 400));
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  Future<void> loadTransporters() async {
    try {
      isLoading.value = true;
      final response = await _repository.getTransporters(
        search: searchQuery.value,
        page: currentPage.value,
        limit: itemsPerPage,
      );

      transporters.value = response.data ?? [];
      if (response.pagination != null) {
        totalPages.value = response.pagination!.pages;
        totalItems.value = response.pagination!.total;
      }
    } catch (e) {
      showErrorSnackbar(
        e is AppException ? e.message : 'Failed to load transporters',
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
      loadTransporters();
    }
  }

  bool validatePhone(String phone) {
    final regExp = RegExp(r'^[6-9]\d{9}$');
    return regExp.hasMatch(phone.trim());
  }

  Future<bool> createTransporter(TransporterPayload payload) async {
    if (!validatePhone(payload.phone)) {
      showErrorSnackbar('Please enter a valid 10-digit Indian mobile number.');
      return false;
    }

    try {
      isSubmitting.value = true;
      await _repository.createTransporter(payload);
      Get.snackbar(
        'Success',
        'Transporter created successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      loadTransporters();
      return true;
    } catch (e) {
      showErrorSnackbar(
        e is AppException ? e.message : 'Failed to create transporter',
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> updateTransporter(String id, TransporterPayload payload) async {
    if (!validatePhone(payload.phone)) {
      showErrorSnackbar('Please enter a valid 10-digit Indian mobile number.');
      return false;
    }

    try {
      isSubmitting.value = true;
      await _repository.updateTransporter(id, payload);
      Get.snackbar(
        'Success',
        'Transporter updated successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      loadTransporters();
      return true;
    } catch (e) {
      showErrorSnackbar(
        e is AppException ? e.message : 'Failed to update transporter',
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> deleteTransporter(String id) async {
    try {
      await _repository.deleteTransporter(id);
      Get.snackbar(
        'Success',
        'Transporter deleted successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      loadTransporters();
    } catch (e) {
      showErrorSnackbar(
        e is AppException ? e.message : 'Failed to delete transporter',
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
