import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/financial_reports_controller.dart';

class GstReportCardMeta {
  final String kind;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String route;

  const GstReportCardMeta({
    required this.kind,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
  });
}

const List<GstReportCardMeta> gstReportCards = [
  GstReportCardMeta(
    kind: 'summary',
    title: 'GST Summary',
    description: 'Output GST, input GST, returns, and net payable.',
    icon: Icons.pie_chart_rounded,
    color: AppColors.primary,
    route: Routes.gstSummary,
  ),
  GstReportCardMeta(
    kind: 'output',
    title: 'Output GST',
    description: 'GST collected on sales invoices.',
    icon: Icons.arrow_upward_rounded,
    color: AppColors.danger,
    route: Routes.gstOutput,
  ),
  GstReportCardMeta(
    kind: 'input',
    title: 'Input GST (ITC)',
    description: 'GST paid on purchase bills and available ITC.',
    icon: Icons.arrow_downward_rounded,
    color: AppColors.info,
    route: Routes.gstInput,
  ),
  GstReportCardMeta(
    kind: 'payable',
    title: 'GST Payable / ITC',
    description: 'GST liability and excess ITC by tax head.',
    icon: Icons.account_balance_rounded,
    color: AppColors.warning,
    route: Routes.gstPayable,
  ),
  GstReportCardMeta(
    kind: 'hsn-summary',
    title: 'HSN Summary',
    description: 'HSN-wise quantity, taxable value, and tax breakdown.',
    icon: Icons.format_list_bulleted_rounded,
    color: Colors.teal,
    route: Routes.gstHsnSummary,
  ),
  GstReportCardMeta(
    kind: 'gstr1',
    title: 'GSTR-1 Style',
    description: 'Internal sales breakup for B2B, B2C, credit notes, and HSN.',
    icon: Icons.menu_book_rounded,
    color: Colors.indigo,
    route: Routes.gstR1,
  ),
  GstReportCardMeta(
    kind: 'gstr3b',
    title: 'GSTR-3B Summary',
    description: 'Internal monthly GST summary for review.',
    icon: Icons.book_rounded,
    color: Colors.purple,
    route: Routes.gstR3b,
  ),
  GstReportCardMeta(
    kind: 'ledger',
    title: 'GST Ledger',
    description: 'Voucher entry movement for GST ledgers.',
    icon: Icons.receipt_long_rounded,
    color: Colors.deepOrange,
    route: Routes.gstLedger,
  ),
  GstReportCardMeta(
    kind: 'party-wise',
    title: 'GST Party-wise',
    description: 'GST grouped by customers and suppliers.',
    icon: Icons.groups_rounded,
    color: Colors.blueGrey,
    route: Routes.gstPartyWise,
  ),
  GstReportCardMeta(
    kind: 'exceptions',
    title: 'GST Exceptions',
    description: 'Missing HSN, GSTIN, state, and tax mismatch issues.',
    icon: Icons.warning_amber_rounded,
    color: Colors.redAccent,
    route: Routes.gstExceptions,
  ),
];

class GstReportsIndexView extends GetView<FinancialReportsController> {
  const GstReportsIndexView({super.key});

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
              // 1. Page Header & Actions
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
                          Icons.currency_rupee_rounded,
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
                              'GST Reports',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'GST summaries, GSTR-style internal reports, HSN, ledger, and exceptions.',
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
                    onPressed: () {
                      controller.loadGstSummary();
                      controller.loadGstReport();
                    },
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

              // 2. Top 4 Control Summary Cards Grid
              Obx(() {
                if (controller.isLoading.value &&
                    controller.gstSummary.value == null) {
                  return const LoadingIndicator();
                }

                final gst = controller.gstSummary.value;
                final rawExceptions = controller.gstReportData.value;
                int exceptionCount = 0;

                if (rawExceptions is Map<String, dynamic> &&
                    rawExceptions['rows'] is List) {
                  exceptionCount = (rawExceptions['rows'] as List).length;
                }

                final outTax = gst?.totalOutputTax ?? 0.0;
                final inTax = gst?.totalInputTax ?? 0.0;
                final netPayable = gst?.netTaxPayable ?? 0.0;

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
                          'Output GST',
                          '₹${outTax.toStringAsFixed(2)}',
                          Icons.arrow_upward_rounded,
                          AppColors.danger,
                          isDark,
                        ),
                        _buildMetricCard(
                          'Input GST',
                          '₹${inTax.toStringAsFixed(2)}',
                          Icons.arrow_downward_rounded,
                          AppColors.info,
                          isDark,
                        ),
                        _buildMetricCard(
                          'Net Payable',
                          '₹${netPayable.toStringAsFixed(2)}',
                          Icons.account_balance_rounded,
                          AppColors.warning,
                          isDark,
                        ),
                        _buildMetricCard(
                          'Exceptions',
                          '$exceptionCount Issues',
                          Icons.warning_amber_rounded,
                          AppColors.danger,
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
                'GST & Tax Report Modules',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Select any report module below to open its dedicated view.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // 3. Grid of 10 GST Report Module Cards
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth < 600
                      ? 1
                      : (constraints.maxWidth < 950 ? 2 : 3);

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: crossAxisCount == 1
                          ? 2.1
                          : (crossAxisCount == 2 ? 1.8 : 1.7),
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    itemCount: gstReportCards.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final item = gstReportCards[index];
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
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportNavigationCard(
    BuildContext context,
    GstReportCardMeta item,
    bool isDark,
  ) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () {
          controller.selectedGstKind.value = item.kind;
          Get.toNamed(item.route);
        },
        borderRadius: AppRadius.lg,
        child: Padding(
          padding: const EdgeInsets.all(14),
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
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
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
