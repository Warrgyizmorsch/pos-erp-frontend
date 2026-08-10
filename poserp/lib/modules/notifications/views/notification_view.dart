import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/notification_controller.dart';

class NotificationView extends GetView<NotificationController> {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
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
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Notifications & System Alerts',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Real-time alerts for low stock, sales milestones, and accounting health issues.',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      AppButton(
                        text: 'Mark All Read',
                        icon: const Icon(Icons.done_all_rounded, size: 16),
                        variant: AppButtonVariant.outline,
                        onPressed: () => controller.markAllRead(),
                      ),
                      const SizedBox(width: 8),
                      AppButton(
                        text: 'Refresh',
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        variant: AppButtonVariant.outline,
                        onPressed: () => controller.loadNotifications(),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Notifications List
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const LoadingIndicator();
                  }

                  if (controller.notifications.isEmpty) {
                    return const Center(
                      child: Text(
                        'No unread notifications.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: controller.notifications.length,
                    itemBuilder: (context, index) {
                      final n = controller.notifications[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: AppCard(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: n.type == 'low_stock'
                                    ? AppColors.warning.withAlpha(30)
                                    : AppColors.primary.withAlpha(30),
                                child: Icon(
                                  n.type == 'low_stock'
                                      ? Icons.warning_amber_rounded
                                      : Icons.info_outline_rounded,
                                  color: n.type == 'low_stock'
                                      ? AppColors.warning
                                      : AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          n.title,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
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
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close_rounded, size: 18),
                                onPressed: () =>
                                    controller.removeNotification(n.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
