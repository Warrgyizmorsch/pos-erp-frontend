import '../../../../core/api/api_exceptions.dart';
import '../../../../data/models/api_response.dart';
import '../models/supplier.dart';
import '../models/supplier_payload.dart';
import '../services/supplier_service.dart';

class SupplierRepository {
  final SupplierService _service;

  SupplierRepository(this._service);

  Future<ApiResponse<List<Supplier>>> getSuppliers({
    String? search,
    int page = 1,
    int limit = 15,
    bool? hasBalance,
  }) async {
    try {
      return await _service.getAll(
        search: search,
        page: page,
        limit: limit,
        hasBalance: hasBalance,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fetch suppliers.');
    }
  }

  Future<Supplier> createSupplier(SupplierPayload payload) async {
    try {
      final res = await _service.create(payload);
      if (res.data != null) return res.data!;
      throw AppException(message: 'Failed to create supplier.');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to create supplier.');
    }
  }

  Future<Supplier> updateSupplier(String id, SupplierPayload payload) async {
    try {
      final res = await _service.update(id, payload);
      if (res.data != null) return res.data!;
      throw AppException(message: 'Failed to update supplier.');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to update supplier.');
    }
  }

  Future<void> deleteSupplier(String id) async {
    try {
      await _service.delete(id);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to delete supplier.');
    }
  }
}
