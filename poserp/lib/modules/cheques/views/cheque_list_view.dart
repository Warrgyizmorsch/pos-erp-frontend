import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_list_card.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/app_stat_card.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/cheque_list_controller.dart';
import '../widgets/cheque_form_dialog.dart';

class ChequeListView extends GetView<ChequeListController> {
  const ChequeListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        title: 'Cheques Register',
        subtitle: 'Received PDC cheques & outgoing cheque clearances',
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, size: 24),
            tooltip: 'Record Cheque',
            onPressed: () => Get.dialog(const ChequeFormDialog()),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.loadCheques(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Metrics Summary Panel
              // Obx(
              //   () =>
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;
                  final pendStr =
                      '₹${controller.totalPendingAmount.toStringAsFixed(2)}';
                  final clrStr =
                      '₹${controller.totalClearedAmount.toStringAsFixed(2)}';
                  final bncStr =
                      '₹${controller.totalBouncedAmount.toStringAsFixed(2)}';

                  if (isMobile) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 150,
                            child: AppStatCard(
                              title: 'Pending Cheques',
                              value: pendStr,
                              icon: Icons.pending_actions_rounded,
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 150,
                            child: AppStatCard(
                              title: 'Cleared Cheques',
                              value: clrStr,
                              icon: Icons.check_circle_outline_rounded,
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 150,
                            child: AppStatCard(
                              title: 'Bounced Cheques',
                              value: bncStr,
                              icon: Icons.error_outline_rounded,
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
                          title: 'Pending Cheques',
                          value: pendStr,
                          icon: Icons.pending_actions_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppStatCard(
                          title: 'Cleared Cheques',
                          value: clrStr,
                          icon: Icons.check_circle_outline_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppStatCard(
                          title: 'Bounced Cheques',
                          value: bncStr,
                          icon: Icons.error_outline_rounded,
                        ),
                      ),
                    ],
                  );
                },
              ),
              // ),
              const SizedBox(height: 16),

              // Filter Toolbar
              AppCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: AppSearchField(
                        hintText: 'Search cheque no, party or bank...',
                        onChanged: (val) => controller.searchQuery.value = val,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Obx(
                      () => DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: controller.statusFilter.value,
                          items: const [
                            DropdownMenuItem(
                              value: 'All',
                              child: Text(
                                'All Status',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'Pending',
                              child: Text(
                                'Pending',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'Cleared',
                              child: Text(
                                'Cleared',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'Bounced',
                              child: Text(
                                'Bounced',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'Cancelled',
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
                      message: 'Loading cheque records...',
                    ),
                  );
                }

                final list = controller.filteredCheques;
                if (list.isEmpty) {
                  return AppCard(
                    padding: const EdgeInsets.all(24),
                    child: EmptyState(
                      icon: Icons.receipt_long_rounded,
                      title: 'No Cheque Records Found',
                      description: controller.searchQuery.value.isNotEmpty
                          ? 'No cheques match your search query.'
                          : 'Record incoming or outgoing cheques to manage clearance.',
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: list.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final c = list[index];

                    AppStatusChipType statusType = AppStatusChipType.info;
                    final s = c.status.toLowerCase();
                    if (s == 'cleared') statusType = AppStatusChipType.success;
                    if (s == 'pending') statusType = AppStatusChipType.warning;
                    if (s == 'bounced' || s == 'cancelled') {
                      statusType = AppStatusChipType.danger;
                    }

                    return AppListCard(
                      title: 'No: ${c.chequeNumber}',
                      subtitle:
                          'Party: ${c.partyName} • Bank: ${c.bankName} • ${c.date.split("T")[0]}',
                      trailingText: '₹${c.amount.toStringAsFixed(2)}',
                      statusText: c.status.toUpperCase(),
                      statusType: statusType,
                      leadIcon: Icons.receipt_long_rounded,
                      onTap: () => Get.dialog(ChequeFormDialog(cheque: c)),
                      popupMenu: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert_rounded, size: 20),
                        padding: EdgeInsets.zero,
                        onSelected: (val) {
                          if (val == 'edit') {
                            Get.dialog(ChequeFormDialog(cheque: c));
                          } else if (val == 'clear') {
                            controller.updateStatus(c, 'Cleared');
                          } else if (val == 'bounce') {
                            controller.updateStatus(c, 'Bounced');
                          } else if (val == 'delete') {
                            controller.deleteCheque(c.id);
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
                                  color: AppColors.warning,
                                ),
                                SizedBox(width: 8),
                                Text('Edit Record'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'clear',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  size: 18,
                                  color: AppColors.success,
                                ),
                                SizedBox(width: 8),
                                Text('Mark as Cleared'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'bounce',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.highlight_off_rounded,
                                  size: 18,
                                  color: AppColors.danger,
                                ),
                                SizedBox(width: 8),
                                Text('Mark as Bounced'),
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
                                Text('Delete Cheque'),
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
        heroTag: 'cheque_record_fab',
        onPressed: () => Get.dialog(const ChequeFormDialog()),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Record Cheque',
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
