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
import '../controllers/customer_controller.dart';
import '../models/customer.dart';
import '../widgets/customer_dialog.dart';

class CustomerListView extends GetView<CustomerController> {
  const CustomerListView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
        foregroundColor: isDark
            ? AppColors.foregroundDark
            : AppColors.foregroundLight,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: AppButton(
              text: 'Add Customer',
              icon: const Icon(Icons.add, size: 18),
              height: 36,
              onPressed: () => CustomerDialog.show(context),
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
              'Manage customer contacts, addresses, and balance ledgers',
              style: AppTypography.caption(isDark: isDark),
            ),
            const SizedBox(height: 16),

            // Search Bar
            AppSearchField(
              hintText: 'Search customers by name, phone, email...',
              onChanged: (val) => controller.onSearchChanged(val),
            ),
            const SizedBox(height: 16),

            // Main Content Area
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const LoadingIndicator(
                    message: 'Loading customers...',
                  );
                }

                if (controller.customers.isEmpty) {
                  return EmptyState(
                    icon: Icons.people_outline,
                    title: 'No Customers Found',
                    description: controller.searchQuery.value.isNotEmpty
                        ? 'No customers match your search criteria.'
                        : 'Get started by creating your first customer contact.',
                    action: AppButton(
                      text: 'Add Customer',
                      icon: const Icon(Icons.add, size: 18),
                      onPressed: () => CustomerDialog.show(context),
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
                                DataColumn(label: Text('Customer')),
                                DataColumn(label: Text('Phone')),
                                DataColumn(label: Text('Email')),
                                DataColumn(label: Text('Purchases')),
                                DataColumn(label: Text('Total Spent')),
                                DataColumn(label: Text('Balance')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows: controller.customers.map((customer) {
                                return DataRow(
                                  cells: [
                                    // Customer Info with Avatar
                                    DataCell(
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 16,
                                            backgroundColor: AppColors.primary
                                                .withValues(alpha: 0.1),
                                            child: Text(
                                              customer.name.isNotEmpty
                                                  ? customer.name[0]
                                                        .toUpperCase()
                                                  : '?',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            customer.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    DataCell(Text(customer.phone)),
                                    DataCell(Text(customer.email ?? '—')),
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
                                          '${customer.totalPurchases}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        '₹${customer.totalSpent.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        '₹${customer.walletBalance.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: customer.walletBalance > 0
                                              ? AppColors.success
                                              : (customer.walletBalance < 0
                                                    ? AppColors.danger
                                                    : null),
                                        ),
                                      ),
                                    ),
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
                                                CustomerDialog.show(
                                                  context,
                                                  customer: customer,
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
                                              customer,
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

  void _showDeleteConfirm(BuildContext context, Customer customer) {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        title: 'Delete Customer',
        description:
            'Are you sure you want to delete customer "${customer.name}"? This action cannot be undone.',
        confirmLabel: 'Delete',
        isDestructive: true,
        onConfirm: () {
          Navigator.of(context).pop();
          controller.deleteCustomer(customer.id);
        },
      ),
    );
  }
}
