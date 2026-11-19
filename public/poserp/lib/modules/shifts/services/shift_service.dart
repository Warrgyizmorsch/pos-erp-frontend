import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/shift.dart';

class ShiftService {
  final ApiClient _apiClient;

  ShiftService(this._apiClient);

  Future<Shift?> getCurrentShift() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.shiftsCurrent);
      if (response.data == null) return null;

      final Map<String, dynamic> body = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : {};
      final data = body['data'] ?? body;

      if (data == null || (data is Map && data.isEmpty)) return null;
      return Shift.fromJson(data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<Shift> openShift({
    required double openingCash,
    required String cashierName,
    String? notes,
  }) async {
    final payload = {
      'openingCash': openingCash,
      'cashierName': cashierName,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    };

    final response = await _apiClient.post(
      ApiEndpoints.shiftsOpen,
      data: payload,
    );

    final Map<String, dynamic> body = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : {};
    final data = body['data'] ?? body;
    return Shift.fromJson(data as Map<String, dynamic>);
  }

  Future<Shift> closeShift({
    required double closingBalance,
    required double actualCash,
    String? notes,
  }) async {
    final payload = {
      'closingBalance': closingBalance,
      'actualCash': actualCash,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    };

    dynamic responseData;
    try {
      final response = await _apiClient.post(
        ApiEndpoints.shiftsClose,
        data: payload,
      );
      responseData = response.data;
    } catch (_) {
      final response = await _apiClient.put(
        ApiEndpoints.shiftsClose,
        data: payload,
      );
      responseData = response.data;
    }

    final Map<String, dynamic> body = responseData is Map<String, dynamic>
        ? responseData
        : {};
    final data = body['data'] ?? body;
    return Shift.fromJson(data as Map<String, dynamic>);
  }
}
