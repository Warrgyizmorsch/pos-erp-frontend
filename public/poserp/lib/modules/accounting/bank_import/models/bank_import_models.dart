class BankStatementTransaction {
  final String id;
  final String date;
  final String narration;
  final String? chequeNo;
  final double deposit;
  final double withdrawal;
  final double amount;
  final String type; // 'DEPOSIT', 'WITHDRAWAL'
  final String? mappedLedgerId;
  final String? mappedLedgerName;
  final double confidenceScore;
  final String status; // 'auto_mapped', 'manual_review', 'posted'
  final String? voucherId;

  BankStatementTransaction({
    required this.id,
    required this.date,
    required this.narration,
    this.chequeNo,
    required this.deposit,
    required this.withdrawal,
    required this.amount,
    required this.type,
    this.mappedLedgerId,
    this.mappedLedgerName,
    required this.confidenceScore,
    required this.status,
    this.voucherId,
  });

  factory BankStatementTransaction.fromJson(Map<String, dynamic> json) {
    return BankStatementTransaction(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      narration: json['narration']?.toString() ?? '',
      chequeNo: json['chequeNo']?.toString(),
      deposit: (json['deposit'] as num?)?.toDouble() ?? 0.0,
      withdrawal: (json['withdrawal'] as num?)?.toDouble() ?? 0.0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      type: json['type']?.toString() ?? 'DEPOSIT',
      mappedLedgerId: json['mappedLedgerId']?.toString(),
      mappedLedgerName:
          json['mappedLedgerName']?.toString() ??
          json['mappedLedger']?['name']?.toString(),
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'auto_mapped',
      voucherId: json['voucherId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date,
    'narration': narration,
    'chequeNo': chequeNo,
    'deposit': deposit,
    'withdrawal': withdrawal,
    'amount': amount,
    'type': type,
    'mappedLedgerId': mappedLedgerId,
    'mappedLedgerName': mappedLedgerName,
    'confidenceScore': confidenceScore,
    'status': status,
    'voucherId': voucherId,
  };
}

class BankStatementImportSession {
  final String sessionId;
  final String bankAccountId;
  final String bankAccountName;
  final String filename;
  final int totalTransactions;
  final int autoMappedCount;
  final int manualReviewCount;
  final int postedCount;
  final List<BankStatementTransaction> transactions;

  BankStatementImportSession({
    required this.sessionId,
    required this.bankAccountId,
    required this.bankAccountName,
    required this.filename,
    required this.totalTransactions,
    required this.autoMappedCount,
    required this.manualReviewCount,
    required this.postedCount,
    required this.transactions,
  });

  factory BankStatementImportSession.fromJson(Map<String, dynamic> json) {
    return BankStatementImportSession(
      sessionId: json['sessionId']?.toString() ?? json['_id']?.toString() ?? '',
      bankAccountId: json['bankAccountId']?.toString() ?? '',
      bankAccountName: json['bankAccountName']?.toString() ?? '',
      filename: json['filename']?.toString() ?? 'statement.csv',
      totalTransactions: (json['totalTransactions'] as num?)?.toInt() ?? 0,
      autoMappedCount: (json['autoMappedCount'] as num?)?.toInt() ?? 0,
      manualReviewCount: (json['manualReviewCount'] as num?)?.toInt() ?? 0,
      postedCount: (json['postedCount'] as num?)?.toInt() ?? 0,
      transactions:
          (json['transactions'] as List?)
              ?.map(
                (e) => BankStatementTransaction.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList() ??
          [],
    );
  }
}

class BankMappingRule {
  final String id;
  final String narrationPattern;
  final String matchType; // 'exact', 'contains', 'regex'
  final String ledgerId;
  final String? ledgerCode;
  final String? ledgerName;
  final String? groupType;
  final bool isActive;
  final int matchCount;
  final double confidence;

  BankMappingRule({
    required this.id,
    required this.narrationPattern,
    required this.matchType,
    required this.ledgerId,
    this.ledgerCode,
    this.ledgerName,
    this.groupType,
    required this.isActive,
    required this.matchCount,
    this.confidence = 100.0,
  });

  factory BankMappingRule.fromJson(Map<String, dynamic> json) {
    final ledger = json['ledger'];
    return BankMappingRule(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      narrationPattern:
          json['pattern']?.toString() ??
          json['narrationPattern']?.toString() ??
          '',
      matchType: json['matchType']?.toString() ?? 'contains',
      ledgerId: json['ledgerId']?.toString() ?? '',
      ledgerCode: ledger is Map
          ? ledger['code']?.toString()
          : json['ledgerCode']?.toString(),
      ledgerName: ledger is Map
          ? ledger['name']?.toString()
          : json['ledgerName']?.toString() ?? json['ledgerName']?.toString(),
      groupType:
          json['groupType']?.toString() ??
          json['ledgerGroup']?.toString() ??
          'INDIRECT_EXPENSES',
      isActive: json['isActive'] ?? true,
      matchCount: (json['matchCount'] as num?)?.toInt() ?? 0,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 100.0,
    );
  }
}

class BankImportSettings {
  final String? defaultBankLedgerId;
  final String? defaultExpenseLedgerId;
  final String? defaultIncomeLedgerId;
  final bool autoPostHighConfidence;
  final double confidenceThreshold;

  BankImportSettings({
    this.defaultBankLedgerId,
    this.defaultExpenseLedgerId,
    this.defaultIncomeLedgerId,
    required this.autoPostHighConfidence,
    required this.confidenceThreshold,
  });

  factory BankImportSettings.fromJson(Map<String, dynamic> json) {
    return BankImportSettings(
      defaultBankLedgerId: json['defaultBankLedgerId']?.toString(),
      defaultExpenseLedgerId: json['defaultExpenseLedgerId']?.toString(),
      defaultIncomeLedgerId: json['defaultIncomeLedgerId']?.toString(),
      autoPostHighConfidence: json['autoPostHighConfidence'] ?? false,
      confidenceThreshold:
          (json['confidenceThreshold'] as num?)?.toDouble() ?? 0.85,
    );
  }

  Map<String, dynamic> toJson() => {
    'defaultBankLedgerId': defaultBankLedgerId,
    'defaultExpenseLedgerId': defaultExpenseLedgerId,
    'defaultIncomeLedgerId': defaultIncomeLedgerId,
    'autoPostHighConfidence': autoPostHighConfidence,
    'confidenceThreshold': confidenceThreshold,
  };
}
