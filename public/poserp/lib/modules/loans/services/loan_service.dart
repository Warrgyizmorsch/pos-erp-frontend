import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/loan.dart';

class LoanService {
  final ApiClient _apiClient;

  LoanService(this._apiClient);

  Future<List<Loan>> getLoans() async {
    final response = await _apiClient.get(ApiEndpoints.loans);
    dynamic body = response.data;
    List list = [];
    if (body is Map<String, dynamic>) {
      list = body['data'] ?? body['loans'] ?? [];
    } else if (body is List) {
      list = body;
    }

    final result = <Loan>[];
    for (final item in list) {
      if (item is Map<String, dynamic>) {
        try {
          result.add(Loan.fromJson(item));
        } catch (_) {}
      }
    }
    return result;
  }

  Future<Loan> createLoan(Map<String, dynamic> payload) async {
    final response = await _apiClient.post(ApiEndpoints.loans, data: payload);
    final body = response.data is Map<String, dynamic> ? response.data : {};
    final data = body['data'] ?? body;
    return Loan.fromJson(data as Map<String, dynamic>);
  }

  Future<Loan> updateLoan(String id, Map<String, dynamic> payload) async {
    final response = await _apiClient.put(
      '${ApiEndpoints.loans}/$id',
      data: payload,
    );
    final body = response.data is Map<String, dynamic> ? response.data : {};
    final data = body['data'] ?? body;
    return Loan.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteLoan(String id) async {
    await _apiClient.delete('${ApiEndpoints.loans}/$id');
  }
}
