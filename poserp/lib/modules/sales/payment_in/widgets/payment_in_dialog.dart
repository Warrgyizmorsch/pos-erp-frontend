import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../parties/customers/models/customer.dart';
import '../controllers/payment_in_controller.dart';
import '../models/payment_in.dart';
import '../models/payment_in_payload.dart';

class PaymentInDialog extends StatefulWidget {
  final PaymentIn? payment;

  const PaymentInDialog({super.key, this.payment});

  static Future<void> show(BuildContext context, {PaymentIn? payment}) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PaymentInDialog(payment: payment),
    );
  }

  @override
  State<PaymentInDialog> createState() => _PaymentInDialogState();
}

class _PaymentInDialogState extends State<PaymentInDialog> {
  final _formKey = GlobalKey<FormState>();

  Customer? _selectedCustomer;
  late TextEditingController _amountController;
  late TextEditingController _dateController;
  late TextEditingController _referenceController;
  late TextEditingController _descriptionController;

  String _paymentMode = 'Cash';
  String? _selectedBankAccountId;
  String? _linkedInvoiceId;

  @override
  void initState() {
    super.initState();
    final p = widget.payment;
    final controller = Get.find<PaymentInController>();

    _amountController = TextEditingController(
      text: p != null ? p.amountReceived.toStringAsFixed(2) : '',
    );
    _dateController = TextEditingController(
      text: p != null && p.date.isNotEmpty
          ? p.date.split('T')[0]
          : DateTime.now().toIso8601String().split('T')[0],
    );
    _referenceController = TextEditingController(text: p?.referenceNo ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _paymentMode = p?.paymentMode ?? 'Cash';
    _selectedBankAccountId = p?.cashBankAccountId;
    _linkedInvoiceId = p?.linkedInvoiceId;

    if (p != null) {
      if (p.partyId is Customer) {
        _selectedCustomer = p.partyId as Customer;
      } else if (p.partyId is String) {
        _selectedCustomer = controller.availableCustomers.firstWhereOrNull(
          (c) => c.id == p.partyId,
        );
      }
      if (_selectedCustomer != null) {
        controller.fetchUnpaidInvoices(_selectedCustomer!.id);
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _dateController.dispose();
    _referenceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCustomer == null) {
      Get.snackbar('Error', 'Please select a customer.');
      return;
    }

    if (_paymentMode.toLowerCase() != 'cash' &&
        (_selectedBankAccountId == null || _selectedBankAccountId!.isEmpty)) {
      Get.snackbar('Error', 'Bank account is required for non-cash payments.');
      return;
    }

    final controller = Get.find<PaymentInController>();
    final amount = double.tryParse(_amountController.text) ?? 0.0;

    final payload = PaymentInPayload(
      partyId: _selectedCustomer!.id,
      amountReceived: amount,
      paymentMode: _paymentMode,
      cashBankAccountId: _selectedBankAccountId,
      date: _dateController.text,
      linkedInvoiceId: _linkedInvoiceId,
      referenceNo: _referenceController.text.trim(),
      description: _descriptionController.text.trim(),
    );

    final bool success;
    if (widget.payment != null) {
      success = await controller.updatePayment(widget.payment!.id, payload);
    } else {
      success = await controller.createPayment(payload);
    }

    if (success) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = Get.find<PaymentInController>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.xl),
      backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.account_balance_wallet,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.payment != null
                              ? 'Edit Payment-In'
                              : 'Add Payment-In',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const Divider(height: 20),

                Flexible(
                  child: SingleChildScrollView(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Side (Customer & Unpaid Invoices)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Customer / Party *',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppColors.foregroundDark
                                      : AppColors.foregroundLight,
                                ),
                              ),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<Customer>(
                                initialValue: _selectedCustomer,
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
                                      (c) => DropdownMenuItem<Customer>(
                                        value: c,
                                        child: Text(
                                          '${c.name} (${c.phone})',
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (c) {
                                  setState(() {
                                    _selectedCustomer = c;
                                    _linkedInvoiceId = null;
                                  });
                                  if (c != null) {
                                    controller.fetchUnpaidInvoices(c.id);
                                  }
                                },
                              ),
                              const SizedBox(height: 16),

                              // Unpaid Invoices List
                              Text(
                                'Unpaid Invoices',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppColors.mutedForegroundDark
                                      : AppColors.mutedForegroundLight,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Obx(() {
                                if (controller.isFetchingUnpaid.value) {
                                  return const Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  );
                                }
                                if (controller.unpaidInvoices.isEmpty) {
                                  return Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? AppColors.inputDark
                                          : Colors.grey[100],
                                      borderRadius: AppRadius.md,
                                    ),
                                    child: const Text(
                                      'No unpaid invoices found.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  );
                                }

                                return Column(
                                  children: controller.unpaidInvoices.map((
                                    inv,
                                  ) {
                                    final isSelected =
                                        _linkedInvoiceId == inv.id;
                                    final balance = inv.balanceDue;
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (isSelected) {
                                            _linkedInvoiceId = null;
                                          } else {
                                            _linkedInvoiceId = inv.id;
                                            _amountController.text = balance
                                                .toStringAsFixed(2);
                                          }
                                        });
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 6,
                                        ),
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.primary.withValues(
                                                  alpha: 0.1,
                                                )
                                              : (isDark
                                                    ? AppColors.inputDark
                                                    : Colors.grey[100]),
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColors.primary
                                                : Colors.transparent,
                                          ),
                                          borderRadius: AppRadius.md,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  inv.invoiceNumber,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                Text(
                                                  inv.createdAt?.split(
                                                        'T',
                                                      )[0] ??
                                                      '',
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              'Due: ₹${balance.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.danger,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                );
                              }),
                              const SizedBox(height: 12),

                              AppTextField(
                                label: 'Notes / Description (Optional)',
                                hintText: 'Enter payment notes...',
                                controller: _descriptionController,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Right Side (Date, Amount, Mode, Bank Account, Ref)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppTextField(
                                label: 'Date',
                                controller: _dateController,
                                isRequired: true,
                              ),
                              const SizedBox(height: 12),

                              AppTextField(
                                label: 'Amount Received (₹)',
                                hintText: '0.00',
                                controller: _amountController,
                                keyboardType: TextInputType.number,
                                isRequired: true,
                                validator: (v) =>
                                    v == null ||
                                        double.tryParse(v) == null ||
                                        double.parse(v) <= 0
                                    ? 'Enter valid amount'
                                    : null,
                              ),
                              const SizedBox(height: 12),

                              Text(
                                'Payment Mode *',
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
                                initialValue: _paymentMode,
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
                                    child: Text('UPI / QR'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Card',
                                    child: Text('Card'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Cheque',
                                    child: Text('Cheque'),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _paymentMode = val;
                                      if (val.toLowerCase() == 'cash') {
                                        _selectedBankAccountId = null;
                                      }
                                    });
                                  }
                                },
                              ),
                              const SizedBox(height: 12),

                              if (_paymentMode.toLowerCase() != 'cash') ...[
                                Text(
                                  'Collect in Bank Account *',
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
                                  initialValue: _selectedBankAccountId,
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
                                  items: controller.bankAccounts
                                      .map(
                                        (acc) => DropdownMenuItem<String>(
                                          value:
                                              acc['_id']?.toString() ??
                                              acc['id']?.toString(),
                                          child: Text(
                                            '${acc['accountName']} (${acc['bankName'] ?? ''})',
                                            style: const TextStyle(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (val) => setState(
                                    () => _selectedBankAccountId = val,
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],

                              AppTextField(
                                label: 'Reference / Transaction ID (Optional)',
                                hintText: 'e.g. UTR / Cheque No.',
                                controller: _referenceController,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AppButton(
                        text: 'Cancel',
                        variant: AppButtonVariant.ghost,
                        onPressed: () => Get.back(),
                      ),
                      const SizedBox(width: 12),
                      AppButton(
                        text: widget.payment != null
                            ? 'Update Payment'
                            : 'Save Payment',
                        isLoading: controller.isSubmitting.value,
                        onPressed: () => _handleSave(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
