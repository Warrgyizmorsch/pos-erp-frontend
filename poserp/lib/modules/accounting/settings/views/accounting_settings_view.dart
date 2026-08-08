import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/accounting_settings_controller.dart';

class AccountingSettingsView extends GetView<AccountingSettingsController> {
  const AccountingSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Obx(() {
            if (controller.isLoading.value &&
                controller.settings.value == null) {
              return const LoadingIndicator();
            }

            return Column(
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
                            Icons.settings_suggest_rounded,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Accounting Controls & Preferences',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Master posting triggers, backdated lock policies, and ledger mappings.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        AppButton(
                          text: 'Refresh',
                          icon: const Icon(Icons.refresh_rounded, size: 16),
                          variant: AppButtonVariant.outline,
                          onPressed: () => controller.loadSettings(),
                        ),
                        const SizedBox(width: 8),
                        AppButton(
                          text: controller.isSaving.value
                              ? 'Saving...'
                              : 'Save Configuration',
                          icon: const Icon(Icons.save_rounded, size: 16),
                          onPressed: controller.isSaving.value
                              ? null
                              : () => controller.saveSettings(),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Form & Controls Body
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Feature Controls Card Grid
                        const Text(
                          'System Feature Controls',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GridView.count(
                          crossAxisCount: 3,
                          childAspectRatio: 2.5,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _buildToggleCard(
                              title: 'Master Accounting Switch',
                              subtitle:
                                  'Enable or disable accounting entry posting across all modules.',
                              value: controller.accountingEnabled,
                            ),
                            _buildToggleCard(
                              title: 'Auto Voucher Posting',
                              subtitle:
                                  'Automatically create double-entry vouchers upon transaction save.',
                              value: controller.autoVoucherPosting,
                            ),
                            _buildToggleCard(
                              title: 'GST Tax Accounting',
                              subtitle:
                                  'Post separate Output/Input GST ledger entries for sales/purchases.',
                              value: controller.gstAccountingEnabled,
                            ),
                            _buildToggleCard(
                              title: 'Inventory Valuation Accounting',
                              subtitle:
                                  'Post perpetual Stock asset and COGS expense ledger balances.',
                              value: controller.inventoryAccountingEnabled,
                            ),
                            _buildToggleCard(
                              title: 'Manual Journal Entry',
                              subtitle:
                                  'Allow finance managers to post custom Debit/Credit journals.',
                              value: controller.allowManualJournalEntry,
                            ),
                            _buildToggleCard(
                              title: 'Allow Backdated Vouchers',
                              subtitle:
                                  'Allow transaction posting dates prior to the current system date.',
                              value: controller.allowBackdatedVouchers,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Accounting Repair Actions Card
                        const Text(
                          'Maintenance & Integrity Repairs',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        AppCard(
                          padding: const EdgeInsets.all(16),
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _buildRepairButton(
                                'cash-bank',
                                'Link Cash/Bank Ledgers',
                                Icons.link_rounded,
                              ),
                              _buildRepairButton(
                                'parties',
                                'Link Party Ledgers',
                                Icons.people_alt_outlined,
                              ),
                              _buildRepairButton(
                                'opening',
                                'Post Opening Balances',
                                Icons.account_balance_outlined,
                              ),
                              _buildRepairButton(
                                'cash-bank-opening',
                                'Post Cash/Bank Opening',
                                Icons.savings_outlined,
                              ),
                              _buildRepairButton(
                                'recalculate',
                                'Recalculate Ledger Balances',
                                Icons.calculate_outlined,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Validation Card
                        if (controller.validation.value != null) ...[
                          const Text(
                            'Configuration Diagnostics',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          AppCard(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      controller.validation.value!.valid
                                          ? Icons.check_circle_outline
                                          : Icons.warning_amber_rounded,
                                      color: controller.validation.value!.valid
                                          ? AppColors.success
                                          : AppColors.warning,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      controller.validation.value!.valid
                                          ? 'All default ledgers & settings are properly mapped.'
                                          : 'Configuration warnings detected.',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            controller.validation.value!.valid
                                            ? AppColors.success
                                            : AppColors.warning,
                                      ),
                                    ),
                                  ],
                                ),
                                if (controller
                                    .validation
                                    .value!
                                    .warnings
                                    .isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  ...controller.validation.value!.warnings.map(
                                    (w) => Text(
                                      '• $w',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildToggleCard({
    required String title,
    required String subtitle,
    required RxBool value,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          Obx(
            () => Switch(
              value: value.value,
              activeTrackColor: AppColors.primary,
              onChanged: (val) => value.value = val,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepairButton(String actionKey, String label, IconData icon) {
    return Obx(() {
      final isRunning = controller.activeRepair.value == actionKey;
      return AppButton(
        text: isRunning ? 'Processing...' : label,
        icon: Icon(icon, size: 16),
        variant: AppButtonVariant.outline,
        onPressed: isRunning
            ? null
            : () => controller.runRepair(actionKey, label),
      );
    });
  }
}
