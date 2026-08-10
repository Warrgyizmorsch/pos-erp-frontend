import '../../../../core/api/api_exceptions.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationRepository {
  final NotificationService _service;

  NotificationRepository(this._service);

  Future<List<NotificationModel>> fetchNotifications() async {
    try {
      return await _service.getNotifications();
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fetch notifications.');
    }
  }

  Future<int> fetchUnreadCount() async {
    try {
      return await _service.getUnreadCount();
    } catch (e) {
      return 0;
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _service.markAsRead(id);
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      await _service.markAllAsRead();
    } catch (_) {}
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _service.deleteNotification(id);
    } catch (_) {}
  }
}
