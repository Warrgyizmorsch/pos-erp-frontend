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
import '../controllers/supplier_controller.dart';
import '../models/supplier.dart';
import '../widgets/supplier_dialog.dart';

class SupplierListView extends GetView<SupplierController> {
  const SupplierListView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suppliers'),
        backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
        foregroundColor: isDark
            ? AppColors.foregroundDark
            : AppColors.foregroundLight,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: AppButton(
              text: 'Add Supplier',
              icon: const Icon(Icons.add, size: 18),
              height: 36,
              onPressed: () => SupplierDialog.show(context),
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
              'Manage your vendor relationships and payables',
              style: AppTypography.caption(isDark: isDark),
            ),
            const SizedBox(height: 16),

            // Search Bar & Balance Filter Toggle
            Row(
              children: [
                Expanded(
                  child: AppSearchField(
                    hintText: 'Search Suppliers...',
                    onChanged: (val) => controller.onSearchChanged(val),
                  ),
                ),
                const SizedBox(width: 12),
                Obx(
                  () => Tooltip(
                    message: 'Filter by outstanding balance',
                    child: IconButton(
                      icon: Icon(
                        Icons.filter_list,
                        color: controller.filterBalance.value
                            ? AppColors.primary
                            : null,
                      ),
                      onPressed: () => controller.toggleFilterBalance(),
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
                    message: 'Loading suppliers...',
                  );
                }

                if (controller.suppliers.isEmpty) {
                  return EmptyState(
                    icon: Icons.people_outline,
                    title: 'No Suppliers Found',
                    description: controller.searchQuery.value.isNotEmpty
                        ? 'No suppliers match your search criteria.'
                        : 'Add your first supplier to start managing purchases.',
                    action: AppButton(
                      text: 'Add Supplier',
                      icon: const Icon(Icons.add, size: 18),
                      onPressed: () => SupplierDialog.show(context),
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
                                DataColumn(label: Text('Party Name')),
                                DataColumn(label: Text('Contact')),
                                DataColumn(label: Text('Purchases')),
                                DataColumn(label: Text('Balance')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows: controller.suppliers.map((supplier) {
                                final balance = supplier.outstandingBalance != 0
                                    ? supplier.outstandingBalance
                                    : supplier.openingBalance;
                                final isPayable =
                                    balance > 0 ||
                                    supplier.openingBalanceType == 'Payable';

                                return DataRow(
                                  cells: [
                                    // Supplier Info with Avatar
                                    DataCell(
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 18,
                                            backgroundColor: AppColors.primary
                                                .withValues(alpha: 0.1),
                                            child: Text(
                                              supplier.name.isNotEmpty
                                                  ? supplier.name[0]
                                                        .toUpperCase()
                                                  : '?',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                supplier.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text(
                                                supplier.gstNumber != null &&
                                                        supplier
                                                            .gstNumber!
                                                            .isNotEmpty
                                                    ? supplier.gstNumber!
                                                    : 'No GST',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: isDark
                                                      ? AppColors
                                                            .mutedForegroundDark
                                                      : AppColors
                                                            .mutedForegroundLight,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Contact Info
                                    DataCell(
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            supplier.phone ?? '—',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            supplier.email ?? '—',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: isDark
                                                  ? AppColors
                                                        .mutedForegroundDark
                                                  : AppColors
                                                        .mutedForegroundLight,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Purchases Badge
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: AppRadius.sm,
                                        ),
                                        child: Text(
                                          '${supplier.totalPurchases}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Outstanding Balance
                                    DataCell(
                                      Text(
                                        '₹${balance.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isPayable
                                              ? AppColors.danger
                                              : AppColors.success,
                                        ),
                                      ),
                                    ),
                                    // Action Buttons
                                    DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit_outlined,
                                              size: 18,
                                            ),
                                            color: AppColors.primary,
                                            onPressed: () =>
                                                SupplierDialog.show(
                                                  context,
                                                  supplier: supplier,
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
                                              supplier,
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

  void _showDeleteConfirm(BuildContext context, Supplier supplier) {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        title: 'Delete Supplier',
        description:
            'This action cannot be undone. All ledger history for supplier "${supplier.name}" will be permanently removed.',
        confirmLabel: 'Delete',
        isDestructive: true,
        onConfirm: () {
          Navigator.of(context).pop();
          controller.deleteSupplier(supplier.id);
        },
      ),
    );
  }
}
