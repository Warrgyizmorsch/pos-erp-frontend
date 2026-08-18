import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/bank_import_controller.dart';

class BankStatementImportView extends GetView<BankImportController> {
  const BankStatementImportView({super.key});

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
              // 1. Page Header
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
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(25),
                            borderRadius: AppRadius.lg,
                          ),
                          child: const Icon(
                            Icons.upload_file_rounded,
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
                                'Bank Statement Import',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Upload statements and map transactions using fuzzy-learning rules.',
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
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      AppButton(
                        text: 'Mapping Rules',
                        icon: const Icon(Icons.settings_outlined, size: 16),
                        variant: AppButtonVariant.outline,
                        onPressed: () =>
                            Get.toNamed('/accounting/mapping-rules'),
                      ),
                      AppButton(
                        text: 'Import Settings',
                        icon: const Icon(Icons.tune_rounded, size: 16),
                        variant: AppButtonVariant.outline,
                        onPressed: () =>
                            Get.toNamed('/accounting/bank-import-settings'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 2. Step Indicator
              Obx(
                () => AppCard(
                  padding: const EdgeInsets.all(12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildStepBadge(0, '1. Select & Upload Statement'),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Icon(
                            Icons.chevron_right_rounded,
                            size: 18,
                            color: Colors.grey,
                          ),
                        ),
                        _buildStepBadge(1, '2. Map & Verify Transactions'),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Icon(
                            Icons.chevron_right_rounded,
                            size: 18,
                            color: Colors.grey,
                          ),
                        ),
                        _buildStepBadge(2, '3. Batch Voucher Post'),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 3. Step Body
              Obx(() {
                if (controller.isLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: LoadingIndicator(),
                  );
                }

                final step = controller.activeStep.value;
                if (step == 0) return _buildStep0Upload(isDark);
                if (step == 1) return _buildStep1Verification(isDark);
                return _buildStep2Result(isDark);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepBadge(int index, String label) {
    final isCurrent = controller.activeStep.value == index;
    final isDone = controller.activeStep.value > index;

    return Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: isDone
              ? AppColors.success
              : (isCurrent ? AppColors.primary : Colors.grey[400]),
          child: Text(
            '${index + 1}',
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            color: isCurrent ? AppColors.primary : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 0: UPLOAD & PARSE STATEMENT
  // ---------------------------------------------------------------------------
  Widget _buildStep0Upload(bool isDark) {
    return AppCard(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Configure Bank Statement Import',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Select target bank ledger account and upload statement (.PDF / .CSV).',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 550),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.inputDark.withAlpha(40)
                    : Colors.grey[50],
                borderRadius: AppRadius.lg,
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.cloud_upload_outlined,
                    size: 56,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Bank Statement File (.PDF / .CSV)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Fuzzy narration matcher will scan transactions against auto-learned pattern rules.',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  AppButton(
                    text: 'Import & Parse Bank Statement',
                    icon: const Icon(Icons.bolt_rounded, size: 16),
                    variant: AppButtonVariant.primary,
                    onPressed: () =>
                        controller.runImport('account-hdfc-01', []),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 1: MAP & VERIFY TRANSACTIONS
  // ---------------------------------------------------------------------------
  Widget _buildStep1Verification(bool isDark) {
    final s = controller.session.value;
    if (s == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top 4 Metric Control Cards
        LayoutBuilder(
          builder: (context, constraints) {
            final cols = constraints.maxWidth < 600
                ? 2
                : (constraints.maxWidth < 1100 ? 3 : 4);

            return GridView.count(
              crossAxisCount: cols,
              childAspectRatio: cols == 4 ? 2.1 : 2.4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildSummaryTile(
                  'Total Rows',
                  '${s.totalTransactions}',
                  AppColors.primary,
                  isDark,
                ),
                _buildSummaryTile(
                  'Auto-Mapped',
                  '${s.autoMappedCount}',
                  AppColors.success,
                  isDark,
                ),
                _buildSummaryTile(
                  'Manual Review',
                  '${s.manualReviewCount}',
                  AppColors.warning,
                  isDark,
                ),
                _buildSummaryTile(
                  'Vouchers Posted',
                  '${s.postedCount}',
                  AppColors.info,
                  isDark,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 20),

        // Action Toolbar Card
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 12,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Parsed Statement Rows: ${s.filename}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Account Ledger: ${s.bankAccountName}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              AppButton(
                text: 'One-Click Auto Post Vouchers',
                icon: const Icon(Icons.post_add_rounded, size: 16),
                variant: AppButtonVariant.primary,
                onPressed: () {
                  controller.selectedTransactionIds.assignAll(
                    s.transactions.map((t) => t.id).toList(),
                  );
                  controller.postSelectedVouchers();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Transactions Table
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
                    // Header Row
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.inputDark : Colors.grey[100],
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
                              'DATE',
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
                              'NARRATION',
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
                              'AMOUNT',
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
                              'MAP TO LEDGER ACCOUNT',
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
                              'CONFIDENCE',
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
                      children: List.generate(s.transactions.length, (index) {
                        final tx = s.transactions[index];
                        final isOdd = index % 2 == 1;
                        final isAuto = tx.status == 'auto_mapped';

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
                              // 1. Date
                              SizedBox(
                                width: 110,
                                child: Text(
                                  tx.date,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),

                              // 2. Narration
                              SizedBox(
                                width: 240,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 16),
                                  child: Text(
                                    tx.narration,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                              ),

                              // 3. Amount
                              SizedBox(
                                width: 120,
                                child: Text(
                                  '₹ ${tx.amount.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: tx.type == 'DEPOSIT'
                                        ? AppColors.success
                                        : AppColors.danger,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),

                              // 4. Mapped Ledger
                              SizedBox(
                                width: 220,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tx.mappedLedgerName ??
                                            'Select Ledger...',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: isAuto
                                              ? AppColors.primary
                                              : AppColors.warning,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 1.5,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              (isAuto
                                                      ? AppColors.success
                                                      : AppColors.warning)
                                                  .withAlpha(20),
                                          borderRadius: AppRadius.sm,
                                        ),
                                        child: Text(
                                          isAuto
                                              ? 'Auto-Suggested'
                                              : 'Manual Review',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: isAuto
                                                ? AppColors.success
                                                : AppColors.warning,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // 5. Confidence Score
                              SizedBox(
                                width: 140,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: LinearProgressIndicator(
                                        value: tx.confidenceScore,
                                        backgroundColor: isDark
                                            ? AppColors.inputDark
                                            : Colors.grey[200],
                                        color: isAuto
                                            ? AppColors.success
                                            : AppColors.warning,
                                        minHeight: 6,
                                        borderRadius: AppRadius.full,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${(tx.confidenceScore * 100).toInt()}%',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontFamily: 'monospace',
                                      ),
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
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 2: POSTING RESULTS
  // ---------------------------------------------------------------------------
  Widget _buildStep2Result(bool isDark) {
    return AppCard(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              size: 64,
              color: AppColors.success,
            ),
            const SizedBox(height: 16),
            const Text(
              'Statement Processed & Vouchers Posted!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bank statement transactions have been converted into double-entry accounting vouchers.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                AppButton(
                  text: 'View Journal Vouchers',
                  icon: const Icon(Icons.receipt_long_rounded, size: 16),
                  variant: AppButtonVariant.outline,
                  onPressed: () => Get.toNamed('/accounting/vouchers'),
                ),
                AppButton(
                  text: 'Import Another Statement',
                  icon: const Icon(Icons.add_rounded, size: 16),
                  variant: AppButtonVariant.primary,
                  onPressed: () => controller.activeStep.value = 0,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HELPER WIDGETS
  // ---------------------------------------------------------------------------
  Widget _buildSummaryTile(
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
}
