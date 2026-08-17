class AccountingReportDashboardModel {
  final double totalIncome;
  final double totalExpenses;
  final double netProfit;
  final double receivables;
  final double payables;
  final double cashBalance;
  final double bankBalance;

  AccountingReportDashboardModel({
    required this.totalIncome,
    required this.totalExpenses,
    required this.netProfit,
    required this.receivables,
    required this.payables,
    required this.cashBalance,
    required this.bankBalance,
  });

  factory AccountingReportDashboardModel.fromJson(Map<String, dynamic> json) {
    return AccountingReportDashboardModel(
      totalIncome: (json['totalIncome'] as num?)?.toDouble() ?? 0.0,
      totalExpenses: (json['totalExpenses'] as num?)?.toDouble() ?? 0.0,
      netProfit: (json['netProfit'] as num?)?.toDouble() ?? 0.0,
      receivables: (json['receivables'] as num?)?.toDouble() ?? 0.0,
      payables: (json['payables'] as num?)?.toDouble() ?? 0.0,
      cashBalance: (json['cashBalance'] as num?)?.toDouble() ?? 0.0,
      bankBalance: (json['bankBalance'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class BookReportEntry {
  final String voucherId;
  final String voucherNo;
  final String voucherTypeCode;
  final String date;
  final String particulars;
  final String referenceNo;
  final double debit;
  final double credit;
  final double balance;
  final String balanceType;
  final String ledgerName;

  BookReportEntry({
    required this.voucherId,
    required this.voucherNo,
    required this.voucherTypeCode,
    required this.date,
    required this.particulars,
    required this.referenceNo,
    required this.debit,
    required this.credit,
    required this.balance,
    required this.balanceType,
    required this.ledgerName,
  });

  factory BookReportEntry.fromJson(Map<String, dynamic> json) {
    return BookReportEntry(
      voucherId: json['voucherId']?.toString() ?? '',
      voucherNo:
          json['voucherNo']?.toString() ??
          json['voucherNumber']?.toString() ??
          '',
      voucherTypeCode:
          json['voucherTypeCode']?.toString() ??
          json['voucherType']?.toString() ??
          '',
      date: json['date']?.toString() ?? '',
      particulars:
          json['particulars']?.toString() ??
          json['narration']?.toString() ??
          '',
      referenceNo:
          json['referenceNo']?.toString() ??
          json['reference']?.toString() ??
          '',
      debit:
          (json['debit'] as num?)?.toDouble() ??
          (json['receipt'] as num?)?.toDouble() ??
          0.0,
      credit:
          (json['credit'] as num?)?.toDouble() ??
          (json['payment'] as num?)?.toDouble() ??
          0.0,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      balanceType: json['balanceType']?.toString() ?? 'DEBIT',
      ledgerName: json['ledgerName']?.toString() ?? '',
    );
  }
}

class BookReportTotals {
  final double totalReceipts;
  final double totalPayments;
  final double totalDeposits;
  final double totalWithdrawals;
  final double closingBalance;
  final String closingBalanceType;

  BookReportTotals({
    required this.totalReceipts,
    required this.totalPayments,
    required this.totalDeposits,
    required this.totalWithdrawals,
    required this.closingBalance,
    required this.closingBalanceType,
  });

  factory BookReportTotals.fromJson(Map<String, dynamic> json) {
    return BookReportTotals(
      totalReceipts:
          (json['totalReceipts'] as num?)?.toDouble() ??
          (json['totalDebit'] as num?)?.toDouble() ??
          0.0,
      totalPayments:
          (json['totalPayments'] as num?)?.toDouble() ??
          (json['totalCredit'] as num?)?.toDouble() ??
          0.0,
      totalDeposits: (json['totalDeposits'] as num?)?.toDouble() ?? 0.0,
      totalWithdrawals: (json['totalWithdrawals'] as num?)?.toDouble() ?? 0.0,
      closingBalance: (json['closingBalance'] as num?)?.toDouble() ?? 0.0,
      closingBalanceType: json['closingBalanceType']?.toString() ?? 'DEBIT',
    );
  }
}

class BookReport {
  final double openingBalance;
  final String openingBalanceType;
  final String startDate;
  final String endDate;
  final BookReportTotals totals;
  final List<BookReportEntry> entries;

  BookReport({
    required this.openingBalance,
    required this.openingBalanceType,
    required this.startDate,
    required this.endDate,
    required this.totals,
    required this.entries,
  });

  factory BookReport.fromJson(Map<String, dynamic> json) {
    final entryList = <BookReportEntry>[];
    final rawEntries =
        (json['entries'] ?? json['rows'] ?? json['transactions'] ?? []) as List;
    for (final item in rawEntries) {
      if (item is Map<String, dynamic>) {
        try {
          entryList.add(BookReportEntry.fromJson(item));
        } catch (_) {}
      }
    }

    final period = json['period'] is Map<String, dynamic>
        ? json['period'] as Map<String, dynamic>
        : {};
    final totalsObj = json['totals'] is Map<String, dynamic>
        ? json['totals'] as Map<String, dynamic>
        : json;

    return BookReport(
      openingBalance: (json['openingBalance'] as num?)?.toDouble() ?? 0.0,
      openingBalanceType: json['openingBalanceType']?.toString() ?? 'DEBIT',
      startDate:
          period['startDate']?.toString() ??
          json['startDate']?.toString() ??
          '',
      endDate:
          period['endDate']?.toString() ?? json['endDate']?.toString() ?? '',
      totals: BookReportTotals.fromJson(totalsObj),
      entries: entryList,
    );
  }
}

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

  String get ledgerName => accountName;
  String get code => accountCode;
  double get debitBalance => debit;
  double get creditBalance => credit;

  factory TrialBalanceRow.fromJson(Map<String, dynamic> json) {
    final String name =
        json['ledgerName']?.toString() ??
        json['name']?.toString() ??
        json['accountName']?.toString() ??
        json['ledger']?.toString() ??
        'Ledger';

    final String code =
        json['code']?.toString() ??
        json['accountCode']?.toString() ??
        json['ledgerCode']?.toString() ??
        '';

    final String group =
        json['groupName']?.toString() ?? json['group']?.toString() ?? '-';

    final double d =
        (json['debitBalance'] as num?)?.toDouble() ??
        (json['closingDebit'] as num?)?.toDouble() ??
        (json['debit'] as num?)?.toDouble() ??
        (json['periodDebit'] as num?)?.toDouble() ??
        (json['openingDebit'] as num?)?.toDouble() ??
        0.0;

    final double c =
        (json['creditBalance'] as num?)?.toDouble() ??
        (json['closingCredit'] as num?)?.toDouble() ??
        (json['credit'] as num?)?.toDouble() ??
        (json['periodCredit'] as num?)?.toDouble() ??
        (json['openingCredit'] as num?)?.toDouble() ??
        0.0;

    return TrialBalanceRow(
      accountCode: code,
      accountName: name,
      groupName: group,
      debit: d,
      credit: c,
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

  double get balance => amount;
  String get ledgerName => name;

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

class ReportLedgerAmount {
  final String? ledgerId;
  final String ledgerName;
  final String code;
  final double amount;

  ReportLedgerAmount({
    this.ledgerId,
    required this.ledgerName,
    required this.code,
    required this.amount,
  });

  factory ReportLedgerAmount.fromJson(Map<String, dynamic> json) {
    return ReportLedgerAmount(
      ledgerId: json['ledgerId']?.toString(),
      ledgerName:
          json['ledgerName']?.toString() ??
          json['name']?.toString() ??
          json['ledger']?.toString() ??
          'Ledger',
      code: json['code']?.toString() ?? '',
      amount:
          (json['amount'] as num?)?.toDouble() ??
          (json['balance'] as num?)?.toDouble() ??
          0.0,
    );
  }
}

class ReportGroupAmount {
  final String? groupId;
  final String groupName;
  final double total;
  final List<ReportLedgerAmount> ledgers;

  ReportGroupAmount({
    this.groupId,
    required this.groupName,
    required this.total,
    required this.ledgers,
  });

  factory ReportGroupAmount.fromJson(Map<String, dynamic> json) {
    final ledgerList = <ReportLedgerAmount>[];
    final rawLedgers = (json['ledgers'] ?? json['accounts'] ?? []) as List;
    for (final item in rawLedgers) {
      if (item is Map<String, dynamic>) {
        try {
          ledgerList.add(ReportLedgerAmount.fromJson(item));
        } catch (_) {}
      }
    }

    final double computedTotal = ledgerList.fold<double>(
      0.0,
      (double sum, l) => sum + l.amount.abs(),
    );

    return ReportGroupAmount(
      groupId: json['groupId']?.toString(),
      groupName:
          json['groupName']?.toString() ??
          json['name']?.toString() ??
          'Account Group',
      total:
          (json['total'] as num?)?.toDouble() ??
          (json['amount'] as num?)?.toDouble() ??
          computedTotal,
      ledgers: ledgerList,
    );
  }
}

class ProfitLossReport {
  final List<ReportGroupAmount> incomeGroups;
  final List<ReportGroupAmount> expenseGroups;
  final List<FinancialReportRow> incomeRows;
  final List<FinancialReportRow> expenseRows;
  final double totalIncome;
  final double totalExpense;
  final double netProfit;

  ProfitLossReport({
    required this.incomeGroups,
    required this.expenseGroups,
    required this.incomeRows,
    required this.expenseRows,
    required this.totalIncome,
    required this.totalExpense,
    required this.netProfit,
  });

  factory ProfitLossReport.fromJson(Map<String, dynamic> json) {
    final incGroups = <ReportGroupAmount>[];
    final expGroups = <ReportGroupAmount>[];
    final incList = <FinancialReportRow>[];
    final expList = <FinancialReportRow>[];

    final totalsObj = json['totals'] is Map<String, dynamic>
        ? json['totals'] as Map<String, dynamic>
        : json;

    final incData = (json['income'] ?? json['revenue'] ?? []) as List;
    for (final item in incData) {
      if (item is Map<String, dynamic>) {
        try {
          if (item.containsKey('ledgers') || item.containsKey('accounts')) {
            incGroups.add(ReportGroupAmount.fromJson(item));
          } else {
            incList.add(FinancialReportRow.fromJson(item));
          }
        } catch (_) {}
      }
    }

    final expData = (json['expenses'] ?? json['expense'] ?? []) as List;
    for (final item in expData) {
      if (item is Map<String, dynamic>) {
        try {
          if (item.containsKey('ledgers') || item.containsKey('accounts')) {
            expGroups.add(ReportGroupAmount.fromJson(item));
          } else {
            expList.add(FinancialReportRow.fromJson(item));
          }
        } catch (_) {}
      }
    }

    final double computedIncome = incGroups.isNotEmpty
        ? incGroups.fold<double>(0.0, (sum, g) => sum + g.total)
        : incList.fold<double>(0.0, (sum, r) => sum + r.amount);

    final double computedExpense = expGroups.isNotEmpty
        ? expGroups.fold<double>(0.0, (sum, g) => sum + g.total)
        : expList.fold<double>(0.0, (sum, r) => sum + r.amount);

    final double totInc =
        (totalsObj['totalIncome'] as num?)?.toDouble() ?? computedIncome;
    final double totExp =
        (totalsObj['totalExpenses'] as num?)?.toDouble() ??
        (totalsObj['totalExpense'] as num?)?.toDouble() ??
        computedExpense;
    final double netP =
        (totalsObj['netProfit'] as num?)?.toDouble() ?? (totInc - totExp);

    return ProfitLossReport(
      incomeGroups: incGroups,
      expenseGroups: expGroups,
      incomeRows: incList,
      expenseRows: expList,
      totalIncome: totInc,
      totalExpense: totExp,
      netProfit: netP,
    );
  }

  List<FinancialReportRow> get incomeAccounts => incomeRows;
  List<FinancialReportRow> get expenseAccounts => expenseRows;
  double get totalExpenses => totalExpense;
  double get netLoss => netProfit < 0 ? netProfit.abs() : 0.0;
}

class BalanceSheetReport {
  final List<ReportGroupAmount> assetGroups;
  final List<ReportGroupAmount> liabilityGroups;
  final List<FinancialReportRow> assetRows;
  final List<FinancialReportRow> liabilityRows;
  final List<FinancialReportRow> equityRows;
  final double totalAssets;
  final double totalLiabilities;
  final double totalEquity;
  final double difference;
  final String asOnDate;

  BalanceSheetReport({
    required this.assetGroups,
    required this.liabilityGroups,
    required this.assetRows,
    required this.liabilityRows,
    required this.equityRows,
    required this.totalAssets,
    required this.totalLiabilities,
    required this.totalEquity,
    required this.difference,
    required this.asOnDate,
  });

  factory BalanceSheetReport.fromJson(Map<String, dynamic> json) {
    final astGroups = <ReportGroupAmount>[];
    final liabGroups = <ReportGroupAmount>[];
    final astList = <FinancialReportRow>[];
    final liabList = <FinancialReportRow>[];
    final eqList = <FinancialReportRow>[];

    final totalsObj = json['totals'] is Map<String, dynamic>
        ? json['totals'] as Map<String, dynamic>
        : json;

    final astData = (json['assets'] ?? []) as List;
    for (final item in astData) {
      if (item is Map<String, dynamic>) {
        try {
          if (item.containsKey('ledgers') || item.containsKey('accounts')) {
            astGroups.add(ReportGroupAmount.fromJson(item));
          } else {
            astList.add(FinancialReportRow.fromJson(item));
          }
        } catch (_) {}
      }
    }

    final liabData = (json['liabilities'] ?? []) as List;
    for (final item in liabData) {
      if (item is Map<String, dynamic>) {
        try {
          if (item.containsKey('ledgers') || item.containsKey('accounts')) {
            liabGroups.add(ReportGroupAmount.fromJson(item));
          } else {
            liabList.add(FinancialReportRow.fromJson(item));
          }
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

    final double computedAssets = astGroups.isNotEmpty
        ? astGroups.fold<double>(0.0, (double sum, g) => sum + g.total)
        : astList.fold<double>(0.0, (double sum, r) => sum + r.amount);

    final double computedLiab = liabGroups.isNotEmpty
        ? liabGroups.fold<double>(0.0, (double sum, g) => sum + g.total)
        : liabList.fold<double>(0.0, (double sum, r) => sum + r.amount);

    final double totAst =
        (totalsObj['totalAssets'] as num?)?.toDouble() ?? computedAssets;
    final double totLiab =
        (totalsObj['totalLiabilities'] as num?)?.toDouble() ?? computedLiab;
    final double totEq = (totalsObj['totalEquity'] as num?)?.toDouble() ?? 0.0;
    final double diff =
        (totalsObj['difference'] as num?)?.toDouble() ??
        (totAst - totLiab).abs();

    return BalanceSheetReport(
      assetGroups: astGroups,
      liabilityGroups: liabGroups,
      assetRows: astList,
      liabilityRows: liabList,
      equityRows: eqList,
      totalAssets: totAst,
      totalLiabilities: totLiab,
      totalEquity: totEq,
      difference: diff,
      asOnDate:
          json['asOnDate']?.toString() ?? json['asOfDate']?.toString() ?? '',
    );
  }

  List<FinancialReportRow> get assetAccounts => assetRows;
  List<FinancialReportRow> get liabilityAccounts => liabilityRows;
  bool get isBalanced => difference < 0.009;
}
