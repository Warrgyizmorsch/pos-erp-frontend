import '../../../../core/api/api_exceptions.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../services/expense_service.dart';

class ExpenseRepository {
  final ExpenseService _service;

  ExpenseRepository(this._service);

  Future<ExpenseFetchResult> getExpenses({
    int page = 1,
    int limit = 20,
    String? search,
    String? category,
    String? startDate,
    String? endDate,
    String? paymentMethod,
    String? entryType,
    String? status,
  }) async {
    try {
      return await _service.getAll(
        page: page,
        limit: limit,
        search: search,
        category: category,
        startDate: startDate,
        endDate: endDate,
        paymentMethod: paymentMethod,
        entryType: entryType,
        status: status,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fetch Expenses & Income list.');
    }
  }

  Future<Expense> getExpenseById(String id) async {
    try {
      return await _service.getById(id);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fetch expense details.');
    }
  }

  Future<Expense> createExpense(Map<String, dynamic> payload) async {
    try {
      return await _service.create(payload);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to create expense entry.');
    }
  }

  Future<Expense> updateExpense(String id, Map<String, dynamic> payload) async {
    try {
      return await _service.update(id, payload);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to update expense entry.');
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      await _service.delete(id);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to delete expense entry.');
    }
  }

  Future<List<ExpenseCategory>> fetchCategories() async {
    try {
      return await _service.getCategories();
    } catch (e) {
      return [];
    }
  }

  Future<ExpenseCategory> createCategory(Map<String, dynamic> payload) async {
    try {
      return await _service.createCategory(payload);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to create expense category.');
    }
  }

  Future<ExpenseCategory> updateCategory(
    String id,
    Map<String, dynamic> payload,
  ) async {
    try {
      return await _service.updateCategory(id, payload);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to update expense category.');
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _service.deleteCategory(id);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to delete expense category.');
    }
  }

  Future<List<Map<String, dynamic>>> fetchBankAccounts() async {
    try {
      final res = await _service.getBankAccounts();
      return res.data ?? [];
    } catch (e) {
      return [];
    }
  }
}
