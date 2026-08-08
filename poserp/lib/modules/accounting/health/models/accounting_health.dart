class AccountingHealthIssue {
  final String id;
  final String severity; // 'critical', 'warning', 'info'
  final String type;
  final String module;
  final String? referenceId;
  final String? referenceNo;
  final String message;
  final String? suggestedFix;
  final String? voucherId;

  AccountingHealthIssue({
    required this.id,
    required this.severity,
    required this.type,
    required this.module,
    this.referenceId,
    this.referenceNo,
    required this.message,
    this.suggestedFix,
    this.voucherId,
  });

  factory AccountingHealthIssue.fromJson(Map<String, dynamic> json) {
    return AccountingHealthIssue(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      severity: json['severity']?.toString() ?? 'warning',
      type: json['type']?.toString() ?? '',
      module: json['module']?.toString() ?? '',
      referenceId: json['referenceId']?.toString(),
      referenceNo: json['referenceNo']?.toString(),
      message: json['message']?.toString() ?? '',
      suggestedFix: json['suggestedFix']?.toString(),
      voucherId: json['voucherId']?.toString(),
    );
  }
}

class AccountingHealthSummary {
  final int totalIssues;
  final int criticalIssues;
  final int warningIssues;
  final int missingPostings;
  final int ledgerMismatches;
  final int duplicateVouchers;

  AccountingHealthSummary({
    required this.totalIssues,
    required this.criticalIssues,
    required this.warningIssues,
    required this.missingPostings,
    required this.ledgerMismatches,
    required this.duplicateVouchers,
  });

  factory AccountingHealthSummary.fromJson(Map<String, dynamic> json) {
    return AccountingHealthSummary(
      totalIssues: (json['totalIssues'] as num?)?.toInt() ?? 0,
      criticalIssues: (json['criticalIssues'] as num?)?.toInt() ?? 0,
      warningIssues: (json['warningIssues'] as num?)?.toInt() ?? 0,
      missingPostings: (json['missingPostings'] as num?)?.toInt() ?? 0,
      ledgerMismatches: (json['ledgerMismatches'] as num?)?.toInt() ?? 0,
      duplicateVouchers: (json['duplicateVouchers'] as num?)?.toInt() ?? 0,
    );
  }
}

class AccountingHealthCheck {
  final String status; // 'healthy', 'warning', 'critical'
  final String checkedAt;
  final AccountingHealthSummary summary;
  final List<AccountingHealthIssue> issues;

  AccountingHealthCheck({
    required this.status,
    required this.checkedAt,
    required this.summary,
    required this.issues,
  });

  factory AccountingHealthCheck.fromJson(Map<String, dynamic> json) {
    return AccountingHealthCheck(
      status: json['status']?.toString() ?? 'healthy',
      checkedAt:
          json['checkedAt']?.toString() ?? DateTime.now().toIso8601String(),
      summary: json['summary'] is Map<String, dynamic>
          ? AccountingHealthSummary.fromJson(json['summary'])
          : AccountingHealthSummary(
              totalIssues: 0,
              criticalIssues: 0,
              warningIssues: 0,
              missingPostings: 0,
              ledgerMismatches: 0,
              duplicateVouchers: 0,
            ),
      issues:
          (json['issues'] as List?)
              ?.map(
                (e) => AccountingHealthIssue.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList() ??
          [],
    );
  }
}
