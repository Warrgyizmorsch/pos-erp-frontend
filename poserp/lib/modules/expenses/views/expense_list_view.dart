import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_list_card.dart';
import '../../../../core/widgets/app_pagination.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/app_stat_card.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/expense_controller.dart';
import '../widgets/expense_category_dialog.dart';
import '../widgets/expense_form_dialog.dart';

class ExpenseListView extends GetView<ExpenseController> {
  const ExpenseListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        title: 'Expenses & Income',
        subtitle: 'Operational expenses & non-sales income ledger',
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, size: 24),
            tooltip: 'Add Expense',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) =>
                    const ExpenseFormDialog(initialEntryType: 'expense'),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.loadExpenses(),
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
                      text: 'Categories',
                      variant: AppButtonVariant.outline,
                      icon: const Icon(Icons.category_outlined, size: 16),
                      height: 38,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => const ExpenseCategoryDialog(),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    AppButton(
                      text: 'Add Income',
                      variant: AppButtonVariant.secondary,
                      icon: const Icon(Icons.add_rounded, size: 18),
                      height: 38,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => const ExpenseFormDialog(
                            initialEntryType: 'income',
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    AppButton(
                      text: 'Add Expense',
                      icon: const Icon(Icons.add_rounded, size: 18),
                      height: 38,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => const ExpenseFormDialog(
                            initialEntryType: 'expense',
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Summary Metrics Panel
              Obx(
                () => LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 600;
                    final expStr =
                        '₹${controller.totalExpenses.toStringAsFixed(2)}';
                    final incStr =
                        '₹${controller.totalIncome.toStringAsFixed(2)}';
                    final netStr =
                        '₹${controller.netAmount.toStringAsFixed(2)}';

                    if (isMobile) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 150,
                              child: AppStatCard(
                                title: 'Expenses (-)',
                                value: expStr,
                                icon: Icons.money_off_rounded,
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 150,
                              child: AppStatCard(
                                title: 'Other Income (+)',
                                value: incStr,
                                icon: Icons.attach_money_rounded,
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 150,
                              child: AppStatCard(
                                title: 'Net Position',
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
                            title: 'Total Expenses (-)',
                            value: expStr,
                            icon: Icons.money_off_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppStatCard(
                            title: 'Total Other Income (+)',
                            value: incStr,
                            icon: Icons.attach_money_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppStatCard(
                            title: 'Net Operating Position',
                            value: netStr,
                            icon: Icons.account_balance_wallet_rounded,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Filter Bar
              AppCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    AppSearchField(
                      hintText: 'Search title, receipt number or notes...',
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
                                value: controller.entryTypeFilter.value,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'all',
                                    child: Text(
                                      'All Entries',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'expense',
                                    child: Text(
                                      'Expenses (-)',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'income',
                                    child: Text(
                                      'Income (+)',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    controller.entryTypeFilter.value = val;
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
                                value: controller.categoryFilter.value,
                                items: [
                                  const DropdownMenuItem(
                                    value: 'all',
                                    child: Text(
                                      'All Categories',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  ...controller.categories.map(
                                    (c) => DropdownMenuItem(
                                      value: c.id,
                                      child: Text(
                                        c.name,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    controller.categoryFilter.value = val;
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
                      message: 'Loading expense records...',
                    ),
                  );
                }
                if (controller.expenses.isEmpty) {
                  return AppCard(
                    padding: const EdgeInsets.all(24),
                    child: EmptyState(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'No Expense Entries Found',
                      description: controller.searchQuery.value.isNotEmpty
                          ? 'No entries match your search criteria.'
                          : 'Record operational expenses or non-sales income.',
                    ),
                  );
                }

                return Column(
                  children: [
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.expenses.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = controller.expenses[index];
                        final isExpense = item.entryType == 'expense';

                        return AppListCard(
                          title: item.title,
                          subtitle:
                              'Category: ${item.categoryName} • Mode: ${item.paymentMethod} • ${item.date.split("T")[0]}',
                          trailingText:
                              '${isExpense ? "-" : "+"}₹${item.amount.toStringAsFixed(2)}',
                          statusText: item.entryType.toUpperCase(),
                          statusType: isExpense
                              ? AppStatusChipType.danger
                              : AppStatusChipType.success,
                          leadIcon: isExpense
                              ? Icons.money_off_rounded
                              : Icons.attach_money_rounded,
                          popupMenu: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert_rounded, size: 20),
                            padding: EdgeInsets.zero,
                            onSelected: (val) {
                              if (val == 'delete') {
                                controller.deleteExpense(item.id);
                              }
                            },
                            itemBuilder: (ctx) => [
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
                                    Text('Delete Entry'),
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
        heroTag: 'expense_add_fab',
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) =>
                const ExpenseFormDialog(initialEntryType: 'expense'),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Add Expense',
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
