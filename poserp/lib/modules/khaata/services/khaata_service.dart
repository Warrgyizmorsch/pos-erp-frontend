import '../../../../core/api/api_client.dart';
import '../models/khaata_party.dart';

class KhaataService {
  final ApiClient _apiClient;

  KhaataService(this._apiClient);

  Future<List<KhaataParty>> getBalances() async {
    final response = await _apiClient.get('/khaata/balances');
    final body = response.data as Map<String, dynamic>;
    final list = body['data'] as List? ?? [];
    return list
        .map((e) => KhaataParty.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> addTransaction(
    String partyId, {
    required double amount,
    required String type,
    required String partyType,
    String? notes,
  }) async {
    final response = await _apiClient.post(
      '/khaata/$partyId/transaction',
      data: {
        'amount': amount,
        'type': type,
        'partyType': partyType,
        'notes': notes ?? '',
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<void> logReminder(String partyId, String message) async {
    await _apiClient.post(
      '/khaata/$partyId/remind',
      data: {'message': message},
    );
  }
}
