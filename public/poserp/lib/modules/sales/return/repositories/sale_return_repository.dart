import '../../../../core/api/api_exceptions.dart';
import '../../../parties/customers/models/customer.dart';
import '../../models/sale.dart';
import '../models/sale_return.dart';
import '../models/sale_return_payload.dart';
import '../services/sale_return_service.dart';

class SaleReturnRepository {
  final SaleReturnService _service;

  SaleReturnRepository(this._service);

  Future<SaleReturnFetchResult> getReturns({
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
        message: 'Failed to fetch Credit Notes / Sale Returns.',
      );
    }
  }

  Future<SaleReturn> getReturnById(String id) async {
    try {
      return await _service.getById(id);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fetch Credit Note details.');
    }
  }

  Future<SaleReturn> createReturn(SaleReturnPayload payload) async {
    try {
      return await _service.create(payload);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to issue Credit Note.');
    }
  }

  Future<void> cancelReturn(String id) async {
    try {
      await _service.cancel(id);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to cancel Credit Note.');
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

  Future<List<Sale>> fetchUnreturnedSales(String customerId) async {
    try {
      final res = await _service.getUnreturnedSalesForCustomer(customerId);
      return res.data ?? [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> fetchReturnableItems(String invoiceId) async {
    try {
      return await _service.getReturnableItemsFromInvoice(invoiceId);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(
        message: 'Failed to load returnable items for invoice.',
      );
    }
  }
}
