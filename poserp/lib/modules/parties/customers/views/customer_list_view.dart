import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_list_card.dart';
import '../../../../core/widgets/app_pagination.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/customer_controller.dart';
import '../models/customer.dart';
import '../widgets/customer_dialog.dart';
import 'customer_detail_view.dart';

class CustomerListView extends GetView<CustomerController> {
  const CustomerListView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final horizontalScrollController = ScrollController();

    return Scaffold(
      appBar: AppTopBar(
        title: 'Customers',
        subtitle: 'Manage customer contacts & balance ledgers',
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded, size: 24),
            tooltip: 'Add Customer',
            onPressed: () => CustomerDialog.show(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.loadCustomers(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Input Toolbar
              AppCard(
                padding: const EdgeInsets.all(12),
                child: AppSearchField(
                  hintText: 'Search customers by name, phone, email...',
                  onChanged: (val) => controller.onSearchChanged(val),
                ),
              ),
              const SizedBox(height: 16),

              // Main Customers Responsive Table / List View
              Obx(() {
                if (controller.isLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: LoadingIndicator(message: 'Loading customers...'),
                  );
                }

                if (controller.customers.isEmpty) {
                  return AppCard(
                    padding: const EdgeInsets.all(24),
                    child: EmptyState(
                      icon: Icons.people_outline,
                      title: 'No Customers Found',
                      description: controller.searchQuery.value.isNotEmpty
                          ? 'No customer records match your search query.'
                          : 'Create your first customer contact to manage sales.',
                    ),
                  );
                }

                return Column(
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isDesktop = constraints.maxWidth >= 700;

                        if (isDesktop) {
                          return AppCard(
                            padding: EdgeInsets.zero,
                            child: ClipRRect(
                              borderRadius: AppRadius.lg,
                              child: Scrollbar(
                                controller: horizontalScrollController,
                                thumbVisibility: true,
                                trackVisibility: true,
                                child: SingleChildScrollView(
                                  controller: horizontalScrollController,
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    headingRowColor: WidgetStateProperty.all(
                                      isDark
                                          ? AppColors.inputDark
                                          : Colors.grey[100],
                                    ),
                                    columnSpacing: 24,
                                    columns: const [
                                      DataColumn(
                                        label: Text(
                                          'CUSTOMER',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'PHONE',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'EMAIL',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'PURCHASES',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'TOTAL SPENT',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'BALANCE',
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
                                    rows: controller.customers.map((c) {
                                      final balance = c.walletBalance;

                                      return DataRow(
                                        onSelectChanged: (_) =>
                                            CustomerDetailView.show(context, c),
                                        cells: [
                                          // Customer Avatar & Name
                                          DataCell(
                                            Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 16,
                                                  backgroundColor: AppColors
                                                      .primary
                                                      .withAlpha(25),
                                                  child: Text(
                                                    c.name.isNotEmpty
                                                        ? c.name[0]
                                                              .toUpperCase()
                                                        : 'C',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: AppColors.primary,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Text(
                                                  c.name,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Phone
                                          DataCell(
                                            Text(
                                              c.phone,
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),

                                          // Email
                                          DataCell(
                                            Text(
                                              (c.email != null &&
                                                      c.email!.isNotEmpty)
                                                  ? c.email!
                                                  : '—',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ),

                                          // Purchases Badge
                                          DataCell(
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 3,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: isDark
                                                    ? AppColors.inputDark
                                                    : Colors.grey[200],
                                                borderRadius: AppRadius.full,
                                              ),
                                              child: Text(
                                                '${c.totalPurchases}',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Total Spent
                                          DataCell(
                                            Text(
                                              '₹${c.totalSpent.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),

                                          // Balance
                                          DataCell(
                                            Text(
                                              '₹${balance.abs().toStringAsFixed(2)}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: balance > 0
                                                    ? Colors.green
                                                    : (balance < 0
                                                          ? Colors.red
                                                          : Colors.grey),
                                              ),
                                            ),
                                          ),

                                          // Actions (Edit & Delete Buttons)
                                          DataCell(
                                            Row(
                                              children: [
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.edit_outlined,
                                                    size: 18,
                                                    color: AppColors.primary,
                                                  ),
                                                  onPressed: () =>
                                                      CustomerDialog.show(
                                                        context,
                                                        customer: c,
                                                      ),
                                                ),
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.delete_outline,
                                                    size: 18,
                                                    color: AppColors.danger,
                                                  ),
                                                  onPressed: () =>
                                                      _showDeleteConfirm(
                                                        context,
                                                        c,
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
                          );
                        }

                        // Mobile View: AppListCards
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.customers.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final customer = controller.customers[index];
                            final balance = customer.walletBalance;

                            AppStatusChipType statusType =
                                AppStatusChipType.info;
                            String statusLabel = 'CLEAR';

                            if (balance > 0) {
                              statusType = AppStatusChipType.success;
                              statusLabel =
                                  'RECEIVABLE (₹${balance.toStringAsFixed(2)})';
                            } else if (balance < 0) {
                              statusType = AppStatusChipType.danger;
                              statusLabel =
                                  'ADVANCE (₹${balance.abs().toStringAsFixed(2)})';
                            }

                            return AppListCard(
                              title: customer.name,
                              subtitle:
                                  'Phone: ${customer.phone} • Orders: ${customer.totalPurchases}',
                              trailingText:
                                  '₹${customer.totalSpent.toStringAsFixed(2)}',
                              statusText: statusLabel,
                              statusType: statusType,
                              leadIcon: Icons.person_rounded,
                              onTap: () =>
                                  CustomerDetailView.show(context, customer),
                              popupMenu: PopupMenuButton<String>(
                                icon: const Icon(
                                  Icons.more_vert_rounded,
                                  size: 20,
                                ),
                                padding: EdgeInsets.zero,
                                onSelected: (val) {
                                  if (val == 'edit') {
                                    CustomerDialog.show(
                                      context,
                                      customer: customer,
                                    );
                                  } else if (val == 'delete') {
                                    _showDeleteConfirm(context, customer);
                                  }
                                },
                                itemBuilder: (ctx) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.edit_outlined,
                                          size: 18,
                                          color: AppColors.primary,
                                        ),
                                        SizedBox(width: 8),
                                        Text('Edit Customer'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete_outline,
                                          size: 18,
                                          color: AppColors.danger,
                                        ),
                                        SizedBox(width: 8),
                                        Text('Delete Customer'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    AppPagination(
                      currentPage: controller.currentPage.value,
                      totalPages: controller.totalPages.value,
                      onPageChanged: (page) => controller.goToPage(page),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'customer_add_fab',
        onPressed: () => CustomerDialog.show(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
        label: const Text(
          'Add Customer',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
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
