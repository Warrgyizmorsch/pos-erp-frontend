import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/financial_reports_controller.dart';

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

            // 2. Statement Content Body
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const LoadingIndicator();
                }

                final pl = controller.profitLoss.value;
                if (pl == null) {
                  return const EmptyState(
                    icon: Icons.trending_up_rounded,
                    title: 'No Statement Data Available',
                    description:
                        'Select a valid date range to compute revenue and operating expenses.',
                  );
                }

                final netVal = pl.netProfit - pl.netLoss;
                final isProf = netVal >= 0;

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Net Profit / Loss Banner Card
                      AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                    (isProf
                                            ? AppColors.success
                                            : AppColors.danger)
                                        .withAlpha(25),
                                borderRadius: AppRadius.lg,
                              ),
                              child: Icon(
                                isProf
                                    ? Icons.trending_up_rounded
                                    : Icons.trending_down_rounded,
                                color: isProf
                                    ? AppColors.success
                                    : AppColors.danger,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isProf
                                        ? 'NET OPERATING PROFIT'
                                        : 'NET OPERATING LOSS',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isProf
                                          ? AppColors.success
                                          : AppColors.danger,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '₹${netVal.abs().toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
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

                      // Income Accounts & Expense Accounts Cards Breakdown
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildBreakdownCard(
                              'Operating Income Accounts',
                              pl.incomeAccounts,
                              pl.totalIncome,
                              AppColors.success,
                              isDark,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildBreakdownCard(
                              'Operating Expense Accounts',
                              pl.expenseAccounts,
                              pl.totalExpenses,
                              AppColors.danger,
                              isDark,
                            ),
                          ),
                        ],
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

  Widget _buildBreakdownCard(
    String title,
    List dynamicAccounts,
    double total,
    Color themeColor,
    bool isDark,
  ) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
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
          const Divider(height: 20),
          if (dynamicAccounts.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No recorded accounts found',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dynamicAccounts.length,
              separatorBuilder: (_, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = dynamicAccounts[index];
                final name = item.name ?? item.ledgerName ?? 'Account';
                final bal = (item.balance ?? item.amount ?? 0.0) as num;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name.toString(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    Text(
                      '₹${bal.toDouble().toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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
