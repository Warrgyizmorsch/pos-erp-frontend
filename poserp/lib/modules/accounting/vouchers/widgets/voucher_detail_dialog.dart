import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';

import '../models/accounting_voucher.dart';

class VoucherDetailDialog extends StatelessWidget {
  final AccountingVoucher voucher;
  final Function(String id)? onPost;
  final Function(String id, String reason)? onCancel;

  const VoucherDetailDialog({
    super.key,
    required this.voucher,
    this.onPost,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 650),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(25),
                          borderRadius: AppRadius.md,
                        ),
                        child: const Icon(
                          Icons.description_outlined,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            voucher.voucherNo.isNotEmpty
                                ? voucher.voucherNo
                                : 'Voucher Detail',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Type: ${voucher.voucherTypeName} (${voucher.voucherTypeCode}) · Date: ${voucher.date.split('T')[0]}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  _buildStatusBadge(voucher.status),
                ],
              ),
              const Divider(height: 24),

              // Narration
              if (voucher.narration != null &&
                  voucher.narration!.isNotEmpty) ...[
                const Text(
                  'NARRATION',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(voucher.narration!, style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 16),
              ],

              // Entries Table
              const Text(
                'JOURNAL ENTRIES',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: AppRadius.md,
                  border: Border.all(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      color: isDark ? AppColors.inputDark : Colors.grey[100],
                      child: const Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              'LEDGER',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'DEBIT (₹)',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'CREDIT (₹)',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...voucher.entries.map((e) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    e.ledgerName,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (e.ledgerCode.isNotEmpty)
                                    Text(
                                      'Code: ${e.ledgerCode}',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontFamily: 'monospace',
                                        color: Colors.grey,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                e.debit > 0
                                    ? '₹${e.debit.toStringAsFixed(2)}'
                                    : '-',
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                e.credit > 0
                                    ? '₹${e.credit.toStringAsFixed(2)}'
                                    : '-',
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Total Summary & Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount: ₹${voucher.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                  Row(
                    children: [
                      if (voucher.status == 'DRAFT' && onPost != null) ...[
                        AppButton(
                          text: 'Post Voucher',
                          variant: AppButtonVariant.primary,
                          icon: const Icon(
                            Icons.check_circle_outline,
                            size: 16,
                          ),
                          onPressed: () {
                            Get.back();
                            onPost!(voucher.id);
                          },
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (voucher.status == 'POSTED' && onCancel != null) ...[
                        AppButton(
                          text: 'Cancel Voucher',
                          variant: AppButtonVariant.destructive,
                          icon: const Icon(Icons.cancel_outlined, size: 16),
                          onPressed: () {
                            Get.back();
                            onCancel!(
                              voucher.id,
                              'Cancelled via Voucher Detail',
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                      ],
                      AppButton(
                        text: 'Close',
                        variant: AppButtonVariant.outline,
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg = AppColors.success;
    String text = status;

    if (status == 'DRAFT') {
      bg = AppColors.warning;
    } else if (status == 'CANCELLED' || status == 'REVERSED') {
      bg = AppColors.danger;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg.withAlpha(25),
        borderRadius: AppRadius.full,
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: bg),
      ),
    );
  }
}
