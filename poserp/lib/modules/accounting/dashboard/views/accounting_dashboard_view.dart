import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../authentication/controllers/auth_controller.dart';
import '../controllers/accounting_dashboard_controller.dart';
import '../models/accounting_dashboard.dart';

class AccountingDashboardView extends GetView<AccountingDashboardController> {
  const AccountingDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authController = Get.find<AuthController>();
    final isAdmin = authController.currentUser.value?.role == 'admin';

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
              final reports = controller.reportDashboard.value;

              return LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Page Header & Action Bar
                      _buildHeader(context, isMobile, isAdmin),
                      const SizedBox(height: 16),

                      // 2. Accounting Status Card
                      _buildAccountingStatusCard(
                        context,
                        dash,
                        isDark,
                        isMobile,
                      ),
                      const SizedBox(height: 20),

                      // 3. Financial Summary (Tally-style Money Cards)
                      _buildFinancialSummarySection(context, reports, isMobile),
                      const SizedBox(height: 20),

                      // 4. Counts Summary Grid
                      _buildCountsSummarySection(context, dash, isMobile),
                      const SizedBox(height: 20),

                      // 5. Quick Actions Section
                      _buildQuickActionsSection(context, isMobile),
                      const SizedBox(height: 20),

                      // 6. Recent Vouchers Table
                      _buildRecentVouchersTable(context, dash, isDark),
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

