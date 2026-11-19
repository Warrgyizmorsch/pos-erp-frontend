import '../../../../core/api/api_exceptions.dart';
import '../../../../data/models/api_response.dart';
import '../models/transporter.dart';
import '../models/transporter_payload.dart';
import '../services/transporter_service.dart';

class TransporterRepository {
  final TransporterService _service;

  TransporterRepository(this._service);

  Future<ApiResponse<List<Transporter>>> getTransporters({
    String? search,
    int page = 1,
    int limit = 15,
  }) async {
    try {
      return await _service.getAll(search: search, page: page, limit: limit);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fetch transporters.');
    }
  }

  Future<Transporter> createTransporter(TransporterPayload payload) async {
    try {
      final res = await _service.create(payload);
      if (res.data != null) return res.data!;
      throw AppException(message: 'Failed to create transporter.');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to create transporter.');
    }
  }

  Future<Transporter> updateTransporter(
    String id,
    TransporterPayload payload,
  ) async {
    try {
      final res = await _service.update(id, payload);
      if (res.data != null) return res.data!;
      throw AppException(message: 'Failed to update transporter.');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to update transporter.');
    }
  }

  Future<void> deleteTransporter(String id) async {
    try {
      await _service.delete(id);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to delete transporter.');
    }
  }
}
