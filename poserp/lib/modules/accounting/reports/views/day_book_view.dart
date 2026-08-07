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
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
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
                            'Chronological day-wise accounting transactions and journal entries.',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
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
              ),
              const SizedBox(height: 20),

              // Filter Controls
              AppCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 180,
                      child: TextField(
                        onChanged: (val) => controller.selectedDate.value = val,
                        controller: TextEditingController(
                          text: controller.selectedDate.value,
                        ),
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          labelText: 'Select Date (YYYY-MM-DD)',
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
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: TextField(
                        onChanged: (val) => controller.searchQuery.value = val,
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Search ledger, voucher no, narration...',
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
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Table Content
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const LoadingIndicator();
                  }

                  final db = controller.dayBook.value;
                  if (db == null || db.entries.isEmpty) {
                    return const EmptyState(
                      icon: Icons.menu_book_rounded,
                      title: 'No Transactions on Selected Date',
                      description:
                          'No journal or voucher postings recorded for this day.',
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
                                      'TYPE',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'LEDGER ACCOUNT',
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
                                ],
                                rows: db.entries.map((e) {
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Text(
                                          e.date.split('T')[0],
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          e.voucherNo.isNotEmpty
                                              ? e.voucherNo
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
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withAlpha(
                                              20,
                                            ),
                                            borderRadius: AppRadius.full,
                                          ),
                                          child: Text(
                                            e.voucherTypeCode,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary,
                                            ),
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
                                              e.ledgerName,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            if (e.narration != null &&
                                                e.narration!.isNotEmpty)
                                              Text(
                                                e.narration!,
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
                                          e.debit > 0
                                              ? '₹${e.debit.toStringAsFixed(2)}'
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
                                          e.credit > 0
                                              ? '₹${e.credit.toStringAsFixed(2)}'
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

                          // Summary Footer
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Day Debit: ₹${db.totalDebit.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                                Text(
                                  'Total Day Credit: ₹${db.totalCredit.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.info,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
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
