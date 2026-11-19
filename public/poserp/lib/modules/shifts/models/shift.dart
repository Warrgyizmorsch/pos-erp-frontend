class Shift {
  final String id;
  final String cashier;
  final String cashierName;
  final String startTime;
  final String? endTime;
  final double openingBalance;
  final double? closingBalance;
  final String status; // 'open' or 'closed'
  final double? actualCash;
  final double? difference;
  final String? notes;

  Shift({
    required this.id,
    required this.cashier,
    required this.cashierName,
    required this.startTime,
    this.endTime,
    required this.openingBalance,
    this.closingBalance,
    required this.status,
    this.actualCash,
    this.difference,
    this.notes,
  });

  factory Shift.fromJson(Map<String, dynamic> json) {
    String cName = json['cashierName']?.toString() ?? 'Cashier';
    String cId = '';

    if (json['cashier'] != null) {
      if (json['cashier'] is Map<String, dynamic>) {
        cId =
            json['cashier']['_id']?.toString() ??
            json['cashier']['id']?.toString() ??
            '';
        cName = json['cashier']['name']?.toString() ?? cName;
      } else {
        cId = json['cashier'].toString();
      }
    }

    return Shift(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      cashier: cId,
      cashierName: cName,
      startTime:
          json['startTime']?.toString() ??
          json['createdAt']?.toString() ??
          DateTime.now().toIso8601String(),
      endTime: json['endTime']?.toString(),
      openingBalance:
          (json['openingBalance'] as num?)?.toDouble() ??
          (json['openingCash'] as num?)?.toDouble() ??
          0.0,
      closingBalance: (json['closingBalance'] as num?)?.toDouble(),
      status: json['status']?.toString() ?? 'open',
      actualCash: (json['actualCash'] as num?)?.toDouble(),
      difference: (json['difference'] as num?)?.toDouble(),
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'openingCash': openingBalance,
      'cashierName': cashierName,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
    };
  }
}
