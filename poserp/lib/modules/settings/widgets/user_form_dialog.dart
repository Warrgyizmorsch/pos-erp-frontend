import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/user_management_controller.dart';

class UserFormDialog extends StatelessWidget {
  final UserManagementController controller;

  const UserFormDialog({super.key, required this.controller});

  static Future<void> show(
    BuildContext context,
    UserManagementController controller,
  ) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => UserFormDialog(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = controller.editingUser.value != null;
    final isSelf = controller.editingUser.value?.id ==
        controller.currentUser.value?.id;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.xl),
      backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 680,
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditing ? 'Edit User' : 'Add New User',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isEditing
                              ? 'Update user profile, role, and fine-grained permissions.'
                              : 'Create a new team member and configure their access rights.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Tabs Bar
            Obx(
              () => Container(
                color: isDark ? Colors.black12 : Colors.grey[50],
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildTabButton(
                      index: 0,
                      label: 'Profile & Role',
                      icon: Icons.person_outline_rounded,
                      isActive: controller.userDialogTab.value == 0,
                    ),
                    const SizedBox(width: 8),
                    _buildTabButton(
                      index: 1,
                      label:
                          'Module Permissions (${controller.userPermissions.length})',
                      icon: Icons.security_rounded,
                      isActive: controller.userDialogTab.value == 1,
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),

            // Tab Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Obx(() {
                  if (controller.userDialogTab.value == 0) {
                    return _buildProfileTab(context, isDark, isEditing, isSelf);
                  } else {
                    return _buildPermissionsTab(context, isDark);
                  }
                }),
              ),
            ),
            const Divider(height: 1),

            // Footer
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                    text: 'Cancel',
                    variant: AppButtonVariant.outline,
                    onPressed: () => Get.back(),
                  ),
                  const SizedBox(width: 12),
                  Obx(
                    () => AppButton(
                      text: isEditing ? 'Save Changes' : 'Create User',
                      variant: AppButtonVariant.primary,
                      isLoading: controller.isSaving.value,
                      onPressed: () async {
                        final success = await controller.saveUser();
                        if (success) {
                          Get.back();
                        }
                      },
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

  Widget _buildTabButton({
    required int index,
    required String label,
    required IconData icon,
    required bool isActive,
  }) {
    return InkWell(
      onTap: () => controller.userDialogTab.value = index,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? AppColors.primary : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 17,
              color: isActive ? AppColors.primary : Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? AppColors.primary : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab(
    BuildContext context,
    bool isDark,
    bool isEditing,
    bool isSelf,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          label: 'Full Name',
          hintText: 'e.g. John Doe',
          isRequired: true,
          controller: controller.nameController,
        ),
        const SizedBox(height: 14),
        AppTextField(
          label: 'Email Address',
          hintText: 'e.g. user@store.com',
          isRequired: true,
          keyboardType: TextInputType.emailAddress,
          controller: controller.emailController,
        ),
        const SizedBox(height: 14),
        AppTextField(
          label: 'Phone Number',
          hintText: 'e.g. +91 9876543210',
          keyboardType: TextInputType.phone,
          controller: controller.phoneController,
        ),
        const SizedBox(height: 14),

        // System Role Selector
        Text(
          'System Role *',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.foregroundDark
                : AppColors.foregroundLight,
          ),
        ),
        const SizedBox(height: 6),
        Obx(
          () => DropdownButtonFormField<String>(
            initialValue: controller.selectedUserRole.value,
            decoration: InputDecoration(
              filled: true,
              fillColor: isDark ? AppColors.inputDark : Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: AppRadius.md,
                borderSide: BorderSide(
                  color: isDark
                      ? AppColors.borderDark
                      : AppColors.borderLight,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.md,
                borderSide: BorderSide(
                  color: isDark
                      ? AppColors.borderDark
                      : AppColors.borderLight,
                ),
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'admin', child: Text('Admin')),
              DropdownMenuItem(value: 'manager', child: Text('Manager')),
              DropdownMenuItem(value: 'accountant', child: Text('Accountant')),
              DropdownMenuItem(
                value: 'stock_manager',
                child: Text('Stock Manager'),
              ),
              DropdownMenuItem(value: 'cashier', child: Text('Cashier')),
            ],
            onChanged: isSelf
                ? null
                : (val) {
                    if (val != null) {
                      controller.selectedUserRole.value = val;
                      controller.loadDefaultsForSelectedRole();
                    }
                  },
          ),
        ),
        if (isSelf) ...[
          const SizedBox(height: 4),
          Text(
            'You cannot change your own role.',
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
        ],
        const SizedBox(height: 14),

        // Password field
        Text(
          isEditing ? 'New Password (Optional)' : 'Password *',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.foregroundDark
                : AppColors.foregroundLight,
          ),
        ),
        const SizedBox(height: 6),
        Obx(
          () => TextField(
            controller: controller.passwordController,
            obscureText: !controller.showPassword.value,
            decoration: InputDecoration(
              filled: true,
              fillColor: isDark ? AppColors.inputDark : Colors.grey[50],
              hintText: isEditing
                  ? 'Leave blank to keep existing password'
                  : 'Enter password for login',
              hintStyle: TextStyle(fontSize: 13, color: Colors.grey[500]),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: AppRadius.md,
                borderSide: BorderSide(
                  color: isDark
                      ? AppColors.borderDark
                      : AppColors.borderLight,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.md,
                borderSide: BorderSide(
                  color: isDark
                      ? AppColors.borderDark
                      : AppColors.borderLight,
                ),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  controller.showPassword.value
                      ? Icons.visibility_off
                      : Icons.visibility,
                  size: 20,
                  color: Colors.grey,
                ),
                onPressed: () => controller.showPassword.toggle(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Account Status Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? AppColors.inputDark : Colors.grey[50],
            borderRadius: AppRadius.md,
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Account Status',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Determine if this user can log into the system.',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Obx(
                () => Switch(
                  value: controller.isUserActive.value,
                  activeThumbColor: AppColors.primary,
                  onChanged: isSelf
                      ? null
                      : (val) => controller.isUserActive.value = val,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionsTab(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Load Defaults Banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.inputDark : Colors.indigo.withAlpha(15),
            borderRadius: AppRadius.md,
            border: Border.all(
              color: isDark
                  ? AppColors.borderDark
                  : Colors.indigo.withAlpha(40),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.tune_rounded,
                color: Colors.indigo,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fine-Grained Module Overrides',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.indigo[900],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'By default, user inherits permissions from the assigned role. Check or uncheck modules below to customize access.',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AppButton(
                text: 'Load Defaults',
                variant: AppButtonVariant.outline,
                height: AppSizes.buttonHeightSm,
                icon: const Icon(Icons.refresh_rounded, size: 14),
                onPressed: () => controller.loadDefaultsForSelectedRole(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Quick select actions
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(
              () => Text(
                'Granted Access: ${controller.userPermissions.length} of ${UserManagementController.allModules.length} Modules',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    controller.userPermissions.assignAll(
                      UserManagementController.allModules,
                    );
                  },
                  child: const Text('Select All', style: TextStyle(fontSize: 11)),
                ),
                TextButton(
                  onPressed: () => controller.userPermissions.clear(),
                  child: const Text('Clear All', style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Checkboxes Categorized Grid
        LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = constraints.maxWidth > 520
                ? (constraints.maxWidth - 24) / 3
                : (constraints.maxWidth - 12) / 2;

            return Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: UserManagementController.moduleCategories.entries.map((cat) {
                  final categoryTitle = cat.key;
                  final modules = cat.value;
                  final selectedInCat = modules
                      .where((m) => controller.userPermissions.contains(m))
                      .length;
                  final isAllSelected = selectedInCat == modules.length;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  categoryTitle,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 1.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isAllSelected
                                        ? AppColors.success.withAlpha(20)
                                        : Colors.grey.withAlpha(25),
                                    borderRadius: AppRadius.full,
                                  ),
                                  child: Text(
                                    '$selectedInCat/${modules.length}',
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                      color: isAllSelected
                                          ? AppColors.success
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            InkWell(
                              borderRadius: AppRadius.sm,
                              onTap: () => controller.toggleCategoryForUser(modules),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                child: Text(
                                  isAllSelected ? 'Deselect Group' : 'Select Group',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Module items
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: modules.map((module) {
                            final isChecked = controller.userPermissions.contains(module);
                            final title = UserManagementController.formatModuleName(module);

                            return InkWell(
                              borderRadius: AppRadius.md,
                              onTap: () => controller.toggleUserPermission(module),
                              child: Container(
                                width: itemWidth,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isChecked
                                      ? AppColors.primary.withAlpha(18)
                                      : (isDark ? AppColors.inputDark : Colors.grey[50]),
                                  borderRadius: AppRadius.md,
                                  border: Border.all(
                                    color: isChecked
                                        ? AppColors.primary
                                        : (isDark
                                            ? AppColors.borderDark
                                            : AppColors.borderLight),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isChecked
                                          ? Icons.check_box_rounded
                                          : Icons.check_box_outline_blank_rounded,
                                      size: 18,
                                      color: isChecked ? AppColors.primary : Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        title,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: isChecked
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: isChecked
                                              ? (isDark
                                                  ? Colors.white
                                                  : AppColors.primary)
                                              : (isDark
                                                  ? AppColors.foregroundDark
                                                  : AppColors.foregroundLight),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }
}
