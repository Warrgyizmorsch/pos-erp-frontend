import '../../../../core/api/api_exceptions.dart';
import '../../models/product.dart';
import '../models/stock_adjustment.dart';
import '../models/stock_movement.dart';
import '../services/stock_service.dart';

class StockRepository {
  final StockService _service;

  StockRepository(this._service);

  Future<StockFetchResult<Product>> getCurrentStock({
    int page = 1,
    int limit = 100,
    String? search,
    String? category,
    String? status,
  }) async {
    try {
      return await _service.getCurrentStock(
        page: page,
        limit: limit,
        search: search,
        category: category,
        status: status,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fetch current stock levels.');
    }
  }

  Future<StockFetchResult<StockMovement>> getMovements({
    int page = 1,
    int limit = 100,
    String? search,
    String? type,
    String? productId,
  }) async {
    try {
      return await _service.getMovements(
        page: page,
        limit: limit,
        search: search,
        type: type,
        productId: productId,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fetch stock movement history.');
    }
  }

  Future<StockFetchResult<StockAdjustment>> getAdjustments({
    int page = 1,
    int limit = 100,
  }) async {
    try {
      return await _service.getAdjustments(page: page, limit: limit);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fetch stock adjustments.');
    }
  }

  Future<StockAdjustment> createAdjustment({
    required String productId,
    required double adjustedStock,
    required String reason,
    String? notes,
  }) async {
    try {
      return await _service.createAdjustment(
        productId: productId,
        adjustedStock: adjustedStock,
        reason: reason,
        notes: notes,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to save stock adjustment.');
    }
  }

  Future<Map<String, dynamic>> createOpeningStock(
    Map<String, dynamic> payload,
  ) async {
    try {
      return await _service.createOpeningStock(payload);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to save opening stock.');
    }
  }
}
