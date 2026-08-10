import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_list_card.dart';
import '../../../../core/widgets/app_pagination.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/app_stat_card.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/app_top_bar.dart';
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
    return Scaffold(
      appBar: AppTopBar(
        title: 'Sales Invoices',
        subtitle: 'Manage customer invoices & sales transactions',
        actions: [
          IconButton(
            icon: const Icon(Icons.add_shopping_cart_rounded, size: 24),
            tooltip: 'Create Sale (POS)',
            onPressed: () => Get.toNamed('/pos'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.loadSales(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Metrics Row
              Obx(
                () => LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 600;
                    final totalStr =
                        '₹${controller.totalAmount.value.toStringAsFixed(2)}';
                    final paidStr =
                        '₹${controller.amountPaid.value.toStringAsFixed(2)}';
                    final balStr =
                        '₹${controller.balanceAmount.value.toStringAsFixed(2)}';

                    if (isMobile) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 150,
                              child: AppStatCard(
                                title: 'Total Sales',
                                value: totalStr,
                                icon: Icons.receipt_long_rounded,
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 150,
                              child: AppStatCard(
                                title: 'Received',
                                value: paidStr,
                                icon: Icons.check_circle_outline_rounded,
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 150,
                              child: AppStatCard(
                                title: 'Balance Due',
                                value: balStr,
                                icon: Icons.pending_actions_rounded,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Row(
                      children: [
                        Expanded(
                          child: AppStatCard(
                            title: 'Total Sales Amount',
                            value: totalStr,
                            icon: Icons.receipt_long_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppStatCard(
                            title: 'Amount Received',
                            value: paidStr,
                            icon: Icons.check_circle_outline_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppStatCard(
                            title: 'Balance Due',
                            value: balStr,
                            icon: Icons.pending_actions_rounded,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Filter Bar (Search + Payment Method Filter)
              AppCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: AppSearchField(
                        hintText: 'Search by invoice number or customer...',
                        onChanged: (val) => controller.onSearchChanged(val),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Obx(
                      () => DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: controller.paymentFilter.value,
                          items: const [
                            DropdownMenuItem(
                              value: 'all',
                              child: Text(
                                'All Methods',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'cash',
                              child: Text(
                                'Cash',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'card',
                              child: Text(
                                'Card',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'upi',
                              child: Text(
                                'UPI',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) controller.setPaymentFilter(val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Sales Data List
              Obx(() {
                if (controller.isLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: LoadingIndicator(
                      message: 'Loading sales invoices...',
                    ),
                  );
                }

                if (controller.sales.isEmpty) {
                  return AppCard(
                    padding: const EdgeInsets.all(24),
                    child: EmptyState(
                      icon: Icons.shopping_cart_outlined,
                      title: 'No Sales Invoices Found',
                      description: controller.searchQuery.value.isNotEmpty
                          ? 'No invoice records match your search criteria.'
                          : 'Complete your first sale transaction from the POS Terminal.',
                    ),
                  );
                }

                return Column(
                  children: [
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.sales.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final sale = controller.sales[index];

                        return AppListCard(
                          title: sale.invoiceNumber,
                          subtitle: 'Customer: ${sale.customerName}',
                          trailingText:
                              '₹${sale.totalAmount.toStringAsFixed(2)}',
                          statusText: sale.paymentMethod.toUpperCase(),
                          statusType: AppStatusChipType.info,
                          leadIcon: Icons.receipt_rounded,
                          onTap: () => SaleDetailDialog.show(context, sale),
                          popupMenu: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert_rounded, size: 20),
                            padding: EdgeInsets.zero,
                            onSelected: (val) {
                              if (val == 'view') {
                                SaleDetailDialog.show(context, sale);
                              } else if (val == 'delete') {
                                _showDeleteConfirm(context, sale);
                              }
                            },
                            itemBuilder: (ctx) => [
                              const PopupMenuItem(
                                value: 'view',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.remove_red_eye_outlined,
                                      size: 18,
                                      color: AppColors.primary,
                                    ),
                                    SizedBox(width: 8),
                                    Text('View Invoice'),
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
                                    Text('Delete Invoice'),
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
        heroTag: 'sale_create_fab',
        onPressed: () => Get.toNamed('/pos'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_shopping_cart_rounded, color: Colors.white),
        label: const Text(
          'Create Sale',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
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
