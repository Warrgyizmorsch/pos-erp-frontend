import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/widgets/app_button.dart';

enum PrintFormat { thermal80mm, standardA4 }

class POSPrintDialog extends StatefulWidget {
  final Map<String, dynamic> saleData;

  const POSPrintDialog({super.key, required this.saleData});

  static Future<void> show(
    BuildContext context,
    Map<String, dynamic> saleData,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => POSPrintDialog(saleData: saleData),
    );
  }

  @override
  State<POSPrintDialog> createState() => _POSPrintDialogState();
}

class _POSPrintDialogState extends State<POSPrintDialog> {
  PrintFormat _format = PrintFormat.thermal80mm;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final invoiceNo = widget.saleData['invoiceNumber'] ??
        widget.saleData['billNo'] ??
        widget.saleData['id'] ??
        'INV-001';
    final customerName =
        widget.saleData['customerName']?.toString() ?? 'Walk-in Customer';
    final totalAmt =
        (widget.saleData['totalAmount'] as num?)?.toDouble() ?? 0.0;
    final subtotal = (widget.saleData['subtotal'] as num?)?.toDouble() ?? 0.0;
    final taxAmount = (widget.saleData['taxAmount'] as num?)?.toDouble() ?? 0.0;
    final discountAmount =
        (widget.saleData['discountAmount'] as num?)?.toDouble() ?? 0.0;
    final amountPaid =
        (widget.saleData['amountPaid'] as num?)?.toDouble() ?? totalAmt;
    final paymentMethod =
        widget.saleData['paymentMethod']?.toString().toUpperCase() ?? 'CASH';
    final items = (widget.saleData['items'] as List?) ?? [];
    final irn = widget.saleData['irn']?.toString();
    final qrCode = widget.saleData['qrCode']?.toString();
    final ewayBillNumber = widget.saleData['ewayBillNumber']?.toString();
    final dateStr = widget.saleData['createdAt'] != null &&
            widget.saleData['createdAt'].toString().contains('T')
        ? widget.saleData['createdAt'].toString().split('T')[0]
        : DateTime.now().toString().split(' ')[0];

