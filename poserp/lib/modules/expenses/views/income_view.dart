import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/expense_controller.dart';

class IncomeView extends GetView<ExpenseController> {
  const IncomeView({super.key});

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
                          color: AppColors.success.withAlpha(25),
                          borderRadius: AppRadius.lg,
                        ),
                        child: const Icon(
                          Icons.trending_up_rounded,
                          color: AppColors.success,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Indirect Income Transactions',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Track non-operating income streams, commission credits, and interest earnings.',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  AppButton(
                    text: 'Record Income',
                    icon: const Icon(Icons.add_rounded, size: 16),
                    variant: AppButtonVariant.primary,
                    onPressed: () => _showRecordIncomeDialog(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Income Table
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
                              'INCOME CATEGORY / SOURCE',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'PAYMENT MODE',
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
                        ],
                        rows: [
                          DataRow(
                            cells: [
                              const DataCell(Text('2026-08-08')),
                              const DataCell(
                                Text(
                                  'Scrap & Packaging Sale',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              const DataCell(Text('Cash')),
                              const DataCell(
                                Text(
                                  '₹3,200.00',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.success,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          DataRow(
                            cells: [
                              const DataCell(Text('2026-08-01')),
                              const DataCell(
                                Text(
                                  'Bank Interest Income',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              const DataCell(Text('HDFC Bank')),
                              const DataCell(
                                Text(
                                  '₹1,250.00',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.success,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRecordIncomeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Record Indirect Income'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              AppTextField(
                label: 'Income Source / Description',
                hintText: 'e.g. Commission Credit',
              ),
              SizedBox(height: 12),
              AppTextField(
                label: 'Amount (₹)',
                hintText: '0.00',
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          AppButton(
            text: 'Save Income Entry',
            variant: AppButtonVariant.primary,
            onPressed: () {
              Navigator.pop(ctx);
              Get.snackbar(
                'Success',
                'Income entry saved.',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
        ],
      ),
    );
  }
}
