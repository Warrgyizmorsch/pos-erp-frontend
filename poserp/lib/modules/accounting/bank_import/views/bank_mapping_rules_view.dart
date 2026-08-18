import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/bank_mapping_rules_controller.dart';
import '../models/bank_import_models.dart';

class BankMappingRulesView extends GetView<BankMappingRulesController> {
  const BankMappingRulesView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final searchQuery = ''.obs;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Navigation & Title
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
                          onPressed: () =>
                              Get.toNamed('/accounting/bank-statement-import'),
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
                            Icons.settings_suggest_outlined,
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
                                'Mapping Rules',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Manage auto-suggestion rules mapping transaction keywords to ledger categories.',
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
                  AppButton(
                    text: 'Add Rule',
                    icon: const Icon(Icons.add_rounded, size: 16),
                    variant: AppButtonVariant.primary,
                    onPressed: () {
                      controller.prepareCreate();
                      _showRuleDialog(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 2. Main Mapping Rules Table Card
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card Header with Search Box
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 16,
                        runSpacing: 12,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Narration Mapping Table',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Rules defining keyword match targets for the statement import wizard.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 260,
                            child: TextField(
                              onChanged: (val) => searchQuery.value = val,
                              decoration: InputDecoration(
                                hintText: 'Search patterns, ledgers...',
                                hintStyle: const TextStyle(fontSize: 12),
                                prefixIcon: const Icon(
                                  Icons.search_rounded,
                                  size: 18,
                                ),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: AppRadius.md,
                                  borderSide: BorderSide(
                                    color: isDark
                                        ? AppColors.borderDark
                                        : AppColors.borderLight,
                                  ),
                                ),
                              ),
                            ),
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

                    // Rules Content Body
                    Obx(() {
                      if (controller.isLoading.value) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 60),
                          child: LoadingIndicator(),
                        );
                      }

                      final query = searchQuery.value.toLowerCase().trim();
                      final filtered = controller.rules.where((r) {
                        if (query.isEmpty) return true;
                        final pattern = r.narrationPattern.toLowerCase();
                        final name = (r.ledgerName ?? '').toLowerCase();
                        final code = (r.ledgerCode ?? '').toLowerCase();
                        return pattern.contains(query) ||
                            name.contains(query) ||
                            code.contains(query);
                      }).toList();

                      if (filtered.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              EmptyState(
                                icon: Icons.tune_rounded,
                                title: 'No rules found',
                                description:
                                    'Add rules manually or mapping transactions in import runs will generate rules automatically.',
                              ),
                              const SizedBox(height: 12),
                              AppButton(
                                text: 'Create First Rule',
                                icon: const Icon(Icons.add_rounded, size: 16),
                                variant: AppButtonVariant.primary,
                                onPressed: () {
                                  controller.prepareCreate();
                                  _showRuleDialog(context);
                                },
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
                            constraints: const BoxConstraints(minWidth: 800),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Table Header Row
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
                                        width: 220,
                                        child: Text(
                                          'NARRATION PATTERN',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 240,
                                        child: Text(
                                          'MAPPED LEDGER',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 140,
                                        child: Text(
                                          'LEDGER GROUP',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 110,
                                        child: Text(
                                          'CONFIDENCE',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 90,
                                        child: Text(
                                          'ACTIONS',
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

                                // Table Rows
                                Column(
                                  children: List.generate(filtered.length, (
                                    index,
                                  ) {
                                    final rule = filtered[index];
                                    final isOdd = index % 2 == 1;

                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
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
                                          // 1. Narration Pattern
                                          SizedBox(
                                            width: 220,
                                            child: Text(
                                              rule.narrationPattern
                                                  .toUpperCase(),
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'monospace',
                                              ),
                                            ),
                                          ),

                                          // 2. Mapped Ledger
                                          SizedBox(
                                            width: 240,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  rule.ledgerName ??
                                                      rule.ledgerId,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                if (rule.ledgerCode != null)
                                                  Text(
                                                    '(${rule.ledgerCode!})',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.grey[600],
                                                      fontFamily: 'monospace',
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),

                                          // 3. Ledger Group
                                          SizedBox(
                                            width: 140,
                                            child: Text(
                                              rule.groupType ??
                                                  'INDIRECT_EXPENSES',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ),

                                          // 4. Confidence Badge
                                          SizedBox(
                                            width: 110,
                                            child: Text(
                                              '${rule.confidence.toInt()}%',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primary,
                                                fontFamily: 'monospace',
                                              ),
                                            ),
                                          ),

                                          // 5. Actions
                                          SizedBox(
                                            width: 90,
                                            child: Row(
                                              children: [
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.edit_outlined,
                                                    size: 18,
                                                  ),
                                                  tooltip: 'Edit Rule',
                                                  onPressed: () {
                                                    controller.prepareEdit(
                                                      rule,
                                                    );
                                                    _showRuleDialog(
                                                      context,
                                                      rule: rule,
                                                    );
                                                  },
                                                ),
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons
                                                        .delete_outline_rounded,
                                                    size: 18,
                                                    color: AppColors.danger,
                                                  ),
                                                  tooltip: 'Delete Rule',
                                                  onPressed: () => controller
                                                      .deleteRule(rule.id),
                                                ),
                                              ],
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
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ADD / EDIT MAPPING RULE DIALOG (MATCHING NEXT.JS MAPPINGRULES PAGE)
  // ---------------------------------------------------------------------------
  void _showRuleDialog(BuildContext context, {BankMappingRule? rule}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.add_rounded, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              rule != null ? 'Edit Mapping Rule' : 'Add Mapping Rule',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Define matching keywords inside statement narrations to auto-fill accounts.',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 18),

              // Field 1: Narration Pattern
              AppTextField(
                label: 'Narration Pattern (e.g. AMAZON)',
                hintText: 'AMAZON, SWIGGY, SALARY...',
                controller: controller.patternController,
              ),
              const SizedBox(height: 14),

              // Field 2: Map to Ledger Dropdown (Populated dynamically from availableLedgers list)
              const Text(
                'Map to Ledger',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Obx(
                () => DropdownButtonFormField<String>(
                  initialValue: controller.selectedLedgerId.value.isEmpty
                      ? 'NONE'
                      : controller.selectedLedgerId.value,
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
                        'Select Ledger...',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                    ...controller.availableLedgers.map((l) {
                      return DropdownMenuItem(
                        value: l.id,
                        child: Text(
                          '${l.name} (${l.code})',
                          style: const TextStyle(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }),
                  ],
                  onChanged: (val) {
                    controller.selectedLedgerId.value = val == 'NONE'
                        ? ''
                        : (val ?? '');
                  },
                ),
              ),
              const SizedBox(height: 14),

              // Field 3: Confidence Weight (%)
              AppTextField(
                label: 'Confidence Weight (%)',
                hintText: '100',
                keyboardType: TextInputType.number,
                controller: controller.confidenceController,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          Obx(
            () => AppButton(
              text: rule != null ? 'Save Rule' : 'Save Rule',
              icon: controller.isSaving.value
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_outlined, size: 16),
              variant: AppButtonVariant.primary,
              onPressed: controller.isSaving.value
                  ? null
                  : () async {
                      await controller.saveRule();
                      if (context.mounted) {
                        Navigator.pop(ctx);
                      }
                    },
            ),
          ),
        ],
      ),
    );
  }
}
