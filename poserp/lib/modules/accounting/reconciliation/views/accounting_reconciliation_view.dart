import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(25),
                            borderRadius: AppRadius.lg,
                          ),
                          child: const Icon(
                            Icons.shield_outlined,
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
                                'Accounting Reconciliation',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Compare posted vouchers with ledger, cash/bank, party, and GST records.',
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
                  const SizedBox(width: 16),
                  Obx(
                    () => AppButton(
                      text: 'Refresh',
                      icon: controller.isLoading.value
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            )
                          : const Icon(Icons.refresh_rounded, size: 16),
                      variant: AppButtonVariant.outline,
                      onPressed: controller.isLoading.value
                          ? null
                          : () => controller.loadAll(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 2. Navigation Tabs Bar
              AppCard(
                padding: const EdgeInsets.all(6),
                child: Obx(
                  () => SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildTab(
                          'ledgers',
                          'Ledger Balances',
                          Icons.account_balance_wallet_outlined,
                        ),
                        const SizedBox(width: 6),
                        _buildTab(
                          'cash-bank',
                          'Cash & Bank',
                          Icons.savings_outlined,
                        ),
                        const SizedBox(width: 6),
                        _buildTab('parties', 'Parties', Icons.people_outline),
                        const SizedBox(width: 6),
                        _buildTab('gst', 'GST', Icons.receipt_long_outlined),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 3. Tab Body Content
              Obx(() {
                if (controller.isLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: LoadingIndicator(),
                  );
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

  // ---------------------------------------------------------------------------
  // TAB 1: LEDGER BALANCES
  // ---------------------------------------------------------------------------
  Widget _buildLedgersTab(bool isDark) {
    final rows = controller.ledgerMismatches;
    final mismatchCount = rows.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 12,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Row(
                  children: [
                    _buildStatusPill(
                      mismatchCount == 0 ? 'ok' : 'mismatch',
                      mismatchCount == 0
                          ? '0 mismatches'
                          : '$mismatchCount mismatch(es)',
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        mismatchCount == 0
                            ? 'Ledger balances match posted vouchers.'
                            : 'Discrepancies detected between stored balances and posted voucher lines.',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              ),
              Obx(() {
                final isFixing = controller.isFixing.value;
                return AppButton(
                  text: isFixing ? 'Fixing...' : 'Fix Ledger Balances',
                  icon: isFixing
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.build_circle_outlined, size: 16),
                  variant: AppButtonVariant.outline,
                  onPressed: isFixing || mismatchCount == 0
                      ? null
                      : () => controller.fixLedgerBalances(),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (rows.isEmpty)
          AppCard(
            padding: const EdgeInsets.all(32),
            child: const EmptyState(
              icon: Icons.task_alt_rounded,
              title: 'All Ledgers Reconciled',
              description: 'Ledger balances match posted vouchers perfectly.',
            ),
          )
        else
          AppCard(
            padding: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: AppRadius.lg,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
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
                              width: 240,
                              child: Text(
                                'LEDGER',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 160,
                              child: Text(
                                'STORED',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 160,
                              child: Text(
                                'EXPECTED',
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
                                'DIFFERENCE',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              child: Text(
                                'STATUS',
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
                        children: List.generate(rows.length, (index) {
                          final r = rows[index];
                          final isOdd = index % 2 == 1;

                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isOdd
                                  ? (isDark
                                        ? AppColors.inputDark.withAlpha(40)
                                        : Colors.grey[50])
                                  : Colors.transparent,
                              border: Border(
                                bottom: BorderSide(
                                  color: isDark
                                      ? AppColors.borderDark.withAlpha(30)
                                      : Colors.grey[200]!,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 240,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        r.ledgerName,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (r.code.isNotEmpty)
                                        Text(
                                          r.code,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[600],
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 160,
                                  child: Text(
                                    '₹ ${r.storedBalance.toStringAsFixed(2)} ${r.storedBalanceType}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 160,
                                  child: Text(
                                    '₹ ${r.expectedBalance.toStringAsFixed(2)} ${r.expectedBalanceType}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 140,
                                  child: Text(
                                    '₹ ${r.difference.abs().toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.danger,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 100,
                                  child: _buildStatusPill(r.status, r.status),
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
            ),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 2: CASH & BANK ACCOUNTS
  // ---------------------------------------------------------------------------
  Widget _buildCashBankTab(bool isDark) {
    final accounts = controller.cashBankAccounts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 12,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Cash & Bank Ledger Mapping',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Link missing accounts first. Recalculate ledger balances only after mappings are correct.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Obx(() {
                    final isFixing = controller.isFixing.value;
                    return AppButton(
                      text: isFixing ? 'Linking...' : 'Link Cash/Bank Ledgers',
                      icon: const Icon(Icons.link_rounded, size: 16),
                      variant: AppButtonVariant.outline,
                      onPressed: isFixing
                          ? null
                          : () => controller.linkCashBankLedgers(),
                    );
                  }),
                  Obx(() {
                    final isFixing = controller.isFixing.value;
                    return AppButton(
                      text: isFixing ? 'Posting...' : 'Post Opening Balances',
                      icon: const Icon(
                        Icons.account_balance_outlined,
                        size: 16,
                      ),
                      variant: AppButtonVariant.outline,
                      onPressed: isFixing
                          ? null
                          : () => controller.postCashBankOpeningBalances(),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (accounts.isEmpty)
          AppCard(
            padding: const EdgeInsets.all(32),
            child: const EmptyState(
              icon: Icons.savings_outlined,
              title: 'No Cash or Bank Accounts Found',
              description: 'No active cash or bank accounts are configured.',
            ),
          )
        else
          Column(
            children: List.generate(accounts.length, (index) {
              final acc = accounts[index];
              final hasDiff = acc.difference.abs() > 0.01;

              return Padding(
                padding: const EdgeInsets.only(bottom: 14.0),
                child: AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        children: [
                          Expanded(
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                Text(
                                  acc.accountName,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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
                                _buildStatusPill(acc.status, acc.status),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.inputDark
                                  : Colors.grey[100],
                              borderRadius: AppRadius.md,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'DIFFERENCE',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  '₹ ${acc.difference.abs().toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: hasDiff
                                        ? AppColors.danger
                                        : AppColors.success,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      if (acc.mappedLedgerName != null)
                        Text(
                          'Mapped to ${acc.mappedLedgerName} · ${acc.mappedLedgerCode ?? ''}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        )
                      else
                        const Text(
                          'No accounting ledger linked.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.warning,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      const SizedBox(height: 14),

                      // 5 Balance Metric Cards Grid
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final cols = constraints.maxWidth < 600
                              ? 2
                              : (constraints.maxWidth < 1100 ? 3 : 5);

                          return GridView.count(
                            crossAxisCount: cols,
                            childAspectRatio: cols == 5 ? 2.1 : 2.4,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              _buildMetricTile(
                                'Opening Balance',
                                '₹ ${acc.openingBalance.toStringAsFixed(2)}',
                                isDark,
                              ),
                              _buildMetricTile(
                                'Cash/Bank Balance',
                                '₹ ${acc.currentBalance.toStringAsFixed(2)}',
                                isDark,
                              ),
                              _buildMetricTile(
                                'Transaction Balance',
                                '₹ ${acc.transactionBalance.toStringAsFixed(2)}',
                                isDark,
                              ),
                              _buildMetricTile(
                                'Ledger Balance',
                                acc.ledgerBalance == null
                                    ? 'Not linked'
                                    : '₹ ${acc.ledgerBalance!.toStringAsFixed(2)}',
                                isDark,
                                isMuted: acc.ledgerBalance == null,
                              ),
                              _buildMetricTile(
                                acc.openingPosted
                                    ? 'Opening Voucher'
                                    : 'Ledger Opening',
                                acc.openingPosted
                                    ? (acc.openingVoucherNo ?? 'Posted')
                                    : (acc.mappedLedgerCode != null
                                          ? acc.mappedLedgerCode!
                                          : 'Not linked'),
                                isDark,
                                isMuted: acc.mappedLedgerCode == null,
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 12),

                      // Suggested Fix Container
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.inputDark.withAlpha(50)
                              : Colors.grey[50],
                          borderRadius: AppRadius.md,
                          border: Border.all(
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.borderLight,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'SUGGESTED FIX',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              acc.suggestedFix,
                              style: const TextStyle(fontSize: 12),
                            ),
                            if (acc.openingBalanceDifference != null &&
                                acc.openingBalanceDifference!.abs() > 0.01) ...[
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withAlpha(25),
                                  borderRadius: AppRadius.sm,
                                ),
                                child: Text(
                                  'Opening difference ₹ ${acc.openingBalanceDifference!.abs().toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.warning,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 3: PARTIES
  // ---------------------------------------------------------------------------
  Widget _buildPartiesTab(bool isDark) {
    final rows = controller.partyRows;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 12,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Party Ledger Mapping',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Ensure every active customer and supplier has a matching accounting ledger.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Obx(() {
                final isFixing = controller.isFixing.value;
                return AppButton(
                  text: isFixing ? 'Linking...' : 'Link Party Ledgers',
                  icon: const Icon(Icons.people_outline, size: 16),
                  variant: AppButtonVariant.outline,
                  onPressed: isFixing
                      ? null
                      : () => controller.linkPartyLedgers(),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (rows.isEmpty)
          AppCard(
            padding: const EdgeInsets.all(32),
            child: const EmptyState(
              icon: Icons.people_outline,
              title: 'No Parties Found',
              description: 'No active customer or supplier accounts found.',
            ),
          )
        else
          AppCard(
            padding: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: AppRadius.lg,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 850),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
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
                              width: 180,
                              child: Text(
                                'PARTY',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 150,
                              child: Text(
                                'BUSINESS BAL',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 180,
                              child: Text(
                                'PARTY LEDGER',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 150,
                              child: Text(
                                'ACCOUNTING LEDGER',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 120,
                              child: Text(
                                'DIFFERENCE',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              child: Text(
                                'STATUS',
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
                        children: List.generate(rows.length, (index) {
                          final r = rows[index];
                          final isOdd = index % 2 == 1;
                          final hasDiff = r.difference.abs() > 0.01;

                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isOdd
                                  ? (isDark
                                        ? AppColors.inputDark.withAlpha(40)
                                        : Colors.grey[50])
                                  : Colors.transparent,
                              border: Border(
                                bottom: BorderSide(
                                  color: isDark
                                      ? AppColors.borderDark.withAlpha(30)
                                      : Colors.grey[200]!,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                // 1. Party
                                SizedBox(
                                  width: 180,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        r.partyName,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        r.partyType.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // 2. Business Balance
                                SizedBox(
                                  width: 150,
                                  child: Text(
                                    '₹ ${r.businessBalance.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),

                                // 3. Party Ledger
                                SizedBox(
                                  width: 180,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        r.partyLedgerBalance == null
                                            ? '-'
                                            : '₹ ${r.partyLedgerBalance!.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                      if (r.partyLedgerEntryCount > 0)
                                        Text(
                                          '${r.partyLedgerEntryCount} entry(ies)${r.lastReceiptNo != null ? ' · Last ${r.lastReceiptNo}' : ''}',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey[600],
                                          ),
                                        )
                                      else
                                        Text(
                                          'No history',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),

                                // 4. Accounting Ledger
                                SizedBox(
                                  width: 150,
                                  child: Text(
                                    r.accountingBalance == null
                                        ? 'Not linked'
                                        : '₹ ${r.accountingBalance!.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'monospace',
                                      color: r.accountingBalance == null
                                          ? Colors.grey
                                          : null,
                                    ),
                                  ),
                                ),

                                // 5. Difference
                                SizedBox(
                                  width: 120,
                                  child: Text(
                                    '₹ ${r.difference.abs().toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: hasDiff
                                          ? AppColors.danger
                                          : AppColors.success,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),

                                // 6. Status
                                SizedBox(
                                  width: 100,
                                  child: _buildStatusPill(r.status, r.status),
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
            ),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 4: GST TAX RECONCILIATION
  // ---------------------------------------------------------------------------
  Widget _buildGstTab(bool isDark) {
    final rows = controller.gstRows;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: const [
              Icon(Icons.info_outline_rounded, size: 16, color: Colors.grey),
              SizedBox(width: 8),
              Text(
                'GST reconciliation is view-only.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (rows.isEmpty)
          AppCard(
            padding: const EdgeInsets.all(32),
            child: const EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No GST Ledgers Found',
              description: 'No GST tax ledger accounts are configured.',
            ),
          )
        else
          AppCard(
            padding: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: AppRadius.lg,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 750),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
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
                              width: 180,
                              child: Text(
                                'GST LEDGER',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 160,
                              child: Text(
                                'REPORT AMOUNT',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 160,
                              child: Text(
                                'ACTUAL LEDGER',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 150,
                              child: Text(
                                'DIFFERENCE',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              child: Text(
                                'STATUS',
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
                        children: List.generate(rows.length, (index) {
                          final r = rows[index];
                          final isOdd = index % 2 == 1;
                          final hasDiff = r.difference.abs() > 0.01;

                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isOdd
                                  ? (isDark
                                        ? AppColors.inputDark.withAlpha(40)
                                        : Colors.grey[50])
                                  : Colors.transparent,
                              border: Border(
                                bottom: BorderSide(
                                  color: isDark
                                      ? AppColors.borderDark.withAlpha(30)
                                      : Colors.grey[200]!,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 180,
                                  child: Text(
                                    r.ledgerCode,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 160,
                                  child: Text(
                                    '₹ ${r.expected.toStringAsFixed(2)} ${r.expectedType}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 160,
                                  child: Text(
                                    '₹ ${r.actual.toStringAsFixed(2)} ${r.actualType}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 150,
                                  child: Text(
                                    '₹ ${r.difference.abs().toStringAsFixed(2)} ${r.difference < 0 ? "CREDIT" : "DEBIT"}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: hasDiff
                                          ? AppColors.danger
                                          : AppColors.success,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 100,
                                  child: _buildStatusPill(r.status, r.status),
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
            ),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // HELPER WIDGETS
  // ---------------------------------------------------------------------------
  Widget _buildMetricTile(
    String label,
    String value,
    bool isDark, {
    bool isMuted = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.inputDark : Colors.white,
        borderRadius: AppRadius.md,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isMuted ? Colors.grey : null,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill(String status, String label) {
    Color bg = AppColors.success;
    Color fg = AppColors.success;

    if (status == 'ok') {
      bg = AppColors.success;
      fg = AppColors.success;
    } else if (status.startsWith('missing_')) {
      bg = AppColors.warning;
      fg = AppColors.warning;
    } else {
      bg = AppColors.danger;
      fg = AppColors.danger;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg.withAlpha(25),
        borderRadius: AppRadius.sm,
        border: Border.all(color: fg.withAlpha(60), width: 0.8),
      ),
      child: Text(
        label.toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }
}
