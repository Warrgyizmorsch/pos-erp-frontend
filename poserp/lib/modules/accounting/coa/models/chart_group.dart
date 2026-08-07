import 'chart_ledger.dart';

class ChartGroup {
  final String id;
  final String code;
  final String name;
  final String nature; // 'asset', 'liability', 'equity', 'revenue', 'expense'
  final String? parent;
  final List<ChartGroup> subgroups;
  final List<ChartLedger> ledgers;

  ChartGroup({
    required this.id,
    required this.code,
    required this.name,
    required this.nature,
    this.parent,
    this.subgroups = const [],
    this.ledgers = const [],
  });

  factory ChartGroup.fromJson(Map<String, dynamic> json) {
    final subList = <ChartGroup>[];
    if (json['subgroups'] != null && json['subgroups'] is List) {
      for (final sub in json['subgroups']) {
        if (sub is Map<String, dynamic>) {
          try {
            subList.add(ChartGroup.fromJson(sub));
          } catch (_) {}
        }
      }
    } else if (json['children'] != null && json['children'] is List) {
      for (final sub in json['children']) {
        if (sub is Map<String, dynamic>) {
          try {
            subList.add(ChartGroup.fromJson(sub));
          } catch (_) {}
        }
      }
    }

    final ledgerList = <ChartLedger>[];
    if (json['ledgers'] != null && json['ledgers'] is List) {
      for (final l in json['ledgers']) {
        if (l is Map<String, dynamic>) {
          try {
            ledgerList.add(ChartLedger.fromJson(l));
          } catch (_) {}
        }
      }
    } else if (json['accounts'] != null && json['accounts'] is List) {
      for (final l in json['accounts']) {
        if (l is Map<String, dynamic>) {
          try {
            ledgerList.add(ChartLedger.fromJson(l));
          } catch (_) {}
        }
      }
    }

    return ChartGroup(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      name:
          json['name']?.toString() ?? json['groupName']?.toString() ?? 'Group',
      nature:
          json['nature']?.toString() ??
          json['category']?.toString() ??
          json['type']?.toString() ??
          'asset',
      parent: json['parent']?.toString() ?? json['parentGroup']?.toString(),
      subgroups: subList,
      ledgers: ledgerList,
    );
  }
}
