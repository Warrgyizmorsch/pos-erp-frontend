import '../../../parties/customers/models/customer.dart';

class PaymentIn {
  final String id;
  final String receiptNo;
  final dynamic partyId; // Customer or String ID
  final String partyName;
  final double amountReceived;
  final String paymentMode; // 'Cash', 'Bank', 'UPI', 'Card', 'Cheque'
  final String? cashBankAccountId;
  final String date;
  final String? linkedInvoiceId;
  final String? description;
  final String? referenceNo;
  final String? createdAt;

  PaymentIn({
    required this.id,
    required this.receiptNo,
    this.partyId,
    required this.partyName,
    required this.amountReceived,
    this.paymentMode = 'Cash',
    this.cashBankAccountId,
    required this.date,
    this.linkedInvoiceId,
    this.description,
    this.referenceNo,
    this.createdAt,
  });

  factory PaymentIn.fromJson(Map<String, dynamic> json) {
    dynamic party;
    String name = 'Customer';
    if (json['partyId'] != null) {
      if (json['partyId'] is Map<String, dynamic>) {
        party = Customer.fromJson(json['partyId']);
        name = (party as Customer).name;
      } else {
        party = json['partyId'].toString();
      }
    }
    if (json['partyName'] != null) {
      name = json['partyName'].toString();
    }

    dynamic invoice;
    if (json['linkedInvoiceId'] != null) {
      if (json['linkedInvoiceId'] is Map<String, dynamic>) {
        invoice =
            json['linkedInvoiceId']['_id'] ?? json['linkedInvoiceId']['id'];
      } else {
        invoice = json['linkedInvoiceId'].toString();
      }
    }

    return PaymentIn(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      receiptNo: json['receiptNo']?.toString() ?? 'Auto-generated',
      partyId: party,
      partyName: name,
      amountReceived: (json['amountReceived'] as num?)?.toDouble() ?? 0.0,
      paymentMode: json['paymentMode']?.toString() ?? 'Cash',
      cashBankAccountId: json['cashBankAccountId']?.toString(),
      date: json['date']?.toString() ?? DateTime.now().toIso8601String(),
      linkedInvoiceId: invoice,
      description: json['description']?.toString(),
      referenceNo: json['referenceNo']?.toString(),
      createdAt: json['createdAt']?.toString(),
    );
  }
}
