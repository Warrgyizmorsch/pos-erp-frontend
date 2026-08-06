import '../../../../core/api/api_exceptions.dart';
import '../../../parties/suppliers/models/supplier.dart';
import '../../models/purchase.dart';
import '../models/purchase_return.dart';
import '../models/purchase_return_payload.dart';
import '../services/purchase_return_service.dart';

class PurchaseReturnRepository {
  final PurchaseReturnService _service;

  PurchaseReturnRepository(this._service);

  Future<PurchaseReturnFetchResult> getReturns({
    int page = 1,
    int limit = 15,
    String? search,
    String? status,
    String? refundType,
    String? startDate,
    String? endDate,
  }) async {
    try {
      return await _service.getAll(
        page: page,
        limit: limit,
        search: search,
        status: status,
        refundType: refundType,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(
        message: 'Failed to fetch Purchase Returns / Debit Notes.',
      );
    }
  }

  Future<PurchaseReturn> getReturnById(String id) async {
    try {
      return await _service.getById(id);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fetch Purchase Return details.');
    }
  }

  Future<PurchaseReturn> createReturn(PurchaseReturnPayload payload) async {
    try {
      return await _service.create(payload);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(
        message: 'Failed to create Purchase Return / Debit Note.',
      );
    }
  }

  Future<void> deleteReturn(String id) async {
    try {
      await _service.delete(id);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to delete Purchase Return record.');
    }
  }

  Future<PurchaseReturn> cancelReturn(String id) async {
    try {
      return await _service.cancel(id);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to cancel Purchase Return record.');
    }
  }

  Future<List<Purchase>> fetchUnreturnedPurchases(String supplierId) async {
    try {
      return await _service.getUnreturnedPurchasesForSupplier(supplierId);
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> fetchReturnableItems(String billId) async {
    try {
      return await _service.getReturnableItemsFromBill(billId);
    } catch (e) {
      return {};
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

  Future<List<Map<String, dynamic>>> fetchBankAccounts() async {
    try {
      final res = await _service.getBankAccounts();
      return res.data ?? [];
    } catch (e) {
      return [];
    }
  }
}
