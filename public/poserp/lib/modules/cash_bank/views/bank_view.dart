import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/cash_bank_controller.dart';

class BankView extends GetView<CashBankController> {
  const BankView({super.key});

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
                            Icons.account_balance_rounded,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Bank Accounts Registry',
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
                      'Configure bank accounts, track IFSC/account details, and monitor transactional balances.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      text: 'Add Bank Account',
                      icon: const Icon(Icons.add_rounded, size: 16),
                      variant: AppButtonVariant.primary,
                      width: double.infinity,
                      onPressed: () => _showAddBankDialog(context),
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
                                  Icons.account_balance_rounded,
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
                                      'Bank Accounts Registry',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Configure bank accounts, track IFSC/account details, and monitor transactional balances.',
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
                        AppButton(
                          text: 'Add Bank Account',
                          icon: const Icon(Icons.add_rounded, size: 16),
                          variant: AppButtonVariant.primary,
                          onPressed: () => _showAddBankDialog(context),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),

                  // Bank Accounts Data Table
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
                                  'BANK NAME',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'ACCOUNT NUMBER',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'IFSC CODE',
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
                                  'CURRENT BALANCE',
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
                                      'HDFC Bank Corporate',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const DataCell(
                                    Text(
                                      '50200012345678',
                                      style: TextStyle(fontFamily: 'monospace'),
                                    ),
                                  ),
                                  const DataCell(
                                    Text(
                                      'HDFC0000123',
                                      style: TextStyle(fontFamily: 'monospace'),
                                    ),
                                  ),
                                  const DataCell(
                                    Text(
                                      '₹2,45,000.00',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              DataRow(
                                cells: [
                                  const DataCell(
                                    Text(
                                      'State Bank of India',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const DataCell(
                                    Text(
                                      '301122334455',
                                      style: TextStyle(fontFamily: 'monospace'),
                                    ),
                                  ),
                                  const DataCell(
                                    Text(
                                      'SBIN0004321',
                                      style: TextStyle(fontFamily: 'monospace'),
                                    ),
                                  ),
                                  const DataCell(
                                    Text(
                                      '₹1,12,800.00',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
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

  void _showAddBankDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Bank Account'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              AppTextField(
                label: 'Bank / Account Name',
                hintText: 'e.g. ICICI Corporate',
              ),
              SizedBox(height: 12),
              AppTextField(
                label: 'Account Number',
                hintText: 'e.g. 00011223344',
              ),
              SizedBox(height: 12),
              AppTextField(label: 'IFSC Code', hintText: 'e.g. ICIC0000001'),
              SizedBox(height: 12),
              AppTextField(
                label: 'Opening Balance (₹)',
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
            text: 'Save Bank Account',
            variant: AppButtonVariant.primary,
            onPressed: () {
              Navigator.pop(ctx);
              Get.snackbar(
                'Success',
                'Bank account registered.',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
        ],
      ),
    );
  }
}
