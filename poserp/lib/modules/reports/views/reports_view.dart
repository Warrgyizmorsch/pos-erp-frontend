import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
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
    final horizontalScrollController = ScrollController();

    return Scaffold(
      appBar: AppTopBar(
        title: 'Analytics & Reports',
        subtitle: 'Enterprise-level business intelligence dashboard',
        actions: [
          IconButton(
            icon: const Icon(Icons.file_present_rounded, size: 20),
            tooltip: 'Export CSV',
            onPressed: () => controller.exportReport('csv'),
          ),
          IconButton(
            icon: const Icon(Icons.grid_on_rounded, size: 20),
            tooltip: 'Export Excel',
            onPressed: () => controller.exportReport('excel'),
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined, size: 20),
            tooltip: 'Export PDF',
            onPressed: () => controller.exportReport('pdf'),
          ),
          IconButton(
            icon: const Icon(Icons.print_outlined, size: 20),
            tooltip: 'Print Report',
            onPressed: () => controller.printReport(),
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
              // 1. Filter Toolbar (Tabs + Period Selector + Date Range Picker)
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
                              'Sales Analytics',
                              Icons.point_of_sale_rounded,
                            ),
                            const SizedBox(width: 8),
                            _buildReportTab(
                              'inventory',
                              'Inventory Analytics',
                              Icons.inventory_2_outlined,
                            ),
                            const SizedBox(width: 8),
                            _buildReportTab(
                              'purchases',
                              'Purchase Analytics',
                              Icons.shopping_bag_outlined,
                            ),
                            const SizedBox(width: 8),
                            _buildReportTab(
                              'cashflow',
                              'Cashflow Analytics',
                              Icons.account_balance_outlined,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Reporting Period: ',
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
                                    DropdownMenuItem(
                                      value: 'custom',
                                      child: Text(
                                        'Custom Range',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) {
                                      controller.period.value = val;
                                      if (val == 'custom') {
                                        _selectDateRange(context);
                                      }
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Custom Date Range Picker Button
                        Obx(() {
                          final range = controller.customDateRange.value;
                          final text = range != null
                              ? '${range.start.toString().split(" ")[0]} to ${range.end.toString().split(" ")[0]}'
                              : 'Select Date Range';

                          return AppButton(
                            text: text,
                            variant: AppButtonVariant.outline,
                            icon: const Icon(
                              Icons.calendar_today_rounded,
                              size: 14,
                            ),
                            onPressed: () => _selectDateRange(context),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. Main Analytics Content
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

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ROW 1 SUMMARY CARDS (Total Sales, Total Revenue, Gross Profit, Net Profit)
                    const Text(
                      'FINANCIAL SUMMARY CARDS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildMetricsGrid([
                      AppStatCard(
                        title: 'Total Sales',
                        value: '₹${rep.totalSales.toStringAsFixed(2)}',
                        icon: Icons.shopping_cart_outlined,
                        color: AppColors.primary,
                      ),
                      AppStatCard(
                        title: 'Total Revenue',
                        value: '₹${rep.totalRevenue.toStringAsFixed(2)}',
                        icon: Icons.attach_money_rounded,
                        color: AppColors.success,
                      ),
                      AppStatCard(
                        title: 'Gross Profit',
                        value: '₹${rep.grossProfit.toStringAsFixed(2)}',
                        icon: Icons.trending_up_rounded,
                        color: AppColors.info,
                      ),
                      AppStatCard(
                        title: 'Net Profit',
                        value: '₹${rep.netProfit.toStringAsFixed(2)}',
                        icon: Icons.bar_chart_rounded,
                        color: AppColors.primary,
                      ),
                    ]),
                    const SizedBox(height: 16),

                    // ROW 2 SECONDARY METRIC CARDS (Avg Order Value, Total Discount, Total Tax, Purchase Cost)
                    const Text(
                      'BREAKDOWN & TRANSACTION CARDS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildMetricsGrid([
                      AppStatCard(
                        title: 'Avg Order Value',
                        value: '₹${rep.averageOrderValue.toStringAsFixed(2)}',
                        icon: Icons.shopping_bag_outlined,
                        color: Colors.cyan,
                      ),
                      AppStatCard(
                        title: 'Total Discount',
                        value: '₹${rep.totalDiscounts.toStringAsFixed(2)}',
                        icon: Icons.card_giftcard_rounded,
                        color: Colors.amber[700]!,
                      ),
                      AppStatCard(
                        title: 'Total Tax',
                        value: '₹${rep.totalTax.toStringAsFixed(2)}',
                        icon: Icons.percent_rounded,
                        color: AppColors.danger,
                      ),
                      AppStatCard(
                        title: 'Purchase Cost',
                        value: '₹${rep.purchaseCost.toStringAsFixed(2)}',
                        icon: Icons.shopping_basket_outlined,
                        color: AppColors.primary,
                      ),
                    ]),
                    const SizedBox(height: 16),

                    // ROW 3 ADDITIONAL METRICS CARDS (Profit Margin %, Total Expenses, Gross Margin %, Total Orders)
                    const Text(
                      'KEY PERFORMANCE METRICS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildMetricsGrid([
                      AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Net Profit Margin',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${rep.profitMargin.toStringAsFixed(2)}%',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Expenses',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${rep.totalExpenses.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Gross Profit %',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${rep.grossProfitMargin.toStringAsFixed(2)}%',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.info,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Orders',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${rep.totalOrders}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]),
                    const SizedBox(height: 20),

                    // ROW 4 TOP PERFORMING ITEMS & DETAILED BREAKDOWN TABLE
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
                            child: Scrollbar(
                              controller: horizontalScrollController,
                              thumbVisibility: true,
                              trackVisibility: true,
                              child: SingleChildScrollView(
                                controller: horizontalScrollController,
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columnSpacing: 24,
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
                                        'TAX',
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
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
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
                                            '₹${r['tax'] ?? 0.0}',
                                            style: const TextStyle(
                                              fontSize: 12,
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

  // Responsive Metrics Cards Grid Builder
  Widget _buildMetricsGrid(List<Widget> cards) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        if (isMobile) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: cards.map((c) {
                return Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: SizedBox(width: 160, child: c),
                );
              }).toList(),
            ),
          );
        }

        return Row(
          children: cards.map((c) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: c,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange:
          controller.customDateRange.value ??
          DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 30)),
            end: DateTime.now(),
          ),
    );
    if (picked != null) {
      controller.setDateRange(picked);
    }
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
