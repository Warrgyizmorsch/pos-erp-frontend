class TrialBalanceRow {
  final String accountCode;
  final String accountName;
  final String groupName;
  final double debit;
  final double credit;

  TrialBalanceRow({
    required this.accountCode,
    required this.accountName,
    required this.groupName,
    required this.debit,
    required this.credit,
  });

  factory TrialBalanceRow.fromJson(Map<String, dynamic> json) {
    return TrialBalanceRow(
      accountCode:
          json['code']?.toString() ?? json['accountCode']?.toString() ?? '',
      accountName:
          json['name']?.toString() ??
          json['accountName']?.toString() ??
          'Ledger',
      groupName:
          json['group']?.toString() ?? json['groupName']?.toString() ?? '-',
      debit:
          (json['debit'] as num?)?.toDouble() ??
          (json['debitBalance'] as num?)?.toDouble() ??
          0.0,
      credit:
          (json['credit'] as num?)?.toDouble() ??
          (json['creditBalance'] as num?)?.toDouble() ??
          0.0,
    );
  }
}

class FinancialReportRow {
  final String code;
  final String name;
  final double amount;

  FinancialReportRow({
    required this.code,
    required this.name,
    required this.amount,
  });

  factory FinancialReportRow.fromJson(Map<String, dynamic> json) {
    return FinancialReportRow(
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? json['label']?.toString() ?? 'Account',
      amount:
          (json['amount'] as num?)?.toDouble() ??
          (json['balance'] as num?)?.toDouble() ??
          0.0,
    );
  }
}

class TrialBalanceReport {
  final List<TrialBalanceRow> rows;
  final double totalDebit;
  final double totalCredit;
  final bool isBalanced;

  TrialBalanceReport({
    required this.rows,
    required this.totalDebit,
    required this.totalCredit,
    required this.isBalanced,
  });

  factory TrialBalanceReport.fromJson(Map<String, dynamic> json) {
    final rowList = <TrialBalanceRow>[];
    final list =
        (json['rows'] ?? json['ledgers'] ?? json['accounts'] ?? []) as List;
    for (final item in list) {
      if (item is Map<String, dynamic>) {
        try {
          rowList.add(TrialBalanceRow.fromJson(item));
        } catch (_) {}
      }
    }

    final double computedDebit = rowList.fold<double>(
      0.0,
      (double sum, r) => sum + r.debit,
    );
    final double computedCredit = rowList.fold<double>(
      0.0,
      (double sum, r) => sum + r.credit,
    );

    final double dTot =
        (json['totalDebit'] as num?)?.toDouble() ?? computedDebit;
    final double cTot =
        (json['totalCredit'] as num?)?.toDouble() ?? computedCredit;

    return TrialBalanceReport(
      rows: rowList,
      totalDebit: dTot,
      totalCredit: cTot,
      isBalanced: (dTot - cTot).abs() < 0.009,
    );
  }
}

class ProfitLossReport {
  final List<FinancialReportRow> incomeRows;
  final List<FinancialReportRow> expenseRows;
  final double totalIncome;
  final double totalExpense;
  final double netProfit;

  ProfitLossReport({
    required this.incomeRows,
    required this.expenseRows,
    required this.totalIncome,
    required this.totalExpense,
    required this.netProfit,
  });

  factory ProfitLossReport.fromJson(Map<String, dynamic> json) {
    final incList = <FinancialReportRow>[];
    final expList = <FinancialReportRow>[];

    final incData = (json['income'] ?? json['revenue'] ?? []) as List;
    for (final item in incData) {
      if (item is Map<String, dynamic>) {
        try {
          incList.add(FinancialReportRow.fromJson(item));
        } catch (_) {}
      }
    }

    final expData = (json['expenses'] ?? json['expense'] ?? []) as List;
    for (final item in expData) {
      if (item is Map<String, dynamic>) {
        try {
          expList.add(FinancialReportRow.fromJson(item));
        } catch (_) {}
      }
    }

    final double computedIncome = incList.fold<double>(
      0.0,
      (double sum, r) => sum + r.amount,
    );
    final double computedExpense = expList.fold<double>(
      0.0,
      (double sum, r) => sum + r.amount,
    );

    final double totInc =
        (json['totalIncome'] as num?)?.toDouble() ?? computedIncome;
    final double totExp =
        (json['totalExpense'] as num?)?.toDouble() ?? computedExpense;
    final double netP =
        (json['netProfit'] as num?)?.toDouble() ?? (totInc - totExp);

    return ProfitLossReport(
      incomeRows: incList,
      expenseRows: expList,
      totalIncome: totInc,
      totalExpense: totExp,
      netProfit: netP,
    );
  }
}

class BalanceSheetReport {
  final List<FinancialReportRow> assetRows;
  final List<FinancialReportRow> liabilityRows;
  final List<FinancialReportRow> equityRows;
  final double totalAssets;
  final double totalLiabilities;
  final double totalEquity;

  BalanceSheetReport({
    required this.assetRows,
    required this.liabilityRows,
    required this.equityRows,
    required this.totalAssets,
    required this.totalLiabilities,
    required this.totalEquity,
  });

  factory BalanceSheetReport.fromJson(Map<String, dynamic> json) {
    final astList = <FinancialReportRow>[];
    final liabList = <FinancialReportRow>[];
    final eqList = <FinancialReportRow>[];

    final astData = (json['assets'] ?? []) as List;
    for (final item in astData) {
      if (item is Map<String, dynamic>) {
        try {
          astList.add(FinancialReportRow.fromJson(item));
        } catch (_) {}
      }
    }

    final liabData = (json['liabilities'] ?? []) as List;
    for (final item in liabData) {
      if (item is Map<String, dynamic>) {
        try {
          liabList.add(FinancialReportRow.fromJson(item));
        } catch (_) {}
      }
    }

    final eqData = (json['equity'] ?? []) as List;
    for (final item in eqData) {
      if (item is Map<String, dynamic>) {
        try {
          eqList.add(FinancialReportRow.fromJson(item));
        } catch (_) {}
      }
    }

    final double computedAssets = astList.fold<double>(
      0.0,
      (double sum, r) => sum + r.amount,
    );
    final double computedLiab = liabList.fold<double>(
      0.0,
      (double sum, r) => sum + r.amount,
    );
    final double computedEquity = eqList.fold<double>(
      0.0,
      (double sum, r) => sum + r.amount,
    );

    final double totAst =
        (json['totalAssets'] as num?)?.toDouble() ?? computedAssets;
    final double totLiab =
        (json['totalLiabilities'] as num?)?.toDouble() ?? computedLiab;
    final double totEq =
        (json['totalEquity'] as num?)?.toDouble() ?? computedEquity;

    return BalanceSheetReport(
      assetRows: astList,
      liabilityRows: liabList,
      equityRows: eqList,
      totalAssets: totAst,
      totalLiabilities: totLiab,
      totalEquity: totEq,
    );
  }
}
