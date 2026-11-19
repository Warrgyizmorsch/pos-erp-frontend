import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/api/api_exceptions.dart';
import '../../../../core/constants/app_colors.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../repositories/expense_repository.dart';

class ExpenseController extends GetxController {
  final ExpenseRepository _repository;

  ExpenseController(this._repository);

  final RxList<Expense> expenses = <Expense>[].obs;
  final RxList<ExpenseCategory> categories = <ExpenseCategory>[].obs;
  final RxList<Map<String, dynamic>> bankAccounts =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoadingList = true.obs;
  final RxBool isLoadingCategories = false.obs;

  final RxString searchQuery = ''.obs;
  final RxString categoryFilter = 'all'.obs;
  final RxString entryTypeFilter = 'all'.obs;
  final RxString paymentMethodFilter = 'all'.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final int itemsPerPage = 20;

  final RxBool isSubmitting = false.obs;

  double get totalExpenses => expenses.fold(
    0.0,
    (sum, e) => e.entryType == 'expense' && e.status != 'cancelled'
        ? sum + e.amount
        : sum,
  );

  double get totalIncome => expenses.fold(
    0.0,
    (sum, e) => e.entryType == 'income' && e.status != 'cancelled'
        ? sum + e.amount
        : sum,
  );

  double get netAmount => totalIncome - totalExpenses;

  @override
  void onInit() {
    super.onInit();
    loadExpenses();
    loadCategories();
    loadBankAccounts();

    debounce(searchQuery, (_) {
      currentPage.value = 1;
      loadExpenses();
    }, time: const Duration(milliseconds: 300));

    ever(categoryFilter, (_) {
      currentPage.value = 1;
      loadExpenses();
    });

    ever(entryTypeFilter, (_) {
      currentPage.value = 1;
      loadExpenses();
    });

    ever(paymentMethodFilter, (_) {
      currentPage.value = 1;
      loadExpenses();
    });
  }

  Future<void> loadExpenses() async {
    try {
      isLoadingList.value = true;
      final result = await _repository.getExpenses(
        page: currentPage.value,
        limit: itemsPerPage,
        search: searchQuery.value,
        category: categoryFilter.value,
        entryType: entryTypeFilter.value,
        paymentMethod: paymentMethodFilter.value,
      );

      expenses.assignAll(result.data);
      if (result.pagination != null) {
        totalPages.value = result.pagination!.pages;
      } else {
        totalPages.value = 1;
      }
    } catch (e) {
      expenses.clear();
      showErrorSnackbar(
        e is AppException ? e.message : 'Failed to load expenses list.',
      );
    } finally {
      isLoadingList.value = false;
    }
  }

  Future<void> loadCategories() async {
    try {
      isLoadingCategories.value = true;
      final cats = await _repository.fetchCategories();
      categories.assignAll(cats);
    } catch (_) {
      categories.clear();
    } finally {
      isLoadingCategories.value = false;
    }
  }

  Future<void> loadBankAccounts() async {
    try {
      final banks = await _repository.fetchBankAccounts();
      bankAccounts.assignAll(banks);
    } catch (_) {}
  }

  Future<bool> createExpense({
    required String title,
    required double amount,
    String? categoryId,
    required String categoryName,
    required String date,
    required String paymentMethod,
    String? cashBankAccountId,
    String? referenceNo,
    String? description,
    required String entryType,
  }) async {
    if (title.trim().isEmpty) {
      showErrorSnackbar('Please enter expense / income title.');
      return false;
    }
    if (amount <= 0) {
      showErrorSnackbar('Please enter a valid amount greater than 0.');
      return false;
    }

    try {
      isSubmitting.value = true;
      final payload = {
        'title': title.trim(),
        'amount': amount,
        if (categoryId != null && categoryId.isNotEmpty) 'category': categoryId,
        'categoryName': categoryName,
        'date': date,
        'paymentMethod': paymentMethod,
        if (paymentMethod.toLowerCase() != 'cash' &&
            cashBankAccountId != null &&
            cashBankAccountId.isNotEmpty)
          'cashBankAccountId': cashBankAccountId,
        if (referenceNo != null && referenceNo.isNotEmpty)
          'referenceNo': referenceNo.trim(),
        if (description != null && description.isNotEmpty)
          'description': description.trim(),
        'entryType': entryType,
      };

      await _repository.createExpense(payload);

      Get.snackbar(
        'Success',
        '${entryType == 'expense' ? 'Expense' : 'Income'} entry created successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );

      loadExpenses();
      return true;
    } catch (e) {
      showErrorSnackbar(
        e is AppException ? e.message : 'Failed to save expense entry.',
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> deleteExpense(String id) async {
    try {
      await _repository.deleteExpense(id);
      Get.snackbar(
        'Success',
        'Expense entry deleted successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      loadExpenses();
      return true;
    } catch (e) {
      showErrorSnackbar(
        e is AppException ? e.message : 'Failed to delete expense entry.',
      );
      return false;
    }
  }

  Future<bool> createCategory(String name, String? description) async {
    if (name.trim().isEmpty) {
      showErrorSnackbar('Please enter a category name.');
      return false;
    }

    try {
      await _repository.createCategory({
        'name': name.trim(),
        if (description != null && description.isNotEmpty)
          'description': description.trim(),
      });

      Get.snackbar(
        'Success',
        'Expense category created successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );

      loadCategories();
      return true;
    } catch (e) {
      showErrorSnackbar(
        e is AppException ? e.message : 'Failed to create category.',
      );
      return false;
    }
  }

  Future<bool> deleteCategory(String id) async {
    try {
      await _repository.deleteCategory(id);
      Get.snackbar(
        'Success',
        'Category deleted successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      loadCategories();
      return true;
    } catch (e) {
      showErrorSnackbar(
        e is AppException ? e.message : 'Failed to delete category.',
      );
      return false;
    }
  }

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages.value) {
      currentPage.value = page;
      loadExpenses();
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
