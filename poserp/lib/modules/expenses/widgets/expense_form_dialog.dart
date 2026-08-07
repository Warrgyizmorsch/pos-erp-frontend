import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../controllers/expense_controller.dart';
import '../models/expense_category.dart';

class ExpenseFormDialog extends StatefulWidget {
  final String initialEntryType;

  const ExpenseFormDialog({super.key, this.initialEntryType = 'expense'});

  @override
  State<ExpenseFormDialog> createState() => _ExpenseFormDialogState();
}

class _ExpenseFormDialogState extends State<ExpenseFormDialog> {
  final ExpenseController controller = Get.find<ExpenseController>();

  late String entryType;
  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController amountCtrl = TextEditingController();
  final TextEditingController dateCtrl = TextEditingController(
    text: DateTime.now().toIso8601String().split('T')[0],
  );
  final TextEditingController refNoCtrl = TextEditingController();
  final TextEditingController notesCtrl = TextEditingController();

  ExpenseCategory? selectedCategory;
  String selectedPaymentMethod = 'Cash';
  String? selectedAccountId;

  @override
  void initState() {
    super.initState();
    entryType = widget.initialEntryType;
    if (controller.categories.isNotEmpty) {
      selectedCategory = controller.categories.first;
    }
    if (controller.bankAccounts.isNotEmpty) {
      selectedAccountId =
          controller.bankAccounts.first['_id']?.toString() ??
          controller.bankAccounts.first['id']?.toString();
    }
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    amountCtrl.dispose();
    dateCtrl.dispose();
    refNoCtrl.dispose();
    notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
      child: Container(
        width: 520,
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
                              (entryType == 'expense'
                                      ? AppColors.danger
                                      : AppColors.success)
                                  .withAlpha(25),
                          borderRadius: AppRadius.md,
                        ),
                        child: Icon(
                          entryType == 'expense'
                              ? Icons.arrow_outward_rounded
                              : Icons.arrow_downward_rounded,
                          color: entryType == 'expense'
                              ? AppColors.danger
                              : AppColors.success,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Record ${entryType == 'expense' ? 'Expense' : 'Income'}',
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
                'TITLE / PURPOSE *',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: titleCtrl,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'e.g. Office Rent, Electricity Bill, Petty Cash',
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
                          'CATEGORY',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<ExpenseCategory>(
                          initialValue: selectedCategory,
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
                          items: controller.categories.map((c) {
                            return DropdownMenuItem<ExpenseCategory>(
                              value: c,
                              child: Text(
                                c.name,
                                style: const TextStyle(fontSize: 13),
                              ),
                            );
                          }).toList(),
                          onChanged: (c) =>
                              setState(() => selectedCategory = c),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Row(
                children: [
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
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PAYMENT METHOD *',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: selectedPaymentMethod,
                          dropdownColor: isDark
                              ? AppColors.cardDark
                              : AppColors.cardLight,
                          decoration: InputDecoration(
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
                          items: const [
                            DropdownMenuItem(
                              value: 'Cash',
                              child: Text('Cash'),
                            ),
                            DropdownMenuItem(
                              value: 'Bank',
                              child: Text('Bank Transfer'),
                            ),
                            DropdownMenuItem(value: 'UPI', child: Text('UPI')),
                            DropdownMenuItem(
                              value: 'Card',
                              child: Text('Card'),
                            ),
                            DropdownMenuItem(
                              value: 'Cheque',
                              child: Text('Cheque'),
                            ),
                          ],
                          onChanged: (v) {
                            if (v != null) {
                              setState(() => selectedPaymentMethod = v);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              const Text(
                'REFERENCE NO',
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
                  hintText: 'e.g. Transaction ID, Receipt No',
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
                'DESCRIPTION / NOTES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: notesCtrl,
                maxLines: 2,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Additional details or memo...',
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
                          'Save ${entryType == 'expense' ? 'Expense' : 'Income'}',
                      isLoading: controller.isSubmitting.value,
                      onPressed: () async {
                        final amt = double.tryParse(amountCtrl.text) ?? 0.0;
                        final ok = await controller.createExpense(
                          title: titleCtrl.text.trim(),
                          amount: amt,
                          categoryId: selectedCategory?.id,
                          categoryName: selectedCategory?.name ?? 'General',
                          date: dateCtrl.text.trim(),
                          paymentMethod: selectedPaymentMethod,
                          cashBankAccountId: selectedAccountId,
                          referenceNo: refNoCtrl.text.trim(),
                          description: notesCtrl.text.trim(),
                          entryType: entryType,
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
