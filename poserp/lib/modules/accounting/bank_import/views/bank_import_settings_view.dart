import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/bank_import_settings_controller.dart';

class BankImportSettingsView extends GetView<BankImportSettingsController> {
  const BankImportSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Obx(() {
            if (controller.isLoading.value) {
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
                            Icons.settings_outlined,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Bank Statement Import Controls',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Configure default fallback ledgers and auto-posting confidence thresholds for bank statements.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    AppButton(
                      text: controller.isSaving.value
                          ? 'Saving...'
                          : 'Save Settings',
                      icon: const Icon(Icons.save_rounded, size: 16),
                      variant: AppButtonVariant.primary,
                      onPressed: controller.isSaving.value
                          ? null
                          : () => controller.saveSettings(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Settings Form
                Expanded(
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: AppCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Default Fallback Ledgers',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              label: 'Default Bank Account Ledger ID',
                              initialValue:
                                  controller.defaultBankLedgerId.value,
                              onChanged: (val) =>
                                  controller.defaultBankLedgerId.value = val,
                            ),
                            const SizedBox(height: 12),
                            AppTextField(
                              label: 'Default Unmapped Expense Ledger ID',
                              initialValue:
                                  controller.defaultExpenseLedgerId.value,
                              onChanged: (val) =>
                                  controller.defaultExpenseLedgerId.value = val,
                            ),
                            const SizedBox(height: 12),
                            AppTextField(
                              label: 'Default Unmapped Income Ledger ID',
                              initialValue:
                                  controller.defaultIncomeLedgerId.value,
                              onChanged: (val) =>
                                  controller.defaultIncomeLedgerId.value = val,
                            ),
                            const Divider(height: 32),
                            const Text(
                              'Fuzzy Auto-Matching Policies',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Auto-Post High Confidence Entries',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Automatically create vouchers for transactions matching above threshold.',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                Switch(
                                  value:
                                      controller.autoPostHighConfidence.value,
                                  activeTrackColor: AppColors.primary,
                                  onChanged: (val) =>
                                      controller.autoPostHighConfidence.value =
                                          val,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Confidence Threshold: ${(controller.confidenceThreshold.value * 100).toInt()}%',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Slider(
                              value: controller.confidenceThreshold.value,
                              min: 0.50,
                              max: 0.99,
                              divisions: 49,
                              activeColor: AppColors.primary,
                              onChanged: (val) =>
                                  controller.confidenceThreshold.value = val,
                            ),
                          ],
                        ),
                      ),
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
}
