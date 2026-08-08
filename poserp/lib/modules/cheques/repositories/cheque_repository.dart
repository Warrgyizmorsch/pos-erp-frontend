import '../../../../core/api/api_exceptions.dart';
import '../models/cheque.dart';
import '../services/cheque_service.dart';

class ChequeRepository {
  final ChequeService _service;

  ChequeRepository(this._service);

  Future<List<Cheque>> fetchCheques() async {
    try {
      return await _service.getCheques();
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fetch cheques list.');
    }
  }

  Future<Cheque> createCheque(Map<String, dynamic> payload) async {
    try {
      return await _service.createCheque(payload);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to create cheque record.');
    }
  }

  Future<Cheque> updateCheque(String id, Map<String, dynamic> payload) async {
    try {
      return await _service.updateCheque(id, payload);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to update cheque status.');
    }
  }

  Future<void> removeCheque(String id) async {
    try {
      await _service.deleteCheque(id);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to delete cheque.');
    }
  }
}
