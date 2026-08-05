import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../authentication/controllers/auth_controller.dart';

class DashboardPlaceholderView extends GetView<AuthController> {
  const DashboardPlaceholderView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = controller.currentUser.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('POS ERP — Dashboard'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () => controller.logout(),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: AppCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: AppColors.success,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Authentication Successful!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Phase 1 Shared Foundation & Auth Module active.',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const Divider(height: 32),
                  if (user != null) ...[
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(user.name),
                      subtitle: Text(
                        '${user.email} (${user.role.toUpperCase()})',
                      ),
                    ),
                  ],
                  AppButton(
                    text: 'Open Categories Module',
                    variant: AppButtonVariant.primary,
                    width: double.infinity,
                    onPressed: () => Get.toNamed('/categories'),
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    text: 'Open Subcategories Module',
                    variant: AppButtonVariant.secondary,
                    width: double.infinity,
                    onPressed: () => Get.toNamed('/subcategories'),
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    text: 'Open Products Catalog Module',
                    variant: AppButtonVariant.primary,
                    width: double.infinity,
                    onPressed: () => Get.toNamed('/products'),
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    text: 'Open Opening Stock Module',
                    variant: AppButtonVariant.secondary,
                    width: double.infinity,
                    onPressed: () => Get.toNamed('/opening-stock'),
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    text: 'Sign Out',
                    variant: AppButtonVariant.destructive,
                    width: double.infinity,
                    onPressed: () => controller.logout(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
