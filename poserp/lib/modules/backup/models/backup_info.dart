class BackupInfo {
  final String id;
  final String filename;
  final int sizeBytes;
  final String type; // 'local' or 'cloud'
  final String createdAt;
  final String status; // 'completed' or 'pending'

  BackupInfo({
    required this.id,
    required this.filename,
    required this.sizeBytes,
    required this.type,
    required this.createdAt,
    required this.status,
  });

  String get formattedSize {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  factory BackupInfo.fromJson(Map<String, dynamic> json) {
    return BackupInfo(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      filename:
          json['filename']?.toString() ??
          json['name']?.toString() ??
          'backup.json',
      sizeBytes:
          (json['sizeBytes'] as num?)?.toInt() ??
          (json['size'] as num?)?.toInt() ??
          10240,
      type: json['type']?.toString().toLowerCase() ?? 'local',
      createdAt:
          json['createdAt']?.toString() ??
          json['timestamp']?.toString() ??
          DateTime.now().toIso8601String(),
      status: json['status']?.toString().toLowerCase() ?? 'completed',
    );
  }
}
