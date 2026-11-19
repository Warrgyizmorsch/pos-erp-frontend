import '../../../parties/suppliers/models/supplier.dart';

class PaymentOut {
  final String id;
  final String receiptNo;
  final dynamic partyId; // Supplier or String ID
  final String partyName;
  final double amountPaid;
  final String paymentMode; // 'Cash', 'Bank', 'UPI', 'Card', 'Cheque'
  final String? cashBankAccountId;
  final String date;
  final String? linkedPurchaseId;
  final String? description;
  final String? referenceNo;
  final String? createdAt;

  PaymentOut({
    required this.id,
    required this.receiptNo,
    required this.partyId,
    required this.partyName,
    required this.amountPaid,
    required this.paymentMode,
    this.cashBankAccountId,
    required this.date,
    this.linkedPurchaseId,
    this.description,
    this.referenceNo,
    this.createdAt,
  });

  factory PaymentOut.fromJson(Map<String, dynamic> json) {
    dynamic pId;
    String pName = 'Supplier';

    if (json['partyId'] != null) {
      if (json['partyId'] is Map<String, dynamic>) {
        final suppMap = json['partyId'] as Map<String, dynamic>;
        try {
          final s = Supplier.fromJson(suppMap);
          pId = s.id;
          pName = s.name;
        } catch (_) {
          pId = suppMap['_id']?.toString() ?? suppMap['id']?.toString();
          pName = suppMap['name']?.toString() ?? 'Supplier';
        }
      } else {
        pId = json['partyId'].toString();
      }
    } else if (json['supplier'] != null) {
      if (json['supplier'] is Map<String, dynamic>) {
        final suppMap = json['supplier'] as Map<String, dynamic>;
        pId = suppMap['_id']?.toString() ?? suppMap['id']?.toString();
        pName = suppMap['name']?.toString() ?? 'Supplier';
      } else {
        pId = json['supplier'].toString();
      }
    }

    if (json['partyName'] != null && json['partyName'].toString().isNotEmpty) {
      pName = json['partyName'].toString();
    } else if (json['supplierName'] != null &&
        json['supplierName'].toString().isNotEmpty) {
      pName = json['supplierName'].toString();
    }

    dynamic linkedId;
    if (json['linkedPurchaseId'] != null) {
      if (json['linkedPurchaseId'] is Map<String, dynamic>) {
        linkedId =
            json['linkedPurchaseId']['_id'] ?? json['linkedPurchaseId']['id'];
      } else {
        linkedId = json['linkedPurchaseId'].toString();
      }
    } else if (json['purchaseId'] != null) {
      linkedId = json['purchaseId'].toString();
    }

    final String recNo =
        json['receiptNo']?.toString() ??
        json['voucherNo']?.toString() ??
        json['referenceNo']?.toString() ??
        '';

    final double amt =
        (json['amountPaid'] as num?)?.toDouble() ??
        (json['amount'] as num?)?.toDouble() ??
        0.0;

    return PaymentOut(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      receiptNo: recNo,
      partyId: pId,
      partyName: pName,
      amountPaid: amt,
      paymentMode:
          json['paymentMode']?.toString() ?? json['mode']?.toString() ?? 'Cash',
      cashBankAccountId:
          json['cashBankAccountId']?.toString() ??
          json['bankAccountId']?.toString(),
      date:
          json['date']?.toString() ??
          json['createdAt']?.toString() ??
          DateTime.now().toIso8601String(),
      linkedPurchaseId: linkedId,
      description: json['description']?.toString() ?? json['notes']?.toString(),
      referenceNo:
          json['referenceNo']?.toString() ?? json['transactionNo']?.toString(),
      createdAt: json['createdAt']?.toString(),
    );
  }
}
