import '../../../../core/api/api_exceptions.dart';
import '../../../parties/suppliers/models/supplier.dart';
import '../../models/purchase.dart';
import '../models/payment_out.dart';
import '../models/payment_out_payload.dart';
import '../services/payment_out_service.dart';

class PaymentOutRepository {
  final PaymentOutService _service;

  PaymentOutRepository(this._service);

  Future<PaymentOutFetchResult> getPayments({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    try {
      return await _service.getAll(page: page, limit: limit, search: search);
    } catch (e) {
      if (e is AppException) {
        if (e.statusCode == 404 ||
            e.message.toLowerCase().contains('not found')) {
          return PaymentOutFetchResult(data: [], pagination: null);
        }
        rethrow;
      }
      return PaymentOutFetchResult(data: [], pagination: null);
    }
  }

  Future<PaymentOut> getPaymentById(String id) async {
    try {
      return await _service.getById(id);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fetch payment details.');
    }
  }

  Future<PaymentOut> createPayment(PaymentOutPayload payload) async {
    try {
      return await _service.create(payload);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to create payment-out record.');
    }
  }

  Future<PaymentOut> updatePayment(String id, PaymentOutPayload payload) async {
    try {
      return await _service.update(id, payload);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to update payment-out record.');
    }
  }

  Future<void> deletePayment(String id) async {
    try {
      await _service.delete(id);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to delete payment-out record.');
    }
  }

  Future<List<Purchase>> fetchUnpaidPurchases(String supplierId) async {
    try {
      return await _service.getUnpaidPurchases(supplierId);
    } catch (e) {
      return [];
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
