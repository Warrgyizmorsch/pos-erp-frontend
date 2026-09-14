import '../../../../core/api/api_exceptions.dart';
import '../models/godown.dart';
import '../services/godown_service.dart';

class GodownRepository {
  final GodownService _service;

  GodownRepository(this._service);

  Future<List<Godown>> getAllGodowns() async {
    try {
      return await _service.getAll();
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fetch warehouse godowns.');
    }
  }

  Future<Godown> createGodown(Map<String, dynamic> data) async {
    try {
      return await _service.create(data);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to create warehouse godown.');
    }
  }

  Future<Godown> updateGodown(String id, Map<String, dynamic> data) async {
    try {
      return await _service.update(id, data);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to update warehouse godown.');
    }
  }

  Future<void> deleteGodown(String id) async {
    try {
      await _service.delete(id);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to delete warehouse godown.');
    }
  }

  Future<void> transferStock({
    required String sourceGodownId,
    required String destinationGodownId,
    required List<Map<String, dynamic>> items,
    String? notes,
  }) async {
    try {
      await _service.transferStock(
        sourceGodownId: sourceGodownId,
        destinationGodownId: destinationGodownId,
        items: items,
        notes: notes,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to execute stock transfer.');
    }
  }
}
