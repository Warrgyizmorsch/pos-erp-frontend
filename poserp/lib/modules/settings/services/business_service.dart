import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/business_profile.dart';

class BusinessService {
  final ApiClient _apiClient;

  BusinessService(this._apiClient);

  Future<BusinessProfile> getProfile() async {
    final response = await _apiClient.get(ApiEndpoints.business);
    final body = response.data;
    if (body is Map<String, dynamic>) {
      final data = body['data'] ?? body;
      return BusinessProfile.fromJson(data as Map<String, dynamic>);
    }
    throw Exception('Unexpected response format for business profile');
  }

  Future<BusinessProfile> updateProfile(Map<String, dynamic> data) async {
    final response = await _apiClient.put(ApiEndpoints.business, data: data);
    final body = response.data;
    if (body is Map<String, dynamic>) {
      final resData = body['data'] ?? body;
      return BusinessProfile.fromJson(resData as Map<String, dynamic>);
    }
    throw Exception('Unexpected response format for business profile update');
  }
}
