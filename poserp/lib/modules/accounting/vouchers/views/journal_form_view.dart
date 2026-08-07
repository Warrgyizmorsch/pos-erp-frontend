import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../controllers/journal_form_controller.dart';

class JournalFormView extends GetView<JournalFormController> {
  const JournalFormView({super.key});

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
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded),
                        onPressed: () => Get.back(),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(25),
                          borderRadius: AppRadius.lg,
                        ),
                        child: const Icon(
                          Icons.edit_note_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Create Journal Voucher',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Post balanced debit and credit ledger entries to general ledger.',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Voucher Main Details Card
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    SizedBox(
                      width: 180,
                      child: TextField(
                        controller: controller.dateController,
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          labelText: 'Posting Date',
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
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: controller.narrationController,
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          labelText: 'Voucher Narration / Remarks',
                          hintText: 'Describe transaction purpose...',
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
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Line Items Grid Header & Add Row Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'JOURNAL ENTRIES',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  AppButton(
                    text: 'Add Entry Row',
                    variant: AppButtonVariant.outline,
                    icon: const Icon(Icons.add_rounded, size: 16),
                    onPressed: () => controller.addRow(),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Rows Table
              Expanded(
                child: Obx(() {
                  if (controller.isLoadingLedgers.value) {
                    return const LoadingIndicator();
                  }

                  return AppCard(
                    padding: const EdgeInsets.all(12),
                    child: ListView.separated(
                      itemCount: controller.rows.length,
                      separatorBuilder: (_, unused) =>
                          const Divider(height: 16),
                      itemBuilder: (context, idx) {
                        final row = controller.rows[idx];
                        return Row(
                          children: [
                            // Ledger Select
                            Expanded(
                              flex: 3,
                              child: DropdownButtonFormField<String>(
                                initialValue: row.ledgerId.isNotEmpty
                                    ? row.ledgerId
                                    : null,
                                hint: const Text(
                                  'Select Ledger Account',
                                  style: TextStyle(fontSize: 12),
                                ),
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
                                items: controller.ledgers.map((l) {
                                  return DropdownMenuItem<String>(
                                    value: l.id,
                                    child: Text(
                                      '${l.name} (${l.code})',
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    row.ledgerId = val;
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 10),

                            // Debit Input
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: row.debitController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Debit (₹)',
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
                                onChanged: (val) {
                                  if (val.isNotEmpty &&
                                      (double.tryParse(val) ?? 0) > 0) {
                                    row.creditController.text = '';
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 10),

                            // Credit Input
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: row.creditController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Credit (₹)',
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
                                onChanged: (val) {
                                  if (val.isNotEmpty &&
                                      (double.tryParse(val) ?? 0) > 0) {
                                    row.debitController.text = '';
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 10),

                            // Line Narration
                            Expanded(
                              flex: 3,
                              child: TextField(
                                controller: row.narrationController,
                                style: const TextStyle(fontSize: 12),
                                decoration: InputDecoration(
                                  hintText: 'Line narration (optional)',
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
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Delete Row Button
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: AppColors.danger,
                                size: 20,
                              ),
                              onPressed: () => controller.removeRow(row.id),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),

              // Real-Time Balancing Card Footer
              Obx(() {
                final dTot = controller.totalDebit.value;
                final cTot = controller.totalCredit.value;
                final diff = controller.difference.value;
                final isBal = controller.isBalanced.value;

                return AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Total Debit',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                '₹${dTot.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 24),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Total Credit',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                '₹${cTot.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 24),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Difference',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                '₹${diff.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isBal
                                      ? AppColors.success
                                      : AppColors.danger,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isBal
                                  ? AppColors.success.withAlpha(20)
                                  : AppColors.danger.withAlpha(20),
                              borderRadius: AppRadius.full,
                            ),
                            child: Text(
                              isBal ? 'BALANCED' : 'UNBALANCED',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isBal
                                    ? AppColors.success
                                    : AppColors.danger,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Submit Actions
                      Row(
                        children: [
                          AppButton(
                            text: 'Cancel',
                            variant: AppButtonVariant.outline,
                            onPressed: () => Get.back(),
                          ),
                          const SizedBox(width: 10),
                          AppButton(
                            text: 'Save Draft',
                            variant: AppButtonVariant.secondary,
                            icon: const Icon(Icons.save_outlined, size: 16),
                            isLoading: controller.isSubmitting.value,
                            onPressed: isBal
                                ? () => controller.submit('draft')
                                : null,
                          ),
                          const SizedBox(width: 10),
                          AppButton(
                            text: 'Post Journal',
                            variant: AppButtonVariant.primary,
                            icon: const Icon(Icons.send_rounded, size: 16),
                            isLoading: controller.isSubmitting.value,
                            onPressed: isBal
                                ? () => controller.submit('post')
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
