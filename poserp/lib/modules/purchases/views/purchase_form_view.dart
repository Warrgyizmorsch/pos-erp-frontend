import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../products/models/product.dart';
import '../controllers/purchase_controller.dart';

class PurchaseFormView extends GetView<PurchaseController> {
  const PurchaseFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final String? editId = Get.parameters['id'];

    if (editId == null || editId.isEmpty) {
      if (controller.formItems.isEmpty) {
        controller.initNewForm();
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          editId != null ? 'Edit Purchase Bill' : 'Create Purchase Bill',
        ),
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
            // Supplier & Bill Meta Card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SUPPLIER & BILL INFORMATION',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Supplier Dropdown
                      Expanded(
                        child: Column(
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
                            Obx(() {
                              final suppIds = controller.availableSuppliers
                                  .map((s) => s.id)
                                  .toSet();
                              final currentSuppId =
                                  controller.formSupplier.value?.id;
                              final validSuppId =
                                  suppIds.contains(currentSuppId)
                                  ? currentSuppId
                                  : (controller.availableSuppliers.isNotEmpty
                                        ? controller.availableSuppliers.first.id
                                        : null);

                              return DropdownButtonFormField<String>(
                                isExpanded: true,
                                initialValue: validSuppId,
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
                                items: controller.availableSuppliers
                                    .map(
                                      (s) => DropdownMenuItem<String>(
                                        value: s.id,
                                        child: Text(
                                          '${s.name} (${s.phone})',
                                          style: const TextStyle(fontSize: 13),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (id) {
                                  controller.formSupplier.value = controller
                                      .availableSuppliers
                                      .firstWhereOrNull((s) => s.id == id);
                                },
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          label: 'Supplier Invoice Ref / Bill No.',
                          hintText: 'e.g. INV-10023',
                          controller:
                              TextEditingController(
                                  text: controller.formInvoiceNumber.value,
                                )
                                ..selection = TextSelection.collapsed(
                                  offset:
                                      controller.formInvoiceNumber.value.length,
                                ),
                          onChanged: (v) =>
                              controller.formInvoiceNumber.value = v,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'Purchase Date',
                          controller: TextEditingController(
                            text: controller.formPurchaseDate.value,
                          ),
                          onChanged: (v) =>
                              controller.formPurchaseDate.value = v,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          label: 'State of Supply',
                          controller: TextEditingController(
                            text: controller.formStateOfSupply.value,
                          ),
                          onChanged: (v) =>
                              controller.formStateOfSupply.value = v,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Transporter (Optional)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Obx(() {
                              final transIds = controller.availableTransporters
                                  .map((t) => t.id)
                                  .toSet();
                              final currentTransId =
                                  controller.formTransporter.value?.id;
                              final validTransId =
                                  transIds.contains(currentTransId)
                                  ? currentTransId
                                  : null;

                              return DropdownButtonFormField<String>(
                                isExpanded: true,
                                initialValue: validTransId,
                                hint: const Text(
                                  'None',
                                  style: TextStyle(fontSize: 13),
                                ),
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
                                items: controller.availableTransporters
                                    .map(
                                      (t) => DropdownMenuItem<String>(
                                        value: t.id,
                                        child: Text(
                                          t.name,
                                          style: const TextStyle(fontSize: 13),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (id) {
                                  controller.formTransporter.value = controller
                                      .availableTransporters
                                      .firstWhereOrNull((t) => t.id == id);
                                },
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Items Entry Card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'PURCHASE ITEMS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      AppButton(
                        text: 'Add Item Row',
                        icon: const Icon(Icons.add, size: 16),
                        variant: AppButtonVariant.secondary,
                        height: 32,
                        onPressed: () => controller.addFormItemRow(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Obx(
                    () => SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(
                          isDark ? AppColors.cardDark : Colors.grey[100],
                        ),
                        columns: const [
                          DataColumn(label: Text('#')),
                          DataColumn(label: Text('Select Product')),
                          DataColumn(label: Text('Item Name')),
                          DataColumn(label: Text('Qty')),
                          DataColumn(label: Text('Purchase Rate (₹)')),
                          DataColumn(label: Text('Sales Price (₹)')),
                          DataColumn(label: Text('Tax %')),
                          DataColumn(label: Text('Line Total (₹)')),
                          DataColumn(label: Text('Action')),
                        ],
                        rows: controller.formItems.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final item = entry.value;

                          return DataRow(
                            cells: [
                              DataCell(Text('${idx + 1}')),
                              DataCell(
                                SizedBox(
                                  width: 160,
                                  child: DropdownButton<Product>(
                                    value: item.product,
                                    hint: const Text(
                                      'Existing Prod',
                                      style: TextStyle(fontSize: 11),
                                    ),
                                    isExpanded: true,
                                    items: controller.availableProducts
                                        .map(
                                          (p) => DropdownMenuItem(
                                            value: p,
                                            child: Text(
                                              p.name,
                                              style: const TextStyle(
                                                fontSize: 11,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (p) {
                                      if (p != null) {
                                        controller.selectProductForItemRow(
                                          item,
                                          p,
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ),
                              DataCell(
                                SizedBox(
                                  width: 140,
                                  child: TextFormField(
                                    initialValue: item.name,
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 4,
                                      ),
                                    ),
                                    onChanged: (val) {
                                      item.name = val;
                                      controller.formItems.refresh();
                                    },
                                  ),
                                ),
                              ),
                              DataCell(
                                SizedBox(
                                  width: 60,
                                  child: TextFormField(
                                    initialValue: item.quantity.toStringAsFixed(
                                      0,
                                    ),
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 4,
                                      ),
                                    ),
                                    onChanged: (val) {
                                      item.quantity = double.tryParse(val) ?? 1;
                                      controller.formItems.refresh();
                                    },
                                  ),
                                ),
                              ),
                              DataCell(
                                SizedBox(
                                  width: 80,
                                  child: TextFormField(
                                    initialValue: item.purchasePrice
                                        .toStringAsFixed(2),
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 4,
                                      ),
                                    ),
                                    onChanged: (val) {
                                      item.purchasePrice =
                                          double.tryParse(val) ?? 0;
                                      controller.formItems.refresh();
                                    },
                                  ),
                                ),
                              ),
                              DataCell(
                                SizedBox(
                                  width: 80,
                                  child: TextFormField(
                                    initialValue: item.salesPrice
                                        .toStringAsFixed(2),
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 4,
                                      ),
                                    ),
                                    onChanged: (val) {
                                      item.salesPrice =
                                          double.tryParse(val) ?? 0;
                                      controller.formItems.refresh();
                                    },
                                  ),
                                ),
                              ),
                              DataCell(
                                SizedBox(
                                  width: 60,
                                  child: TextFormField(
                                    initialValue: item.taxRate.toStringAsFixed(
                                      0,
                                    ),
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 4,
                                      ),
                                    ),
                                    onChanged: (val) {
                                      item.taxRate = double.tryParse(val) ?? 0;
                                      controller.formItems.refresh();
                                    },
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '₹${item.lineTotal.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataCell(
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 18,
                                    color: AppColors.danger,
                                  ),
                                  onPressed: () =>
                                      controller.removeFormItemRow(idx),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Payments & Totals Card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PAYMENT & SUMMARY',
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
                              'Payment Method *',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Obx(() {
                              final allowedMethods = {
                                'cash',
                                'bank',
                                'bank_transfer',
                                'upi',
                                'card',
                                'cheque',
                                'credit',
                              };
                              String rawMethod = controller
                                  .formPaymentMethod
                                  .value
                                  .toLowerCase()
                                  .trim();
                              if (!allowedMethods.contains(rawMethod)) {
                                rawMethod = 'cash';
                              }

                              return DropdownButtonFormField<String>(
                                isExpanded: true,
                                initialValue: rawMethod,
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
                                    value: 'cash',
                                    child: Text('Cash'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'bank',
                                    child: Text('Bank Transfer'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'bank_transfer',
                                    child: Text('Bank Transfer (Wire)'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'upi',
                                    child: Text('UPI / QR'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'card',
                                    child: Text('Card'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'cheque',
                                    child: Text('Cheque'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'credit',
                                    child: Text('Credit / Ledger'),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    controller.formPaymentMethod.value = val;
                                  }
                                },
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          label: 'Amount Paid (₹)',
                          hintText: '0.00',
                          keyboardType: TextInputType.number,
                          controller: TextEditingController(
                            text: controller.formAmountPaid.value
                                .toStringAsFixed(2),
                          ),
                          onChanged: (v) => controller.formAmountPaid.value =
                              double.tryParse(v) ?? 0.0,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          label: 'Discount (₹)',
                          hintText: '0.00',
                          keyboardType: TextInputType.number,
                          controller: TextEditingController(
                            text: controller.formDiscountAmount.value
                                .toStringAsFixed(2),
                          ),
                          onChanged: (v) =>
                              controller.formDiscountAmount.value =
                                  double.tryParse(v) ?? 0.0,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          label: 'Shipping Charges (₹)',
                          hintText: '0.00',
                          keyboardType: TextInputType.number,
                          controller: TextEditingController(
                            text: controller.formShippingCharges.value
                                .toStringAsFixed(2),
                          ),
                          onChanged: (v) =>
                              controller.formShippingCharges.value =
                                  double.tryParse(v) ?? 0.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Grand Total Bill:',
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
                          text: editId != null
                              ? 'Update Purchase Bill'
                              : 'Save Purchase Bill',
                          icon: const Icon(Icons.check, size: 18),
                          isLoading: controller.isSubmitting.value,
                          onPressed: () async {
                            final success = await controller.savePurchase(
                              editId: editId,
                            );
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
