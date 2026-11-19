import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_sizes.dart';
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

  void _fillAndLogin(String email, String password) {
    _emailController.text = email;
    _passwordController.text = password;
    _onLogin();
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
              'Sign In',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Access your POS ERP cashier terminal & business control center',
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppColors.mutedForegroundDark
                    : AppColors.mutedForegroundLight,
              ),
            ),
            const SizedBox(height: 24),

            // Email Field
            AppTextField(
              label: 'Email address',
              hintText: 'admin@poserp.com',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
              isRequired: true,
            ),
            const SizedBox(height: 16),

            // Password Field
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
            const SizedBox(height: 8),

            // Forgot Password Link
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  minimumSize: const Size(0, AppSizes.minTouchTarget),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () => Get.toNamed('/forgot-password'),
                child: const Text(
                  'Forgot password?',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Sign In Button
            Obx(
              () => AppButton(
                text: 'Sign In to Account',
                icon: const Icon(Icons.login_rounded, size: 18),
                width: double.infinity,
                height: AppSizes.buttonHeightMd,
                isLoading: controller.isLoading.value,
                onPressed: _onLogin,
              ),
            ),
            const SizedBox(height: 20),

            // Register Account Navigation Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account? ",
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
                  onPressed: () => Get.toNamed('/register'),
                  child: const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Quick Demo Role Login Section
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'QUICK DEMO LOGINS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'Tap to Login',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Admin & Manager Row
                  Row(
                    children: [
                      Expanded(
                        child: _DemoRoleButton(
                          title: 'Admin',
                          subtitle: 'admin@poserp.com',
                          icon: Icons.shield_outlined,
                          color: AppColors.primary,
                          onPressed: () =>
                              _fillAndLogin('admin@poserp.com', 'admin123'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _DemoRoleButton(
                          title: 'Manager',
                          subtitle: 'manager@poserp.com',
                          icon: Icons.manage_accounts_outlined,
                          color: Colors.orange,
                          onPressed: () =>
                              _fillAndLogin('manager@poserp.com', 'manager123'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Accountant & Stock Manager Row
                  Row(
                    children: [
                      Expanded(
                        child: _DemoRoleButton(
                          title: 'Accountant',
                          subtitle: 'accountant@poserp.com',
                          icon: Icons.account_balance_wallet_outlined,
                          color: AppColors.success,
                          onPressed: () => _fillAndLogin(
                            'accountant@poserp.com',
                            'accountant123',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _DemoRoleButton(
                          title: 'Stock Mgr',
                          subtitle: 'stockmanager@poserp.com',
                          icon: Icons.inventory_2_outlined,
                          color: Colors.cyan,
                          onPressed: () => _fillAndLogin(
                            'stockmanager@poserp.com',
                            'stockmanager123',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Cashier Button Full Width
                  _DemoRoleButton(
                    title: 'Cashier Terminal',
                    subtitle: 'cashier@poserp.com',
                    icon: Icons.point_of_sale_rounded,
                    color: Colors.purple,
                    isFullWidth: true,
                    onPressed: () =>
                        _fillAndLogin('cashier@poserp.com', 'cashier123'),
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

class _DemoRoleButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final bool isFullWidth;

  const _DemoRoleButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        minimumSize: const Size(0, AppSizes.minTouchTarget),
        side: BorderSide(color: color.withAlpha(80)),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.md),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: isFullWidth
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Column(
              crossAxisAlignment: isFullWidth
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 9, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
