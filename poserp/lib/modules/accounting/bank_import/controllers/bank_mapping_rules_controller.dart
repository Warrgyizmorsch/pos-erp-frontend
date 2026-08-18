import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/bank_import_models.dart';
import '../repositories/bank_import_repository.dart';
import '../../ledgers/models/accounting_ledger.dart';
import '../../ledgers/repositories/ledger_repository.dart';

class BankMappingRulesController extends GetxController {
  final BankImportRepository _repository;
  final LedgerRepository? _ledgerRepository;

  BankMappingRulesController(this._repository, [this._ledgerRepository]);

  final RxList<BankMappingRule> rules = <BankMappingRule>[].obs;
  final RxList<AccountingLedger> availableLedgers = <AccountingLedger>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;

  final patternController = TextEditingController();
  final confidenceController = TextEditingController(text: '100');
  final RxString selectedMatchType = 'contains'.obs;
  final RxString selectedLedgerId = ''.obs;
  final Rxn<BankMappingRule> editingRule = Rxn<BankMappingRule>();

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      await Future.wait([loadRules(), loadLedgers()]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadLedgers() async {
    try {
      if (_ledgerRepository != null) {
        final list = await _ledgerRepository.fetchLedgers(status: 'active');
        availableLedgers.assignAll(list);
      }
    } catch (e) {
      Get.log('Failed to load active ledgers dynamically: $e');
    }
  }

  Future<void> loadRules() async {
    try {
      final res = await _repository.fetchMappingRules();
      rules.assignAll(res);
    } catch (e) {
      Get.log('Failed to load mapping rules dynamically: $e');
    }
  }

  void prepareCreate() {
    editingRule.value = null;
    patternController.clear();
    confidenceController.text = '100';
    selectedMatchType.value = 'contains';
    selectedLedgerId.value = '';
  }

  void prepareEdit(BankMappingRule rule) {
    editingRule.value = rule;
    patternController.text = rule.narrationPattern;
    confidenceController.text = rule.confidence.toInt().toString();
    selectedMatchType.value = rule.matchType;
    selectedLedgerId.value = rule.ledgerId;
  }

  Future<void> saveRule() async {
    final patternText = patternController.text.trim().toUpperCase();
    if (patternText.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please enter a narration pattern',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (selectedLedgerId.value.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please select a target ledger account',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isSaving.value = true;
      final payload = {
        'pattern': patternText,
        'ledgerId': selectedLedgerId.value,
        'confidence': double.tryParse(confidenceController.text) ?? 100.0,
        'matchType': selectedMatchType.value,
      };

      if (editingRule.value != null) {
        // Edit mode
        final ruleId = editingRule.value!.id;
        final savedRule = await _repository.createRule({
          ...payload,
          '_id': ruleId,
        });
        rules.removeWhere((r) => r.id == ruleId);
        rules.insert(0, savedRule);
        Get.snackbar(
          'Success',
          'Mapping rule updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withAlpha(40),
        );
      } else {
        // Create mode
        final newRule = await _repository.createRule(payload);
        rules.insert(0, newRule);
        Get.snackbar(
          'Success',
          'Mapping rule created successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withAlpha(40),
        );
      }
      await loadRules();
    } catch (e) {
      Get.log('Failed to save mapping rule: $e');
      Get.snackbar(
        'Error',
        'Failed to save mapping rule. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withAlpha(40),
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteRule(String id) async {
    try {
      await _repository.deleteRule(id);
      rules.removeWhere((r) => r.id == id);
      Get.snackbar(
        'Deleted',
        'Mapping rule deleted successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.log('Failed to delete mapping rule: $e');
      Get.snackbar(
        'Error',
        'Failed to delete mapping rule.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withAlpha(40),
      );
    }
  }
}
