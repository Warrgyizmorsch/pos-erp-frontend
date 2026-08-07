import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/cash_bank_controller.dart';
import '../widgets/bank_account_dialog.dart';
import '../widgets/bank_transfer_dialog.dart';
import '../widgets/cash_entry_dialog.dart';

class CashBankListView extends GetView<CashBankController> {
  const CashBankListView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(25),
                          borderRadius: AppRadius.lg,
                        ),
                        child: const Icon(
                          Icons.account_balance_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Cash & Bank Management',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Track cash drawer balances, bank accounts, fund transfers, and transactional ledgers.',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      AppButton(
                        text: 'Cash Entry',
                        variant: AppButtonVariant.outline,
                        icon: const Icon(Icons.payments_outlined, size: 16),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => const CashEntryDialog(),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      AppButton(
                        text: 'Fund Transfer',
                        variant: AppButtonVariant.secondary,
                        icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => const BankTransferDialog(),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      AppButton(
                        text: 'Add Bank Account',
                        icon: const Icon(Icons.add_rounded, size: 18),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => const BankAccountDialog(),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Summary Metrics Panel
              Obx(() {
                final s = controller.summary.value;
                final cashBal = s?.cashBalance ?? 0.0;
                final bankBal = s?.totalBankBalance ?? 0.0;
                final net = s?.netBalance ?? (cashBal + bankBal);

                return Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        context,
                        title: 'CASH DRAWER BALANCE',
                        value: cashBal,
                        subtitle: 'Physical cash in drawer',
                        accentColor: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildMetricCard(
                        context,
                        title: 'TOTAL BANK BALANCE',
                        value: bankBal,
                        subtitle:
                            '${controller.bankAccounts.length} Active Accounts',
                        accentColor: AppColors.info,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildMetricCard(
                        context,
                        title: 'TOTAL LIQUIDITY POSITION',
                        value: net,
                        subtitle: 'Combined Cash + Bank assets',
                        accentColor: AppColors.success,
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 16),

              // Bank Accounts Carousel / Horizontal Grid
              Obx(() {
                if (controller.isLoadingAccounts.value) {
                  return const SizedBox(height: 90, child: LoadingIndicator());
                }
                if (controller.bankAccounts.isEmpty) {
                  return const SizedBox.shrink();
                }

                return SizedBox(
                  height: 96,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.bankAccounts.length,
                    separatorBuilder: (ctx, i) => const SizedBox(width: 12),
                    itemBuilder: (context, idx) {
                      final acc = controller.bankAccounts[idx];
                      return Container(
                        width: 260,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.cardDark
                              : AppColors.cardLight,
                          border: Border.all(
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight,
                          ),
                          borderRadius: AppRadius.md,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    acc.accountName,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) =>
                                              BankAccountDialog(
                                                initialAccount: acc,
                                              ),
                                        );
                                      },
                                      child: const Icon(
                                        Icons.edit_outlined,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    InkWell(
                                      onTap: () =>
                                          controller.deleteBankAccount(acc.id),
                                      child: const Icon(
                                        Icons.delete_outline_rounded,
                                        size: 16,
                                        color: AppColors.danger,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Text(
                              'A/C: ${acc.accountNumber}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontFamily: 'monospace',
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '₹${acc.currentBalance.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }),
              const SizedBox(height: 16),

              // Filter Bar
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      onChanged: (val) => controller.searchQuery.value = val,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Search by reference number or notes...',
                        prefixIcon: const Icon(Icons.search, size: 18),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
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
                    ),
                  ),
                  const SizedBox(width: 14),
                  Obx(
                    () => SizedBox(
                      width: 170,
                      child: DropdownButtonFormField<String>(
                        initialValue: controller.typeFilter.value,
                        dropdownColor: isDark
                            ? AppColors.cardDark
                            : AppColors.cardLight,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
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
                            value: 'all',
                            child: Text('All Types'),
                          ),
                          DropdownMenuItem(
                            value: 'deposit',
                            child: Text('Deposit'),
                          ),
                          DropdownMenuItem(
                            value: 'withdrawal',
                            child: Text('Withdrawal'),
                          ),
                          DropdownMenuItem(
                            value: 'transfer',
                            child: Text('Transfer'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            controller.typeFilter.value = val;
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Data Table
              Expanded(
                child: Obx(() {
                  if (controller.isLoadingTransactions.value) {
                    return const LoadingIndicator();
                  }
                  if (controller.transactions.isEmpty) {
                    return EmptyState(
                      icon: Icons.account_balance_rounded,
                      title: 'No Cash & Bank Transactions Found',
                      description:
                          'Track transfers, deposits, and cash drawer settlements.',
                      action: AppButton(
                        text: 'Record Transfer',
                        icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => const BankTransferDialog(),
                          );
                        },
                      ),
                    );
                  }

                  return AppCard(
                    padding: EdgeInsets.zero,
                    child: ClipRRect(
                      borderRadius: AppRadius.lg,
                      child: Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: DataTable(
                                columnSpacing: 20,
                                headingRowColor: WidgetStateProperty.all(
                                  isDark
                                      ? AppColors.inputDark
                                      : Colors.grey[100],
                                ),
                                columns: const [
                                  DataColumn(
                                    label: Text(
                                      '#',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'DATE',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'TYPE',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'FROM ACCOUNT',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'TO ACCOUNT',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    numeric: true,
                                    label: Text(
                                      'AMOUNT',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'STATUS',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                                rows: List.generate(
                                  controller.transactions.length,
                                  (idx) {
                                    final item = controller.transactions[idx];
                                    final dateStr = item.date.split('T')[0];

                                    return DataRow(
                                      cells: [
                                        DataCell(
                                          Text(
                                            '${idx + 1 + (controller.currentPage.value - 1) * controller.itemsPerPage}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            dateStr,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontFamily: 'monospace',
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary
                                                  .withAlpha(25),
                                              borderRadius: AppRadius.full,
                                            ),
                                            child: Text(
                                              item.type.toUpperCase(),
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            item.fromAccount ?? 'Cash',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            item.toAccount ?? 'Bank Account',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            '₹${item.amount.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'monospace',
                                              color: AppColors.success,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            item.status.toUpperCase(),
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.success,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),

                          // Pagination Footer
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: isDark
                                      ? AppColors.borderDark
                                      : AppColors.borderLight,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Page ${controller.currentPage.value} of ${controller.totalPages.value}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Row(
                                  children: [
                                    AppButton(
                                      text: 'Previous',
                                      variant: AppButtonVariant.outline,
                                      onPressed:
                                          controller.currentPage.value > 1
                                          ? () => controller.goToPage(
                                              controller.currentPage.value - 1,
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 8),
                                    AppButton(
                                      text: 'Next',
                                      variant: AppButtonVariant.outline,
                                      onPressed:
                                          controller.currentPage.value <
                                              controller.totalPages.value
                                          ? () => controller.goToPage(
                                              controller.currentPage.value + 1,
                                            )
                                          : null,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required double value,
    required String subtitle,
    required Color accentColor,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              Container(
                width: 4,
                height: 14,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: AppRadius.full,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '₹${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: accentColor,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
