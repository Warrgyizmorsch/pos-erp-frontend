class DayBookEntry {
  final String id;
  final String voucherId;
  final String date;
  final String voucherNo;
  final String voucherTypeCode;
  final String ledgerId;
  final String ledgerName;
  final String ledgerCode;
  final double debit;
  final double credit;
  final String? narration;
  final String? referenceNo;
  final String status;

  DayBookEntry({
    required this.id,
    required this.voucherId,
    required this.date,
    required this.voucherNo,
    required this.voucherTypeCode,
    required this.ledgerId,
    required this.ledgerName,
    required this.ledgerCode,
    required this.debit,
    required this.credit,
    this.narration,
    this.referenceNo,
    required this.status,
  });

  factory DayBookEntry.fromJson(Map<String, dynamic> json) {
    String lId = '';
    String lName = 'Ledger';
    String lCode = '';

    if (json['ledger'] != null) {
      if (json['ledger'] is Map<String, dynamic>) {
        lId =
            json['ledger']['_id']?.toString() ??
            json['ledger']['id']?.toString() ??
            '';
        lName = json['ledger']['name']?.toString() ?? 'Ledger';
        lCode = json['ledger']['code']?.toString() ?? '';
      } else {
        lName = json['ledger'].toString();
      }
    } else if (json['ledgerName'] != null) {
      lId = json['ledgerId']?.toString() ?? '';
      lName = json['ledgerName'].toString();
      lCode = json['ledgerCode']?.toString() ?? '';
    }

    return DayBookEntry(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      voucherId:
          json['voucherId']?.toString() ??
          json['voucher']?.toString() ??
          json['_id']?.toString() ??
          '',
      date:
          json['date']?.toString() ??
          json['createdAt']?.toString() ??
          DateTime.now().toIso8601String(),
      voucherNo:
          json['voucherNo']?.toString() ??
          json['referenceNo']?.toString() ??
          '',
      voucherTypeCode:
          json['voucherTypeCode']?.toString() ??
          json['typeCode']?.toString() ??
          'JV',
      ledgerId: lId,
      ledgerName: lName,
      ledgerCode: lCode,
      debit: (json['debit'] as num?)?.toDouble() ?? 0.0,
      credit: (json['credit'] as num?)?.toDouble() ?? 0.0,
      narration: json['narration']?.toString() ?? json['remarks']?.toString(),
      referenceNo: json['referenceNo']?.toString(),
      status: json['status']?.toString() ?? 'POSTED',
    );
  }
}

class DayBook {
  final String date;
  final List<DayBookEntry> entries;
  final double totalDebit;
  final double totalCredit;

  DayBook({
    required this.date,
    required this.entries,
    required this.totalDebit,
    required this.totalCredit,
  });

  factory DayBook.fromJson(Map<String, dynamic> json) {
    final entryList = <DayBookEntry>[];
    if (json['entries'] != null && json['entries'] is List) {
      for (final e in json['entries']) {
        if (e is Map<String, dynamic>) {
          try {
            entryList.add(DayBookEntry.fromJson(e));
          } catch (_) {}
        }
      }
    } else if (json['transactions'] != null && json['transactions'] is List) {
      for (final e in json['transactions']) {
        if (e is Map<String, dynamic>) {
          try {
            entryList.add(DayBookEntry.fromJson(e));
          } catch (_) {}
        }
      }
    }

    double dTot = 0.0;
    double cTot = 0.0;

    if (json['totals'] != null && json['totals'] is Map<String, dynamic>) {
      dTot = (json['totals']['totalDebit'] as num?)?.toDouble() ?? 0.0;
      cTot = (json['totals']['totalCredit'] as num?)?.toDouble() ?? 0.0;
    } else {
      dTot = (json['totalDebit'] as num?)?.toDouble() ?? 0.0;
      cTot = (json['totalCredit'] as num?)?.toDouble() ?? 0.0;
    }

    if (dTot == 0.0 && cTot == 0.0 && entryList.isNotEmpty) {
      for (final e in entryList) {
        dTot += e.debit;
        cTot += e.credit;
      }
    }

    return DayBook(
      date:
          json['date']?.toString() ??
          DateTime.now().toIso8601String().split('T')[0],
      entries: entryList,
      totalDebit: dTot,
      totalCredit: cTot,
    );
  }
}
