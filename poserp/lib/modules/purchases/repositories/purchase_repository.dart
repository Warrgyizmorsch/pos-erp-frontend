import '../../../../core/api/api_exceptions.dart';
import '../../parties/suppliers/models/supplier.dart';
import '../../parties/transporters/models/transporter.dart';
import '../../products/models/product.dart';
import '../models/purchase.dart';
import '../models/purchase_payload.dart';
import '../services/purchase_service.dart';

class PurchaseRepository {
  final PurchaseService _service;

  PurchaseRepository(this._service);

  Future<PurchaseFetchResult> getPurchases({
    int page = 1,
    int limit = 20,
    String? search,
    String? status,
    String? paymentStatus,
    String? startDate,
    String? endDate,
  }) async {
    try {
      return await _service.getAll(
        page: page,
        limit: limit,
        search: search,
        status: status,
        paymentStatus: paymentStatus,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fetch purchase bills.');
    }
  }

  Future<Purchase> getPurchaseById(String id) async {
    try {
      return await _service.getById(id);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fetch purchase details.');
    }
  }

  Future<Purchase> createPurchase(PurchasePayload payload) async {
    try {
      return await _service.create(payload);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to create purchase bill.');
    }
  }

  Future<Purchase> updatePurchase(String id, PurchasePayload payload) async {
    try {
      return await _service.update(id, payload);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to update purchase bill.');
    }
  }

  Future<void> deletePurchase(String id) async {
    try {
      await _service.delete(id);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to delete purchase bill.');
    }
  }

  Future<void> repostAccounting(String id) async {
    try {
      await _service.repostAccounting(id);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to repost accounting voucher.');
    }
  }

  Future<List<Supplier>> fetchSuppliers() async {
    try {
      final res = await _service.getSuppliers();
      return res.data ?? [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Transporter>> fetchTransporters() async {
    try {
      final res = await _service.getTransporters();
      return res.data ?? [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Product>> fetchProducts() async {
    try {
      final res = await _service.getProducts();
      return res.data ?? [];
    } catch (e) {
      return [];
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
