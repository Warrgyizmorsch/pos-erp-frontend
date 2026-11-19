import '../../../../core/api/api_exceptions.dart';
import '../models/khaata_party.dart';
import '../services/khaata_service.dart';

class KhaataRepository {
  final KhaataService _service;

  KhaataRepository(this._service);

  Future<List<KhaataParty>> getBalances() async {
    try {
      return await _service.getBalances();
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fetch digital khaata balances.');
    }
  }

  Future<Map<String, dynamic>> addTransaction(
    String partyId, {
    required double amount,
    required String type,
    required String partyType,
    String? notes,
  }) async {
    try {
      return await _service.addTransaction(
        partyId,
        amount: amount,
        type: type,
        partyType: partyType,
        notes: notes,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to record khaata transaction.');
    }
  }

  Future<void> logReminder(String partyId, String message) async {
    try {
      await _service.logReminder(partyId, message);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to log reminder.');
    }
  }
}
