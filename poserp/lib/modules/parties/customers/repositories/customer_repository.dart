import '../../../../core/api/api_exceptions.dart';
import '../../../../data/models/api_response.dart';
import '../models/customer.dart';
import '../models/customer_payload.dart';
import '../services/customer_service.dart';

class CustomerRepository {
  final CustomerService _service;

  CustomerRepository(this._service);

  Future<ApiResponse<List<Customer>>> getCustomers({
    String? search,
    int page = 1,
    int limit = 15,
  }) async {
    try {
      return await _service.getAll(search: search, page: page, limit: limit);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fetch customers.');
    }
  }

  Future<Customer> createCustomer(CustomerPayload payload) async {
    try {
      final res = await _service.create(payload);
      if (res.data != null) return res.data!;
      throw AppException(message: 'Failed to create customer.');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to create customer.');
    }
  }

  Future<Customer> updateCustomer(String id, CustomerPayload payload) async {
    try {
      final res = await _service.update(id, payload);
      if (res.data != null) return res.data!;
      throw AppException(message: 'Failed to update customer.');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to update customer.');
    }
  }

  Future<void> deleteCustomer(String id) async {
    try {
      await _service.delete(id);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to delete customer.');
    }
  }
}
