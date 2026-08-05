import '../../../../core/api/api_exceptions.dart';
import '../models/sale.dart';
import '../services/sale_service.dart';

class SaleRepository {
  final SaleService _service;

  SaleRepository(this._service);

  Future<SaleFetchResult> getSales({
    int page = 1,
    int limit = 20,
    String? search,
    String? paymentMethod,
    String? startDate,
    String? endDate,
  }) async {
    try {
      return await _service.getAll(
        page: page,
        limit: limit,
        search: search,
        paymentMethod: paymentMethod,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fetch sales invoices.');
    }
  }

  Future<Sale> getSaleById(String id) async {
    try {
      return await _service.getById(id);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fetch sale details.');
    }
  }

  Future<void> deleteSale(String id) async {
    try {
      await _service.delete(id);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to delete sale invoice.');
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
}
