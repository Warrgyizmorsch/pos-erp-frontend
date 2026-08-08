import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/accounting_reconciliation_controller.dart';

class AccountingReconciliationView
    extends GetView<AccountingReconciliationController> {
  const AccountingReconciliationView({super.key});

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
                          Icons.published_with_changes_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Accounting Reconciliation Hub',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Compare posted double-entry vouchers with ledgers, cash/bank, party, and GST balances.',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  AppButton(
                    text: 'Refresh Data',
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    variant: AppButtonVariant.outline,
                    onPressed: () => controller.loadAll(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Navigation Tabs
              AppCard(
                padding: const EdgeInsets.all(8),
                child: Obx(
                  () => Row(
                    children: [
                      _buildTab(
                        'ledgers',
                        'Ledger Balances',
                        Icons.account_balance_wallet_outlined,
                      ),
                      const SizedBox(width: 8),
                      _buildTab(
                        'cash-bank',
                        'Cash & Bank Accounts',
                        Icons.savings_outlined,
                      ),
                      const SizedBox(width: 8),
                      _buildTab(
                        'parties',
                        'Party Accounts',
                        Icons.people_outline,
                      ),
                      const SizedBox(width: 8),
                      _buildTab(
                        'gst',
                        'GST Tax Reconciliation',
                        Icons.receipt_long_outlined,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Tab Body Content
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const LoadingIndicator();
                  }

                  final currentTab = controller.activeTab.value;
                  if (currentTab == 'ledgers') {
                    return _buildLedgersTab(isDark);
                  }
                  if (currentTab == 'cash-bank') {
                    return _buildCashBankTab(isDark);
                  }
                  if (currentTab == 'parties') {
                    return _buildPartiesTab(isDark);
                  }
                  return _buildGstTab(isDark);
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String key, String title, IconData icon) {
    final isSelected = controller.activeTab.value == key;
    return InkWell(
      onTap: () => controller.activeTab.value = key,
      borderRadius: AppRadius.md,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withAlpha(25)
              : Colors.transparent,
          borderRadius: AppRadius.md,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.primary : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primary : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLedgersTab(bool isDark) {
    final rows = controller.ledgerMismatches;
    return Column(
      children: [
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${rows.length} Stored Ledger Balance Mismatch(es) Found',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppButton(
                text: 'Recalculate Ledger Balances',
                icon: const Icon(Icons.build_circle_outlined, size: 16),
                variant: AppButtonVariant.outline,
                onPressed: () => controller.fixLedgerBalances(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: AppCard(
            padding: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: AppRadius.lg,
              child: SingleChildScrollView(
                child: DataTable(
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
                      numeric: true,
                      label: Text(
                        'STORED BALANCE',
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
                        'EXPECTED BALANCE',
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
                        'DIFFERENCE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                  rows: rows.map((r) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            r.ledgerName,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            '₹${r.storedBalance.toStringAsFixed(2)} ${r.storedBalanceType}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        DataCell(
                          Text(
                            '₹${r.expectedBalance.toStringAsFixed(2)} ${r.expectedBalanceType}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        DataCell(
                          Text(
                            '₹${r.difference.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.danger,
                            ),
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
      ],
    );
  }

  Widget _buildCashBankTab(bool isDark) {
    final accounts = controller.cashBankAccounts;
    return Column(
      children: [
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Cash & Bank Ledger Alignment',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  AppButton(
                    text: 'Link Cash/Bank Ledgers',
                    icon: const Icon(Icons.link_rounded, size: 16),
                    variant: AppButtonVariant.outline,
                    onPressed: () => controller.linkCashBankLedgers(),
                  ),
                  const SizedBox(width: 8),
                  AppButton(
                    text: 'Post Opening Balances',
                    icon: const Icon(Icons.account_balance_outlined, size: 16),
                    variant: AppButtonVariant.outline,
                    onPressed: () => controller.postCashBankOpeningBalances(),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: accounts.length,
            itemBuilder: (context, index) {
              final acc = accounts[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                acc.accountName,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withAlpha(20),
                                  borderRadius: AppRadius.full,
                                ),
                                child: Text(
                                  acc.accountType,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Difference: ₹${acc.difference.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: acc.difference.abs() > 0.01
                                  ? AppColors.danger
                                  : AppColors.success,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Suggested Fix: ${acc.suggestedFix}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPartiesTab(bool isDark) {
    final rows = controller.partyRows;
    return Column(
      children: [
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Party Ledger Mapping & Outstanding Balances',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              AppButton(
                text: 'Link Party Ledgers',
                icon: const Icon(Icons.people_outline, size: 16),
                variant: AppButtonVariant.outline,
                onPressed: () => controller.linkPartyLedgers(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: AppCard(
            padding: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: AppRadius.lg,
              child: SingleChildScrollView(
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    isDark ? AppColors.inputDark : Colors.grey[100],
                  ),
                  columns: const [
                    DataColumn(
                      label: Text(
                        'PARTY NAME',
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
                        'BUSINESS BALANCE',
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
                        'ACCOUNTING LEDGER BALANCE',
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
                        'DIFFERENCE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                  rows: rows.map((r) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            '${r.partyName} (${r.partyType})',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            '₹${r.businessBalance.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        DataCell(
                          Text(
                            r.accountingBalance != null
                                ? '₹${r.accountingBalance!.toStringAsFixed(2)}'
                                : 'Not Linked',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        DataCell(
                          Text(
                            '₹${r.difference.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: r.difference.abs() > 0.01
                                  ? AppColors.danger
                                  : AppColors.success,
                            ),
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
      ],
    );
  }

  Widget _buildGstTab(bool isDark) {
    final rows = controller.gstRows;
    return AppCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: AppRadius.lg,
        child: SingleChildScrollView(
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(
              isDark ? AppColors.inputDark : Colors.grey[100],
            ),
            columns: const [
              DataColumn(
                label: Text(
                  'GST LEDGER CODE',
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
                  'REPORT AMOUNT',
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
                  'ACTUAL LEDGER AMOUNT',
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
                  'DIFFERENCE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
            rows: rows.map((r) {
              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      r.ledgerCode,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      '₹${r.expected.toStringAsFixed(2)} ${r.expectedType}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  DataCell(
                    Text(
                      '₹${r.actual.toStringAsFixed(2)} ${r.actualType}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  DataCell(
                    Text(
                      '₹${r.difference.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: r.difference.abs() > 0.01
                            ? AppColors.danger
                            : AppColors.success,
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
