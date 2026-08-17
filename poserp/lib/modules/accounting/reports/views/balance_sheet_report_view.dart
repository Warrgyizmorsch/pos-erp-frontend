import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/financial_reports_controller.dart';

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
                final diff = (bs.totalAssets - bs.totalLiabilities).abs();

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Balance Status Card
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
                                  Text(
                                    isBal
                                        ? 'BALANCE SHEET STATUS: BALANCED'
                                        : 'DIFFERENCE IN BALANCES',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isBal
                                          ? AppColors.success
                                          : AppColors.warning,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isBal
                                        ? 'Assets = Liabilities + Equity (₹${bs.totalAssets.toStringAsFixed(2)})'
                                        : 'Unmatched Difference: ₹${diff.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Assets vs Liabilities Cards Breakdown
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildBreakdownCard(
                              'ASSETS SUMMARY',
                              bs.assetAccounts,
                              bs.totalAssets,
                              AppColors.primary,
                              isDark,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildBreakdownCard(
                              'LIABILITIES & EQUITY SUMMARY',
                              bs.liabilityAccounts,
                              bs.totalLiabilities,
                              AppColors.info,
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
                'No recorded ledger balances',
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
