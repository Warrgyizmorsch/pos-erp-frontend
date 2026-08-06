import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../parties/suppliers/models/supplier.dart';
import '../../models/purchase.dart';
import '../controllers/purchase_return_controller.dart';

class PurchaseReturnFormView extends GetView<PurchaseReturnController> {
  const PurchaseReturnFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () {
                      controller.resetForm();
                      controller.viewMode.value = 'list';
                    },
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Issue Debit Note / Purchase Return',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Deduct inventory stock and adjust supplier ledger balances.',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Main Form Body
              Expanded(
                child: SingleChildScrollView(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column: Supplier & Bill Picker + Items Table + Settlement
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            // Card 1: Supplier & Invoice Picker
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
                                  Row(
                                    children: [
                                      // Supplier Selector
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                                initialValue: controller
                                                    .selectedSupplier
                                                    .value,
                                                isExpanded: true,
                                                dropdownColor: isDark
                                                    ? AppColors.cardDark
                                                    : AppColors.cardLight,
                                                decoration: InputDecoration(
                                                  contentPadding:
                                                      const EdgeInsets.symmetric(
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
                                                          : AppColors
                                                                .borderLight,
                                                    ),
                                                  ),
                                                ),
                                                items: controller.suppliers.map((
                                                  s,
                                                ) {
                                                  return DropdownMenuItem<
                                                    Supplier
                                                  >(
                                                    value: s,
                                                    child: Text(
                                                      '${s.name} (${s.phone}) — Out: ₹${s.outstandingBalance.toStringAsFixed(2)}',
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  );
                                                }).toList(),
                                                onChanged: (s) =>
                                                    controller
                                                            .selectedSupplier
                                                            .value =
                                                        s,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 14),

                                      // Purchase Bill Selector
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                                initialValue: controller
                                                    .selectedBill
                                                    .value,
                                                isExpanded: true,
                                                dropdownColor: isDark
                                                    ? AppColors.cardDark
                                                    : AppColors.cardLight,
                                                decoration: InputDecoration(
                                                  contentPadding:
                                                      const EdgeInsets.symmetric(
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
                                                          : AppColors
                                                                .borderLight,
                                                    ),
                                                  ),
                                                ),
                                                items: controller.supplierBills
                                                    .map((bill) {
                                                      return DropdownMenuItem<
                                                        Purchase
                                                      >(
                                                        value: bill,
                                                        child: Text(
                                                          '${bill.purchaseNumber} — Total: ₹${bill.totalAmount.toStringAsFixed(2)} (${bill.purchaseDate.split('T')[0]})',
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 13,
                                                              ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      );
                                                    })
                                                    .toList(),
                                                onChanged: (bill) =>
                                                    controller
                                                            .selectedBill
                                                            .value =
                                                        bill,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Return Date',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Obx(
                                              () => TextField(
                                                controller:
                                                    TextEditingController(
                                                      text: controller
                                                          .returnDate
                                                          .value,
                                                    ),
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                ),
                                                decoration: InputDecoration(
                                                  hintText: 'YYYY-MM-DD',
                                                  suffixIcon: const Icon(
                                                    Icons
                                                        .calendar_today_rounded,
                                                    size: 16,
                                                  ),
                                                  contentPadding:
                                                      const EdgeInsets.symmetric(
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
                                                          : AppColors
                                                                .borderLight,
                                                    ),
                                                  ),
                                                ),
                                                onChanged: (v) =>
                                                    controller
                                                            .returnDate
                                                            .value =
                                                        v,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'State of Supply',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Obx(
                                              () => TextField(
                                                controller:
                                                    TextEditingController(
                                                      text: controller
                                                          .stateOfSupply
                                                          .value,
                                                    ),
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                ),
                                                decoration: InputDecoration(
                                                  hintText: 'e.g. Maharashtra',
                                                  contentPadding:
                                                      const EdgeInsets.symmetric(
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
                                                          : AppColors
                                                                .borderLight,
                                                    ),
                                                  ),
                                                ),
                                                onChanged: (v) =>
                                                    controller
                                                            .stateOfSupply
                                                            .value =
                                                        v,
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

                            // Card 2: Returned Items Table
                            AppCard(
                              padding: EdgeInsets.zero,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Text(
                                      'RETURNED ITEMS (STOCK REDUCTIONS)',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  Obx(() {
                                    if (controller.isFetchingItems.value) {
                                      return const Padding(
                                        padding: EdgeInsets.all(24.0),
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    }
                                    if (controller.formItems.isEmpty) {
                                      return const Padding(
                                        padding: EdgeInsets.all(32.0),
                                        child: Center(
                                          child: Text(
                                            'Select a valid original purchase bill to load returnable items.',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      );
                                    }

                                    return SingleChildScrollView(
                                      child: DataTable(
                                        columnSpacing: 16,
                                        columns: const [
                                          DataColumn(
                                            label: Text(
                                              '#',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            label: Text(
                                              'Item Name',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            numeric: true,
                                            label: Text(
                                              'Purchased',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            numeric: true,
                                            label: Text(
                                              'Prev. Ret.',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            numeric: true,
                                            label: Text(
                                              'Ret Qty',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            numeric: true,
                                            label: Text(
                                              'Price',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            numeric: true,
                                            label: Text(
                                              'Tax %',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            numeric: true,
                                            label: Text(
                                              'Return Total',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                        rows: List.generate(controller.formItems.length, (
                                          idx,
                                        ) {
                                          final item =
                                              controller.formItems[idx];
                                          final base =
                                              (item.returnQty *
                                                  item.purchasePrice) -
                                              (item.discountAmount *
                                                  item.returnQty);
                                          final itemTotal =
                                              base +
                                              ((base * item.taxPercent) / 100);

                                          return DataRow(
                                            cells: [
                                              DataCell(
                                                Text(
                                                  '${idx + 1}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      item.itemName,
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    if (item.barcode.isNotEmpty)
                                                      Text(
                                                        item.barcode,
                                                        style: const TextStyle(
                                                          fontSize: 10,
                                                          fontFamily:
                                                              'monospace',
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  '${item.purchasedQty}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  '${item.alreadyReturnedQty}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                SizedBox(
                                                  width: 70,
                                                  height: 32,
                                                  child: TextField(
                                                    controller:
                                                        TextEditingController(
                                                          text: item.returnQty
                                                              .toString(),
                                                        ),
                                                    keyboardType:
                                                        TextInputType.number,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    decoration: InputDecoration(
                                                      contentPadding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 4,
                                                          ),
                                                      border:
                                                          OutlineInputBorder(
                                                            borderRadius:
                                                                AppRadius.sm,
                                                          ),
                                                    ),
                                                    onChanged: (v) {
                                                      final qty =
                                                          double.tryParse(v) ??
                                                          0.0;
                                                      controller
                                                          .updateItemReturnQty(
                                                            idx,
                                                            qty,
                                                          );
                                                    },
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  '₹${item.purchasePrice.toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontFamily: 'monospace',
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  '${item.taxPercent}%',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  '₹${itemTotal.toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'monospace',
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Card 3: Settlement & Remarks
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
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Refund Settlement Type',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Obx(
                                              () => DropdownButtonFormField<String>(
                                                initialValue:
                                                    controller.refundType.value,
                                                dropdownColor: isDark
                                                    ? AppColors.cardDark
                                                    : AppColors.cardLight,
                                                decoration: InputDecoration(
                                                  contentPadding:
                                                      const EdgeInsets.symmetric(
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
                                                          : AppColors
                                                                .borderLight,
                                                    ),
                                                  ),
                                                ),
                                                items: const [
                                                  DropdownMenuItem(
                                                    value: 'keep_as_debit',
                                                    child: Text(
                                                      'Keep as Supplier Debit Balance',
                                                    ),
                                                  ),
                                                  DropdownMenuItem(
                                                    value: 'refund_received',
                                                    child: Text(
                                                      'Refund Cash/Bank Received',
                                                    ),
                                                  ),
                                                  DropdownMenuItem(
                                                    value:
                                                        'adjust_future_purchase',
                                                    child: Text(
                                                      'Adjust Against Next Bill',
                                                    ),
                                                  ),
                                                ],
                                                onChanged: (v) {
                                                  if (v != null) {
                                                    controller
                                                            .refundType
                                                            .value =
                                                        v;
                                                  }
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Reference / Transaction No',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            TextField(
                                              onChanged: (v) =>
                                                  controller.referenceNo.value =
                                                      v,
                                              style: const TextStyle(
                                                fontSize: 13,
                                              ),
                                              decoration: InputDecoration(
                                                hintText:
                                                    'e.g. UPI Ref ID, Cheque No',
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
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
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Internal Notes',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  TextField(
                                    onChanged: (v) =>
                                        controller.notes.value = v,
                                    maxLines: 2,
                                    style: const TextStyle(fontSize: 13),
                                    decoration: InputDecoration(
                                      hintText:
                                          'Add return reasons, quality issues, or comments...',
                                      contentPadding: const EdgeInsets.all(12),
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
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Right Column: Summary Card & Action Buttons
                      Expanded(
                        flex: 1,
                        child: AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'RETURN INVOICE SUMMARY',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Obx(
                                () => Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Subtotal Base',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          '₹${controller.formSubtotal.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Proportional Discount',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.success,
                                          ),
                                        ),
                                        Text(
                                          '-₹${controller.formTotalDiscount.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.success,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Tax Reversed',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          '₹${controller.formTotalTax.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Checkbox(
                                              value: controller.roundOff.value,
                                              onChanged: (v) =>
                                                  controller.roundOff.value =
                                                      v ?? false,
                                            ),
                                            const Text(
                                              'Round Off',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          '₹${controller.formRoundOffValue.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 24),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Grand Return Amount',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '₹${controller.formFinalGrandTotal.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? AppColors.inputDark
                                            : Colors.grey[100],
                                        borderRadius: AppRadius.md,
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                'Refund Inflow:',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              Text(
                                                '₹${controller.formRefundReceivedAmount.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.success,
                                                  fontFamily: 'monospace',
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                'Supplier Debit Adjustment:',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              Text(
                                                '₹${controller.formDebitBalance.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.warning,
                                                  fontFamily: 'monospace',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    AppButton(
                                      text: 'Save Debit Note',
                                      width: double.infinity,
                                      isLoading: controller.isSubmitting.value,
                                      onPressed: () => controller.saveReturn(),
                                    ),
                                    const SizedBox(height: 10),
                                    AppButton(
                                      text: 'Cancel & Return',
                                      variant: AppButtonVariant.outline,
                                      width: double.infinity,
                                      onPressed: () {
                                        controller.resetForm();
                                        controller.viewMode.value = 'list';
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
