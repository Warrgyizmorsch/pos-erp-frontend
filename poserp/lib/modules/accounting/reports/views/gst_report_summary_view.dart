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

  const GstReportItemMeta({
    required this.key,
    required this.label,
    required this.description,
    required this.icon,
  });
}

const List<GstReportItemMeta> gstKindsList = [
  GstReportItemMeta(
    key: 'summary',
    label: 'GST Summary',
    description: 'Output GST, input GST, returns, and net payable.',
    icon: Icons.pie_chart_rounded,
  ),
  GstReportItemMeta(
    key: 'output',
    label: 'Output GST',
    description: 'GST collected on sales invoices.',
    icon: Icons.arrow_upward_rounded,
  ),
  GstReportItemMeta(
    key: 'input',
    label: 'Input GST (ITC)',
    description: 'GST paid on purchase bills and available ITC.',
    icon: Icons.arrow_downward_rounded,
  ),
  GstReportItemMeta(
    key: 'payable',
    label: 'GST Payable / ITC',
    description: 'GST liability and excess ITC by tax head.',
    icon: Icons.account_balance_rounded,
  ),
  GstReportItemMeta(
    key: 'hsn-summary',
    label: 'HSN Summary',
    description: 'HSN-wise quantity, taxable value, and tax.',
    icon: Icons.format_list_bulleted_rounded,
  ),
  GstReportItemMeta(
    key: 'gstr1',
    label: 'GSTR-1 Style',
    description: 'Internal sales breakup for B2B, B2C, credit notes, and HSN.',
    icon: Icons.menu_book_rounded,
  ),
  GstReportItemMeta(
    key: 'gstr3b',
    label: 'GSTR-3B Summary',
    description: 'Internal monthly GST summary for review.',
    icon: Icons.book_rounded,
  ),
  GstReportItemMeta(
    key: 'ledger',
    label: 'GST Ledger',
    description: 'Voucher entry movement for GST ledgers.',
    icon: Icons.receipt_long_rounded,
  ),
  GstReportItemMeta(
    key: 'party-wise',
    label: 'GST Party-wise',
    description: 'GST grouped by customers and suppliers.',
    icon: Icons.groups_rounded,
  ),
  GstReportItemMeta(
    key: 'exceptions',
    label: 'GST Exceptions',
    description: 'Missing HSN, GSTIN, state, and tax mismatch issues.',
    icon: Icons.warning_amber_rounded,
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
            // 1. Date Range Filter & GST Kind Selector Toolbar
            AppCard(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  // Horizontal Scrollable GST Sub-Section Tabs
                  SizedBox(
                    height: 38,
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
                                fontSize: 12,
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
                            selectedColor: AppColors.primary,
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
                  const SizedBox(height: 12),

                  // Date inputs
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
                            AppButton(
                              text: 'Apply Filter',
                              icon: const Icon(
                                Icons.filter_alt_rounded,
                                size: 14,
                              ),
                              onPressed: () =>
                                  controller.loadCurrentTabReport(),
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

            // 2. Report Body
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
    final cgstPayable = gst.outputCgst - gst.inputCgst;
    final sgstPayable = gst.outputSgst - gst.inputSgst;
    final igstPayable = gst.outputIgst - gst.inputIgst;

    final rows = [
      {
        'taxHead': 'CGST (Central Tax)',
        'output': gst.outputCgst,
        'input': gst.inputCgst,
        'payable': cgstPayable,
      },
      {
        'taxHead': 'SGST (State Tax)',
        'output': gst.outputSgst,
        'input': gst.inputSgst,
        'payable': sgstPayable,
      },
      {
        'taxHead': 'IGST (Integrated Tax)',
        'output': gst.outputIgst,
        'input': gst.inputIgst,
        'payable': igstPayable,
      },
    ];

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
                      'OUTPUT GST (SALES)',
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
                      'INPUT GST (PURCHASES)',
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
                      'NET PAYABLE / (ITC)',
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
                final outVal = r['output'] as double;
                final inVal = r['input'] as double;
                final payVal = r['payable'] as double;

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          r['taxHead'] as String,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '₹${outVal.toStringAsFixed(2)}',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'monospace',
                            color: AppColors.danger,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '₹${inVal.toStringAsFixed(2)}',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'monospace',
                            color: AppColors.info,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '₹${payVal.abs().toStringAsFixed(2)} ${payVal >= 0 ? "Payable" : "ITC"}',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                            color: payVal >= 0
                                ? AppColors.warning
                                : AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
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
                    flex: 3,
                    child: Text(
                      'TOTAL TAX SUMMARY',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '₹${gst.totalOutputTax.toStringAsFixed(2)}',
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
                      '₹${gst.totalInputTax.toStringAsFixed(2)}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        color: AppColors.info,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '₹${gst.netTaxPayable.toStringAsFixed(2)}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        color: AppColors.warning,
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
