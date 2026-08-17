import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/financial_reports_controller.dart';
import '../models/gst_report_summary.dart';

class GstReportItemMeta {
  final String key;
  final String label;
  final String description;
  final IconData icon;
  final Color color;

  const GstReportItemMeta({
    required this.key,
    required this.label,
    required this.description,
    required this.icon,
    required this.color,
  });
}

const List<GstReportItemMeta> gstKindsList = [
  GstReportItemMeta(
    key: 'summary',
    label: 'GST Summary',
    description: 'Output GST, input GST, returns, and net payable.',
    icon: Icons.pie_chart_rounded,
    color: AppColors.primary,
  ),
  GstReportItemMeta(
    key: 'output',
    label: 'Output GST',
    description: 'GST collected on sales invoices.',
    icon: Icons.arrow_upward_rounded,
    color: AppColors.danger,
  ),
  GstReportItemMeta(
    key: 'input',
    label: 'Input GST (ITC)',
    description: 'GST paid on purchase bills and available ITC.',
    icon: Icons.arrow_downward_rounded,
    color: AppColors.info,
  ),
  GstReportItemMeta(
    key: 'payable',
    label: 'GST Payable / ITC',
    description: 'GST liability and excess ITC by tax head.',
    icon: Icons.account_balance_rounded,
    color: AppColors.warning,
  ),
  GstReportItemMeta(
    key: 'hsn-summary',
    label: 'HSN Summary',
    description: 'HSN-wise quantity, taxable value, and tax breakdown.',
    icon: Icons.format_list_bulleted_rounded,
    color: Colors.teal,
  ),
  GstReportItemMeta(
    key: 'gstr1',
    label: 'GSTR-1 Style',
    description: 'Internal sales breakup for B2B, B2C, credit notes, and HSN.',
    icon: Icons.menu_book_rounded,
    color: Colors.indigo,
  ),
  GstReportItemMeta(
    key: 'gstr3b',
    label: 'GSTR-3B Summary',
    description: 'Internal monthly GST summary for review.',
    icon: Icons.book_rounded,
    color: Colors.purple,
  ),
  GstReportItemMeta(
    key: 'ledger',
    label: 'GST Ledger',
    description: 'Voucher entry movement for GST ledgers.',
    icon: Icons.receipt_long_rounded,
    color: Colors.deepOrange,
  ),
  GstReportItemMeta(
    key: 'party-wise',
    label: 'GST Party-wise',
    description: 'GST grouped by customers and suppliers.',
    icon: Icons.groups_rounded,
    color: Colors.blueGrey,
  ),
  GstReportItemMeta(
    key: 'exceptions',
    label: 'GST Exceptions',
    description: 'Missing HSN, GSTIN, state, and tax mismatch issues.',
    icon: Icons.warning_amber_rounded,
    color: Colors.redAccent,
  ),
];

