import '../../../../core/api/api_exceptions.dart';
import '../../../parties/customers/models/customer.dart';
import '../../models/sale.dart';
import '../models/payment_in.dart';
import '../models/payment_in_payload.dart';
import '../services/payment_in_service.dart';

class PaymentInRepository {
  final PaymentInService _service;

  PaymentInRepository(this._service);

  Future<List<PaymentIn>> getPayments({String? search}) async {
    try {
      final res = await _service.getAll(search: search);
      return res.data ?? [];
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fetch Payment-In records.');
    }
  }

  Future<PaymentIn> getPaymentById(String id) async {
    try {
      final res = await _service.getById(id);
      if (res.data != null) return res.data!;
      throw AppException(message: 'Failed to fetch Payment-In details.');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fetch Payment-In details.');
    }
  }

  Future<PaymentIn> createPayment(PaymentInPayload payload) async {
    try {
      final res = await _service.create(payload);
      if (res.data != null) return res.data!;
      throw AppException(message: 'Failed to create Payment-In.');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to create Payment-In.');
    }
  }

  Future<PaymentIn> updatePayment(String id, PaymentInPayload payload) async {
    try {
      final res = await _service.update(id, payload);
      if (res.data != null) return res.data!;
      throw AppException(message: 'Failed to update Payment-In.');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to update Payment-In.');
    }
  }

  Future<void> deletePayment(String id) async {
    try {
      await _service.delete(id);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to delete Payment-In.');
    }
  }

  Future<List<Customer>> fetchCustomers() async {
    try {
      final res = await _service.getCustomers();
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

  Future<List<Sale>> fetchUnpaidInvoices(String customerId) async {
    try {
      final res = await _service.getUnpaidInvoices(customerId);
      return res.data ?? [];
    } catch (e) {
      return [];
    }
  }
}
