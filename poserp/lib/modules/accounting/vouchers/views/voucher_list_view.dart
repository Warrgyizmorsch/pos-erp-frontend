import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_list_card.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/voucher_list_controller.dart';
import '../widgets/voucher_detail_dialog.dart';

class VoucherListView extends GetView<VoucherListController> {
  const VoucherListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        title: 'Accounting Vouchers',
        subtitle: 'Journal, Payment & Receipt double-entry vouchers',
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, size: 24),
            tooltip: 'Create Journal Voucher',
            onPressed: () {
              Get.toNamed('/accounting/journal/create');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.loadVouchers(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter Toolbar
              AppCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    AppSearchField(
                      hintText:
                          'Search voucher number, reference or narration...',
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
                                value: controller.selectedTypeCode.value,
                                items: [
                                  const DropdownMenuItem(
                                    value: 'ALL',
                                    child: Text(
                                      'All Voucher Types',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  ...controller.voucherTypes.map((t) {
                                    return DropdownMenuItem<String>(
                                      value: t.code,
                                      child: Text(
                                        '${t.name} (${t.code})',
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    );
                                  }),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    controller.selectedTypeCode.value = val;
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
                                value: controller.selectedStatus.value,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'ALL',
                                    child: Text(
                                      'All Status',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'POSTED',
                                    child: Text(
                                      'Posted',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'DRAFT',
                                    child: Text(
                                      'Draft',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'CANCELLED',
                                    child: Text(
                                      'Cancelled',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    controller.selectedStatus.value = val;
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

              // Vouchers Data List
              Obx(() {
                if (controller.isLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: LoadingIndicator(
                      message: 'Loading accounting vouchers...',
                    ),
                  );
                }

                if (controller.vouchers.isEmpty) {
                  return AppCard(
                    padding: const EdgeInsets.all(24),
                    child: EmptyState(
                      icon: Icons.receipt_rounded,
                      title: 'No Vouchers Found',
                      description: controller.searchQuery.value.isNotEmpty
                          ? 'No vouchers match your search criteria.'
                          : 'Create a double-entry journal voucher to post financial entries.',
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.vouchers.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final v = controller.vouchers[index];

                    AppStatusChipType statusType = AppStatusChipType.success;
                    if (v.status == 'DRAFT') {
                      statusType = AppStatusChipType.warning;
                    } else if (v.status == 'CANCELLED' ||
                        v.status == 'REVERSED') {
                      statusType = AppStatusChipType.danger;
                    }

                    return AppListCard(
                      title: v.voucherNo.isNotEmpty ? v.voucherNo : 'DRAFT',
                      subtitle:
                          'Type: ${v.voucherTypeCode} • ${v.narration ?? "No narration"} • ${v.date.split("T")[0]}',
                      trailingText: '₹${v.totalAmount.toStringAsFixed(2)}',
                      statusText: v.status,
                      statusType: statusType,
                      leadIcon: Icons.receipt_rounded,
                      onTap: () {
                        Get.dialog(
                          VoucherDetailDialog(
                            voucher: v,
                            onPost: (id) => controller.postDraftVoucher(id),
                            onCancel: (id, reason) =>
                                controller.cancelVoucher(id, reason),
                          ),
                        );
                      },
                      popupMenu: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert_rounded, size: 20),
                        padding: EdgeInsets.zero,
                        onSelected: (val) {
                          if (val == 'view') {
                            Get.dialog(
                              VoucherDetailDialog(
                                voucher: v,
                                onPost: (id) => controller.postDraftVoucher(id),
                                onCancel: (id, reason) =>
                                    controller.cancelVoucher(id, reason),
                              ),
                            );
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
                                Text('View Detail'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'voucher_add_fab',
        onPressed: () {
          Get.toNamed('/accounting/journal/create');
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Create Journal',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
