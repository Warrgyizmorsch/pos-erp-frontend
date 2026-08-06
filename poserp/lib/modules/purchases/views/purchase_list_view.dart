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
import '../controllers/purchase_controller.dart';
import '../models/purchase.dart';

class PurchaseListView extends GetView<PurchaseController> {
  const PurchaseListView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Bills'),
        backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
        foregroundColor: isDark
            ? AppColors.foregroundDark
            : AppColors.foregroundLight,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: AppButton(
              text: 'Create Purchase',
              icon: const Icon(Icons.add, size: 18),
              height: 36,
              onPressed: () {
                controller.initNewForm();
                Get.toNamed('/purchases/create');
              },
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
              'View supplier bills, stock intake, and purchase payment statuses',
              style: AppTypography.caption(isDark: isDark),
            ),
            const SizedBox(height: 16),

            // Filter Bar
            Row(
              children: [
                Expanded(
                  child: AppSearchField(
                    hintText: 'Search by purchase number or supplier name...',
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
                            value: 'draft',
                            child: Text('Draft'),
                          ),
                          DropdownMenuItem(
                            value: 'confirmed',
                            child: Text('Confirmed'),
                          ),
                          DropdownMenuItem(
                            value: 'received',
                            child: Text('Received'),
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
                        value: controller.paymentFilter.value,
                        items: const [
                          DropdownMenuItem(
                            value: 'all',
                            child: Text('All Payment'),
                          ),
                          DropdownMenuItem(value: 'paid', child: Text('Paid')),
                          DropdownMenuItem(
                            value: 'pending',
                            child: Text('Pending'),
                          ),
                          DropdownMenuItem(
                            value: 'partial',
                            child: Text('Partial'),
                          ),
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

            // Main Table
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const LoadingIndicator(
                    message: 'Loading purchase bills...',
                  );
                }

                if (controller.purchases.isEmpty) {
                  return EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'No Purchases Found',
                    description: controller.searchQuery.value.isNotEmpty
                        ? 'No purchase bills match your search criteria.'
                        : 'Record a new purchase bill from a supplier to increase inventory.',
                    action: AppButton(
                      text: 'Create Purchase',
                      icon: const Icon(Icons.add, size: 18),
                      onPressed: () {
                        controller.initNewForm();
                        Get.toNamed('/purchases/create');
                      },
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
                                DataColumn(label: Text('Purchase No')),
                                DataColumn(label: Text('Supplier Name')),
                                DataColumn(label: Text('Date')),
                                DataColumn(label: Text('Amount (₹)')),
                                DataColumn(label: Text('Status')),
                                DataColumn(label: Text('Payment')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows: controller.purchases.asMap().entries.map((
                                entry,
                              ) {
                                final idx = entry.key;
                                final p = entry.value;

                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Text(
                                        '${((controller.currentPage.value - 1) * controller.itemsPerPage) + idx + 1}',
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        p.purchaseNumber,
                                        style: const TextStyle(
                                          fontFamily: 'monospace',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        p.supplierName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(p.purchaseDate.split('T')[0]),
                                    ),
                                    DataCell(
                                      Text(
                                        '₹${p.totalAmount.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
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
                                          p.status.toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
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
                                              (p.paymentStatus == 'paid'
                                                      ? AppColors.success
                                                      : AppColors.warning)
                                                  .withValues(alpha: 0.15),
                                          borderRadius: AppRadius.sm,
                                        ),
                                        child: Text(
                                          p.paymentStatus.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: p.paymentStatus == 'paid'
                                                ? AppColors.success
                                                : AppColors.warning,
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
                                            onPressed: () => Get.toNamed(
                                              '/purchases/${p.id}',
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit_outlined,
                                              size: 18,
                                            ),
                                            color: AppColors.warning,
                                            onPressed: () {
                                              controller.initEditForm(p);
                                              Get.toNamed(
                                                '/purchases/create?id=${p.id}',
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              size: 18,
                                            ),
                                            color: AppColors.danger,
                                            onPressed: () =>
                                                _showDeleteConfirm(context, p),
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

  void _showDeleteConfirm(BuildContext context, Purchase purchase) {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        title: 'Delete Purchase Bill',
        description:
            'This action will permanently delete purchase bill "${purchase.purchaseNumber}". Stock increases will be reversed!',
        confirmLabel: 'Delete',
        isDestructive: true,
        onConfirm: () {
          Navigator.of(context).pop();
          controller.deletePurchase(purchase.id);
        },
      ),
    );
  }
}
