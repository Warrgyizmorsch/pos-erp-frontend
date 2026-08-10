import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_list_card.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/app_stat_card.dart';
import '../../../../core/widgets/app_status_chip.dart';

class StockManagerDashboardWidget extends StatelessWidget {
  const StockManagerDashboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stock Overview Grid
          Row(
            children: [
              Expanded(
                child: AppStatCard(
                  title: 'Total Catalog Products',
                  value: '148 Items',
                  subtitle: '12 Categories',
                  icon: Icons.inventory_2_outlined,
                  color: AppColors.primary,
                  onTap: () => Get.toNamed('/products'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppStatCard(
                  title: 'Low Stock Alerts',
                  value: '4 Products',
                  subtitle: 'Needs reorder',
                  icon: Icons.warning_amber_rounded,
                  color: AppColors.danger,
                  onTap: () => Get.toNamed('/inventory'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Inventory Manager Quick Actions
          const AppSectionHeader(title: 'Stock Operations'),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'Products Catalog',
                  icon: const Icon(Icons.category_rounded, size: 16),
                  variant: AppButtonVariant.primary,
                  onPressed: () => Get.toNamed('/products'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppButton(
                  text: 'Stock Manager',
                  icon: const Icon(Icons.warehouse_rounded, size: 16),
                  variant: AppButtonVariant.secondary,
                  onPressed: () => Get.toNamed('/inventory'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'Purchase Bills',
                  icon: const Icon(Icons.receipt_rounded, size: 16),
                  variant: AppButtonVariant.outline,
                  onPressed: () => Get.toNamed('/purchases'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppButton(
                  text: 'Opening Stock',
                  icon: const Icon(Icons.inventory_rounded, size: 16),
                  variant: AppButtonVariant.outline,
                  onPressed: () => Get.toNamed('/opening-stock'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Low Stock Alert Items List
          AppSectionHeader(
            title: 'Low Stock Reorder List',
            actionLabel: 'View Inventory',
            onActionTap: () => Get.toNamed('/inventory'),
          ),
          AppListCard(
            title: 'Organic Green Tea (250g)',
            subtitle: 'SKU: PRD-001 • Category: Beverages',
            trailingText: '5 kg Left',
            statusText: 'Reorder Now',
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
