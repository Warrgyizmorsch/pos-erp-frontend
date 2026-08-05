import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_layout_wrapper.dart';

class LoginView extends GetView<AuthController> {
  LoginView({super.key});

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'admin@poserp.com');
  final _passwordController = TextEditingController(text: 'admin123');
  final RxBool _obscurePassword = true.obs;

  void _onLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      controller.login(_emailController.text.trim(), _passwordController.text);
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
              'Welcome back',
              style: AppTypography.pageTitle(isDark: isDark),
            ),
            const SizedBox(height: 4),
            Text(
              'Sign in to your account to continue',
              style: AppTypography.caption(isDark: isDark),
            ),
            const SizedBox(height: 32),
            // Email Input
            AppTextField(
              label: 'Email address',
              hintText: 'admin@poserp.com',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
              isRequired: true,
            ),
            const SizedBox(height: 20),
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
            const SizedBox(height: 8),
            // Forgot Password Link
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () => Get.toNamed('/forgot-password'),
                child: const Text(
                  'Forgot password?',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Submit Button
            Obx(
              () => AppButton(
                text: 'Sign in',
                width: double.infinity,
                height: 44,
                isLoading: controller.isLoading.value,
                onPressed: _onLogin,
              ),
            ),
            const SizedBox(height: 24),
            // Register Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account? ",
                  style: AppTypography.caption(isDark: isDark),
                ),
                GestureDetector(
                  onTap: () => Get.toNamed('/register'),
                  child: const Text(
                    'Create account',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Demo Credentials Tile
            AppCard(
              padding: const EdgeInsets.all(16),
              backgroundColor: isDark
                  ? AppColors.secondaryDark.withValues(alpha: 0.5)
                  : AppColors.secondaryLight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Demo Credentials',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.mutedForegroundDark
                          : AppColors.mutedForegroundLight,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Admin: admin@poserp.com / admin123',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.foregroundDark
                          : AppColors.foregroundLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Cashier: cashier@poserp.com / cashier123',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.foregroundDark
                          : AppColors.foregroundLight,
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
