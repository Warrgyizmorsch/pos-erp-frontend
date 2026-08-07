import 'accounting_ledger.dart';
import 'ledger_statement_entry.dart';

class LedgerStatementTotals {
  final double openingBalance;
  final String openingBalanceType;
  final double closingBalance;
  final String closingBalanceType;
  final double debitTotal;
  final double creditTotal;

  LedgerStatementTotals({
    required this.openingBalance,
    required this.openingBalanceType,
    required this.closingBalance,
    required this.closingBalanceType,
    required this.debitTotal,
    required this.creditTotal,
  });

  factory LedgerStatementTotals.fromJson(Map<String, dynamic> json) {
    return LedgerStatementTotals(
      openingBalance: (json['openingBalance'] as num?)?.toDouble() ?? 0.0,
      openingBalanceType:
          json['openingBalanceType']?.toString().toUpperCase() ?? 'DEBIT',
      closingBalance: (json['closingBalance'] as num?)?.toDouble() ?? 0.0,
      closingBalanceType:
          json['closingBalanceType']?.toString().toUpperCase() ?? 'DEBIT',
      debitTotal: (json['debitTotal'] as num?)?.toDouble() ?? 0.0,
      creditTotal: (json['creditTotal'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class LedgerStatement {
  final AccountingLedger ledger;
  final List<LedgerStatementEntry> entries;
  final LedgerStatementTotals totals;

  LedgerStatement({
    required this.ledger,
    required this.entries,
    required this.totals,
  });

  factory LedgerStatement.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> ledgerObj =
        json['ledger'] is Map<String, dynamic> ? json['ledger'] : json;
    final AccountingLedger l = AccountingLedger.fromJson(ledgerObj);

    final entryList = <LedgerStatementEntry>[];
    if (json['entries'] != null && json['entries'] is List) {
      for (final e in json['entries']) {
        if (e is Map<String, dynamic>) {
          try {
            entryList.add(LedgerStatementEntry.fromJson(e));
          } catch (_) {}
        }
      }
    }

    final Map<String, dynamic> totalsObj =
        json['totals'] is Map<String, dynamic> ? json['totals'] : {};
    final LedgerStatementTotals t = LedgerStatementTotals.fromJson(totalsObj);

    return LedgerStatement(ledger: l, entries: entryList, totals: t);
  }
}
