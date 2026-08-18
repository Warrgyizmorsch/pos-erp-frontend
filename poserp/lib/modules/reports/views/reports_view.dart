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
import '../models/analytics_report.dart';

class ReportsView extends GetView<ReportsController> {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
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

              // 2. Main Tab-Specific Analytics Content
              Obx(() {
                if (controller.isLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.all(48.0),
                    child: LoadingIndicator(
                      message: 'Fetching live analytics from API backend...',
                    ),
                  );
                }

                if (controller.errorMessage.value != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: AppCard(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.cloud_off_rounded,
                              size: 48,
                              color: AppColors.danger,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Unable to Connect to API Backend',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              controller.errorMessage.value!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 16),
                            AppButton(
                              text: 'Retry API Connection',
                              icon: const Icon(Icons.refresh_rounded, size: 16),
                              onPressed: () => controller.loadReport(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                if (controller.reportData.value == null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: AppCard(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.inbox_rounded,
                              size: 40,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'No Analytics Data Available',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'The backend API returned an empty response for this period.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                final rep = controller.reportData.value!;
                final activeTab = controller.reportType.value;

                if (activeTab == 'inventory') {
                  return _buildInventoryDashboard(context, rep);
                } else if (activeTab == 'purchases') {
                  return _buildPurchasesDashboard(context, rep);
                } else if (activeTab == 'cashflow') {
                  return _buildCashflowDashboard(context, rep);
                }
                return _buildSalesDashboard(context, rep);
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1. SALES ANALYTICS DASHBOARD (12 METRIC CARDS + TOP PRODUCTS + RECENT SALES)
  // ---------------------------------------------------------------------------
  Widget _buildSalesDashboard(BuildContext context, AnalyticsReport rep) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                  style: TextStyle(fontSize: 12, color: Colors.grey),
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
                  style: TextStyle(fontSize: 12, color: Colors.grey),
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
                  style: TextStyle(fontSize: 12, color: Colors.grey),
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
                  style: TextStyle(fontSize: 12, color: Colors.grey),
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

        _buildSalesTable(context, rep),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 2. INVENTORY ANALYTICS DASHBOARD (6 INVENTORY CARDS + LOW STOCK TABLE)
  // ---------------------------------------------------------------------------
  Widget _buildInventoryDashboard(BuildContext context, AnalyticsReport rep) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final horizontalScrollController = ScrollController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'INVENTORY VALUATION & STOCK STATUS',
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
            title: 'Total Products',
            value: '${rep.totalProducts}',
            icon: Icons.inventory_2_outlined,
            color: AppColors.primary,
          ),
          AppStatCard(
            title: 'Inventory Value',
            value: '₹${rep.inventoryValue.toStringAsFixed(2)}',
            icon: Icons.attach_money_rounded,
            color: AppColors.success,
          ),
          AppStatCard(
            title: 'Inventory Cost',
            value: '₹${rep.inventoryCost.toStringAsFixed(2)}',
            icon: Icons.money_off_rounded,
            color: Colors.blueGrey,
          ),
          AppStatCard(
            title: 'Potential Profit',
            value: '₹${rep.potentialProfit.toStringAsFixed(2)}',
            icon: Icons.trending_up_rounded,
            color: AppColors.info,
          ),
        ]),
        const SizedBox(height: 12),

        _buildMetricsGrid([
          AppStatCard(
            title: 'Low Stock Alert',
            value: '${rep.lowStockProducts} Items',
            icon: Icons.warning_amber_rounded,
            color: Colors.amber[800]!,
          ),
          AppStatCard(
            title: 'Out of Stock',
            value: '${rep.outOfStockProducts} Items',
            icon: Icons.error_outline_rounded,
            color: AppColors.danger,
          ),
        ]),
        const SizedBox(height: 20),

        // Low Stock Alert Table
        AppCard(
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
                    isDark ? AppColors.inputDark : Colors.grey[100],
                  ),
                  columns: const [
                    DataColumn(
                      label: Text(
                        'PRODUCT NAME',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'BARCODE / SKU',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'CATEGORY',
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
                        'STOCK',
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
                        'INVENTORY VALUE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'STATUS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                  rows:
                      (rep.reportRows.isNotEmpty
                              ? rep.reportRows
                              : rep.topProducts)
                          .map((p) {
                            final name =
                                (p['productName'] ?? p['name'] ?? 'Item')
                                    .toString();
                            final barcode =
                                (p['barcode'] ?? p['sku'] ?? 'ITEM-001')
                                    .toString();
                            final category = (p['category'] ?? 'General')
                                .toString();
                            final stock =
                                p['currentStock'] ??
                                p['stock'] ??
                                p['quantity'] ??
                                0;
                            final val =
                                (p['inventoryValue'] ??
                                        p['value'] ??
                                        p['sales'] ??
                                        0.0)
                                    as num;
                            final status =
                                (p['status'] ??
                                        (stock == 0
                                            ? 'Out of Stock'
                                            : stock <= 5
                                            ? 'Low Stock'
                                            : 'In Stock'))
                                    .toString();
                            final isOut =
                                status == 'Out of Stock' || stock == 0;
                            final isLow =
                                status == 'Low Stock' ||
                                (stock > 0 && stock <= 10);

                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    barcode,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    category,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    '$stock units',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    '₹${val.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          (isOut
                                                  ? Colors.red
                                                  : isLow
                                                  ? Colors.amber
                                                  : Colors.green)
                                              .withAlpha(30),
                                      borderRadius: AppRadius.sm,
                                    ),
                                    child: Text(
                                      status,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isOut
                                            ? Colors.red
                                            : isLow
                                            ? Colors.amber
                                            : Colors.green,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          })
                          .toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 3. PURCHASE ANALYTICS DASHBOARD (6 PURCHASE CARDS + SUPPLIER TABLE)
  // ---------------------------------------------------------------------------
  Widget _buildPurchasesDashboard(BuildContext context, AnalyticsReport rep) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final horizontalScrollController = ScrollController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PURCHASE & VENDOR PROCUREMENT CARDS',
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
            title: 'Total Purchases',
            value: '${rep.totalPurchases} Bills',
            icon: Icons.shopping_bag_outlined,
            color: AppColors.primary,
          ),
          AppStatCard(
            title: 'Purchase Amount',
            value: '₹${rep.totalPurchaseAmount.toStringAsFixed(2)}',
            icon: Icons.attach_money_rounded,
            color: AppColors.success,
          ),
          AppStatCard(
            title: 'Active Suppliers',
            value: '${rep.supplierCount}',
            icon: Icons.business_outlined,
            color: AppColors.info,
          ),
          AppStatCard(
            title: 'Avg Purchase Value',
            value: '₹${rep.averagePurchaseValue.toStringAsFixed(2)}',
            icon: Icons.trending_up_rounded,
            color: Colors.purple,
          ),
        ]),
        const SizedBox(height: 12),

        _buildMetricsGrid([
          AppStatCard(
            title: 'Pending Payments',
            value: '₹${rep.pendingPayments.toStringAsFixed(2)}',
            icon: Icons.access_time_rounded,
            color: Colors.amber[800]!,
          ),
          AppStatCard(
            title: 'Procurement Items',
            value: '${rep.totalProducts} Items',
            icon: Icons.inventory_2_outlined,
            color: Colors.cyan,
          ),
        ]),
        const SizedBox(height: 20),

        // Recent Purchase Transactions Table
        AppCard(
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
                    isDark ? AppColors.inputDark : Colors.grey[100],
                  ),
                  columns: const [
                    DataColumn(
                      label: Text(
                        'PURCHASE BILL #',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'SUPPLIER NAME',
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
                        'AMOUNT',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'STATUS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                  rows: rep.reportRows.isNotEmpty
                      ? rep.reportRows.map((r) {
                          final isPaid = (r['status'] ?? 'Paid') == 'Paid';
                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  (r['invoiceNumber'] ??
                                          r['billNumber'] ??
                                          'PUR-2026-001')
                                      .toString(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  (r['supplierName'] ??
                                          r['customerName'] ??
                                          'Anand Wholesale')
                                      .toString(),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '₹${r['totalAmount'] ?? r['revenue'] ?? 0.0}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        (isPaid ? Colors.green : Colors.amber)
                                            .withAlpha(30),
                                    borderRadius: AppRadius.sm,
                                  ),
                                  child: Text(
                                    isPaid ? 'Paid' : 'Pending',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isPaid
                                          ? Colors.green
                                          : Colors.amber,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList()
                      : [
                          const DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  'No purchase bills',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                              DataCell(Text('-')),
                              DataCell(Text('-')),
                              DataCell(Text('-')),
                            ],
                          ),
                        ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 4. CASHFLOW ANALYTICS DASHBOARD (4 CASHFLOW CARDS + MOVEMENT TABLE)
  // ---------------------------------------------------------------------------
  Widget _buildCashflowDashboard(BuildContext context, AnalyticsReport rep) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final horizontalScrollController = ScrollController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CASHFLOW & LIQUIDITY MOVEMENT CARDS',
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
            title: 'Total Cash In',
            value: '₹${rep.totalCashIn.toStringAsFixed(2)}',
            icon: Icons.arrow_downward_rounded,
            color: AppColors.success,
          ),
          AppStatCard(
            title: 'Total Cash Out',
            value: '₹${rep.totalCashOut.toStringAsFixed(2)}',
            icon: Icons.arrow_upward_rounded,
            color: AppColors.danger,
          ),
          AppStatCard(
            title: 'Net Cash Flow',
            value: '₹${rep.netCashFlow.toStringAsFixed(2)}',
            icon: Icons.swap_horiz_rounded,
            color: AppColors.primary,
          ),
          AppStatCard(
            title: 'Operating Profit',
            value: '₹${rep.netProfit.toStringAsFixed(2)}',
            icon: Icons.account_balance_wallet_rounded,
            color: AppColors.info,
          ),
        ]),
        const SizedBox(height: 20),

        // Cashflow Transactions Table
        AppCard(
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
                    isDark ? AppColors.inputDark : Colors.grey[100],
                  ),
                  columns: const [
                    DataColumn(
                      label: Text(
                        'DATE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'CATEGORY',
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
                        'CASH IN',
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
                        'CASH OUT',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                  rows: rep.reportRows.isNotEmpty
                      ? rep.reportRows.map((r) {
                          final cashIn =
                              (r['revenue'] ?? r['totalAmount'] ?? 0.0) as num;
                          final cashOut =
                              (r['expenses'] ?? r['discount'] ?? 0.0) as num;
                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  (r['date'] ?? '-').toString(),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              DataCell(
                                Text(
                                  (r['category'] ??
                                          r['customerName'] ??
                                          'Operating Receipts')
                                      .toString(),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '₹${cashIn.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '₹${cashOut.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: cashOut > 0
                                        ? Colors.red
                                        : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList()
                      : [
                          const DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  'No cashflow entries',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                              DataCell(Text('-')),
                              DataCell(Text('-')),
                              DataCell(Text('-')),
                            ],
                          ),
                        ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // HELPER: SALES TABLE
  // ---------------------------------------------------------------------------
  Widget _buildSalesTable(BuildContext context, AnalyticsReport rep) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final horizontalScrollController = ScrollController();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;

        final topItemsCard = AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Top Performing Items',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...rep.topProducts.map((p) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                    isDark ? AppColors.inputDark : Colors.grey[100],
                  ),
                  columns: const [
                    DataColumn(
                      label: Text(
                        'INVOICE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'CUSTOMER',
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
                        'PRODUCTS',
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
                        'AMOUNT',
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
                        'DISCOUNT',
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
                        'REVENUE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'DATE',
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
                            (r['invoiceNumber'] ?? 'INV-2026-001').toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            (r['customerName'] ?? 'Walk-in Customer')
                                .toString(),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        DataCell(
                          Text(
                            '${r['productsCount'] ?? 1} items',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        DataCell(
                          Text(
                            '₹${r['totalAmount'] ?? r['revenue'] ?? 0.0}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            '₹${r['discount'] ?? 0.0}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.amber,
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
                            '₹${r['revenue'] ?? 0.0}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            (r['date'] ?? '-').toString(),
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
          ),
        );

        if (isMobile) {
          return Column(
            children: [topItemsCard, const SizedBox(height: 16), breakdownCard],
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
