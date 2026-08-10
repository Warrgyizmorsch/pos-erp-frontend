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
import '../controllers/purchase_controller.dart';
import '../models/purchase.dart';

class PurchaseListView extends GetView<PurchaseController> {
  const PurchaseListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        title: 'Purchase Bills',
        subtitle: 'Manage supplier bills, stock intake & vendor ledgers',
        actions: [
          IconButton(
            icon: const Icon(Icons.add_business_rounded, size: 24),
            tooltip: 'Create Purchase Bill',
            onPressed: () {
              controller.initNewForm();
              Get.toNamed('/purchases/create');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.loadPurchases(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter Bar
              AppCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    AppSearchField(
                      hintText: 'Search by purchase bill number or supplier...',
                      onChanged: (val) => controller.searchQuery.value = val,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Obx(
                            () => DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: controller.statusFilter.value,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'all',
                                    child: Text(
                                      'All Status',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'draft',
                                    child: Text(
                                      'Draft',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'confirmed',
                                    child: Text(
                                      'Confirmed',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'received',
                                    child: Text(
                                      'Received',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'cancelled',
                                    child: Text(
                                      'Cancelled',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    controller.setStatusFilter(val);
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Obx(
                            () => DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: controller.paymentFilter.value,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'all',
                                    child: Text(
                                      'All Payment',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'paid',
                                    child: Text(
                                      'Paid',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'pending',
                                    child: Text(
                                      'Pending',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'partial',
                                    child: Text(
                                      'Partial',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    controller.setPaymentFilter(val);
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Data List
              Obx(() {
                if (controller.isLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: LoadingIndicator(
                      message: 'Loading purchase bills...',
                    ),
                  );
                }

                if (controller.purchases.isEmpty) {
                  return AppCard(
                    padding: const EdgeInsets.all(24),
                    child: EmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: 'No Purchases Found',
                      description: controller.searchQuery.value.isNotEmpty
                          ? 'No purchase bills match your search query.'
                          : 'Record your first supplier bill to add inventory stock.',
                    ),
                  );
                }

                return Column(
                  children: [
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.purchases.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final p = controller.purchases[index];

                        AppStatusChipType statusType = AppStatusChipType.info;
                        if (p.paymentStatus == 'paid') {
                          statusType = AppStatusChipType.success;
                        } else if (p.paymentStatus == 'pending') {
                          statusType = AppStatusChipType.warning;
                        }

                        return AppListCard(
                          title: p.purchaseNumber,
                          subtitle:
                              'Supplier: ${p.supplierName} • Date: ${p.purchaseDate.split("T")[0]}',
                          trailingText: '₹${p.totalAmount.toStringAsFixed(2)}',
                          statusText: p.paymentStatus.toUpperCase(),
                          statusType: statusType,
                          leadIcon: Icons.receipt_long_rounded,
                          onTap: () => Get.toNamed('/purchases/${p.id}'),
                          popupMenu: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert_rounded, size: 20),
                            padding: EdgeInsets.zero,
                            onSelected: (val) {
                              if (val == 'view') {
                                Get.toNamed('/purchases/${p.id}');
                              } else if (val == 'edit') {
                                controller.initEditForm(p);
                                Get.toNamed('/purchases/create?id=${p.id}');
                              } else if (val == 'delete') {
                                _showDeleteConfirm(context, p);
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
                                    Text('View Purchase'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.edit_outlined,
                                      size: 18,
                                      color: AppColors.warning,
                                    ),
                                    SizedBox(width: 8),
                                    Text('Edit Purchase'),
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
                                    Text('Delete Purchase'),
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
        heroTag: 'purchase_create_fab',
        onPressed: () {
          controller.initNewForm();
          Get.toNamed('/purchases/create');
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_business_rounded, color: Colors.white),
        label: const Text(
          'Create Purchase',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
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
