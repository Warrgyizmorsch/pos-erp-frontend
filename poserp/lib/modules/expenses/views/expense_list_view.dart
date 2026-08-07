import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/expense_controller.dart';
import '../widgets/expense_category_dialog.dart';
import '../widgets/expense_form_dialog.dart';

class ExpenseListView extends GetView<ExpenseController> {
  const ExpenseListView({super.key});

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
                          Icons.account_balance_wallet_outlined,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Expenses & Income Manager',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Track business operational expenses, non-sales income, and cash outflow records.',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      AppButton(
                        text: 'Categories',
                        variant: AppButtonVariant.outline,
                        icon: const Icon(Icons.category_outlined, size: 16),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => const ExpenseCategoryDialog(),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      AppButton(
                        text: 'Add Income',
                        variant: AppButtonVariant.secondary,
                        icon: const Icon(Icons.add_rounded, size: 18),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => const ExpenseFormDialog(
                              initialEntryType: 'income',
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      AppButton(
                        text: 'Add Expense',
                        icon: const Icon(Icons.add_rounded, size: 18),
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
                ],
              ),
              const SizedBox(height: 20),

              // Summary Metrics Panel
              Obx(
                () => Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        context,
                        title: 'TOTAL EXPENSES',
                        value: controller.totalExpenses,
                        subtitle: 'Operational cash outflow',
                        accentColor: AppColors.danger,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMetricCard(
                        context,
                        title: 'TOTAL OTHER INCOME',
                        value: controller.totalIncome,
                        subtitle: 'Non-sales cash inflow',
                        accentColor: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMetricCard(
                        context,
                        title: 'NET OPERATING CASH POSITION',
                        value: controller.netAmount,
                        subtitle: 'Income minus Expenses',
                        accentColor: controller.netAmount >= 0
                            ? AppColors.success
                            : AppColors.danger,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Control & Filter Bar
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      onChanged: (val) => controller.searchQuery.value = val,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Search by title, receipt number or notes...',
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
                      width: 150,
                      child: DropdownButtonFormField<String>(
                        initialValue: controller.entryTypeFilter.value,
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
                            child: Text('All Entries'),
                          ),
                          DropdownMenuItem(
                            value: 'expense',
                            child: Text('Expenses (-)'),
                          ),
                          DropdownMenuItem(
                            value: 'income',
                            child: Text('Income (+)'),
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
                  const SizedBox(width: 14),

                  Obx(
                    () => SizedBox(
                      width: 170,
                      child: DropdownButtonFormField<String>(
                        initialValue: controller.categoryFilter.value,
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
                        items: [
                          const DropdownMenuItem(
                            value: 'all',
                            child: Text('All Categories'),
                          ),
                          ...controller.categories.map(
                            (c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(c.name),
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
                ],
              ),
              const SizedBox(height: 16),

              // Data Table
              Expanded(
                child: Obx(() {
                  if (controller.isLoadingList.value) {
                    return const LoadingIndicator();
                  }
                  if (controller.expenses.isEmpty) {
                    return EmptyState(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'No Expense / Income Entries Found',
                      description:
                          'Record operational expenses or non-sales income.',
                      action: AppButton(
                        text: 'Add Expense',
                        icon: const Icon(Icons.add, size: 18),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => const ExpenseFormDialog(),
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
                                      'TITLE / PURPOSE',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'ENTRY TYPE',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'CATEGORY',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'PAYMENT METHOD',
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
                                      'ACTION',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                                rows: List.generate(controller.expenses.length, (
                                  idx,
                                ) {
                                  final item = controller.expenses[idx];
                                  final isExpense = item.entryType == 'expense';
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
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.title,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            if (item.referenceNo != null &&
                                                item.referenceNo!.isNotEmpty)
                                              Text(
                                                'Ref: ${item.referenceNo}',
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                (isExpense
                                                        ? AppColors.danger
                                                        : AppColors.success)
                                                    .withAlpha(25),
                                            borderRadius: AppRadius.full,
                                          ),
                                          child: Text(
                                            item.entryType.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: isExpense
                                                  ? AppColors.danger
                                                  : AppColors.success,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          item.categoryName,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          item.paymentMethod,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          '${isExpense ? '-' : '+'}₹${item.amount.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'monospace',
                                            color: isExpense
                                                ? AppColors.danger
                                                : AppColors.success,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline_rounded,
                                            size: 18,
                                            color: AppColors.danger,
                                          ),
                                          tooltip: 'Delete Entry',
                                          onPressed: () =>
                                              controller.deleteExpense(item.id),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ),
                            ),
                          ),

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
