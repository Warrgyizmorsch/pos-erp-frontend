import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../models/chart_group.dart';

class AccountGroupTile extends StatelessWidget {
  final ChartGroup group;
  final int depth;

  const AccountGroupTile({super.key, required this.group, this.depth = 0});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final natureColor = _getNatureColor(group.nature);

    return Container(
      margin: EdgeInsets.only(left: depth * 16.0, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: AppRadius.md,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        childrenPadding: const EdgeInsets.only(left: 12, right: 12, bottom: 10),
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
        title: Row(
          children: [
            if (group.code.isNotEmpty) ...[
              Text(
                '${group.code} - ',
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: Colors.grey,
                ),
              ),
            ],
            Expanded(
              child: Text(
                group.name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: natureColor.withAlpha(20),
                borderRadius: AppRadius.full,
              ),
              child: Text(
                group.nature.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: natureColor,
                ),
              ),
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
            const SizedBox(height: 6),
            const Text(
              'LEDGERS / ACCOUNTS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            ...group.ledgers.map((l) {
              return Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.inputDark : Colors.grey[100],
                  borderRadius: AppRadius.sm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.account_tree_outlined,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l.name,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (l.code.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Text(
                            '(${l.code})',
                            style: const TextStyle(
                              fontSize: 11,
                              fontFamily: 'monospace',
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      '₹${l.currentBalance.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        color: l.currentBalance >= 0
                            ? AppColors.success
                            : AppColors.danger,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Color _getNatureColor(String nature) {
    final n = nature.toLowerCase();
    if (n.contains('asset')) return AppColors.info;
    if (n.contains('liab')) return AppColors.danger;
    if (n.contains('equity')) return AppColors.warning;
    if (n.contains('income') || n.contains('revenue')) return AppColors.success;
    return Colors.purple;
  }

  IconData _getNatureIcon(String nature) {
    final n = nature.toLowerCase();
    if (n.contains('asset')) return Icons.account_balance_wallet_outlined;
    if (n.contains('liab')) return Icons.credit_card_outlined;
    if (n.contains('equity')) return Icons.pie_chart_outline_rounded;
    if (n.contains('income') || n.contains('revenue')) {
      return Icons.trending_up_rounded;
    }
    return Icons.trending_down_rounded;
  }
}
