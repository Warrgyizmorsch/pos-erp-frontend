import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/api/api_exceptions.dart';
import '../../../../core/constants/app_colors.dart';
import '../models/bank_account.dart';
import '../models/cash_bank_summary.dart';
import '../models/cash_bank_transaction.dart';
import '../repositories/cash_bank_repository.dart';

class CashBankController extends GetxController {
  final CashBankRepository _repository;

  CashBankController(this._repository);

  // Observable States
  final RxList<BankAccount> bankAccounts = <BankAccount>[].obs;
  final RxList<CashBankTransaction> transactions = <CashBankTransaction>[].obs;
  final Rxn<CashBankSummary> summary = Rxn<CashBankSummary>();

  final RxBool isLoadingAccounts = true.obs;
  final RxBool isLoadingTransactions = true.obs;
  final RxBool isSubmitting = false.obs;

  // Filters & Pagination
  final RxString searchQuery = ''.obs;
  final RxString typeFilter = 'all'.obs;
  final RxString selectedAccountId = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final int itemsPerPage = 20;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();

    debounce(searchQuery, (_) {
      currentPage.value = 1;
      loadTransactions();
    }, time: const Duration(milliseconds: 300));

    ever(typeFilter, (_) {
      currentPage.value = 1;
      loadTransactions();
    });

    ever(selectedAccountId, (_) {
      currentPage.value = 1;
      loadTransactions();
    });
  }

  Future<void> loadDashboardData() async {
    loadBankAccounts();
    loadSummary();
    loadTransactions();
  }

  Future<void> loadBankAccounts() async {
    try {
      isLoadingAccounts.value = true;
      final accs = await _repository.fetchBankAccounts();
      bankAccounts.assignAll(accs);
    } catch (_) {
      bankAccounts.clear();
    } finally {
      isLoadingAccounts.value = false;
    }
  }

  Future<void> loadSummary() async {
    try {
      final s = await _repository.fetchSummary();
      summary.value = s;
    } catch (_) {}
  }

  Future<void> loadTransactions() async {
    try {
      isLoadingTransactions.value = true;
      final res = await _repository.fetchTransactions(
        page: currentPage.value,
        limit: itemsPerPage,
        search: searchQuery.value,
        type: typeFilter.value,
        accountId: selectedAccountId.value,
      );

      transactions.assignAll(res.data);
      if (res.pagination != null) {
        totalPages.value = res.pagination!.pages;
      } else {
        totalPages.value = 1;
      }
    } catch (e) {
      transactions.clear();
    } finally {
      isLoadingTransactions.value = false;
    }
  }

  Future<bool> saveBankAccount({
    String? id,
    required String accountName,
    required String accountNumber,
    required String ifscCode,
    required double openingBalance,
    String? bankName,
    String? branch,
  }) async {
    if (accountName.trim().isEmpty) {
      showErrorSnackbar('Please enter Account Name.');
      return false;
    }
    if (accountNumber.trim().isEmpty) {
      showErrorSnackbar('Please enter Account Number.');
      return false;
    }
    if (ifscCode.trim().isEmpty) {
      showErrorSnackbar('Please enter IFSC Code.');
      return false;
    }

    try {
      isSubmitting.value = true;
      final payload = {
        'accountName': accountName.trim(),
        'accountNumber': accountNumber.trim(),
        'ifscCode': ifscCode.trim().toUpperCase(),
        'openingBalance': openingBalance,
        if (bankName != null && bankName.isNotEmpty)
          'bankName': bankName.trim(),
        if (branch != null && branch.isNotEmpty) 'branch': branch.trim(),
      };

      if (id != null && id.isNotEmpty) {
        await _repository.updateBankAccount(id, payload);
        Get.snackbar(
          'Success',
          'Bank Account updated successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      } else {
        await _repository.createBankAccount(payload);
        Get.snackbar(
          'Success',
          'Bank Account created successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      }

      loadBankAccounts();
      loadSummary();
      return true;
    } catch (e) {
      showErrorSnackbar(
        e is AppException ? e.message : 'Failed to save Bank Account.',
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> deleteBankAccount(String id) async {
    try {
      await _repository.deleteBankAccount(id);
      Get.snackbar(
        'Success',
        'Bank Account deleted successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      loadBankAccounts();
      loadSummary();
      return true;
    } catch (e) {
      showErrorSnackbar(
        e is AppException ? e.message : 'Failed to delete Bank Account.',
      );
      return false;
    }
  }

  Future<bool> recordCashEntry({
    required String type, // 'deposit' or 'withdrawal'
    required double amount,
    required String date,
    String? remarks,
  }) async {
    if (amount <= 0) {
      showErrorSnackbar('Amount must be greater than 0.');
      return false;
    }

    try {
      isSubmitting.value = true;
      await _repository.createCashEntry({
        'type': type,
        'amount': amount,
        'date': date,
        if (remarks != null && remarks.isNotEmpty) 'remarks': remarks.trim(),
      });

      Get.snackbar(
        'Success',
        'Cash entry recorded successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );

      loadDashboardData();
      return true;
    } catch (e) {
      showErrorSnackbar(
        e is AppException ? e.message : 'Failed to record Cash Entry.',
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> recordBankTransfer({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    required String date,
    String? referenceNo,
    String? remarks,
  }) async {
    if (fromAccountId == toAccountId) {
      showErrorSnackbar('Source and Destination accounts must be different.');
      return false;
    }
    if (amount <= 0) {
      showErrorSnackbar('Amount must be greater than 0.');
      return false;
    }

    try {
      isSubmitting.value = true;
      await _repository.createBankTransfer({
        'fromAccountId': fromAccountId,
        'toAccountId': toAccountId,
        'amount': amount,
        'date': date,
        if (referenceNo != null && referenceNo.isNotEmpty)
          'referenceNo': referenceNo.trim(),
        if (remarks != null && remarks.isNotEmpty) 'remarks': remarks.trim(),
      });

      Get.snackbar(
        'Success',
        'Bank transfer recorded successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );

      loadDashboardData();
      return true;
    } catch (e) {
      showErrorSnackbar(
        e is AppException ? e.message : 'Failed to record Bank Transfer.',
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages.value) {
      currentPage.value = page;
      loadTransactions();
    }
  }

  void showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.danger,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }
}
