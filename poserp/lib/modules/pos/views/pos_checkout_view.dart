import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../controllers/pos_checkout_controller.dart';

class POSCheckoutView extends GetView<POSCheckoutController> {
  const POSCheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(
        title: 'POS Payment & Checkout',
        subtitle: 'Multi-tender payment, change calculation & receipt',
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 800;

            if (isDesktop) {
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _buildOrderSummaryCard()),
                    const SizedBox(width: 20),
                    Expanded(flex: 3, child: _buildPaymentDetailsCard()),
                  ],
                ),
              );
            }

            // Mobile Layout (<800dp)
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildOrderSummaryCard(),
                  const SizedBox(height: 16),
                  _buildPaymentDetailsCard(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard() {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            final items = controller.cartItems;
            final count = items.length;
            final qtyTotal = items.fold(0.0, (sum, i) => sum + i.quantity);

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Order Summary',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '$count Items (${qtyTotal.toStringAsFixed(0)} Qty)',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          }),
          const Divider(height: 20),
          Obx(() {
            final items = controller.cartItems;
            if (items.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: Text(
                    'No items in cart',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, _) => const Divider(height: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    item.itemName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${item.quantity.toStringAsFixed(0)} x ₹${item.rate.toStringAsFixed(2)}',
                  ),
                  trailing: Text(
                    '₹${item.total.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
            );
          }),
          const Divider(height: 20),
          Obx(
            () => Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal', style: TextStyle(fontSize: 13)),
                    Text(
                      '₹${controller.subtotal.value.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Taxes', style: TextStyle(fontSize: 13)),
                    Text(
                      '₹${controller.taxAmount.value.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Discounts', style: TextStyle(fontSize: 13)),
                    Text(
                      '-₹${controller.discountAmount.value.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Grand Total',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '₹${controller.grandTotal.value.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
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
    );
  }

  Widget _buildPaymentDetailsCard() {
    return Column(
      children: [
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Multi-Tender Payment Methods',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),

              // Quick Tender Buttons Grid
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Exact Amount',
                      height: 42,
                      variant: AppButtonVariant.outline,
                      onPressed: () => controller.setExactPayment(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppButton(
                      text: '+ ₹100',
                      height: 42,
                      variant: AppButtonVariant.outline,
                      onPressed: () => controller.addQuickCash(100),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppButton(
                      text: '+ ₹500',
                      height: 42,
                      variant: AppButtonVariant.outline,
                      onPressed: () => controller.addQuickCash(500),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

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
                    const SizedBox(height: 10),
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
                    const SizedBox(height: 10),
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
              const SizedBox(height: 16),

              // Change Due / Remaining Box
              Obx(
                () => Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: controller.changeDue > 0
                        ? AppColors.success.withAlpha(20)
                        : (controller.remainingBalance > 0
                              ? AppColors.danger.withAlpha(20)
                              : AppColors.primary.withAlpha(20)),
                    borderRadius: AppRadius.md,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        controller.changeDue > 0
                            ? 'CHANGE DUE TO CUSTOMER'
                            : (controller.remainingBalance > 0
                                  ? 'REMAINING UNPAID'
                                  : 'PAYMENT MATCHED'),
                        style: TextStyle(
                          fontSize: 11,
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
                          fontSize: 20,
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

        // Complete Checkout Action Button
        Obx(
          () => AppButton(
            text: controller.isSubmitting.value
                ? 'Processing Sale...'
                : 'Complete Sale & Print Receipt',
            icon: const Icon(Icons.print_rounded, size: 18),
            variant: AppButtonVariant.primary,
            width: double.infinity,
            height: AppSizes.buttonHeightMd,
            onPressed: controller.isSubmitting.value
                ? null
                : () => controller.submitCheckout(),
          ),
        ),
      ],
    );
  }
}
