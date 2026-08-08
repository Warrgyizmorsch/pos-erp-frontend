class LedgerMismatchRow {
  final String ledgerId;
  final String ledgerName;
  final String code;
  final double storedBalance;
  final String storedBalanceType;
  final double expectedBalance;
  final String expectedBalanceType;
  final double difference;
  final String status;

  LedgerMismatchRow({
    required this.ledgerId,
    required this.ledgerName,
    required this.code,
    required this.storedBalance,
    required this.storedBalanceType,
    required this.expectedBalance,
    required this.expectedBalanceType,
    required this.difference,
    required this.status,
  });

  factory LedgerMismatchRow.fromJson(Map<String, dynamic> json) {
    return LedgerMismatchRow(
      ledgerId: json['ledgerId']?.toString() ?? '',
      ledgerName: json['ledgerName']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      storedBalance: (json['storedBalance'] as num?)?.toDouble() ?? 0.0,
      storedBalanceType: json['storedBalanceType']?.toString() ?? 'Dr',
      expectedBalance: (json['expectedBalance'] as num?)?.toDouble() ?? 0.0,
      expectedBalanceType: json['expectedBalanceType']?.toString() ?? 'Dr',
      difference: (json['difference'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'mismatch',
    );
  }
}

class CashBankReconciliationAccount {
  final String accountId;
  final String accountName;
  final String accountType;
  final double openingBalance;
  final double currentBalance;
  final double transactionBalance;
  final double? ledgerBalance;
  final double difference;
  final String status;
  final String suggestedFix;
  final String? mappedLedgerCode;
  final String? mappedLedgerName;

  CashBankReconciliationAccount({
    required this.accountId,
    required this.accountName,
    required this.accountType,
    required this.openingBalance,
    required this.currentBalance,
    required this.transactionBalance,
    this.ledgerBalance,
    required this.difference,
    required this.status,
    required this.suggestedFix,
    this.mappedLedgerCode,
    this.mappedLedgerName,
  });

  factory CashBankReconciliationAccount.fromJson(Map<String, dynamic> json) {
    final mapped = json['mappedLedger'];
    return CashBankReconciliationAccount(
      accountId: json['accountId']?.toString() ?? json['_id']?.toString() ?? '',
      accountName:
          json['accountName']?.toString() ?? json['name']?.toString() ?? '',
      accountType: json['accountType']?.toString() ?? 'BANK',
      openingBalance: (json['openingBalance'] as num?)?.toDouble() ?? 0.0,
      currentBalance: (json['currentBalance'] as num?)?.toDouble() ?? 0.0,
      transactionBalance:
          (json['transactionBalance'] as num?)?.toDouble() ?? 0.0,
      ledgerBalance: (json['ledgerBalance'] as num?)?.toDouble(),
      difference: (json['difference'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'ok',
      suggestedFix: json['suggestedFix']?.toString() ?? 'No action required.',
      mappedLedgerCode: mapped is Map ? mapped['code']?.toString() : null,
      mappedLedgerName: mapped is Map ? mapped['name']?.toString() : null,
    );
  }
}

class PartyReconciliationRow {
  final String partyId;
  final String partyType;
  final String partyName;
  final double businessBalance;
  final double? partyLedgerBalance;
  final double? accountingBalance;
  final double difference;
  final String status;
  final int partyLedgerEntryCount;

  PartyReconciliationRow({
    required this.partyId,
    required this.partyType,
    required this.partyName,
    required this.businessBalance,
    this.partyLedgerBalance,
    this.accountingBalance,
    required this.difference,
    required this.status,
    required this.partyLedgerEntryCount,
  });

  factory PartyReconciliationRow.fromJson(Map<String, dynamic> json) {
    return PartyReconciliationRow(
      partyId: json['partyId']?.toString() ?? '',
      partyType: json['partyType']?.toString() ?? 'customer',
      partyName: json['partyName']?.toString() ?? '',
      businessBalance: (json['businessBalance'] as num?)?.toDouble() ?? 0.0,
      partyLedgerBalance: (json['partyLedgerBalance'] as num?)?.toDouble(),
      accountingBalance: (json['accountingBalance'] as num?)?.toDouble(),
      difference: (json['difference'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'ok',
      partyLedgerEntryCount:
          (json['partyLedgerEntryCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class GSTReconciliationRow {
  final String ledgerCode;
  final double expected;
  final String expectedType;
  final double actual;
  final String actualType;
  final double difference;
  final String status;

  GSTReconciliationRow({
    required this.ledgerCode,
    required this.expected,
    required this.expectedType,
    required this.actual,
    required this.actualType,
    required this.difference,
    required this.status,
  });

  factory GSTReconciliationRow.fromJson(Map<String, dynamic> json) {
    return GSTReconciliationRow(
      ledgerCode: json['ledgerCode']?.toString() ?? '',
      expected: (json['expected'] as num?)?.toDouble() ?? 0.0,
      expectedType: json['expectedType']?.toString() ?? 'CREDIT',
      actual: (json['actual'] as num?)?.toDouble() ?? 0.0,
      actualType: json['actualType']?.toString() ?? 'CREDIT',
      difference: (json['difference'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'ok',
    );
  }
}
