import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../controllers/pos_controller.dart';

class POSFullBreakupDialog extends StatelessWidget {
  const POSFullBreakupDialog({super.key});

  static Future<void> show(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => const POSFullBreakupDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<POSController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bill = controller.activeBill;

    if (bill == null) return const SizedBox.shrink();

    final realItems = bill.items.where((i) => i.itemName.isNotEmpty).toList();

    final subtotal = realItems.fold(0.0, (s, i) {
      final base = i.quantity * i.pricePerUnit;
      if (i.isInclusive && i.taxPercent > 0) {
        return s + base / (1 + i.taxPercent / 100);
      }
      return s + base;
    });

    final discountTotal = realItems.fold(0.0, (s, i) {
      final base = i.quantity * i.pricePerUnit;
      return s + base * (i.discount / 100);
    });

    final itemTax = realItems.fold(0.0, (s, i) => s + i.taxAmount);
    final grandTotal = realItems.fold(0.0, (s, i) => s + i.total);
    final finalTotal = grandTotal.roundToDouble();
    final roundOff = finalTotal - grandTotal;

    final rows = [
      {'label': 'Sub Total', 'value': subtotal},
      {'label': 'Discount', 'value': -discountTotal},
      {'label': 'Item Tax', 'value': itemTax},
      {'label': 'Round Off', 'value': roundOff},
    ];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.xl),
      backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Full Bill Breakup',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const Divider(height: 24),

              ...rows.map(
                (r) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        r['label'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '₹${(r['value'] as double).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Divider(height: 24),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: AppRadius.lg,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Final Total',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '₹${finalTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              AppButton(
                text: 'Close',
                variant: AppButtonVariant.ghost,
                width: double.infinity,
                onPressed: () => Get.back(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
