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
import '../controllers/sale_return_controller.dart';
import '../models/sale_return.dart';
import '../widgets/sale_return_detail_dialog.dart';

class SaleReturnListView extends GetView<SaleReturnController> {
  const SaleReturnListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        title: 'Sale Returns & Credit Notes',
        subtitle: 'Merchandise returns & store credit management',
        actions: [
          IconButton(
            icon: const Icon(Icons.assignment_return_rounded, size: 24),
            tooltip: 'Add Credit Note',
            onPressed: () => Get.toNamed('/sales/return/create'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.loadReturns(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Metrics Summary Row
              // Obx(
              //   () =>
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;
                  final retStr =
                      '₹${controller.totalReturnedAmount.toStringAsFixed(2)}';
                  final refStr =
                      '₹${controller.totalRefundedAmount.toStringAsFixed(2)}';
                  final credStr =
                      '₹${controller.totalCreditBalance.toStringAsFixed(2)}';

                  if (isMobile) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 150,
                            child: AppStatCard(
                              title: 'Returned',
                              value: retStr,
                              icon: Icons.assignment_return_rounded,
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 150,
                            child: AppStatCard(
                              title: 'Refunded',
                              value: refStr,
                              icon: Icons.price_check_rounded,
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 150,
                            child: AppStatCard(
                              title: 'Store Credit',
                              value: credStr,
                              icon: Icons.account_balance_rounded,
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
                          title: 'Total Returned',
                          value: retStr,
                          icon: Icons.assignment_return_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppStatCard(
                          title: 'Total Refunded',
                          value: refStr,
                          icon: Icons.price_check_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppStatCard(
                          title: 'Store Credit Issued',
                          value: credStr,
                          icon: Icons.account_balance_rounded,
                        ),
                      ),
                    ],
                  );
                },
              ),
              // ),
              const SizedBox(height: 16),

              // Filter Bar
              AppCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    AppSearchField(
                      hintText: 'Search by Credit Note or invoice number...',
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
                                    value: 'issued',
                                    child: Text(
                                      'Issued',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'refunded',
                                    child: Text(
                                      'Refunded',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'adjusted',
                                    child: Text(
                                      'Adjusted',
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
                                value: controller.refundFilter.value,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'all',
                                    child: Text(
                                      'All Types',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'refund_now',
                                    child: Text(
                                      'Refund Now',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'keep_as_credit',
                                    child: Text(
                                      'Store Credit',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'adjust_future_invoice',
                                    child: Text(
                                      'Future Adjust',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    controller.setRefundFilter(val);
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
                    child: LoadingIndicator(message: 'Loading Credit Notes...'),
                  );
                }

                if (controller.returns.isEmpty) {
                  return AppCard(
                    padding: const EdgeInsets.all(24),
                    child: EmptyState(
                      icon: Icons.swap_horiz_outlined,
                      title: 'No Credit Notes Available',
                      description: controller.searchQuery.value.isNotEmpty
                          ? 'No credit notes match your search criteria.'
                          : 'Record a sale return to issue store credit or cash back.',
                    ),
                  );
                }

                return Column(
                  children: [
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.returns.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final ret = controller.returns[index];

                        AppStatusChipType statusType = AppStatusChipType.info;
                        if (ret.status == 'refunded') {
                          statusType = AppStatusChipType.success;
                        } else if (ret.status == 'cancelled') {
                          statusType = AppStatusChipType.danger;
                        }

                        return AppListCard(
                          title: ret.creditNoteNo,
                          subtitle:
                              'Customer: ${ret.customerName} • Invoice: ${ret.invoiceNumber}',
                          trailingText: '₹${ret.grandTotal.toStringAsFixed(2)}',
                          statusText: ret.status.toUpperCase(),
                          statusType: statusType,
                          leadIcon: Icons.assignment_return_rounded,
                          onTap: () =>
                              SaleReturnDetailDialog.show(context, ret),
                          popupMenu: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert_rounded, size: 20),
                            padding: EdgeInsets.zero,
                            onSelected: (val) {
                              if (val == 'view') {
                                SaleReturnDetailDialog.show(context, ret);
                              } else if (val == 'cancel') {
                                _showCancelConfirm(context, ret);
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
                                    Text('View Details'),
                                  ],
                                ),
                              ),
                              if (ret.status != 'cancelled')
                                const PopupMenuItem(
                                  value: 'cancel',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.block_outlined,
                                        size: 18,
                                        color: AppColors.danger,
                                      ),
                                      SizedBox(width: 8),
                                      Text('Cancel Credit Note'),
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
        heroTag: 'sale_return_add_fab',
        onPressed: () => Get.toNamed('/sales/return/create'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.assignment_return_rounded, color: Colors.white),
        label: const Text(
          'Add Credit Note',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
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
