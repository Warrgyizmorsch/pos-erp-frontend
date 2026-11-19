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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(() {
            if (controller.isLoading.value &&
                controller.settings.value == null) {
              return const LoadingIndicator();
            }

            final enabled = controller.accountingEnabled.value;
            final st = controller.status.value;
            final val = controller.validation.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Toolbar
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 600;

                    final statusBadge = Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: (enabled ? AppColors.success : Colors.grey)
                            .withAlpha(20),
                        borderRadius: AppRadius.full,
                      ),
                      child: Text(
                        enabled ? 'Accounting Enabled' : 'Accounting Disabled',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: enabled ? AppColors.success : Colors.grey,
                        ),
                      ),
                    );

                    if (isMobile) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withAlpha(25),
                                  borderRadius: AppRadius.md,
                                ),
                                child: const Icon(
                                  Icons.settings_suggest_rounded,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Text(
                                  'Accounting Settings',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              statusBadge,
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Enable accounting, control posting behavior, and map default ledgers.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: AppButton(
                                  text: 'Initialize',
                                  variant: AppButtonVariant.outline,
                                  icon: const Icon(
                                    Icons.storage_rounded,
                                    size: 14,
                                  ),
                                  height: 36,
                                  isLoading: controller.isInitializing.value,
                                  onPressed: () =>
                                      controller.initializeAccounting(),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: AppButton(
                                  text: 'Restore Ledgers',
                                  variant: AppButtonVariant.outline,
                                  icon: const Icon(
                                    Icons.settings_backup_restore_rounded,
                                    size: 14,
                                  ),
                                  height: 36,
                                  isLoading: controller.isRestoring.value,
                                  onPressed: () =>
                                      controller.restoreDefaultLedgers(),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: AppButton(
                                  text: 'Refresh',
                                  variant: AppButtonVariant.outline,
                                  icon: const Icon(
                                    Icons.refresh_rounded,
                                    size: 14,
                                  ),
                                  height: 36,
                                  onPressed: () => controller.loadSettings(),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: AppButton(
                                  text: 'Save Settings',
                                  icon: const Icon(
                                    Icons.save_rounded,
                                    size: 14,
                                  ),
                                  height: 36,
                                  isLoading: controller.isSaving.value,
                                  onPressed: () => controller.saveSettings(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }

                    return Row(
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
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'Accounting Settings',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    statusBadge,
                                  ],
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Enable accounting, control posting behavior, and map default ledgers.',
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
                              text: 'Initialize Accounting',
                              variant: AppButtonVariant.outline,
                              icon: const Icon(Icons.storage_rounded, size: 16),
                              isLoading: controller.isInitializing.value,
                              onPressed: () =>
                                  controller.initializeAccounting(),
                            ),
                            const SizedBox(width: 8),
                            AppButton(
                              text: 'Restore Default Ledgers',
                              variant: AppButtonVariant.outline,
                              icon: const Icon(
                                Icons.settings_backup_restore_rounded,
                                size: 16,
                              ),
                              isLoading: controller.isRestoring.value,
                              onPressed: () =>
                                  controller.restoreDefaultLedgers(),
                            ),
                            const SizedBox(width: 8),
                            AppButton(
                              text: 'Refresh',
                              variant: AppButtonVariant.outline,
                              icon: const Icon(Icons.refresh_rounded, size: 16),
                              onPressed: () => controller.loadSettings(),
                            ),
                            const SizedBox(width: 8),
                            AppButton(
                              text: 'Save Settings',
                              icon: const Icon(Icons.save_rounded, size: 16),
                              isLoading: controller.isSaving.value,
                              onPressed: () => controller.saveSettings(),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),

                // 2. Scrollable Body
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Feature Controls Card Grid
                        const Text(
                          'FEATURE CONTROLS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final cols = constraints.maxWidth < 600
                                ? 1
                                : (constraints.maxWidth < 1000 ? 2 : 3);

                            return GridView.count(
                              crossAxisCount: cols,
                              childAspectRatio: cols == 1
                                  ? 2.8
                                  : (cols == 2 ? 2.2 : 2.0),
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                _buildToggleCard(
                                  title: 'Enable Accounting',
                                  subtitle:
                                      'Master switch for accounting posting and reports.',
                                  value: controller.accountingEnabled,
                                  isDark: isDark,
                                ),
                                _buildToggleCard(
                                  title: 'Auto Voucher Posting',
                                  subtitle:
                                      'Create accounting vouchers automatically from transactions.',
                                  value: controller.autoVoucherPosting,
                                  isDark: isDark,
                                ),
                                _buildToggleCard(
                                  title: 'GST Accounting',
                                  subtitle:
                                      'Use GST ledgers for tax accounting where modules support it.',
                                  value: controller.gstAccountingEnabled,
                                  isDark: isDark,
                                ),
                                _buildToggleCard(
                                  title: 'Inventory Accounting',
                                  subtitle:
                                      'Reserved for stock/COGS accounting phases.',
                                  value: controller.inventoryAccountingEnabled,
                                  isDark: isDark,
                                ),
                                _buildToggleCard(
                                  title: 'Manual Journal Entry',
                                  subtitle:
                                      'Allow users to create accounting journal vouchers manually.',
                                  value: controller.allowManualJournalEntry,
                                  isDark: isDark,
                                ),
                                _buildToggleCard(
                                  title: 'Backdated Vouchers',
                                  subtitle:
                                      'Allow voucher dates before the current date.',
                                  value: controller.allowBackdatedVouchers,
                                  isDark: isDark,
                                ),
                                // Lock Books Till Date Card
                                AppCard(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Lock Books Till Date',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        'Prevent accounting changes before date.',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      SizedBox(
                                        height: 36,
                                        child: TextField(
                                          readOnly: true,
                                          onTap: () => _pickLockDate(context),
                                          controller: controller
                                              .lockBooksDateTextController,
                                          style: const TextStyle(fontSize: 11),
                                          decoration: InputDecoration(
                                            hintText: 'Select date...',
                                            suffixIcon: IconButton(
                                              icon: const Icon(
                                                Icons.calendar_today_rounded,
                                                size: 14,
                                              ),
                                              onPressed: () =>
                                                  _pickLockDate(context),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                            filled: true,
                                            fillColor: isDark
                                                ? AppColors.inputDark
                                                : Colors.grey[100],
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
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        // Maintenance & Integrity Repairs
                        const Text(
                          'ACCOUNTING REPAIR ACTIONS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AppCard(
                          padding: const EdgeInsets.all(14),
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 10,
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
                        const SizedBox(height: 20),

                        // Configuration Diagnostics & Validation
                        const Text(
                          'SETTINGS VALIDATION & DIAGNOSTICS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isMobile = constraints.maxWidth < 600;

                            final diagnosticCards = Row(
                              children: [
                                Expanded(
                                  child: _buildDiagnosticMetricCard(
                                    title: 'Accounting Foundation',
                                    badgeText: st?.initialized == true
                                        ? 'Accounting Initialized'
                                        : 'Not Initialized',
                                    badgeColor: st?.initialized == true
                                        ? AppColors.success
                                        : AppColors.warning,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildDiagnosticMetricCard(
                                    title: 'Missing Default Ledgers',
                                    valueText:
                                        '${st?.missingDefaultLedgersCount ?? 0}',
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildDiagnosticMetricCard(
                                    title: 'Missing Default Groups',
                                    valueText:
                                        '${st?.missingDefaultGroupsCount ?? 0}',
                                  ),
                                ),
                              ],
                            );

                            if (isMobile) {
                              return Column(
                                children: [
                                  _buildDiagnosticMetricCard(
                                    title: 'Accounting Foundation',
                                    badgeText: st?.initialized == true
                                        ? 'Accounting Initialized'
                                        : 'Not Initialized',
                                    badgeColor: st?.initialized == true
                                        ? AppColors.success
                                        : AppColors.warning,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildDiagnosticMetricCard(
                                          title: 'Missing Ledgers',
                                          valueText:
                                              '${st?.missingDefaultLedgersCount ?? 0}',
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: _buildDiagnosticMetricCard(
                                          title: 'Missing Groups',
                                          valueText:
                                              '${st?.missingDefaultGroupsCount ?? 0}',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            }

                            return diagnosticCards;
                          },
                        ),
                        const SizedBox(height: 10),

                        // Validation Card Summary
                        if (val != null) ...[
                          AppCard(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      val.valid
                                          ? Icons.check_circle_outline
                                          : Icons.warning_amber_rounded,
                                      color: val.valid
                                          ? AppColors.success
                                          : AppColors.warning,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      val.valid
                                          ? 'Valid Configuration'
                                          : '${val.missingLedgers.length} Missing Ledger Mapping(s)',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: val.valid
                                            ? AppColors.success
                                            : AppColors.warning,
                                      ),
                                    ),
                                  ],
                                ),
                                if (val.warnings.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  ...val.warnings.map(
                                    (w) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 4.0,
                                      ),
                                      child: Text(
                                        '• $w',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.warning,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),

                        // 3. Default Ledger Mapping Section (11 Ledgers)
                        const Text(
                          'DEFAULT LEDGER MAPPING',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final cols = constraints.maxWidth < 600
                                ? 1
                                : (constraints.maxWidth < 1000 ? 2 : 3);

                            final mappingFields = [
                              _buildLedgerSelectCard(
                                label: 'Default Cash Ledger',
                                value: controller.defaultCashLedgerId,
                                filterType: 'CASH',
                                isDark: isDark,
                              ),
                              _buildLedgerSelectCard(
                                label: 'Default Bank Ledger',
                                value: controller.defaultBankLedgerId,
                                filterType: 'BANK',
                                isDark: isDark,
                              ),
                              _buildLedgerSelectCard(
                                label: 'Default Sales Ledger',
                                value: controller.defaultSalesLedgerId,
                                filterType: 'SALES',
                                isDark: isDark,
                              ),
                              _buildLedgerSelectCard(
                                label: 'Default Purchase Ledger',
                                value: controller.defaultPurchaseLedgerId,
                                filterType: 'PURCHASE',
                                isDark: isDark,
                              ),
                              _buildLedgerSelectCard(
                                label: 'Default Sales Return Ledger',
                                value: controller.defaultSalesReturnLedgerId,
                                filterType: 'SALES_RETURN',
                                isDark: isDark,
                              ),
                              _buildLedgerSelectCard(
                                label: 'Default Purchase Return Ledger',
                                value: controller.defaultPurchaseReturnLedgerId,
                                filterType: 'PURCHASE_RETURN',
                                isDark: isDark,
                              ),
                              _buildLedgerSelectCard(
                                label: 'Default Round Off Ledger',
                                value: controller.defaultRoundOffLedgerId,
                                filterType: 'ROUND_OFF',
                                isDark: isDark,
                              ),
                              _buildLedgerSelectCard(
                                label: 'Discount Given Ledger',
                                value: controller.defaultDiscountGivenLedgerId,
                                filterType: 'DISCOUNT',
                                isDark: isDark,
                              ),
                              _buildLedgerSelectCard(
                                label: 'Discount Received Ledger',
                                value:
                                    controller.defaultDiscountReceivedLedgerId,
                                filterType: 'DISCOUNT',
                                isDark: isDark,
                              ),
                              _buildLedgerSelectCard(
                                label: 'Default Stock Ledger',
                                value: controller.defaultStockLedgerId,
                                filterType: 'STOCK',
                                isDark: isDark,
                              ),
                              _buildLedgerSelectCard(
                                label: 'Default COGS Ledger',
                                value: controller.defaultCOGSLedgerId,
                                filterType: 'EXPENSE',
                                isDark: isDark,
                              ),
                            ];

                            return GridView.count(
                              crossAxisCount: cols,
                              childAspectRatio: cols == 1 ? 3.5 : 2.5,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              children: mappingFields,
                            );
                          },
                        ),
                        const SizedBox(height: 24),
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
    required bool isDark,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(12),
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
                const SizedBox(height: 2),
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

  Widget _buildLedgerSelectCard({
    required String label,
    required RxString value,
    required String filterType,
    required bool isDark,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Obx(() {
            final String targetId = value.value;
            final options = controller.getLedgersByType(filterType);

            final effectiveList = options.any((l) => l.id == targetId)
                ? options
                : (controller.availableLedgers.any((l) => l.id == targetId)
                      ? controller.availableLedgers
                      : options);

            final String selectedVal =
                effectiveList.any((l) => l.id == targetId) ? targetId : '';

            return DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: selectedVal,
              dropdownColor: isDark ? AppColors.cardDark : AppColors.cardLight,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                filled: true,
                fillColor: isDark ? AppColors.inputDark : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: AppRadius.md,
                  borderSide: BorderSide(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                  ),
                ),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: '',
                  child: Text(
                    'Not configured',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ),
                ...effectiveList.map((l) {
                  return DropdownMenuItem<String>(
                    value: l.id,
                    child: Text(
                      '${l.name} (${l.code})',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11),
                    ),
                  );
                }),
              ],
              onChanged: (val) {
                value.value = val ?? '';
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDiagnosticMetricCard({
    required String title,
    String? badgeText,
    Color? badgeColor,
    String? valueText,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 6),
          if (badgeText != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: (badgeColor ?? AppColors.primary).withAlpha(20),
                borderRadius: AppRadius.full,
              ),
              child: Text(
                badgeText,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: badgeColor ?? AppColors.primary,
                ),
              ),
            ),
          if (valueText != null)
            Text(
              valueText,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

  Future<void> _pickLockDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          DateTime.tryParse(controller.lockBooksTillDate.value) ??
          DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      final formatted = picked.toIso8601String().split('T')[0];
      controller.lockBooksTillDate.value = formatted;
      controller.lockBooksDateTextController.text = formatted;
    }
  }
}
