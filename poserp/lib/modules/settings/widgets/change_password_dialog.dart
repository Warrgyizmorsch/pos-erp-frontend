import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/widgets/app_button.dart';
import '../controllers/settings_controller.dart';

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.shield_outlined, color: AppColors.primary),
                  SizedBox(width: 10),
                  Text(
                    'Change Password',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _currentController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _newController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _confirmController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                    text: 'Cancel',
                    variant: AppButtonVariant.outline,
                    onPressed: () => Get.back(),
                  ),
                  const SizedBox(width: 8),
                  Obx(
                    () => AppButton(
                      text: 'Update Password',
                      isLoading: controller.isChangingPassword.value,
                      onPressed: controller.isChangingPassword.value
                          ? null
                          : () {
                              final current = _currentController.text.trim();
                              final newPass = _newController.text.trim();
                              final confirm = _confirmController.text.trim();

                              if (current.isEmpty) {
                                AppSnackbar.error(
                                  'Current password is required',
                                  title: 'Validation Error',
                                );
                                return;
                              }
                              if (newPass.isEmpty) {
                                AppSnackbar.error(
                                  'New password is required',
                                  title: 'Validation Error',
                                );
                                return;
                              }
                              if (newPass.length < 6) {
                                AppSnackbar.error(
                                  'New password must be at least 6 characters',
                                  title: 'Validation Error',
                                );
                                return;
                              }
                              if (newPass != confirm) {
                                AppSnackbar.error(
                                  'Passwords do not match',
                                  title: 'Validation Error',
                                );
                                return;
                              }
                              controller.changePassword(
                                currentPassword: current,
                                newPassword: newPass,
                              );
                            },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
