import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../controllers/cash_bank_controller.dart';

class BankTransferDialog extends StatefulWidget {
  const BankTransferDialog({super.key});

  @override
  State<BankTransferDialog> createState() => _BankTransferDialogState();
}

class _BankTransferDialogState extends State<BankTransferDialog> {
  final CashBankController controller = Get.find<CashBankController>();

  final TextEditingController amountCtrl = TextEditingController();
  final TextEditingController dateCtrl = TextEditingController(
    text: DateTime.now().toIso8601String().split('T')[0],
  );
  final TextEditingController refNoCtrl = TextEditingController();
  final TextEditingController remarksCtrl = TextEditingController();

  String? fromAccountId;
  String? toAccountId;

  @override
  void initState() {
    super.initState();
    if (controller.bankAccounts.isNotEmpty) {
      fromAccountId = controller.bankAccounts.first.id;
      if (controller.bankAccounts.length > 1) {
        toAccountId = controller.bankAccounts[1].id;
      }
    }
  }

  @override
  void dispose() {
    amountCtrl.dispose();
    dateCtrl.dispose();
    refNoCtrl.dispose();
    remarksCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
      child: Container(
        width: 500,
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
                          color: AppColors.primary.withAlpha(25),
                          borderRadius: AppRadius.md,
                        ),
                        child: const Icon(
                          Icons.swap_horiz_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Fund Transfer',
                        style: TextStyle(
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
                'FROM ACCOUNT *',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: fromAccountId,
                isExpanded: true,
                dropdownColor: isDark
                    ? AppColors.cardDark
                    : AppColors.cardLight,
                decoration: InputDecoration(
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
                items: controller.bankAccounts.map((a) {
                  return DropdownMenuItem<String>(
                    value: a.id,
                    child: Text(
                      '${a.accountName} (${a.accountNumber}) - ₹${a.currentBalance.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => fromAccountId = val),
              ),
              const SizedBox(height: 14),

              const Text(
                'TO ACCOUNT *',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: toAccountId,
                isExpanded: true,
                dropdownColor: isDark
                    ? AppColors.cardDark
                    : AppColors.cardLight,
                decoration: InputDecoration(
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
                items: controller.bankAccounts.map((a) {
                  return DropdownMenuItem<String>(
                    value: a.id,
                    child: Text(
                      '${a.accountName} (${a.accountNumber}) - ₹${a.currentBalance.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => toAccountId = val),
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            prefixText: '₹ ',
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
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              const Text(
                'REFERENCE NO / UTR',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: refNoCtrl,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'e.g. UTR / NEFT Reference Number',
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
                      text: 'Execute Transfer',
                      isLoading: controller.isSubmitting.value,
                      onPressed: () async {
                        if (fromAccountId == null || toAccountId == null) {
                          controller.showErrorSnackbar(
                            'Please select both accounts.',
                          );
                          return;
                        }
                        final amt = double.tryParse(amountCtrl.text) ?? 0.0;
                        final ok = await controller.recordBankTransfer(
                          fromAccountId: fromAccountId!,
                          toAccountId: toAccountId!,
                          amount: amt,
                          date: dateCtrl.text.trim(),
                          referenceNo: refNoCtrl.text.trim(),
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