class GstReportSummaryView extends GetView<FinancialReportsController> {
  const GstReportSummaryView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('GST & Tax Reports Hub'),
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
            // 1. Interactive Header & Sub-Section Selector Toolbar
            AppCard(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Active Report Header Banner
                  Obx(() {
                    final currentKey = controller.selectedGstKind.value;
                    final activeMeta = gstKindsList.firstWhere(
                      (m) => m.key == currentKey,
                      orElse: () => gstKindsList.first,
                    );

                    return Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: activeMeta.color.withAlpha(25),
                            borderRadius: AppRadius.lg,
                          ),
                          child: Icon(
                            activeMeta.icon,
                            color: activeMeta.color,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activeMeta.label,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                activeMeta.description,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Dropdown Selector Button
                        PopupMenuButton<String>(
                          tooltip: 'Switch GST Report Type',
                          initialValue: currentKey,
                          onSelected: (key) =>
                              controller.selectedGstKind.value = key,
                          itemBuilder: (context) => gstKindsList.map((item) {
                            return PopupMenuItem<String>(
                              value: item.key,
                              child: Row(
                                children: [
                                  Icon(item.icon, size: 18, color: item.color),
                                  const SizedBox(width: 10),
                                  Text(item.label),
                                ],
                              ),
                            );
                          }).toList(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isDark
                                    ? AppColors.borderDark
                                    : AppColors.borderLight,
                              ),
                              borderRadius: AppRadius.md,
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.swap_horiz_rounded, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'Switch',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 14),

                  // Horizontal Scrollable GST Sub-Section Choice Chips
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: gstKindsList.length,
                      separatorBuilder: (_, index) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final item = gstKindsList[index];
                        return Obx(() {
                          final isSelected =
                              controller.selectedGstKind.value == item.key;
                          return ChoiceChip(
                            avatar: Icon(
                              item.icon,
                              size: 14,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark
                                        ? Colors.grey[300]
                                        : Colors.grey[700]),
                            ),
                            label: Text(
                              item.label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark
                                          ? Colors.grey[300]
                                          : Colors.grey[800]),
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: item.color,
                            backgroundColor: isDark
                                ? AppColors.inputDark
                                : Colors.grey[200],
                            onSelected: (val) {
                              if (val) {
                                controller.selectedGstKind.value = item.key;
                              }
                            },
                          );
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Date Filter Inputs & Preset Quick Buttons
                  LayoutBuilder(
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
                            Row(
                              children: [
                                Expanded(
                                  child: AppButton(
                                    text: 'This Month',
                                    variant: AppButtonVariant.outline,
                                    height: 36,
                                    onPressed: () {
                                      final now = DateTime.now();
                                      final first = DateTime(
                                        now.year,
                                        now.month,
                                        1,
                                      );
                                      controller.startDate.value = first
                                          .toIso8601String()
                                          .split('T')[0];
                                      controller.endDate.value = now
                                          .toIso8601String()
                                          .split('T')[0];
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: AppButton(
                                    text: 'Apply Filter',
                                    icon: const Icon(
                                      Icons.filter_alt_rounded,
                                      size: 14,
                                    ),
                                    height: 36,
                                    onPressed: () =>
                                        controller.loadCurrentTabReport(),
                                  ),
                                ),
                              ],
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
                            text: 'This Month',
                            variant: AppButtonVariant.outline,
                            onPressed: () {
                              final now = DateTime.now();
                              final first = DateTime(now.year, now.month, 1);
                              controller.startDate.value = first
                                  .toIso8601String()
                                  .split('T')[0];
                              controller.endDate.value = now
                                  .toIso8601String()
                                  .split('T')[0];
                            },
                          ),
                          const SizedBox(width: 8),
                          AppButton(
                            text: 'Apply Filter',
                            icon: const Icon(
                              Icons.filter_alt_rounded,
                              size: 16,
                            ),
                            onPressed: () => controller.loadCurrentTabReport(),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            // 2. Report Content Body
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const LoadingIndicator();
                }

                final currentKind = controller.selectedGstKind.value;
                final rawData = controller.gstReportData.value;
                final gstSummary = controller.gstSummary.value;

                if (currentKind == 'summary' && gstSummary != null) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        // Top 4 Summary Cards
                        _buildSummaryMetricsGrid(gstSummary, isDark),
                        const SizedBox(height: 20),
                        // Tax Head Breakdown Table
                        _buildDesktopGstTable(gstSummary, isDark),
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                }

                if (currentKind == 'exceptions' && rawData != null) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        _buildExceptionsSeverityGrid(rawData, isDark),
                        const SizedBox(height: 16),
                        _buildGenericGstDataView(currentKind, rawData, isDark),
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                }

                if (rawData == null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!controller.isLoading.value) {
                      controller.loadGstReport();
                    }
                  });
                  return const EmptyState(
                    icon: Icons.receipt_long_rounded,
                    title: 'No GST Data Available',
                    description:
                        'Select a valid date range to view tax registers.',
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _buildGenericGstDataView(currentKind, rawData, isDark),
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

  Widget _buildSummaryMetricsGrid(GstReportSummary gst, bool isDark) {
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
              '₹${gst.totalOutputTax.toStringAsFixed(2)}',
              Icons.arrow_upward_rounded,
              AppColors.danger,
              isDark,
            ),
            _buildMetricCard(
              'Input GST (ITC)',
              '₹${gst.totalInputTax.toStringAsFixed(2)}',
              Icons.arrow_downward_rounded,
              AppColors.info,
              isDark,
            ),
            _buildMetricCard(
              'Net Tax Payable',
              '₹${gst.netTaxPayable.toStringAsFixed(2)}',
              Icons.account_balance_rounded,
              AppColors.warning,
              isDark,
            ),
            _buildMetricCard(
              'Total Available ITC',
              '₹${gst.totalInputTax.toStringAsFixed(2)}',
              Icons.verified_user_rounded,
              AppColors.success,
              isDark,
            ),
          ],
        );
      },
    );
  }

  Widget _buildExceptionsSeverityGrid(dynamic rawData, bool isDark) {
    int high = 0;
    int medium = 0;
    int low = 0;

    if (rawData is Map<String, dynamic> && rawData['counts'] is Map) {
      final counts = rawData['counts'] as Map;
      high = (counts['high'] as num?)?.toInt() ?? 0;
      medium = (counts['medium'] as num?)?.toInt() ?? 0;
      low = (counts['low'] as num?)?.toInt() ?? 0;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        final hWidget = _buildMetricCard(
          'High Severity Issues',
          '$high',
          Icons.error_outline_rounded,
          AppColors.danger,
          isDark,
        );
        final mWidget = _buildMetricCard(
          'Medium Severity Issues',
          '$medium',
          Icons.warning_amber_rounded,
          AppColors.warning,
          isDark,
        );
        final lWidget = _buildMetricCard(
          'Low Severity Issues',
          '$low',
          Icons.info_outline_rounded,
          AppColors.info,
          isDark,
        );

        if (isMobile) {
          return Column(
            children: [
              hWidget,
              const SizedBox(height: 8),
              mWidget,
              const SizedBox(height: 8),
              lWidget,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: hWidget),
            const SizedBox(width: 12),
            Expanded(child: mWidget),
            const SizedBox(width: 12),
            Expanded(child: lWidget),
          ],
        );
      },
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

  Widget _buildDesktopGstTable(GstReportSummary gst, bool isDark) {
    final rows = gst.breakdownRows;

    return AppCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: AppRadius.lg,
        child: Column(
          children: [
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
                    flex: 3,
                    child: Text(
                      'TAX HEAD',
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
                      'OUTPUT TAX',
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
                      'INPUT TAX',
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
                      'PAYABLE',
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
                      'EXCESS ITC',
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
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rows.length,
              separatorBuilder: (_, index) => Divider(
                height: 1,
                color: isDark
                    ? AppColors.borderDark.withAlpha(50)
                    : Colors.grey[200],
              ),
              itemBuilder: (context, index) {
                final r = rows[index];
                final isTotalRow = r.head.contains('TOTAL');

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  color: isTotalRow
                      ? (isDark ? AppColors.inputDark : Colors.grey[100])
                      : null,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          r.head,
                          style: TextStyle(
                            fontSize: isTotalRow ? 12 : 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '₹${r.output.toStringAsFixed(2)}',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: isTotalRow ? 12 : 13,
                            fontWeight: isTotalRow
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontFamily: 'monospace',
                            color: AppColors.danger,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '₹${r.input.toStringAsFixed(2)}',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: isTotalRow ? 12 : 13,
                            fontWeight: isTotalRow
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontFamily: 'monospace',
                            color: AppColors.info,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '₹${r.payable.toStringAsFixed(2)}',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: isTotalRow ? 12 : 13,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '₹${r.excessITC.toStringAsFixed(2)}',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: isTotalRow ? 12 : 13,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenericGstDataView(String kind, dynamic rawData, bool isDark) {
    List<Map<String, dynamic>> rowList = [];

    if (rawData is List) {
      for (final item in rawData) {
        if (item is Map<String, dynamic>) {
          rowList.add(item);
        }
      }
    } else if (rawData is Map<String, dynamic>) {
      final rows = rawData['rows'] ?? rawData['data'] ?? rawData['entries'];
      if (rows is List) {
        for (final item in rows) {
          if (item is Map<String, dynamic>) {
            rowList.add(item);
          }
        }
      } else {
        rowList.add(rawData);
      }
    }

    if (rowList.isEmpty) {
      return const EmptyState(
        icon: Icons.file_present_rounded,
        title: 'No GST Records Found',
        description:
            'No tax rows available for this period in the selected GST section.',
      );
    }

    final keys = rowList.first.keys.take(8).toList();

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
              child: Row(
                children: keys.map((k) {
                  final isMoney =
                      k.toLowerCase().contains('tax') ||
                      k.toLowerCase().contains('amount') ||
                      k.toLowerCase().contains('value') ||
                      k.toLowerCase().contains('cgst') ||
                      k.toLowerCase().contains('sgst') ||
                      k.toLowerCase().contains('igst') ||
                      k.toLowerCase().contains('payable');

                  final formattedKey = k
                      .replaceAll(RegExp(r'([A-Z])'), ' \$1')
                      .toUpperCase()
                      .trim();

                  return Expanded(
                    child: Text(
                      formattedKey,
                      textAlign: isMoney ? TextAlign.right : TextAlign.left,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Rows
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rowList.length,
              separatorBuilder: (_, index) => Divider(
                height: 1,
                color: isDark
                    ? AppColors.borderDark.withAlpha(50)
                    : Colors.grey[200],
              ),
              itemBuilder: (context, rIndex) {
                final row = rowList[rIndex];
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    children: keys.map((k) {
                      final val = row[k];
                      final isMoney =
                          k.toLowerCase().contains('tax') ||
                          k.toLowerCase().contains('amount') ||
                          k.toLowerCase().contains('value') ||
                          k.toLowerCase().contains('cgst') ||
                          k.toLowerCase().contains('sgst') ||
                          k.toLowerCase().contains('igst') ||
                          k.toLowerCase().contains('payable');
                      final isSeverity = k.toLowerCase().contains('severity');

                      if (isSeverity && val != null) {
                        final strVal = val.toString().toUpperCase();
                        Color sevColor = AppColors.info;
                        if (strVal.contains('HIGH') || strVal.contains('ERR')) {
                          sevColor = AppColors.danger;
                        } else if (strVal.contains('MED') ||
                            strVal.contains('WARN')) {
                          sevColor = AppColors.warning;
                        }

                        return Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: sevColor.withAlpha(25),
                                borderRadius: AppRadius.sm,
                              ),
                              child: Text(
                                strVal,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: sevColor,
                                ),
                              ),
                            ),
                          ),
                        );
                      }

                      String textVal = '-';
                      if (val is num) {
                        textVal = isMoney
                            ? '₹${val.toDouble().toStringAsFixed(2)}'
                            : val.toString();
                      } else if (val != null) {
                        textVal = val.toString();
                      }

                      return Expanded(
                        child: Text(
                          textVal,
                          textAlign: isMoney ? TextAlign.right : TextAlign.left,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isMoney
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontFamily: isMoney ? 'monospace' : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
