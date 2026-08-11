import 'chart_ledger.dart';

class ChartGroup {
  final String id;
  final String code;
  final String name;
  final String nature; // ASSET, LIABILITY, INCOME, EXPENSE
  final String normalBalance; // DEBIT, CREDIT
  final bool isSystem;
  final bool affectsGrossProfit;
  final bool isActive;
  final String? parent;
  final List<ChartGroup> subgroups;
  final List<ChartLedger> ledgers;

  ChartGroup({
    required this.id,
    required this.code,
    required this.name,
    required this.nature,
    this.normalBalance = 'DEBIT',
    this.isSystem = false,
    this.affectsGrossProfit = false,
    this.isActive = true,
    this.parent,
    this.subgroups = const [],
    this.ledgers = const [],
  });

  factory ChartGroup.fromJson(Map<String, dynamic> json) {
    final subList = <ChartGroup>[];
    final rawSub = json['childGroups'] ?? json['subgroups'] ?? json['children'];
    if (rawSub != null && rawSub is List) {
      for (final sub in rawSub) {
        if (sub is Map<String, dynamic>) {
          try {
            subList.add(ChartGroup.fromJson(sub));
          } catch (_) {}
        }
      }
    }

    final ledgerList = <ChartLedger>[];
    final rawLedgers = json['ledgers'] ?? json['accounts'];
    if (rawLedgers != null && rawLedgers is List) {
      for (final l in rawLedgers) {
        if (l is Map<String, dynamic>) {
          try {
            ledgerList.add(ChartLedger.fromJson(l));
          } catch (_) {}
        }
      }
    }

    return ChartGroup(
      id:
          json['groupId']?.toString() ??
          json['_id']?.toString() ??
          json['id']?.toString() ??
          '',
      code: json['code']?.toString() ?? '',
      name:
          json['groupName']?.toString() ?? json['name']?.toString() ?? 'Group',
      nature: (json['nature'] ?? json['category'] ?? json['type'] ?? 'ASSET')
          .toString()
          .toUpperCase(),
      normalBalance: (json['normalBalance'] ?? 'DEBIT')
          .toString()
          .toUpperCase(),
      isSystem: json['isSystemDefault'] == true || json['isSystem'] == true,
      affectsGrossProfit: json['affectsGrossProfit'] == true,
      isActive: json['isActive'] != false,
      parent:
          json['parentGroupId']?.toString() ??
          json['parent']?.toString() ??
          json['parentGroup']?.toString(),
      subgroups: subList,
      ledgers: ledgerList,
    );
  }
}
