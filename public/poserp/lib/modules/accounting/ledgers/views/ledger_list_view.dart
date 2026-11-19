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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Toolbar
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;

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
                                Icons.format_list_bulleted_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'Account Ledgers',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Professional ledger list with balances and statement access.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Obx(
                                () => AppButton(
                                  text: 'Restore Defaults',
                                  variant: AppButtonVariant.outline,
                                  icon: const Icon(
                                    Icons.settings_backup_restore_rounded,
                                    size: 14,
                                  ),
                                  height: 36,
                                  isLoading: controller.isRestoring.value,
                                  onPressed: () => controller.restoreDefaults(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: AppButton(
                                text: 'Refresh',
                                icon: const Icon(
                                  Icons.refresh_rounded,
                                  size: 14,
                                ),
                                height: 36,
                                onPressed: () => controller.loadLedgers(),
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
                                'Ledgers',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Professional ledger list with balances and statement access.',
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
                  );
                },
              ),
              const SizedBox(height: 16),

              // Filter Bar (5 Filters: Search, Group, Ledger Type, Nature, Status)
              AppCard(
                padding: const EdgeInsets.all(12),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 600;

                    final searchInput = TextField(
                      onChanged: (val) => controller.searchQuery.value = val,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Search name or code...',
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
                    );

                    final groupDropdown = Obx(
                      () => DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: controller.selectedGroup.value,
                        dropdownColor: isDark
                            ? AppColors.cardDark
                            : AppColors.cardLight,
                        decoration: _buildDropdownDecoration(isDark),
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
                    );

                    final typeDropdown = Obx(
                      () => DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: controller.selectedLedgerType.value,
                        dropdownColor: isDark
                            ? AppColors.cardDark
                            : AppColors.cardLight,
                        decoration: _buildDropdownDecoration(isDark),
                        items: controller.availableTypes.map((t) {
                          return DropdownMenuItem<String>(
                            value: t,
                            child: Text(
                              t == 'ALL' ? 'All Types' : t,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            controller.selectedLedgerType.value = val;
                          }
                        },
                      ),
                    );

                    final natureDropdown = Obx(
                      () => DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: controller.selectedNature.value,
                        dropdownColor: isDark
                            ? AppColors.cardDark
                            : AppColors.cardLight,
                        decoration: _buildDropdownDecoration(isDark),
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
                    );

                    final statusDropdown = Obx(
                      () => DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: controller.selectedStatus.value,
                        dropdownColor: isDark
                            ? AppColors.cardDark
                            : AppColors.cardLight,
                        decoration: _buildDropdownDecoration(isDark),
                        items: const [
                          DropdownMenuItem(
                            value: 'ALL',
                            child: Text('All Status'),
                          ),
                          DropdownMenuItem(
                            value: 'ACTIVE',
                            child: Text('Active'),
                          ),
                          DropdownMenuItem(
                            value: 'INACTIVE',
                            child: Text('Inactive'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            controller.selectedStatus.value = val;
                          }
                        },
                      ),
                    );

                    if (isMobile) {
                      return Column(
                        children: [
                          searchInput,
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(child: groupDropdown),
                              const SizedBox(width: 8),
                              Expanded(child: typeDropdown),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(child: natureDropdown),
                              const SizedBox(width: 8),
                              Expanded(child: statusDropdown),
                            ],
                          ),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(flex: 2, child: searchInput),
                        const SizedBox(width: 8),
                        Expanded(child: groupDropdown),
                        const SizedBox(width: 8),
                        Expanded(child: typeDropdown),
                        const SizedBox(width: 8),
                        Expanded(child: natureDropdown),
                        const SizedBox(width: 8),
                        Expanded(child: statusDropdown),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Data Table (10 Columns matching Next.js)
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
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 900),
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
                                    'LEDGER TYPE',
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
                                    'SYSTEM',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'STATUS',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'ACTIONS',
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
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withAlpha(20),
                                          borderRadius: AppRadius.sm,
                                          border: Border.all(
                                            color: Colors.grey.withAlpha(50),
                                          ),
                                        ),
                                        child: Text(
                                          l.ledgerType,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
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
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'monospace',
                                          color:
                                              l.currentBalanceType == 'CREDIT'
                                              ? AppColors.success
                                              : AppColors.primary,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              (l.isSystemDefault
                                                      ? AppColors.primary
                                                      : Colors.grey)
                                                  .withAlpha(20),
                                          borderRadius: AppRadius.full,
                                        ),
                                        child: Text(
                                          l.isSystemDefault
                                              ? 'System'
                                              : 'Custom',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: l.isSystemDefault
                                                ? AppColors.primary
                                                : Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              (l.isActive
                                                      ? AppColors.success
                                                      : Colors.grey)
                                                  .withAlpha(20),
                                          borderRadius: AppRadius.full,
                                        ),
                                        child: Text(
                                          l.isActive ? 'Active' : 'Inactive',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: l.isActive
                                                ? AppColors.success
                                                : Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      AppButton(
                                        text: 'Statement',
                                        variant: AppButtonVariant.outline,
                                        icon: const Icon(
                                          Icons.visibility_outlined,
                                          size: 14,
                                        ),
                                        height: 32,
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

  InputDecoration _buildDropdownDecoration(bool isDark) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      filled: true,
      fillColor: isDark ? AppColors.inputDark : Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: AppRadius.md,
        borderSide: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
    );
  }

  Color _getNatureColor(String nature) {
    final n = nature.toUpperCase();
    if (n.contains('ASSET')) return AppColors.info;
    if (n.contains('LIAB')) return AppColors.danger;
    if (n.contains('EQUITY')) return AppColors.warning;
    if (n.contains('INCOME') || n.contains('REVENUE')) return AppColors.success;
    return Colors.purple;
  }
}
