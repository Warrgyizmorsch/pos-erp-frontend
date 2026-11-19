import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';

class ThermalReceiptGenerator {
  /// Generate ESC/POS byte array for a POS sale receipt.
  /// [paperSize] can be '80mm' or '58mm'.
  static Future<List<int>> generateReceipt(
    Map<String, dynamic> saleData, {
    String paperSize = '80mm',
    String businessName = 'POS ERP RETAIL',
    String? businessAddress,
    String? businessPhone,
    String? businessGstin,
  }) async {
    final profile = await CapabilityProfile.load();
    final pSize = paperSize == '58mm' ? PaperSize.mm58 : PaperSize.mm80;
    final generator = Generator(pSize, profile);
    List<int> bytes = [];

    final is80mm = pSize == PaperSize.mm80;

    // Reset printer
    bytes += generator.reset();

    // 1. Store Header
    bytes += generator.text(
      businessName.toUpperCase(),
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
      linesAfter: 1,
    );

    if (businessAddress != null && businessAddress.trim().isNotEmpty) {
      bytes += generator.text(
        businessAddress.trim(),
        styles: const PosStyles(align: PosAlign.center),
      );
    }
    if (businessPhone != null && businessPhone.trim().isNotEmpty) {
      bytes += generator.text(
        'Phone: ${businessPhone.trim()}',
        styles: const PosStyles(align: PosAlign.center),
      );
    }
    if (businessGstin != null && businessGstin.trim().isNotEmpty) {
      bytes += generator.text(
        'GSTIN: ${businessGstin.trim()}',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      );
    }

    bytes += generator.text(
      'Tax Invoice / Cash Memo',
      styles: const PosStyles(align: PosAlign.center, bold: true),
      linesAfter: 1,
    );

    bytes += generator.hr();

    // 2. Invoice Meta Details
    final invoiceNo = saleData['invoiceNumber'] ??
        saleData['billNo'] ??
        saleData['id'] ??
        'INV-${DateTime.now().millisecondsSinceEpoch % 100000}';
    final customerName =
        saleData['customerName']?.toString().trim() ?? 'Walk-in Customer';
    final customerPhone = saleData['customerPhone']?.toString().trim();
    final rawDate = saleData['createdAt']?.toString() ??
        saleData['date']?.toString() ??
        DateTime.now().toIso8601String();
    final dateStr = rawDate.contains('T')
        ? rawDate.split('T')[0]
        : rawDate.split(' ')[0];
    final timeStr = rawDate.contains('T') && rawDate.split('T').length > 1
        ? rawDate.split('T')[1].split('.')[0]
        : '';

    if (is80mm) {
      bytes += generator.row([
        PosColumn(
          text: 'Inv: $invoiceNo',
          width: 6,
          styles: const PosStyles(bold: true),
        ),
        PosColumn(
          text: 'Date: $dateStr ${timeStr.isNotEmpty ? timeStr : ''}'.trim(),
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    } else {
      bytes += generator.text('Inv: $invoiceNo',
          styles: const PosStyles(bold: true));
      bytes += generator.text(
          'Date: $dateStr ${timeStr.isNotEmpty ? timeStr : ''}'.trim());
    }

    bytes += generator.text('Customer: $customerName');
    if (customerPhone != null && customerPhone.isNotEmpty) {
      bytes += generator.text('Phone: $customerPhone');
    }

    bytes += generator.hr();

    // 3. Item Table Header
    if (is80mm) {
      bytes += generator.row([
        PosColumn(
          text: 'ITEM',
          width: 6,
          styles: const PosStyles(bold: true),
        ),
        PosColumn(
          text: 'QTY',
          width: 2,
          styles: const PosStyles(bold: true, align: PosAlign.center),
        ),
        PosColumn(
          text: 'RATE',
          width: 2,
          styles: const PosStyles(bold: true, align: PosAlign.right),
        ),
        PosColumn(
          text: 'TOTAL',
          width: 2,
          styles: const PosStyles(bold: true, align: PosAlign.right),
        ),
      ]);
    } else {
      // 58mm compact layout
      bytes += generator.row([
        PosColumn(
          text: 'ITEM',
          width: 6,
          styles: const PosStyles(bold: true),
        ),
        PosColumn(
          text: 'QTY',
          width: 2,
          styles: const PosStyles(bold: true, align: PosAlign.center),
        ),
        PosColumn(
          text: 'TOTAL',
          width: 4,
          styles: const PosStyles(bold: true, align: PosAlign.right),
        ),
      ]);
    }

    bytes += generator.hr(ch: '-');

    // 4. Items List
    final items = (saleData['items'] as List?) ?? [];
    for (final itm in items) {
      final name = itm['name'] ??
          itm['itemName'] ??
          itm['productName'] ??
          'Item';
      final qty = (itm['quantity'] ?? itm['qty'] as num?)?.toDouble() ?? 1.0;
      final rate = (itm['rate'] ?? itm['unitPrice'] as num?)?.toDouble() ?? 0.0;
      final total = (itm['total'] ?? itm['totalAmount'] as num?)?.toDouble() ??
          (qty * rate);

      final qtyStr = qty % 1 == 0 ? qty.toInt().toString() : qty.toStringAsFixed(1);
      final rateStr = rate.toStringAsFixed(2);
      final totalStr = total.toStringAsFixed(2);

      if (is80mm) {
        bytes += generator.row([
          PosColumn(text: name.toString(), width: 6),
          PosColumn(
            text: qtyStr,
            width: 2,
            styles: const PosStyles(align: PosAlign.center),
          ),
          PosColumn(
            text: rateStr,
            width: 2,
            styles: const PosStyles(align: PosAlign.right),
          ),
          PosColumn(
            text: totalStr,
            width: 2,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]);
      } else {
        bytes += generator.row([
          PosColumn(text: name.toString(), width: 6),
          PosColumn(
            text: qtyStr,
            width: 2,
            styles: const PosStyles(align: PosAlign.center),
          ),
          PosColumn(
            text: totalStr,
            width: 4,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]);
      }
    }

    bytes += generator.hr(ch: '-');

    // 5. Calculations / Totals
    final totalAmt =
        (saleData['totalAmount'] ?? saleData['grandTotal'] as num?)?.toDouble() ??
            0.0;
    final subtotal = (saleData['subtotal'] as num?)?.toDouble() ?? totalAmt;
    final taxAmount = (saleData['taxAmount'] as num?)?.toDouble() ?? 0.0;
    final discountAmount =
        (saleData['discountAmount'] as num?)?.toDouble() ?? 0.0;
    final amountPaid =
        (saleData['amountPaid'] as num?)?.toDouble() ?? totalAmt;
    final changeDue = (saleData['changeDue'] as num?)?.toDouble() ?? 0.0;
    final paymentMethod =
        (saleData['paymentMethod'] ?? 'CASH').toString().toUpperCase();

    // Subtotal
    bytes += generator.row([
      PosColumn(text: 'Subtotal:', width: is80mm ? 8 : 6),
      PosColumn(
        text: 'Rs. ${subtotal.toStringAsFixed(2)}',
        width: is80mm ? 4 : 6,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    // Discount if any
    if (discountAmount > 0) {
      bytes += generator.row([
        PosColumn(text: 'Discount:', width: is80mm ? 8 : 6),
        PosColumn(
          text: '-Rs. ${discountAmount.toStringAsFixed(2)}',
          width: is80mm ? 4 : 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    // Tax if any
    if (taxAmount > 0) {
      bytes += generator.row([
        PosColumn(text: 'Total Tax (GST):', width: is80mm ? 8 : 6),
        PosColumn(
          text: 'Rs. ${taxAmount.toStringAsFixed(2)}',
          width: is80mm ? 4 : 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    bytes += generator.hr(ch: '=');

    // GRAND TOTAL
    bytes += generator.row([
      PosColumn(
        text: 'GRAND TOTAL:',
        width: is80mm ? 6 : 6,
        styles: const PosStyles(
          bold: true,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ),
      ),
      PosColumn(
        text: 'Rs. ${totalAmt.toStringAsFixed(2)}',
        width: is80mm ? 6 : 6,
        styles: const PosStyles(
          bold: true,
          align: PosAlign.right,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ),
      ),
    ]);

    bytes += generator.hr(ch: '=');

    // 6. Payment Information
    bytes += generator.row([
      PosColumn(text: 'Payment Method:', width: is80mm ? 7 : 6),
      PosColumn(
        text: paymentMethod,
        width: is80mm ? 5 : 6,
        styles: const PosStyles(align: PosAlign.right, bold: true),
      ),
    ]);

    bytes += generator.row([
      PosColumn(text: 'Amount Paid:', width: is80mm ? 7 : 6),
      PosColumn(
        text: 'Rs. ${amountPaid.toStringAsFixed(2)}',
        width: is80mm ? 5 : 6,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    if (changeDue > 0) {
      bytes += generator.row([
        PosColumn(text: 'Change Returned:', width: is80mm ? 7 : 6),
        PosColumn(
          text: 'Rs. ${changeDue.toStringAsFixed(2)}',
          width: is80mm ? 5 : 6,
          styles: const PosStyles(align: PosAlign.right, bold: true),
        ),
      ]);
    }

    // 7. QR Code / E-Invoice IRN (if available)
    final qrCode = saleData['qrCode']?.toString();
    if (qrCode != null && qrCode.trim().isNotEmpty) {
      bytes += generator.feed(1);
      bytes += generator.qrcode(
        qrCode.trim(),
        align: PosAlign.center,
        size: QRSize.size4,
      );
    }

    final irn = saleData['irn']?.toString();
    if (irn != null && irn.trim().isNotEmpty) {
      bytes += generator.feed(1);
      bytes += generator.text(
        'IRN: ${irn.trim()}',
        styles: const PosStyles(align: PosAlign.center),
      );
    }

    // 8. Footer
    bytes += generator.hr();
    bytes += generator.text(
      'Thank you for shopping with us!',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.text(
      'Goods once sold cannot be returned.',
      styles: const PosStyles(align: PosAlign.center),
      linesAfter: 1,
    );

    // 9. Feed & Cut
    bytes += generator.feed(2);
    bytes += generator.cut();

    return bytes;
  }

  /// Generate a quick test receipt to verify Bluetooth printer connection.
  static Future<List<int>> generateTestReceipt({
    String paperSize = '80mm',
    String printerName = 'Posiflow Thermal Printer',
    String? macAddress,
  }) async {
    final profile = await CapabilityProfile.load();
    final pSize = paperSize == '58mm' ? PaperSize.mm58 : PaperSize.mm80;
    final generator = Generator(pSize, profile);
    List<int> bytes = [];

    bytes += generator.reset();

    // Header
    bytes += generator.text(
      'POS ERP / POSIFLOW',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
      linesAfter: 1,
    );

    bytes += generator.text(
      '*** BLUETOOTH TEST PRINT ***',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );

    bytes += generator.hr();

    bytes += generator.text('Device: $printerName');
    if (macAddress != null && macAddress.isNotEmpty) {
      bytes += generator.text('MAC: $macAddress');
    }
    bytes += generator.text('Paper Width: $paperSize');
    bytes += generator.text('Timestamp: ${DateTime.now().toString().split('.')[0]}');
    bytes += generator.text('Status: SUCCESS / CONNECTED');

    bytes += generator.hr();

    bytes += generator.text(
      'Your terminal printer is connected and ready to print POS receipts.',
      styles: const PosStyles(align: PosAlign.center),
      linesAfter: 1,
    );

    bytes += generator.feed(2);
    bytes += generator.cut();

    return bytes;
  }
}
