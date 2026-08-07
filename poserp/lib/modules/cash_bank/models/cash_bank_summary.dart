class CashBankSummary {
  final double cashBalance;
  final double totalBankBalance;
  final double todayInflow;
  final double todayOutflow;
  final double netBalance;

  CashBankSummary({
    required this.cashBalance,
    required this.totalBankBalance,
    required this.todayInflow,
    required this.todayOutflow,
    required this.netBalance,
  });

  factory CashBankSummary.fromJson(Map<String, dynamic> json) {
    final double cash = (json['cashBalance'] as num?)?.toDouble() ?? 0.0;
    final double bank =
        (json['totalBankBalance'] as num?)?.toDouble() ??
        (json['bankBalance'] as num?)?.toDouble() ??
        0.0;
    final double inflow = (json['todayInflow'] as num?)?.toDouble() ?? 0.0;
    final double outflow = (json['todayOutflow'] as num?)?.toDouble() ?? 0.0;
    final double net =
        (json['netBalance'] as num?)?.toDouble() ?? (cash + bank);

    return CashBankSummary(
      cashBalance: cash,
      totalBankBalance: bank,
      todayInflow: inflow,
      todayOutflow: outflow,
      netBalance: net,
    );
  }
}
