import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
        ],
      ),
      actions:
          actions ??
          [
            IconButton(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.notifications_outlined, size: 22),
                  Positioned(
                    right: -1,
                    top: -1,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppColors.danger,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        '1',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              tooltip: 'Notifications',
              onPressed: () => Get.toNamed('/notifications'),
            ),
            const SizedBox(width: 8),
          ],
    );
  }
}
