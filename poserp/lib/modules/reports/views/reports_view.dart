import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_stat_card.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/reports_controller.dart';

class ReportsView extends GetView<ReportsController> {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppTopBar(
        title: 'Business Intelligence & Reports',
        subtitle: 'Sales performance, inventory valuation & cashflow',
        actions: [
          IconButton(
            icon: const Icon(Icons.file_present_rounded, size: 22),
            tooltip: 'Export CSV',
            onPressed: () => controller.exportReport('csv'),
          ),
          IconButton(
            icon: const Icon(Icons.grid_on_rounded, size: 22),
            tooltip: 'Export Excel',
            onPressed: () => controller.exportReport('excel'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.loadReport(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter Toolbar (Horizontal Scrolling Tabs + Period Picker)
              AppCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Obx(
                        () => Row(
                          children: [
                            _buildReportTab(
                              'sales',
                              'Sales BI',
                              Icons.point_of_sale_rounded,
                            ),
                            const SizedBox(width: 8),
                            _buildReportTab(
                              'inventory',
                              'Inventory',
                              Icons.inventory_2_outlined,
                            ),
                            const SizedBox(width: 8),
                            _buildReportTab(
                              'purchases',
                              'Purchase BI',
                              Icons.shopping_bag_outlined,
                            ),
                            const SizedBox(width: 8),
                            _buildReportTab(
                              'cashflow',
                              'Cashflow',
                              Icons.account_balance_outlined,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Reporting Period:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        Obx(
                          () => DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: controller.period.value,
                              items: const [
                                DropdownMenuItem(
                                  value: 'daily',
                                  child: Text(
                                    'Daily',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'weekly',
                                  child: Text(
                                    'Weekly',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'monthly',
                                  child: Text(
                                    'Monthly',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'yearly',
                                  child: Text(
                                    'Yearly',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                              onChanged: (val) {
                                if (val != null) controller.period.value = val;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Report Content
              Obx(() {
                if (controller.isLoading.value &&
                    controller.reportData.value == null) {
                  return const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: LoadingIndicator(
                      message: 'Generating analytics report...',
                    ),
                  );
                }

                if (controller.reportData.value == null) {
                  return const Center(child: Text('No report data available'));
                }

                final rep = controller.reportData.value!;
                final revStr = '₹${rep.totalRevenue.toStringAsFixed(2)}';
                final expStr = '₹${rep.totalExpenses.toStringAsFixed(2)}';
                final prfStr = '₹${rep.netProfit.toStringAsFixed(2)}';
                final aovStr = '₹${rep.averageOrderValue.toStringAsFixed(2)}';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stat Cards Grid (Mobile Horizontal Scroll / Desktop Row)
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isMobile = constraints.maxWidth < 600;

                        if (isMobile) {
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 150,
                                  child: AppStatCard(
                                    title: 'Total Revenue',
                                    value: revStr,
                                    icon: Icons.trending_up_rounded,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                SizedBox(
                                  width: 150,
                                  child: AppStatCard(
                                    title: 'Total Cost',
                                    value: expStr,
                                    icon: Icons.money_off_rounded,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                SizedBox(
                                  width: 150,
                                  child: AppStatCard(
                                    title: 'Net Profit',
                                    value: prfStr,
                                    icon: Icons.account_balance_wallet_rounded,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                SizedBox(
                                  width: 150,
                                  child: AppStatCard(
                                    title: 'Avg Order Value',
                                    value: aovStr,
                                    icon: Icons.shopping_basket_rounded,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return Row(
                          children: [
                            Expanded(
                              child: AppStatCard(
                                title: 'Total Revenue',
                                value: revStr,
                                icon: Icons.trending_up_rounded,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: AppStatCard(
                                title: 'Total Cost',
                                value: expStr,
                                icon: Icons.money_off_rounded,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: AppStatCard(
                                title: 'Net Profit',
                                value: prfStr,
                                icon: Icons.account_balance_wallet_rounded,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: AppStatCard(
                                title: 'Avg Order Value',
                                value: aovStr,
                                icon: Icons.shopping_basket_rounded,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Top Performing Items & Detailed Breakdown Table
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isMobile = constraints.maxWidth < 800;

                        final topItemsCard = AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Top Performing Items',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...rep.topProducts.map((p) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              p['name'].toString(),
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              '${p['quantity']} units sold',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '₹${p['sales']}',
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
                            ],
                          ),
                        );

                        final breakdownCard = AppCard(
                          padding: EdgeInsets.zero,
                          child: ClipRRect(
                            borderRadius: AppRadius.lg,
                            child: SingleChildScrollView(
                              child: DataTable(
                                columnSpacing: 16,
                                headingRowColor: WidgetStateProperty.all(
                                  isDark
                                      ? AppColors.inputDark
                                      : Colors.grey[100],
                                ),
                                columns: const [
                                  DataColumn(
                                    label: Text(
                                      'PERIOD',
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
                                      'ORDERS',
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
                                      'REVENUE',
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
                                      'PROFIT',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                                rows: rep.reportRows.map((r) {
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Text(
                                          r['date'].toString(),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          r['orders'].toString(),
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          '₹${r['revenue']}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          '₹${r['profit']}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.success,
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
                        );

                        if (isMobile) {
                          return Column(
                            children: [
                              topItemsCard,
                              const SizedBox(height: 16),
                              breakdownCard,
                            ],
                          );
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 1, child: topItemsCard),
                            const SizedBox(width: 16),
                            Expanded(flex: 2, child: breakdownCard),
                          ],
                        );
                      },
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportTab(String key, String title, IconData icon) {
    final isSelected = controller.reportType.value == key;
    return InkWell(
      onTap: () => controller.reportType.value = key,
      borderRadius: AppRadius.md,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withAlpha(25)
              : Colors.transparent,
          borderRadius: AppRadius.md,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.primary : Colors.grey,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primary : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
