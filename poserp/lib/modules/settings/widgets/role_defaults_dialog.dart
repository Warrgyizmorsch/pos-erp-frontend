import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/app_button.dart';
import '../controllers/user_management_controller.dart';

class RoleDefaultsDialog extends StatelessWidget {
  final UserManagementController controller;

  const RoleDefaultsDialog({super.key, required this.controller});

  static Future<void> show(
    BuildContext context,
    UserManagementController controller,
  ) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RoleDefaultsDialog(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final role = controller.editingRole.value;
    final roleName = role?.name ?? 'Role';
    final formattedRoleName = roleName
        .split('_')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.xl),
      backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 720,
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
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.indigo.withAlpha(20),
                                borderRadius: AppRadius.sm,
                              ),
                              child: const Icon(
                                Icons.tune_rounded,
                                color: Colors.indigo,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '$formattedRoleName — Default Permissions',
                                style: const TextStyle(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Configure the baseline module permissions assigned when creating a "$formattedRoleName" user.',
                          style: TextStyle(
                            fontSize: 11.5,
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

            // Quick select bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  Obx(
                    () => Text(
                      'Access: ${controller.rolePermissions.length} of ${UserManagementController.allModules.length} Modules',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Wrap(
                    spacing: 4,
                    children: [
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          visualDensity: VisualDensity.compact,
                        ),
                        icon: const Icon(Icons.restart_alt_rounded, size: 14),
                        label: const Text('Reset Defaults', style: TextStyle(fontSize: 11)),
                        onPressed: () => controller.resetRoleToSystemDefaults(),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () {
                          controller.rolePermissions.assignAll(
                            UserManagementController.allModules,
                          );
                        },
                        child: const Text('Select All', style: TextStyle(fontSize: 11)),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () => controller.rolePermissions.clear(),
                        child: const Text('Clear All', style: TextStyle(fontSize: 11)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Checkbox Body Categorized
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: LayoutBuilder(
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
                              .where((m) => controller.rolePermissions.contains(m))
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
                                      onTap: () => controller.toggleCategoryForRole(modules),
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

                                // Category Module Items
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: modules.map((module) {
                                    final isChecked = controller.rolePermissions.contains(module);
                                    final title = UserManagementController.formatModuleName(module);

                                    return InkWell(
                                      borderRadius: AppRadius.md,
                                      onTap: () => controller.toggleRolePermission(module),
                                      child: Container(
                                        width: itemWidth,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isChecked
                                              ? Colors.indigo.withAlpha(20)
                                              : (isDark ? AppColors.inputDark : Colors.grey[50]),
                                          borderRadius: AppRadius.md,
                                          border: Border.all(
                                            color: isChecked
                                                ? Colors.indigo
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
                                              color: isChecked ? Colors.indigo : Colors.grey,
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
                                                          : Colors.indigo[900])
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
                      text: 'Save Defaults',
                      variant: AppButtonVariant.primary,
                      height: AppSizes.buttonHeightMd,
                      isLoading: controller.updatingId.value ==
                          'role-${role?.id}',
                      onPressed: () async {
                        final success =
                            await controller.saveRolePermissions();
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
}
