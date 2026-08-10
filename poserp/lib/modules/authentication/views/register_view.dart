import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
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
            const Text(
              'Create Account',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Get started with POS ERP for your retail or warehouse store',
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppColors.mutedForegroundDark
                    : AppColors.mutedForegroundLight,
              ),
            ),
            const SizedBox(height: 24),

            // Full Name Input
            AppTextField(
              label: 'Full name',
              hintText: 'John Doe',
              controller: _nameController,
              validator: Validators.name,
              isRequired: true,
            ),
            const SizedBox(height: 14),

            // Email Input
            AppTextField(
              label: 'Email address',
              hintText: 'you@example.com',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
              isRequired: true,
            ),
            const SizedBox(height: 14),

            // Phone Input
            AppTextField(
              label: 'Phone number (optional)',
              hintText: '+91 9876543210',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 14),

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
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    size: 20,
                    color: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForegroundLight,
                  ),
                  onPressed: () => _obscurePassword.toggle(),
                ),
              ),
            ),
            const SizedBox(height: 14),

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

            // Register Button
            Obx(
              () => AppButton(
                text: 'Create Account',
                icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                width: double.infinity,
                height: AppSizes.buttonHeightMd,
                isLoading: controller.isLoading.value,
                onPressed: _onRegister,
              ),
            ),
            const SizedBox(height: 20),

            // Sign In Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account? ',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.mutedForegroundDark
                        : AppColors.mutedForegroundLight,
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    minimumSize: const Size(0, AppSizes.minTouchTarget),
                  ),
                  onPressed: () => Get.toNamed('/login'),
                  child: const Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
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