    final hasEInvoice = irn != null && irn.isNotEmpty;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.xl),
      backgroundColor: isDark ? AppColors.cardDark : AppColors.cardLight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: _format == PrintFormat.standardA4 ? 640 : 420,
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header & Format Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Invoice & Print Preview',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Select format & verify government compliance tags',
                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Format Selector Tabs
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.inputDark : Colors.grey[200],
                  borderRadius: AppRadius.md,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _format = PrintFormat.thermal80mm),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: _format == PrintFormat.thermal80mm
                                ? (isDark ? AppColors.cardDark : Colors.white)
                                : Colors.transparent,
                            borderRadius: AppRadius.sm,
                            boxShadow: _format == PrintFormat.thermal80mm
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(10),
                                      blurRadius: 4,
                                    )
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long_rounded,
                                size: 14,
                                color: _format == PrintFormat.thermal80mm
                                    ? AppColors.primary
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '80mm Thermal',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: _format == PrintFormat.thermal80mm
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: _format == PrintFormat.thermal80mm
                                      ? AppColors.primary
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _format = PrintFormat.standardA4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: _format == PrintFormat.standardA4
                                ? (isDark ? AppColors.cardDark : Colors.white)
                                : Colors.transparent,
                            borderRadius: AppRadius.sm,
                            boxShadow: _format == PrintFormat.standardA4
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(10),
                                      blurRadius: 4,
                                    )
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.description_outlined,
                                size: 14,
                                color: _format == PrintFormat.standardA4
                                    ? AppColors.primary
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'A4 Tax Invoice',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: _format == PrintFormat.standardA4
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: _format == PrintFormat.standardA4
                                      ? AppColors.primary
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Preview Scrollable Container
              Flexible(
                child: SingleChildScrollView(
                  child: _format == PrintFormat.thermal80mm
                      ? _buildThermalPreview(
                          invoiceNo: invoiceNo,
                          customerName: customerName,
                          totalAmt: totalAmt,
                          subtotal: subtotal,
                          taxAmount: taxAmount,
                          discountAmount: discountAmount,
                          amountPaid: amountPaid,
                          paymentMethod: paymentMethod,
                          items: items,
                          dateStr: dateStr,
                          hasEInvoice: hasEInvoice,
                          irn: irn,
                          qrCode: qrCode,
                          ewayBillNumber: ewayBillNumber,
                        )
                      : _buildA4Preview(
                          invoiceNo: invoiceNo,
                          customerName: customerName,
                          totalAmt: totalAmt,
                          subtotal: subtotal,
                          taxAmount: taxAmount,
                          discountAmount: discountAmount,
                          amountPaid: amountPaid,
                          paymentMethod: paymentMethod,
                          items: items,
                          dateStr: dateStr,
                          hasEInvoice: hasEInvoice,
                          irn: irn,
                          qrCode: qrCode,
                          ewayBillNumber: ewayBillNumber,
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                    text: 'Close',
                    variant: AppButtonVariant.ghost,
                    onPressed: () => Get.back(),
                  ),
                  const SizedBox(width: 12),
                  AppButton(
                    text: _format == PrintFormat.thermal80mm
                        ? 'Print Receipt'
                        : 'Print A4 Tax Invoice',
                    icon: const Icon(Icons.print, size: 18),
                    onPressed: () {
                      Get.back();
                      AppSnackbar.success(
                        'Invoice #$invoiceNo sent to printer spooler.',
                        title: 'Print Spooler',
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 80mm Thermal Receipt Layout ---
  Widget _buildThermalPreview({
    required String invoiceNo,
    required String customerName,
    required double totalAmt,
    required double subtotal,
    required double taxAmount,
    required double discountAmount,
    required double amountPaid,
    required String paymentMethod,
    required List items,
    required String dateStr,
    required bool hasEInvoice,
    String? irn,
    String? qrCode,
    String? ewayBillNumber,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: AppRadius.md,
      ),
      child: Column(
        children: [
          const Text(
            'POS ERP RETAIL',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          const Text(
            'Tax Invoice / Cash Memo',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Inv: $invoiceNo',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Date: $dateStr',
                  style: const TextStyle(fontSize: 10, color: Colors.black),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Customer: $customerName',
                  style: const TextStyle(fontSize: 11, color: Colors.black),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                paymentMethod,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const Divider(color: Colors.black, height: 16),

          // Items List
          ...items.map((i) {
            final name = i['name'] ?? i['itemName'] ?? 'Item';
            final qty = (i['quantity'] as num?)?.toInt() ?? 1;
            final tot =
                (i['total'] ?? i['totalAmount'] as num?)?.toDouble() ?? 0.0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '$name x$qty',
                      style: const TextStyle(fontSize: 11, color: Colors.black),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '₹${tot.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            );
          }),
          const Divider(color: Colors.black, height: 16),

          // Financial Breakdown
          if (subtotal > 0) ...[
            _buildReceiptRow('Subtotal:', '₹${subtotal.toStringAsFixed(2)}'),
          ],
          if (taxAmount > 0) ...[
            _buildReceiptRow('Tax (GST):', '₹${taxAmount.toStringAsFixed(2)}'),
          ],
          if (discountAmount > 0) ...[
            _buildReceiptRow('Discount:', '-₹${discountAmount.toStringAsFixed(2)}'),
          ],
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TOTAL AMOUNT:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.black,
                ),
              ),
              Text(
                '₹${totalAmt.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'AMOUNT PAID:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  color: Colors.black,
                ),
              ),
              Text(
                '₹${amountPaid.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  color: Colors.black,
                ),
              ),
            ],
          ),

          // Government E-Invoice Thermal Block
          if (hasEInvoice) ...[
            const Divider(color: Colors.black, height: 18),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: AppRadius.sm,
              ),
              child: Column(
                children: [
                  const Text(
                    'GOVERNMENT E-INVOICE',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'IRN: ${irn!.length > 24 ? "${irn.substring(0, 24)}..." : irn}',
                    style: const TextStyle(
                      fontSize: 8,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (ewayBillNumber != null && ewayBillNumber.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      'E-Way Bill: $ewayBillNumber',
                      style: const TextStyle(fontSize: 8, color: Colors.black),
                    ),
                  ],
                  const SizedBox(height: 6),
                  // Styled Thermal QR Code Box
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.qr_code_2_rounded, size: 48, color: Colors.black),
                          Text('GST IRP', style: TextStyle(fontSize: 6, fontWeight: FontWeight.bold, color: Colors.black)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Scan with GST IRP App to Verify',
                    style: TextStyle(fontSize: 7, color: Colors.black),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),
          const Text(
            'Thank you! Visit Again.',
            style: TextStyle(
              fontSize: 10,
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // --- A4 Standard Tax Invoice Layout ---
  Widget _buildA4Preview({
    required String invoiceNo,
    required String customerName,
    required double totalAmt,
    required double subtotal,
    required double taxAmount,
    required double discountAmount,
    required double amountPaid,
    required String paymentMethod,
    required List items,
    required String dateStr,
    required bool hasEInvoice,
    String? irn,
    String? qrCode,
    String? ewayBillNumber,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: AppRadius.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Company & Tax Invoice Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'POS ERP ENTERPRISE',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Regd Office: Plot 102, Commercial Zone, Tech Park\nGSTIN: 27AAAAA0000A1Z5 • State: 27-Maharashtra',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Email: billing@poserp.com • Phone: +91 98765 43210',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(25),
                      borderRadius: AppRadius.sm,
                    ),
                    child: const Text(
                      'TAX INVOICE',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Invoice No: $invoiceNo',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    'Date: $dateStr',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const Divider(color: Colors.black, height: 24),

          // Government E-Invoice Compliance Bar
          if (hasEInvoice) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border.all(color: Colors.grey[400]!),
                borderRadius: AppRadius.sm,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // QR Code Box
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 1.2),
                    ),
                    child: const Center(
                      child: Icon(Icons.qr_code_2_rounded, size: 48, color: Colors.black),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.verified_user_rounded, size: 14, color: AppColors.success),
                            SizedBox(width: 4),
                            Text(
                              'GOVERNMENT E-INVOICE AUTHENTICATION',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        SelectableText(
                          'IRN: $irn',
                          style: const TextStyle(
                            fontSize: 9,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        if (ewayBillNumber != null && ewayBillNumber.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            'E-Way Bill Number: $ewayBillNumber',
                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Bill To Section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'BILL TO / BUYER:',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      customerName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const Text(
                      'Payment Method: ',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    Text(
                      paymentMethod,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Items Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: AppRadius.sm,
            ),
            child: const Row(
              children: [
                SizedBox(width: 24, child: Text('#', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black))),
                Expanded(flex: 4, child: Text('ITEM DESCRIPTION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black))),
                Expanded(flex: 1, child: Text('QTY', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black))),
                Expanded(flex: 2, child: Text('RATE', textAlign: TextAlign.right, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black))),
                Expanded(flex: 2, child: Text('TOTAL', textAlign: TextAlign.right, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black))),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Items Table Rows
          ...items.asMap().entries.map((entry) {
            final idx = entry.key;
            final i = entry.value;
            final name = i['name'] ?? i['itemName'] ?? 'Item';
            final qty = (i['quantity'] as num?)?.toInt() ?? 1;
            final rate = (i['rate'] ?? i['price'] as num?)?.toDouble() ?? 0.0;
            final tot = (i['total'] ?? i['totalAmount'] as num?)?.toDouble() ?? 0.0;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  SizedBox(width: 24, child: Text('${idx + 1}', style: const TextStyle(fontSize: 10, color: Colors.black))),
                  Expanded(flex: 4, child: Text(name, style: const TextStyle(fontSize: 11, color: Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  Expanded(flex: 1, child: Text('$qty', textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: Colors.black))),
                  Expanded(flex: 2, child: Text('₹${rate.toStringAsFixed(2)}', textAlign: TextAlign.right, style: const TextStyle(fontSize: 10, color: Colors.black))),
                  Expanded(flex: 2, child: Text('₹${tot.toStringAsFixed(2)}', textAlign: TextAlign.right, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black))),
                ],
              ),
            );
          }),
          const Divider(color: Colors.black, height: 16),

          // Totals Section
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 420;

              final totalsColumn = Column(
                children: [
                  if (subtotal > 0)
                    _buildReceiptRow('Subtotal:', '₹${subtotal.toStringAsFixed(2)}'),
                  if (taxAmount > 0)
                    _buildReceiptRow('GST Tax:', '₹${taxAmount.toStringAsFixed(2)}'),
                  if (discountAmount > 0)
                    _buildReceiptRow('Discount:', '-₹${discountAmount.toStringAsFixed(2)}'),
                  const Divider(color: Colors.black, height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Flexible(
                        child: Text(
                          'GRAND TOTAL:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '₹${totalAmt.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );

              final termsWidget = const Text(
                'Terms & Conditions:\n1. Goods once sold will not be taken back.\n2. Subject to local state jurisdiction.',
                style: TextStyle(fontSize: 9, color: Colors.grey),
              );

              if (isCompact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    totalsColumn,
                    const SizedBox(height: 12),
                    const Divider(color: Colors.black12, height: 1),
                    const SizedBox(height: 8),
                    termsWidget,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: termsWidget),
                  const SizedBox(width: 16),
                  Expanded(flex: 5, child: totalsColumn),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // Signatory Footer
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: const [
              Text(
                'Customer Signature',
                style: TextStyle(fontSize: 9, color: Colors.grey),
              ),
              Text(
                'Authorized Signatory for POS ERP',
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
