import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/api/api_exceptions.dart';
import '../../../../core/constants/app_colors.dart';
import '../../ledgers/models/accounting_ledger.dart';
import '../../ledgers/repositories/ledger_repository.dart';
import '../repositories/voucher_repository.dart';

class JournalRowItem {
  final String id;
  String ledgerId;
  final TextEditingController debitController;
  final TextEditingController creditController;
  final TextEditingController narrationController;

  JournalRowItem({
    required this.id,
    this.ledgerId = '',
    String debit = '',
    String credit = '',
    String narration = '',
  }) : debitController = TextEditingController(text: debit),
       creditController = TextEditingController(text: credit),
       narrationController = TextEditingController(text: narration);

  void dispose() {
    debitController.dispose();
    creditController.dispose();
    narrationController.dispose();
  }
}

class JournalFormController extends GetxController {
  final VoucherRepository _voucherRepository;
  final LedgerRepository _ledgerRepository;

  JournalFormController(this._voucherRepository, this._ledgerRepository);

  final RxList<AccountingLedger> ledgers = <AccountingLedger>[].obs;
  final RxList<JournalRowItem> rows = <JournalRowItem>[].obs;
  final RxBool isLoadingLedgers = true.obs;
  final RxBool isSubmitting = false.obs;

  final TextEditingController dateController = TextEditingController(
    text: DateTime.now().toIso8601String().split('T')[0],
  );
  final TextEditingController narrationController = TextEditingController();

  final RxDouble totalDebit = 0.0.obs;
  final RxDouble totalCredit = 0.0.obs;
  final RxDouble difference = 0.0.obs;
  final RxBool isBalanced = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadLedgers();
    // Initialize 2 rows
    addRow();
    addRow();
  }

  @override
  void onClose() {
    for (final row in rows) {
      row.dispose();
    }
    dateController.dispose();
    narrationController.dispose();
    super.onClose();
  }

  Future<void> loadLedgers() async {
    try {
      isLoadingLedgers.value = true;
      final result = await _ledgerRepository.fetchLedgers(status: 'ACTIVE');
      ledgers.assignAll(result);
    } catch (_) {
      ledgers.clear();
    } finally {
      isLoadingLedgers.value = false;
    }
  }

  void addRow() {
    final row = JournalRowItem(
      id: '${DateTime.now().millisecondsSinceEpoch}-${rows.length}',
    );
    row.debitController.addListener(recalculateTotals);
    row.creditController.addListener(recalculateTotals);
    rows.add(row);
    recalculateTotals();
  }

  void removeRow(String id) {
    if (rows.length <= 2) {
      Get.snackbar(
        'Warning',
        'At least two entries are required for a double-entry journal voucher.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.warning,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }
    final index = rows.indexWhere((r) => r.id == id);
    if (index != -1) {
      final item = rows.removeAt(index);
      item.dispose();
      recalculateTotals();
    }
  }

  void recalculateTotals() {
    double dTot = 0.0;
    double cTot = 0.0;

    for (final r in rows) {
      final d = double.tryParse(r.debitController.text) ?? 0.0;
      final c = double.tryParse(r.creditController.text) ?? 0.0;
      dTot += d;
      cTot += c;
    }

    totalDebit.value = dTot;
    totalCredit.value = cTot;
    final diff = (dTot - cTot).abs();
    difference.value = diff;
    isBalanced.value = dTot > 0.0 && diff < 0.009;
  }

  String? validateForm() {
    if (rows.length < 2) return 'At least two entries are required';
    for (final row in rows) {
      if (row.ledgerId.isEmpty) return 'Please select a ledger for all rows';
      final d = double.tryParse(row.debitController.text) ?? 0.0;
      final c = double.tryParse(row.creditController.text) ?? 0.0;
      if (d <= 0.0 && c <= 0.0) {
        return 'Each row needs a debit or credit amount';
      }
      if (d > 0.0 && c > 0.0) {
        return 'Debit and credit cannot both be entered in the same row';
      }
    }
    if (!isBalanced.value) return 'Voucher is not balanced (Debit != Credit)';
    return null;
  }

  Future<void> submit(String mode) async {
    final err = validateForm();
    if (err != null) {
      Get.snackbar(
        'Validation Error',
        err,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    try {
      isSubmitting.value = true;
      final payload = {
        'date': dateController.text,
        'narration': narrationController.text,
        'entries': rows.map((r) {
          final d = double.tryParse(r.debitController.text) ?? 0.0;
          final c = double.tryParse(r.creditController.text) ?? 0.0;
          return {
            'ledgerId': r.ledgerId,
            'debit': d,
            'credit': c,
            'narration': r.narrationController.text,
          };
        }).toList(),
      };

      if (mode == 'draft') {
        await _voucherRepository.saveJournalDraft(payload);
        Get.snackbar(
          'Success',
          'Draft journal voucher saved successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      } else {
        await _voucherRepository.postJournalVoucher(payload);
        Get.snackbar(
          'Success',
          'Journal voucher posted successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      }
      Get.back();
    } catch (e) {
      Get.snackbar(
        'Error',
        e is AppException ? e.message : 'Journal voucher submission failed.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.danger,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isSubmitting.value = false;
    }
  }
}
