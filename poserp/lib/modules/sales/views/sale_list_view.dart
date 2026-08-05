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
import '../controllers/sale_controller.dart';
import '../models/sale.dart';
import '../widgets/sale_detail_dialog.dart';

class SaleListView extends GetView<SaleController> {
  const SaleListView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Invoices'),
        backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
        foregroundColor: isDark
            ? AppColors.foregroundDark
            : AppColors.foregroundLight,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: AppButton(
              text: 'Create Sale',
              icon: const Icon(Icons.add, size: 18),
              height: 36,
              onPressed: () => Get.toNamed('/pos'),
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
              'View and manage customer sales invoices & transaction records',
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
                            'Total Sales Amount',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.mutedForegroundDark
                                  : AppColors.mutedForegroundLight,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${controller.totalAmount.value.toStringAsFixed(2)}',
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
                            'Amount Received',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.mutedForegroundDark
                                  : AppColors.mutedForegroundLight,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${controller.amountPaid.value.toStringAsFixed(2)}',
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
                            'Balance Due',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.mutedForegroundDark
                                  : AppColors.mutedForegroundLight,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${controller.balanceAmount.value.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.danger,
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

            // Filter Bar (Search + Payment Method Filter)
            Row(
              children: [
                Expanded(
                  child: AppSearchField(
                    hintText: 'Search by invoice number or customer name...',
                    onChanged: (val) => controller.onSearchChanged(val),
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
                        value: controller.paymentFilter.value,
                        items: const [
                          DropdownMenuItem(
                            value: 'all',
                            child: Text('All Methods'),
                          ),
                          DropdownMenuItem(value: 'cash', child: Text('Cash')),
                          DropdownMenuItem(value: 'card', child: Text('Card')),
                          DropdownMenuItem(value: 'upi', child: Text('UPI')),
                        ],
                        onChanged: (val) {
                          if (val != null) controller.setPaymentFilter(val);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Main Content Area
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const LoadingIndicator(
                    message: 'Loading sales invoices...',
                  );
                }

                if (controller.sales.isEmpty) {
                  return EmptyState(
                    icon: Icons.shopping_cart_outlined,
                    title: 'No Sales Invoices Found',
                    description: controller.searchQuery.value.isNotEmpty
                        ? 'No sales match your search criteria.'
                        : 'Complete your first transaction from the POS Cashier interface.',
                    action: AppButton(
                      text: 'Create Sale',
                      icon: const Icon(Icons.add, size: 18),
                      onPressed: () => Get.toNamed('/pos'),
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
                                DataColumn(label: Text('Invoice No')),
                                DataColumn(label: Text('Customer')),
                                DataColumn(label: Text('Payment')),
                                DataColumn(label: Text('Amount (₹)')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows: controller.sales.asMap().entries.map((
                                entry,
                              ) {
                                final idx = entry.key;
                                final sale = entry.value;

                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Text(
                                        '${((controller.currentPage.value - 1) * controller.itemsPerPage) + idx + 1}',
                                        style: TextStyle(
                                          color: isDark
                                              ? AppColors.mutedForegroundDark
                                              : AppColors.mutedForegroundLight,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        sale.invoiceNumber,
                                        style: const TextStyle(
                                          fontFamily: 'monospace',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        sale.customerName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
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
                                          color: AppColors.primary.withValues(
                                            alpha: 0.15,
                                          ),
                                          borderRadius: AppRadius.sm,
                                        ),
                                        child: Text(
                                          sale.paymentMethod.toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        '₹${sale.totalAmount.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
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
                                                SaleDetailDialog.show(
                                                  context,
                                                  sale,
                                                ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              size: 18,
                                            ),
                                            color: AppColors.danger,
                                            onPressed: () => _showDeleteConfirm(
                                              context,
                                              sale,
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
                    // Pagination Controls
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

  void _showDeleteConfirm(BuildContext context, Sale sale) {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        title: 'Delete Sale Invoice',
        description:
            'This action cannot be undone. Are you sure you want to delete sale invoice "${sale.invoiceNumber}"?',
        confirmLabel: 'Delete',
        isDestructive: true,
        onConfirm: () {
          Navigator.of(context).pop();
          controller.deleteSale(sale.id);
        },
      ),
    );
  }
}
