import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../parties/suppliers/models/supplier.dart';
import '../controllers/payment_out_controller.dart';

class PaymentOutFormDialog extends GetView<PaymentOutController> {
  const PaymentOutFormDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
      backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Obx(
                () => Row(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      controller.editingPaymentId.value != null
                          ? 'Edit Payment-Out'
                          : 'Add Payment-Out',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 20),

              // Content Body
              Expanded(
                child: SingleChildScrollView(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 550;

                      final leftCol = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'SUPPLIER / VENDOR *',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Obx(
                            () => DropdownButtonFormField<Supplier>(
                              initialValue: controller.selectedSupplier.value,
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
                                        '${s.name} (${s.phone})',
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (s) =>
                                  controller.selectedSupplier.value = s,
                            ),
                          ),
                          const SizedBox(height: 16),

                          AppTextField(
                            label: 'Description / Notes',
                            hintText: 'Payment notes or terms...',
                            controller:
                                TextEditingController(
                                    text: controller.description.value,
                                  )
                                  ..selection = TextSelection.collapsed(
                                    offset: controller.description.value.length,
                                  ),
                            onChanged: (v) => controller.description.value = v,
                          ),
                          const SizedBox(height: 16),

                          // Unpaid Bills Section
                          Obx(() {
                            if (controller.selectedSupplier.value == null) {
                              return const SizedBox.shrink();
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'UNPAID PURCHASE BILLS',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (controller.isFetchingUnpaid.value)
                                  const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(12),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  )
                                else if (controller.unpaidPurchases.isEmpty)
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? AppColors.inputDark
                                          : Colors.grey[100],
                                      borderRadius: AppRadius.md,
                                    ),
                                    child: const Text(
                                      'No unpaid purchase bills for supplier.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                                else
                                  SizedBox(
                                    height: 180,
                                    child: ListView.builder(
                                      itemCount:
                                          controller.unpaidPurchases.length,
                                      itemBuilder: (context, idx) {
                                        final bill =
                                            controller.unpaidPurchases[idx];
                                        final isSelected =
                                            controller
                                                .selectedPurchase
                                                .value
                                                ?.id ==
                                            bill.id;
                                        final due = bill.dueAmount > 0
                                            ? bill.dueAmount
                                            : bill.totalAmount -
                                                  bill.amountPaid;

                                        return GestureDetector(
                                          onTap: () => controller
                                              .selectUnpaidPurchase(bill),
                                          child: Container(
                                            margin: const EdgeInsets.only(
                                              bottom: 8,
                                            ),
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? AppColors.primary
                                                        .withValues(alpha: 0.1)
                                                  : (isDark
                                                        ? AppColors.inputDark
                                                        : Colors.grey[100]),
                                              borderRadius: AppRadius.md,
                                              border: Border.all(
                                                color: isSelected
                                                    ? AppColors.primary
                                                    : Colors.transparent,
                                                width: 1.5,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      bill.purchaseNumber,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 13,
                                                        fontFamily: 'monospace',
                                                      ),
                                                    ),
                                                    Text(
                                                      bill.purchaseDate.split(
                                                        'T',
                                                      )[0],
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      '₹${due.toStringAsFixed(2)}',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 13,
                                                        color: AppColors.danger,
                                                      ),
                                                    ),
                                                    const Text(
                                                      'Due Amount',
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            );
                          }),
                        ],
                      );

                      final rightCol = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: AppTextField(
                                  label: 'Date *',
                                  controller: TextEditingController(
                                    text: controller.date.value,
                                  ),
                                  onChanged: (v) => controller.date.value = v,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AppTextField(
                                  label: 'Receipt No',
                                  enabled: false,
                                  controller: TextEditingController(
                                    text:
                                        controller.editingPaymentId.value !=
                                            null
                                        ? 'Existing'
                                        : 'Auto-generated',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          AppTextField(
                            label: 'Amount Paid (₹) *',
                            hintText: '0.00',
                            keyboardType: TextInputType.number,
                            controller:
                                TextEditingController(
                                    text: controller.amountPaid.value
                                        .toStringAsFixed(2),
                                  )
                                  ..selection = TextSelection.collapsed(
                                    offset: controller.amountPaid.value
                                        .toStringAsFixed(2)
                                        .length,
                                  ),
                            onChanged: (v) => controller.amountPaid.value =
                                double.tryParse(v) ?? 0.0,
                          ),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Payment Mode *',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Obx(
                                      () => DropdownButtonFormField<String>(
                                        initialValue:
                                            controller.paymentMode.value,
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
                                          DropdownMenuItem(
                                            value: 'Cheque',
                                            child: Text('Cheque'),
                                          ),
                                        ],
                                        onChanged: (v) {
                                          if (v != null) {
                                            controller.paymentMode.value = v;
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Obx(() {
                                if (controller.paymentMode.value
                                        .toLowerCase() ==
                                    'cash') {
                                  return const SizedBox.shrink();
                                }
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Bank Account *',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        DropdownButtonFormField<String>(
                                          initialValue:
                                              controller.bankAccountId.value,
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
                                                    : AppColors.borderLight,
                                              ),
                                            ),
                                          ),
                                          items: controller.bankAccounts
                                              .map((b) {
                                                final id =
                                                    b['_id']?.toString() ??
                                                    b['id']?.toString() ??
                                                    '';
                                                final name =
                                                    b['accountName']
                                                        ?.toString() ??
                                                    b['bankName']?.toString() ??
                                                    b['name']?.toString() ??
                                                    'Account';
                                                return DropdownMenuItem<String>(
                                                  value: id,
                                                  child: Text(
                                                    name,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                );
                                              })
                                              .where(
                                                (item) =>
                                                    item.value!.isNotEmpty,
                                              )
                                              .toList(),
                                          onChanged: (v) =>
                                              controller.bankAccountId.value =
                                                  v,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                          const SizedBox(height: 16),

                          AppTextField(
                            label: 'Reference / Transaction No.',
                            hintText: 'e.g. UTR12003948',
                            controller:
                                TextEditingController(
                                    text: controller.referenceNo.value,
                                  )
                                  ..selection = TextSelection.collapsed(
                                    offset: controller.referenceNo.value.length,
                                  ),
                            onChanged: (v) => controller.referenceNo.value = v,
                          ),
                        ],
                      );

                      if (isMobile) {
                        return Column(
                          children: [
                            leftCol,
                            const SizedBox(height: 16),
                            rightCol,
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: leftCol),
                          const SizedBox(width: 16),
                          Expanded(child: rightCol),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const Divider(height: 20),

              // Footer Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                    text: 'Cancel',
                    variant: AppButtonVariant.secondary,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 12),
                  Obx(
                    () => AppButton(
                      text: controller.editingPaymentId.value != null
                          ? 'Update Payment'
                          : 'Save Payment',
                      icon: const Icon(Icons.check, size: 18),
                      isLoading: controller.isSubmitting.value,
                      onPressed: () async {
                        final nav = Navigator.of(context);
                        final ok = await controller.savePayment();
                        if (ok) nav.pop();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
