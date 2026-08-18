import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/bank_import_settings_controller.dart';

class BankImportSettingsView extends GetView<BankImportSettingsController> {
  const BankImportSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Padding(
                padding: EdgeInsets.only(top: 80),
                child: LoadingIndicator(),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Navigation & Actions
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 550),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_rounded),
                            onPressed: () => Get.toNamed(
                              '/accounting/bank-statement-import',
                            ),
                            tooltip: 'Back to Bank Import',
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(25),
                              borderRadius: AppRadius.lg,
                            ),
                            child: const Icon(
                              Icons.tune_rounded,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Bank Import Settings',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Configure global default accounts, confidence thresholds, and automatic bank detection mappings.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 2. Settings Form Section
                Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row: Cards 1 & 2
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth > 900;

                          final card1 = AppCard(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(
                                      Icons.account_balance_rounded,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Default Account Assignments',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Configure fallbacks for unrecognized statements or auto-detected categories.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 18),

                                // Default Bank Account
                                const Text(
                                  'Default Bank Account (Ledger)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Obx(
                                  () => DropdownButtonFormField<String>(
                                    initialValue:
                                        controller
                                            .defaultBankLedgerId
                                            .value
                                            .isEmpty
                                        ? 'NONE'
                                        : controller.defaultBankLedgerId.value,
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                    ),
                                    items: [
                                      const DropdownMenuItem(
                                        value: 'NONE',
                                        child: Text(
                                          'Select Default Bank Ledger...',
                                          style: TextStyle(fontSize: 13),
                                        ),
                                      ),
                                      ...controller.bankLedgers.map((l) {
                                        return DropdownMenuItem(
                                          value: l.id,
                                          child: Text(
                                            '${l.name} (${l.code})',
                                            style: const TextStyle(
                                              fontSize: 13,
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                    onChanged: (val) {
                                      controller.defaultBankLedgerId.value =
                                          val == 'NONE' ? '' : (val ?? '');
                                    },
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Used if statement upload does not specify a bank ledger.',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Default Expense Account
                                const Text(
                                  'Default Expense Account (Ledger)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Obx(
                                  () => DropdownButtonFormField<String>(
                                    initialValue:
                                        controller
                                            .defaultExpenseLedgerId
                                            .value
                                            .isEmpty
                                        ? 'NONE'
                                        : controller
                                              .defaultExpenseLedgerId
                                              .value,
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                    ),
                                    items: [
                                      const DropdownMenuItem(
                                        value: 'NONE',
                                        child: Text(
                                          'Select Default Expense Ledger...',
                                          style: TextStyle(fontSize: 13),
                                        ),
                                      ),
                                      ...controller.allLedgers.map((l) {
                                        return DropdownMenuItem(
                                          value: l.id,
                                          child: Text(
                                            '${l.name} (${l.groupName})',
                                            style: const TextStyle(
                                              fontSize: 13,
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                    onChanged: (val) {
                                      controller.defaultExpenseLedgerId.value =
                                          val == 'NONE' ? '' : (val ?? '');
                                    },
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Pre-populated in wizard when no matching narration rule is found.',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          );

                          final card2 = AppCard(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(
                                      Icons.settings_outlined,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Posting Controls',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Set accuracy limits and posting toggles.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 18),

                                // Confidence Slider
                                Obx(
                                  () => Text(
                                    'Confidence Match Threshold (${controller.confidenceThreshold.value.toInt()}%)',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Obx(
                                  () => Slider(
                                    value: controller.confidenceThreshold.value
                                        .clamp(50.0, 100.0),
                                    min: 50.0,
                                    max: 100.0,
                                    divisions: 50,
                                    activeColor: AppColors.primary,
                                    onChanged: (val) =>
                                        controller.confidenceThreshold.value =
                                            val,
                                  ),
                                ),
                                Text(
                                  'Rules below threshold are shown as low confidence suggestions.',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Checkbox Toggle
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Checkbox(
                                      value: controller
                                          .autoPostHighConfidence
                                          .value,
                                      activeColor: AppColors.primary,
                                      onChanged: (val) =>
                                          controller
                                                  .autoPostHighConfidence
                                                  .value =
                                              val ?? false,
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Enable One-Click Bulk Post',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Allows bypassing stepper if 100% match narration rules.',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );

                          if (isWide) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 3, child: card1),
                                const SizedBox(width: 16),
                                Expanded(flex: 2, child: card2),
                              ],
                            );
                          }

                          return Column(
                            children: [
                              card1,
                              const SizedBox(height: 16),
                              card2,
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // Card 3: Automatic Bank Detection Mappings Table (Next.js Parity)
                      AppCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 16,
                                runSpacing: 12,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'Automatic Bank Detection Mappings',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Associate keywords parsed from PDF contents with their corresponding Bank ledger accounts.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  AppButton(
                                    text: 'Add Bank Rule',
                                    icon: const Icon(
                                      Icons.add_rounded,
                                      size: 16,
                                    ),
                                    variant: AppButtonVariant.outline,
                                    onPressed: () =>
                                        controller.handleAddMappingRow(),
                                  ),
                                ],
                              ),
                            ),
                            Divider(
                              height: 1,
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.borderLight,
                            ),

                            // Table Content
                            Obx(() {
                              if (controller.bankMappings.isEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Column(
                                    children: [
                                      const EmptyState(
                                        icon: Icons.shield_outlined,
                                        title: 'No Bank Mappings Configured',
                                        description:
                                            'Add rules below to auto-select bank accounts. E.g., if PDF contains keyword "HDFC", select HDFC Bank ledger automatically.',
                                      ),
                                      const SizedBox(height: 12),
                                      AppButton(
                                        text: 'Configure First Mapping',
                                        icon: const Icon(
                                          Icons.add_rounded,
                                          size: 16,
                                        ),
                                        variant: AppButtonVariant.primary,
                                        onPressed: () =>
                                            controller.handleAddMappingRow(),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return ClipRRect(
                                borderRadius: AppRadius.lg,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      minWidth: 700,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Header Row
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? AppColors.inputDark
                                                : Colors.grey[100],
                                            border: Border(
                                              bottom: BorderSide(
                                                color: isDark
                                                    ? AppColors.borderDark
                                                    : AppColors.borderLight,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            children: const [
                                              SizedBox(
                                                width: 300,
                                                child: Text(
                                                  'BANK KEYWORD (DETECTED IN PDF TEXT)',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 320,
                                                child: Text(
                                                  'TARGET BANK LEDGER ACCOUNT',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 80,
                                                child: Text(
                                                  'ACTION',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Rows
                                        Column(
                                          children: List.generate(controller.bankMappings.length, (
                                            idx,
                                          ) {
                                            final mapping =
                                                controller.bankMappings[idx];
                                            final isOdd = idx % 2 == 1;

                                            return Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 10,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: isOdd
                                                    ? (isDark
                                                          ? AppColors.inputDark
                                                                .withAlpha(40)
                                                          : Colors.grey[50])
                                                    : Colors.transparent,
                                                border: Border(
                                                  bottom: BorderSide(
                                                    color: isDark
                                                        ? AppColors.borderDark
                                                              .withAlpha(30)
                                                        : Colors.grey[200]!,
                                                  ),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  // Keyword Input
                                                  SizedBox(
                                                    width: 300,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            right: 16,
                                                          ),
                                                      child: TextField(
                                                        controller:
                                                            TextEditingController(
                                                                text:
                                                                    mapping['keyword'],
                                                              )
                                                              ..selection = TextSelection.fromPosition(
                                                                TextPosition(
                                                                  offset:
                                                                      (mapping['keyword'] ??
                                                                              '')
                                                                          .length,
                                                                ),
                                                              ),
                                                        onChanged: (val) =>
                                                            controller
                                                                .handleMappingChange(
                                                                  idx,
                                                                  'keyword',
                                                                  val,
                                                                ),
                                                        style: const TextStyle(
                                                          fontSize: 13,
                                                          fontFamily:
                                                              'monospace',
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        decoration: InputDecoration(
                                                          hintText:
                                                              'e.g. HDFC, ICICI, SBI',
                                                          isDense: true,
                                                          contentPadding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 10,
                                                                vertical: 8,
                                                              ),
                                                          border:
                                                              const OutlineInputBorder(),
                                                        ),
                                                      ),
                                                    ),
                                                  ),

                                                  // Target Bank Ledger Select
                                                  SizedBox(
                                                    width: 320,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            right: 16,
                                                          ),
                                                      child: DropdownButtonFormField<String>(
                                                        initialValue:
                                                            (mapping['bankLedgerId'] ??
                                                                    '')
                                                                .isEmpty
                                                            ? 'NONE'
                                                            : mapping['bankLedgerId'],
                                                        decoration: const InputDecoration(
                                                          isDense: true,
                                                          border:
                                                              OutlineInputBorder(),
                                                          contentPadding:
                                                              EdgeInsets.symmetric(
                                                                horizontal: 10,
                                                                vertical: 8,
                                                              ),
                                                        ),
                                                        items: [
                                                          const DropdownMenuItem(
                                                            value: 'NONE',
                                                            child: Text(
                                                              'Select Bank Ledger...',
                                                              style: TextStyle(
                                                                fontSize: 13,
                                                              ),
                                                            ),
                                                          ),
                                                          ...controller.bankLedgers.map((
                                                            l,
                                                          ) {
                                                            return DropdownMenuItem(
                                                              value: l.id,
                                                              child: Text(
                                                                '${l.name} (${l.code})',
                                                                style:
                                                                    const TextStyle(
                                                                      fontSize:
                                                                          13,
                                                                    ),
                                                              ),
                                                            );
                                                          }),
                                                        ],
                                                        onChanged: (val) {
                                                          controller
                                                              .handleMappingChange(
                                                                idx,
                                                                'bankLedgerId',
                                                                val == 'NONE'
                                                                    ? ''
                                                                    : (val ??
                                                                          ''),
                                                              );
                                                        },
                                                      ),
                                                    ),
                                                  ),

                                                  // Action Delete Button
                                                  SizedBox(
                                                    width: 80,
                                                    child: IconButton(
                                                      icon: const Icon(
                                                        Icons
                                                            .delete_outline_rounded,
                                                        size: 18,
                                                        color: AppColors.danger,
                                                      ),
                                                      onPressed: () => controller
                                                          .handleRemoveMappingRow(
                                                            idx,
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Footer Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AppButton(
                            text: 'Cancel',
                            variant: AppButtonVariant.outline,
                            onPressed: () => Get.toNamed(
                              '/accounting/bank-statement-import',
                            ),
                          ),
                          const SizedBox(width: 12),
                          AppButton(
                            text: controller.isSaving.value
                                ? 'Saving Configurations...'
                                : 'Save Configurations',
                            icon: const Icon(Icons.save_rounded, size: 16),
                            variant: AppButtonVariant.primary,
                            onPressed: controller.isSaving.value
                                ? null
                                : () => controller.saveSettings(),
                          ),
                        ],
                      ),
                    ],
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
