import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_card.dart';
import '../models/activity_log.dart';
import 'activity_log_detail_dialog.dart';

class ActivityLogCard extends StatelessWidget {
  final ActivityLog log;

  const ActivityLogCard({super.key, required this.log});

  static Color getActionColor(String actionStr) {
    switch (actionStr.toLowerCase()) {
      case 'create':
      case 'add':
        return Colors.green;
      case 'update':
      case 'edit':
        return Colors.blue;
      case 'delete':
      case 'remove':
      case 'cancel':
        return Colors.red;
      case 'login':
        return Colors.teal;
      case 'logout':
        return Colors.orange;
      case 'stock_adjust':
        return Colors.purple;
      case 'sale':
        return Colors.green;
      case 'purchase':
        return Colors.indigo;
      default:
        return Colors.amber[800] ?? Colors.amber;
    }
  }

  static IconData getActionIcon(String actionStr) {
    switch (actionStr.toLowerCase()) {
      case 'create':
      case 'add':
        return Icons.add_circle_outline;
      case 'update':
      case 'edit':
        return Icons.edit_outlined;
      case 'delete':
      case 'remove':
      case 'cancel':
        return Icons.delete_outline;
      case 'login':
        return Icons.login_rounded;
      case 'logout':
        return Icons.logout_rounded;
      case 'stock_adjust':
        return Icons.tune_outlined;
      case 'sale':
        return Icons.shopping_cart_outlined;
      case 'purchase':
        return Icons.shopping_bag_outlined;
      default:
        return Icons.history_outlined;
    }
  }

  static IconData getModuleIcon(String module) {
    switch (module.toLowerCase()) {
      case 'product':
        return Icons.inventory_2_outlined;
      case 'category':
      case 'subcategory':
        return Icons.category_outlined;
      case 'customer':
        return Icons.people_outline;
      case 'supplier':
        return Icons.local_shipping_outlined;
      case 'transporter':
        return Icons.commute_outlined;
      case 'sale':
        return Icons.point_of_sale_outlined;
      case 'purchase':
        return Icons.receipt_outlined;
      case 'expense':
        return Icons.receipt_long_outlined;
      case 'shift':
        return Icons.access_time_outlined;
      case 'auth':
        return Icons.lock_person_outlined;
      case 'inventory':
        return Icons.warehouse_outlined;
      case 'cashbank':
        return Icons.account_balance_outlined;
      default:
        return Icons.layers_outlined;
    }
  }

  String _formatRelativeTime(String dateStr) {
    final parsed = DateTime.tryParse(dateStr);
    if (parsed == null) return dateStr.split('T')[0];

    final local = parsed.toLocal();
    final now = DateTime.now();
    final diff = now.difference(local);

    final timePart =
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';

    if (diff.isNegative || diff.inSeconds < 45) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24 && local.day == now.day) {
      return 'Today $timePart';
    } else if (diff.inDays == 1 ||
        (now.day - local.day == 1 && diff.inHours < 48)) {
      return 'Yesterday $timePart';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago • $timePart';
    } else {
      return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year} $timePart';
    }
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return 'U';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final actionColor = getActionColor(log.action);
    final actionIcon = getActionIcon(log.action);
    final moduleIcon = getModuleIcon(log.module);

    return InkWell(
      onTap: () {
        Get.dialog(ActivityLogDetailDialog(log: log));
      },
      borderRadius: AppRadius.lg,
      child: AppCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: User Avatar, User Name, Timestamp & Action Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 17,
                  backgroundColor: actionColor.withAlpha(25),
                  child: Text(
                    _getInitials(log.userName),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: actionColor,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log.userName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatRelativeTime(log.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? Colors.grey[400]
                              : Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (log.userEmail != null && log.userEmail!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          log.userEmail!,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.grey[500] : Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Action Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: actionColor.withAlpha(25),
                    borderRadius: AppRadius.full,
                    border: Border.all(color: actionColor.withAlpha(50)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(actionIcon, size: 12, color: actionColor),
                      const SizedBox(width: 4),
                      Text(
                        log.action.replaceAll('_', ' ').toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: actionColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Middle: Module Tag & Description
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    borderRadius: AppRadius.sm,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(moduleIcon, size: 12, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        log.module,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    log.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[200] : Colors.grey[800],
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Bottom row: IP address chip and subtle detail prompt
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (log.ipAddress != null && log.ipAddress!.isNotEmpty)
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.computer_outlined,
                          size: 13,
                          color: isDark ? Colors.grey[500] : Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            log.ipAddress!,
                            style: TextStyle(
                              fontSize: 11,
                              fontFamily: 'monospace',
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  const SizedBox.shrink(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View details',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
