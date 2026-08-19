import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/cash_bank_controller.dart';

class CashView extends GetView<CashBankController> {
  const CashView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 700;
              final horizontalScrollController = ScrollController();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Responsive Header
                  if (isMobile) ...[
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(25),
                            borderRadius: AppRadius.lg,
                          ),
                          child: const Icon(
                            Icons.currency_rupee_rounded,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Petty Cash & Register',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Monitor in-hand cash, process cash adjustments, and execute bank deposits.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            text: 'Bank Transfer',
                            icon: const Icon(
                              Icons.swap_horiz_rounded,
                              size: 16,
                            ),
                            variant: AppButtonVariant.outline,
                            onPressed: () => _showTransferDialog(context),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AppButton(
                            text: 'Adjust Cash',
                            icon: const Icon(Icons.tune_rounded, size: 16),
                            variant: AppButtonVariant.primary,
                            onPressed: () => _showAdjustDialog(context),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withAlpha(25),
                                  borderRadius: AppRadius.lg,
                                ),
                                child: const Icon(
                                  Icons.currency_rupee_rounded,
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
                                      'Petty Cash & Cash Drawer Register',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Monitor in-hand cash, process cash adjustments, and execute bank deposits.',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
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
                        const SizedBox(width: 16),
                        Row(
                          children: [
                            AppButton(
                              text: 'Bank Transfer',
                              icon: const Icon(
                                Icons.swap_horiz_rounded,
                                size: 16,
                              ),
                              variant: AppButtonVariant.outline,
                              onPressed: () => _showTransferDialog(context),
                            ),
                            const SizedBox(width: 8),
                            AppButton(
                              text: 'Adjust Cash',
                              icon: const Icon(Icons.tune_rounded, size: 16),
                              variant: AppButtonVariant.primary,
                              onPressed: () => _showAdjustDialog(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),

                  // Cash Balance Card
                  AppCard(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'CURRENT IN-HAND CASH BALANCE',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '₹42,500.00',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AppButton(
                          text: 'View History',
                          icon: const Icon(Icons.history_rounded, size: 16),
                          variant: AppButtonVariant.outline,
                          onPressed: () => Get.toNamed('/cash-bank'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Recent Cash Activity Table Header
                  const Text(
                    'Recent Cash Entries',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // Recent Cash Activity Responsive Data Table
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: ClipRRect(
                      borderRadius: AppRadius.lg,
                      child: Scrollbar(
                        controller: horizontalScrollController,
                        thumbVisibility: true,
                        trackVisibility: true,
                        child: SingleChildScrollView(
                          controller: horizontalScrollController,
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(
                              isDark ? AppColors.inputDark : Colors.grey[100],
                            ),
                            columns: const [
                              DataColumn(
                                label: Text(
                                  'TYPE',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'RECEIPT / REF',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
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
                                  const DataCell(
                                    Text(
                                      'POS Cash Sale',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const DataCell(
                                    Text(
                                      'INV-2026-088',
                                      style: TextStyle(fontFamily: 'monospace'),
                                    ),
                                  ),
                                  const DataCell(Text('2026-08-10')),
                                  const DataCell(
                                    Text(
                                      '+₹1,250.00',
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
                                  const DataCell(
                                    Text(
                                      'Petty Cash Expense',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const DataCell(
                                    Text(
                                      'EXP-042',
                                      style: TextStyle(fontFamily: 'monospace'),
                                    ),
                                  ),
                                  const DataCell(Text('2026-08-09')),
                                  const DataCell(
                                    Text(
                                      '-₹350.00',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.danger,
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
              );
            },
          ),
        ),
      ),
    );
  }

  void _showAdjustDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Adjust Cash Balance'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              AppTextField(
                label: 'Adjustment Amount (₹)',
                hintText: '0.00',
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 12),
              AppTextField(
                label: 'Remarks / Notes',
                hintText: 'e.g. Petty cash replenishment',
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
            text: 'Save Adjustment',
            variant: AppButtonVariant.primary,
            onPressed: () {
              Navigator.pop(ctx);
              Get.snackbar(
                'Cash Adjusted',
                'Petty cash updated.',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
        ],
      ),
    );
  }

  void _showTransferDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bank Transfer (Cash <-> Bank)'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              AppTextField(
                label: 'Transfer Amount (₹)',
                hintText: '0.00',
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 12),
              AppTextField(label: 'Bank Account ID', hintText: 'e.g. HDFC-01'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          AppButton(
            text: 'Process Transfer',
            variant: AppButtonVariant.primary,
            onPressed: () {
              Navigator.pop(ctx);
              Get.snackbar(
                'Transfer Processed',
                'Bank transfer recorded.',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
        ],
      ),
    );
  }
}
