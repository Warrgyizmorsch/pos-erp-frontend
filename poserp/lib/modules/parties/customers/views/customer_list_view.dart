import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
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

class CustomerListView extends GetView<CustomerController> {
  const CustomerListView({super.key});

  @override
  Widget build(BuildContext context) {
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
              // Search Input
              AppCard(
                padding: const EdgeInsets.all(12),
                child: AppSearchField(
                  hintText: 'Search customers by name, phone, email...',
                  onChanged: (val) => controller.onSearchChanged(val),
                ),
              ),
              const SizedBox(height: 16),

              // Main Customers List
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
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.customers.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final customer = controller.customers[index];
                        final balance = customer.walletBalance;

                        AppStatusChipType statusType = AppStatusChipType.info;
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
                              CustomerDialog.show(context, customer: customer),
                          popupMenu: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert_rounded, size: 20),
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
