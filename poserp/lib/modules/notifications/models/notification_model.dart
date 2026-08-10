class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String
  type; // "low_stock" | "sale" | "purchase" | "expense" | "system" | "alert"
  final bool isRead;
  final String? link;
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    this.link,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Notification',
      message: json['message']?.toString() ?? '',
      type: json['type']?.toString() ?? 'system',
      isRead: json['isRead'] ?? false,
      link: json['link']?.toString(),
      createdAt:
          json['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }
}
