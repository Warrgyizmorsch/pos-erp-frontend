import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/coa_controller.dart';
import '../widgets/account_group_tile.dart';

class ChartOfAccountsView extends GetView<COAController> {
  const ChartOfAccountsView({super.key});

  @override
  Widget build(BuildContext context) {
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
                          Icons.account_tree_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Chart of Accounts',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'General ledger master hierarchy organizing Assets, Liabilities, Equity, Revenue, and Expenses.',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Obx(
                        () => AppButton(
                          text: 'Initialize Engine',
                          variant: AppButtonVariant.outline,
                          icon: const Icon(Icons.flash_on_rounded, size: 16),
                          isLoading: controller.isInitializing.value,
                          onPressed: () => controller.initializeEngine(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      AppButton(
                        text: 'Refresh',
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        onPressed: () => controller.loadData(),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Metric Cards Row
              Obx(
                () => Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        title: 'ASSETS GROUPS',
                        value: '${controller.assetGroupsCount}',
                        subtitle: 'Cash, Bank, Receivables & Inventory',
                        accentColor: AppColors.info,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'LIABILITIES GROUPS',
                        value: '${controller.liabilityGroupsCount}',
                        subtitle: 'Payables, Loans & Taxes',
                        accentColor: AppColors.danger,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'EQUITY GROUPS',
                        value: '${controller.equityGroupsCount}',
                        subtitle: 'Owner capital & Retained earnings',
                        accentColor: AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'INCOME & EXPENSES',
                        value: '${controller.incomeExpenseGroupsCount}',
                        subtitle: 'Operating revenue & Overhead cost',
                        accentColor: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Tree Accordion View
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const LoadingIndicator();
                  }

                  if (controller.chartGroups.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.account_tree_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Chart of Accounts is Empty or Not Initialized',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Initialize default accounting groups and ledgers to start financial posting.',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                          const SizedBox(height: 20),
                          AppButton(
                            text: 'Initialize Accounting Engine',
                            icon: const Icon(Icons.flash_on_rounded, size: 18),
                            onPressed: () => controller.initializeEngine(),
                          ),
                        ],
                      ),
                    );
                  }

                  return AppCard(
                    padding: const EdgeInsets.all(16),
                    child: ListView.builder(
                      itemCount: controller.chartGroups.length,
                      itemBuilder: (context, idx) {
                        final group = controller.chartGroups[idx];
                        return AccountGroupTile(group: group);
                      },
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

  Widget _buildMetricCard({
    required String title,
    required String value,
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
            value,
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
