import '../../../../core/api/api_exceptions.dart';
import '../services/pos_checkout_service.dart';

class POSCheckoutRepository {
  final POSCheckoutService _service;

  POSCheckoutRepository(this._service);

  Future<Map<String, dynamic>> completeCheckout(
    Map<String, dynamic> salePayload,
  ) async {
    try {
      return await _service.submitCheckout(salePayload);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to complete POS checkout.');
    }
  }
}
