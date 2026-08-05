import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/api/api_exceptions.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/auth_repository.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository;

  AuthController(this._authRepository);

  final Rx<User?> currentUser = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isInitializing = true.obs;

  bool get isAuthenticated => currentUser.value != null;

  @override
  void onInit() {
    super.onInit();
    checkSession();
  }

  Future<void> checkSession() async {
    try {
      isInitializing.value = true;
      final user = await _authRepository.getCurrentUser();
      currentUser.value = user;
    } catch (_) {
      currentUser.value = null;
    } finally {
      isInitializing.value = false;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      final response = await _authRepository.login(email, password);
      if (response.success && response.data != null) {
        currentUser.value = response.data;
        Get.snackbar(
          'Welcome back!',
          'Logged in as ${response.data!.name}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        );
        Get.offAllNamed('/dashboard');
      } else {
        showErrorSnackbar(
          response.message ?? 'Login failed. Invalid credentials.',
        );
      }
    } catch (e) {
      final msg = e is AppException
          ? e.message
          : 'An error occurred during sign in.';
      showErrorSnackbar(msg);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      isLoading.value = true;
      final response = await _authRepository.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
      if (response.success && response.data != null) {
        currentUser.value = response.data;
        Get.snackbar(
          'Account created!',
          'Welcome to POS ERP',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        );
        Get.offAllNamed('/dashboard');
      } else {
        showErrorSnackbar(response.message ?? 'Registration failed.');
      }
    } catch (e) {
      final msg = e is AppException
          ? e.message
          : 'An error occurred during account creation.';
      showErrorSnackbar(msg);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _authRepository.logout();
      currentUser.value = null;
      Get.offAllNamed('/login');
    } catch (e) {
      showErrorSnackbar('Failed to log out cleanly.');
    }
  }

  void showErrorSnackbar(String message) {
    Get.snackbar(
      'Authentication Failed',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.danger,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 4),
    );
  }
}
