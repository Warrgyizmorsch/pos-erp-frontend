import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_list_card.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/payment_in_controller.dart';
import '../models/payment_in.dart';
import '../widgets/payment_in_dialog.dart';

class PaymentInListView extends GetView<PaymentInController> {
  const PaymentInListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        title: 'Payment-In Receipts',
        subtitle: 'Track customer payment receipts & deposits',
        actions: [
          IconButton(
            icon: const Icon(Icons.add_card_rounded, size: 24),
            tooltip: 'Add Payment-In',
            onPressed: () => PaymentInDialog.show(context),
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
                  hintText: 'Search by receipt number or customer name...',
                  onChanged: (val) => controller.onSearchChanged(val),
                ),
              ),
              const SizedBox(height: 16),

              // Payments Data List
              Obx(() {
                if (controller.isLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: LoadingIndicator(
                      message: 'Loading payment receipts...',
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
                          ? 'No payment receipts match your search criteria.'
                          : 'Record customer payment collections to track your cash flow.',
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.payments.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final payment = controller.payments[index];

                    return AppListCard(
                      title: payment.receiptNo,
                      subtitle:
                          'Party: ${payment.partyName} • Date: ${payment.date.split("T")[0]}',
                      trailingText:
                          '₹${payment.amountReceived.toStringAsFixed(2)}',
                      statusText: payment.paymentMode.toUpperCase(),
                      statusType: AppStatusChipType.success,
                      leadIcon: Icons.account_balance_wallet_rounded,
                      onTap: () =>
                          PaymentInDialog.show(context, payment: payment),
                      popupMenu: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert_rounded, size: 20),
                        padding: EdgeInsets.zero,
                        onSelected: (val) {
                          if (val == 'edit') {
                            PaymentInDialog.show(context, payment: payment);
                          } else if (val == 'delete') {
                            _showDeleteConfirm(context, payment);
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
                                Text('Edit Receipt'),
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
                                Text('Delete Receipt'),
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
        heroTag: 'payment_in_add_fab',
        onPressed: () => PaymentInDialog.show(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_card_rounded, color: Colors.white),
        label: const Text(
          'Add Payment-In',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, PaymentIn payment) {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        title: 'Delete Payment-In',
        description:
            'This action cannot be undone. Are you sure you want to delete payment receipt "${payment.receiptNo}"?',
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
