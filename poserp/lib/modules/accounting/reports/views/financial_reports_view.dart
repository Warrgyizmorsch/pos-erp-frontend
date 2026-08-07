import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/financial_reports_controller.dart';

class FinancialReportsView extends GetView<FinancialReportsController> {
  const FinancialReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(25),
                          borderRadius: AppRadius.lg,
                        ),
                        child: const Icon(
                          Icons.assessment_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Financial & Tax Reports',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Trial Balance, Profit & Loss Statement, Balance Sheet, and GST reconciliation.',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  AppButton(
                    text: 'Refresh',
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    onPressed: () => controller.loadCurrentTabReport(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Filter Controls Bar
              AppCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 160,
                      child: TextField(
                        onChanged: (val) => controller.startDate.value = val,
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Start (YYYY-MM-DD)',
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
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 160,
                      child: TextField(
                        onChanged: (val) => controller.endDate.value = val,
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'End (YYYY-MM-DD)',
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
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Report Tabs Navigation
              Obx(
                () => Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.inputDark : Colors.grey[200],
                    borderRadius: AppRadius.lg,
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      _buildTabButton('Trial Balance', 0),
                      _buildTabButton('Profit & Loss', 1),
                      _buildTabButton('Balance Sheet', 2),
                      _buildTabButton('GST Summary', 3),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Tab Content Area
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const LoadingIndicator();
                  }

                  switch (controller.selectedTabIndex.value) {
                    case 0:
                      return _buildTrialBalanceTab(isDark);
                    case 1:
                      return _buildProfitLossTab(isDark);
                    case 2:
                      return _buildBalanceSheetTab(isDark);
                    case 3:
                      return _buildGstTab(isDark);
                    default:
                      return const SizedBox.shrink();
                  }
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    final isSelected = controller.selectedTabIndex.value == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.selectedTabIndex.value = index,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: AppRadius.md,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  // Tab 0: Trial Balance
  Widget _buildTrialBalanceTab(bool isDark) {
    final tb = controller.trialBalance.value;
    if (tb == null || tb.rows.isEmpty) {
      return const EmptyState(
        icon: Icons.scale_rounded,
        title: 'No Trial Balance Data',
        description: 'Post journal vouchers to generate trial balance audit.',
      );
    }

    return AppCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: AppRadius.lg,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: DataTable(
                  columnSpacing: 24,
                  headingRowColor: WidgetStateProperty.all(
                    isDark ? AppColors.inputDark : Colors.grey[100],
                  ),
                  columns: const [
                    DataColumn(
                      label: Text(
                        'CODE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'ACCOUNT / LEDGER NAME',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'GROUP',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    DataColumn(
                      numeric: true,
                      label: Text(
                        'DEBIT (₹)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    DataColumn(
                      numeric: true,
                      label: Text(
                        'CREDIT (₹)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                  rows: tb.rows.map((r) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            r.accountCode,
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            r.accountName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            r.groupName,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        DataCell(
                          Text(
                            r.debit > 0
                                ? '₹${r.debit.toStringAsFixed(2)}'
                                : '-',
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            r.credit > 0
                                ? '₹${r.credit.toStringAsFixed(2)}'
                                : '-',
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(14),
              color: isDark ? AppColors.inputDark : Colors.grey[100],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Debit: ₹${tb.totalDebit.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontFamily: 'monospace',
                    ),
                  ),
                  Text(
                    'Total Credit: ₹${tb.totalCredit.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.info,
                      fontFamily: 'monospace',
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: tb.isBalanced
                          ? AppColors.success.withAlpha(20)
                          : AppColors.danger.withAlpha(20),
                      borderRadius: AppRadius.full,
                    ),
                    child: Text(
                      tb.isBalanced ? 'BALANCED' : 'UNBALANCED',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: tb.isBalanced
                            ? AppColors.success
                            : AppColors.danger,
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

  // Tab 1: Profit & Loss
  Widget _buildProfitLossTab(bool isDark) {
    final pl = controller.profitLoss.value;
    if (pl == null) {
      return const EmptyState(
        icon: Icons.trending_up_rounded,
        title: 'No Profit & Loss Statement Data',
        description: 'Generate sales, purchases, or expense postings.',
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Income Column
              Expanded(
                child: AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'REVENUE & INCOME',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                      const Divider(height: 20),
                      ...pl.incomeRows.map((r) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                r.name,
                                style: const TextStyle(fontSize: 13),
                              ),
                              Text(
                                '₹${r.amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Income',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '₹${pl.totalIncome.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Expenses Column
              Expanded(
                child: AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'OPERATING EXPENSES',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.danger,
                        ),
                      ),
                      const Divider(height: 20),
                      ...pl.expenseRows.map((r) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                r.name,
                                style: const TextStyle(fontSize: 13),
                              ),
                              Text(
                                '₹${r.amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Expenses',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '₹${pl.totalExpense.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.danger,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Net Profit Card
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'NET PROFIT / LOSS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pl.netProfit >= 0 ? 'NET PROFIT' : 'NET LOSS',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: pl.netProfit >= 0
                            ? AppColors.success
                            : AppColors.danger,
                      ),
                    ),
                  ],
                ),
                Text(
                  '₹${pl.netProfit.abs().toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    color: pl.netProfit >= 0
                        ? AppColors.success
                        : AppColors.danger,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Tab 2: Balance Sheet
  Widget _buildBalanceSheetTab(bool isDark) {
    final bs = controller.balanceSheet.value;
    if (bs == null) {
      return const EmptyState(
        icon: Icons.account_balance_rounded,
        title: 'No Balance Sheet Data',
        description:
            'Initialize accounting ledgers to view asset/liability state.',
      );
    }

    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Assets
          Expanded(
            child: AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ASSETS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.info,
                    ),
                  ),
                  const Divider(height: 20),
                  ...bs.assetRows.map((r) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(r.name, style: const TextStyle(fontSize: 13)),
                          Text(
                            '₹${r.amount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Assets',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '₹${bs.totalAssets.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.info,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Liabilities & Equity
          Expanded(
            child: AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'LIABILITIES & EQUITY',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.warning,
                    ),
                  ),
                  const Divider(height: 20),
                  ...bs.liabilityRows.map((r) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(r.name, style: const TextStyle(fontSize: 13)),
                          Text(
                            '₹${r.amount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  ...bs.equityRows.map((r) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(r.name, style: const TextStyle(fontSize: 13)),
                          Text(
                            '₹${r.amount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Liabilities & Equity',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '₹${(bs.totalLiabilities + bs.totalEquity).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.warning,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tab 3: GST Summary
  Widget _buildGstTab(bool isDark) {
    final gst = controller.gstSummary.value;
    if (gst == null) {
      return const EmptyState(
        icon: Icons.pie_chart_rounded,
        title: 'No GST Summary Data',
        description:
            'Post taxable invoices or purchase bills to compute GST liability.',
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            children: [
              // Output Tax
              Expanded(
                child: AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'OUTPUT TAX (LIABILITY)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.danger,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '₹${gst.totalOutputTax.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.danger,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'CGST: ₹${gst.outputCgst.toStringAsFixed(2)} · SGST: ₹${gst.outputSgst.toStringAsFixed(2)} · IGST: ₹${gst.outputIgst.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Input Tax Credit
              Expanded(
                child: AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'INPUT TAX CREDIT (ITC)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '₹${gst.totalInputTax.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'CGST: ₹${gst.inputCgst.toStringAsFixed(2)} · SGST: ₹${gst.inputSgst.toStringAsFixed(2)} · IGST: ₹${gst.inputIgst.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Net GST Payable
              Expanded(
                child: AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'NET GST PAYABLE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '₹${gst.netTaxPayable.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Output Tax minus Input Tax Credit',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
