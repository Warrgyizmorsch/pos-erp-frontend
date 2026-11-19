import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../../parties/customers/models/customer.dart';
import '../../models/sale.dart';
import '../controllers/sale_return_controller.dart';

class SaleReturnFormView extends GetView<SaleReturnController> {
  const SaleReturnFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const AppTopBar(
        title: 'Issue Credit Note',
        subtitle: 'Process customer returns & store credit',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Party & Bill Details Card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PARTY & BILL DETAILS',
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

                      final customerDropdown = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Select Customer *',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Obx(
                            () => DropdownButtonFormField<Customer>(
                              initialValue: controller.selectedCustomer.value,
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
                              items: controller.availableCustomers
                                  .map(
                                    (c) => DropdownMenuItem(
                                      value: c,
                                      child: Text(
                                        '${c.name} (${c.phone})',
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (c) =>
                                  controller.onCustomerSelected(c),
                            ),
                          ),
                        ],
                      );

                      final invoiceDropdown = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Original Invoice *',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Obx(
                            () => DropdownButtonFormField<Sale>(
                              initialValue: controller.selectedInvoice.value,
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
                              items: controller.customerInvoices
                                  .map(
                                    (inv) => DropdownMenuItem(
                                      value: inv,
                                      child: Text(
                                        '${inv.invoiceNumber} - ₹${inv.totalAmount.toStringAsFixed(2)}',
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (inv) =>
                                  controller.onInvoiceSelected(inv),
                            ),
                          ),
                        ],
                      );

                      if (isMobile) {
                        return Column(
                          children: [
                            customerDropdown,
                            const SizedBox(height: 12),
                            invoiceDropdown,
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(child: customerDropdown),
                          const SizedBox(width: 12),
                          Expanded(child: invoiceDropdown),
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
                            'No items loaded. Select a valid original invoice to list sold items.',
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
                                  '₹${item.lineTotal.toStringAsFixed(2)}',
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
                              'Sold: ${item.soldQty.toInt()} • Prev Returned: ${item.alreadyReturnedQty.toInt()} • Rate: ₹${item.pricePerUnit.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                SizedBox(
                                  width: 80,
                                  child: TextFormField(
                                    initialValue: item.returnQty
                                        .toStringAsFixed(0),
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    decoration: const InputDecoration(
                                      labelText: 'Ret Qty',
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 6,
                                      ),
                                    ),
                                    onChanged: (val) {
                                      final qty = double.tryParse(val) ?? 0;
                                      controller.updateItemReturnQty(item, qty);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    initialValue: item.reason,
                                    decoration: const InputDecoration(
                                      labelText: 'Reason',
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 6,
                                      ),
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'Damaged',
                                        child: Text(
                                          'Damaged',
                                          style: TextStyle(fontSize: 11),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Wrong item',
                                        child: Text(
                                          'Wrong item',
                                          style: TextStyle(fontSize: 11),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Expired',
                                        child: Text(
                                          'Expired',
                                          style: TextStyle(fontSize: 11),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Customer cancelled',
                                        child: Text(
                                          'Cancelled',
                                          style: TextStyle(fontSize: 11),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Other',
                                        child: Text(
                                          'Other',
                                          style: TextStyle(fontSize: 11),
                                        ),
                                      ),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) {
                                        controller.updateItemReason(item, val);
                                      }
                                    },
                                  ),
                                ),
                              ],
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

            // Refund Settlement Options
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'REFUND SETTLEMENT',
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
                        labelText: 'Settlement Option *',
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
                          value: 'refund_now',
                          child: Text(
                            'Refund Now (Outflow)',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'keep_as_credit',
                          child: Text(
                            'Keep as Store Credit',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'adjust_future_invoice',
                          child: Text(
                            'Adjust in Future Invoice',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          controller.refundType.value = val;
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Grand Return Total & Issue Action
                  Obx(
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Grand Return Amount:',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              '₹${controller.formGrandTotal.toStringAsFixed(2)}',
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
                          text: 'Issue Credit Note',
                          icon: const Icon(Icons.check, size: 18),
                          isLoading: controller.isSubmitting.value,
                          width: double.infinity,
                          height: AppSizes.buttonHeightMd,
                          onPressed: () async {
                            final success = await controller.submitCreditNote();
                            if (success) Get.back();
                          },
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
