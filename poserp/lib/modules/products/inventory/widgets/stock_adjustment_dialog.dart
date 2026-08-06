import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../models/product.dart';
import '../controllers/stock_controller.dart';

class StockAdjustmentDialog extends StatefulWidget {
  final Product? initialProduct;

  const StockAdjustmentDialog({super.key, this.initialProduct});

  @override
  State<StockAdjustmentDialog> createState() => _StockAdjustmentDialogState();
}

class _StockAdjustmentDialogState extends State<StockAdjustmentDialog> {
  final StockController controller = Get.find<StockController>();

  Product? selectedProduct;
  final TextEditingController adjustedStockCtrl = TextEditingController();
  final TextEditingController notesCtrl = TextEditingController();
  String selectedReason = 'Physical Audit Miscount';

  final List<String> reasons = [
    'Physical Audit Miscount',
    'Damage / Expiry',
    'Theft / Loss',
    'Supplier Bonus / Gift',
    'Internal Usage / Testing',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    selectedProduct =
        widget.initialProduct ??
        (controller.products.isNotEmpty ? controller.products.first : null);
    if (selectedProduct != null) {
      adjustedStockCtrl.text = selectedProduct!.stock.toString();
    }
  }

  @override
  void dispose() {
    adjustedStockCtrl.dispose();
    notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentStock = selectedProduct?.stock ?? 0.0;
    final newStock = double.tryParse(adjustedStockCtrl.text) ?? currentStock;
    final diff = newStock - currentStock;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
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
                          Icons.swap_vert_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Record Stock Adjustment',
                        style: TextStyle(
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
              const SizedBox(height: 20),

              // Product Selector
              const Text(
                'PRODUCT *',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<Product>(
                initialValue: selectedProduct,
                isExpanded: true,
                dropdownColor: isDark
                    ? AppColors.cardDark
                    : AppColors.cardLight,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  filled: true,
                  fillColor: isDark ? AppColors.inputDark : Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.md,
                    borderSide: BorderSide(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                  ),
                ),
                items: controller.products.map((p) {
                  return DropdownMenuItem<Product>(
                    value: p,
                    child: Text(
                      '${p.name} (${p.sku}) — Stock: ${p.stock} ${p.unit}',
                      style: const TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (p) {
                  setState(() {
                    selectedProduct = p;
                    if (p != null) {
                      adjustedStockCtrl.text = p.stock.toString();
                    }
                  });
                },
              ),
              const SizedBox(height: 16),

              // Stock Comparison Grid
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.inputDark : Colors.grey[100],
                  borderRadius: AppRadius.md,
                  border: Border.all(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CURRENT STOCK',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$currentStock ${selectedProduct?.unit ?? 'pcs'}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: Colors.grey,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'ADJUSTED STOCK',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            height: 36,
                            width: 100,
                            child: TextField(
                              controller: adjustedStockCtrl,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderRadius: AppRadius.sm,
                                ),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'DIFFERENCE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            diff >= 0
                                ? '+$diff'
                                : '$diff ${selectedProduct?.unit ?? 'pcs'}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: diff > 0
                                  ? AppColors.success
                                  : (diff < 0 ? AppColors.danger : Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Reason Dropdown
              const Text(
                'REASON *',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: selectedReason,
                dropdownColor: isDark
                    ? AppColors.cardDark
                    : AppColors.cardLight,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  filled: true,
                  fillColor: isDark ? AppColors.inputDark : Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.md,
                    borderSide: BorderSide(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                  ),
                ),
                items: reasons.map((r) {
                  return DropdownMenuItem<String>(
                    value: r,
                    child: Text(r, style: const TextStyle(fontSize: 13)),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => selectedReason = v);
                },
              ),
              const SizedBox(height: 16),

              // Notes Text Area
              const Text(
                'NOTES / REMARKS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: notesCtrl,
                maxLines: 2,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Additional details about this stock change...',
                  contentPadding: const EdgeInsets.all(12),
                  filled: true,
                  fillColor: isDark ? AppColors.inputDark : Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.md,
                    borderSide: BorderSide(
                      color: isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Footer Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                    text: 'Cancel',
                    variant: AppButtonVariant.outline,
                    onPressed: () => Get.back(),
                  ),
                  const SizedBox(width: 12),
                  Obx(
                    () => AppButton(
                      text: 'Save Adjustment',
                      isLoading: controller.isSubmittingAdjustment.value,
                      onPressed: () async {
                        if (selectedProduct == null) return;
                        final success = await controller.createStockAdjustment(
                          productId: selectedProduct!.id,
                          adjustedStock: newStock,
                          reason: selectedReason,
                          notes: notesCtrl.text.trim(),
                        );
                        if (success) Get.back();
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
