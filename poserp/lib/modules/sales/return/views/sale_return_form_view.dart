import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../parties/customers/models/customer.dart';
import '../../models/sale.dart';
import '../controllers/sale_return_controller.dart';

class SaleReturnFormView extends GetView<SaleReturnController> {
  const SaleReturnFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Issue Credit Note'),
        backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
        foregroundColor: isDark
            ? AppColors.foregroundDark
            : AppColors.foregroundLight,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
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
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Customer Dropdown
                      Expanded(
                        child: Column(
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
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Original Invoice Dropdown
                      Expanded(
                        child: Column(
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
                        ),
                      ),
                    ],
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
                      fontSize: 12,
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
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(
                          isDark ? AppColors.cardDark : Colors.grey[100],
                        ),
                        columns: const [
                          DataColumn(label: Text('#')),
                          DataColumn(label: Text('Item Name')),
                          DataColumn(label: Text('Sold Qty')),
                          DataColumn(label: Text('Prev. Ret')),
                          DataColumn(label: Text('Ret Qty')),
                          DataColumn(label: Text('Rate (₹)')),
                          DataColumn(label: Text('Tax %')),
                          DataColumn(label: Text('Return Total')),
                          DataColumn(label: Text('Reason')),
                          DataColumn(label: Text('Stock Action')),
                        ],
                        rows: controller.formItems.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final item = entry.value;

                          return DataRow(
                            cells: [
                              DataCell(Text('${idx + 1}')),
                              DataCell(
                                Text(
                                  item.itemName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataCell(Text('${item.soldQty.toInt()}')),
                              DataCell(
                                Text('${item.alreadyReturnedQty.toInt()}'),
                              ),
                              DataCell(
                                SizedBox(
                                  width: 60,
                                  child: TextFormField(
                                    initialValue: item.returnQty
                                        .toStringAsFixed(0),
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 4,
                                      ),
                                    ),
                                    onChanged: (val) {
                                      final qty = double.tryParse(val) ?? 0;
                                      controller.updateItemReturnQty(item, qty);
                                    },
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '₹${item.pricePerUnit.toStringAsFixed(2)}',
                                ),
                              ),
                              DataCell(Text('${item.taxPercent}%')),
                              DataCell(
                                Text(
                                  '₹${item.lineTotal.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataCell(
                                DropdownButton<String>(
                                  value: item.reason,
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
                                      value: 'Exchange',
                                      child: Text(
                                        'Exchange',
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
                              DataCell(
                                DropdownButton<String>(
                                  value: item.stockAction,
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'restore_stock',
                                      child: Text(
                                        'Restore Stock',
                                        style: TextStyle(fontSize: 11),
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 'damaged_stock',
                                      child: Text(
                                        'Damaged Stock',
                                        style: TextStyle(fontSize: 11),
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 'no_stock',
                                      child: Text(
                                        'No Stock Action',
                                        style: TextStyle(fontSize: 11),
                                      ),
                                    ),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) {
                                      controller.updateItemStockAction(
                                        item,
                                        val,
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Refund Settlement & Notes
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'REFUND SETTLEMENT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Refund Settlement Option *',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Obx(
                              () => DropdownButtonFormField<String>(
                                initialValue: controller.refundType.value,
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
                                items: const [
                                  DropdownMenuItem(
                                    value: 'refund_now',
                                    child: Text('Refund Now (Outflow)'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'keep_as_credit',
                                    child: Text('Keep as Store Credit'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'adjust_future_invoice',
                                    child: Text('Adjust in Future Invoice'),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    controller.refundType.value = val;
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Obx(() {
                        if (controller.refundType.value != 'refund_now') {
                          return const SizedBox.shrink();
                        }
                        return Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Payment Mode *',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                initialValue: controller.paymentMode.value,
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
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Cash',
                                    child: Text('Cash'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Bank',
                                    child: Text('Bank Transfer'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'UPI',
                                    child: Text('UPI'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Card',
                                    child: Text('Card'),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    controller.paymentMode.value = val;
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Grand Total Breakdown & Save Button
                  Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        AppButton(
                          text: 'Issue Credit Note',
                          icon: const Icon(Icons.check, size: 18),
                          isLoading: controller.isSubmitting.value,
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
