import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../data/models/api_response.dart';
import '../../../../data/models/pagination.dart';
import '../../../parties/customers/models/customer.dart';
import '../../models/sale.dart';
import '../models/sale_return.dart';
import '../models/sale_return_payload.dart';

class SaleReturnFetchResult {
  final List<SaleReturn> data;
  final Pagination? pagination;

  SaleReturnFetchResult({required this.data, this.pagination});
}

class SaleReturnService {
  final ApiClient _apiClient;

  SaleReturnService(this._apiClient);

  Future<SaleReturnFetchResult> getAll({
    int page = 1,
    int limit = 15,
    String? search,
    String? status,
    String? refundType,
    String? startDate,
    String? endDate,
  }) async {
    final Map<String, dynamic> queryParams = {'page': page, 'limit': limit};
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }
    if (status != null && status != 'all' && status.isNotEmpty) {
      queryParams['status'] = status;
    }
    if (refundType != null && refundType != 'all' && refundType.isNotEmpty) {
      queryParams['refundType'] = refundType;
    }
    if (startDate != null && startDate.isNotEmpty) {
      queryParams['startDate'] = startDate;
    }
    if (endDate != null && endDate.isNotEmpty) {
      queryParams['endDate'] = endDate;
    }

    final response = await _apiClient.get(
      ApiEndpoints.salesReturns,
      queryParameters: queryParams,
    );

    final Map<String, dynamic> body = response.data as Map<String, dynamic>;
    final List list = body['data'] as List? ?? [];
    final returns = list
        .map((item) => SaleReturn.fromJson(item as Map<String, dynamic>))
        .toList();

    Pagination? pagination;
    if (body['pagination'] != null &&
        body['pagination'] is Map<String, dynamic>) {
      pagination = Pagination.fromJson(
        body['pagination'] as Map<String, dynamic>,
      );
    }

    return SaleReturnFetchResult(data: returns, pagination: pagination);
  }

  Future<SaleReturn> getById(String id) async {
    final response = await _apiClient.get('${ApiEndpoints.salesReturns}/$id');
    final body = response.data as Map<String, dynamic>;
    final data = body['data'] ?? body;
    return SaleReturn.fromJson(data as Map<String, dynamic>);
  }

  Future<SaleReturn> create(SaleReturnPayload payload) async {
    final response = await _apiClient.post(
      ApiEndpoints.salesReturns,
      data: payload.toJson(),
    );
    final body = response.data as Map<String, dynamic>;
    final data = body['data'] ?? body;
    return SaleReturn.fromJson(data as Map<String, dynamic>);
  }

  Future<void> cancel(String id) async {
    await _apiClient.post('${ApiEndpoints.salesReturns}/$id/cancel');
  }

  Future<ApiResponse<List<Customer>>> getCustomers() async {
    final response = await _apiClient.get(
      ApiEndpoints.customers,
      queryParameters: {'limit': 100},
    );
    return ApiResponse<List<Customer>>.fromJson(
      response.data,
      (json) => (json as List)
          .map((item) => Customer.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getBankAccounts() async {
    final response = await _apiClient.get(ApiEndpoints.cashBankAccounts);
    return ApiResponse<List<Map<String, dynamic>>>.fromJson(
      response.data,
      (json) =>
          (json as List).map((item) => item as Map<String, dynamic>).toList(),
    );
  }

  Future<ApiResponse<List<Sale>>> getUnreturnedSalesForCustomer(
    String customerId,
  ) async {
    final response = await _apiClient.get(
      '${ApiEndpoints.salesReturns}/customer/$customerId/unreturned',
    );
    return ApiResponse<List<Sale>>.fromJson(
      response.data,
      (json) => (json as List)
          .map((item) => Sale.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<Map<String, dynamic>> getReturnableItemsFromInvoice(
    String invoiceId,
  ) async {
    final response = await _apiClient.get(
      '${ApiEndpoints.salesReturns}/invoice/$invoiceId/returnable-items',
    );
    final body = response.data as Map<String, dynamic>;
    return body['data'] as Map<String, dynamic>;
  }
}
