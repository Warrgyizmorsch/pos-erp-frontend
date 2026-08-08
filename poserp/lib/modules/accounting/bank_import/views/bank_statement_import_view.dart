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
                          Icons.upload_file_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Bank Statement Auto-Matching & Importer',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Import PDF/CSV bank statements with fuzzy narration rules and one-click voucher generation.',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      AppButton(
                        text: 'Fuzzy Narration Rules',
                        icon: const Icon(Icons.rule_folder_outlined, size: 16),
                        variant: AppButtonVariant.outline,
                        onPressed: () =>
                            Get.toNamed('/accounting/mapping-rules'),
                      ),
                      const SizedBox(width: 8),
                      AppButton(
                        text: 'Import Settings',
                        icon: const Icon(Icons.settings_outlined, size: 16),
                        variant: AppButtonVariant.outline,
                        onPressed: () =>
                            Get.toNamed('/accounting/bank-import-settings'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Stepper
              Obx(
                () => AppCard(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStepBadge(0, '1. Select & Upload Statement'),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: Colors.grey,
                      ),
                      _buildStepBadge(1, '2. Verify Mapped Transactions'),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: Colors.grey,
                      ),
                      _buildStepBadge(2, '3. Batch Voucher Post'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Step Content
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const LoadingIndicator();
                  }

                  final step = controller.activeStep.value;
                  if (step == 0) return _buildStep0Upload();
                  if (step == 1) return _buildStep1Verification(isDark);
                  return _buildStep2Result();
                }),
              ),
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

  Widget _buildStep0Upload() {
    return AppCard(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_upload_outlined,
              size: 64,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Upload Bank Statement File (.CSV / .PDF)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Fuzzy narration matcher will scan entries against mapping rules and auto-link ledgers.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AppButton(
              text: 'Simulate Bank Statement Import',
              icon: const Icon(Icons.file_present_rounded, size: 16),
              variant: AppButtonVariant.primary,
              onPressed: () => controller.runImport('account-hdfc-01', []),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1Verification(bool isDark) {
    final s = controller.session.value;
    if (s == null) return const SizedBox.shrink();

    return Column(
      children: [
        // Summary Cards
        Row(
          children: [
            Expanded(
              child: AppCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOTAL ENTRIES',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${s.totalTransactions}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AUTO-MAPPED',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${s.autoMappedCount}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'MANUAL REVIEW',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${s.manualReviewCount}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Action Toolbar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Parsed Statement Transactions',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            AppButton(
              text: 'Post Selected as Vouchers',
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
        const SizedBox(height: 12),

        // Transactions Table
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
                        'AMOUNT',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'MAPPED LEDGER',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'MATCH CONFIDENCE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                  rows: s.transactions.map((tx) {
                    final isAuto = tx.status == 'auto_mapped';
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            tx.date,
                            style: const TextStyle(
                              fontSize: 11,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            tx.narration,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            '₹${tx.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: tx.type == 'DEPOSIT'
                                  ? AppColors.success
                                  : AppColors.danger,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            tx.mappedLedgerName ?? 'Unmapped (Review)',
                            style: TextStyle(
                              fontSize: 12,
                              color: isAuto
                                  ? AppColors.primary
                                  : AppColors.warning,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            '${(tx.confidenceScore * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 11,
                              fontFamily: 'monospace',
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

  Widget _buildStep2Result() {
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
              'Batch Voucher Posting Completed!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bank statement transactions have been converted into double-entry accounting vouchers.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppButton(
                  text: 'View Journal Vouchers',
                  variant: AppButtonVariant.outline,
                  onPressed: () => Get.toNamed('/accounting/vouchers'),
                ),
                const SizedBox(width: 12),
                AppButton(
                  text: 'Import Another Statement',
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
}
