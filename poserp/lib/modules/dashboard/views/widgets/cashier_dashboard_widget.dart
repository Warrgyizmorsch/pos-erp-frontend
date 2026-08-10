import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_list_card.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/app_stat_card.dart';
import '../../../../core/widgets/app_status_chip.dart';

class CashierDashboardWidget extends StatelessWidget {
  const CashierDashboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shift Action Hero Card
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'ACTIVE POS REGISTER SHIFT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    AppStatusChip(
                      label: 'SHIFT OPEN',
                      type: AppStatusChipType.success,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Counter Register #1',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Opened at 09:00 AM • Opening Drawer Cash: ₹2,000.00',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: 'Launch POS Terminal',
                        icon: const Icon(Icons.bolt_rounded, size: 18),
                        variant: AppButtonVariant.primary,
                        onPressed: () => Get.toNamed('/pos'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppButton(
                        text: 'Dedicated Checkout',
                        icon: const Icon(
                          Icons.shopping_cart_checkout_rounded,
                          size: 18,
                        ),
                        variant: AppButtonVariant.secondary,
                        onPressed: () => Get.toNamed('/checkout'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Cashier Today's Metrics
          Row(
            children: [
              Expanded(
                child: AppStatCard(
                  title: "Today's POS Sales",
                  value: '₹14,250.00',
                  subtitle: '12 Completed Orders',
                  icon: Icons.receipt_rounded,
                  color: AppColors.success,
                  onTap: () => Get.toNamed('/sales'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppStatCard(
                  title: 'Shift Cash Received',
                  value: '₹9,500.00',
                  subtitle: 'In Drawer',
                  icon: Icons.point_of_sale_rounded,
                  color: AppColors.primary,
                  onTap: () => Get.toNamed('/shifts'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Quick Cashier Actions
          const AppSectionHeader(title: 'Cashier Quick Tools'),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'Payment-In',
                  icon: const Icon(Icons.add_card_rounded, size: 16),
                  variant: AppButtonVariant.outline,
                  onPressed: () => Get.toNamed('/sales/payment-in'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppButton(
                  text: 'Sale Return',
                  icon: const Icon(Icons.assignment_return_rounded, size: 16),
                  variant: AppButtonVariant.outline,
                  onPressed: () => Get.toNamed('/sales/return'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Recent Bills Log
          AppSectionHeader(
            title: 'Recent Bills Issued',
            actionLabel: 'View All',
            onActionTap: () => Get.toNamed('/sales'),
          ),
          AppListCard(
            title: 'INV-2026-089',
            subtitle: 'Customer: Walk-in Customer • 3 Items',
            trailingText: '₹1,250.00',
            statusText: 'PAID',
            statusType: AppStatusChipType.success,
            leadIcon: Icons.receipt_long_rounded,
            onTap: () => Get.toNamed('/sales'),
          ),
          const SizedBox(height: 8),
          AppListCard(
            title: 'INV-2026-088',
            subtitle: 'Customer: Acme Retails • 8 Items',
            trailingText: '₹4,500.00',
            statusText: 'PAID',
            statusType: AppStatusChipType.success,
            leadIcon: Icons.receipt_long_rounded,
            onTap: () => Get.toNamed('/sales'),
          ),
        ],
      ),
    );
  }
}
