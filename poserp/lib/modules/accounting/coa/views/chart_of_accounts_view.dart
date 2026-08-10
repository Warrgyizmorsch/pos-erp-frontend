import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_stat_card.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/coa_controller.dart';
import '../widgets/account_group_tile.dart';

class ChartOfAccountsView extends GetView<COAController> {
  const ChartOfAccountsView({super.key});

  @override
  Widget build(BuildContext context) {
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

              // Metric Cards Row (Responsive Horizontal Scroll)
              Obx(
                () => LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 600;

                    if (isMobile) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 140,
                              child: AppStatCard(
                                title: 'Assets',
                                value: '${controller.assetGroupsCount}',
                                icon: Icons.account_balance_rounded,
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 140,
                              child: AppStatCard(
                                title: 'Liabilities',
                                value: '${controller.liabilityGroupsCount}',
                                icon: Icons.account_balance_wallet_rounded,
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 140,
                              child: AppStatCard(
                                title: 'Equity',
                                value: '${controller.equityGroupsCount}',
                                icon: Icons.pie_chart_rounded,
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 140,
                              child: AppStatCard(
                                title: 'P&L Groups',
                                value: '${controller.incomeExpenseGroupsCount}',
                                icon: Icons.show_chart_rounded,
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
                            title: 'Assets Groups',
                            value: '${controller.assetGroupsCount}',
                            icon: Icons.account_balance_rounded,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AppStatCard(
                            title: 'Liabilities Groups',
                            value: '${controller.liabilityGroupsCount}',
                            icon: Icons.account_balance_wallet_rounded,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AppStatCard(
                            title: 'Equity Groups',
                            value: '${controller.equityGroupsCount}',
                            icon: Icons.pie_chart_rounded,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AppStatCard(
                            title: 'Income & Expenses',
                            value: '${controller.incomeExpenseGroupsCount}',
                            icon: Icons.show_chart_rounded,
                          ),
                        ),
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

                if (controller.chartGroups.isEmpty) {
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
                            'Chart of Accounts is Empty',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Initialize default accounting groups to enable double-entry ledger posting.',
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
                    itemCount: controller.chartGroups.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 16),
                    itemBuilder: (context, idx) {
                      final group = controller.chartGroups[idx];
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
