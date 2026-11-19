class AccountingAuditLog {
  final String id;
  final String action;
  final String module;
  final String? referenceId;
  final String? referenceNo;
  final String? description;
  final Map<String, dynamic>? oldData;
  final Map<String, dynamic>? newData;
  final Map<String, dynamic>? details;
  final String? ipAddress;
  final String? userAgent;
  final String? userName;
  final String createdAt;

  AccountingAuditLog({
    required this.id,
    required this.action,
    required this.module,
    this.referenceId,
    this.referenceNo,
    this.description,
    this.oldData,
    this.newData,
    this.details,
    this.ipAddress,
    this.userAgent,
    this.userName,
    required this.createdAt,
  });

  factory AccountingAuditLog.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? extractMap(dynamic val) {
      if (val is Map) return Map<String, dynamic>.from(val);
      return null;
    }

    final user = json['user'];
    final uName = user is Map
        ? user['name']?.toString()
        : json['userName']?.toString();

    return AccountingAuditLog(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      action: json['action']?.toString() ?? '',
      module: json['module']?.toString() ?? '',
      referenceId: json['referenceId']?.toString(),
      referenceNo: json['referenceNo']?.toString(),
      description: json['description']?.toString(),
      oldData: extractMap(json['oldData']),
      newData: extractMap(json['newData']),
      details: extractMap(json['details']),
      ipAddress: json['ipAddress']?.toString(),
      userAgent: json['userAgent']?.toString(),
      userName: uName,
      createdAt:
          json['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }
}
