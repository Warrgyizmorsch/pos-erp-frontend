class ActivityLog {
  final String id;
  final String userName;
  final String? userEmail;
  final String action;
  final String module;
  final String description;
  final Map<String, dynamic>? details;
  final String? ipAddress;
  final String createdAt;

  ActivityLog({
    required this.id,
    required this.userName,
    this.userEmail,
    required this.action,
    required this.module,
    required this.description,
    this.details,
    this.ipAddress,
    required this.createdAt,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    String uName = 'System User';
    String? uEmail;

    if (json['user'] != null) {
      if (json['user'] is Map<String, dynamic>) {
        uName = json['user']['name']?.toString() ?? 'User';
        uEmail = json['user']['email']?.toString();
      } else {
        uName = json['user'].toString();
      }
    }

    if (json['userName'] != null && uName == 'System User') {
      uName = json['userName'].toString();
    }

    Map<String, dynamic>? det;
    if (json['details'] != null && json['details'] is Map<String, dynamic>) {
      det = json['details'] as Map<String, dynamic>;
    } else if (json['payload'] != null &&
        json['payload'] is Map<String, dynamic>) {
      det = json['payload'] as Map<String, dynamic>;
    }

    return ActivityLog(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      userName: uName,
      userEmail: uEmail ?? json['userEmail']?.toString(),
      action: json['action']?.toString().toLowerCase() ?? 'update',
      module: json['module']?.toString() ?? 'System',
      description:
          json['description']?.toString() ??
          json['message']?.toString() ??
          'System Event',
      details: det,
      ipAddress: json['ipAddress']?.toString() ?? json['ip']?.toString(),
      createdAt:
          json['createdAt']?.toString() ??
          json['timestamp']?.toString() ??
          DateTime.now().toIso8601String(),
    );
  }
}
