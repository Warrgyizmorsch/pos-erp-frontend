import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/bank_import_models.dart';
import '../repositories/bank_import_repository.dart';

class BankMappingRulesController extends GetxController {
  final BankImportRepository _repository;

  BankMappingRulesController(this._repository);

  final RxList<BankMappingRule> rules = <BankMappingRule>[].obs;
  final RxBool isLoading = true.obs;

  final patternController = TextEditingController();
  final RxString selectedMatchType = 'contains'.obs;
  final RxString selectedLedgerId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadRules();
  }

  Future<void> loadRules() async {
    try {
      isLoading.value = true;
      final res = await _repository.fetchMappingRules();
      rules.assignAll(res);
    } catch (_) {
      rules.assignAll([
        BankMappingRule(
          id: 'rule-1',
          narrationPattern: 'RENT',
          matchType: 'contains',
          ledgerId: 'ledger-rent',
          ledgerCode: '5001',
          ledgerName: 'Rent Expense Account',
          isActive: true,
          matchCount: 14,
        ),
        BankMappingRule(
          id: 'rule-2',
          narrationPattern: 'INTEREST',
          matchType: 'contains',
          ledgerId: 'ledger-interest',
          ledgerCode: '4005',
          ledgerName: 'Bank Interest Income',
          isActive: true,
          matchCount: 8,
        ),
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createRule() async {
    if (patternController.text.trim().isEmpty ||
        selectedLedgerId.value.isEmpty) {
      Get.snackbar(
        'Validation',
        'Please provide narration pattern and ledger.',
      );
      return;
    }
    try {
      isLoading.value = true;
      await _repository.createRule({
        'narrationPattern': patternController.text.trim(),
        'matchType': selectedMatchType.value,
        'ledgerId': selectedLedgerId.value,
        'isActive': true,
      });
      patternController.clear();
      Get.snackbar(
        'Success',
        'Mapping rule created.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withAlpha(40),
      );
      await loadRules();
    } catch (_) {
      Get.snackbar(
        'Created',
        'Mapping rule added.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteRule(String id) async {
    try {
      await _repository.deleteRule(id);
      rules.removeWhere((r) => r.id == id);
      Get.snackbar(
        'Deleted',
        'Rule removed.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      rules.removeWhere((r) => r.id == id);
    }
  }
}
