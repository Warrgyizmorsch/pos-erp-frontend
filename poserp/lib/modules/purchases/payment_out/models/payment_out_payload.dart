class PaymentOutPayload {
  final String partyId;
  final double amountPaid;
  final String paymentMode;
  final String? cashBankAccountId;
  final String date;
  final String? linkedPurchaseId;
  final String? description;
  final String? referenceNo;

  PaymentOutPayload({
    required this.partyId,
    required this.amountPaid,
    required this.paymentMode,
    this.cashBankAccountId,
    required this.date,
    this.linkedPurchaseId,
    this.description,
    this.referenceNo,
  });

  Map<String, dynamic> toJson() {
    return {
      'partyId': partyId,
      'supplier': partyId,
      'supplierId': partyId,
      'amountPaid': amountPaid,
      'paymentMode': paymentMode,
      if (paymentMode.toLowerCase() != 'cash' &&
          cashBankAccountId != null &&
          cashBankAccountId!.isNotEmpty)
        'cashBankAccountId': cashBankAccountId,
      'date': date,
      if (linkedPurchaseId != null && linkedPurchaseId!.isNotEmpty)
        'linkedPurchaseId': linkedPurchaseId,
      if (description != null && description!.isNotEmpty)
        'description': description,
      if (referenceNo != null && referenceNo!.isNotEmpty)
        'referenceNo': referenceNo,
    };
  }
}
