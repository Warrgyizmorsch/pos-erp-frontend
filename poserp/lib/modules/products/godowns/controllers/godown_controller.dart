import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/api/api_exceptions.dart';
import '../../../../core/constants/app_colors.dart';
import '../models/godown.dart';
import '../repositories/godown_repository.dart';

class GodownController extends GetxController {
  final GodownRepository _repository;

  GodownController(this._repository);

  final RxList<Godown> godowns = <Godown>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadGodowns();
  }

  Future<void> loadGodowns() async {
    try {
      isLoading.value = true;
      final list = await _repository.getAllGodowns();
      godowns.assignAll(list);
    } catch (e) {
      showErrorSnackbar(
        e is AppException ? e.message : 'Failed to load godowns',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> saveGodown({
    String? id,
    required String name,
    required String code,
    String? location,
    double capacity = 0,
    bool isDefault = false,
  }) async {
    if (name.trim().isEmpty || code.trim().isEmpty) {
      showErrorSnackbar('Godown name and code are required');
      return false;
    }

    try {
      isSubmitting.value = true;
      final payload = {
        'name': name.trim(),
        'code': code.trim(),
        'location': location?.trim() ?? '',
        'capacity': capacity,
        'isDefault': isDefault,
        'isActive': true,
      };

      if (id != null && id.isNotEmpty) {
        await _repository.updateGodown(id, payload);
        Get.snackbar(
          'Success',
          'Godown updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      } else {
        await _repository.createGodown(payload);
        Get.snackbar(
          'Success',
          'Godown created successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      }

      await loadGodowns();
      return true;
    } catch (e) {
      showErrorSnackbar(
        e is AppException ? e.message : 'Failed to save godown',
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> deleteGodown(String id) async {
    try {
      isSubmitting.value = true;
      await _repository.deleteGodown(id);
      Get.snackbar(
        'Success',
        'Godown deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      await loadGodowns();
    } catch (e) {
      showErrorSnackbar(
        e is AppException ? e.message : 'Failed to delete godown',
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> transferStock({
    required String sourceGodownId,
    required String destinationGodownId,
    required List<Map<String, dynamic>> items,
    String? notes,
  }) async {
    if (sourceGodownId.isEmpty || destinationGodownId.isEmpty) {
      showErrorSnackbar('Please select source and destination godowns');
      return false;
    }
    if (sourceGodownId == destinationGodownId) {
      showErrorSnackbar('Source and destination godowns cannot be the same');
      return false;
    }
    if (items.isEmpty) {
      showErrorSnackbar('Please add at least one product to transfer');
      return false;
    }

    try {
      isSubmitting.value = true;
      await _repository.transferStock(
        sourceGodownId: sourceGodownId,
        destinationGodownId: destinationGodownId,
        items: items,
        notes: notes,
      );

      Get.snackbar(
        'Success',
        'Stock transferred successfully between godowns',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return true;
    } catch (e) {
      showErrorSnackbar(
        e is AppException ? e.message : 'Failed to transfer stock',
      );
      return false;
    } finally {
      isSubmitting.value = false;
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
