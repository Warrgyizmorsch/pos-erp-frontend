import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../models/barcode_config.dart';

class BarcodeTile extends StatelessWidget {
  final BarcodeConfig cfg;

  const BarcodeTile({super.key, required this.cfg});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
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
          if (cfg.showBusinessName)
            Text(
              cfg.businessName,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          if (cfg.showProductName)
            Text(
              cfg.productName,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 4),

          // Simulated Barcode Lines
          Container(
            height: 36,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: List.generate(
                cfg.barcodeValue.length * 2,
                (idx) => Container(
                  width: (idx % 3 == 0) ? 2.5 : 1.2,
                  color: (idx % 5 == 0) ? Colors.transparent : Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),

          Text(
            cfg.barcodeValue,
            style: const TextStyle(
              fontSize: 9,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          if (cfg.showPrice) ...[
            const SizedBox(height: 2),
            Text(
              'MRP: ₹${cfg.price.toStringAsFixed(2)}',
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
