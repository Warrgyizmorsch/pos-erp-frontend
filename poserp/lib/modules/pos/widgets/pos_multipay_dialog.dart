import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/pos_controller.dart';

class POSMultiPayDialog extends StatefulWidget {
  const POSMultiPayDialog({super.key});

  static Future<void> show(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => const POSMultiPayDialog(),
    );
  }

  @override
  State<POSMultiPayDialog> createState() => _POSMultiPayDialogState();
}

class _POSMultiPayDialogState extends State<POSMultiPayDialog> {
  final _cashController = TextEditingController();
  final _upiController = TextEditingController();
  final _cardController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final controller = Get.find<POSController>();
    final bill = controller.activeBill;
    if (bill != null) {
      _cashController.text = bill.grandTotal.toStringAsFixed(2);
      _upiController.text = '0.00';
      _cardController.text = '0.00';
    }
  }

  @override
  void dispose() {
    _cashController.dispose();
    _upiController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<POSController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bill = controller.activeBill;

    if (bill == null) return const SizedBox.shrink();

    final grandTotal = bill.grandTotal;

    final cashAmt = double.tryParse(_cashController.text) ?? 0.0;
    final upiAmt = double.tryParse(_upiController.text) ?? 0.0;
    final cardAmt = double.tryParse(_cardController.text) ?? 0.0;
    final totalReceived = cashAmt + upiAmt + cardAmt;
    final balance = grandTotal - totalReceived;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.xl),
      backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Multi Pay / Split Tender',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const Divider(height: 24),

              AppTextField(
                label: 'Cash Amount (₹)',
                controller: _cashController,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'UPI / Online Amount (₹)',
                controller: _upiController,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Card Amount (₹)',
                controller: _cardController,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.inputDark : Colors.grey[100],
                  borderRadius: AppRadius.lg,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Bill Total:'),
                        Text(
                          '₹${grandTotal.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Received:'),
                        Text(
                          '₹${totalReceived.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          balance > 0 ? 'Remaining Balance:' : 'Change Return:',
                        ),
                        Text(
                          '₹${balance.abs().toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: balance > 0
                                ? AppColors.danger
                                : AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                    text: 'Cancel',
                    variant: AppButtonVariant.ghost,
                    onPressed: () => Get.back(),
                  ),
                  const SizedBox(width: 12),
                  AppButton(
                    text: 'Apply & Save',
                    onPressed: () {
                      controller.setPaymentMode('Partial');
                      controller.setAmountReceived(totalReceived);
                      Get.back();
                      controller.submitSale();
                    },
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
