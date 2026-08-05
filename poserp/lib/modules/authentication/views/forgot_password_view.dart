import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../widgets/auth_layout_wrapper.dart';

class ForgotPasswordView extends StatelessWidget {
  ForgotPasswordView({super.key});

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  void _onSendResetLink() {
    if (_formKey.currentState?.validate() ?? false) {
      Get.snackbar(
        'Reset link sent!',
        'Password reset link sent to ${_emailController.text.trim()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AuthLayoutWrapper(
      isRegister: false,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reset password',
              style: AppTypography.pageTitle(isDark: isDark),
            ),
            const SizedBox(height: 4),
            Text(
              'Enter your email to receive a reset link',
              style: AppTypography.caption(isDark: isDark),
            ),
            const SizedBox(height: 32),
            AppTextField(
              label: 'Email address',
              hintText: 'you@example.com',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
              isRequired: true,
            ),
            const SizedBox(height: 24),
            AppButton(
              text: 'Send reset link',
              width: double.infinity,
              height: 44,
              onPressed: _onSendResetLink,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => Get.toNamed('/login'),
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_back,
                    size: 16,
                    color: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForegroundLight,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Back to sign in',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.mutedForegroundDark
                          : AppColors.mutedForegroundLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
