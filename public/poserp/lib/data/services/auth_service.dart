import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../models/api_response.dart';
import '../models/role.dart';
import '../models/user.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  Future<ApiResponse<User>> login(String email, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
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

  Future<void> forgotPassword(String email) async {
    await _apiClient.post(
      ApiEndpoints.forgotPassword,
      data: {'email': email},
    );
  }

  Future<ApiResponse<List<User>>> getUsers() async {
    final response = await _apiClient.get(ApiEndpoints.users);
    return ApiResponse<List<User>>.fromJson(
      response.data,
      (json) => (json as List).map((e) => User.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<ApiResponse<User>> createUser(Map<String, dynamic> payload) async {
    final response = await _apiClient.post(
      ApiEndpoints.users,
      data: payload,
    );
    return ApiResponse<User>.fromJson(
      response.data,
      (json) => User.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<User>> updateUser(String id, Map<String, dynamic> payload) async {
    final response = await _apiClient.put(
      ApiEndpoints.userById(id),
      data: payload,
    );
    return ApiResponse<User>.fromJson(
      response.data,
      (json) => User.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<dynamic>> deleteUser(String id) async {
    final response = await _apiClient.delete(ApiEndpoints.userById(id));
    return ApiResponse<dynamic>.fromJson(
      response.data,
      (json) => json,
    );
  }

  Future<ApiResponse<List<Role>>> getRoles() async {
    final response = await _apiClient.get(ApiEndpoints.roles);
    return ApiResponse<List<Role>>.fromJson(
      response.data,
      (json) => (json as List).map((e) => Role.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<ApiResponse<Role>> updateRolePermissions(String id, List<String> permissions) async {
    final response = await _apiClient.put(
      ApiEndpoints.roleById(id),
      data: {'permissions': permissions},
    );
    return ApiResponse<Role>.fromJson(
      response.data,
      (json) => Role.fromJson(json as Map<String, dynamic>),
    );
  }
}
