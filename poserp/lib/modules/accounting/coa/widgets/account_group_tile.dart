import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../models/chart_group.dart';
import '../models/chart_ledger.dart';

class AccountGroupTile extends StatelessWidget {
  final ChartGroup group;
  final int depth;

  const AccountGroupTile({super.key, required this.group, this.depth = 0});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final natureColor = _getNatureColor(group.nature);

    return Container(
      margin: EdgeInsets.only(
        left: depth > 0 ? (depth * 14.0).clamp(0.0, 42.0) : 0.0,
        top: 4,
        bottom: 4,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: AppRadius.md,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: ExpansionTile(
        initiallyExpanded: depth == 0,
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        childrenPadding: const EdgeInsets.only(left: 10, right: 10, bottom: 8),
        leading: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: natureColor.withAlpha(25),
            borderRadius: AppRadius.sm,
          ),
          child: Icon(
            _getNatureIcon(group.nature),
            color: natureColor,
            size: 18,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6,
              runSpacing: 4,
              children: [
                Text(
                  group.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (group.isSystem)
                  _buildBadge('System', AppColors.primary, isOutline: true),
                if (group.affectsGrossProfit)
                  _buildBadge('Gross Profit', Colors.teal, isOutline: true),
                _buildBadge(
                  group.isActive ? 'Active' : 'Inactive',
                  group.isActive ? AppColors.success : Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              '${group.code} · ${group.nature} · Normal ${group.normalBalance}',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
        children: [
          // Subgroups
          if (group.subgroups.isNotEmpty)
            ...group.subgroups.map(
              (sub) => AccountGroupTile(group: sub, depth: depth + 1),
            ),

          // Ledgers under this group
          if (group.ledgers.isNotEmpty) ...[
            const SizedBox(height: 4),
            ...group.ledgers.map((l) => _buildLedgerLine(context, l)),
          ] else if (group.subgroups.isEmpty) ...[
            Container(
              padding: const EdgeInsets.all(8),
              alignment: Alignment.centerLeft,
              child: const Text(
                'No ledgers in this group.',
                style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLedgerLine(BuildContext context, ChartLedger ledger) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final balSuffix = ledger.currentBalanceType == 'CREDIT' ? 'Cr' : 'Dr';

    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.inputDark : Colors.grey[100],
        borderRadius: AppRadius.sm,
        border: Border.all(
          color: isDark ? AppColors.borderDark : Colors.grey[300]!,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 400;

          if (isMobile) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        ledger.name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _buildBadge(
                      ledger.ledgerType,
                      AppColors.info,
                      isOutline: true,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      ledger.code,
                      style: const TextStyle(
                        fontSize: 10,
                        fontFamily: 'monospace',
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      '₹${ledger.currentBalance.toStringAsFixed(2)} $balSuffix',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        color: balSuffix == 'Cr'
                            ? AppColors.success
                            : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            );
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      ledger.name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (ledger.code.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Text(
                        '(${ledger.code})',
                        style: const TextStyle(
                          fontSize: 10,
                          fontFamily: 'monospace',
                          color: Colors.grey,
                        ),
                      ),
                    ],
                    if (ledger.isSystem) ...[
                      const SizedBox(width: 6),
                      _buildBadge('System', AppColors.primary, isOutline: true),
                    ],
                  ],
                ),
              ),
              Row(
                children: [
                  _buildBadge(
                    ledger.ledgerType,
                    AppColors.info,
                    isOutline: true,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '₹${ledger.currentBalance.toStringAsFixed(2)} $balSuffix',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      color: balSuffix == 'Cr'
                          ? AppColors.success
                          : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBadge(String label, Color color, {bool isOutline = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: isOutline ? color.withAlpha(20) : color.withAlpha(30),
        borderRadius: AppRadius.full,
        border: isOutline ? Border.all(color: color.withAlpha(60)) : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Color _getNatureColor(String nature) {
    final n = nature.toUpperCase();
    if (n.contains('ASSET')) return AppColors.info;
    if (n.contains('LIAB')) return AppColors.danger;
    if (n.contains('EQUITY')) return AppColors.warning;
    if (n.contains('INCOME') || n.contains('REVENUE')) return AppColors.success;
    return Colors.purple;
  }

  IconData _getNatureIcon(String nature) {
    final n = nature.toUpperCase();
    if (n.contains('ASSET')) return Icons.account_balance_wallet_outlined;
    if (n.contains('LIAB')) return Icons.credit_card_outlined;
    if (n.contains('EQUITY')) return Icons.pie_chart_outline_rounded;
    if (n.contains('INCOME') || n.contains('REVENUE')) {
      return Icons.trending_up_rounded;
    }
    return Icons.trending_down_rounded;
  }
}
