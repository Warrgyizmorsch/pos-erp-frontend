import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../models/api_response.dart';
import '../models/user.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  Future<ApiResponse<User>> login(String email, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {
        'email': email,
        'password': password,
      },
    );

    return ApiResponse<User>.fromJson(
      response.data,
      (json) => User.fromJson(json),
    );
  }

  Future<ApiResponse<User>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? role,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.register,
      data: {
        'name': name,
        'email': email,
        'password': password,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (role != null && role.isNotEmpty) 'role': role,
      },
    );

    return ApiResponse<User>.fromJson(
      response.data,
      (json) => User.fromJson(json),
    );
  }

  Future<ApiResponse<User>> getMe() async {
    final response = await _apiClient.get(ApiEndpoints.me);

    return ApiResponse<User>.fromJson(
      response.data,
      (json) => User.fromJson(json),
    );
  }
}
