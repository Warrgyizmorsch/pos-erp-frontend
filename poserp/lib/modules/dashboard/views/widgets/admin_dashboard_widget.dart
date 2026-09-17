import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_list_card.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/app_stat_card.dart';
import '../../../../core/widgets/app_status_chip.dart';
import '../../controllers/dashboard_controller.dart';

class AdminDashboardWidget extends GetView<DashboardController> {
  const AdminDashboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Business Overview KPI Grid
          Obx(() {
            final s = controller.summary.value;
            final isLoading = controller.isLoading.value && s == null;

            final sales = s?.todaySales ?? 0.0;
            final purchases = s?.todayPurchases ?? 0.0;
            final receivables = s?.totalReceivables ?? 0.0;
            final payables = s?.totalPayables ?? 0.0;
            final cashBank = s?.cashBankBalance ?? 0.0;
            final lowStock = s?.lowStockCount ?? 0;

            return LayoutBuilder(
              builder: (context, constraints) {
                final isTablet = constraints.maxWidth >= 600;
                final crossCount = isTablet ? 3 : 2;

                return GridView.count(
                  crossAxisCount: crossCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: isTablet ? 1.5 : 1.35,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    AppStatCard(
                      title: "Today's Sales",
                      value: isLoading ? '...' : '₹${sales.toStringAsFixed(2)}',
                      subtitle: "Today's revenue",
                      icon: Icons.trending_up_rounded,
                      color: AppColors.success,
                      onTap: () => Get.toNamed('/sales'),
                    ),
                    AppStatCard(
                      title: "Today's Purchases",
                      value: isLoading ? '...' : '₹${purchases.toStringAsFixed(2)}',
                      subtitle: "Today's bills",
                      icon: Icons.shopping_bag_outlined,
                      color: AppColors.primary,
                      onTap: () => Get.toNamed('/purchases'),
                    ),
                    AppStatCard(
                      title: 'Receivables',
                      value: isLoading ? '...' : '₹${receivables.toStringAsFixed(2)}',
                      subtitle: 'To receive (Customers)',
                      icon: Icons.call_received_rounded,
                      color: AppColors.info,
                      onTap: () => Get.toNamed('/customers'),
                    ),
                    AppStatCard(
                      title: 'Payables',
                      value: isLoading ? '...' : '₹${payables.toStringAsFixed(2)}',
                      subtitle: 'To pay (Suppliers)',
                      icon: Icons.call_made_rounded,
                      color: AppColors.warning,
                      onTap: () => Get.toNamed('/suppliers'),
                    ),
                    AppStatCard(
                      title: 'Cash & Bank',
                      value: isLoading ? '...' : '₹${cashBank.toStringAsFixed(2)}',
                      subtitle: 'Total liquid balance',
                      icon: Icons.account_balance_wallet_outlined,
                      color: AppColors.primary,
                      onTap: () => Get.toNamed('/cash-bank'),
                    ),
                    AppStatCard(
                      title: 'Low Stock Items',
                      value: isLoading ? '...' : '$lowStock Products',
                      subtitle: lowStock > 0 ? 'Requires reorder' : 'All stock healthy',
                      icon: Icons.warning_amber_rounded,
                      color: lowStock > 0 ? AppColors.danger : AppColors.success,
                      onTap: () => Get.toNamed('/inventory'),
                    ),
                  ],
                );
              },
            );
          }),
          const SizedBox(height: 16),

          // Executive Quick Actions
          const AppSectionHeader(title: 'Quick Operations'),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'POS Terminal',
                  icon: const Icon(Icons.point_of_sale_rounded, size: 16),
                  variant: AppButtonVariant.primary,
                  onPressed: () => Get.toNamed('/pos'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppButton(
                  text: 'New Sale Bill',
                  icon: const Icon(Icons.add_rounded, size: 16),
                  variant: AppButtonVariant.secondary,
                  onPressed: () => Get.toNamed('/checkout'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Low Stock Alert List Section
          AppSectionHeader(
            title: 'Critical Inventory Alerts',
            actionLabel: 'View All',
            onActionTap: () => Get.toNamed('/inventory'),
          ),
          AppListCard(
            title: 'Organic Green Tea (250g)',
            subtitle: 'SKU: PRD-001 • Category: Beverages',
            trailingText: '5 kg Left',
            statusText: 'Low Stock',
            statusType: AppStatusChipType.danger,
            leadIcon: Icons.inventory_2_outlined,
            onTap: () => Get.toNamed('/inventory'),
          ),
          const SizedBox(height: 8),
          AppListCard(
            title: 'Dark Chocolate Bar (100g)',
            subtitle: 'SKU: PRD-002 • Category: Snacks',
            trailingText: '8 pcs Left',
            statusText: 'Low Stock',
            statusType: AppStatusChipType.warning,
            leadIcon: Icons.inventory_2_outlined,
            onTap: () => Get.toNamed('/inventory'),
          ),
        ],
      ),
    );
  }
}
