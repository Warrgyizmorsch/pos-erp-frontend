import '../../../../core/api/api_exceptions.dart';
import '../models/business_profile.dart';
import '../services/business_service.dart';

class BusinessRepository {
  final BusinessService _service;

  BusinessRepository(this._service);

  Future<BusinessProfile> getProfile() async {
    try {
      return await _service.getProfile();
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fetch business profile.');
    }
  }

  Future<BusinessProfile> updateProfile(Map<String, dynamic> data) async {
    try {
      return await _service.updateProfile(data);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to update business profile.');
    }
  }
}
