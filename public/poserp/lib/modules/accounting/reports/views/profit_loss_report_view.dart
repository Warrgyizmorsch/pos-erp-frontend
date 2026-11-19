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

class ProfitLossReportView extends GetView<FinancialReportsController> {
  const ProfitLossReportView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profit & Loss Statement'),
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
            // 1. Date Range Filter Toolbar
            AppCard(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;

                  final startInput = TextField(
                    onChanged: (val) => controller.startDate.value = val,
                    controller: TextEditingController(
                      text: controller.startDate.value,
                    ),
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'Start Date (YYYY-MM-DD)',
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
                            controller.startDate.value = picked
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

                  final endInput = TextField(
                    onChanged: (val) => controller.endDate.value = val,
                    controller: TextEditingController(
                      text: controller.endDate.value,
                    ),
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'End Date (YYYY-MM-DD)',
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
                            controller.endDate.value = picked
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
                        startInput,
                        const SizedBox(height: 8),
                        endInput,
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: startInput),
                      const SizedBox(width: 12),
                      Expanded(child: endInput),
                      const SizedBox(width: 12),
                      AppButton(
                        text: 'Apply Filter',
                        icon: const Icon(Icons.filter_alt_rounded, size: 16),
                        onPressed: () => controller.loadCurrentTabReport(),
                      ),
                    ],
                  );
                },
              ),
            ),

            // 2. Statement Body
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const LoadingIndicator();
                }

                final pl = controller.profitLoss.value;
                if (pl == null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!controller.isLoading.value) {
                      controller.loadProfitLoss();
                    }
                  });
                  return const EmptyState(
                    icon: Icons.trending_up_rounded,
                    title: 'No Statement Data Available',
                    description:
                        'Select a valid date range to compute revenue and operating expenses.',
                  );
                }

                final isProf = pl.netProfit >= 0;
                final netVal = pl.netProfit.abs();

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Top 3 Metric Summary Cards (Income, Expenses, Net Profit/Loss)
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isMobile = constraints.maxWidth < 600;

                          if (isMobile) {
                            return Column(
                              children: [
                                _buildSummaryCard(
                                  'Total Income',
                                  pl.totalIncome,
                                  AppColors.success,
                                  isDark,
                                ),
                                const SizedBox(height: 8),
                                _buildSummaryCard(
                                  'Total Expenses',
                                  pl.totalExpenses,
                                  AppColors.danger,
                                  isDark,
                                ),
                                const SizedBox(height: 8),
                                _buildSummaryCard(
                                  isProf ? 'Net Profit' : 'Net Loss',
                                  netVal,
                                  isProf ? AppColors.success : AppColors.danger,
                                  isDark,
                                ),
                              ],
                            );
                          }

                          return Row(
                            children: [
                              Expanded(
                                child: _buildSummaryCard(
                                  'Total Income',
                                  pl.totalIncome,
                                  AppColors.success,
                                  isDark,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildSummaryCard(
                                  'Total Expenses',
                                  pl.totalExpenses,
                                  AppColors.danger,
                                  isDark,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildSummaryCard(
                                  isProf ? 'Net Profit' : 'Net Loss',
                                  netVal,
                                  isProf ? AppColors.success : AppColors.danger,
                                  isDark,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // 2-Column Tally Statement Layout (Expenses on Left, Income on Right)
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isDesktop = constraints.maxWidth >= 768;

                          if (!isDesktop) {
                            return Column(
                              children: [
                                _buildMobileStatementCard(
                                  'EXPENSES STATEMENT',
                                  _prepareExpensesLines(pl),
                                  pl.totalExpenses + (isProf ? netVal : 0),
                                  AppColors.danger,
                                  isDark,
                                ),
                                const SizedBox(height: 16),
                                _buildMobileStatementCard(
                                  'INCOME STATEMENT',
                                  _prepareIncomeLines(pl),
                                  pl.totalIncome + (!isProf ? netVal : 0),
                                  AppColors.success,
                                  isDark,
                                ),
                              ],
                            );
                          }

                          return _buildTwoColumnTallyStatement(pl, isDark);
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

  Widget _buildSummaryCard(
    String label,
    double value,
    Color color,
    bool isDark,
  ) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 6),
          Text(
            '₹${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  List<_StatementLine> _prepareExpensesLines(ProfitLossReport pl) {
    final lines = <_StatementLine>[];

    if (pl.expenseGroups.isNotEmpty) {
      for (final group in pl.expenseGroups) {
        lines.add(
          _StatementLine(
            label: group.groupName,
            amount: group.total,
            kind: _LineKind.group,
          ),
        );
        for (final l in group.ledgers) {
          lines.add(
            _StatementLine(
              label: l.ledgerName,
              code: l.code,
              amount: l.amount,
              kind: _LineKind.ledger,
            ),
          );
        }
        lines.add(
          _StatementLine(
            label: 'Subtotal ${group.groupName}',
            amount: group.total,
            kind: _LineKind.subtotal,
          ),
        );
      }
    } else {
      for (final r in pl.expenseRows) {
        lines.add(
          _StatementLine(
            label: r.name,
            code: r.code,
            amount: r.amount,
            kind: _LineKind.ledger,
          ),
        );
      }
    }

    if (pl.netProfit > 0) {
      lines.add(
        _StatementLine(
          label: 'Net Profit',
          amount: pl.netProfit,
          kind: _LineKind.result,
        ),
      );
    }

    return lines;
  }

  List<_StatementLine> _prepareIncomeLines(ProfitLossReport pl) {
    final lines = <_StatementLine>[];

    if (pl.incomeGroups.isNotEmpty) {
      for (final group in pl.incomeGroups) {
        lines.add(
          _StatementLine(
            label: group.groupName,
            amount: group.total,
            kind: _LineKind.group,
          ),
        );
        for (final l in group.ledgers) {
          lines.add(
            _StatementLine(
              label: l.ledgerName,
              code: l.code,
              amount: l.amount,
              kind: _LineKind.ledger,
            ),
          );
        }
        lines.add(
          _StatementLine(
            label: 'Subtotal ${group.groupName}',
            amount: group.total,
            kind: _LineKind.subtotal,
          ),
        );
      }
    } else {
      for (final r in pl.incomeRows) {
        lines.add(
          _StatementLine(
            label: r.name,
            code: r.code,
            amount: r.amount,
            kind: _LineKind.ledger,
          ),
        );
      }
    }

    if (pl.netProfit < 0) {
      lines.add(
        _StatementLine(
          label: 'Net Loss',
          amount: pl.netProfit.abs(),
          kind: _LineKind.result,
        ),
      );
    }

    return lines;
  }

  Widget _buildTwoColumnTallyStatement(ProfitLossReport pl, bool isDark) {
    final expLines = _prepareExpensesLines(pl);
    final incLines = _prepareIncomeLines(pl);
    final maxCount = expLines.length > incLines.length
        ? expLines.length
        : incLines.length;

    final leftTotal = pl.totalExpenses + (pl.netProfit > 0 ? pl.netProfit : 0);
    final rightTotal =
        pl.totalIncome + (pl.netProfit < 0 ? pl.netProfit.abs() : 0);

    return AppCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: AppRadius.lg,
        child: Column(
          children: [
            // Table Header
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
                      'EXPENSES',
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
                      'INCOME',
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

            // Rows
            if (maxCount == 0)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No statement rows recorded for period.',
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
                  final left = index < expLines.length ? expLines[index] : null;
                  final right = index < incLines.length
                      ? incLines[index]
                      : null;

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: _getRowColor(left, right, isDark),
                    child: Row(
                      children: [
                        // Left Cell (Expenses)
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
                                    fontWeight: left.kind == _LineKind.ledger
                                        ? FontWeight.normal
                                        : FontWeight.bold,
                                    fontFamily: 'monospace',
                                    color: left.kind == _LineKind.result
                                        ? AppColors.success
                                        : null,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        const SizedBox(width: 24),
                        // Right Cell (Income)
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
                                    fontWeight: right.kind == _LineKind.ledger
                                        ? FontWeight.normal
                                        : FontWeight.bold,
                                    fontFamily: 'monospace',
                                    color: right.kind == _LineKind.result
                                        ? AppColors.danger
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

            // Footer Balanced Totals
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
                      'TOTAL EXPENSES & PROFIT',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '₹${leftTotal.toStringAsFixed(2)}',
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
                      'TOTAL INCOME & LOSS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '₹${rightTotal.toStringAsFixed(2)}',
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

  Widget _buildCellLabel(_StatementLine line) {
    if (line.kind == _LineKind.ledger) {
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
        color: line.kind == _LineKind.result
            ? (line.label.contains('Profit')
                  ? AppColors.success
                  : AppColors.danger)
            : null,
      ),
    );
  }

  Color? _getRowColor(
    _StatementLine? left,
    _StatementLine? right,
    bool isDark,
  ) {
    if (left?.kind == _LineKind.result || right?.kind == _LineKind.result) {
      return AppColors.primary.withAlpha(15);
    }
    if (left?.kind == _LineKind.group || right?.kind == _LineKind.group) {
      return isDark ? Colors.grey[900] : Colors.grey[50];
    }
    return null;
  }

  Widget _buildMobileStatementCard(
    String title,
    List<_StatementLine> lines,
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
                'No recorded lines',
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
                        fontWeight: l.kind == _LineKind.ledger
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

enum _LineKind { group, ledger, subtotal, result }

class _StatementLine {
  final String label;
  final String code;
  final double amount;
  final _LineKind kind;

  _StatementLine({
    required this.label,
    this.code = '',
    required this.amount,
    required this.kind,
  });
}
