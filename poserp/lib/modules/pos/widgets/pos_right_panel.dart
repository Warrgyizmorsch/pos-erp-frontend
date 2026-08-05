import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../parties/customers/models/customer.dart';
import '../../parties/customers/widgets/customer_dialog.dart';
import '../controllers/pos_controller.dart';
import '../models/pos_bill.dart';
import 'pos_full_breakup_dialog.dart';
import 'pos_multipay_dialog.dart';
import 'pos_print_dialog.dart';

class POSRightPanel extends StatelessWidget {
  const POSRightPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<POSController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final bill = controller.activeBill;
      if (bill == null) return const SizedBox.shrink();

      final grandTotal = bill.grandTotal;
      final totalItems = bill.totalItems;
      final totalQty = bill.totalQuantity;
      final amountReceived = bill.amountReceived;
      final change = (amountReceived - grandTotal).clamp(0.0, double.infinity);
      final remaining = (grandTotal - amountReceived).clamp(
        0.0,
        double.infinity,
      );

      final isWalkIn = bill.customer == null || bill.customer!.id == 'walk-in';

      return AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ═══ Total Bill Amount Card ═══
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                      : [AppColors.primary, AppColors.primaryHover],
                ),
                borderRadius: AppRadius.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TOTAL BILL AMOUNT',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => POSFullBreakupDialog.show(context),
                        child: const Text(
                          'Full Breakup [Ctrl+F]',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '₹${grandTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(color: Colors.white24, height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Items: $totalItems',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Quantity: ${totalQty.toInt()}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ═══ Customer Selection ═══
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Customer',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.foregroundDark
                        : AppColors.foregroundLight,
                  ),
                ),
                GestureDetector(
                  onTap: () => CustomerDialog.show(context),
                  child: const Text(
                    '+ Add New',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<Customer>(
              initialValue: isWalkIn ? walkInCustomer : bill.customer,
              dropdownColor: isDark ? AppColors.cardDark : AppColors.cardLight,
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
              items: [
                DropdownMenuItem<Customer>(
                  value: walkInCustomer,
                  child: const Text(
                    'Walk-in Customer (Default)',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
                ...controller.availableCustomers.map(
                  (c) => DropdownMenuItem<Customer>(
                    value: c,
                    child: Text(
                      '${c.name} (${c.phone})',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
              ],
              onChanged: (c) => controller.setCustomer(c),
            ),
            const SizedBox(height: 16),

            // ═══ Payment Mode & Amount Received ═══
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Mode',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.foregroundDark
                              : AppColors.foregroundLight,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: bill.paymentMode,
                        dropdownColor: isDark
                            ? AppColors.cardDark
                            : AppColors.cardLight,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
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
                            child: Text('Cash', style: TextStyle(fontSize: 13)),
                          ),
                          DropdownMenuItem(
                            value: 'UPI',
                            child: Text(
                              'UPI / QR',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Card',
                            child: Text('Card', style: TextStyle(fontSize: 13)),
                          ),
                          DropdownMenuItem(
                            value: 'Bank',
                            child: Text(
                              'Bank Transfer',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Wallet',
                            child: Text(
                              'Wallet',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'Partial',
                            child: Text(
                              'Multi Pay / Split',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            if (val == 'Partial') {
                              POSMultiPayDialog.show(context);
                            } else {
                              controller.setPaymentMode(val);
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    label: 'Amount Received (₹)',
                    hintText: grandTotal.toStringAsFixed(2),
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      final parsed = double.tryParse(val) ?? grandTotal;
                      controller.setAmountReceived(parsed);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ═══ Change / Remaining Indicator ═══
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: remaining > 0
                    ? AppColors.danger.withValues(alpha: 0.1)
                    : AppColors.success.withValues(alpha: 0.1),
                borderRadius: AppRadius.md,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    remaining > 0 ? 'Remaining Amount:' : 'Change to Return:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: remaining > 0
                          ? AppColors.danger
                          : AppColors.success,
                    ),
                  ),
                  Text(
                    '₹${(remaining > 0 ? remaining : change).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: remaining > 0
                          ? AppColors.danger
                          : AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),

            // ═══ Action Buttons ═══
            AppButton(
              text: 'SAVE & PRINT BILL',
              icon: const Icon(Icons.print, size: 18),
              isLoading: controller.isSubmitting.value,
              width: double.infinity,
              height: 48,
              onPressed: () async {
                final success = await controller.submitSale();
                if (success &&
                    controller.lastSavedSale.value != null &&
                    context.mounted) {
                  POSPrintDialog.show(context, controller.lastSavedSale.value!);
                }
              },
            ),
            const SizedBox(height: 8),
            AppButton(
              text: 'Other / Multi Payments [Ctrl+M]',
              variant: AppButtonVariant.secondary,
              width: double.infinity,
              height: 40,
              onPressed: () => POSMultiPayDialog.show(context),
            ),
          ],
        ),
      );
    });
  }
}
