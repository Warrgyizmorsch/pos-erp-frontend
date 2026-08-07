import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../data/models/api_response.dart';
import '../../../../data/models/pagination.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';

class ExpenseFetchResult {
  final List<Expense> data;
  final Pagination? pagination;

  ExpenseFetchResult({required this.data, this.pagination});
}

class ExpenseService {
  final ApiClient _apiClient;

  ExpenseService(this._apiClient);

  Future<ExpenseFetchResult> getAll({
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
    final Map<String, dynamic> queryParams = {'page': page, 'limit': limit};
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }
    if (category != null && category.trim().isNotEmpty && category != 'all') {
      queryParams['category'] = category;
    }
    if (startDate != null && startDate.trim().isNotEmpty) {
      queryParams['startDate'] = startDate;
    }
    if (endDate != null && endDate.trim().isNotEmpty) {
      queryParams['endDate'] = endDate;
    }
    if (paymentMethod != null &&
        paymentMethod.trim().isNotEmpty &&
        paymentMethod != 'all') {
      queryParams['paymentMethod'] = paymentMethod;
    }
    if (entryType != null &&
        entryType.trim().isNotEmpty &&
        entryType != 'all') {
      queryParams['entryType'] = entryType;
    }
    if (status != null && status.trim().isNotEmpty && status != 'all') {
      queryParams['status'] = status;
    }

    try {
      final response = await _apiClient.get(
        ApiEndpoints.expenses,
        queryParameters: queryParams,
      );

      List list = [];
      Pagination? pagination;

      if (response.data is Map<String, dynamic>) {
        final Map<String, dynamic> body = response.data as Map<String, dynamic>;
        if (body['data'] != null) {
          if (body['data'] is List) {
            list = body['data'] as List;
          } else if (body['data'] is Map<String, dynamic> &&
              body['data']['expenses'] is List) {
            list = body['data']['expenses'] as List;
          }
        } else if (body['expenses'] is List) {
          list = body['expenses'] as List;
        }

        if (body['pagination'] != null &&
            body['pagination'] is Map<String, dynamic>) {
          pagination = Pagination.fromJson(
            body['pagination'] as Map<String, dynamic>,
          );
        }
      } else if (response.data is List) {
        list = response.data as List;
      }

      final expenses = <Expense>[];
      for (final item in list) {
        if (item is Map<String, dynamic>) {
          try {
            expenses.add(Expense.fromJson(item));
          } catch (_) {}
        }
      }

      return ExpenseFetchResult(data: expenses, pagination: pagination);
    } catch (_) {
      return ExpenseFetchResult(data: [], pagination: null);
    }
  }

  Future<Expense> getById(String id) async {
    final response = await _apiClient.get('${ApiEndpoints.expenses}/$id');
    final Map<String, dynamic> body = response.data as Map<String, dynamic>;
    final data = body['data'] ?? body;
    return Expense.fromJson(data as Map<String, dynamic>);
  }

  Future<Expense> create(Map<String, dynamic> payload) async {
    final response = await _apiClient.post(
      ApiEndpoints.expenses,
      data: payload,
    );
    final Map<String, dynamic> body = response.data as Map<String, dynamic>;
    final data = body['data'] ?? body;
    return Expense.fromJson(data as Map<String, dynamic>);
  }

  Future<Expense> update(String id, Map<String, dynamic> payload) async {
    final response = await _apiClient.put(
      '${ApiEndpoints.expenses}/$id',
      data: payload,
    );
    final Map<String, dynamic> body = response.data as Map<String, dynamic>;
    final data = body['data'] ?? body;
    return Expense.fromJson(data as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    await _apiClient.delete('${ApiEndpoints.expenses}/$id');
  }

  // Expense Categories
  Future<List<ExpenseCategory>> getCategories() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.expenseCategories);
      List list = [];
      if (response.data is Map<String, dynamic>) {
        final Map<String, dynamic> body = response.data as Map<String, dynamic>;
        list = body['data'] as List? ?? [];
      } else if (response.data is List) {
        list = response.data as List;
      }

      final categories = <ExpenseCategory>[];
      for (final item in list) {
        if (item is Map<String, dynamic>) {
          try {
            categories.add(ExpenseCategory.fromJson(item));
          } catch (_) {}
        }
      }
      return categories;
    } catch (_) {
      return [];
    }
  }

  Future<ExpenseCategory> createCategory(Map<String, dynamic> payload) async {
    final response = await _apiClient.post(
      ApiEndpoints.expenseCategories,
      data: payload,
    );
    final Map<String, dynamic> body = response.data as Map<String, dynamic>;
    final data = body['data'] ?? body;
    return ExpenseCategory.fromJson(data as Map<String, dynamic>);
  }

  Future<ExpenseCategory> updateCategory(
    String id,
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.put(
      '${ApiEndpoints.expenseCategories}/$id',
      data: payload,
    );
    final Map<String, dynamic> body = response.data as Map<String, dynamic>;
    final data = body['data'] ?? body;
    return ExpenseCategory.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteCategory(String id) async {
    await _apiClient.delete('${ApiEndpoints.expenseCategories}/$id');
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getBankAccounts() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.bank);
      List list = [];
      if (response.data is Map<String, dynamic>) {
        final Map<String, dynamic> body = response.data as Map<String, dynamic>;
        list = body['data'] as List? ?? [];
      } else if (response.data is List) {
        list = response.data as List;
      }
      return ApiResponse<List<Map<String, dynamic>>>(
        success: true,
        data: list.whereType<Map<String, dynamic>>().toList(),
      );
    } catch (_) {
      return ApiResponse<List<Map<String, dynamic>>>(success: true, data: []);
    }
  }
}
