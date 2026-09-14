import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../../parties/customers/models/customer.dart';
import '../../products/models/product.dart';
import '../controllers/sale_controller.dart';

class _SaleFormItem {
  Product? product;
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController qtyCtrl = TextEditingController(text: '1');
  final TextEditingController rateCtrl = TextEditingController(text: '0');
  final TextEditingController discountCtrl = TextEditingController(text: '0');
  double taxRate = 0.0;

  double get quantity => double.tryParse(qtyCtrl.text) ?? 1.0;
  double get rate => double.tryParse(rateCtrl.text) ?? 0.0;
  double get discount => double.tryParse(discountCtrl.text) ?? 0.0;

  double get baseAmount => quantity * rate;
  double get discountAmount => (baseAmount * discount) / 100;
  double get taxableAmount => baseAmount - discountAmount;
  double get taxAmount => (taxableAmount * taxRate) / 100;
  double get totalAmount => taxableAmount + taxAmount;

  void dispose() {
    nameCtrl.dispose();
    qtyCtrl.dispose();
    rateCtrl.dispose();
    discountCtrl.dispose();
  }
}

class SaleFormView extends StatefulWidget {
  const SaleFormView({super.key});

  @override
  State<SaleFormView> createState() => _SaleFormViewState();
}

class _SaleFormViewState extends State<SaleFormView> {
  final SaleController saleController = Get.find<SaleController>();
  final ApiClient apiClient = Get.find<ApiClient>();

  final List<Customer> availableCustomers = [];
  final List<Product> availableProducts = [];
  bool isLoadingData = false;

  Customer? selectedCustomer;
  final TextEditingController invoiceDateCtrl = TextEditingController(
    text: DateTime.now().toIso8601String().split('T')[0],
  );
  final TextEditingController dueDateCtrl = TextEditingController(
    text: DateTime.now().add(const Duration(days: 30)).toIso8601String().split('T')[0],
  );
  final TextEditingController poNumberCtrl = TextEditingController();
  final TextEditingController challanCtrl = TextEditingController();
  final TextEditingController ewayBillCtrl = TextEditingController();
  final TextEditingController vehicleNumberCtrl = TextEditingController();
  final TextEditingController notesCtrl = TextEditingController();
  final TextEditingController paidAmountCtrl = TextEditingController(text: '0');

