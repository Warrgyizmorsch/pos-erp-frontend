import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/financial_reports_controller.dart';
import '../models/financial_report.dart';

class BalanceSheetReportView extends GetView<FinancialReportsController> {
  const BalanceSheetReportView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Balance Sheet Statement'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => controller.loadCurrentTabReport(),
            tooltip: 'Refresh Statement',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. As On Date Filter Toolbar
            AppCard(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;

                  final dateInput = TextField(
                    onChanged: (val) => controller.asOnDate.value = val,
                    controller: TextEditingController(
                      text: controller.asOnDate.value,
                    ),
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'As On Date (YYYY-MM-DD)',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today, size: 16),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            controller.asOnDate.value = picked
                                .toIso8601String()
                                .split('T')[0];
                          }
                        },
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.inputDark
                          : Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.md,
                        borderSide: BorderSide(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                        ),
                      ),
                    ),
                  );

                  if (isMobile) {
                    return Column(
                      children: [
                        dateInput,
                        const SizedBox(height: 8),
                        AppButton(
                          text: 'Recalculate Statement',
                          icon: const Icon(Icons.refresh_rounded, size: 14),
                          onPressed: () => controller.loadCurrentTabReport(),
                        ),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: dateInput),
                      const SizedBox(width: 12),
                      AppButton(
                        text: 'Recalculate Statement',
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        onPressed: () => controller.loadCurrentTabReport(),
                      ),
                    ],
                  );
                },
              ),
            ),

            // 2. Statement Content Body
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const LoadingIndicator();
                }

                final bs = controller.balanceSheet.value;
                if (bs == null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!controller.isLoading.value) {
                      controller.loadBalanceSheet();
                    }
                  });
                  return const EmptyState(
                    icon: Icons.account_balance_rounded,
                    title: 'No Balance Sheet Data',
                    description:
                        'Recalculate as on target date to view asset and liability structures.',
                  );
                }

                final isBal = bs.isBalanced;
                final diff = bs.difference;

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Balance Status Card Header
                      AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                    (isBal
                                            ? AppColors.success
                                            : AppColors.warning)
                                        .withAlpha(25),
                                borderRadius: AppRadius.lg,
                              ),
                              child: Icon(
                                isBal
                                    ? Icons.check_circle_rounded
                                    : Icons.warning_amber_rounded,
                                color: isBal
                                    ? AppColors.success
                                    : AppColors.warning,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        isBal
                                            ? 'BALANCED STATEMENT'
                                            : 'UNMATCHED DIFFERENCE',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: isBal
                                              ? AppColors.success
                                              : AppColors.warning,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              (isBal
                                                      ? AppColors.success
                                                      : AppColors.warning)
                                                  .withAlpha(25),
                                          borderRadius: AppRadius.full,
                                        ),
                                        child: Text(
                                          isBal
                                              ? 'BALANCED'
                                              : 'DIFFERENCE ₹${diff.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: isBal
                                                ? AppColors.success
                                                : AppColors.warning,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Liabilities: ₹${bs.totalLiabilities.toStringAsFixed(2)}   |   Assets: ₹${bs.totalAssets.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 2-Column Tally Balance Sheet Layout (Liabilities on Left, Assets on Right)
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isDesktop = constraints.maxWidth >= 768;

                          if (!isDesktop) {
                            return Column(
                              children: [
                                _buildMobileSectionCard(
                                  'LIABILITIES & EQUITY',
                                  _prepareLiabilityLines(bs),
                                  bs.totalLiabilities,
                                  AppColors.info,
                                  isDark,
                                ),
                                const SizedBox(height: 16),
                                _buildMobileSectionCard(
                                  'ASSETS',
                                  _prepareAssetLines(bs),
                                  bs.totalAssets,
                                  AppColors.primary,
                                  isDark,
                                ),
                              ],
                            );
                          }

                          return _buildTwoColumnTallyBalanceSheet(bs, isDark);
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  List<_BSLine> _prepareLiabilityLines(BalanceSheetReport bs) {
    final lines = <_BSLine>[];

    if (bs.liabilityGroups.isNotEmpty) {
      for (final group in bs.liabilityGroups) {
        lines.add(
          _BSLine(
            label: group.groupName,
            amount: group.total,
            kind: _BSKind.group,
          ),
        );
        for (final l in group.ledgers) {
          lines.add(
            _BSLine(
              label: l.ledgerName,
              code: l.code,
              amount: l.amount,
              kind: _BSKind.ledger,
            ),
          );
        }
        lines.add(
          _BSLine(
            label: 'Total ${group.groupName}',
            amount: group.total,
            kind: _BSKind.subtotal,
          ),
        );
      }
    } else {
      for (final r in bs.liabilityRows) {
        lines.add(
          _BSLine(
            label: r.name,
            code: r.code,
            amount: r.amount,
            kind: _BSKind.ledger,
          ),
        );
      }
    }

    if (!bs.isBalanced) {
      lines.add(
        _BSLine(
          label: 'Difference',
          amount: bs.difference,
          kind: _BSKind.difference,
        ),
      );
    }

    return lines;
  }

  List<_BSLine> _prepareAssetLines(BalanceSheetReport bs) {
    final lines = <_BSLine>[];

    if (bs.assetGroups.isNotEmpty) {
      for (final group in bs.assetGroups) {
        lines.add(
          _BSLine(
            label: group.groupName,
            amount: group.total,
            kind: _BSKind.group,
          ),
        );
        for (final l in group.ledgers) {
          lines.add(
            _BSLine(
              label: l.ledgerName,
              code: l.code,
              amount: l.amount,
              kind: _BSKind.ledger,
            ),
          );
        }
        lines.add(
          _BSLine(
            label: 'Total ${group.groupName}',
            amount: group.total,
            kind: _BSKind.subtotal,
          ),
        );
      }
    } else {
      for (final r in bs.assetRows) {
        lines.add(
          _BSLine(
            label: r.name,
            code: r.code,
            amount: r.amount,
            kind: _BSKind.ledger,
          ),
        );
      }
    }

    if (!bs.isBalanced) {
      lines.add(
        _BSLine(
          label: 'Difference',
          amount: bs.difference,
          kind: _BSKind.difference,
        ),
      );
    }

    return lines;
  }

  Widget _buildTwoColumnTallyBalanceSheet(BalanceSheetReport bs, bool isDark) {
    final leftLines = _prepareLiabilityLines(bs);
    final rightLines = _prepareAssetLines(bs);
    final maxCount = leftLines.length > rightLines.length
        ? leftLines.length
        : rightLines.length;

    return AppCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: AppRadius.lg,
        child: Column(
          children: [
            // Header Row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.inputDark : Colors.grey[100],
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                  ),
                ),
              ),
              child: const Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      'LIABILITIES & EQUITY',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'AMOUNT (₹)',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  VerticalDivider(width: 24),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'ASSETS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'AMOUNT (₹)',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Rows Body
            if (maxCount == 0)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No balance sheet items recorded for selected date.',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: maxCount,
                separatorBuilder: (_, index) => Divider(
                  height: 1,
                  color: isDark
                      ? AppColors.borderDark.withAlpha(50)
                      : Colors.grey[200],
                ),
                itemBuilder: (context, index) {
                  final left = index < leftLines.length
                      ? leftLines[index]
                      : null;
                  final right = index < rightLines.length
                      ? rightLines[index]
                      : null;

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: _getRowColor(left, right, isDark),
                    child: Row(
                      children: [
                        // Left (Liabilities)
                        Expanded(
                          flex: 3,
                          child: left != null
                              ? _buildCellLabel(left)
                              : const SizedBox.shrink(),
                        ),
                        Expanded(
                          flex: 2,
                          child: left != null
                              ? Text(
                                  '₹${left.amount.toStringAsFixed(2)}',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: left.kind == _BSKind.ledger
                                        ? FontWeight.normal
                                        : FontWeight.bold,
                                    fontFamily: 'monospace',
                                    color: left.kind == _BSKind.difference
                                        ? AppColors.warning
                                        : null,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        const SizedBox(width: 24),
                        // Right (Assets)
                        Expanded(
                          flex: 3,
                          child: right != null
                              ? _buildCellLabel(right)
                              : const SizedBox.shrink(),
                        ),
                        Expanded(
                          flex: 2,
                          child: right != null
                              ? Text(
                                  '₹${right.amount.toStringAsFixed(2)}',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: right.kind == _BSKind.ledger
                                        ? FontWeight.normal
                                        : FontWeight.bold,
                                    fontFamily: 'monospace',
                                    color: right.kind == _BSKind.difference
                                        ? AppColors.warning
                                        : null,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  );
                },
              ),

            // Footer Totals
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.inputDark : Colors.grey[100],
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                    width: 2,
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Expanded(
                    flex: 3,
                    child: Text(
                      'TOTAL LIABILITIES & EQUITY',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '₹${bs.totalLiabilities.toStringAsFixed(2)}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  const Expanded(
                    flex: 3,
                    child: Text(
                      'TOTAL ASSETS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '₹${bs.totalAssets.toStringAsFixed(2)}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCellLabel(_BSLine line) {
    if (line.kind == _BSKind.ledger) {
      return Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(line.label, style: const TextStyle(fontSize: 12)),
            if (line.code.isNotEmpty)
              Text(
                line.code,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                  fontFamily: 'monospace',
                ),
              ),
          ],
        ),
      );
    }

    return Text(
      line.label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: line.kind == _BSKind.difference ? AppColors.warning : null,
      ),
    );
  }

  Color? _getRowColor(_BSLine? left, _BSLine? right, bool isDark) {
    if (left?.kind == _BSKind.difference || right?.kind == _BSKind.difference) {
      return AppColors.warning.withAlpha(20);
    }
    if (left?.kind == _BSKind.group || right?.kind == _BSKind.group) {
      return isDark ? Colors.grey[900] : Colors.grey[50];
    }
    return null;
  }

  Widget _buildMobileSectionCard(
    String title,
    List<_BSLine> lines,
    double total,
    Color themeColor,
    bool isDark,
  ) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '₹${total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: themeColor,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const Divider(height: 16),
          if (lines.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No recorded items',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: lines.length,
              separatorBuilder: (_, index) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final l = lines[index];
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: _buildCellLabel(l)),
                    Text(
                      '₹${l.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: l.kind == _BSKind.ledger
                            ? FontWeight.normal
                            : FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

enum _BSKind { group, ledger, subtotal, difference }

class _BSLine {
  final String label;
  final String code;
  final double amount;
  final _BSKind kind;

  _BSLine({
    required this.label,
    this.code = '',
    required this.amount,
    required this.kind,
  });
}
