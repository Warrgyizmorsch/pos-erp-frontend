import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../widgets/auth_layout_wrapper.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isSubmitted = false;

  void _onSendResetLink() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSubmitted = true;
      });
      Get.snackbar(
        'Password Reset Link Sent',
        'Check your inbox at ${_emailController.text.trim()}',
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
            const Text(
              'Reset Password',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Enter your registered email address to receive recovery instructions',
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppColors.mutedForegroundDark
                    : AppColors.mutedForegroundLight,
              ),
            ),
            const SizedBox(height: 24),

            if (_isSubmitted) ...[
              AppCard(
                padding: const EdgeInsets.all(16),
                backgroundColor: AppColors.success.withAlpha(20),
                child: Row(
                  children: [
                    const Icon(
                      Icons.mark_email_read_rounded,
                      color: AppColors.success,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Reset Email Delivered',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.success,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'We sent reset link & OTP instructions to ${_emailController.text.trim()}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Email Input
            AppTextField(
              label: 'Email address',
              hintText: 'you@example.com',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
              isRequired: true,
            ),
            const SizedBox(height: 20),

            // Send Reset Link Button
            AppButton(
              text: _isSubmitted ? 'Resend Reset Link' : 'Send Reset Link',
              icon: const Icon(Icons.send_rounded, size: 18),
              width: double.infinity,
              height: AppSizes.buttonHeightMd,
              onPressed: _onSendResetLink,
            ),
            const SizedBox(height: 20),

            // Back to Sign In
            Center(
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, AppSizes.minTouchTarget),
                ),
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: const Text(
                  'Back to Sign In',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () => Get.toNamed('/login'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
