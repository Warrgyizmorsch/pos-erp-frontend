import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/purchase_return_controller.dart';
import 'purchase_return_detail_view.dart';
import 'purchase_return_form_view.dart';

class PurchaseReturnListView extends GetView<PurchaseReturnController> {
  const PurchaseReturnListView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      if (controller.viewMode.value == 'create') {
        return const PurchaseReturnFormView();
      }

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
                            Icons.receipt_long_outlined,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Purchase Return / Debit Note',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'View and manage purchase bills returns history and supplier debit notes.',
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
                      text: 'Add Purchase Return',
                      icon: const Icon(Icons.add_rounded, size: 18),
                      onPressed: () => controller.viewMode.value = 'create',
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Metrics Panel
                Obx(
                  () => Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          context,
                          title: 'TOTAL RETURNS AMOUNT',
                          value: controller.listTotalReturns,
                          subtitle: 'Excludes cancelled transactions',
                          accentColor: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildMetricCard(
                          context,
                          title: 'TOTAL CASH RECEIVED',
                          value: controller.listTotalRefunded,
                          subtitle: 'Refund received in cash or bank',
                          accentColor: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildMetricCard(
                          context,
                          title: 'SUPPLIER DEBIT BALANCE',
                          value: controller.listTotalDebit,
                          subtitle: 'Reduces supplier outstanding balances',
                          accentColor: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Control & Filter Bar
                Row(
                  children: [
                    // Search Input
                    Expanded(
                      flex: 2,
                      child: TextField(
                        onChanged: (val) => controller.searchQuery.value = val,
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Search Debit Note or purchase bill...',
                          prefixIcon: const Icon(Icons.search, size: 18),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
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

                    // Status Filter
                    Obx(
                      () => SizedBox(
                        width: 150,
                        child: DropdownButtonFormField<String>(
                          initialValue: controller.statusFilter.value,
                          dropdownColor: isDark
                              ? AppColors.cardDark
                              : AppColors.cardLight,
                          decoration: InputDecoration(
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
                          items: const [
                            DropdownMenuItem(
                              value: 'all',
                              child: Text('All Status'),
                            ),
                            DropdownMenuItem(
                              value: 'issued',
                              child: Text('Issued'),
                            ),
                            DropdownMenuItem(
                              value: 'refunded',
                              child: Text('Refunded'),
                            ),
                            DropdownMenuItem(
                              value: 'adjusted',
                              child: Text('Adjusted'),
                            ),
                            DropdownMenuItem(
                              value: 'cancelled',
                              child: Text('Cancelled'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              controller.statusFilter.value = val;
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Refund Filter
                    Obx(
                      () => SizedBox(
                        width: 170,
                        child: DropdownButtonFormField<String>(
                          initialValue: controller.refundFilter.value,
                          dropdownColor: isDark
                              ? AppColors.cardDark
                              : AppColors.cardLight,
                          decoration: InputDecoration(
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
                          items: const [
                            DropdownMenuItem(
                              value: 'all',
                              child: Text('All Refund Types'),
                            ),
                            DropdownMenuItem(
                              value: 'refund_received',
                              child: Text('Refund Received'),
                            ),
                            DropdownMenuItem(
                              value: 'keep_as_debit',
                              child: Text('Supplier Debit'),
                            ),
                            DropdownMenuItem(
                              value: 'adjust_future_purchase',
                              child: Text('Future Adjust'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              controller.refundFilter.value = val;
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Returns List Table
                Expanded(
                  child: Obx(() {
                    if (controller.isLoadingList.value) {
                      return const LoadingIndicator();
                    }
                    if (controller.returns.isEmpty) {
                      return EmptyState(
                        icon: Icons.receipt_long_outlined,
                        title: 'No Purchase Returns Recorded',
                        description:
                            'Record returned stock to suppliers and issue debit notes.',
                        action: AppButton(
                          text: 'Add Purchase Return',
                          icon: const Icon(Icons.add, size: 18),
                          onPressed: () => controller.viewMode.value = 'create',
                        ),
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
                                        '#',
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
                                    DataColumn(
                                      label: Text(
                                        'DEBIT NOTE NO',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'PURCHASE BILL NO',
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
                                      label: Text(
                                        'RETURN TYPE',
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
                                        'TOTAL RETURN',
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
                                        'REFUND RECD',
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
                                        'DEBIT BAL',
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
                                  rows: List.generate(controller.returns.length, (
                                    idx,
                                  ) {
                                    final note = controller.returns[idx];
                                    final dateStr = note.returnDate.split(
                                      'T',
                                    )[0];

                                    return DataRow(
                                      cells: [
                                        DataCell(
                                          Text(
                                            '${idx + 1 + (controller.currentPage.value - 1) * controller.itemsPerPage}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            dateStr,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontFamily: 'monospace',
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            note.debitNoteNo,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'monospace',
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            note.purchaseNumber,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontFamily: 'monospace',
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            note.supplierName,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            note.refundType == 'refund_received'
                                                ? 'Refund Recd'
                                                : (note.refundType ==
                                                          'keep_as_debit'
                                                      ? 'Supplier Debit'
                                                      : 'Bill Adjust'),
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            '₹${note.grandTotal.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'monospace',
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            '₹${note.refundReceivedAmount.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.success,
                                              fontFamily: 'monospace',
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            '₹${note.debitBalance.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.warning,
                                              fontFamily: 'monospace',
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  (note.status == 'cancelled'
                                                          ? AppColors.danger
                                                          : AppColors.success)
                                                      .withAlpha(25),
                                              borderRadius: AppRadius.full,
                                            ),
                                            child: Text(
                                              note.status.toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    note.status == 'cancelled'
                                                    ? AppColors.danger
                                                    : AppColors.success,
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.remove_red_eye_outlined,
                                                  size: 18,
                                                ),
                                                tooltip: 'View Details',
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        PurchaseReturnDetailDialog(
                                                          note: note,
                                                        ),
                                                  );
                                                },
                                              ),
                                              if (note.status != 'cancelled')
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.block_rounded,
                                                    size: 18,
                                                    color: AppColors.danger,
                                                  ),
                                                  tooltip: 'Cancel Debit Note',
                                                  onPressed: () => controller
                                                      .cancelReturn(note.id),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                ),
                              ),
                            ),

                            // Pagination Footer
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: isDark
                                        ? AppColors.borderDark
                                        : AppColors.borderLight,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Page ${controller.currentPage.value} of ${controller.totalPages.value}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      AppButton(
                                        text: 'Previous',
                                        variant: AppButtonVariant.outline,
                                        onPressed:
                                            controller.currentPage.value > 1
                                            ? () => controller.goToPage(
                                                controller.currentPage.value -
                                                    1,
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 8),
                                      AppButton(
                                        text: 'Next',
                                        variant: AppButtonVariant.outline,
                                        onPressed:
                                            controller.currentPage.value <
                                                controller.totalPages.value
                                            ? () => controller.goToPage(
                                                controller.currentPage.value +
                                                    1,
                                              )
                                            : null,
                                      ),
                                    ],
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
    });
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required double value,
    required String subtitle,
    required Color accentColor,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              Container(
                width: 4,
                height: 14,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: AppRadius.full,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '₹${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: accentColor,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
