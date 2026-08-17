import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/accounting_health_controller.dart';

class AccountingHealthView extends GetView<AccountingHealthController> {
  const AccountingHealthView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Obx(() {
            if (controller.isLoading.value && controller.health.value == null) {
              return const Padding(
                padding: EdgeInsets.only(top: 80),
                child: LoadingIndicator(),
              );
            }

            final h = controller.health.value!;
            final isHealthy = h.status == 'healthy';
            final isCritical = h.status == 'critical';

            Color statusColor = AppColors.success;
            if (isCritical) {
              statusColor = AppColors.danger;
            } else if (!isHealthy) {
              statusColor = AppColors.warning;
            }

            final hasGSTMismatch = h.issues.any(
              (issue) => issue.type == 'GST_MISMATCH',
            );
            final hasLedgerMismatch = h.issues.any(
              (issue) => issue.type == 'LEDGER_BALANCE_MISMATCH',
            );

            return Column(
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
                              color: statusColor.withAlpha(25),
                              borderRadius: AppRadius.lg,
                            ),
                            child: Icon(
                              isHealthy
                                  ? Icons.health_and_safety_outlined
                                  : Icons.favorite_border_rounded,
                              color: statusColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 10,
                                  runSpacing: 6,
                                  children: [
                                    const Text(
                                      'Accounting Health',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusColor.withAlpha(25),
                                        borderRadius: AppRadius.full,
                                      ),
                                      child: Text(
                                        h.status.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: statusColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Final validation for postings, balances, GST, audit, and reconciliation readiness.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    AppButton(
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
                          : () => controller.loadHealth(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 2. 7-Summary Control Metric Cards Grid
                LayoutBuilder(
                  builder: (context, constraints) {
                    final cols = constraints.maxWidth < 600
                        ? 2
                        : (constraints.maxWidth < 1100 ? 3 : 7);

                    return GridView.count(
                      crossAxisCount: cols,
                      childAspectRatio: cols == 7
                          ? 1.35
                          : (cols == 3 ? 1.7 : 1.9),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildSummaryCard(
                          'System Status',
                          h.status.toUpperCase(),
                          statusColor,
                          isDark,
                        ),
                        _buildSummaryCard(
                          'Total Issues',
                          '${h.summary.totalIssues}',
                          AppColors.primary,
                          isDark,
                        ),
                        _buildSummaryCard(
                          'Critical',
                          '${h.summary.criticalIssues}',
                          AppColors.danger,
                          isDark,
                        ),
                        _buildSummaryCard(
                          'Warnings',
                          '${h.summary.warningIssues}',
                          AppColors.warning,
                          isDark,
                        ),
                        _buildSummaryCard(
                          'Missing Postings',
                          '${h.summary.missingPostings}',
                          AppColors.warning,
                          isDark,
                        ),
                        _buildSummaryCard(
                          'Ledger Mismatches',
                          '${h.summary.ledgerMismatches}',
                          AppColors.danger,
                          isDark,
                        ),
                        _buildSummaryCard(
                          'Duplicate Vouchers',
                          '${h.summary.duplicateVouchers}',
                          AppColors.danger,
                          isDark,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),

                // 3. Quick Action Bar
                AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Quick Fix Actions',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Automated resolution tools for stored balances and GST posting reconciliation.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              Obx(() {
                                final isFixing =
                                    controller.activeFixingId.value ==
                                    'ledger-fix';
                                return AppButton(
                                  text: isFixing
                                      ? 'Recalculating...'
                                      : 'Recalculate Ledger Balances',
                                  icon: const Icon(
                                    Icons.build_circle_outlined,
                                    size: 16,
                                  ),
                                  variant: AppButtonVariant.outline,
                                  onPressed: isFixing
                                      ? null
                                      : () => controller.fixLedgers(),
                                );
                              }),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildGuidanceBadge(
                            'Repost missing accounting one document at a time',
                            isDark,
                          ),
                          if (hasGSTMismatch)
                            _buildGuidanceBadge(
                              'GST reconciliation is view-only',
                              isDark,
                            ),
                          if (hasLedgerMismatch)
                            _buildGuidanceBadge(
                              'Ledger fix does not modify voucher entries',
                              isDark,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 4. Diagnostic Issues Table
                Row(
                  children: [
                    Icon(
                      isHealthy
                          ? Icons.check_circle_outline_rounded
                          : Icons.warning_amber_rounded,
                      size: 18,
                      color: isHealthy ? AppColors.success : AppColors.warning,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Diagnostic Results',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (h.issues.isEmpty)
                  AppCard(
                    padding: const EdgeInsets.all(32),
                    child: EmptyState(
                      icon: Icons.task_alt_rounded,
                      title: 'All Systems Operational',
                      description:
                          'No accounting health issues found. Last checked ${h.checkedAt.contains('T') ? h.checkedAt.split('T')[0] : h.checkedAt}',
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
                          constraints: const BoxConstraints(minWidth: 900),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Table Header
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
                                      width: 110,
                                      child: Text(
                                        'SEVERITY',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 190,
                                      child: Text(
                                        'TYPE',
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
                                        'MODULE',
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
                                        'REFERENCE NO',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 280,
                                      child: Text(
                                        'MESSAGE',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 220,
                                      child: Text(
                                        'SUGGESTED FIX',
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

                              // Table Rows
                              Column(
                                children: List.generate(h.issues.length, (
                                  index,
                                ) {
                                  final issue = h.issues[index];
                                  final isOdd = index % 2 == 1;
                                  final isFixingThis =
                                      controller.activeFixingId.value ==
                                      issue.id;

                                  final isCriticalIssue =
                                      issue.severity == 'critical';
                                  final isWarningIssue =
                                      issue.severity == 'warning';

                                  Color sevColor = AppColors.info;
                                  if (isCriticalIssue) {
                                    sevColor = AppColors.danger;
                                  } else if (isWarningIssue) {
                                    sevColor = AppColors.warning;
                                  }

                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 11,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isOdd
                                          ? (isDark
                                                ? AppColors.inputDark.withAlpha(
                                                    40,
                                                  )
                                                : Colors.grey[50])
                                          : Colors.transparent,
                                      border: Border(
                                        bottom: BorderSide(
                                          color: isDark
                                              ? AppColors.borderDark.withAlpha(
                                                  30,
                                                )
                                              : Colors.grey[200]!,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        // 1. Severity Badge
                                        SizedBox(
                                          width: 110,
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 3,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: sevColor.withAlpha(25),
                                                borderRadius: AppRadius.sm,
                                                border: Border.all(
                                                  color: sevColor.withAlpha(60),
                                                  width: 0.8,
                                                ),
                                              ),
                                              child: Text(
                                                issue.severity.toUpperCase(),
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: sevColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),

                                        // 2. Type
                                        SizedBox(
                                          width: 190,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              right: 16,
                                            ),
                                            child: Text(
                                              issue.type,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),

                                        // 3. Module
                                        SizedBox(
                                          width: 120,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              right: 16,
                                            ),
                                            child: Text(
                                              issue.module,
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),

                                        // 4. Reference No
                                        SizedBox(
                                          width: 140,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              right: 16,
                                            ),
                                            child: Text(
                                              issue.referenceNo ?? '-',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontFamily: 'monospace',
                                              ),
                                            ),
                                          ),
                                        ),

                                        // 5. Message
                                        SizedBox(
                                          width: 280,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              right: 16,
                                            ),
                                            child: Text(
                                              issue.message,
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),

                                        // 6. Suggested Fix
                                        SizedBox(
                                          width: 220,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              right: 16,
                                            ),
                                            child: Text(
                                              issue.suggestedFix ?? '-',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ),
                                        ),

                                        // 7. Action Button
                                        SizedBox(
                                          width: 120,
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child:
                                                issue.type ==
                                                        'MISSING_POSTING' &&
                                                    issue.referenceId != null
                                                ? AppButton(
                                                    text: isFixingThis
                                                        ? 'Fixing...'
                                                        : 'Repost',
                                                    icon: isFixingThis
                                                        ? const SizedBox(
                                                            width: 12,
                                                            height: 12,
                                                            child:
                                                                CircularProgressIndicator(
                                                                  strokeWidth:
                                                                      2,
                                                                ),
                                                          )
                                                        : const Icon(
                                                            Icons
                                                                .rotate_right_rounded,
                                                            size: 14,
                                                          ),
                                                    variant: AppButtonVariant
                                                        .outline,
                                                    onPressed: isFixingThis
                                                        ? null
                                                        : () => controller
                                                              .repost(issue),
                                                  )
                                                : const Text(
                                                    '-',
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                    ),
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
                    ),
                  ),
                const SizedBox(height: 24),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String label,
    String value,
    Color color,
    bool isDark,
  ) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidanceBadge(String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.inputDark : Colors.grey[200],
        borderRadius: AppRadius.full,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: isDark ? Colors.grey[300] : Colors.grey[700],
        ),
      ),
    );
  }
}
