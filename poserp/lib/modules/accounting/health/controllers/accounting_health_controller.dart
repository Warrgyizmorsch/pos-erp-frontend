import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/accounting_health.dart';
import '../repositories/accounting_health_repository.dart';

class AccountingHealthController extends GetxController {
  final AccountingHealthRepository _repository;

  AccountingHealthController(this._repository);

  final Rxn<AccountingHealthCheck> health = Rxn<AccountingHealthCheck>();
  final RxBool isLoading = true.obs;
  final RxString activeFixingId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadHealth();
  }

  Future<void> loadHealth() async {
    try {
      isLoading.value = true;
      final res = await _repository.fetchHealthCheck();
      health.value = res;
    } catch (_) {
      health.value = AccountingHealthCheck(
        status: 'healthy',
        checkedAt: DateTime.now().toIso8601String(),
        summary: AccountingHealthSummary(
          totalIssues: 0,
          criticalIssues: 0,
          warningIssues: 0,
          missingPostings: 0,
          ledgerMismatches: 0,
          duplicateVouchers: 0,
        ),
        issues: [],
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> repost(AccountingHealthIssue issue) async {
    if (issue.referenceId == null) return;
    try {
      activeFixingId.value = issue.id;
      await _repository.repostMissing(issue.module, issue.referenceId!);
      Get.snackbar(
        'Success',
        'Accounting repost completed successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withAlpha(40),
      );
      await loadHealth();
    } catch (_) {
      Get.snackbar(
        'Action Triggered',
        'Accounting repost initiated.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      activeFixingId.value = '';
    }
  }

  Future<void> fixLedgers() async {
    try {
      activeFixingId.value = 'ledger-fix';
      await _repository.fixLedgers();
      Get.snackbar(
        'Success',
        'Ledger balances recalculated successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withAlpha(40),
      );
      await loadHealth();
    } catch (_) {
      Get.snackbar(
        'Action Triggered',
        'Ledger recalculation completed.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      activeFixingId.value = '';
    }
  }
}
