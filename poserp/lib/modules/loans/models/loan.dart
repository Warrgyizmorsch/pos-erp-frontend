class Loan {
  final String id;
  final String loanName;
  final String lenderName;
  final double totalAmount;
  final double interestRate;
  final double currentBalance;
  final String status; // 'Active' or 'Closed'
  final String createdAt;

  Loan({
    required this.id,
    required this.loanName,
    required this.lenderName,
    required this.totalAmount,
    required this.interestRate,
    required this.currentBalance,
    required this.status,
    required this.createdAt,
  });

  factory Loan.fromJson(Map<String, dynamic> json) {
    final amt =
        (json['totalAmount'] as num?)?.toDouble() ??
        (json['amount'] as num?)?.toDouble() ??
        0.0;
    final bal = (json['currentBalance'] as num?)?.toDouble() ?? amt;

    return Loan(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      loanName:
          json['loanName']?.toString() ??
          json['name']?.toString() ??
          'Loan Account',
      lenderName:
          json['lenderName']?.toString() ??
          json['lender']?.toString() ??
          'Lender Bank',
      totalAmount: amt,
      interestRate: (json['interestRate'] as num?)?.toDouble() ?? 0.0,
      currentBalance: bal,
      status: json['status']?.toString() ?? 'Active',
      createdAt:
          json['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'loanName': loanName,
      'lenderName': lenderName,
      'totalAmount': totalAmount,
      'interestRate': interestRate,
      'currentBalance': currentBalance,
      'status': status,
    };
  }
}
