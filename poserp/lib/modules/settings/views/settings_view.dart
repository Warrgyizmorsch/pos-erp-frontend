import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../controllers/settings_controller.dart';
import '../widgets/change_password_dialog.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppTopBar(
        title: 'System Settings',
        subtitle: 'User profile, app preferences & accounting toggles',
        actions: [
          Obx(
            () => IconButton(
              icon: const Icon(Icons.save_rounded, size: 24),
              tooltip: 'Save Settings',
              onPressed: controller.isSaving.value
                  ? null
                  : () => controller.saveProfile(),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section Card
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.person_outline,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'User Profile & Credentials',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Obx(
                        () => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(20),
                            borderRadius: AppRadius.full,
                          ),
                          child: Text(
                            controller.role.value.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 600;

                      final nameField = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Full Name',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Obx(
                            () => TextField(
                              controller:
                                  TextEditingController(
                                      text: controller.name.value,
                                    )
                                    ..selection = TextSelection.collapsed(
                                      offset: controller.name.value.length,
                                    ),
                              onChanged: (val) => controller.name.value = val,
                              style: const TextStyle(fontSize: 13),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                filled: true,
                                fillColor: isDark
                                    ? AppColors.inputDark
                                    : Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: AppRadius.md,
                                  borderSide: BorderSide(
                                    color: isDark
                                        ? AppColors.borderDark
                                        : AppColors.borderLight,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );

                      final phoneField = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Phone Number',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Obx(
                            () => TextField(
                              controller:
                                  TextEditingController(
                                      text: controller.phone.value,
                                    )
                                    ..selection = TextSelection.collapsed(
                                      offset: controller.phone.value.length,
                                    ),
                              onChanged: (val) => controller.phone.value = val,
                              style: const TextStyle(fontSize: 13),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                filled: true,
                                fillColor: isDark
                                    ? AppColors.inputDark
                                    : Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: AppRadius.md,
                                  borderSide: BorderSide(
                                    color: isDark
                                        ? AppColors.borderDark
                                        : AppColors.borderLight,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );

                      if (isMobile) {
                        return Column(
                          children: [
                            nameField,
                            const SizedBox(height: 12),
                            phoneField,
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(child: nameField),
                          const SizedBox(width: 12),
                          Expanded(child: phoneField),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(
                        () => Text(
                          'Email Address: ${controller.email.value.isNotEmpty ? controller.email.value : "admin@poserp.com"}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      AppButton(
                        text: 'Change Password',
                        variant: AppButtonVariant.outline,
                        icon: const Icon(Icons.lock_outline, size: 16),
                        height: 38,
                        onPressed: () =>
                            Get.dialog(const ChangePasswordDialog()),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Application Preferences Card
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.tune_outlined,
                        color: AppColors.info,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Application Preferences & Modules',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // Theme Switcher
                  Obx(
                    () => SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Dark Mode Appearance',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: const Text(
                        'Switch UI palette between Dark and Light mode.',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      value: controller.isDarkTheme.value,
                      activeThumbColor: AppColors.primary,
                      onChanged: (val) {
                        controller.isDarkTheme.value = val;
                        Get.changeThemeMode(
                          val ? ThemeMode.dark : ThemeMode.light,
                        );
                      },
                    ),
                  ),
                  const Divider(height: 16),

                  // Accounting Toggle
                  Obx(
                    () => SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Double-Entry Accounting Engine',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: const Text(
                        'Automatically post journal vouchers for invoices, bills & cash/bank.',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      value: controller.doubleEntryAccountingEnabled.value,
                      activeThumbColor: AppColors.success,
                      onChanged: (val) =>
                          controller.doubleEntryAccountingEnabled.value = val,
                    ),
                  ),
                  const Divider(height: 16),

                  // Thermal Printer Auto Print
                  Obx(
                    () => SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Auto-Print POS Thermal Receipts',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: const Text(
                        'Automatically print receipts upon cashier sale completion.',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      value: controller.autoPrintReceipts.value,
                      activeThumbColor: AppColors.warning,
                      onChanged: (val) =>
                          controller.autoPrintReceipts.value = val,
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
