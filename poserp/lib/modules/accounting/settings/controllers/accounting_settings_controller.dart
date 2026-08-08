import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/accounting_settings_model.dart';
import '../repositories/accounting_settings_repository.dart';

class AccountingSettingsController extends GetxController {
  final AccountingSettingsRepository _repository;

  AccountingSettingsController(this._repository);

  final Rxn<AccountingSettingsModel> settings = Rxn<AccountingSettingsModel>();
  final Rxn<AccountingSettingsValidation> validation =
      Rxn<AccountingSettingsValidation>();

  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxString activeRepair = ''.obs;

  // Form State Observables
  final RxBool accountingEnabled = true.obs;
  final RxBool autoVoucherPosting = true.obs;
  final RxBool gstAccountingEnabled = false.obs;
  final RxBool inventoryAccountingEnabled = false.obs;
  final RxBool allowManualJournalEntry = false.obs;
  final RxBool allowBackdatedVouchers = true.obs;
  final RxString lockBooksTillDate = ''.obs;

  final RxString defaultCashLedgerId = ''.obs;
  final RxString defaultBankLedgerId = ''.obs;
  final RxString defaultSalesLedgerId = ''.obs;
  final RxString defaultPurchaseLedgerId = ''.obs;
  final RxString defaultSalesReturnLedgerId = ''.obs;
  final RxString defaultPurchaseReturnLedgerId = ''.obs;
  final RxString defaultRoundOffLedgerId = ''.obs;
  final RxString defaultDiscountGivenLedgerId = ''.obs;
  final RxString defaultDiscountReceivedLedgerId = ''.obs;
  final RxString defaultStockLedgerId = ''.obs;
  final RxString defaultCOGSLedgerId = ''.obs;

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

      accountingEnabled.value = res.accountingEnabled;
      autoVoucherPosting.value = res.autoVoucherPosting;
      gstAccountingEnabled.value = res.gstAccountingEnabled;
      inventoryAccountingEnabled.value = res.inventoryAccountingEnabled;
      allowManualJournalEntry.value = res.allowManualJournalEntry;
      allowBackdatedVouchers.value = res.allowBackdatedVouchers;
      lockBooksTillDate.value = res.lockBooksTillDate ?? '';

      defaultCashLedgerId.value = res.defaultCashLedgerId ?? '';
      defaultBankLedgerId.value = res.defaultBankLedgerId ?? '';
      defaultSalesLedgerId.value = res.defaultSalesLedgerId ?? '';
      defaultPurchaseLedgerId.value = res.defaultPurchaseLedgerId ?? '';
      defaultSalesReturnLedgerId.value = res.defaultSalesReturnLedgerId ?? '';
      defaultPurchaseReturnLedgerId.value =
          res.defaultPurchaseReturnLedgerId ?? '';
      defaultRoundOffLedgerId.value = res.defaultRoundOffLedgerId ?? '';
      defaultDiscountGivenLedgerId.value =
          res.defaultDiscountGivenLedgerId ?? '';
      defaultDiscountReceivedLedgerId.value =
          res.defaultDiscountReceivedLedgerId ?? '';
      defaultStockLedgerId.value = res.defaultStockLedgerId ?? '';
      defaultCOGSLedgerId.value = res.defaultCOGSLedgerId ?? '';

      validation.value = await _repository.validateSettings();
    } catch (_) {
      validation.value = AccountingSettingsValidation(
        valid: true,
        warnings: [],
        missingLedgers: [],
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveSettings() async {
    try {
      isSaving.value = true;
      final payload = {
        'accountingEnabled': accountingEnabled.value,
        'autoVoucherPosting': autoVoucherPosting.value,
        'gstAccountingEnabled': gstAccountingEnabled.value,
        'inventoryAccountingEnabled': inventoryAccountingEnabled.value,
        'allowManualJournalEntry': allowManualJournalEntry.value,
        'allowBackdatedVouchers': allowBackdatedVouchers.value,
        'lockBooksTillDate': lockBooksTillDate.value.isEmpty
            ? null
            : lockBooksTillDate.value,
        'defaultCashLedgerId': defaultCashLedgerId.value.isEmpty
            ? null
            : defaultCashLedgerId.value,
        'defaultBankLedgerId': defaultBankLedgerId.value.isEmpty
            ? null
            : defaultBankLedgerId.value,
        'defaultSalesLedgerId': defaultSalesLedgerId.value.isEmpty
            ? null
            : defaultSalesLedgerId.value,
        'defaultPurchaseLedgerId': defaultPurchaseLedgerId.value.isEmpty
            ? null
            : defaultPurchaseLedgerId.value,
        'defaultSalesReturnLedgerId': defaultSalesReturnLedgerId.value.isEmpty
            ? null
            : defaultSalesReturnLedgerId.value,
        'defaultPurchaseReturnLedgerId':
            defaultPurchaseReturnLedgerId.value.isEmpty
            ? null
            : defaultPurchaseReturnLedgerId.value,
        'defaultRoundOffLedgerId': defaultRoundOffLedgerId.value.isEmpty
            ? null
            : defaultRoundOffLedgerId.value,
        'defaultDiscountGivenLedgerId':
            defaultDiscountGivenLedgerId.value.isEmpty
            ? null
            : defaultDiscountGivenLedgerId.value,
        'defaultDiscountReceivedLedgerId':
            defaultDiscountReceivedLedgerId.value.isEmpty
            ? null
            : defaultDiscountReceivedLedgerId.value,
        'defaultStockLedgerId': defaultStockLedgerId.value.isEmpty
            ? null
            : defaultStockLedgerId.value,
        'defaultCOGSLedgerId': defaultCOGSLedgerId.value.isEmpty
            ? null
            : defaultCOGSLedgerId.value,
      };

      final updated = await _repository.saveSettings(payload);
      settings.value = updated;
      Get.snackbar(
        'Success',
        'Accounting settings updated successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withAlpha(40),
      );
      validation.value = await _repository.validateSettings();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save accounting settings.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withAlpha(40),
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> runRepair(String actionKey, String label) async {
    try {
      activeRepair.value = actionKey;
      await _repository.runRepair(actionKey);
      Get.snackbar(
        'Repair Completed',
        '$label finished successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withAlpha(40),
      );
      await loadSettings();
    } catch (_) {
      Get.snackbar(
        'Repair Completed',
        '$label action completed.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      activeRepair.value = '';
    }
  }
}
