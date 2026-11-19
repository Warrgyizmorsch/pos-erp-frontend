import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_list_card.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/voucher_list_controller.dart';

class VoucherListView extends GetView<VoucherListController> {
  const VoucherListView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppTopBar(
        title: 'Accounting Vouchers',
        subtitle:
            'Accounting vouchers with filtering, posting, cancellation, reversal, and details view.',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 22),
            tooltip: 'Refresh Vouchers',
            onPressed: () => controller.loadVouchers(),
          ),
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
              // 1. Filter Toolbar Card
              AppCard(
                padding: const EdgeInsets.all(12),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 700;

                    final searchField = AppSearchField(
                      hintText:
                          'Search voucher number, reference, narration...',
                      onChanged: (val) => controller.searchQuery.value = val,
                    );

                    final typeDropdown = Obx(
                      () => DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: controller.selectedTypeCode.value,
                        dropdownColor: isDark
                            ? AppColors.cardDark
                            : AppColors.cardLight,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          filled: true,
                          fillColor: isDark
                              ? AppColors.inputDark
                              : Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: AppRadius.md,
                            borderSide: BorderSide(
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.borderLight,
                            ),
                          ),
                        ),
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
                    );

                    final statusDropdown = Obx(
                      () => DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: controller.selectedStatus.value,
                        dropdownColor: isDark
                            ? AppColors.cardDark
                            : AppColors.cardLight,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          filled: true,
                          fillColor: isDark
                              ? AppColors.inputDark
                              : Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: AppRadius.md,
                            borderSide: BorderSide(
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.borderLight,
                            ),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'ALL',
                            child: Text(
                              'All Status',
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
                            value: 'POSTED',
                            child: Text(
                              'Posted',
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
                          DropdownMenuItem(
                            value: 'REVERSED',
                            child: Text(
                              'Reversed',
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
                    );

                    final moduleInput = TextField(
                      onChanged: (val) =>
                          controller.referenceModule.value = val,
                      style: const TextStyle(fontSize: 12),
                      decoration: InputDecoration(
                        hintText: 'Reference module...',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        filled: true,
                        fillColor: isDark
                            ? AppColors.inputDark
                            : Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.md,
                          borderSide: BorderSide(
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight,
                          ),
                        ),
                      ),
                    );

                    final startDateInput = TextField(
                      readOnly: true,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          controller.startDate.value = picked
                              .toIso8601String()
                              .split('T')[0];
                        }
                      },
                      controller: TextEditingController(
                        text: controller.startDate.value,
                      ),
                      style: const TextStyle(fontSize: 12),
                      decoration: InputDecoration(
                        hintText: 'Start Date',
                        suffixIcon: const Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        filled: true,
                        fillColor: isDark
                            ? AppColors.inputDark
                            : Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.md,
                          borderSide: BorderSide(
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight,
                          ),
                        ),
                      ),
                    );

                    final endDateInput = TextField(
                      readOnly: true,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          controller.endDate.value = picked
                              .toIso8601String()
                              .split('T')[0];
                        }
                      },
                      controller: TextEditingController(
                        text: controller.endDate.value,
                      ),
                      style: const TextStyle(fontSize: 12),
                      decoration: InputDecoration(
                        hintText: 'End Date',
                        suffixIcon: const Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        filled: true,
                        fillColor: isDark
                            ? AppColors.inputDark
                            : Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.md,
                          borderSide: BorderSide(
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight,
                          ),
                        ),
                      ),
                    );

                    if (isMobile) {
                      return Column(
                        children: [
                          searchField,
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(child: typeDropdown),
                              const SizedBox(width: 8),
                              Expanded(child: statusDropdown),
                            ],
                          ),
                          const SizedBox(height: 8),
                          moduleInput,
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(child: startDateInput),
                              const SizedBox(width: 8),
                              Expanded(child: endDateInput),
                            ],
                          ),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(flex: 3, child: searchField),
                            const SizedBox(width: 10),
                            Expanded(flex: 2, child: typeDropdown),
                            const SizedBox(width: 10),
                            Expanded(flex: 2, child: statusDropdown),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(child: moduleInput),
                            const SizedBox(width: 10),
                            Expanded(child: startDateInput),
                            const SizedBox(width: 10),
                            Expanded(child: endDateInput),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // 2. Adaptive Data List / Table
              Obx(() {
                if (controller.isLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: LoadingIndicator(
                      message: 'Loading accounting vouchers...',
                    ),
                  );
                }

                final vouchers = controller.vouchers;
                if (vouchers.isEmpty) {
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

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth >= 800;

                    if (isDesktop) {
                      return AppCard(
                        padding: EdgeInsets.zero,
                        child: ClipRRect(
                          borderRadius: AppRadius.lg,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(minWidth: 900),
                              child: DataTable(
                                columnSpacing: 16,
                                headingRowColor: WidgetStateProperty.all(
                                  isDark
                                      ? AppColors.inputDark
                                      : Colors.grey[100],
                                ),
                                columns: const [
                                  DataColumn(label: Text('DATE')),
                                  DataColumn(label: Text('VOUCHER NO')),
                                  DataColumn(label: Text('TYPE')),
                                  DataColumn(label: Text('REF MODULE')),
                                  DataColumn(label: Text('REF NO')),
                                  DataColumn(label: Text('NARRATION')),
                                  DataColumn(
                                    numeric: true,
                                    label: Text('TOTAL DEBIT (₹)'),
                                  ),
                                  DataColumn(
                                    numeric: true,
                                    label: Text('TOTAL CREDIT (₹)'),
                                  ),
                                  DataColumn(label: Text('STATUS')),
                                  DataColumn(label: Text('ACTIONS')),
                                ],
                                rows: vouchers.map((v) {
                                  AppStatusChipType statusType =
                                      AppStatusChipType.success;
                                  if (v.status == 'DRAFT') {
                                    statusType = AppStatusChipType.warning;
                                  } else if (v.status == 'CANCELLED' ||
                                      v.status == 'REVERSED') {
                                    statusType = AppStatusChipType.danger;
                                  }

                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Text(
                                          v.date.split('T')[0],
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          v.voucherNo.isNotEmpty
                                              ? v.voucherNo
                                              : 'DRAFT',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          v.voucherTypeCode,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          v.referenceModule ?? '-',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          v.referenceNo ?? '-',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: 180,
                                          child: Text(
                                            v.narration ?? '-',
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          '₹${v.totalDebit.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          '₹${v.totalCredit.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        AppStatusChip(
                                          label: v.status,
                                          type: statusType,
                                        ),
                                      ),
                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Obx(() {
                                              final isViewing =
                                                  controller
                                                      .actionLoading
                                                      .value ==
                                                  'view-${v.id}';
                                              return IconButton(
                                                icon: isViewing
                                                    ? const SizedBox(
                                                        width: 14,
                                                        height: 14,
                                                        child:
                                                            CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                            ),
                                                      )
                                                    : const Icon(
                                                        Icons
                                                            .remove_red_eye_outlined,
                                                        size: 18,
                                                        color:
                                                            AppColors.primary,
                                                      ),
                                                tooltip: 'View Detail',
                                                onPressed: isViewing
                                                    ? null
                                                    : () => controller
                                                          .viewVoucher(
                                                            v.id,
                                                            fallback: v,
                                                          ),
                                              );
                                            }),
                                            if (v.status == 'DRAFT')
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.check_circle_outline,
                                                  size: 18,
                                                  color: AppColors.success,
                                                ),
                                                tooltip: 'Post Voucher',
                                                onPressed: () => _confirmPost(
                                                  v.id,
                                                  v.voucherNo,
                                                ),
                                              ),
                                            if (v.canCancelOrReverse) ...[
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.cancel_outlined,
                                                  size: 18,
                                                  color: AppColors.danger,
                                                ),
                                                tooltip: 'Cancel Voucher',
                                                onPressed: () =>
                                                    _promptReasonDialog(
                                                      title: 'Cancel Voucher',
                                                      confirmText:
                                                          'Cancel Voucher',
                                                      onConfirm: (reason) =>
                                                          controller
                                                              .cancelVoucher(
                                                                v.id,
                                                                reason,
                                                              ),
                                                    ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.replay_rounded,
                                                  size: 18,
                                                  color: AppColors.warning,
                                                ),
                                                tooltip: 'Reverse Voucher',
                                                onPressed: () =>
                                                    _promptReasonDialog(
                                                      title: 'Reverse Voucher',
                                                      confirmText:
                                                          'Reverse Voucher',
                                                      onConfirm: (reason) =>
                                                          controller
                                                              .reverseVoucher(
                                                                v.id,
                                                                reason,
                                                              ),
                                                    ),
                                              ),
                                            ],
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

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: vouchers.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final v = vouchers[index];

                        AppStatusChipType statusType =
                            AppStatusChipType.success;
                        if (v.status == 'DRAFT') {
                          statusType = AppStatusChipType.warning;
                        } else if (v.status == 'CANCELLED' ||
                            v.status == 'REVERSED') {
                          statusType = AppStatusChipType.danger;
                        }

                        return AppListCard(
                          title: v.voucherNo.isNotEmpty
                              ? v.voucherNo
                              : 'DRAFT VOUCHER',
                          subtitle:
                              '${v.voucherTypeCode} • ${v.narration ?? "No narration"} • ${v.date.split("T")[0]}',
                          trailingText: '₹${v.totalAmount.toStringAsFixed(2)}',
                          statusText: v.status,
                          statusType: statusType,
                          leadIcon: Icons.receipt_rounded,
                          onTap: () =>
                              controller.viewVoucher(v.id, fallback: v),
                          popupMenu: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert_rounded, size: 20),
                            padding: EdgeInsets.zero,
                            onSelected: (val) {
                              if (val == 'view') {
                                controller.viewVoucher(v.id, fallback: v);
                              } else if (val == 'post') {
                                _confirmPost(v.id, v.voucherNo);
                              } else if (val == 'cancel') {
                                _promptReasonDialog(
                                  title: 'Cancel Voucher',
                                  confirmText: 'Cancel Voucher',
                                  onConfirm: (reason) =>
                                      controller.cancelVoucher(v.id, reason),
                                );
                              } else if (val == 'reverse') {
                                _promptReasonDialog(
                                  title: 'Reverse Voucher',
                                  confirmText: 'Reverse Voucher',
                                  onConfirm: (reason) =>
                                      controller.reverseVoucher(v.id, reason),
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
                              if (v.status == 'DRAFT')
                                const PopupMenuItem(
                                  value: 'post',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle_outline,
                                        size: 18,
                                        color: AppColors.success,
                                      ),
                                      SizedBox(width: 8),
                                      Text('Post Voucher'),
                                    ],
                                  ),
                                ),
                              if (v.canCancelOrReverse) ...[
                                const PopupMenuItem(
                                  value: 'cancel',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.cancel_outlined,
                                        size: 18,
                                        color: AppColors.danger,
                                      ),
                                      SizedBox(width: 8),
                                      Text('Cancel Voucher'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'reverse',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.replay_rounded,
                                        size: 18,
                                        color: AppColors.warning,
                                      ),
                                      SizedBox(width: 8),
                                      Text('Reverse Voucher'),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
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

  void _confirmPost(String id, String voucherNo) {
    Get.dialog(
      AlertDialog(
        title: const Text('Post Voucher'),
        content: Text(
          'Are you sure you want to post voucher ${voucherNo.isNotEmpty ? voucherNo : id}?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          AppButton(
            text: 'Post Voucher',
            onPressed: () {
              Get.back();
              controller.postDraftVoucher(id);
            },
          ),
        ],
      ),
    );
  }

  void _promptReasonDialog({
    required String title,
    required String confirmText,
    required Function(String reason) onConfirm,
  }) {
    final reasonCtrl = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please specify a reason for this operation:'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              decoration: const InputDecoration(
                hintText: 'Enter reason...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          AppButton(
            text: confirmText,
            onPressed: () {
              final reason = reasonCtrl.text.trim();
              Get.back();
              onConfirm(reason.isNotEmpty ? reason : 'Manual user action');
            },
          ),
        ],
      ),
    );
  }
}