  // 1. Page Header
  Widget _buildHeader(BuildContext context, bool isMobile, bool isAdmin) {
    return LayoutBuilder(
      builder: (context, constraints) {
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
                      Icons.account_balance_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Accounting',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Accounting dashboard for manual journals, ledgers, vouchers, day book, and validation reports.',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (isAdmin) ...[
                    AppButton(
                      text: 'Initialize',
                      icon: const Icon(Icons.dns_rounded, size: 14),
                      variant: AppButtonVariant.outline,
                      height: 36,
                      isLoading: controller.isInitializing.value,
                      onPressed: () => _confirmAction(
                        context,
                        'Initialize Accounting',
                        'This will create missing default account groups, ledgers, voucher types, financial year, and settings. Existing records will not be duplicated.',
                        () => controller.initializeAccountingEngine(),
                      ),
                    ),
                    AppButton(
                      text: 'Restore Defaults',
                      icon: const Icon(Icons.refresh_rounded, size: 14),
                      variant: AppButtonVariant.outline,
                      height: 36,
                      isLoading: controller.isRestoringLedgers.value,
                      onPressed: () => _confirmAction(
                        context,
                        'Restore Missing Default Ledgers',
                        'This will recreate any missing system default Chart of Accounts ledgers.',
                        () => controller.restoreDefaultLedgers(),
                      ),
                    ),
                  ],
                  AppButton(
                    text: 'Refresh',
                    icon: const Icon(Icons.refresh_rounded, size: 14),
                    variant: AppButtonVariant.outline,
                    height: 36,
                    onPressed: () => controller.loadDashboard(),
                  ),
                  AppButton(
                    text: 'Create Journal',
                    icon: const Icon(Icons.add_rounded, size: 14),
                    height: 36,
                    onPressed: () => Get.toNamed('/accounting/journal/create'),
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
                    Icons.account_balance_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Accounting',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Accounting dashboard for manual journals, ledgers, vouchers, day book, and validation reports.',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              children: [
                if (isAdmin) ...[
                  AppButton(
                    text: 'Initialize Accounting',
                    icon: const Icon(Icons.dns_rounded, size: 16),
                    variant: AppButtonVariant.outline,
                    isLoading: controller.isInitializing.value,
                    onPressed: () => _confirmAction(
                      context,
                      'Initialize Accounting',
                      'This will create missing default account groups, ledgers, voucher types, financial year, and settings. Existing records will not be duplicated.',
                      () => controller.initializeAccountingEngine(),
                    ),
                  ),
                  AppButton(
                    text: 'Restore Missing Default Ledgers',
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    variant: AppButtonVariant.outline,
                    isLoading: controller.isRestoringLedgers.value,
                    onPressed: () => _confirmAction(
                      context,
                      'Restore Missing Default Ledgers',
                      'This will recreate any missing system default Chart of Accounts ledgers.',
                      () => controller.restoreDefaultLedgers(),
                    ),
                  ),
                ],
                AppButton(
                  text: 'Refresh',
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  variant: AppButtonVariant.outline,
                  onPressed: () => controller.loadDashboard(),
                ),
                AppButton(
                  text: 'Create Journal',
                  icon: const Icon(Icons.add_rounded, size: 16),
                  onPressed: () => Get.toNamed('/accounting/journal/create'),
                ),
                PopupMenuButton<String>(
                  tooltip: 'More Accounting Modules',
                  onSelected: (route) => Get.toNamed(route),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: '/accounting/gst',
                      child: Row(
                        children: [
                          Icon(
                            Icons.receipt_rounded,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 8),
                          Text('GST & Tax Reports'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: '/accounting/reports',
                      child: Row(
                        children: [
                          Icon(
                            Icons.pie_chart_outline_rounded,
                            size: 18,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 8),
                          Text('Financial Reports'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: '/accounting/trial-balance',
                      child: Row(
                        children: [
                          Icon(
                            Icons.scale_rounded,
                            size: 18,
                            color: Colors.green,
                          ),
                          SizedBox(width: 8),
                          Text('Trial Balance'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: '/accounting/day-book',
                      child: Row(
                        children: [
                          Icon(
                            Icons.menu_book_outlined,
                            size: 18,
                            color: Colors.orange,
                          ),
                          SizedBox(width: 8),
                          Text('Day Book'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: '/accounting/reconciliation',
                      child: Row(
                        children: [
                          Icon(
                            Icons.fact_check_outlined,
                            size: 18,
                            color: Colors.teal,
                          ),
                          SizedBox(width: 8),
                          Text('Bank Reconciliation'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: '/accounting/settings',
                      child: Row(
                        children: [
                          Icon(
                            Icons.settings_outlined,
                            size: 18,
                            color: Colors.grey,
                          ),
                          SizedBox(width: 8),
                          Text('Accounting Settings'),
                        ],
                      ),
                    ),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                      ),
                      borderRadius: AppRadius.md,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.more_vert_rounded, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'More',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // 2. Accounting Status Card
  Widget _buildAccountingStatusCard(
    BuildContext context,
    AccountingDashboard dash,
    bool isDark,
    bool isMobile,
  ) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Accounting Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Current foundation settings and active financial year.',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildBadge(
                dash.accountingEnabled ? 'Enabled' : 'Disabled',
                dash.accountingEnabled ? AppColors.success : AppColors.warning,
                icon: dash.accountingEnabled
                    ? Icons.check_circle_outline
                    : Icons.highlight_off_rounded,
              ),
            ],
          ),
          const Divider(height: 20),

          // Foundation Cards Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isMobile ? 2 : 4,
            childAspectRatio: isMobile ? 1.8 : 2.2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: [
              _buildStatusBox(
                context,
                title: 'Accounting Foundation',
                widget: _buildBadge(
                  dash.isInitialized
                      ? 'Accounting Initialized'
                      : 'Not Initialized',
                  dash.isInitialized ? AppColors.success : AppColors.warning,
                ),
              ),
              _buildStatusBox(
                context,
                title: 'Missing Default Ledgers',
                widget: Text(
                  '${dash.missingDefaultLedgersCount}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildStatusBox(
                context,
                title: 'Missing Default Groups',
                widget: Text(
                  '${dash.missingDefaultGroupsCount}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildStatusBox(
                context,
                title: 'Active Financial Year',
                widget: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dash.activeFinancialYearName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      dash.activeFinancialYearDates,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Foundation Toggles Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isMobile ? 2 : 4,
            childAspectRatio: isMobile ? 2.2 : 2.6,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: [
              _buildStatusBox(
                context,
                title: 'Auto Voucher Posting',
                widget: _buildBadge(
                  dash.autoVoucherPosting ? 'Enabled' : 'Disabled',
                  dash.autoVoucherPosting ? AppColors.success : Colors.grey,
                ),
              ),
              _buildStatusBox(
                context,
                title: 'GST Accounting',
                widget: _buildBadge(
                  dash.gstAccountingEnabled ? 'Enabled' : 'Disabled',
                  dash.gstAccountingEnabled ? AppColors.success : Colors.grey,
                ),
              ),
              _buildStatusBox(
                context,
                title: 'Inventory Accounting',
                widget: _buildBadge(
                  dash.inventoryAccountingEnabled ? 'Enabled' : 'Disabled',
                  dash.inventoryAccountingEnabled
                      ? AppColors.success
                      : Colors.grey,
                ),
              ),
              _buildStatusBox(
                context,
                title: 'Accounting Enabled',
                widget: _buildBadge(
                  dash.accountingEnabled ? 'Enabled' : 'Disabled',
                  dash.accountingEnabled ? AppColors.success : Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBox(
    BuildContext context, {
    required String title,
    required Widget widget,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.inputDark : Colors.grey[50],
        borderRadius: AppRadius.md,
        border: Border.all(
          color: isDark ? AppColors.borderDark : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          widget,
        ],
      ),
    );
  }

  // 3. Financial Summary (Tally-Style Control Totals)
  Widget _buildFinancialSummarySection(
    BuildContext context,
    AccountingReportDashboard? reports,
    bool isMobile,
  ) {
    final cash = reports?.cashBalance ?? 0.0;
    final bank = reports?.bankBalance ?? 0.0;
    final rec = reports?.receivables ?? 0.0;
    final pay = reports?.payables ?? 0.0;
    final inc = reports?.totalIncome ?? 0.0;
    final exp = reports?.totalExpenses ?? 0.0;
    final profit = reports?.netProfit ?? 0.0;
    final loss = reports?.netLoss ?? 0.0;
    final diff = reports?.trialBalanceDifference ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Financial Summary',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        const Text(
          'Tally-style control totals from posted accounting reports.',
          style: TextStyle(fontSize: 11, color: Colors.grey),
        ),
        const SizedBox(height: 12),

        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isMobile ? 2 : 4,
          childAspectRatio: isMobile ? 1.6 : 1.8,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            _buildMoneyCard('Cash Balance', cash, AppColors.success),
            _buildMoneyCard('Bank Balance', bank, AppColors.info),
            _buildMoneyCard('Receivables', rec, AppColors.primary),
            _buildMoneyCard('Payables', pay, AppColors.warning),
            _buildMoneyCard('Income / Sales', inc, AppColors.success),
            _buildMoneyCard('Expenses / Purchases', exp, AppColors.danger),
            _buildMoneyCard(
              profit > 0 ? 'Net Profit' : 'Net Loss',
              profit > 0 ? profit : loss,
              profit > 0 ? AppColors.success : AppColors.danger,
            ),
            _buildMoneyCard(
              'Trial Balance Difference',
              diff,
              diff == 0 ? AppColors.success : AppColors.danger,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMoneyCard(String label, double value, Color color) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '₹${value.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 4. Counts Summary Section
  Widget _buildCountsSummarySection(
    BuildContext context,
    AccountingDashboard dash,
    bool isMobile,
  ) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isMobile ? 2 : 6,
      childAspectRatio: isMobile ? 1.8 : 1.6,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: [
        _buildCountCard('Account Groups', dash.accountGroupCount),
        _buildCountCard('Ledgers', dash.ledgerCount),
        _buildCountCard('Voucher Types', dash.voucherTypeCount),
        _buildCountCard(
          'Posted Vouchers',
          dash.postedVoucherCount,
          color: AppColors.success,
        ),
        _buildCountCard(
          'Draft Vouchers',
          dash.draftVoucherCount,
          color: AppColors.warning,
        ),
        _buildCountCard(
          'Cancelled Vouchers',
          dash.cancelledVoucherCount,
          color: AppColors.danger,
        ),
      ],
    );
  }

  Widget _buildCountCard(String label, int value, {Color? color}) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color ?? AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  // 5. Quick Actions Section
  Widget _buildQuickActionsSection(BuildContext context, bool isMobile) {
    final actions = [
      {
        'label': 'Chart of Accounts',
        'href': '/accounting/chart-of-accounts',
        'icon': Icons.layers_outlined,
      },
      {
        'label': 'View Ledgers',
        'href': '/accounting/ledgers',
        'icon': Icons.list_alt_rounded,
      },
      {
        'label': 'Create Journal',
        'href': '/accounting/journal/create',
        'icon': Icons.insert_drive_file_outlined,
      },
      {
        'label': 'Day Book',
        'href': '/accounting/day-book',
        'icon': Icons.menu_book_outlined,
      },
      {
        'label': 'Trial Balance',
        'href': '/accounting/trial-balance',
        'icon': Icons.bar_chart_rounded,
      },
      {
        'label': 'GST Reports',
        'href': '/accounting/gst',
        'icon': Icons.receipt_rounded,
      },
      {
        'label': 'Financial Reports',
        'href': '/accounting/reports',
        'icon': Icons.pie_chart_outline_rounded,
      },
      {
        'label': 'Settings',
        'href': '/accounting/settings',
        'icon': Icons.settings_outlined,
      },
    ];

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          const Text(
            'Open the core accounting work areas.',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 12),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isMobile ? 2 : 6,
            childAspectRatio: isMobile ? 2.5 : 2.2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            children: actions.map((act) {
              return OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.md),
                ),
                onPressed: () => Get.toNamed(act['href'] as String),
                icon: Icon(act['icon'] as IconData, size: 16),
                label: Text(
                  act['label'] as String,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // 6. Recent Vouchers Table
  Widget _buildRecentVouchersTable(
    BuildContext context,
    AccountingDashboard dash,
    bool isDark,
  ) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Recent Vouchers',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Latest accounting vouchers across draft, posted, cancelled, and reversed states.',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => Get.toNamed('/accounting/vouchers'),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                  label: const Text('View All', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          if (dash.recentVouchers.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(
                child: Text(
                  'No vouchers created yet.',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 20,
                headingRowColor: WidgetStateProperty.all(
                  isDark ? AppColors.inputDark : Colors.grey[100],
                ),
                columns: const [
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
                      'NARRATION',
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
                      'DEBIT (₹)',
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
                      'CREDIT (₹)',
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
                ],
                rows: dash.recentVouchers.map((v) {
                  final status = v['status']?.toString() ?? 'POSTED';
                  final deb = (v['totalDebit'] as num?)?.toDouble() ?? 0.0;
                  final cred = (v['totalCredit'] as num?)?.toDouble() ?? 0.0;

                  return DataRow(
                    cells: [
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
                          v['voucherNo']?.toString() ?? '-',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          v['type']?.toString() ?? 'JOURNAL',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 200,
                          child: Text(
                            v['narration']?.toString() ?? '-',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          '₹${deb.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          '₹${cred.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      DataCell(_buildStatusBadge(status)),
                    ],
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color color, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: AppRadius.full,
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color col;
    switch (status.toUpperCase()) {
      case 'POSTED':
        col = AppColors.success;
        break;
      case 'DRAFT':
        col = AppColors.warning;
        break;
      case 'CANCELLED':
        col = AppColors.danger;
        break;
      case 'REVERSED':
      default:
        col = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: col.withAlpha(20),
        borderRadius: AppRadius.full,
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: col),
      ),
    );
  }

  void _confirmAction(
    BuildContext context,
    String title,
    String message,
    VoidCallback onConfirm,
  ) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Get.back();
              onConfirm();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
