import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/bank_import_models.dart';
import '../repositories/bank_import_repository.dart';
import '../../ledgers/models/accounting_ledger.dart';
import '../../ledgers/repositories/ledger_repository.dart';

class BankImportSettingsController extends GetxController {
  final BankImportRepository _repository;
  final LedgerRepository? _ledgerRepository;

  BankImportSettingsController(this._repository, [this._ledgerRepository]);

  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;

  final Rxn<BankImportSettings> settings = Rxn<BankImportSettings>();

  final RxString defaultBankLedgerId = ''.obs;
  final RxString defaultExpenseLedgerId = ''.obs;
  final RxString defaultIncomeLedgerId = ''.obs;
  final RxBool autoPostHighConfidence = false.obs;
  final RxDouble confidenceThreshold = 0.90.obs;

  final RxList<Map<String, String>> bankMappings = <Map<String, String>>[].obs;
  final RxList<AccountingLedger> allLedgers = <AccountingLedger>[].obs;
  final RxList<AccountingLedger> bankLedgers = <AccountingLedger>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
    try {
      isLoading.value = true;
      await loadLedgers();

      final res = await _repository.fetchSettings();
      settings.value = res;
      defaultBankLedgerId.value = res.defaultBankLedgerId ?? '';
      defaultExpenseLedgerId.value = res.defaultExpenseLedgerId ?? '';
      defaultIncomeLedgerId.value = res.defaultIncomeLedgerId ?? '';
      autoPostHighConfidence.value = res.autoPostHighConfidence;
      confidenceThreshold.value = res.confidenceThreshold;
    } catch (e) {
      Get.log('Failed to load bank import settings dynamically: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadLedgers() async {
    try {
      if (_ledgerRepository != null) {
        final list = await _ledgerRepository.fetchLedgers(status: 'active');
        allLedgers.assignAll(list);
        bankLedgers.assignAll(
          list.where((l) => l.ledgerType == 'BANK').toList(),
        );
      }
    } catch (e) {
      Get.log('Failed to load ledgers in settings dynamically: $e');
    }
  }

  void handleAddMappingRow() {
    bankMappings.add({'keyword': '', 'bankLedgerId': ''});
  }

  void handleRemoveMappingRow(int index) {
    if (index >= 0 && index < bankMappings.length) {
      bankMappings.removeAt(index);
    }
  }

  void handleMappingChange(int index, String field, String value) {
    if (index >= 0 && index < bankMappings.length) {
      final updated = Map<String, String>.from(bankMappings[index]);
      updated[field] = value;
      bankMappings[index] = updated;
    }
  }

  Future<void> saveSettings() async {
    try {
      isSaving.value = true;
      final cleanedMappings = bankMappings
          .where(
            (m) =>
                (m['keyword'] ?? '').trim().isNotEmpty &&
                (m['bankLedgerId'] ?? '').isNotEmpty,
          )
          .map(
            (m) => {
              'keyword': (m['keyword'] ?? '').trim().toUpperCase(),
              'bankLedgerId': m['bankLedgerId']!,
            },
          )
          .toList();

      final payload = {
        'defaultBankLedgerId': defaultBankLedgerId.value,
        'defaultExpenseLedgerId': defaultExpenseLedgerId.value,
        'defaultIncomeLedgerId': defaultIncomeLedgerId.value,
        'autoPostEnabled': autoPostHighConfidence.value,
        'confidenceThreshold': confidenceThreshold.value,
        'bankMappings': cleanedMappings,
      };
      await _repository.saveSettings(payload);
      Get.snackbar(
        'Success',
        'Bank import configuration settings saved successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withAlpha(40),
      );
      await loadSettings();
    } catch (e) {
      Get.log('Failed to save settings dynamically: $e');
      Get.snackbar(
        'Error',
        'Failed to save bank import settings.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withAlpha(40),
      );
    } finally {
      isSaving.value = false;
    }
  }
}
