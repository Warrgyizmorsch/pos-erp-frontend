import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/api/api_exceptions.dart';
import '../../../../core/constants/app_colors.dart';
import '../models/accounting_ledger.dart';
import '../repositories/ledger_repository.dart';

class LedgerListController extends GetxController {
  final LedgerRepository _repository;

  LedgerListController(this._repository);

  final RxList<AccountingLedger> ledgers = <AccountingLedger>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isRestoring = false.obs;

  final RxString searchQuery = ''.obs;
  final RxString selectedGroup = 'ALL'.obs;
  final RxString selectedNature = 'ALL'.obs;
  final RxString selectedLedgerType = 'ALL'.obs;
  final RxString selectedStatus = 'ALL'.obs;

  List<String> get availableGroups => [
    'ALL',
    ...ledgers.map((l) => l.groupName).where((n) => n != '-').toSet(),
  ];

  List<String> get availableTypes => [
    'ALL',
    ...ledgers.map((l) => l.ledgerType).toSet(),
  ];

  @override
  void onInit() {
    super.onInit();
    loadLedgers();

    debounce(
      searchQuery,
      (_) => loadLedgers(),
      time: const Duration(milliseconds: 300),
    );
    ever(selectedGroup, (_) => loadLedgers());
    ever(selectedNature, (_) => loadLedgers());
    ever(selectedLedgerType, (_) => loadLedgers());
    ever(selectedStatus, (_) => loadLedgers());
  }

  Future<void> loadLedgers() async {
    try {
      isLoading.value = true;
      final result = await _repository.fetchLedgers(
        search: searchQuery.value,
        group: selectedGroup.value,
        nature: selectedNature.value,
        ledgerType: selectedLedgerType.value,
        status: selectedStatus.value,
      );
      ledgers.assignAll(result);
    } catch (_) {
      ledgers.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> restoreDefaults() async {
    try {
      isRestoring.value = true;
      await _repository.restoreDefaults();
      Get.snackbar(
        'Success',
        'Default system ledgers restored successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      loadLedgers();
    } catch (e) {
      Get.snackbar(
        'Error',
        e is AppException ? e.message : 'Failed to restore default ledgers.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isRestoring.value = false;
    }
  }
}
