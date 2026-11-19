import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/api/api_exceptions.dart';
import '../../../../core/constants/app_colors.dart';
import '../models/accounting_voucher.dart';
import '../models/voucher_type.dart';
import '../repositories/voucher_repository.dart';
import '../widgets/voucher_detail_dialog.dart';

class VoucherListController extends GetxController {
  final VoucherRepository _repository;

  VoucherListController(this._repository);

  final RxList<AccountingVoucher> vouchers = <AccountingVoucher>[].obs;
  final RxList<VoucherType> voucherTypes = <VoucherType>[].obs;
  final RxBool isLoading = true.obs;
  final RxString actionLoading = ''.obs;
  final Rxn<AccountingVoucher> selectedVoucherDetail = Rxn<AccountingVoucher>();

  final RxString searchQuery = ''.obs;
  final RxString selectedTypeCode = 'ALL'.obs;
  final RxString selectedStatus = 'ALL'.obs;
  final RxString referenceModule = ''.obs;
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
    debounce(
      referenceModule,
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
        referenceModule: referenceModule.value,
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

  Future<void> viewVoucher(String id, {AccountingVoucher? fallback}) async {
    try {
      actionLoading.value = 'view-$id';
      final detail = await _repository.fetchVoucherById(id);
      selectedVoucherDetail.value = detail;
      Get.dialog(
        VoucherDetailDialog(
          voucher: detail,
          onPost: (vId) => postDraftVoucher(vId),
          onCancel: (vId, reason) => cancelVoucher(vId, reason),
        ),
      );
    } catch (e) {
      if (fallback != null) {
        selectedVoucherDetail.value = fallback;
        Get.dialog(
          VoucherDetailDialog(
            voucher: fallback,
            onPost: (vId) => postDraftVoucher(vId),
            onCancel: (vId, reason) => cancelVoucher(vId, reason),
          ),
        );
      } else {
        Get.snackbar(
          'Error',
          e is AppException ? e.message : 'Failed to load voucher details.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.danger.withAlpha(40),
          margin: const EdgeInsets.all(16),
        );
      }
    } finally {
      actionLoading.value = '';
    }
  }

  Future<void> postDraftVoucher(String id) async {
    try {
      actionLoading.value = 'post-$id';
      await _repository.postVoucher(id);
      Get.snackbar(
        'Success',
        'Voucher posted successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success.withAlpha(40),
        margin: const EdgeInsets.all(16),
      );
      await loadVouchers();
    } catch (e) {
      Get.snackbar(
        'Error',
        e is AppException ? e.message : 'Failed to post voucher.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger.withAlpha(40),
        margin: const EdgeInsets.all(16),
      );
    } finally {
      actionLoading.value = '';
    }
  }

  Future<void> cancelVoucher(String id, String reason) async {
    try {
      actionLoading.value = 'cancel-$id';
      await _repository.cancelVoucher(id, reason);
      Get.snackbar(
        'Success',
        'Voucher cancelled successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.warning.withAlpha(40),
        margin: const EdgeInsets.all(16),
      );
      await loadVouchers();
    } catch (e) {
      Get.snackbar(
        'Error',
        e is AppException ? e.message : 'Failed to cancel voucher.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger.withAlpha(40),
        margin: const EdgeInsets.all(16),
      );
    } finally {
      actionLoading.value = '';
    }
  }

  Future<void> reverseVoucher(String id, String reason) async {
    try {
      actionLoading.value = 'reverse-$id';
      await _repository.reverseVoucher(id, reason);
      Get.snackbar(
        'Success',
        'Voucher reversed successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success.withAlpha(40),
        margin: const EdgeInsets.all(16),
      );
      await loadVouchers();
    } catch (e) {
      Get.snackbar(
        'Error',
        e is AppException ? e.message : 'Failed to reverse voucher.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger.withAlpha(40),
        margin: const EdgeInsets.all(16),
      );
    } finally {
      actionLoading.value = '';
    }
  }
}
