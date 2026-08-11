import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/accounting_dashboard_controller.dart';

class AccountingDashboardView extends GetView<AccountingDashboardController> {
  const AccountingDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => controller.loadDashboard(),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.dashboard.value == null) {
                return const SizedBox(height: 400, child: LoadingIndicator());
              }

              final dash = controller.dashboard.value!;

              return LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Responsive Header
                      if (isMobile) ...[
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(25),
                                borderRadius: AppRadius.md,
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet_outlined,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'Financial Accounting Overview',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Double-entry chart of accounts, vouchers & financial books.',
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
                                text: 'Refresh',
                                icon: const Icon(
                                  Icons.refresh_rounded,
                                  size: 16,
                                ),
                                variant: AppButtonVariant.outline,
                                onPressed: () => controller.loadDashboard(),
                              ),
                            ),
                            if (!dash.isInitialized) ...[
                              const SizedBox(width: 8),
                              Expanded(
                                child: AppButton(
                                  text: controller.isInitializing.value
                                      ? 'Initializing...'
                                      : 'Initialize Engine',
                                  icon: const Icon(
                                    Icons.flash_on_rounded,
                                    size: 16,
                                  ),
                                  onPressed: controller.isInitializing.value
                                      ? null
                                      : () => controller
                                            .initializeAccountingEngine(),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ] else ...[
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
                                    Icons.account_balance_wallet_outlined,
                                    color: AppColors.primary,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Financial Accounting Overview',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Double-entry chart of accounts, vouchers, and financial book status.',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                AppButton(
                                  text: 'Refresh Data',
                                  icon: const Icon(
                                    Icons.refresh_rounded,
                                    size: 16,
                                  ),
                                  variant: AppButtonVariant.outline,
                                  onPressed: () => controller.loadDashboard(),
                                ),
                                const SizedBox(width: 8),
                                if (!dash.isInitialized)
                                  AppButton(
                                    text: controller.isInitializing.value
                                        ? 'Initializing...'
                                        : 'Initialize Engine',
                                    icon: const Icon(
                                      Icons.flash_on_rounded,
                                      size: 16,
                                    ),
                                    onPressed: controller.isInitializing.value
                                        ? null
                                        : () => controller
                                              .initializeAccountingEngine(),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 16),

                      // Engine Health Status & System Warnings
                      if (dash.missingDefaultLedgersCount > 0) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withAlpha(20),
                            borderRadius: AppRadius.md,
                            border: Border.all(
                              color: AppColors.warning.withAlpha(80),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: AppColors.warning,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Missing ${dash.missingDefaultLedgersCount} default system ledgers in Chart of Accounts.',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              AppButton(
                                text: controller.isRestoringLedgers.value
                                    ? 'Restoring...'
                                    : 'Restore Defaults',
                                variant: AppButtonVariant.outline,
                                onPressed: controller.isRestoringLedgers.value
                                    ? null
                                    : () => controller.restoreDefaultLedgers(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Metrics Cards Grid
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: isMobile ? 2 : 4,
                        childAspectRatio: isMobile ? 1.4 : 1.6,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        children: [
                          _buildMetricCard(
                            title: 'TOTAL LEDGERS',
                            value: '${dash.ledgerCount}',
                            subtitle:
                                '${dash.accountGroupCount} Account Groups',
                            color: AppColors.primary,
                          ),
                          _buildMetricCard(
                            title: 'POSTED VOUCHERS',
                            value: '${dash.postedVoucherCount}',
                            subtitle: 'Total: ${dash.voucherCount}',
                            color: AppColors.success,
                          ),
                          _buildMetricCard(
                            title: 'DRAFT VOUCHERS',
                            value: '${dash.draftVoucherCount}',
                            subtitle: 'Awaiting posting',
                            color: AppColors.warning,
                          ),
                          _buildMetricCard(
                            title: 'FINANCIAL YEAR',
                            value: dash.activeFinancialYear,
                            subtitle: 'Lock: ${dash.bookLockDate}',
                            color: AppColors.info,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Quick Navigation Shortcuts
                      const Text(
                        'Accounting Sub-Modules & Shortcuts',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: isMobile ? 3 : 6,
                        childAspectRatio: isMobile ? 1.1 : 1.3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        children: [
                          _buildQuickTile(
                            icon: Icons.account_tree_outlined,
                            label: 'Chart of Accounts',
                            route: '/accounting/chart-of-accounts',
                            color: AppColors.primary,
                          ),
                          _buildQuickTile(
                            icon: Icons.menu_book_outlined,
                            label: 'Ledgers',
                            route: '/accounting/ledgers',
                            color: AppColors.success,
                          ),
                          _buildQuickTile(
                            icon: Icons.edit_note_rounded,
                            label: 'Create Journal',
                            route: '/accounting/journal/create',
                            color: AppColors.warning,
                          ),
                          _buildQuickTile(
                            icon: Icons.calendar_today_rounded,
                            label: 'Day Book',
                            route: '/accounting/day-book',
                            color: AppColors.info,
                          ),
                          _buildQuickTile(
                            icon: Icons.scale_rounded,
                            label: 'Trial Balance',
                            route: '/accounting/trial-balance',
                            color: Colors.teal,
                          ),
                          _buildQuickTile(
                            icon: Icons.assessment_outlined,
                            label: 'Financial Reports',
                            route: '/accounting/reports',
                            color: Colors.purple,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Recent Vouchers Section with Full Complete Data
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Recent Accounting Transactions',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () =>
                                Get.toNamed('/accounting/vouchers'),
                            icon: const Icon(Icons.arrow_forward, size: 14),
                            label: const Text(
                              'View All Vouchers',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      if (dash.recentVouchers.isEmpty) ...[
                        AppCard(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: Column(
                              children: const [
                                Icon(
                                  Icons.receipt_long_outlined,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'No recent vouchers found.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ] else ...[
                        AppCard(
                          padding: EdgeInsets.zero,
                          child: ClipRRect(
                            borderRadius: AppRadius.lg,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: constraints.maxWidth - 32,
                                ),
                                child: DataTable(
                                  columnSpacing: 20,
                                  headingRowColor: WidgetStateProperty.all(
                                    isDark
                                        ? AppColors.inputDark
                                        : Colors.grey[100],
                                  ),
                                  columns: const [
                                    DataColumn(
                                      label: Text(
                                        'VOUCHER NO',
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
                                      label: Text(
                                        'DATE',
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
                                        'AMOUNT (₹)',
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
                                        'NARRATION / DESCRIPTION',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ],
                                  rows: dash.recentVouchers.map((v) {
                                    final status =
                                        v['status']?.toString() ?? 'POSTED';
                                    final isPosted =
                                        status.toUpperCase() == 'POSTED';

                                    return DataRow(
                                      cells: [
                                        DataCell(
                                          Text(
                                            v['voucherNo']?.toString() ?? 'N/A',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'monospace',
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            v['type']?.toString() ?? 'Journal',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            v['date']?.toString() ?? '',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontFamily: 'monospace',
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            '₹${(v['amount'] as num?)?.toStringAsFixed(2) ?? "0.00"}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'monospace',
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
                                                  (isPosted
                                                          ? AppColors.success
                                                          : AppColors.warning)
                                                      .withAlpha(20),
                                              borderRadius: AppRadius.full,
                                            ),
                                            child: Text(
                                              status.toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: isPosted
                                                    ? AppColors.success
                                                    : AppColors.warning,
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            v['narration']?.toString() ?? 'N/A',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey,
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
                    ],
                  );
                },
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickTile({
    required IconData icon,
    required String label,
    required String route,
    required Color color,
  }) {
    return InkWell(
      onTap: () => Get.toNamed(route),
      borderRadius: AppRadius.md,
      child: AppCard(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
