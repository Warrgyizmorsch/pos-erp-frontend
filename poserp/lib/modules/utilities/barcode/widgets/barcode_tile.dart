import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../models/barcode_config.dart';

class BarcodeTile extends StatelessWidget {
  final BarcodeRow item;
  final BarcodeDisplaySettings settings;
  final String businessName;

  const BarcodeTile({
    super.key,
    required this.item,
    required this.settings,
    required this.businessName,
  });

  @override
  Widget build(BuildContext context) {
    double tileWidth = 160;
    switch (settings.labelSize) {
      case '40x20':
        tileWidth = 135;
        break;
      case '38x25':
        tileWidth = 130;
        break;
      case '50x25':
      default:
        tileWidth = 160;
        break;
    }

    final code = item.barcode.isNotEmpty ? item.barcode : item.productCode;
    final barcodeString = code.isNotEmpty ? code : '8901234567890';

    return Container(
      width: tileWidth,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.md,
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Business Name Header
          if (settings.showHeader)
            Text(
              businessName.toUpperCase(),
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

          // Item Name
          if (settings.showItemName)
            Text(
              item.productName.isNotEmpty ? item.productName : 'Product Name',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

          // Extra Line (SKU)
          if (settings.showExtraLines && item.productCode.isNotEmpty)
            Text(
              'SKU: ${item.productCode}',
              style: TextStyle(fontSize: 8, color: Colors.grey[700]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 4),

          // Code128 Vector Barcode Lines
          Container(
            height: 32,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: List.generate(
                barcodeString.length * 2,
                (idx) => Container(
                  width: (idx % 3 == 0) ? 2.2 : 1.1,
                  color: (idx % 5 == 0) ? Colors.transparent : Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),

          // Barcode Number
          if (settings.showBarcodeNumber)
            Text(
              barcodeString,
              style: const TextStyle(
                fontSize: 9,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

          // Price / MRP
          if (settings.showPrice) ...[
            const SizedBox(height: 2),
            Text(
              'MRP: ₹${item.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
