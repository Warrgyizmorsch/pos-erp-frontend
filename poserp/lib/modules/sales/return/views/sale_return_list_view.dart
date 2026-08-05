import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_pagination.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/sale_return_controller.dart';
import '../models/sale_return.dart';
import '../widgets/sale_return_detail_dialog.dart';

class SaleReturnListView extends GetView<SaleReturnController> {
  const SaleReturnListView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sale Return / Credit Note'),
        backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
        foregroundColor: isDark
            ? AppColors.foregroundDark
            : AppColors.foregroundLight,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: AppButton(
              text: 'Add Credit Note',
              icon: const Icon(Icons.add, size: 18),
              height: 36,
              onPressed: () => Get.toNamed('/sales/return/create'),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Process customer merchandise returns and issue store credit or cash refunds',
              style: AppTypography.caption(isDark: isDark),
            ),
            const SizedBox(height: 16),

            // Summary Metrics Cards
            Obx(
              () => Row(
                children: [
                  Expanded(
                    child: AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Returned',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.mutedForegroundDark
                                  : AppColors.mutedForegroundLight,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${controller.totalReturnedAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Refunded',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.mutedForegroundDark
                                  : AppColors.mutedForegroundLight,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${controller.totalRefundedAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Credit Balance Issued',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.mutedForegroundDark
                                  : AppColors.mutedForegroundLight,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${controller.totalCreditBalance.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Filter Bar
            Row(
              children: [
                Expanded(
                  child: AppSearchField(
                    hintText: 'Search by Credit Note or original invoice...',
                    onChanged: (val) => controller.searchQuery.value = val,
                  ),
                ),
                const SizedBox(width: 12),
                Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : AppColors.cardLight,
                      borderRadius: AppRadius.lg,
                      border: Border.all(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: controller.statusFilter.value,
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
                          if (val != null) controller.setStatusFilter(val);
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : AppColors.cardLight,
                      borderRadius: AppRadius.lg,
                      border: Border.all(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: controller.refundFilter.value,
                        items: const [
                          DropdownMenuItem(
                            value: 'all',
                            child: Text('All Types'),
                          ),
                          DropdownMenuItem(
                            value: 'refund_now',
                            child: Text('Refund Now'),
                          ),
                          DropdownMenuItem(
                            value: 'keep_as_credit',
                            child: Text('Store Credit'),
                          ),
                          DropdownMenuItem(
                            value: 'adjust_future_invoice',
                            child: Text('Future Adjust'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) controller.setRefundFilter(val);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Main Content Table
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const LoadingIndicator(
                    message: 'Loading Credit Notes...',
                  );
                }

                if (controller.returns.isEmpty) {
                  return EmptyState(
                    icon: Icons.swap_horiz_outlined,
                    title: 'No Credit Notes Available',
                    description: controller.searchQuery.value.isNotEmpty
                        ? 'No credit notes match your search criteria.'
                        : 'Record a sale return and issue store credit or cash back.',
                    action: AppButton(
                      text: 'Add Credit Note',
                      icon: const Icon(Icons.add, size: 18),
                      onPressed: () => Get.toNamed('/sales/return/create'),
                    ),
                  );
                }

                return Column(
                  children: [
                    Expanded(
                      child: AppCard(
                        padding: EdgeInsets.zero,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(
                                isDark ? AppColors.cardDark : Colors.grey[100],
                              ),
                              columns: const [
                                DataColumn(label: Text('#')),
                                DataColumn(label: Text('Date')),
                                DataColumn(label: Text('Credit Note No')),
                                DataColumn(label: Text('Original Invoice')),
                                DataColumn(label: Text('Customer')),
                                DataColumn(label: Text('Return Type')),
                                DataColumn(label: Text('Total Returned')),
                                DataColumn(label: Text('Refunded')),
                                DataColumn(label: Text('Credit Bal.')),
                                DataColumn(label: Text('Status')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows: controller.returns.asMap().entries.map((
                                entry,
                              ) {
                                final idx = entry.key;
                                final ret = entry.value;

                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Text(
                                        '${((controller.currentPage.value - 1) * controller.itemsPerPage) + idx + 1}',
                                      ),
                                    ),
                                    DataCell(
                                      Text(ret.returnDate.split('T')[0]),
                                    ),
                                    DataCell(
                                      Text(
                                        ret.creditNoteNo,
                                        style: const TextStyle(
                                          fontFamily: 'monospace',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        ret.invoiceNumber,
                                        style: const TextStyle(
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        ret.customerName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        ret.refundType == 'refund_now'
                                            ? 'Refund Now'
                                            : ret.refundType == 'keep_as_credit'
                                            ? 'Store Credit'
                                            : 'Adjust',
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        '₹${ret.grandTotal.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        '₹${ret.refundedAmount.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          color: AppColors.success,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        '₹${ret.creditBalance.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          color: AppColors.warning,
                                          fontWeight: FontWeight.bold,
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
                                          color:
                                              (ret.status == 'refunded'
                                                      ? AppColors.success
                                                      : ret.status ==
                                                            'cancelled'
                                                      ? AppColors.danger
                                                      : AppColors.primary)
                                                  .withValues(alpha: 0.15),
                                          borderRadius: AppRadius.sm,
                                        ),
                                        child: Text(
                                          ret.status.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: ret.status == 'refunded'
                                                ? AppColors.success
                                                : ret.status == 'cancelled'
                                                ? AppColors.danger
                                                : AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.remove_red_eye_outlined,
                                              size: 18,
                                            ),
                                            color: AppColors.primary,
                                            onPressed: () =>
                                                SaleReturnDetailDialog.show(
                                                  context,
                                                  ret,
                                                ),
                                          ),
                                          if (ret.status != 'cancelled')
                                            IconButton(
                                              icon: const Icon(
                                                Icons.block_outlined,
                                                size: 18,
                                              ),
                                              color: AppColors.danger,
                                              onPressed: () =>
                                                  _showCancelConfirm(
                                                    context,
                                                    ret,
                                                  ),
                                            ),
                                        ],
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
                    const SizedBox(height: 12),
                    // Pagination
                    Obx(
                      () => AppPagination(
                        currentPage: controller.currentPage.value,
                        totalPages: controller.totalPages.value,
                        onPageChanged: (page) => controller.goToPage(page),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelConfirm(BuildContext context, SaleReturn ret) {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        title: 'Cancel Credit Note',
        description:
            'Are you sure you want to cancel Credit Note "${ret.creditNoteNo}"? This will reverse stock and ledger adjustments!',
        confirmLabel: 'Cancel Credit Note',
        isDestructive: true,
        onConfirm: () {
          Navigator.of(context).pop();
          controller.cancelReturn(ret.id);
        },
      ),
    );
  }
}
