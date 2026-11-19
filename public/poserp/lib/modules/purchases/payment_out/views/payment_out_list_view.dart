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
import '../controllers/payment_out_controller.dart';
import '../models/payment_out.dart';
import '../widgets/payment_out_form_dialog.dart';

class PaymentOutListView extends GetView<PaymentOutController> {
  const PaymentOutListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        title: 'Payment-Out Receipts',
        subtitle: 'Track money paid to suppliers & vendor ledgers',
        actions: [
          IconButton(
            icon: const Icon(Icons.outbox_rounded, size: 24),
            tooltip: 'Add Payment-Out',
            onPressed: () {
              controller.resetForm();
              showDialog(
                context: context,
                builder: (context) => const PaymentOutFormDialog(),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.loadPayments(),
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
                  hintText: 'Search by receipt number or supplier name...',
                  onChanged: (val) => controller.searchQuery.value = val,
                ),
              ),
              const SizedBox(height: 16),

              // Payments Data List
              Obx(() {
                if (controller.isLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: LoadingIndicator(
                      message: 'Loading payment-out receipts...',
                    ),
                  );
                }

                if (controller.payments.isEmpty) {
                  return AppCard(
                    padding: const EdgeInsets.all(24),
                    child: EmptyState(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'No Payments Found',
                      description: controller.searchQuery.value.isNotEmpty
                          ? 'No payment-out receipts match your search query.'
                          : 'Record supplier payments to manage account payables.',
                    ),
                  );
                }

                return Column(
                  children: [
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.payments.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final p = controller.payments[index];

                        return AppListCard(
                          title: p.receiptNo,
                          subtitle:
                              'Supplier: ${p.partyName} • Date: ${p.date.split("T")[0]}',
                          trailingText: '₹${p.amountPaid.toStringAsFixed(2)}',
                          statusText: p.paymentMode.toUpperCase(),
                          statusType: AppStatusChipType.danger,
                          leadIcon: Icons.outbox_rounded,
                          onTap: () {
                            controller.setEditForm(p);
                            showDialog(
                              context: context,
                              builder: (context) =>
                                  const PaymentOutFormDialog(),
                            );
                          },
                          popupMenu: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert_rounded, size: 20),
                            padding: EdgeInsets.zero,
                            onSelected: (val) {
                              if (val == 'edit') {
                                controller.setEditForm(p);
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      const PaymentOutFormDialog(),
                                );
                              } else if (val == 'delete') {
                                _showDeleteConfirm(context, p);
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
                                    Text('Edit Payment'),
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
                                    Text('Delete Payment'),
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
        heroTag: 'payment_out_add_fab',
        onPressed: () {
          controller.resetForm();
          showDialog(
            context: context,
            builder: (context) => const PaymentOutFormDialog(),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.outbox_rounded, color: Colors.white),
        label: const Text(
          'Add Payment-Out',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, PaymentOut payment) {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        title: 'Delete Payment-Out',
        description:
            'Are you sure you want to delete payment receipt "${payment.receiptNo}"?',
        confirmLabel: 'Delete',
        isDestructive: true,
        onConfirm: () {
          Navigator.of(context).pop();
          controller.deletePayment(payment.id);
        },
      ),
    );
  }
}
