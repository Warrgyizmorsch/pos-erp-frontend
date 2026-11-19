import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/api/api_exceptions.dart';
import '../../../../core/constants/app_colors.dart';
import '../models/shift.dart';
import '../repositories/shift_repository.dart';

class ShiftController extends GetxController {
  final ShiftRepository _repository;

  ShiftController(this._repository);

  final Rxn<Shift> currentShift = Rxn<Shift>();
  final RxBool isLoading = true.obs;
  final RxBool isSubmitting = false.obs;

  bool get isShiftActive =>
      currentShift.value != null && currentShift.value!.status == 'open';

  @override
  void onInit() {
    super.onInit();
    loadCurrentShift();
  }

  Future<void> loadCurrentShift() async {
    try {
      isLoading.value = true;
      final s = await _repository.fetchCurrentShift();
      currentShift.value = s;
    } catch (_) {
      currentShift.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> startNewShift({
    required double openingCash,
    required String cashierName,
    String? notes,
  }) async {
    if (openingCash < 0) {
      showErrorSnackbar('Opening cash balance cannot be negative.');
      return false;
    }
    if (cashierName.trim().isEmpty) {
      showErrorSnackbar('Please enter cashier name.');
      return false;
    }

    try {
      isSubmitting.value = true;
      final shift = await _repository.openShift(
        openingCash: openingCash,
        cashierName: cashierName.trim(),
        notes: notes?.trim(),
      );

      currentShift.value = shift;
      Get.snackbar(
        'Shift Opened',
        'Cashier shift started successfully for ${shift.cashierName}.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return true;
    } catch (e) {
      showErrorSnackbar(
        e is AppException ? e.message : 'Failed to open cashier shift.',
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> endActiveShift({
    required double closingBalance,
    required double actualCash,
    String? notes,
  }) async {
    try {
      isSubmitting.value = true;
      final shift = await _repository.closeShift(
        closingBalance: closingBalance,
        actualCash: actualCash,
        notes: notes?.trim(),
      );

      currentShift.value = shift;
      Get.snackbar(
        'Shift Closed',
        'Cashier shift closed and reconciled successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.info,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return true;
    } catch (e) {
      showErrorSnackbar(
        e is AppException ? e.message : 'Failed to close cashier shift.',
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
