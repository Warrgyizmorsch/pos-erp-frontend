import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_search_field.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment-In'),
        backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
        foregroundColor: isDark
            ? AppColors.foregroundDark
            : AppColors.foregroundLight,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: AppButton(
              text: 'Add Payment-In',
              icon: const Icon(Icons.add, size: 18),
              height: 36,
              onPressed: () => PaymentInDialog.show(context),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Track customer payment receipts, ledgers, & account deposits',
              style: AppTypography.caption(isDark: isDark),
            ),
            const SizedBox(height: 16),

            // Search Bar
            AppSearchField(
              hintText: 'Search by receipt number or customer name...',
              onChanged: (val) => controller.onSearchChanged(val),
            ),
            const SizedBox(height: 16),

            // Main Content Area
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const LoadingIndicator(
                    message: 'Loading payment receipts...',
                  );
                }

                if (controller.payments.isEmpty) {
                  return EmptyState(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'No Payments Found',
                    description: controller.searchQuery.value.isNotEmpty
                        ? 'No payment receipts match your search criteria.'
                        : 'Record customer payment collections to track your cash flow.',
                    action: AppButton(
                      text: 'Add Payment-In',
                      icon: const Icon(Icons.add, size: 18),
                      onPressed: () => PaymentInDialog.show(context),
                    ),
                  );
                }

                return AppCard(
                  padding: EdgeInsets.zero,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(
                          isDark ? AppColors.cardDark : Colors.grey[100],
                        ),
                        columns: const [
                          DataColumn(label: Text('#')),
                          DataColumn(label: Text('Receipt No')),
                          DataColumn(label: Text('Party Name')),
                          DataColumn(label: Text('Date')),
                          DataColumn(label: Text('Mode')),
                          DataColumn(label: Text('Amount Received (₹)')),
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: controller.payments.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final payment = entry.value;

                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  '${idx + 1}',
                                  style: TextStyle(
                                    color: isDark
                                        ? AppColors.mutedForegroundDark
                                        : AppColors.mutedForegroundLight,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  payment.receiptNo,
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  payment.partyName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  payment.date.split('T')[0],
                                  style: TextStyle(
                                    color: isDark
                                        ? AppColors.mutedForegroundDark
                                        : AppColors.mutedForegroundLight,
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.15,
                                    ),
                                    borderRadius: AppRadius.sm,
                                  ),
                                  child: Text(
                                    payment.paymentMode.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '₹${payment.amountReceived.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: AppColors.success,
                                  ),
                                ),
                              ),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        size: 18,
                                      ),
                                      color: AppColors.primary,
                                      onPressed: () => PaymentInDialog.show(
                                        context,
                                        payment: payment,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        size: 18,
                                      ),
                                      color: AppColors.danger,
                                      onPressed: () =>
                                          _showDeleteConfirm(context, payment),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
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
