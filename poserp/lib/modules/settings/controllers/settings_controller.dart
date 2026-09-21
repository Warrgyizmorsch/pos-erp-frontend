import 'package:get/get.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/api_exceptions.dart';
import '../../../core/utils/app_snackbar.dart';
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
      AppSnackbar.error('Name is required', title: 'Validation Error');
      return;
    }
    try {
      isSaving.value = true;
      await _apiClient.put(
        ApiEndpoints.profile,
        data: {'name': name.value.trim(), 'phone': phone.value.trim()},
      );
      if (Get.isRegistered<AuthController>()) {
        await Get.find<AuthController>().checkSession();
      }
      AppSnackbar.success(
        'Profile settings updated successfully.',
        title: 'Saved',
      );
    } catch (e) {
      final msg = e is AppException ? e.message : 'Failed to update profile settings.';
      AppSnackbar.error(msg, title: 'Save Failed');
    } finally {
      isSaving.value = false;
    }
  }

  final RxBool isChangingPassword = false.obs;

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      isChangingPassword.value = true;
      await _apiClient.put(
        ApiEndpoints.changePassword,
        data: {'currentPassword': currentPassword, 'newPassword': newPassword},
      );
      Get.back();
      AppSnackbar.success(
        'Password changed successfully.',
        title: 'Success',
      );
      return true;
    } catch (e) {
      final msg = e is AppException ? e.message : 'Failed to change password.';
      AppSnackbar.error(msg, title: 'Password Change Failed');
      return false;
    } finally {
      isChangingPassword.value = false;
    }
  }
}
