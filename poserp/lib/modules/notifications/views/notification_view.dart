import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/notification_controller.dart';

class NotificationView extends GetView<NotificationController> {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header (Responsive for mobile & desktop)
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;

                  final titleSection = Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(25),
                          borderRadius: AppRadius.lg,
                        ),
                        child: const Icon(
                          Icons.notifications_active_outlined,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Notifications & Alerts',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Real-time alerts for low stock, sales, and accounts.',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );

                  final actionButtons = Row(
                    mainAxisSize: isMobile ? MainAxisSize.max : MainAxisSize.min,
                    children: [
                      Expanded(
                        flex: isMobile ? 1 : 0,
                        child: AppButton(
                          text: 'Mark All Read',
                          icon: const Icon(Icons.done_all_rounded, size: 16),
                          variant: AppButtonVariant.outline,
                          height: 34,
                          onPressed: () => controller.markAllRead(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: isMobile ? 1 : 0,
                        child: AppButton(
                          text: 'Refresh',
                          icon: const Icon(Icons.refresh_rounded, size: 16),
                          variant: AppButtonVariant.outline,
                          height: 34,
                          onPressed: () => controller.loadNotifications(),
                        ),
                      ),
                    ],
                  );

                  if (isMobile) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        titleSection,
                        const SizedBox(height: 12),
                        actionButtons,
                      ],
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: titleSection),
                      const SizedBox(width: 16),
                      actionButtons,
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),

              // Notifications List
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const LoadingIndicator();
                  }

                  if (controller.notifications.isEmpty) {
                    return const Center(
                      child: EmptyState(
                        icon: Icons.notifications_none_outlined,
                        title: 'No Notifications',
                        description: 'You have no unread system alerts or messages.',
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => controller.loadNotifications(),
                    color: AppColors.primary,
                    child: ListView.builder(
                      itemCount: controller.notifications.length,
                      itemBuilder: (context, index) {
                        final n = controller.notifications[index];
                        final isLowStock = n.type == 'low_stock';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: AppCard(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: isLowStock
                                      ? AppColors.warning.withAlpha(30)
                                      : AppColors.primary.withAlpha(30),
                                  child: Icon(
                                    isLowStock
                                        ? Icons.warning_amber_rounded
                                        : Icons.info_outline_rounded,
                                    color: isLowStock
                                        ? AppColors.warning
                                        : AppColors.primary,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              n.title,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            n.createdAt.contains('T')
                                                ? n.createdAt
                                                    .split('T')
                                                    .last
                                                    .substring(0, 5)
                                                : n.createdAt,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        n.message,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[700],
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                InkWell(
                                  onTap: () =>
                                      controller.removeNotification(n.id),
                                  borderRadius: AppRadius.full,
                                  child: const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(
                                      Icons.close_rounded,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
