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
  final RxString selectedNature =
      'ALL'.obs; // ALL, ASSET, LIABILITY, INCOME, EXPENSE

  int get assetGroupsCount =>
      chartGroups.where((g) => g.nature.toUpperCase().contains('ASSET')).length;

  int get liabilityGroupsCount =>
      chartGroups.where((g) => g.nature.toUpperCase().contains('LIAB')).length;

  int get equityGroupsCount => chartGroups
      .where((g) => g.nature.toUpperCase().contains('EQUITY'))
      .length;

  int get incomeExpenseGroupsCount => chartGroups
      .where(
        (g) =>
            g.nature.toUpperCase().contains('INCOME') ||
            g.nature.toUpperCase().contains('REVENUE') ||
            g.nature.toUpperCase().contains('EXPENSE'),
      )
      .length;

  List<ChartGroup> get filteredChartGroups {
    final query = searchQuery.value.trim().toLowerCase();
    final nature = selectedNature.value.toUpperCase();

    if (query.isEmpty && nature == 'ALL') {
      return chartGroups;
    }

    ChartGroup? filterNode(ChartGroup group) {
      final natureMatches = nature == 'ALL' || group.nature.contains(nature);
      final groupMatches =
          query.isEmpty ||
          group.name.toLowerCase().contains(query) ||
          group.code.toLowerCase().contains(query);

      final filteredLedgers = group.ledgers
          .where(
            (l) =>
                query.isEmpty ||
                l.name.toLowerCase().contains(query) ||
                l.code.toLowerCase().contains(query),
          )
          .toList();

      final filteredChildren = group.subgroups
          .map((child) => filterNode(child))
          .whereType<ChartGroup>()
          .toList();

      if ((natureMatches && groupMatches) ||
          filteredLedgers.isNotEmpty ||
          filteredChildren.isNotEmpty) {
        return ChartGroup(
          id: group.id,
          code: group.code,
          name: group.name,
          nature: group.nature,
          normalBalance: group.normalBalance,
          isSystem: group.isSystem,
          affectsGrossProfit: group.affectsGrossProfit,
          isActive: group.isActive,
          parent: group.parent,
          subgroups: filteredChildren,
          ledgers: filteredLedgers,
        );
      }

      return null;
    }

    return chartGroups
        .map((g) => filterNode(g))
        .whereType<ChartGroup>()
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadData();
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
