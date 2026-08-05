import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../data/models/api_response.dart';
import '../../../parties/customers/models/customer.dart';
import '../../models/sale.dart';
import '../models/payment_in.dart';
import '../models/payment_in_payload.dart';

class PaymentInService {
  final ApiClient _apiClient;

  PaymentInService(this._apiClient);

  Future<ApiResponse<List<PaymentIn>>> getAll({String? search}) async {
    final response = await _apiClient.get(
      ApiEndpoints.paymentIn,
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );

    return ApiResponse<List<PaymentIn>>.fromJson(
      response.data,
      (json) => (json as List)
          .map((item) => PaymentIn.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<ApiResponse<PaymentIn>> getById(String id) async {
    final response = await _apiClient.get('${ApiEndpoints.paymentIn}/$id');
    return ApiResponse<PaymentIn>.fromJson(
      response.data,
      (json) => PaymentIn.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<PaymentIn>> create(PaymentInPayload payload) async {
    final response = await _apiClient.post(
      ApiEndpoints.paymentIn,
      data: payload.toJson(),
    );

    return ApiResponse<PaymentIn>.fromJson(
      response.data,
      (json) => PaymentIn.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<PaymentIn>> update(
    String id,
    PaymentInPayload payload,
  ) async {
    final response = await _apiClient.put(
      '${ApiEndpoints.paymentIn}/$id',
      data: payload.toJson(),
    );

    return ApiResponse<PaymentIn>.fromJson(
      response.data,
      (json) => PaymentIn.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<void> delete(String id) async {
    await _apiClient.delete('${ApiEndpoints.paymentIn}/$id');
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

  Future<ApiResponse<List<Sale>>> getUnpaidInvoices(String customerId) async {
    final response = await _apiClient.get(
      '${ApiEndpoints.sales}/unpaid/$customerId',
    );
    return ApiResponse<List<Sale>>.fromJson(
      response.data,
      (json) => (json as List)
          .map((item) => Sale.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
