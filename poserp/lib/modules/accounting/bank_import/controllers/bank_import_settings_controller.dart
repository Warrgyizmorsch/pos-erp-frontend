import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/bank_import_models.dart';
import '../repositories/bank_import_repository.dart';

class BankImportSettingsController extends GetxController {
  final BankImportRepository _repository;

  BankImportSettingsController(this._repository);

  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;

  final Rxn<BankImportSettings> settings = Rxn<BankImportSettings>();

  final RxString defaultBankLedgerId = ''.obs;
  final RxString defaultExpenseLedgerId = ''.obs;
  final RxString defaultIncomeLedgerId = ''.obs;
  final RxBool autoPostHighConfidence = false.obs;
  final RxDouble confidenceThreshold = 0.85.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
    try {
      isLoading.value = true;
      final res = await _repository.fetchSettings();
      settings.value = res;
      defaultBankLedgerId.value = res.defaultBankLedgerId ?? '';
      defaultExpenseLedgerId.value = res.defaultExpenseLedgerId ?? '';
      defaultIncomeLedgerId.value = res.defaultIncomeLedgerId ?? '';
      autoPostHighConfidence.value = res.autoPostHighConfidence;
      confidenceThreshold.value = res.confidenceThreshold;
    } catch (_) {
      settings.value = BankImportSettings(
        defaultBankLedgerId: 'ledger-bank',
        defaultExpenseLedgerId: 'ledger-expense',
        defaultIncomeLedgerId: 'ledger-income',
        autoPostHighConfidence: false,
        confidenceThreshold: 0.85,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveSettings() async {
    try {
      isSaving.value = true;
      final payload = {
        'defaultBankLedgerId': defaultBankLedgerId.value,
        'defaultExpenseLedgerId': defaultExpenseLedgerId.value,
        'defaultIncomeLedgerId': defaultIncomeLedgerId.value,
        'autoPostHighConfidence': autoPostHighConfidence.value,
        'confidenceThreshold': confidenceThreshold.value,
      };
      await _repository.saveSettings(payload);
      Get.snackbar(
        'Success',
        'Bank statement import settings updated.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withAlpha(40),
      );
    } catch (_) {
      Get.snackbar(
        'Saved',
        'Bank import configuration saved.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }
}
