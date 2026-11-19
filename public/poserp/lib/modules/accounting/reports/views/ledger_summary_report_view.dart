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

class LedgerSummaryReportView extends GetView<FinancialReportsController> {
  const LedgerSummaryReportView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ledger Summary Report'),
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
                        const SizedBox(height: 8),
                        AppButton(
                          text: 'Apply Filter',
                          icon: const Icon(Icons.filter_alt_rounded, size: 14),
                          onPressed: () => controller.loadCurrentTabReport(),
                        ),
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

                final report = controller.ledgerSummary.value;
                if (report == null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!controller.isLoading.value) {
                      controller.loadLedgerSummary();
                    }
                  });
                  return const EmptyState(
                    icon: Icons.summarize_rounded,
                    title: 'No Ledger Summary Data',
                    description:
                        'Select a valid date range to view account group balances.',
                  );
                }

                final grouped = _groupLedgerRows(report.rows);

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isDesktop = constraints.maxWidth >= 768;

                          if (!isDesktop) {
                            return _buildMobileGroupedList(grouped, isDark);
                          }

                          return _buildDesktopLedgerSummaryTable(
                            grouped,
                            isDark,
                          );
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

  Map<String, List<LedgerSummaryRow>> _groupLedgerRows(
    List<LedgerSummaryRow> rows,
  ) {
    final groups = <String, List<LedgerSummaryRow>>{};
    for (final row in rows) {
      final key = row.groupName.isNotEmpty ? row.groupName : 'General Group';
      groups.putIfAbsent(key, () => []).add(row);
    }
    return groups;
  }

  Widget _buildDesktopLedgerSummaryTable(
    Map<String, List<LedgerSummaryRow>> grouped,
    bool isDark,
  ) {
    double grandOpening = 0.0;
    double grandDebit = 0.0;
    double grandCredit = 0.0;
    double grandClosing = 0.0;

    for (final list in grouped.values) {
      for (final r in list) {
        grandOpening += r.openingBalance;
        grandDebit += r.periodDebit;
        grandCredit += r.periodCredit;
        grandClosing += r.closingBalance;
      }
    }

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
                    flex: 4,
                    child: Text(
                      'PARTICULARS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'OPENING',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'DEBIT (₹)',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'CREDIT (₹)',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'CLOSING',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Rows Body
            if (grouped.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No ledger summary rows available.',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: grouped.length,
                itemBuilder: (context, gIndex) {
                  final groupName = grouped.keys.elementAt(gIndex);
                  final items = grouped[groupName]!;

                  double groupOpening = 0;
                  double groupDebit = 0;
                  double groupCredit = 0;
                  double groupClosing = 0;

                  for (final r in items) {
                    groupOpening += r.openingBalance;
                    groupDebit += r.periodDebit;
                    groupCredit += r.periodCredit;
                    groupClosing += r.closingBalance;
                  }

                  return Column(
                    children: [
                      // Group Header Row
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        color: isDark ? Colors.grey[900] : Colors.grey[50],
                        child: Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: Text(
                                groupName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '₹${groupOpening.toStringAsFixed(2)}',
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '₹${groupDebit.toStringAsFixed(2)}',
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '₹${groupCredit.toStringAsFixed(2)}',
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '₹${groupClosing.toStringAsFixed(2)}',
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Ledger Item Rows
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: items.length,
                        separatorBuilder: (_, index) => Divider(
                          height: 1,
                          color: isDark
                              ? AppColors.borderDark.withAlpha(40)
                              : Colors.grey[200],
                        ),
                        itemBuilder: (context, rIndex) {
                          final row = items[rIndex];
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            if (row.ledgerId.isNotEmpty) {
                                              Get.toNamed(
                                                '/accounting/ledgers/${row.ledgerId}',
                                              );
                                            }
                                          },
                                          child: Text(
                                            row.ledgerName,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '${row.code.isNotEmpty ? row.code : "-"} · ${row.ledgerType}',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '₹${row.openingBalance.toStringAsFixed(2)} ${row.openingBalanceType == "CREDIT" ? "Cr" : "Dr"}',
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    row.periodDebit > 0
                                        ? '₹${row.periodDebit.toStringAsFixed(2)}'
                                        : '-',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: row.periodDebit > 0
                                          ? AppColors.success
                                          : null,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    row.periodCredit > 0
                                        ? '₹${row.periodCredit.toStringAsFixed(2)}'
                                        : '-',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: row.periodCredit > 0
                                          ? AppColors.danger
                                          : null,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '₹${row.closingBalance.toStringAsFixed(2)} ${row.closingBalanceType == "CREDIT" ? "Cr" : "Dr"}',
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),

            // Grand Total Footer Row
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
                    flex: 4,
                    child: Text(
                      'GRAND TOTAL',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '₹${grandOpening.toStringAsFixed(2)}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '₹${grandDebit.toStringAsFixed(2)}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        color: AppColors.success,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '₹${grandCredit.toStringAsFixed(2)}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        color: AppColors.danger,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '₹${grandClosing.toStringAsFixed(2)}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 12,
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

  Widget _buildMobileGroupedList(
    Map<String, List<LedgerSummaryRow>> grouped,
    bool isDark,
  ) {
    return Column(
      children: [
        if (grouped.isEmpty)
          const AppCard(
            padding: EdgeInsets.all(24),
            child: Center(
              child: Text(
                'No ledger items recorded.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: grouped.length,
            itemBuilder: (context, gIndex) {
              final groupName = grouped.keys.elementAt(gIndex);
              final items = grouped[groupName]!;

              return AppCard(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                child: ExpansionTile(
                  title: Text(
                    groupName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${items.length} Ledgers',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  children: items.map((row) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                row.ledgerName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              AppButton(
                                text: 'View Ledger',
                                variant: AppButtonVariant.outline,
                                onPressed: () {
                                  if (row.ledgerId.isNotEmpty) {
                                    Get.toNamed(
                                      '/accounting/ledgers/${row.ledgerId}',
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Dr: ₹${row.periodDebit.toStringAsFixed(2)} | Cr: ₹${row.periodCredit.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                'Closing: ₹${row.closingBalance.toStringAsFixed(2)} ${row.closingBalanceType == "CREDIT" ? "Cr" : "Dr"}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
      ],
    );
  }
}
