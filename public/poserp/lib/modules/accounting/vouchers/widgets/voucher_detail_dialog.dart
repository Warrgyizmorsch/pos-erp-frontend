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
        constraints: const BoxConstraints(maxWidth: 750),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Toolbar
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            voucher.voucherNo.isNotEmpty
                                ? 'Voucher ${voucher.voucherNo}'
                                : 'Voucher Details',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Header and double-entry ledger lines for this voucher.',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusBadge(voucher.status),
                  ],
                ),
                const Divider(height: 20),

                // 2. Metadata Summary Card Grid (3 Columns)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.inputDark : Colors.grey[100],
                    borderRadius: AppRadius.md,
                    border: Border.all(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final cols = constraints.maxWidth < 550 ? 1 : 3;

                      return GridView.count(
                        crossAxisCount: cols,
                        childAspectRatio: cols == 1 ? 4.5 : 3.0,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 10,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildMetaItem('Date', voucher.date.split('T')[0]),
                          _buildMetaItem(
                            'Voucher Type',
                            '${voucher.voucherTypeName} (${voucher.voucherTypeCode})',
                          ),
                          _buildMetaItem('Status', voucher.status),
                          _buildMetaItem(
                            'Reference Module',
                            voucher.referenceModule ?? '-',
                          ),
                          _buildMetaItem(
                            'Reference No',
                            voucher.referenceNo ?? '-',
                          ),
                          _buildMetaItem(
                            'Posted At',
                            voucher.postedAt != null &&
                                    voucher.postedAt!.isNotEmpty
                                ? voucher.postedAt!.split('T')[0]
                                : '-',
                          ),
                          _buildMetaItem('Narration', voucher.narration ?? '-'),
                          if (voucher.cancelledAt != null &&
                              voucher.cancelledAt!.isNotEmpty)
                            _buildMetaItem(
                              'Cancelled At',
                              voucher.cancelledAt!.split('T')[0],
                            ),
                          if (voucher.reversalVoucherId != null &&
                              voucher.reversalVoucherId!.isNotEmpty)
                            _buildMetaItem(
                              'Reversal Voucher ID',
                              voucher.reversalVoucherId!,
                            ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // 3. 5-Column Journal Entries Table
                const Text(
                  'JOURNAL ENTRIES',
                  style: TextStyle(
                    fontSize: 11,
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
                                'GROUP',
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
                            Expanded(
                              flex: 2,
                              child: Text(
                                'NARRATION',
                                textAlign: TextAlign.center,
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
                                  e.groupName,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
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
                              Expanded(
                                flex: 2,
                                child: Text(
                                  e.narration ?? '-',
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
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

                // 4. Total Summary & Actions (Responsive LayoutBuilder)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobileFooter = constraints.maxWidth < 480;

                    final totalText = Text(
                      'Total Amount: ₹${voucher.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    );

                    final actionButtons = Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.end,
                      children: [
                        if (voucher.status == 'DRAFT' && onPost != null)
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
                        if (voucher.status == 'POSTED' && onCancel != null)
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
                        AppButton(
                          text: 'Close',
                          variant: AppButtonVariant.outline,
                          onPressed: () => Get.back(),
                        ),
                      ],
                    );

                    if (isMobileFooter) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          totalText,
                          const SizedBox(height: 12),
                          actionButtons,
                        ],
                      );
                    }

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        totalText,
                        Flexible(child: actionButtons),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetaItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
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
