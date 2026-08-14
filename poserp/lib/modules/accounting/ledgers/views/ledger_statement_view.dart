import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/ledger_statement_controller.dart';

class LedgerStatementView extends GetView<LedgerStatementController> {
  const LedgerStatementView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button & Header
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;

                  if (isMobile) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_rounded),
                              onPressed: () => Get.back(),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(25),
                                borderRadius: AppRadius.md,
                              ),
                              child: const Icon(
                                Icons.receipt_long_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Obx(() {
                              final st = controller.statement.value;
                              final l = st?.ledger;
                              return Expanded(
                                child: Text(
                                  l != null
                                      ? '${l.name} Statement'
                                      : 'Ledger Statement',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Obx(() {
                          final st = controller.statement.value;
                          final l = st?.ledger;
                          return Text(
                            l != null
                                ? 'Code: ${l.code} · Group: ${l.groupName}'
                                : 'Ledger entries and T-Account debit/credit statement.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          );
                        }),
                        const SizedBox(height: 12),
                        AppButton(
                          text: 'Refresh',
                          icon: const Icon(Icons.refresh_rounded, size: 14),
                          height: 36,
                          onPressed: () => controller.loadStatement(),
                        ),
                      ],
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_rounded),
                            onPressed: () => Get.back(),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(25),
                              borderRadius: AppRadius.lg,
                            ),
                            child: const Icon(
                              Icons.receipt_long_rounded,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Obx(() {
                            final st = controller.statement.value;
                            final l = st?.ledger;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l != null
                                      ? '${l.name} Statement'
                                      : 'Ledger Statement',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  l != null
                                      ? 'Code: ${l.code} · Group: ${l.groupName}'
                                      : 'Ledger entries and T-Account debit/credit statement.',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                      AppButton(
                        text: 'Refresh',
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        onPressed: () => controller.loadStatement(),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),

              // Filter Controls
              AppCard(
                padding: const EdgeInsets.all(12),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 600;

                    final searchInput = TextField(
                      onChanged: (val) => controller.searchQuery.value = val,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Search voucher number or narration...',
                        prefixIcon: const Icon(Icons.search, size: 18),
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

                    final startDateInput = TextField(
                      onChanged: (val) => controller.startDate.value = val,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Start (YYYY-MM-DD)',
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

                    final endDateInput = TextField(
                      onChanged: (val) => controller.endDate.value = val,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'End (YYYY-MM-DD)',
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
                          searchInput,
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(child: startDateInput),
                              const SizedBox(width: 8),
                              Expanded(child: endDateInput),
                            ],
                          ),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(flex: 2, child: searchInput),
                        const SizedBox(width: 12),
                        SizedBox(width: 150, child: startDateInput),
                        const SizedBox(width: 12),
                        SizedBox(width: 150, child: endDateInput),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Summary Cards
              Obx(() {
                final st = controller.statement.value;
                if (st == null) return const SizedBox.shrink();

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 600;

                    if (isMobile) {
                      return Column(
                        children: [
                          _buildMetricCard(
                            title: 'OPENING BALANCE',
                            value:
                                '₹${st.ledger.openingBalance.toStringAsFixed(2)} ${st.ledger.openingBalanceType == 'CREDIT' ? 'Cr' : 'Dr'}',
                            accentColor: AppColors.info,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _buildMetricCard(
                                  title: 'CURRENT BALANCE',
                                  value:
                                      '₹${st.ledger.currentBalance.toStringAsFixed(2)} ${st.ledger.currentBalanceType == 'CREDIT' ? 'Cr' : 'Dr'}',
                                  accentColor: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildMetricCard(
                                  title: 'CLOSING BALANCE',
                                  value:
                                      '₹${st.totals.closingBalance.toStringAsFixed(2)} ${st.totals.closingBalanceType == 'CREDIT' ? 'Cr' : 'Dr'}',
                                  accentColor: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            title: 'OPENING BALANCE',
                            value:
                                '₹${st.ledger.openingBalance.toStringAsFixed(2)} ${st.ledger.openingBalanceType == 'CREDIT' ? 'Cr' : 'Dr'}',
                            accentColor: AppColors.info,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetricCard(
                            title: 'CURRENT BALANCE',
                            value:
                                '₹${st.ledger.currentBalance.toStringAsFixed(2)} ${st.ledger.currentBalanceType == 'CREDIT' ? 'Cr' : 'Dr'}',
                            accentColor: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetricCard(
                            title: 'CLOSING BALANCE',
                            value:
                                '₹${st.totals.closingBalance.toStringAsFixed(2)} ${st.totals.closingBalanceType == 'CREDIT' ? 'Cr' : 'Dr'}',
                            accentColor: AppColors.success,
                          ),
                        ),
                      ],
                    );
                  },
                );
              }),
              const SizedBox(height: 16),

              // Two-Column T-Account Table (Debit Side vs Credit Side)
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const LoadingIndicator();
                  }

                  final sides = controller.sides;
                  if (sides == null) {
                    return const Center(
                      child: Text('No statement details available.'),
                    );
                  }

                  final rowCount = sides.debit.length > sides.credit.length
                      ? sides.debit.length
                      : sides.credit.length;

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
                                  minWidth: 800,
                                ),
                                child: SingleChildScrollView(
                                  child: DataTable(
                                    columnSpacing: 12,
                                    headingRowColor: WidgetStateProperty.all(
                                      isDark
                                          ? AppColors.inputDark
                                          : Colors.grey[100],
                                    ),
                                    columns: const [
                                      DataColumn(
                                        label: Text(
                                          'DEBIT DATE',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'DEBIT PARTICULARS',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        numeric: true,
                                        label: Text(
                                          'DEBIT (₹)',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'CREDIT DATE',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.info,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'CREDIT PARTICULARS',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.info,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        numeric: true,
                                        label: Text(
                                          'CREDIT (₹)',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.info,
                                          ),
                                        ),
                                      ),
                                    ],
                                    rows: List.generate(rowCount, (idx) {
                                      final dLine = idx < sides.debit.length
                                          ? sides.debit[idx]
                                          : null;
                                      final cLine = idx < sides.credit.length
                                          ? sides.credit[idx]
                                          : null;

                                      return DataRow(
                                        cells: [
                                          DataCell(
                                            Text(
                                              dLine?.date.split('T')[0] ?? '',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontFamily: 'monospace',
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  dLine?.particulars ?? '',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight:
                                                        dLine?.kind != 'entry'
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                                  ),
                                                ),
                                                if (dLine?.meta != null)
                                                  Text(
                                                    dLine!.meta!,
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              dLine != null
                                                  ? '₹${dLine.amount.toStringAsFixed(2)}'
                                                  : '',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'monospace',
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              cLine?.date.split('T')[0] ?? '',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontFamily: 'monospace',
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  cLine?.particulars ?? '',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight:
                                                        cLine?.kind != 'entry'
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                                  ),
                                                ),
                                                if (cLine?.meta != null)
                                                  Text(
                                                    cLine!.meta!,
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              cLine != null
                                                  ? '₹${cLine.amount.toStringAsFixed(2)}'
                                                  : '',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'monospace',
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Total Footer Summary Row
                          Container(
                            padding: const EdgeInsets.all(12),
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
                                            'Debit: ₹${sides.debitTotal.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary,
                                              fontFamily: 'monospace',
                                            ),
                                          ),
                                          Text(
                                            'Credit: ₹${sides.creditTotal.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.info,
                                              fontFamily: 'monospace',
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Variance: ₹${(sides.debitTotal - sides.creditTotal).abs().toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
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
                                      'Total Debit: ₹${sides.debitTotal.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                    Text(
                                      'Total Credit: ₹${sides.creditTotal.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.info,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                    Text(
                                      'Variance: ₹${(sides.debitTotal - sides.creditTotal).abs().toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
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

  Widget _buildMetricCard({
    required String title,
    required String value,
    required Color accentColor,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: accentColor,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
