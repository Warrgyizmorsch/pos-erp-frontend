import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_layout_wrapper.dart';

class RegisterView extends GetView<AuthController> {
  RegisterView({super.key});

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final RxBool _obscurePassword = true.obs;

  void _onRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      controller.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AuthLayoutWrapper(
      isRegister: true,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create account',
              style: AppTypography.pageTitle(isDark: isDark),
            ),
            const SizedBox(height: 4),
            Text(
              'Get started with POS ERP',
              style: AppTypography.caption(isDark: isDark),
            ),
            const SizedBox(height: 28),
            // Full Name Input
            AppTextField(
              label: 'Full name',
              hintText: 'John Doe',
              controller: _nameController,
              validator: Validators.name,
              isRequired: true,
            ),
            const SizedBox(height: 16),
            // Email Input
            AppTextField(
              label: 'Email address',
              hintText: 'you@example.com',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
              isRequired: true,
            ),
            const SizedBox(height: 16),
            // Phone Input
            AppTextField(
              label: 'Phone (optional)',
              hintText: '+91 9876543210',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            // Password Input
            Obx(
              () => AppTextField(
                label: 'Password',
                hintText: '••••••••',
                controller: _passwordController,
                obscureText: _obscurePassword.value,
                validator: Validators.password,
                isRequired: true,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword.value
                        ? Icons.visibility_off
                        : Icons.visibility,
                    size: 20,
                    color: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForegroundLight,
                  ),
                  onPressed: () => _obscurePassword.toggle(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Confirm Password Input
            AppTextField(
              label: 'Confirm password',
              hintText: '••••••••',
              controller: _confirmPasswordController,
              obscureText: true,
              validator: (val) =>
                  Validators.confirmPassword(val, _passwordController.text),
              isRequired: true,
            ),
            const SizedBox(height: 24),
            // Submit Button
            Obx(
              () => AppButton(
                text: 'Create account',
                width: double.infinity,
                height: 44,
                isLoading: controller.isLoading.value,
                onPressed: _onRegister,
              ),
            ),
            const SizedBox(height: 24),
            // Login Navigation Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account? ',
                  style: AppTypography.caption(isDark: isDark),
                ),
                GestureDetector(
                  onTap: () => Get.toNamed('/login'),
                  child: const Text(
                    'Sign in',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
