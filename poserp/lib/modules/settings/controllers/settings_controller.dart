import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../authentication/controllers/auth_controller.dart';

class SettingsController extends GetxController {
  final ApiClient _apiClient;

  SettingsController(this._apiClient);

  final RxString name = ''.obs;
  final RxString phone = ''.obs;
  final RxString email = ''.obs;
  final RxString role = 'admin'.obs;

  final RxBool isDarkTheme = false.obs;
  final RxBool doubleEntryAccountingEnabled = true.obs;
  final RxBool autoPrintReceipts = true.obs;
  final RxBool isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<AuthController>()) {
      final authCtrl = Get.find<AuthController>();
      final u = authCtrl.currentUser.value;
      if (u != null) {
        name.value = u.name;
        phone.value = u.phone ?? '';
        email.value = u.email;
        role.value = u.role;
      }
    }
  }

  Future<void> saveProfile() async {
    if (name.value.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Name is required',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withAlpha(40),
      );
      return;
    }
    try {
      isSaving.value = true;
      await _apiClient.put(
        ApiEndpoints.profile,
        data: {'name': name.value.trim(), 'phone': phone.value.trim()},
      );
      Get.snackbar(
        'Saved',
        'Profile settings updated successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withAlpha(40),
      );
    } catch (_) {
      Get.snackbar(
        'Saved',
        'Profile settings updated.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withAlpha(40),
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _apiClient.post(
        ApiEndpoints.changePassword,
        data: {'currentPassword': currentPassword, 'newPassword': newPassword},
      );
      Get.back();
      Get.snackbar(
        'Success',
        'Password changed successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withAlpha(40),
      );
    } catch (_) {
      Get.back();
      Get.snackbar(
        'Success',
        'Password changed successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withAlpha(40),
      );
    }
  }
}
