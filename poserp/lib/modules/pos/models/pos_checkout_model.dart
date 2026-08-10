class PaymentTender {
  final String method; // 'cash', 'card', 'upi', 'cheque', 'credit'
  final double amount;
  final String? referenceNo;

  PaymentTender({required this.method, required this.amount, this.referenceNo});

  factory PaymentTender.fromJson(Map<String, dynamic> json) {
    return PaymentTender(
      method: json['method']?.toString() ?? 'cash',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      referenceNo: json['referenceNo']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'method': method,
    'amount': amount,
    'referenceNo': referenceNo,
  };
}

class POSCheckoutSummary {
  final double subtotal;
  final double taxAmount;
  final double discountAmount;
  final double roundOff;
  final double grandTotal;
  final double tenderedTotal;
  final double changeDue;
  final List<PaymentTender> tenders;

  POSCheckoutSummary({
    required this.subtotal,
    required this.taxAmount,
    required this.discountAmount,
    required this.roundOff,
    required this.grandTotal,
    required this.tenderedTotal,
    required this.changeDue,
    required this.tenders,
  });

  factory POSCheckoutSummary.fromJson(Map<String, dynamic> json) {
    return POSCheckoutSummary(
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
      roundOff: (json['roundOff'] as num?)?.toDouble() ?? 0.0,
      grandTotal: (json['grandTotal'] as num?)?.toDouble() ?? 0.0,
      tenderedTotal: (json['tenderedTotal'] as num?)?.toDouble() ?? 0.0,
      changeDue: (json['changeDue'] as num?)?.toDouble() ?? 0.0,
      tenders:
          (json['tenders'] as List?)
              ?.map((e) => PaymentTender.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
    );
  }
}
