import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/ledger_list_controller.dart';

class LedgerListView extends GetView<LedgerListController> {
  const LedgerListView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                          Icons.format_list_bulleted_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Account Ledgers',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'General and party ledger master accounts with running debit/credit balances.',
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
                          text: 'Restore Defaults',
                          variant: AppButtonVariant.outline,
                          icon: const Icon(
                            Icons.settings_backup_restore_rounded,
                            size: 16,
                          ),
                          isLoading: controller.isRestoring.value,
                          onPressed: () => controller.restoreDefaults(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      AppButton(
                        text: 'Refresh',
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        onPressed: () => controller.loadLedgers(),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Filter Bar
              AppCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        onChanged: (val) => controller.searchQuery.value = val,
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Search ledger name or code...',
                          prefixIcon: const Icon(Icons.search, size: 18),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
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
                    const SizedBox(width: 10),

                    // Group Filter
                    Obx(
                      () => SizedBox(
                        width: 160,
                        child: DropdownButtonFormField<String>(
                          initialValue: controller.selectedGroup.value,
                          dropdownColor: isDark
                              ? AppColors.cardDark
                              : AppColors.cardLight,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
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
                          items: controller.availableGroups.map((g) {
                            return DropdownMenuItem<String>(
                              value: g,
                              child: Text(
                                g == 'ALL' ? 'All Groups' : g,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              controller.selectedGroup.value = val;
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Nature Filter
                    Obx(
                      () => SizedBox(
                        width: 140,
                        child: DropdownButtonFormField<String>(
                          initialValue: controller.selectedNature.value,
                          dropdownColor: isDark
                              ? AppColors.cardDark
                              : AppColors.cardLight,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
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
                          items: const [
                            DropdownMenuItem(
                              value: 'ALL',
                              child: Text('All Nature'),
                            ),
                            DropdownMenuItem(
                              value: 'ASSET',
                              child: Text('Assets'),
                            ),
                            DropdownMenuItem(
                              value: 'LIABILITY',
                              child: Text('Liabilities'),
                            ),
                            DropdownMenuItem(
                              value: 'INCOME',
                              child: Text('Income'),
                            ),
                            DropdownMenuItem(
                              value: 'EXPENSE',
                              child: Text('Expenses'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              controller.selectedNature.value = val;
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Data Table
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const LoadingIndicator();
                  }
                  if (controller.ledgers.isEmpty) {
                    return EmptyState(
                      icon: Icons.format_list_bulleted_rounded,
                      title: 'No Ledgers Found',
                      description:
                          'Try clearing search filters or restore default system ledgers.',
                      action: AppButton(
                        text: 'Restore Default Ledgers',
                        icon: const Icon(
                          Icons.settings_backup_restore_rounded,
                          size: 16,
                        ),
                        onPressed: () => controller.restoreDefaults(),
                      ),
                    );
                  }

                  return AppCard(
                    padding: EdgeInsets.zero,
                    child: ClipRRect(
                      borderRadius: AppRadius.lg,
                      child: SingleChildScrollView(
                        child: DataTable(
                          columnSpacing: 18,
                          headingRowColor: WidgetStateProperty.all(
                            isDark ? AppColors.inputDark : Colors.grey[100],
                          ),
                          columns: const [
                            DataColumn(
                              label: Text(
                                'LEDGER NAME',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'CODE',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'GROUP',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'NATURE',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'TYPE',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            DataColumn(
                              numeric: true,
                              label: Text(
                                'OPENING BALANCE',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            DataColumn(
                              numeric: true,
                              label: Text(
                                'CURRENT BALANCE',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'ACTION',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                          rows: controller.ledgers.map((l) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    l.name,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    l.code,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'monospace',
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    l.groupName,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getNatureColor(
                                        l.nature,
                                      ).withAlpha(20),
                                      borderRadius: AppRadius.full,
                                    ),
                                    child: Text(
                                      l.nature.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: _getNatureColor(l.nature),
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    l.ledgerType,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    '₹${l.openingBalance.toStringAsFixed(2)} ${l.openingBalanceType == 'CREDIT' ? 'Cr' : 'Dr'}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    '₹${l.currentBalance.toStringAsFixed(2)} ${l.currentBalanceType == 'CREDIT' ? 'Cr' : 'Dr'}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'monospace',
                                      color: AppColors.success,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  AppButton(
                                    text: 'Statement',
                                    variant: AppButtonVariant.outline,
                                    icon: const Icon(
                                      Icons.receipt_long_outlined,
                                      size: 14,
                                    ),
                                    onPressed: () {
                                      Get.toNamed(
                                        '/accounting/ledgers/${l.id}',
                                        arguments: l.id,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
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

  Color _getNatureColor(String nature) {
    final n = nature.toLowerCase();
    if (n.contains('asset')) return AppColors.info;
    if (n.contains('liab')) return AppColors.danger;
    if (n.contains('equity')) return AppColors.warning;
    if (n.contains('income') || n.contains('revenue')) return AppColors.success;
    return Colors.purple;
  }
}
