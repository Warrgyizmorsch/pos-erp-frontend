import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_list_card.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/app_stat_card.dart';
import '../../../../core/widgets/app_status_chip.dart';

class AccountantDashboardWidget extends StatelessWidget {
  const AccountantDashboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Financial Position Overview Grid
          Row(
            children: [
              Expanded(
                child: AppStatCard(
                  title: 'Party Receivables',
                  value: '₹42,500.00',
                  subtitle: '8 Outstanding ledgers',
                  icon: Icons.call_received_rounded,
                  color: AppColors.info,
                  onTap: () => Get.toNamed('/accounting/ledgers'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppStatCard(
                  title: 'Vendor Payables',
                  value: '₹18,900.00',
                  subtitle: '4 Vendor bills',
                  icon: Icons.call_made_rounded,
                  color: AppColors.warning,
                  onTap: () => Get.toNamed('/accounting/ledgers'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppStatCard(
            title: 'Liquid Cash & Bank Reserves',
            value: '₹1,24,800.00',
            subtitle: 'Petty Cash + Active Bank Accounts',
            icon: Icons.account_balance_rounded,
            color: AppColors.primary,
            onTap: () => Get.toNamed('/cash-bank'),
          ),
          const SizedBox(height: 16),

          // Accounting Quick Actions
          const AppSectionHeader(title: 'Accounting Operations'),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'Chart of Accounts',
                  icon: const Icon(Icons.layers_rounded, size: 16),
                  variant: AppButtonVariant.primary,
                  onPressed: () => Get.toNamed('/accounting/chart-of-accounts'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppButton(
                  text: 'Vouchers',
                  icon: const Icon(Icons.receipt_long_rounded, size: 16),
                  variant: AppButtonVariant.secondary,
                  onPressed: () => Get.toNamed('/accounting/vouchers'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'Trial Balance',
                  icon: const Icon(Icons.bar_chart_rounded, size: 16),
                  variant: AppButtonVariant.outline,
                  onPressed: () => Get.toNamed('/accounting/trial-balance'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppButton(
                  text: 'Day Book',
                  icon: const Icon(Icons.book_rounded, size: 16),
                  variant: AppButtonVariant.outline,
                  onPressed: () => Get.toNamed('/accounting/day-book'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Diagnostic Health & Statements
          AppSectionHeader(
            title: 'Audit & Health Checks',
            actionLabel: 'Health Diagnostics',
            onActionTap: () => Get.toNamed('/accounting/health'),
          ),
          AppListCard(
            title: 'Double-Entry Health Status',
            subtitle: 'Automated trial balance integrity audit',
            trailingText: 'BALANCED',
            statusText: 'PASSED',
            statusType: AppStatusChipType.success,
            leadIcon: Icons.shield_rounded,
            onTap: () => Get.toNamed('/accounting/health'),
          ),
          const SizedBox(height: 8),
          AppListCard(
            title: 'Bank Statement Auto-Importer',
            subtitle: 'Upload CSV/PDF statement & post vouchers',
            trailingText: '3 Pending',
            statusText: 'IMPORT READY',
            statusType: AppStatusChipType.info,
            leadIcon: Icons.upload_file_rounded,
            onTap: () => Get.toNamed('/accounting/bank-statement-import'),
          ),
        ],
      ),
    );
  }
}
