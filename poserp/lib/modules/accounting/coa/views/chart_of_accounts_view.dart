import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_stat_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/coa_controller.dart';
import '../widgets/account_group_tile.dart';

class ChartOfAccountsView extends GetView<COAController> {
  const ChartOfAccountsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppTopBar(
        title: 'Chart of Accounts',
        subtitle: 'General ledger master hierarchy & financial structure',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 22),
            tooltip: 'Refresh',
            onPressed: () => controller.loadData(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.loadData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Action Bar
              Row(
                children: [
                  Obx(
                    () => AppButton(
                      text: 'Initialize Engine',
                      variant: AppButtonVariant.outline,
                      icon: const Icon(Icons.flash_on_rounded, size: 16),
                      height: 38,
                      isLoading: controller.isInitializing.value,
                      onPressed: () => controller.initializeEngine(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  AppButton(
                    text: 'Refresh Hierarchy',
                    variant: AppButtonVariant.secondary,
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    height: 38,
                    onPressed: () => controller.loadData(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Metric Cards Row
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;

                  if (isMobile) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Obx(
                            () => SizedBox(
                              width: 140,
                              child: AppStatCard(
                                title: 'Assets',
                                value: '${controller.assetGroupsCount}',
                                icon: Icons.account_balance_rounded,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Obx(
                            () => SizedBox(
                              width: 140,
                              child: AppStatCard(
                                title: 'Liabilities',
                                value: '${controller.liabilityGroupsCount}',
                                icon: Icons.account_balance_wallet_rounded,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Obx(
                            () => SizedBox(
                              width: 140,
                              child: AppStatCard(
                                title: 'Equity',
                                value: '${controller.equityGroupsCount}',
                                icon: Icons.pie_chart_rounded,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Obx(
                            () => SizedBox(
                              width: 140,
                              child: AppStatCard(
                                title: 'P&L Groups',
                                value: '${controller.incomeExpenseGroupsCount}',
                                icon: Icons.show_chart_rounded,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Row(
                    children: [
                      Expanded(
                        child: Obx(
                          () => AppStatCard(
                            title: 'Assets Groups',
                            value: '${controller.assetGroupsCount}',
                            icon: Icons.account_balance_rounded,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Obx(
                          () => AppStatCard(
                            title: 'Liabilities Groups',
                            value: '${controller.liabilityGroupsCount}',
                            icon: Icons.account_balance_wallet_rounded,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Obx(
                          () => AppStatCard(
                            title: 'Equity Groups',
                            value: '${controller.equityGroupsCount}',
                            icon: Icons.pie_chart_rounded,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Obx(
                          () => AppStatCard(
                            title: 'Income & Expenses',
                            value: '${controller.incomeExpenseGroupsCount}',
                            icon: Icons.show_chart_rounded,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),

              // Search & Nature Filter Controls
              AppCard(
                padding: const EdgeInsets.all(12),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 500;

                    final searchInput = AppTextField(
                      hintText: 'Search group or ledger...',
                      prefixIcon: const Icon(Icons.search, size: 18),
                      onChanged: (v) => controller.searchQuery.value = v,
                    );

                    final natureDropdown = Obx(
                      () => DropdownButtonFormField<String>(
                        initialValue: controller.selectedNature.value,
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
                            value: 'ALL',
                            child: Text('All Natures'),
                          ),
                          DropdownMenuItem(
                            value: 'ASSET',
                            child: Text('Assets'),
                          ),
                          DropdownMenuItem(
                            value: 'LIABILITY',
                            child: Text('Liabilities'),
                          ),
                          DropdownMenuItem(
                            value: 'INCOME',
                            child: Text('Income'),
                          ),
                          DropdownMenuItem(
                            value: 'EXPENSE',
                            child: Text('Expenses'),
                          ),
                        ],
                        onChanged: (v) {
                          if (v != null) controller.selectedNature.value = v;
                        },
                      ),
                    );

                    if (isMobile) {
                      return Column(
                        children: [
                          searchInput,
                          const SizedBox(height: 8),
                          natureDropdown,
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: searchInput),
                        const SizedBox(width: 12),
                        SizedBox(width: 180, child: natureDropdown),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Tree Accordion View
              Obx(() {
                if (controller.isLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: LoadingIndicator(
                      message: 'Loading Chart of Accounts...',
                    ),
                  );
                }

                final groups = controller.filteredChartGroups;

                if (groups.isEmpty) {
                  return AppCard(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.account_tree_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No Account Groups Found',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Try changing your search query or nature filter.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          AppButton(
                            text: 'Initialize Accounting Engine',
                            icon: const Icon(Icons.flash_on_rounded, size: 16),
                            onPressed: () => controller.initializeEngine(),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return AppCard(
                  padding: const EdgeInsets.all(12),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: groups.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 12),
                    itemBuilder: (context, idx) {
                      final group = groups[idx];
                      return AccountGroupTile(group: group);
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
