import '../../core/api/api_exceptions.dart';
import '../models/api_response.dart';
import '../models/role.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class AuthRepository {
  final AuthService _authService;
  final StorageService _storageService;

  AuthRepository(this._authService, this._storageService);

  Future<ApiResponse<User>> login(String email, String password) async {
    try {
      final response = await _authService.login(email, password);
      if (response.success && response.data != null && response.token != null) {
        await _storageService.saveToken(response.token!);
        await _storageService.saveUser(response.data!);
      }
      return response;
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to process login response.');
    }
  }

  Future<ApiResponse<User>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final response = await _authService.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
      if (response.success && response.data != null && response.token != null) {
        await _storageService.saveToken(response.token!);
        await _storageService.saveUser(response.data!);
      }
      return response;
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to process registration response.');
    }
  }

  Future<User?> getCurrentUser() async {
    final token = _storageService.getToken();
    if (token == null || token.isEmpty) return null;

    final cachedUser = _storageService.getUser();

    try {
      final response = await _authService.getMe();
      if (response.success && response.data != null) {
        await _storageService.saveUser(response.data!);
        return response.data;
      }
    } catch (_) {
      // If fetching fresh user fails due to 401, return null
    }

    return cachedUser;
  }

  Future<void> logout() async {
    await _storageService.clearSession();
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _authService.forgotPassword(email);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to send password reset link.');
    }
  }

  Future<List<User>> getUsers() async {
    try {
      final response = await _authService.getUsers();
      return response.data ?? [];
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fetch users: $e');
    }
  }

  Future<User> createUser(Map<String, dynamic> payload) async {
    try {
      final response = await _authService.createUser(payload);
      if (response.data == null) {
        throw AppException(message: 'Invalid response from server when creating user.');
      }
      return response.data!;
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to create user: $e');
    }
  }

  Future<User> updateUser(String id, Map<String, dynamic> payload) async {
    try {
      final response = await _authService.updateUser(id, payload);
      if (response.data == null) {
        throw AppException(message: 'Invalid response from server when updating user.');
      }
      return response.data!;
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to update user: $e');
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await _authService.deleteUser(id);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to delete user: $e');
    }
  }

  Future<List<Role>> getRoles() async {
    try {
      final response = await _authService.getRoles();
      return response.data ?? [];
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fetch roles: $e');
    }
  }

  Future<Role> updateRolePermissions(String id, List<String> permissions) async {
    try {
      final response = await _authService.updateRolePermissions(id, permissions);
      if (response.data == null) {
        throw AppException(message: 'Invalid response from server when updating role permissions.');
      }
      return response.data!;
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to update role permissions: $e');
    }
  }
}