  String paymentMethod = 'cash';
  bool isInterstate = false;
  final List<_SaleFormItem> items = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _addItem();
  }

  Future<void> _loadInitialData() async {
    setState(() => isLoadingData = true);
    try {
      final custRes = await apiClient.get(
        ApiEndpoints.customers,
        queryParameters: {'limit': 100},
      );
      final prodRes = await apiClient.get(
        ApiEndpoints.products,
        queryParameters: {'limit': 100},
      );

      final custData = (custRes.data as Map<String, dynamic>)['data'] as List? ?? [];
      final prodData = (prodRes.data as Map<String, dynamic>)['data'] as List? ?? [];

      if (mounted) {
        setState(() {
          availableCustomers.assignAll(
            custData.map((e) => Customer.fromJson(e as Map<String, dynamic>)).toList(),
          );
          availableProducts.assignAll(
            prodData.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList(),
          );
        });
      }
    } catch (_) {
      // Ignored
    } finally {
      if (mounted) {
        setState(() => isLoadingData = false);
      }
    }
  }

  @override
  void dispose() {
    for (final item in items) {
      item.dispose();
    }
    invoiceDateCtrl.dispose();
    dueDateCtrl.dispose();
    poNumberCtrl.dispose();
    challanCtrl.dispose();
    ewayBillCtrl.dispose();
    vehicleNumberCtrl.dispose();
    notesCtrl.dispose();
    paidAmountCtrl.dispose();
    super.dispose();
  }

  void _addItem() {
    setState(() {
      items.add(_SaleFormItem());
    });
  }

  void _removeItem(int index) {
    if (items.length <= 1) return;
    setState(() {
      final removed = items.removeAt(index);
      removed.dispose();
    });
  }

  double get subtotal => items.fold(0.0, (acc, item) => acc + item.taxableAmount);
  double get totalTax => items.fold(0.0, (acc, item) => acc + item.taxAmount);
  double get grandTotal => subtotal + totalTax;
  double get amountPaid => double.tryParse(paidAmountCtrl.text) ?? 0.0;
  double get balanceDue => (grandTotal - amountPaid).clamp(0.0, double.infinity);

  Future<void> _submitInvoice() async {
    if (items.isEmpty) {
      Get.snackbar('Error', 'Please add at least one line item', backgroundColor: AppColors.danger, colorText: Colors.white);
      return;
    }

    final validItems = items.where((it) => it.product != null || it.nameCtrl.text.trim().isNotEmpty).toList();
    if (validItems.isEmpty) {
      Get.snackbar('Error', 'Please select products for the invoice items', backgroundColor: AppColors.danger, colorText: Colors.white);
      return;
    }

    final payload = {
      'customer': selectedCustomer?.id ?? 'walk-in',
      'customerName': selectedCustomer?.name ?? 'Walk-in Customer',
      'paymentMethod': paymentMethod,
      'status': 'completed',
      'notes': notesCtrl.text.trim(),
      'poNumber': poNumberCtrl.text.trim(),
      'deliveryChallan': challanCtrl.text.trim(),
      'ewayBill': ewayBillCtrl.text.trim(),
      'vehicleNumber': vehicleNumberCtrl.text.trim(),
      'isInterstate': isInterstate,
      'items': validItems.map((it) {
        final taxAmt = it.taxAmount;
        final cgst = isInterstate ? 0.0 : taxAmt / 2;
        final sgst = isInterstate ? 0.0 : taxAmt / 2;
        final igst = isInterstate ? taxAmt : 0.0;

        return {
          'product': it.product?.id,
          'name': it.nameCtrl.text.isNotEmpty ? it.nameCtrl.text : (it.product?.name ?? 'Item'),
          'sku': it.product?.sku ?? '',
          'hsn': it.product?.hsnCode ?? '',
          'quantity': it.quantity,
          'unitPrice': it.rate,
          'rate': it.rate,
          'purchasePrice': it.product?.purchasePrice ?? 0.0,
          'discount': it.discount,
          'taxRate': it.taxRate,
          'cgst': cgst,
          'sgst': sgst,
          'igst': igst,
          'total': it.totalAmount,
          'totalAmount': it.totalAmount,
        };
      }).toList(),
      'subtotal': subtotal,
      'taxAmount': totalTax,
      'totalAmount': grandTotal,
      'amountPaid': amountPaid > 0 ? amountPaid : grandTotal,
    };

    final created = await saleController.createSaleInvoice(payload);
    if (created != null) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppTopBar(
        title: 'New B2B Sale Invoice',
        subtitle: 'Create standard GST invoice with party & transport',
        actions: [
          Obx(
            () => AppButton(
              text: 'Save Invoice',
              icon: const Icon(Icons.check_rounded, size: 16),
              variant: AppButtonVariant.primary,
              height: 38,
              isLoading: saleController.isSubmitting.value,
              onPressed: _submitInvoice,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Customer & Invoice Meta Information
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('CUSTOMER & INVOICE DETAILS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 650;

                      final customerSelector = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Customer *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            isExpanded: true,
                            initialValue: selectedCustomer?.id,
                            hint: const Text('Walk-in / Select Customer', style: TextStyle(fontSize: 13)),
                            dropdownColor: isDark ? AppColors.cardDark : AppColors.cardLight,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              filled: true,
                              fillColor: isDark ? AppColors.inputDark : Colors.grey[100],
                              border: OutlineInputBorder(borderRadius: AppRadius.md, borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
                            ),
                            items: [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text('Walk-in Customer', style: TextStyle(fontSize: 13)),
                              ),
                              ...availableCustomers.map((c) => DropdownMenuItem<String>(
                                value: c.id,
                                child: Text('${c.name} (${c.phone})', style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                              )),
                            ],
                            onChanged: (id) {
                              setState(() {
                                selectedCustomer = id != null ? availableCustomers.firstWhereOrNull((c) => c.id == id) : null;
                              });
                            },
                          ),
                        ],
                      );

                      final datesRow = Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: invoiceDateCtrl,
                              label: 'Invoice Date',
                              prefixIcon: const Icon(Icons.calendar_today_outlined, size: 16),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppTextField(
                              controller: dueDateCtrl,
                              label: 'Due Date',
                              prefixIcon: const Icon(Icons.event_outlined, size: 16),
                            ),
                          ),
                        ],
                      );

                      if (isMobile) {
                        return Column(
                          children: [
                            customerSelector,
                            const SizedBox(height: 12),
                            datesRow,
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(flex: 5, child: customerSelector),
                          const SizedBox(width: 16),
                          Expanded(flex: 5, child: datesRow),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  // Transport & Reference row
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 650;
                      if (isMobile) {
                        return Column(
                          children: [
                            AppTextField(controller: poNumberCtrl, label: 'PO Reference #', hintText: 'e.g. PO-9821'),
                            const SizedBox(height: 10),
                            AppTextField(controller: ewayBillCtrl, label: 'E-Way Bill #', hintText: '12-digit number'),
                            const SizedBox(height: 10),
                            AppTextField(controller: vehicleNumberCtrl, label: 'Vehicle Number', hintText: 'e.g. DL-01-AB-1234'),
                          ],
                        );
                      }
                      return Row(
                        children: [
                          Expanded(child: AppTextField(controller: poNumberCtrl, label: 'PO Reference #', hintText: 'e.g. PO-9821')),
                          const SizedBox(width: 12),
                          Expanded(child: AppTextField(controller: ewayBillCtrl, label: 'E-Way Bill #', hintText: '12-digit number')),
                          const SizedBox(width: 12),
                          Expanded(child: AppTextField(controller: vehicleNumberCtrl, label: 'Vehicle Number', hintText: 'e.g. DL-01-AB-1234')),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Line Items Table
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('LINE ITEMS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                      Row(
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: isInterstate,
                                activeColor: AppColors.primary,
                                onChanged: (val) => setState(() => isInterstate = val ?? false),
                              ),
                              const Text('Interstate (IGST)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(width: 8),
                          AppButton(
                            text: 'Add Item',
                            icon: const Icon(Icons.add, size: 16),
                            variant: AppButtonVariant.outline,
                            height: 32,
                            onPressed: _addItem,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.inputDark : Colors.grey[50],
                        borderRadius: AppRadius.md,
                        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isItemMobile = constraints.maxWidth < 650;

                          if (isItemMobile) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 11,
                                      backgroundColor: AppColors.primary.withAlpha(30),
                                      child: Text('${index + 1}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        item.product?.name ?? 'Item ${index + 1}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (items.length > 1)
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () => _removeItem(index),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  initialValue: item.product?.id,
                                  hint: const Text('Select Product...', style: TextStyle(fontSize: 12)),
                                  dropdownColor: isDark ? AppColors.cardDark : AppColors.cardLight,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    border: OutlineInputBorder(borderRadius: AppRadius.sm),
                                  ),
                                  items: availableProducts.map((p) => DropdownMenuItem<String>(
                                    value: p.id,
                                    child: Text('${p.name} (₹${p.salesPrice.toStringAsFixed(2)})', style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
                                  )).toList(),
                                  onChanged: (pId) {
                                    final p = availableProducts.firstWhereOrNull((x) => x.id == pId);
                                    if (p != null) {
                                      setState(() {
                                        item.product = p;
                                        item.nameCtrl.text = p.name;
                                        item.rateCtrl.text = p.salesPrice.toStringAsFixed(2);
                                        item.taxRate = p.taxRate;
                                      });
                                    }
                                  },
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: AppTextField(
                                        controller: item.qtyCtrl,
                                        label: 'Qty',
                                        keyboardType: TextInputType.number,
                                        onChanged: (_) => setState(() {}),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      flex: 4,
                                      child: AppTextField(
                                        controller: item.rateCtrl,
                                        label: 'Rate (₹)',
                                        keyboardType: TextInputType.number,
                                        onChanged: (_) => setState(() {}),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      flex: 3,
                                      child: AppTextField(
                                        controller: item.discountCtrl,
                                        label: 'Disc %',
                                        keyboardType: TextInputType.number,
                                        onChanged: (_) => setState(() {}),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Tax: ${item.taxRate.toStringAsFixed(0)}% (₹${item.taxAmount.toStringAsFixed(2)})',
                                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                                    ),
                                    Text(
                                      'Total: ₹${item.totalAmount.toStringAsFixed(2)}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }

                          return Row(
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: AppColors.primary.withAlpha(30),
                                child: Text('${index + 1}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 4,
                                child: DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  initialValue: item.product?.id,
                                  hint: const Text('Select Product...', style: TextStyle(fontSize: 12)),
                                  dropdownColor: isDark ? AppColors.cardDark : AppColors.cardLight,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    border: OutlineInputBorder(borderRadius: AppRadius.sm),
                                  ),
                                  items: availableProducts.map((p) => DropdownMenuItem<String>(
                                    value: p.id,
                                    child: Text('${p.name} (₹${p.salesPrice.toStringAsFixed(2)})', style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
                                  )).toList(),
                                  onChanged: (pId) {
                                    final p = availableProducts.firstWhereOrNull((x) => x.id == pId);
                                    if (p != null) {
                                      setState(() {
                                        item.product = p;
                                        item.nameCtrl.text = p.name;
                                        item.rateCtrl.text = p.salesPrice.toStringAsFixed(2);
                                        item.taxRate = p.taxRate;
                                      });
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: AppTextField(
                                  controller: item.qtyCtrl,
                                  label: 'Qty',
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: AppTextField(
                                  controller: item.rateCtrl,
                                  label: 'Rate (₹)',
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: AppTextField(
                                  controller: item.discountCtrl,
                                  label: 'Disc %',
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text('Total (₹)', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                    const SizedBox(height: 4),
                                    Text('₹${item.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              if (items.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.danger),
                                  onPressed: () => _removeItem(index),
                                ),
                            ],
                          );
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Payment & Totals Summary
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 650;

                final paymentCard = AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('PAYMENT & SETTLEMENT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: paymentMethod,
                        dropdownColor: isDark ? AppColors.cardDark : AppColors.cardLight,
                        decoration: InputDecoration(
                          labelText: 'Payment Mode',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(borderRadius: AppRadius.md),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'cash', child: Text('Cash', overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'bank', child: Text('Bank Transfer / NEFT', overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'upi', child: Text('UPI / QR', overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'card', child: Text('Credit / Debit Card', overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'credit', child: Text('Credit (Customer Ledger)', overflow: TextOverflow.ellipsis)),
                        ],
                        onChanged: (val) => setState(() => paymentMethod = val ?? 'cash'),
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: paidAmountCtrl,
                        label: 'Paid Amount (₹)',
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: notesCtrl,
                        label: 'Notes / Remarks',
                        hintText: 'Optional notes for this invoice',
                      ),
                    ],
                  ),
                );

                final summaryCard = AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildSummaryRow('Subtotal (Taxable):', '₹${subtotal.toStringAsFixed(2)}'),
                      const SizedBox(height: 8),
                      _buildSummaryRow('GST Tax Amount:', '₹${totalTax.toStringAsFixed(2)}'),
                      const Divider(height: 20),
                      _buildSummaryRow('Grand Total:', '₹${grandTotal.toStringAsFixed(2)}', isBold: true, fontSize: 16),
                      const SizedBox(height: 8),
                      _buildSummaryRow('Paid Amount:', '₹${amountPaid.toStringAsFixed(2)}', isBold: true, valueColor: AppColors.success),
                      const SizedBox(height: 8),
                      _buildSummaryRow('Balance Due:', '₹${balanceDue.toStringAsFixed(2)}', isBold: true, valueColor: balanceDue > 0 ? AppColors.danger : Colors.grey),
                    ],
                  ),
                );

                if (isMobile) {
                  return Column(
                    children: [
                      paymentCard,
                      const SizedBox(height: 16),
                      summaryCard,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: paymentCard),
                    const SizedBox(width: 16),
                    Expanded(flex: 5, child: summaryCard),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          border: Border(
            top: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Grand Total', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    Text(
                      '₹${grandTotal.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              Obx(
                () => AppButton(
                  text: 'Create Invoice',
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  variant: AppButtonVariant.primary,
                  height: 42,
                  isLoading: saleController.isSubmitting.value,
                  onPressed: _submitInvoice,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, double fontSize = 13, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: fontSize, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: isBold ? null : Colors.grey),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(fontSize: fontSize, fontWeight: isBold ? FontWeight.bold : FontWeight.w600, color: valueColor),
        ),
      ],
    );
  }
}
