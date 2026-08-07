import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../controllers/cash_bank_controller.dart';

class CashEntryDialog extends StatefulWidget {
  final String initialType; // 'deposit' or 'withdrawal'

  const CashEntryDialog({super.key, this.initialType = 'deposit'});

  @override
  State<CashEntryDialog> createState() => _CashEntryDialogState();
}

class _CashEntryDialogState extends State<CashEntryDialog> {
  final CashBankController controller = Get.find<CashBankController>();

  late String entryType;
  final TextEditingController amountCtrl = TextEditingController();
  final TextEditingController dateCtrl = TextEditingController(
    text: DateTime.now().toIso8601String().split('T')[0],
  );
  final TextEditingController remarksCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    entryType = widget.initialType;
  }

  @override
  void dispose() {
    amountCtrl.dispose();
    dateCtrl.dispose();
    remarksCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
      child: Container(
        width: 440,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:
                              (entryType == 'deposit'
                                      ? AppColors.success
                                      : AppColors.danger)
                                  .withAlpha(25),
                          borderRadius: AppRadius.md,
                        ),
                        child: Icon(
                          entryType == 'deposit'
                              ? Icons.arrow_downward_rounded
                              : Icons.arrow_upward_rounded,
                          color: entryType == 'deposit'
                              ? AppColors.success
                              : AppColors.danger,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Cash ${entryType == 'deposit' ? 'Deposit' : 'Withdrawal'}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              const Text(
                'AMOUNT *',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  prefixText: '₹ ',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  filled: true,
                  fillColor: isDark ? AppColors.inputDark : Colors.grey[100],
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
              const SizedBox(height: 14),

              const Text(
                'DATE *',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: dateCtrl,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'YYYY-MM-DD',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  filled: true,
                  fillColor: isDark ? AppColors.inputDark : Colors.grey[100],
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
              const SizedBox(height: 14),

              const Text(
                'REMARKS / REASON',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: remarksCtrl,
                maxLines: 2,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Notes regarding this cash movement...',
                  contentPadding: const EdgeInsets.all(12),
                  filled: true,
                  fillColor: isDark ? AppColors.inputDark : Colors.grey[100],
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
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                    text: 'Cancel',
                    variant: AppButtonVariant.outline,
                    onPressed: () => Get.back(),
                  ),
                  const SizedBox(width: 12),
                  Obx(
                    () => AppButton(
                      text:
                          'Record ${entryType == 'deposit' ? 'Deposit' : 'Withdrawal'}',
                      isLoading: controller.isSubmitting.value,
                      onPressed: () async {
                        final amt = double.tryParse(amountCtrl.text) ?? 0.0;
                        final ok = await controller.recordCashEntry(
                          type: entryType,
                          amount: amt,
                          date: dateCtrl.text.trim(),
                          remarks: remarksCtrl.text.trim(),
                        );
                        if (ok) Get.back();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
