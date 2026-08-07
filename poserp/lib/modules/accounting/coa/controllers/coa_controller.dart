import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/api/api_exceptions.dart';
import '../../../../core/constants/app_colors.dart';
import '../models/accounting_status.dart';
import '../models/chart_group.dart';
import '../repositories/coa_repository.dart';

class COAController extends GetxController {
  final COARepository _repository;

  COAController(this._repository);

  final Rxn<AccountingStatus> status = Rxn<AccountingStatus>();
  final RxList<ChartGroup> chartGroups = <ChartGroup>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isInitializing = false.obs;
  final RxString searchQuery = ''.obs;

  int get assetGroupsCount =>
      chartGroups.where((g) => g.nature.toLowerCase().contains('asset')).length;

  int get liabilityGroupsCount =>
      chartGroups.where((g) => g.nature.toLowerCase().contains('liab')).length;

  int get equityGroupsCount => chartGroups
      .where((g) => g.nature.toLowerCase().contains('equity'))
      .length;

  int get incomeExpenseGroupsCount => chartGroups
      .where(
        (g) =>
            g.nature.toLowerCase().contains('income') ||
            g.nature.toLowerCase().contains('revenue') ||
            g.nature.toLowerCase().contains('expense'),
      )
      .length;

  @override
  void onInit() {
    super.onInit();
    loadData();

    debounce(searchQuery, (_) {}, time: const Duration(milliseconds: 300));
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      final st = await _repository.fetchStatus();
      status.value = st;

      final groups = await _repository.fetchChartOfAccounts();
      chartGroups.assignAll(groups);
    } catch (_) {
      chartGroups.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> initializeEngine() async {
    try {
      isInitializing.value = true;
      await _repository.initializeEngine();
      Get.snackbar(
        'Success',
        'Accounting Engine initialized with standard Chart of Accounts.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      loadData();
    } catch (e) {
      Get.snackbar(
        'Error',
        e is AppException
            ? e.message
            : 'Failed to initialize Accounting Engine.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isInitializing.value = false;
    }
  }
}
