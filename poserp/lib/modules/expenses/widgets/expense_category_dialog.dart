import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../controllers/expense_controller.dart';

class ExpenseCategoryDialog extends StatefulWidget {
  const ExpenseCategoryDialog({super.key});

  @override
  State<ExpenseCategoryDialog> createState() => _ExpenseCategoryDialogState();
}

class _ExpenseCategoryDialogState extends State<ExpenseCategoryDialog> {
  final ExpenseController controller = Get.find<ExpenseController>();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();

  @override
  void dispose() {
    nameCtrl.dispose();
    descCtrl.dispose();
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
                          Icons.category_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Expense Categories',
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
              const SizedBox(height: 16),

              const Text(
                'NEW CATEGORY',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: nameCtrl,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Category Name *',
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
                  const SizedBox(width: 10),
                  AppButton(
                    text: 'Add',
                    icon: const Icon(Icons.add, size: 16),
                    onPressed: () async {
                      if (nameCtrl.text.trim().isEmpty) return;
                      final ok = await controller.createCategory(
                        nameCtrl.text.trim(),
                        descCtrl.text.trim(),
                      );
                      if (ok) {
                        nameCtrl.clear();
                        descCtrl.clear();
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              const Text(
                'EXISTING CATEGORIES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Obx(() {
                if (controller.categories.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: Text(
                        'No custom categories found.',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ),
                  );
                }

                return Container(
                  constraints: const BoxConstraints(maxHeight: 250),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                    borderRadius: AppRadius.md,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: controller.categories.length,
                    separatorBuilder: (ctx, i) => const Divider(height: 1),
                    itemBuilder: (context, idx) {
                      final cat = controller.categories[idx];
                      return ListTile(
                        dense: true,
                        title: Text(
                          cat.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle:
                            cat.description != null &&
                                cat.description!.isNotEmpty
                            ? Text(
                                cat.description!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              )
                            : null,
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 18,
                            color: AppColors.danger,
                          ),
                          onPressed: () => controller.deleteCategory(cat.id),
                        ),
                      );
                    },
                  ),
                );
              }),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                    text: 'Close',
                    variant: AppButtonVariant.outline,
                    onPressed: () => Get.back(),
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
