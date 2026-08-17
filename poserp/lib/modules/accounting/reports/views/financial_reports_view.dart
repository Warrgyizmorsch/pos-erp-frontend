import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/financial_reports_controller.dart';

class FinancialReportsView extends GetView<FinancialReportsController> {
  const FinancialReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Toolbar
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;

                  final headerTitle = Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(25),
                          borderRadius: AppRadius.lg,
                        ),
                        child: const Icon(
                          Icons.bar_chart_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Financial Reports Hub',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Access trial balance, balance sheets, P&L statements, books, and party aging reports.',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );

                  final refreshBtn = AppButton(
                    text: 'Refresh',
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    onPressed: () => controller.loadDashboardMetrics(),
                  );

                  if (isMobile) {
                    return Column(
                      children: [
                        headerTitle,
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: refreshBtn,
                        ),
                      ],
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: headerTitle),
                      refreshBtn,
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),

              // 2. Top Metric Summary Cards (4 Cards Grid)
              Obx(() {
                if (controller.isLoading.value) {
                  return const LoadingIndicator();
                }

                final metrics = controller.dashboardMetrics.value;
                final inc = metrics?.totalIncome ?? 0.0;
                final exp = metrics?.totalExpenses ?? 0.0;
                final rec = metrics?.receivables ?? 0.0;
                final pay = metrics?.payables ?? 0.0;

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final cols = constraints.maxWidth < 600
                        ? 2
                        : (constraints.maxWidth < 900 ? 2 : 4);

                    return GridView.count(
                      crossAxisCount: cols,
                      childAspectRatio: cols == 4 ? 2.2 : 1.6,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildMetricCard(
                          'Income',
                          '₹${inc.toStringAsFixed(2)}',
                          Icons.arrow_upward_rounded,
                          AppColors.success,
                          isDark,
                        ),
                        _buildMetricCard(
                          'Expenses',
                          '₹${exp.toStringAsFixed(2)}',
                          Icons.arrow_downward_rounded,
                          AppColors.danger,
                          isDark,
                        ),
                        _buildMetricCard(
                          'Receivables',
                          '₹${rec.toStringAsFixed(2)}',
                          Icons.account_balance_wallet_outlined,
                          AppColors.info,
                          isDark,
                        ),
                        _buildMetricCard(
                          'Payables',
                          '₹${pay.toStringAsFixed(2)}',
                          Icons.money_off_rounded,
                          AppColors.warning,
                          isDark,
                        ),
                      ],
                    );
                  },
                );
              }),
              const SizedBox(height: 24),

              // Section Title
              const Text(
                'Financial Statements & Book Registers',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Click any report module below to open its dedicated view.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // 3. Grid of 9 Interactive Report Cards
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth < 600
                      ? 1
                      : (constraints.maxWidth < 950 ? 2 : 3);

                  final items = [
                    _ReportItem(
                      title: 'Trial Balance',
                      description:
                          'Validation-level double-entry debit vs credit balance summary by ledger.',
                      icon: Icons.scale_rounded,
                      color: AppColors.primary,
                      badge: 'Validation',
                      route: Routes.trialBalance,
                    ),
                    _ReportItem(
                      title: 'Profit & Loss',
                      description:
                          'Net profit, revenue, expense breakdown, and operating income statement.',
                      icon: Icons.trending_up_rounded,
                      color: AppColors.success,
                      badge: 'Statement',
                      route: Routes.profitLossReport,
                    ),
                    _ReportItem(
                      title: 'Balance Sheet',
                      description:
                          'Assets vs liabilities, equity distribution, and financial position status.',
                      icon: Icons.account_balance_rounded,
                      color: AppColors.info,
                      badge: 'Statement',
                      route: Routes.balanceSheetReport,
                    ),
                    _ReportItem(
                      title: 'Cash Book',
                      description:
                          'Daily cash transactions register, opening/closing cash balances.',
                      icon: Icons.book_rounded,
                      color: Colors.amber,
                      badge: 'Register',
                      route: Routes.cashBookReport,
                    ),
                    _ReportItem(
                      title: 'Bank Book',
                      description:
                          'Bank account transaction history, deposits, withdrawals, and bank ledgers.',
                      icon: Icons.account_balance_wallet_rounded,
                      color: Colors.teal,
                      badge: 'Register',
                      route: Routes.bankBookReport,
                    ),
                    _ReportItem(
                      title: 'Receivables Aging',
                      description:
                          'Customer outstanding balances, unpaid invoices, and receivables aging.',
                      icon: Icons.people_alt_rounded,
                      color: Colors.indigo,
                      badge: 'Aging',
                      route: Routes.receivablesReport,
                    ),
                    _ReportItem(
                      title: 'Payables Aging',
                      description:
                          'Supplier outstanding balances, unpaid bills, and payables aging.',
                      icon: Icons.receipt_long_rounded,
                      color: Colors.deepOrange,
                      badge: 'Aging',
                      route: Routes.payablesReport,
                    ),
                    _ReportItem(
                      title: 'Ledger Summary',
                      description:
                          'Individual ledger account statements, debit/credit entries, and balances.',
                      icon: Icons.format_list_bulleted_rounded,
                      color: Colors.purple,
                      badge: 'Master',
                      route: Routes.ledgerSummaryReport,
                    ),
                    _ReportItem(
                      title: 'Group Summary',
                      description:
                          'Hierarchical account group balances, nature distribution, and COA structure.',
                      icon: Icons.account_tree_rounded,
                      color: Colors.blueGrey,
                      badge: 'Hierarchy',
                      route: Routes.groupSummaryReport,
                    ),
                  ];

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: crossAxisCount == 1
                          ? 2.1
                          : (crossAxisCount == 2 ? 1.8 : 1.7),
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    itemCount: items.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _buildReportNavigationCard(context, item, isDark);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String amount,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return AppCard(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: AppRadius.sm,
                ),
                child: Icon(icon, color: color, size: 14),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              amount,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportNavigationCard(
    BuildContext context,
    _ReportItem item,
    bool isDark,
  ) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () => Get.toNamed(item.route),
        borderRadius: AppRadius.lg,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: item.color.withAlpha(25),
                      borderRadius: AppRadius.md,
                    ),
                    child: Icon(item.icon, color: item.color, size: 20),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: item.color.withAlpha(20),
                      borderRadius: AppRadius.full,
                      border: Border.all(color: item.color.withAlpha(50)),
                    ),
                    child: Text(
                      item.badge,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: item.color,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String badge;
  final String route;

  _ReportItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.badge,
    required this.route,
  });
}
