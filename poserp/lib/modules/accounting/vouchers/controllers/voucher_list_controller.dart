import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/api/api_exceptions.dart';
import '../../../../core/constants/app_colors.dart';
import '../models/accounting_voucher.dart';
import '../models/voucher_type.dart';
import '../repositories/voucher_repository.dart';

class VoucherListController extends GetxController {
  final VoucherRepository _repository;

  VoucherListController(this._repository);

  final RxList<AccountingVoucher> vouchers = <AccountingVoucher>[].obs;
  final RxList<VoucherType> voucherTypes = <VoucherType>[].obs;
  final RxBool isLoading = true.obs;

  final RxString searchQuery = ''.obs;
  final RxString selectedTypeCode = 'ALL'.obs;
  final RxString selectedStatus = 'ALL'.obs;
  final RxString startDate = ''.obs;
  final RxString endDate = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadVoucherTypes();
    loadVouchers();

    debounce(
      searchQuery,
      (_) => loadVouchers(),
      time: const Duration(milliseconds: 300),
    );
    ever(selectedTypeCode, (_) => loadVouchers());
    ever(selectedStatus, (_) => loadVouchers());
    ever(startDate, (_) => loadVouchers());
    ever(endDate, (_) => loadVouchers());
  }

  Future<void> loadVoucherTypes() async {
    final types = await _repository.fetchVoucherTypes();
    voucherTypes.assignAll(types);
  }

  Future<void> loadVouchers() async {
    try {
      isLoading.value = true;
      final result = await _repository.fetchVouchers(
        search: searchQuery.value,
        typeCode: selectedTypeCode.value,
        status: selectedStatus.value,
        startDate: startDate.value,
        endDate: endDate.value,
      );
      vouchers.assignAll(result);
    } catch (_) {
      vouchers.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> postDraftVoucher(String id) async {
    try {
      await _repository.postVoucher(id);
      Get.snackbar(
        'Success',
        'Voucher posted successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      loadVouchers();
    } catch (e) {
      Get.snackbar(
        'Error',
        e is AppException ? e.message : 'Failed to post voucher.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  Future<void> cancelVoucher(String id, String reason) async {
    try {
      await _repository.cancelVoucher(id, reason);
      Get.snackbar(
        'Success',
        'Voucher cancelled successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.warning,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      loadVouchers();
    } catch (e) {
      Get.snackbar(
        'Error',
        e is AppException ? e.message : 'Failed to cancel voucher.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    }
  }
}
