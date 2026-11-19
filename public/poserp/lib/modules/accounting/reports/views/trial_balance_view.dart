import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/financial_reports_controller.dart';

class TrialBalanceView extends GetView<FinancialReportsController> {
  const TrialBalanceView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Basic Trial Balance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => controller.loadCurrentTabReport(),
            tooltip: 'Refresh Trial Balance',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Toolbar
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;

                  final statusBadge = Obx(() {
                    final isBal = controller.tbIsBalanced;
                    final diff = controller.tbDifference;
                    final hasData = controller.tbFilteredRows.isNotEmpty;

                    if (!hasData) return const SizedBox.shrink();

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: (isBal ? AppColors.success : AppColors.warning)
                            .withAlpha(25),
                        borderRadius: AppRadius.full,
                      ),
                      child: Text(
                        isBal
                            ? 'BALANCED'
                            : 'DIFFERENCE ₹${diff.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isBal ? AppColors.success : AppColors.warning,
                        ),
                      ),
                    );
                  });

                  if (isMobile) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(25),
                                borderRadius: AppRadius.md,
                              ),
                              child: const Icon(
                                Icons.bar_chart_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'Basic Trial Balance',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            statusBadge,
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Validation-level double-entry debit vs credit balance summary by ledger.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 12),
                        AppButton(
                          text: 'Refresh',
                          icon: const Icon(Icons.refresh_rounded, size: 14),
                          height: 36,
                          variant: AppButtonVariant.outline,
                          onPressed: () => controller.loadCurrentTabReport(),
                        ),
                      ],
                    );
                  }

                  return Row(
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
                              Icons.bar_chart_rounded,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Basic Trial Balance',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  statusBadge,
                                ],
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Validation-level double-entry debit vs credit balance summary by ledger.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      AppButton(
                        text: 'Refresh',
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        variant: AppButtonVariant.outline,
                        onPressed: () => controller.loadCurrentTabReport(),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),

              // 2. Filter Controls (As On Date & Account Group Dropdown)
              AppCard(
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
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
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

                    final groupDropdown = Obx(
                      () => DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: controller.tbSelectedGroup.value,
                        dropdownColor: isDark
                            ? AppColors.cardDark
                            : AppColors.cardLight,
                        decoration: InputDecoration(
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
                        items: [
                          const DropdownMenuItem(
                            value: 'ALL',
                            child: Text(
                              'All Groups',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          ...controller.tbAvailableGroups.map((g) {
                            return DropdownMenuItem<String>(
                              value: g,
                              child: Text(
                                g,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          }),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            controller.tbSelectedGroup.value = val;
                          }
                        },
                      ),
                    );

                    if (isMobile) {
                      return Column(
                        children: [
                          dateInput,
                          const SizedBox(height: 8),
                          groupDropdown,
                        ],
                      );
                    }

                    return Row(
                      children: [
                        SizedBox(width: 200, child: dateInput),
                        const SizedBox(width: 12),
                        SizedBox(width: 260, child: groupDropdown),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // 3. Live Trial Balance Data Table & Footer
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const LoadingIndicator();
                  }

                  final rows = controller.tbFilteredRows;
                  if (rows.isEmpty) {
                    return const EmptyState(
                      icon: Icons.bar_chart_rounded,
                      title: 'No Ledger Balances Found',
                      description:
                          'Initialize accounting or post manual vouchers to generate trial balance entries.',
                    );
                  }

                  final totalDebit = controller.tbTotalDebit;
                  final totalCredit = controller.tbTotalCredit;
                  final difference = controller.tbDifference;

                  return AppCard(
                    padding: EdgeInsets.zero,
                    child: ClipRRect(
                      borderRadius: AppRadius.lg,
                      child: Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  minWidth: 700,
                                ),
                                child: SingleChildScrollView(
                                  child: DataTable(
                                    columnSpacing: 20,
                                    headingRowColor: WidgetStateProperty.all(
                                      isDark
                                          ? AppColors.inputDark
                                          : Colors.grey[100],
                                    ),
                                    columns: const [
                                      DataColumn(
                                        label: Text(
                                          'LEDGER NAME & CODE',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'ACCOUNT GROUP',
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
                                          'DEBIT BALANCE (₹)',
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
                                          'CREDIT BALANCE (₹)',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ],
                                    rows: rows.map((r) {
                                      return DataRow(
                                        cells: [
                                          DataCell(
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  r.ledgerName,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  r.code,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    fontFamily: 'monospace',
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              r.groupName.isNotEmpty
                                                  ? r.groupName
                                                  : '-',
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              r.debitBalance > 0
                                                  ? '₹${r.debitBalance.toStringAsFixed(2)}'
                                                  : '-',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'monospace',
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              r.creditBalance > 0
                                                  ? '₹${r.creditBalance.toStringAsFixed(2)}'
                                                  : '-',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
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
                          ),

                          // Summary Footer Row (Totals & Difference)
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.inputDark
                                  : Colors.grey[100],
                              border: Border(
                                top: BorderSide(
                                  color: isDark
                                      ? AppColors.borderDark
                                      : AppColors.borderLight,
                                ),
                              ),
                            ),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final isMobileFooter =
                                    constraints.maxWidth < 500;

                                if (isMobileFooter) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Debit: ₹${totalDebit.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary,
                                              fontFamily: 'monospace',
                                            ),
                                          ),
                                          Text(
                                            'Credit: ₹${totalCredit.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.info,
                                              fontFamily: 'monospace',
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Difference: ₹${difference.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: difference < 0.01
                                              ? AppColors.success
                                              : AppColors.warning,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ],
                                  );
                                }

                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total Debit: ₹${totalDebit.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                    Text(
                                      'Total Credit: ₹${totalCredit.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.info,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                    Text(
                                      'Difference: ₹${difference.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: difference < 0.01
                                            ? AppColors.success
                                            : AppColors.warning,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
