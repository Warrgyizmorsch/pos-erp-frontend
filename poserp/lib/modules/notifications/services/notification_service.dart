import '../../../../core/api/api_client.dart';
import '../models/notification_model.dart';

class NotificationService {
  final ApiClient _apiClient;

  NotificationService(this._apiClient);

  Future<List<NotificationModel>> getNotifications() async {
    final response = await _apiClient.get('/notifications');
    final body = response.data is Map<String, dynamic> ? response.data : {};
    final data = body['data'] ?? body;
    final list = data is List ? data : [];
    return list
        .map((e) => NotificationModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<int> getUnreadCount() async {
    final response = await _apiClient.get('/notifications/unread-count');
    final body = response.data is Map<String, dynamic> ? response.data : {};
    final data = body['data'] ?? body;
    return (data is Map ? data['count'] as num? : data as num?)?.toInt() ?? 0;
  }

  Future<void> markAsRead(String id) async {
    await _apiClient.put('/notifications/$id/read');
  }

  Future<void> markAllAsRead() async {
    await _apiClient.put('/notifications/read-all');
  }

  Future<void> deleteNotification(String id) async {
    await _apiClient.delete('/notifications/$id');
  }
}
