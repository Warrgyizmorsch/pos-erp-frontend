import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../data/models/pagination.dart';
import '../models/sale.dart';

class SaleFetchResult {
  final List<Sale> data;
  final SaleTotals totals;
  final Pagination? pagination;

  SaleFetchResult({required this.data, required this.totals, this.pagination});
}

class SaleService {
  final ApiClient _apiClient;

  SaleService(this._apiClient);

  Future<SaleFetchResult> getAll({
    int page = 1,
    int limit = 20,
    String? search,
    String? paymentMethod,
    String? startDate,
    String? endDate,
  }) async {
    final Map<String, dynamic> queryParams = {'page': page, 'limit': limit};

    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }
    if (paymentMethod != null &&
        paymentMethod != 'all' &&
        paymentMethod.isNotEmpty) {
      queryParams['paymentMethod'] = paymentMethod;
    }
    if (startDate != null && startDate.isNotEmpty) {
      queryParams['startDate'] = startDate;
    }
    if (endDate != null && endDate.isNotEmpty) {
      queryParams['endDate'] = endDate;
    }

    final response = await _apiClient.get(
      ApiEndpoints.sales,
      queryParameters: queryParams,
    );

    final Map<String, dynamic> body = response.data as Map<String, dynamic>;
    final List list = body['data'] as List? ?? [];
    final sales = list
        .map((item) => Sale.fromJson(item as Map<String, dynamic>))
        .toList();

    SaleTotals totals = SaleTotals();
    if (body['totals'] != null && body['totals'] is Map<String, dynamic>) {
      totals = SaleTotals.fromJson(body['totals'] as Map<String, dynamic>);
    }

    Pagination? pagination;
    if (body['pagination'] != null &&
        body['pagination'] is Map<String, dynamic>) {
      pagination = Pagination.fromJson(
        body['pagination'] as Map<String, dynamic>,
      );
    }

    return SaleFetchResult(data: sales, totals: totals, pagination: pagination);
  }

  Future<Sale> getById(String id) async {
    final response = await _apiClient.get('${ApiEndpoints.sales}/$id');
    final body = response.data as Map<String, dynamic>;
    final data = body['data'] ?? body;
    return Sale.fromJson(data as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    await _apiClient.delete('${ApiEndpoints.sales}/$id');
  }

  Future<void> repostAccounting(String id) async {
    await _apiClient.post('/accounting/repost/sale/$id');
  }
}
