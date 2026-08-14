import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/day_book_controller.dart';

class DayBookView extends GetView<DayBookController> {
  const DayBookView({super.key});

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
              // 1. Header Toolbar
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;

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
                                Icons.menu_book_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'Day Book',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Posted accounting voucher entries date-wise.',
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
                          onPressed: () => controller.loadDayBook(),
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
                              Icons.menu_book_rounded,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Day Book',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Posted accounting voucher entries date-wise.',
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
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        onPressed: () => controller.loadDayBook(),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),

              // 2. Filter Controls (5 Filters: Start Date, End Date, Voucher Type, Ledger, Search)
              AppCard(
                padding: const EdgeInsets.all(12),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 600;

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

                    final typeDropdown = Obx(
                      () => DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: controller.selectedVoucherType.value,
                        dropdownColor: isDark
                            ? AppColors.cardDark
                            : AppColors.cardLight,
                        decoration: _buildDropdownDecoration(isDark),
                        items: [
                          const DropdownMenuItem(
                            value: 'ALL',
                            child: Text(
                              'All Types',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          ...controller.availableVoucherTypes.map((t) {
                            return DropdownMenuItem<String>(
                              value: t.code,
                              child: Text(
                                t.name,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          }),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            controller.selectedVoucherType.value = val;
                          }
                        },
                      ),
                    );

                    final ledgerDropdown = Obx(
                      () => DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: controller.selectedLedgerId.value,
                        dropdownColor: isDark
                            ? AppColors.cardDark
                            : AppColors.cardLight,
                        decoration: _buildDropdownDecoration(isDark),
                        items: [
                          const DropdownMenuItem(
                            value: 'ALL',
                            child: Text(
                              'All Ledgers',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          ...controller.availableLedgers.map((l) {
                            return DropdownMenuItem<String>(
                              value: l.id,
                              child: Text(
                                l.name,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          }),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            controller.selectedLedgerId.value = val;
                          }
                        },
                      ),
                    );

                    final searchInput = TextField(
                      onChanged: (val) => controller.searchQuery.value = val,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Search voucher, reference, narration...',
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
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(child: typeDropdown),
                              const SizedBox(width: 8),
                              Expanded(child: ledgerDropdown),
                            ],
                          ),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        SizedBox(width: 140, child: startDateInput),
                        const SizedBox(width: 8),
                        SizedBox(width: 140, child: endDateInput),
                        const SizedBox(width: 8),
                        Expanded(child: typeDropdown),
                        const SizedBox(width: 8),
                        Expanded(child: ledgerDropdown),
                        const SizedBox(width: 8),
                        Expanded(flex: 2, child: searchInput),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // 3. Date-Grouped Posted Entries Table
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const LoadingIndicator();
                  }

                  final groups = controller.groupedEntries;
                  final db = controller.dayBook.value;

                  if (groups.isEmpty) {
                    return const EmptyState(
                      icon: Icons.menu_book_rounded,
                      title: 'No Posted Day Book Entries Found',
                      description:
                          'Try clearing filter options or changing date range.',
                    );
                  }

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
                                  minWidth: 950,
                                ),
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
                                          'VOUCHER NO',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'VOUCHER TYPE',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'PARTY / LEDGER',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'NARRATION',
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
                                          'DEBIT (₹)',
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
                                          'CREDIT (₹)',
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
                                      DataColumn(
                                        label: Text(
                                          'ACTIONS',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ],
                                    rows: groups.flatMap((group) {
                                      final List<DataRow> rows = [];

                                      // Date Header Row
                                      rows.add(
                                        DataRow(
                                          color: WidgetStateProperty.all(
                                            isDark
                                                ? AppColors.cardDark
                                                : Colors.grey[200],
                                          ),
                                          cells: [
                                            DataCell(
                                              Text(
                                                group.date,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ),
                                            const DataCell(Text('')),
                                            const DataCell(Text('')),
                                            const DataCell(Text('')),
                                            const DataCell(Text('')),
                                            const DataCell(Text('')),
                                            const DataCell(Text('')),
                                            const DataCell(Text('')),
                                            const DataCell(Text('')),
                                          ],
                                        ),
                                      );

                                      // Individual Entry Rows
                                      for (final entry in group.entries) {
                                        rows.add(
                                          DataRow(
                                            cells: [
                                              DataCell(
                                                Text(
                                                  entry.date.contains('T')
                                                      ? entry.date.split('T')[0]
                                                      : entry.date,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontFamily: 'monospace',
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  entry.voucherNo.isNotEmpty
                                                      ? entry.voucherNo
                                                      : '-',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'monospace',
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.primary
                                                        .withAlpha(20),
                                                    borderRadius: AppRadius.sm,
                                                    border: Border.all(
                                                      color: AppColors.primary
                                                          .withAlpha(50),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    entry.voucherTypeCode,
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: AppColors.primary,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  entry.ledgerName,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                SizedBox(
                                                  width: 200,
                                                  child: Text(
                                                    entry.narration ??
                                                        entry.referenceNo ??
                                                        '-',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  entry.debit > 0
                                                      ? '₹${entry.debit.toStringAsFixed(2)}'
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
                                                  entry.credit > 0
                                                      ? '₹${entry.credit.toStringAsFixed(2)}'
                                                      : '-',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'monospace',
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.success
                                                        .withAlpha(20),
                                                    borderRadius:
                                                        AppRadius.full,
                                                  ),
                                                  child: Text(
                                                    entry.status.toUpperCase(),
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: AppColors.success,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                AppButton(
                                                  text: 'View',
                                                  variant:
                                                      AppButtonVariant.outline,
                                                  icon: const Icon(
                                                    Icons.receipt_long_rounded,
                                                    size: 14,
                                                  ),
                                                  height: 30,
                                                  onPressed: () {
                                                    if (entry
                                                        .ledgerId
                                                        .isNotEmpty) {
                                                      Get.toNamed(
                                                        '/accounting/ledgers/${entry.ledgerId}',
                                                        arguments:
                                                            entry.ledgerId,
                                                      );
                                                    } else {
                                                      Get.toNamed(
                                                        '/accounting/vouchers',
                                                      );
                                                    }
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }

                                      // Subtotal Day Total Row
                                      rows.add(
                                        DataRow(
                                          color: WidgetStateProperty.all(
                                            isDark
                                                ? AppColors.inputDark
                                                : Colors.grey[100],
                                          ),
                                          cells: [
                                            const DataCell(
                                              Text(
                                                'Day Total',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const DataCell(Text('')),
                                            const DataCell(Text('')),
                                            const DataCell(Text('')),
                                            const DataCell(Text('')),
                                            DataCell(
                                              Text(
                                                '₹${group.subtotalDebit.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'monospace',
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                '₹${group.subtotalCredit.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'monospace',
                                                  color: AppColors.info,
                                                ),
                                              ),
                                            ),
                                            const DataCell(Text('')),
                                            const DataCell(Text('')),
                                          ],
                                        ),
                                      );

                                      return rows;
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // 4. Grand Total Summary Footer
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
                                      const Text(
                                        'Grand Total',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Debit: ₹${db?.totalDebit.toStringAsFixed(2) ?? "0.00"}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary,
                                              fontFamily: 'monospace',
                                            ),
                                          ),
                                          Text(
                                            'Credit: ₹${db?.totalCredit.toStringAsFixed(2) ?? "0.00"}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.info,
                                              fontFamily: 'monospace',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                }

                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Grand Total',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          'Total Debit: ₹${db?.totalDebit.toStringAsFixed(2) ?? "0.00"}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                        const SizedBox(width: 20),
                                        Text(
                                          'Total Credit: ₹${db?.totalCredit.toStringAsFixed(2) ?? "0.00"}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.info,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ],
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

  InputDecoration _buildDropdownDecoration(bool isDark) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      filled: true,
      fillColor: isDark ? AppColors.inputDark : Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: AppRadius.md,
        borderSide: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
    );
  }
}

extension FlatMapExtension<T> on Iterable<T> {
  List<R> flatMap<R>(Iterable<R> Function(T element) transform) {
    return expand(transform).toList();
  }
}
