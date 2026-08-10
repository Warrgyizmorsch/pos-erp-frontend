import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/pos_checkout_controller.dart';

class POSCheckoutView extends GetView<POSCheckoutController> {
  const POSCheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('POS Terminal — Payment & Checkout'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Cart Summary
              Expanded(
                flex: 2,
                child: AppCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'Order Summary',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '3 Items',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Expanded(
                        child: ListView(
                          children: const [
                            ListTile(
                              dense: true,
                              title: Text(
                                'Organic Green Tea (250g)',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text('2 x ₹500.00'),
                              trailing: Text(
                                '₹1,000.00',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            ListTile(
                              dense: true,
                              title: Text(
                                'Dark Chocolate Bar (100g)',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text('1 x ₹250.00'),
                              trailing: Text(
                                '₹250.00',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 24),
                      Obx(
                        () => Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Subtotal',
                                  style: TextStyle(fontSize: 13),
                                ),
                                Text(
                                  '₹${controller.grandTotal.value.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text(
                                  'Taxes & Discounts',
                                  style: TextStyle(fontSize: 13),
                                ),
                                Text('₹0.00', style: TextStyle(fontSize: 13)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Grand Total',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '₹${controller.grandTotal.value.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),

              // Right Column: Payment Methods & Cash Tender
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    AppCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Multi-Tender Payment Method',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Quick Cash Fill Buttons
                          Row(
                            children: [
                              Expanded(
                                child: AppButton(
                                  text: 'Exact Amount',
                                  variant: AppButtonVariant.outline,
                                  onPressed: () => controller.setExactPayment(),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: AppButton(
                                  text: '+ ₹100',
                                  variant: AppButtonVariant.outline,
                                  onPressed: () => controller.addQuickCash(100),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: AppButton(
                                  text: '+ ₹500',
                                  variant: AppButtonVariant.outline,
                                  onPressed: () => controller.addQuickCash(500),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Tender Inputs
                          Obx(
                            () => Column(
                              children: [
                                AppTextField(
                                  label: 'Cash Tendered (₹)',
                                  initialValue: controller.cashTendered.value
                                      .toStringAsFixed(2),
                                  keyboardType: TextInputType.number,
                                  onChanged: (val) {
                                    final d = double.tryParse(val) ?? 0.0;
                                    controller.cashTendered.value = d;
                                  },
                                ),
                                const SizedBox(height: 12),
                                AppTextField(
                                  label: 'Card Payment (₹)',
                                  initialValue: controller.cardTendered.value
                                      .toStringAsFixed(2),
                                  keyboardType: TextInputType.number,
                                  onChanged: (val) {
                                    final d = double.tryParse(val) ?? 0.0;
                                    controller.cardTendered.value = d;
                                  },
                                ),
                                const SizedBox(height: 12),
                                AppTextField(
                                  label: 'UPI / QR Payment (₹)',
                                  initialValue: controller.upiTendered.value
                                      .toStringAsFixed(2),
                                  keyboardType: TextInputType.number,
                                  onChanged: (val) {
                                    final d = double.tryParse(val) ?? 0.0;
                                    controller.upiTendered.value = d;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Change Due Box
                          Obx(
                            () => Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: controller.changeDue > 0
                                    ? AppColors.success.withAlpha(20)
                                    : (controller.remainingBalance > 0
                                          ? AppColors.danger.withAlpha(20)
                                          : AppColors.primary.withAlpha(20)),
                                borderRadius: AppRadius.md,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    controller.changeDue > 0
                                        ? 'CHANGE DUE TO CUSTOMER'
                                        : (controller.remainingBalance > 0
                                              ? 'REMAINING UNPAID BALANCE'
                                              : 'PAYMENT EXACTLY MATCHED'),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: controller.changeDue > 0
                                          ? AppColors.success
                                          : (controller.remainingBalance > 0
                                                ? AppColors.danger
                                                : AppColors.primary),
                                    ),
                                  ),
                                  Text(
                                    '₹${(controller.changeDue > 0 ? controller.changeDue : controller.remainingBalance).toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: controller.changeDue > 0
                                          ? AppColors.success
                                          : (controller.remainingBalance > 0
                                                ? AppColors.danger
                                                : AppColors.primary),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Complete Checkout Button
                    Obx(
                      () => AppButton(
                        text: controller.isSubmitting.value
                            ? 'Processing Sale...'
                            : 'Complete Sale & Print Receipt',
                        icon: const Icon(Icons.print_rounded, size: 18),
                        variant: AppButtonVariant.primary,
                        width: double.infinity,
                        onPressed: controller.isSubmitting.value
                            ? null
                            : () => controller.submitCheckout(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
