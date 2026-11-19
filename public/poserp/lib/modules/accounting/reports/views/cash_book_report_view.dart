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

class CashBookReportView extends GetView<FinancialReportsController> {
  const CashBookReportView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cash Book Report'),
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

            // 2. Statement Content Body
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const LoadingIndicator();
                }

                final cb = controller.cashBook.value;
                if (cb == null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!controller.isLoading.value) {
                      controller.loadCashBook();
                    }
                  });
                  return const EmptyState(
                    icon: Icons.account_balance_wallet_rounded,
                    title: 'No Cash Book Data',
                    description:
                        'Select a date range to view cash receipts, payments, and running balances.',
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Top 3 Metric Summary Cards (Opening, Receipts, Closing)
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isMobile = constraints.maxWidth < 600;

                          final openingWidget = _buildSummaryMetricCard(
                            'Opening Balance',
                            cb.openingBalance,
                            cb.openingBalanceType == 'CREDIT' ? 'Cr' : 'Dr',
                            AppColors.info,
                            isDark,
                          );
                          final receiptsWidget = _buildSummaryMetricCard(
                            'Total Receipts',
                            cb.totals.totalReceipts,
                            '',
                            AppColors.success,
                            isDark,
                          );
                          final closingWidget = _buildSummaryMetricCard(
                            'Closing Balance',
                            cb.totals.closingBalance,
                            cb.totals.closingBalanceType == 'CREDIT'
                                ? 'Cr'
                                : 'Dr',
                            AppColors.primary,
                            isDark,
                          );

                          if (isMobile) {
                            return Column(
                              children: [
                                openingWidget,
                                const SizedBox(height: 8),
                                receiptsWidget,
                                const SizedBox(height: 8),
                                closingWidget,
                              ],
                            );
                          }

                          return Row(
                            children: [
                              Expanded(child: openingWidget),
                              const SizedBox(width: 12),
                              Expanded(child: receiptsWidget),
                              const SizedBox(width: 12),
                              Expanded(child: closingWidget),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // Statement Data Table
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isDesktop = constraints.maxWidth >= 768;

                          if (!isDesktop) {
                            return _buildMobileCashBookList(cb, isDark);
                          }

                          return _buildDesktopCashBookTable(cb, isDark);
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

  Widget _buildSummaryMetricCard(
    String label,
    double amount,
    String badge,
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
          Row(
            children: [
              Text(
                '₹${amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontFamily: 'monospace',
                ),
              ),
              if (badge.isNotEmpty) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color.withAlpha(25),
                    borderRadius: AppRadius.sm,
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopCashBookTable(BookReport cb, bool isDark) {
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
                    flex: 2,
                    child: Text(
                      'DATE',
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
                      'VOUCHER',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
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
                      'REFERENCE',
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
                      'RECEIPT (₹)',
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
                      'PAYMENT (₹)',
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
                      'BALANCE (₹)',
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

            // 1. Opening Balance Row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: isDark ? Colors.grey[900] : Colors.grey[50],
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      cb.startDate.isNotEmpty ? cb.startDate : '-',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const Expanded(
                    flex: 2,
                    child: Text(
                      'Opening',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Expanded(
                    flex: 3,
                    child: Text(
                      'Opening Balance',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Expanded(
                    flex: 2,
                    child: Text('-', style: TextStyle(fontSize: 12)),
                  ),
                  const Expanded(
                    flex: 2,
                    child: Text(
                      '-',
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  const Expanded(
                    flex: 2,
                    child: Text(
                      '-',
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '₹${cb.openingBalance.toStringAsFixed(2)} ${cb.openingBalanceType == "CREDIT" ? "Cr" : "Dr"}',
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
            const Divider(height: 1),

            // 2. Entries List
            if (cb.entries.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No cash transactions recorded for selected period.',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cb.entries.length,
                separatorBuilder: (_, index) => Divider(
                  height: 1,
                  color: isDark
                      ? AppColors.borderDark.withAlpha(50)
                      : Colors.grey[200],
                ),
                itemBuilder: (context, index) {
                  final entry = cb.entries[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            entry.date,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.voucherNo.isNotEmpty
                                    ? entry.voucherNo
                                    : '-',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (entry.voucherTypeCode.isNotEmpty)
                                Text(
                                  entry.voucherTypeCode,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            entry.particulars.isNotEmpty
                                ? entry.particulars
                                : (entry.ledgerName.isNotEmpty
                                      ? entry.ledgerName
                                      : '-'),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            entry.referenceNo.isNotEmpty
                                ? entry.referenceNo
                                : '-',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            entry.debit > 0
                                ? '₹${entry.debit.toStringAsFixed(2)}'
                                : '-',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 12,
                              color: entry.debit > 0 ? AppColors.success : null,
                              fontWeight: entry.debit > 0
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            entry.credit > 0
                                ? '₹${entry.credit.toStringAsFixed(2)}'
                                : '-',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 12,
                              color: entry.credit > 0 ? AppColors.danger : null,
                              fontWeight: entry.credit > 0
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '₹${entry.balance.toStringAsFixed(2)} ${entry.balanceType == "CREDIT" ? "Cr" : "Dr"}',
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

            // 3. Footer Totals Row
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
                    flex: 9,
                    child: Text(
                      'CLOSING BALANCE TOTALS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '₹${cb.totals.totalReceipts.toStringAsFixed(2)}',
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
                      '₹${cb.totals.totalPayments.toStringAsFixed(2)}',
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
                      '₹${cb.totals.closingBalance.toStringAsFixed(2)} ${cb.totals.closingBalanceType == "CREDIT" ? "Cr" : "Dr"}',
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

  Widget _buildMobileCashBookList(BookReport cb, bool isDark) {
    return Column(
      children: [
        if (cb.entries.isEmpty)
          const AppCard(
            padding: EdgeInsets.all(24),
            child: Center(
              child: Text(
                'No cash transactions recorded for period.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cb.entries.length,
            separatorBuilder: (_, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final entry = cb.entries[index];
              final isRec = entry.debit > 0;
              final amt = isRec ? entry.debit : entry.credit;

              return AppCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.date,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                (isRec ? AppColors.success : AppColors.danger)
                                    .withAlpha(25),
                            borderRadius: AppRadius.sm,
                          ),
                          child: Text(
                            isRec ? 'RECEIPT' : 'PAYMENT',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isRec
                                  ? AppColors.success
                                  : AppColors.danger,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      entry.particulars.isNotEmpty
                          ? entry.particulars
                          : (entry.ledgerName.isNotEmpty
                                ? entry.ledgerName
                                : 'Cash Entry'),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (entry.voucherNo.isNotEmpty)
                      Text(
                        'Voucher #${entry.voucherNo}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    const Divider(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₹${amt.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isRec ? AppColors.success : AppColors.danger,
                            fontFamily: 'monospace',
                          ),
                        ),
                        Text(
                          'Bal: ₹${entry.balance.toStringAsFixed(2)} ${entry.balanceType == "CREDIT" ? "Cr" : "Dr"}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
