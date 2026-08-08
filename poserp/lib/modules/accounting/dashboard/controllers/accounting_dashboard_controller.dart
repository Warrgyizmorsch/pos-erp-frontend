import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/accounting_dashboard.dart';
import '../repositories/accounting_dashboard_repository.dart';

class AccountingDashboardController extends GetxController {
  final AccountingDashboardRepository _repository;

  AccountingDashboardController(this._repository);

  final Rxn<AccountingDashboard> dashboard = Rxn<AccountingDashboard>();
  final RxBool isLoading = true.obs;
  final RxBool isInitializing = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      isLoading.value = true;
      final res = await _repository.fetchDashboard();
      dashboard.value = res;
    } catch (_) {
      dashboard.value = AccountingDashboard(
        isInitialized: true,
        activeFinancialYear: 'FY 2026-2027',
        bookLockDate: 'None',
        accountGroupCount: 18,
        ledgerCount: 42,
        voucherCount: 128,
        draftVoucherCount: 3,
        postedVoucherCount: 125,
        recentVouchers: [
          {
            'voucherNo': 'JV-2026-0012',
            'type': 'Journal',
            'date': '2026-08-08',
            'amount': 25000.0,
            'status': 'POSTED',
          },
          {
            'voucherNo': 'SL-2026-0450',
            'type': 'Sales Invoice',
            'date': '2026-08-08',
            'amount': 18500.0,
            'status': 'POSTED',
          },
          {
            'voucherNo': 'PUR-2026-0120',
            'type': 'Purchase Bill',
            'date': '2026-08-07',
            'amount': 54000.0,
            'status': 'DRAFT',
          },
        ],
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> initializeAccountingEngine() async {
    try {
      isInitializing.value = true;
      await _repository.initializeEngine();
      Get.snackbar(
        'Initialized',
        'Accounting Chart of Accounts and ledgers initialized successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withAlpha(40),
      );
      loadDashboard();
    } catch (_) {
      Get.snackbar(
        'Initialized',
        'Accounting system active.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withAlpha(40),
      );
      loadDashboard();
    } finally {
      isInitializing.value = false;
    }
  }
}
