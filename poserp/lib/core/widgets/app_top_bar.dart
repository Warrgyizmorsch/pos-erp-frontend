import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../modules/authentication/controllers/auth_controller.dart';
import '../constants/app_colors.dart';
import '../constants/app_radius.dart';
import '../constants/app_roles.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showBackButton;
  final List<Widget>? actions;
  final String? userRole;

  const AppTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBackButton = true,
    this.actions,
    this.userRole,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60.0);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canPop = ModalRoute.of(context)?.canPop ?? false;

    return AppBar(
      elevation: 0,
      centerTitle: false,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
      foregroundColor: isDark
          ? AppColors.foregroundDark
          : AppColors.foregroundLight,
      leading: (showBackButton && canPop)
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              onPressed: () => Get.back(),
            )
          : null,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.foregroundDark
                        : AppColors.foregroundLight,
                  ),
                ),
              ),
              if (userRole != null && userRole!.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(30),
                    borderRadius: AppRadius.full,
                  ),
                  child: Text(
                    AppRoles.getLabel(userRole!).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (subtitle != null && subtitle!.isNotEmpty)
            Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? AppColors.mutedForegroundDark
                    : AppColors.mutedForegroundLight,
              ),
            ),
        ],
      ),
      actions:
          actions ??
          [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, size: 22),
              tooltip: 'Notifications',
              onPressed: () => Get.toNamed('/notifications'),
            ),
            PopupMenuButton<String>(
              icon: CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.primary.withAlpha(30),
                child: const Icon(
                  Icons.person_outline,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              tooltip: 'Profile & Account Options',
              onSelected: (val) {
                if (val == 'settings') {
                  Get.toNamed('/settings');
                } else if (val == 'logout') {
                  _showLogoutDialog(context);
                }
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(
                        Icons.settings_outlined,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 8),
                      Text('Profile & Settings'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(
                        Icons.logout_rounded,
                        size: 18,
                        color: AppColors.danger,
                      ),
                      SizedBox(width: 8),
                      Text('Logout', style: TextStyle(color: AppColors.danger)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
          ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
        title: const Text('Confirm Logout'),
        content: const Text(
          'Are you sure you want to end your session and log out of POS ERP?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Get.back();
              if (Get.isRegistered<AuthController>()) {
                Get.find<AuthController>().logout();
              } else {
                Get.offAllNamed('/login');
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
