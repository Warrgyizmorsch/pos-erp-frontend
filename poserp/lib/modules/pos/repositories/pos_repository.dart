import '../../../../core/api/api_exceptions.dart';
import '../../parties/customers/models/customer.dart';
import '../../products/models/product.dart';
import '../models/pos_sale_payload.dart';
import '../services/pos_service.dart';

class POSRepository {
  final POSService _service;

  POSRepository(this._service);

  Future<List<Product>> fetchProducts({String? search}) async {
    try {
      final res = await _service.getProducts(search: search);
      return res.data ?? [];
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fetch products for POS.');
    }
  }

  Future<List<Customer>> fetchCustomers() async {
    try {
      final res = await _service.getCustomers();
      return res.data ?? [];
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fetch customers for POS.');
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

  Future<Map<String, dynamic>> submitSale(
    POSSalePayload payload, {
    String? editingId,
  }) async {
    try {
      final res = editingId != null
          ? await _service.updateSale(editingId, payload)
          : await _service.createSale(payload);
      if (res.data != null) return res.data!;
      throw AppException(message: 'Failed to process POS sale.');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to process POS sale.');
    }
  }
}
