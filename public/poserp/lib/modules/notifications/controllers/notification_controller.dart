import 'package:get/get.dart';
import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';

class NotificationController extends GetxController {
  final NotificationRepository _repository;

  NotificationController(this._repository);

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    try {
      isLoading.value = true;
      final res = await _repository.fetchNotifications();
      notifications.assignAll(res);
      unreadCount.value = await _repository.fetchUnreadCount();
    } catch (_) {
      // Fallback demo notifications if offline
      notifications.assignAll([
        NotificationModel(
          id: 'notif-1',
          title: 'Low Stock Warning',
          message:
              'Product "Organic Green Tea" stock is below threshold (5 items remaining).',
          type: 'low_stock',
          isRead: false,
          createdAt: DateTime.now()
              .subtract(const Duration(minutes: 25))
              .toIso8601String(),
        ),
        NotificationModel(
          id: 'notif-2',
          title: 'Day Book Reconciled',
          message: 'Day book totals for today verified with zero mismatch.',
          type: 'system',
          isRead: true,
          createdAt: DateTime.now()
              .subtract(const Duration(hours: 2))
              .toIso8601String(),
        ),
      ]);
      unreadCount.value = 1;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markRead(String id) async {
    await _repository.markAsRead(id);
    await loadNotifications();
  }

  Future<void> markAllRead() async {
    await _repository.markAllAsRead();
    await loadNotifications();
  }

  Future<void> removeNotification(String id) async {
    await _repository.deleteNotification(id);
    notifications.removeWhere((n) => n.id == id);
  }
}
