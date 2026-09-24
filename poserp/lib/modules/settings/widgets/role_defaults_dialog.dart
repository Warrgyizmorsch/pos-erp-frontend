import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
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
          maxWidth: 680,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
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
                          '$formattedRoleName — Default Permissions',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Select the modules that users with the "$formattedRoleName" role will access by default.',
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

            // Quick select bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(
                    () => Text(
                      'Default Access: ${controller.rolePermissions.length} of ${UserManagementController.allModules.length} Modules',
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
                          controller.rolePermissions.assignAll(
                            UserManagementController.allModules,
                          );
                        },
                        child: const Text('Select All', style: TextStyle(fontSize: 11)),
                      ),
                      TextButton(
                        onPressed: () => controller.rolePermissions.clear(),
                        child: const Text('Clear All', style: TextStyle(fontSize: 11)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Checkbox Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Obx(
                  () => Wrap(
                    spacing: 12,
                    runSpacing: 10,
                    children: UserManagementController.allModules.map((module) {
                      final isChecked = controller.rolePermissions.contains(module);
                      final title = UserManagementController.formatModuleName(module);

                      return InkWell(
                        borderRadius: AppRadius.md,
                        onTap: () => controller.toggleRolePermission(module),
                        child: Container(
                          width: 190,
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
                                    fontSize: 12.5,
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
