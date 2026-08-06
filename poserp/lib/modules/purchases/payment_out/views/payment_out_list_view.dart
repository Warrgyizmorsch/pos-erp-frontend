import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_pagination.dart';
import '../../../../core/widgets/app_search_field.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment-Out'),
        backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
        foregroundColor: isDark
            ? AppColors.foregroundDark
            : AppColors.foregroundLight,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: AppButton(
              text: 'Add Payment-Out',
              icon: const Icon(Icons.add, size: 18),
              height: 36,
              onPressed: () {
                controller.resetForm();
                showDialog(
                  context: context,
                  builder: (context) => const PaymentOutFormDialog(),
                );
              },
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
              'Money paid to suppliers and vendor account settlements',
              style: AppTypography.caption(isDark: isDark),
            ),
            const SizedBox(height: 16),

            // Search Bar
            Row(
              children: [
                Expanded(
                  child: AppSearchField(
                    hintText: 'Search by receipt number or supplier name...',
                    onChanged: (val) => controller.searchQuery.value = val,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Main Table
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const LoadingIndicator(
                    message: 'Loading payment-out records...',
                  );
                }

                if (controller.payments.isEmpty) {
                  return EmptyState(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'No Payments Found',
                    description: controller.searchQuery.value.isNotEmpty
                        ? 'No payment-out records match your search query.'
                        : 'Record a supplier payment to see it here.',
                    action: AppButton(
                      text: 'Add Payment-Out',
                      icon: const Icon(Icons.add, size: 18),
                      onPressed: () {
                        controller.resetForm();
                        showDialog(
                          context: context,
                          builder: (context) => const PaymentOutFormDialog(),
                        );
                      },
                    ),
                  );
                }

                return Column(
                  children: [
                    Expanded(
                      child: AppCard(
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
                                DataColumn(label: Text('Supplier')),
                                DataColumn(label: Text('Date')),
                                DataColumn(label: Text('Mode')),
                                DataColumn(label: Text('Amount Paid (₹)')),
                                DataColumn(label: Text('Actions')),
                              ],
                              rows: controller.payments.asMap().entries.map((
                                entry,
                              ) {
                                final idx = entry.key;
                                final p = entry.value;

                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Text(
                                        '${((controller.currentPage.value - 1) * controller.itemsPerPage) + idx + 1}',
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        p.receiptNo,
                                        style: const TextStyle(
                                          fontFamily: 'monospace',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        p.partyName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    DataCell(Text(p.date.split('T')[0])),
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
                                          p.paymentMode.toUpperCase(),
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
                                        '₹${p.amountPaid.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: AppColors.danger,
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
                                            color: AppColors.warning,
                                            onPressed: () {
                                              controller.setEditForm(p);
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    const PaymentOutFormDialog(),
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              size: 18,
                                            ),
                                            color: AppColors.danger,
                                            onPressed: () =>
                                                _showDeleteConfirm(context, p),
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
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Pagination
                    Obx(
                      () => AppPagination(
                        currentPage: controller.currentPage.value,
                        totalPages: controller.totalPages.value,
                        onPageChanged: (page) => controller.goToPage(page),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
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
