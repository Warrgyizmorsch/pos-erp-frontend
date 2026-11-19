import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_list_card.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/app_stat_card.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/app_top_bar.dart';
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
      appBar: AppTopBar(
        title: 'Cash & Bank Management',
        subtitle: 'Cash drawer, bank accounts & fund transfers',
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz_rounded, size: 24),
            tooltip: 'Fund Transfer',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const BankTransferDialog(),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.loadDashboardData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Action Buttons Row (Mobile Scrollable)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    AppButton(
                      text: 'Cash Entry',
                      variant: AppButtonVariant.outline,
                      icon: const Icon(Icons.payments_outlined, size: 16),
                      height: 38,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => const CashEntryDialog(),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    AppButton(
                      text: 'Fund Transfer',
                      variant: AppButtonVariant.secondary,
                      icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                      height: 38,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => const BankTransferDialog(),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    AppButton(
                      text: 'Add Bank Account',
                      icon: const Icon(Icons.add_rounded, size: 18),
                      height: 38,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => const BankAccountDialog(),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Summary Metrics Panel
              Obx(() {
                final s = controller.summary.value;
                final cashBal = s?.cashBalance ?? 0.0;
                final bankBal = s?.totalBankBalance ?? 0.0;
                final net = s?.netBalance ?? (cashBal + bankBal);

                final cashStr = '₹${cashBal.toStringAsFixed(2)}';
                final bankStr = '₹${bankBal.toStringAsFixed(2)}';
                final netStr = '₹${net.toStringAsFixed(2)}';

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 600;

                    if (isMobile) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 150,
                              child: AppStatCard(
                                title: 'Cash Drawer',
                                value: cashStr,
                                icon: Icons.payments_rounded,
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 150,
                              child: AppStatCard(
                                title: 'Bank Accounts',
                                value: bankStr,
                                icon: Icons.account_balance_rounded,
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 150,
                              child: AppStatCard(
                                title: 'Total Liquidity',
                                value: netStr,
                                icon: Icons.account_balance_wallet_rounded,
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
                            title: 'Cash Drawer Balance',
                            value: cashStr,
                            icon: Icons.payments_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppStatCard(
                            title: 'Total Bank Balance',
                            value: bankStr,
                            icon: Icons.account_balance_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppStatCard(
                            title: 'Total Liquidity Position',
                            value: netStr,
                            icon: Icons.account_balance_wallet_rounded,
                          ),
                        ),
                      ],
                    );
                  },
                );
              }),
              const SizedBox(height: 16),

              // Bank Accounts Horizontal Cards
              Obx(() {
                if (controller.isLoadingAccounts.value) {
                  return const SizedBox(height: 80, child: LoadingIndicator());
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
                        width: 240,
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
                                InkWell(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => BankAccountDialog(
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
                                fontSize: 14,
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
              AppCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: AppSearchField(
                        hintText: 'Search reference number or notes...',
                        onChanged: (val) => controller.searchQuery.value = val,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Obx(
                      () => DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: controller.typeFilter.value,
                          items: const [
                            DropdownMenuItem(
                              value: 'all',
                              child: Text(
                                'All Types',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'deposit',
                              child: Text(
                                'Deposit',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'withdrawal',
                              child: Text(
                                'Withdrawal',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'transfer',
                              child: Text(
                                'Transfer',
                                style: TextStyle(fontSize: 12),
                              ),
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
              ),
              const SizedBox(height: 16),

              // Transactions Data List
              Obx(() {
                if (controller.isLoadingTransactions.value) {
                  return const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: LoadingIndicator(
                      message: 'Loading financial transactions...',
                    ),
                  );
                }
                if (controller.transactions.isEmpty) {
                  return AppCard(
                    padding: const EdgeInsets.all(24),
                    child: EmptyState(
                      icon: Icons.account_balance_rounded,
                      title: 'No Transactions Found',
                      description:
                          'Record bank transfers, deposits, or drawer cash entries.',
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.transactions.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = controller.transactions[index];

                    return AppListCard(
                      title: item.type.toUpperCase(),
                      subtitle:
                          'From: ${item.fromAccount ?? "Cash"} • To: ${item.toAccount ?? "Bank"} • ${item.date.split("T")[0]}',
                      trailingText: '₹${item.amount.toStringAsFixed(2)}',
                      statusText: item.status.toUpperCase(),
                      statusType: AppStatusChipType.success,
                      leadIcon: Icons.swap_horiz_rounded,
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'cash_bank_transfer_fab',
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const BankTransferDialog(),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.swap_horiz_rounded, color: Colors.white),
        label: const Text(
          'Fund Transfer',
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
