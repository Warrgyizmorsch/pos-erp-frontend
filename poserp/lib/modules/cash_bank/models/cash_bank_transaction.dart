class CashBankTransaction {
  final String id;
  final String transactionNo;
  final String
  type; // 'deposit', 'withdrawal', 'transfer', 'income', 'expense', 'payment'
  final double amount;
  final String date;
  final String paymentMethod; // 'Cash', 'Bank', 'UPI', 'Card', 'Cheque'
  final String? fromAccount;
  final String? toAccount;
  final String? referenceNo;
  final String? description;
  final String status; // 'completed', 'reversed', 'pending'
  final String? partyName;

  CashBankTransaction({
    required this.id,
    required this.transactionNo,
    required this.type,
    required this.amount,
    required this.date,
    required this.paymentMethod,
    this.fromAccount,
    this.toAccount,
    this.referenceNo,
    this.description,
    required this.status,
    this.partyName,
  });

  factory CashBankTransaction.fromJson(Map<String, dynamic> json) {
    String fromName = 'Cash';
    if (json['fromAccount'] != null) {
      if (json['fromAccount'] is Map<String, dynamic>) {
        fromName =
            json['fromAccount']['accountName']?.toString() ??
            json['fromAccount']['name']?.toString() ??
            'Cash';
      } else {
        fromName = json['fromAccount'].toString();
      }
    }

    String toName = 'Bank Account';
    if (json['toAccount'] != null) {
      if (json['toAccount'] is Map<String, dynamic>) {
        toName =
            json['toAccount']['accountName']?.toString() ??
            json['toAccount']['name']?.toString() ??
            'Bank Account';
      } else {
        toName = json['toAccount'].toString();
      }
    }

    return CashBankTransaction(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      transactionNo:
          json['transactionNo']?.toString() ??
          json['referenceNo']?.toString() ??
          json['voucherNo']?.toString() ??
          '',
      type:
          json['type']?.toString() ??
          json['transactionType']?.toString() ??
          'deposit',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date:
          json['date']?.toString() ??
          json['createdAt']?.toString() ??
          DateTime.now().toIso8601String(),
      paymentMethod:
          json['paymentMethod']?.toString() ??
          json['paymentMode']?.toString() ??
          'Cash',
      fromAccount: fromName,
      toAccount: toName,
      referenceNo: json['referenceNo']?.toString(),
      description:
          json['description']?.toString() ?? json['remarks']?.toString(),
      status: json['status']?.toString() ?? 'completed',
      partyName: json['partyName']?.toString() ?? json['party']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'amount': amount,
      'date': date,
      'paymentMethod': paymentMethod,
      if (fromAccount != null) 'fromAccount': fromAccount,
      if (toAccount != null) 'toAccount': toAccount,
      if (referenceNo != null && referenceNo!.isNotEmpty)
        'referenceNo': referenceNo,
      if (description != null && description!.isNotEmpty)
        'description': description,
    };
  }
}
