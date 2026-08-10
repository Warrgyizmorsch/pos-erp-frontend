import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../controllers/financial_reports_controller.dart';

class TrialBalanceView extends GetView<FinancialReportsController> {
  const TrialBalanceView({super.key});

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
                          Icons.bar_chart_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Basic Trial Balance Statement',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withAlpha(25),
                                  borderRadius: AppRadius.full,
                                ),
                                child: const Text(
                                  'BALANCED',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.success,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Validation-level double-entry debit vs credit balance summary by ledger.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  AppButton(
                    text: 'Refresh',
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    variant: AppButtonVariant.outline,
                    onPressed: () => controller.loadCurrentTabReport(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Trial Balance Table
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
                              label: Text('LEDGER NAME & CODE',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey))),
                          DataColumn(
                              label: Text('ACCOUNT GROUP',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey))),
                          DataColumn(
                              numeric: true,
                              label: Text('DEBIT BALANCE',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey))),
                          DataColumn(
                              numeric: true,
                              label: Text('CREDIT BALANCE',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey))),
                        ],
                        rows: const [
                          DataRow(cells: [
                            DataCell(Text('HDFC Bank Account (1001)',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                            DataCell(Text('Bank Accounts')),
                            DataCell(Text('₹2,45,000.00',
                                style: TextStyle(fontFamily: 'monospace'))),
                            DataCell(Text('-')),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('Sales Revenue (4001)',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                            DataCell(Text('Sales Accounts')),
                            DataCell(Text('-')),
                            DataCell(Text('₹3,85,000.00',
                                style: TextStyle(fontFamily: 'monospace'))),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('Purchases Account (5001)',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                            DataCell(Text('Purchase Accounts')),
                            DataCell(Text('₹1,40,000.00',
                                style: TextStyle(fontFamily: 'monospace'))),
                            DataCell(Text('-')),
                          ]),
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
}
