import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/khaata_controller.dart';
import '../models/khaata_party.dart';

class KhaataPaymentDialog extends StatefulWidget {
  final KhaataParty party;
  final String type; // 'payment_in' | 'payment_out'

  const KhaataPaymentDialog({
    super.key,
    required this.party,
    required this.type,
  });

  static Future<void> show(
    BuildContext context, {
    required KhaataParty party,
    required String type,
  }) {
    return showDialog(
      context: context,
      builder: (_) => KhaataPaymentDialog(party: party, type: type),
    );
  }

  @override
  State<KhaataPaymentDialog> createState() => _KhaataPaymentDialogState();
}

class _KhaataPaymentDialogState extends State<KhaataPaymentDialog> {
  final KhaataController controller = Get.find<KhaataController>();
  late final TextEditingController amountCtrl;
  final TextEditingController notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    double initialAmt = 0;
    if (widget.type == 'payment_in' && widget.party.currentBalance > 0) {
      initialAmt = widget.party.currentBalance;
    } else if (widget.type == 'payment_out' && widget.party.currentBalance < 0) {
      initialAmt = widget.party.currentBalance.abs();
    }

    amountCtrl = TextEditingController(
      text: initialAmt > 0 ? initialAmt.toStringAsFixed(2) : '',
    );
  }

  @override
  void dispose() {
    amountCtrl.dispose();
    notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amt = double.tryParse(amountCtrl.text) ?? 0.0;
    final success = await controller.recordTransaction(
      partyId: widget.party.id,
      amount: amt,
      type: widget.type,
      partyType: widget.party.partyType,
      notes: notesCtrl.text.trim(),
    );

    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPaymentIn = widget.type == 'payment_in';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (isPaymentIn ? AppColors.success : AppColors.danger)
                        .withAlpha(25),
                    borderRadius: AppRadius.md,
                  ),
                  child: Icon(
                    isPaymentIn
                        ? Icons.arrow_downward_rounded
                        : Icons.arrow_upward_rounded,
                    color: isPaymentIn ? AppColors.success : AppColors.danger,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isPaymentIn ? 'Receive Payment' : 'Make Payment',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        isPaymentIn
                            ? 'Record cash/bank receipt from customer'
                            : 'Record cash/bank disbursement to supplier',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Party Overview Tile
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.inputDark : Colors.grey[100],
                borderRadius: AppRadius.md,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.party.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Phone: ${widget.party.phone}',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(20),
                      borderRadius: AppRadius.full,
                    ),
                    child: Text(
                      widget.party.partyType.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Current Outstanding Balance
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Current Outstanding:',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  widget.party.currentBalance > 0
                      ? '₹${widget.party.currentBalance.toStringAsFixed(2)} (Receivable)'
                      : widget.party.currentBalance < 0
                          ? '₹${widget.party.currentBalance.abs().toStringAsFixed(2)} (Payable)'
                          : '₹0.00 (Settled)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: widget.party.currentBalance > 0
                        ? AppColors.success
                        : (widget.party.currentBalance < 0
                            ? AppColors.danger
                            : Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Amount Input Field
            AppTextField(
              controller: amountCtrl,
              label: isPaymentIn ? 'Amount Received (₹) *' : 'Amount Paid (₹) *',
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.currency_rupee, size: 16),
            ),
            const SizedBox(height: 12),

            // Notes Input Field
            AppTextField(
              controller: notesCtrl,
              label: 'Notes / Remarks',
              hintText: 'e.g. Cash settlement, UPI transaction reference',
            ),
            const SizedBox(height: 20),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppButton(
                  text: 'Cancel',
                  variant: AppButtonVariant.outline,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 8),
                Obx(
                  () => AppButton(
                    text: isPaymentIn ? 'Confirm Receipt' : 'Confirm Payment',
                    variant: isPaymentIn
                        ? AppButtonVariant.primary
                        : AppButtonVariant.destructive,
                    isLoading: controller.isSubmitting.value,
                    onPressed: _submit,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
