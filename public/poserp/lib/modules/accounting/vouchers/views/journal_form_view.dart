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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Toolbar
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;

                  if (isMobile) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_rounded),
                              onPressed: () => Get.back(),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(25),
                                borderRadius: AppRadius.md,
                              ),
                              child: const Icon(
                                Icons.edit_note_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'Create Journal Voucher',
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
                          'Manually post debit and credit ledger entries to general ledger.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    );
                  }

                  return Row(
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
                            'Manually post debit and credit ledger entries to general ledger.',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),

              // 2. Voucher Main Details Card
              AppCard(
                padding: const EdgeInsets.all(16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 600;

                    final dateInput = TextField(
                      controller: controller.dateController,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Posting Date (YYYY-MM-DD)',
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

                    final narrationInput = TextField(
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
                    );

                    if (isMobile) {
                      return Column(
                        children: [
                          dateInput,
                          const SizedBox(height: 12),
                          narrationInput,
                        ],
                      );
                    }

                    return Row(
                      children: [
                        SizedBox(width: 200, child: dateInput),
                        const SizedBox(width: 16),
                        Expanded(child: narrationInput),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // 3. Line Items Header & Add Row Button
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
                    text: 'Add Row',
                    variant: AppButtonVariant.outline,
                    icon: const Icon(Icons.add_rounded, size: 16),
                    onPressed: () => controller.addRow(),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 4. Entry Rows Table (Scrollable on Mobile)
              Expanded(
                child: Obx(() {
                  if (controller.isLoadingLedgers.value) {
                    return const LoadingIndicator();
                  }

                  return AppCard(
                    padding: const EdgeInsets.all(12),
                    child: SingleChildScrollView(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 700),
                          child: Column(
                            children: [
                              // Table Header Row
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.inputDark
                                      : Colors.grey[100],
                                  borderRadius: AppRadius.sm,
                                ),
                                child: Row(
                                  children: const [
                                    SizedBox(
                                      width: 220,
                                      child: Text(
                                        'Ledger',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    SizedBox(
                                      width: 120,
                                      child: Text(
                                        'Debit (₹)',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    SizedBox(
                                      width: 120,
                                      child: Text(
                                        'Credit (₹)',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    SizedBox(
                                      width: 200,
                                      child: Text(
                                        'Line Narration',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 40),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Table Row Inputs
                              ...controller.rows.map((row) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    children: [
                                      // Ledger Dropdown
                                      SizedBox(
                                        width: 220,
                                        child: DropdownButtonFormField<String>(
                                          isExpanded: true,
                                          initialValue: row.ledgerId.isNotEmpty
                                              ? row.ledgerId
                                              : null,
                                          hint: const Text(
                                            'Select Ledger',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                          dropdownColor: isDark
                                              ? AppColors.cardDark
                                              : AppColors.cardLight,
                                          decoration: InputDecoration(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
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
                                                '${l.name} · ${l.code}',
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
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
                                      SizedBox(
                                        width: 120,
                                        child: TextField(
                                          controller: row.debitController,
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontFamily: 'monospace',
                                          ),
                                          decoration: InputDecoration(
                                            hintText: '0.00',
                                            contentPadding:
                                                const EdgeInsets.symmetric(
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
                                                (double.tryParse(val) ?? 0) >
                                                    0) {
                                              row.creditController.text = '';
                                            }
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 10),

                                      // Credit Input
                                      SizedBox(
                                        width: 120,
                                        child: TextField(
                                          controller: row.creditController,
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontFamily: 'monospace',
                                          ),
                                          decoration: InputDecoration(
                                            hintText: '0.00',
                                            contentPadding:
                                                const EdgeInsets.symmetric(
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
                                                (double.tryParse(val) ?? 0) >
                                                    0) {
                                              row.debitController.text = '';
                                            }
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 10),

                                      // Line Narration Input
                                      SizedBox(
                                        width: 200,
                                        child: TextField(
                                          controller: row.narrationController,
                                          style: const TextStyle(fontSize: 12),
                                          decoration: InputDecoration(
                                            hintText: 'Line narration',
                                            contentPadding:
                                                const EdgeInsets.symmetric(
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
                                      const SizedBox(width: 6),

                                      // Delete Button
                                      SizedBox(
                                        width: 34,
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline_rounded,
                                            color: AppColors.danger,
                                            size: 18,
                                          ),
                                          onPressed: controller.rows.length > 2
                                              ? () =>
                                                    controller.removeRow(row.id)
                                              : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),

              // 5. Balancing Summary & Action Footer
              Obx(() {
                final dTot = controller.totalDebit.value;
                final cTot = controller.totalCredit.value;
                final diff = controller.difference.value;
                final isBal = controller.isBalanced.value;

                return AppCard(
                  padding: const EdgeInsets.all(16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 600;

                      final metricsGrid = Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Total Debit',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '₹${dTot.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Total Credit',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '₹${cTot.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Difference',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '₹${diff.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isBal
                                          ? AppColors.success
                                          : AppColors.danger,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (isBal
                                          ? AppColors.success
                                          : AppColors.warning)
                                      .withAlpha(20),
                              borderRadius: AppRadius.full,
                            ),
                            child: Text(
                              isBal ? 'Balanced' : 'Not Balanced',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isBal
                                    ? AppColors.success
                                    : AppColors.warning,
                              ),
                            ),
                          ),
                        ],
                      );

                      if (isMobile) {
                        return Column(
                          children: [
                            metricsGrid,
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: AppButton(
                                    text: 'Cancel',
                                    variant: AppButtonVariant.outline,
                                    height: 38,
                                    onPressed: () => Get.back(),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: AppButton(
                                    text: 'Save Draft',
                                    variant: AppButtonVariant.secondary,
                                    height: 38,
                                    isLoading: controller.isSubmitting.value,
                                    onPressed: isBal
                                        ? () => controller.submit('draft')
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: AppButton(
                                    text: 'Post',
                                    variant: AppButtonVariant.primary,
                                    height: 38,
                                    isLoading: controller.isSubmitting.value,
                                    onPressed: isBal
                                        ? () => controller.submit('post')
                                        : null,
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
                          Expanded(child: metricsGrid),
                          const SizedBox(width: 16),
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
                                text: 'Post Voucher',
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
                      );
                    },
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
