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
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/purchase_return_controller.dart';
import 'purchase_return_detail_view.dart';
import 'purchase_return_form_view.dart';

class PurchaseReturnListView extends GetView<PurchaseReturnController> {
  const PurchaseReturnListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.viewMode.value == 'create') {
        return const PurchaseReturnFormView();
      }

      return Scaffold(
        appBar: AppTopBar(
          title: 'Purchase Returns & Debit Notes',
          subtitle: 'Manage supplier merchandise returns & debit notes',
          actions: [
            IconButton(
              icon: const Icon(Icons.assignment_return_rounded, size: 24),
              tooltip: 'Add Purchase Return',
              onPressed: () => controller.viewMode.value = 'create',
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
                        '₹${controller.listTotalReturns.toStringAsFixed(2)}';
                    final refStr =
                        '₹${controller.listTotalRefunded.toStringAsFixed(2)}';
                    final debStr =
                        '₹${controller.listTotalDebit.toStringAsFixed(2)}';

                    if (isMobile) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 150,
                              child: AppStatCard(
                                title: 'Total Returned',
                                value: retStr,
                                icon: Icons.assignment_return_rounded,
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 150,
                              child: AppStatCard(
                                title: 'Cash Received',
                                value: refStr,
                                icon: Icons.price_check_rounded,
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 150,
                              child: AppStatCard(
                                title: 'Debit Balance',
                                value: debStr,
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
                            title: 'Total Returns Amount',
                            value: retStr,
                            icon: Icons.assignment_return_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppStatCard(
                            title: 'Total Cash Received',
                            value: refStr,
                            icon: Icons.price_check_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppStatCard(
                            title: 'Supplier Debit Balance',
                            value: debStr,
                            icon: Icons.account_balance_rounded,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                // ),
                const SizedBox(height: 16),

                // Control & Filter Bar
                AppCard(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      AppSearchField(
                        hintText: 'Search Debit Note or purchase bill...',
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
                                      controller.statusFilter.value = val;
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
                                        'All Refund Types',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 'refund_received',
                                      child: Text(
                                        'Refund Received',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 'keep_as_debit',
                                      child: Text(
                                        'Supplier Debit',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 'adjust_future_purchase',
                                      child: Text(
                                        'Future Adjust',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) {
                                      controller.refundFilter.value = val;
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
                  if (controller.isLoadingList.value) {
                    return const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: LoadingIndicator(
                        message: 'Loading Debit Notes...',
                      ),
                    );
                  }

                  if (controller.returns.isEmpty) {
                    return AppCard(
                      padding: const EdgeInsets.all(24),
                      child: EmptyState(
                        icon: Icons.receipt_long_outlined,
                        title: 'No Purchase Returns Recorded',
                        description: controller.searchQuery.value.isNotEmpty
                            ? 'No purchase returns match your search criteria.'
                            : 'Record returned stock to suppliers and issue debit notes.',
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
                          final note = controller.returns[index];

                          AppStatusChipType statusType = AppStatusChipType.info;
                          if (note.status == 'refunded') {
                            statusType = AppStatusChipType.success;
                          } else if (note.status == 'cancelled') {
                            statusType = AppStatusChipType.danger;
                          }

                          return AppListCard(
                            title: note.debitNoteNo,
                            subtitle:
                                'Supplier: ${note.supplierName} • Bill: ${note.purchaseNumber}',
                            trailingText:
                                '₹${note.grandTotal.toStringAsFixed(2)}',
                            statusText: note.status.toUpperCase(),
                            statusType: statusType,
                            leadIcon: Icons.assignment_return_rounded,
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) =>
                                    PurchaseReturnDetailDialog(note: note),
                              );
                            },
                            popupMenu: PopupMenuButton<String>(
                              icon: const Icon(
                                Icons.more_vert_rounded,
                                size: 20,
                              ),
                              padding: EdgeInsets.zero,
                              onSelected: (val) {
                                if (val == 'view') {
                                  showDialog(
                                    context: context,
                                    builder: (context) =>
                                        PurchaseReturnDetailDialog(note: note),
                                  );
                                } else if (val == 'cancel') {
                                  controller.cancelReturn(note.id);
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
                                if (note.status != 'cancelled')
                                  const PopupMenuItem(
                                    value: 'cancel',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.block_rounded,
                                          size: 18,
                                          color: AppColors.danger,
                                        ),
                                        SizedBox(width: 8),
                                        Text('Cancel Debit Note'),
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
          heroTag: 'purchase_return_add_fab',
          onPressed: () => controller.viewMode.value = 'create',
          backgroundColor: AppColors.primary,
          icon: const Icon(
            Icons.assignment_return_rounded,
            color: Colors.white,
          ),
          label: const Text(
            'Add Purchase Return',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      );
    });
  }
}
