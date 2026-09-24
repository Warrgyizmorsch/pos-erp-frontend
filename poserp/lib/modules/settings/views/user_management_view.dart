import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../data/models/role.dart';
import '../../../../data/models/user.dart';
import '../controllers/user_management_controller.dart';
import '../widgets/role_defaults_dialog.dart';
import '../widgets/user_form_dialog.dart';

class UserManagementView extends GetView<UserManagementController> {
  const UserManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppTopBar(
        title: 'User Management',
        subtitle: 'Manage team members, roles & module permissions',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () => controller.fetchData(),
          ),
          const SizedBox(width: 4),
          AppButton(
            text: 'Add User',
            icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
            height: AppSizes.buttonHeightSm,
            onPressed: () {
              controller.openAddUserDialog();
              UserFormDialog.show(context, controller);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Navigation Tabs Bar
          Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                  ),
                ),
              ),
              child: Row(
                children: [
                  _buildTabPill(
                    index: 0,
                    label: 'Users',
                    count: controller.users.length,
                    icon: Icons.people_outline_rounded,
                    isActive: controller.selectedTab.value == 0,
                  ),
                  const SizedBox(width: 8),
                  _buildTabPill(
                    index: 1,
                    label: 'Roles & Defaults',
                    count: controller.roles.length,
                    icon: Icons.key_rounded,
                    isActive: controller.selectedTab.value == 1,
                  ),
                ],
              ),
            ),
          ),

          // Tab Content
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: LoadingIndicator());
              }

              if (controller.selectedTab.value == 0) {
                return _buildUsersTab(context, isDark);
              } else {
                return _buildRolesTab(context, isDark);
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTabPill({
    required int index,
    required String label,
    required int count,
    required IconData icon,
    required bool isActive,
  }) {
    return InkWell(
      borderRadius: AppRadius.full,
      onTap: () => controller.selectedTab.value = index,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary
              : AppColors.primary.withAlpha(15),
          borderRadius: AppRadius.full,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.white : AppColors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              '$label ($count)',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? Colors.white : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersTab(BuildContext context, bool isDark) {
    return Column(
      children: [
        // Search & Role Filter Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                onChanged: (val) => controller.searchQuery.value = val,
                decoration: InputDecoration(
                  hintText: 'Search by user name, email, or phone...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  filled: true,
                  fillColor: isDark ? AppColors.cardDark : Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
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
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildRoleFilterChip('all', 'All Roles'),
                    _buildRoleFilterChip('admin', 'Admin'),
                    _buildRoleFilterChip('manager', 'Manager'),
                    _buildRoleFilterChip('accountant', 'Accountant'),
                    _buildRoleFilterChip('stock_manager', 'Stock Manager'),
                    _buildRoleFilterChip('cashier', 'Cashier'),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Users List
        Expanded(
          child: Obx(() {
            final userList = controller.filteredUsers;
            if (userList.isEmpty) {
              return const EmptyState(
                title: 'No users found',
                description: 'No team members match your current filter or search criteria.',
                icon: Icons.person_off_rounded,
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: userList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final user = userList[index];
                return _buildUserCard(context, user, isDark);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildRoleFilterChip(String value, String label) {
    return Obx(() {
      final isSelected = controller.selectedRoleFilter.value == value;
      return Padding(
        padding: const EdgeInsets.only(right: 6.0),
        child: ChoiceChip(
          label: Text(label, style: const TextStyle(fontSize: 11.5)),
          selected: isSelected,
          onSelected: (_) => controller.selectedRoleFilter.value = value,
          selectedColor: AppColors.primary,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          showCheckmark: false,
          visualDensity: VisualDensity.compact,
        ),
      );
    });
  }

  Widget _buildUserCard(BuildContext context, User user, bool isDark) {
    final isSelf = user.id == controller.currentUser.value?.id;
    final roleColor = _getRoleColor(user.role);
    final initial = user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U';

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // User Avatar Circle
          CircleAvatar(
            radius: 22,
            backgroundColor: roleColor.withAlpha(35),
            child: Text(
              initial,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: roleColor,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (!user.isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withAlpha(20),
                          borderRadius: AppRadius.sm,
                        ),
                        child: const Text(
                          'INACTIVE',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: AppColors.danger,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${user.email}${user.phone != null && user.phone!.isNotEmpty ? ' • ${user.phone}' : ''}',
                  style: TextStyle(fontSize: 11.5, color: Colors.grey[600]),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    // Role Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: roleColor.withAlpha(20),
                        borderRadius: AppRadius.full,
                        border: Border.all(color: roleColor.withAlpha(50)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSelf) ...[
                            const Icon(
                              Icons.security_rounded,
                              size: 11,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'ADMIN (YOU)',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ] else ...[
                            Text(
                              user.role.replaceAll('_', ' ').toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: roleColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Permissions count badge
                    if (user.permissions.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.indigo.withAlpha(15),
                          borderRadius: AppRadius.full,
                        ),
                        child: Text(
                          '${user.permissions.length} Custom Modules',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.indigo,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.withAlpha(20),
                          borderRadius: AppRadius.full,
                        ),
                        child: Text(
                          'Inheriting Role Defaults',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                tooltip: 'Edit User & Permissions',
                onPressed: () {
                  controller.openEditUserDialog(user);
                  UserFormDialog.show(context, controller);
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: isSelf ? Colors.grey : AppColors.danger,
                ),
                tooltip: isSelf ? 'Cannot delete self' : 'Delete User',
                onPressed: isSelf
                    ? null
                    : () {
                        showDialog(
                          context: context,
                          builder: (ctx) => ConfirmDialog(
                            title: 'Delete User?',
                            description:
                                'Are you sure you want to permanently delete "${user.name}" (${user.email})? This action cannot be undone.',
                            confirmLabel: 'Delete User',
                            isDestructive: true,
                            onConfirm: () async {
                              Navigator.of(ctx).pop();
                              await controller.deleteUser(user);
                            },
                          ),
                        );
                      },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRolesTab(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info Banner
          Container(
            padding: const EdgeInsets.all(14),
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
              children: [
                const Icon(
                  Icons.admin_panel_settings_rounded,
                  color: Colors.indigo,
                  size: 26,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Role Permissions Matrix & Defaults',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Define the standard module permissions granted to team members when assigned a specific role.',
                        style: TextStyle(fontSize: 11.5, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Role Cards Grid
          Obx(
            () => ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.roles.length,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final role = controller.roles[index];
                return _buildRoleCard(context, role, isDark);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard(BuildContext context, Role role, bool isDark) {
    final roleColor = _getRoleColor(role.name);
    final formattedName = role.name
        .split('_')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: roleColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formattedName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: roleColor.withAlpha(20),
                      borderRadius: AppRadius.full,
                    ),
                    child: Text(
                      '${role.permissions.length} of ${UserManagementController.allModules.length} Modules',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: roleColor,
                      ),
                    ),
                  ),
                ],
              ),
              AppButton(
                text: 'Edit Defaults',
                variant: AppButtonVariant.outline,
                height: AppSizes.buttonHeightSm,
                icon: const Icon(Icons.tune_rounded, size: 14),
                onPressed: () {
                  controller.openRoleDialog(role);
                  RoleDefaultsDialog.show(context, controller);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Modules badges
          if (role.permissions.isEmpty)
            Text(
              'No default module permissions assigned.',
              style: TextStyle(fontSize: 12, color: Colors.grey[500], fontStyle: FontStyle.italic),
            )
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ...role.permissions.take(10).map((mod) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.inputDark : Colors.grey[100],
                      borderRadius: AppRadius.sm,
                      border: Border.all(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                      ),
                    ),
                    child: Text(
                      UserManagementController.formatModuleName(mod),
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.foregroundDark
                            : AppColors.foregroundLight,
                      ),
                    ),
                  );
                }),
                if (role.permissions.length > 10)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(15),
                      borderRadius: AppRadius.sm,
                    ),
                    child: Text(
                      '+${role.permissions.length - 10} more',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return AppColors.primary;
      case 'manager':
        return Colors.deepPurple;
      case 'accountant':
        return Colors.teal;
      case 'stock_manager':
        return Colors.amber[800] ?? Colors.orange;
      case 'cashier':
      default:
        return AppColors.info;
    }
  }
}
