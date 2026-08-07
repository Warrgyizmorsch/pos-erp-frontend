import '../../../../core/api/api_exceptions.dart';
import '../models/shift.dart';
import '../services/shift_service.dart';

class ShiftRepository {
  final ShiftService _service;

  ShiftRepository(this._service);

  Future<Shift?> fetchCurrentShift() async {
    try {
      return await _service.getCurrentShift();
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to check active cashier shift.');
    }
  }

  Future<Shift> openShift({
    required double openingCash,
    required String cashierName,
    String? notes,
  }) async {
    try {
      return await _service.openShift(
        openingCash: openingCash,
        cashierName: cashierName,
        notes: notes,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to open cashier shift.');
    }
  }

  Future<Shift> closeShift({
    required double closingBalance,
    required double actualCash,
    String? notes,
  }) async {
    try {
      return await _service.closeShift(
        closingBalance: closingBalance,
        actualCash: actualCash,
        notes: notes,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to close cashier shift.');
    }
  }
}
