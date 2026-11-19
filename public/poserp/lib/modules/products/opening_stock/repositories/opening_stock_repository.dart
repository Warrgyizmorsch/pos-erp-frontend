import '../../../../core/api/api_exceptions.dart';
import '../models/opening_stock_payload.dart';
import '../services/opening_stock_service.dart';

class OpeningStockRepository {
  final OpeningStockService _service;

  OpeningStockRepository(this._service);

  Future<dynamic> submitOpeningStock(OpeningStockPayload payload) async {
    try {
      final res = await _service.submitOpeningStock(payload);
      return res.data;
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to submit opening stock.');
    }
  }
}
