class Cheque {
  final String id;
  final String type; // 'received' or 'issued'
  final String chequeNumber;
  final double amount;
  final String date;
  final String partyName;
  final String bankName;
  final String status; // 'Pending', 'Cleared', 'Bounced', 'Cancelled'
  final String clearanceAccountType;
  final String? clearanceAccountId;
  final String createdAt;

  Cheque({
    required this.id,
    required this.type,
    required this.chequeNumber,
    required this.amount,
    required this.date,
    required this.partyName,
    required this.bankName,
    required this.status,
    required this.clearanceAccountType,
    this.clearanceAccountId,
    required this.createdAt,
  });

  factory Cheque.fromJson(Map<String, dynamic> json) {
    return Cheque(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      type: json['type']?.toString().toLowerCase() ?? 'received',
      chequeNumber:
          json['chequeNumber']?.toString() ?? json['number']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: json['date']?.toString() ?? DateTime.now().toIso8601String(),
      partyName:
          json['partyName']?.toString() ?? json['party']?.toString() ?? 'Party',
      bankName:
          json['bankName']?.toString() ?? json['bank']?.toString() ?? 'Bank',
      status: json['status']?.toString() ?? 'Pending',
      clearanceAccountType: json['clearanceAccountType']?.toString() ?? 'bank',
      clearanceAccountId: json['clearanceAccountId']?.toString(),
      createdAt:
          json['createdAt']?.toString() ??
          json['timestamp']?.toString() ??
          DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'chequeNumber': chequeNumber,
      'amount': amount,
      'date': date,
      'partyName': partyName,
      'bankName': bankName,
      'status': status,
      'clearanceAccountType': clearanceAccountType,
      'clearanceAccountId': clearanceAccountId,
    };
  }
}
