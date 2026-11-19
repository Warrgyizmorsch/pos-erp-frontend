class PaymentInPayload {
  final String partyId;
  final double amountReceived;
  final String paymentMode;
  final String? cashBankAccountId;
  final String date;
  final String? linkedInvoiceId;
  final String? description;
  final String? referenceNo;

  PaymentInPayload({
    required this.partyId,
    required this.amountReceived,
    required this.paymentMode,
    this.cashBankAccountId,
    required this.date,
    this.linkedInvoiceId,
    this.description,
    this.referenceNo,
  });

  Map<String, dynamic> toJson() {
    final isCash = paymentMode.toLowerCase() == 'cash';
    return {
      'partyId': partyId,
      'amountReceived': amountReceived,
      'paymentMode': paymentMode,
      if (!isCash && cashBankAccountId != null && cashBankAccountId!.isNotEmpty)
        'cashBankAccountId': cashBankAccountId,
      'date': date,
      if (linkedInvoiceId != null && linkedInvoiceId!.isNotEmpty)
        'linkedInvoiceId': linkedInvoiceId,
      if (description != null && description!.isNotEmpty)
        'description': description,
      if (referenceNo != null && referenceNo!.isNotEmpty)
        'referenceNo': referenceNo,
    };
  }
}
