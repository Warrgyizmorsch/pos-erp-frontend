import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../parties/suppliers/models/supplier.dart';
import '../../models/purchase.dart';
import '../controllers/purchase_return_controller.dart';

class PurchaseReturnFormView extends GetView<PurchaseReturnController> {
  const PurchaseReturnFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppTopBar(
        title: 'Issue Debit Note',
        subtitle: 'Process purchase returns & supplier credit',
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 22),
            tooltip: 'Cancel',
            onPressed: () {
              controller.resetForm();
              controller.viewMode.value = 'list';
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Supplier & Bill Details Card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SUPPLIER & INVOICE DETAILS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 600;

                      final supplierDropdown = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Select Supplier *',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Obx(
                            () => DropdownButtonFormField<Supplier>(
                              initialValue: controller.selectedSupplier.value,
                              isExpanded: true,
                              dropdownColor: isDark
                                  ? AppColors.cardDark
                                  : AppColors.cardLight,
                              decoration: InputDecoration(
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
                              items: controller.suppliers
                                  .map(
                                    (s) => DropdownMenuItem(
                                      value: s,
                                      child: Text(
                                        '${s.name} (${s.phone ?? "N/A"})',
                                        style: const TextStyle(fontSize: 13),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (s) =>
                                  controller.selectedSupplier.value = s,
                            ),
                          ),
                        ],
                      );

                      final billDropdown = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Original Purchase Bill *',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Obx(
                            () => DropdownButtonFormField<Purchase>(
                              initialValue: controller.selectedBill.value,
                              isExpanded: true,
                              dropdownColor: isDark
                                  ? AppColors.cardDark
                                  : AppColors.cardLight,
                              decoration: InputDecoration(
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
                              items: controller.supplierBills
                                  .map(
                                    (bill) => DropdownMenuItem(
                                      value: bill,
                                      child: Text(
                                        '${bill.purchaseNumber} - ₹${bill.totalAmount.toStringAsFixed(2)}',
                                        style: const TextStyle(fontSize: 13),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (bill) =>
                                  controller.selectedBill.value = bill,
                            ),
                          ),
                        ],
                      );

                      if (isMobile) {
                        return Column(
                          children: [
                            supplierDropdown,
                            const SizedBox(height: 12),
                            billDropdown,
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(child: supplierDropdown),
                          const SizedBox(width: 12),
                          Expanded(child: billDropdown),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Returned Items Card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'RETURNED ITEMS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(() {
                    if (controller.isFetchingItems.value) {
                      return const Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (controller.formItems.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Center(
                          child: Text(
                            'Select a valid purchase bill to load returnable items.',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.formItems.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 20),
                      itemBuilder: (context, index) {
                        final item = controller.formItems[index];
                        final base =
                            (item.returnQty * item.purchasePrice) -
                            (item.discountAmount * item.returnQty);
                        final itemTotal =
                            base + ((base * item.taxPercent) / 100);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item.itemName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Text(
                                  '₹${itemTotal.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Purchased: ${item.purchasedQty} • Rate: ₹${item.purchasePrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: 100,
                              child: TextFormField(
                                initialValue: item.returnQty.toString(),
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  labelText: 'Return Qty',
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 6,
                                  ),
                                ),
                                onChanged: (v) {
                                  final qty = double.tryParse(v) ?? 0.0;
                                  controller.updateItemReturnQty(index, qty);
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Settlement & Action Button Card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SETTLEMENT & REMARKS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(
                    () => DropdownButtonFormField<String>(
                      initialValue: controller.refundType.value,
                      decoration: InputDecoration(
                        labelText: 'Refund Settlement Type *',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        filled: true,
                        fillColor: isDark
                            ? AppColors.inputDark
                            : Colors.grey[100],
                        border: OutlineInputBorder(borderRadius: AppRadius.md),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'keep_as_debit',
                          child: Text(
                            'Keep as Supplier Debit Balance',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'refund_received',
                          child: Text(
                            'Refund Cash/Bank Received',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'adjust_future_purchase',
                          child: Text(
                            'Adjust Against Next Bill',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          controller.refundType.value = v;
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Grand Return Total:',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              '₹${controller.formFinalGrandTotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        AppButton(
                          text: 'Issue Debit Note',
                          icon: const Icon(Icons.check, size: 18),
                          isLoading: controller.isSubmitting.value,
                          width: double.infinity,
                          height: AppSizes.buttonHeightMd,
                          onPressed: () => controller.saveReturn(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
