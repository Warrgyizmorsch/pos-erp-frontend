import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_top_bar.dart';
import '../controllers/barcode_controller.dart';
import '../widgets/barcode_tile.dart';

class BarcodeView extends GetView<BarcodeController> {
  const BarcodeView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppTopBar(
        title: 'Barcode Label Generator',
        subtitle: 'Customize & print thermal barcode stickers',
        actions: [
          Obx(
            () => IconButton(
              icon: const Icon(Icons.print_rounded, size: 24),
              tooltip: 'Print Barcode Labels',
              onPressed: controller.isPrinting.value
                  ? null
                  : () => controller.printLabels(),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 800;

            final settingsPanel = AppCard(
              padding: const EdgeInsets.all(16),
              child: Obx(() {
                final cfg = controller.config.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Label Parameters',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 20),

                    // Product Name
                    const Text(
                      'Product Name',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: TextEditingController(text: cfg.productName)
                        ..selection = TextSelection.collapsed(
                          offset: cfg.productName.length,
                        ),
                      onChanged: controller.updateProductName,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
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
                    ),
                    const SizedBox(height: 12),

                    // Barcode Value
                    const Text(
                      'Barcode Value',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller:
                                TextEditingController(text: cfg.barcodeValue)
                                  ..selection = TextSelection.collapsed(
                                    offset: cfg.barcodeValue.length,
                                  ),
                            onChanged: controller.updateBarcodeValue,
                            style: const TextStyle(
                              fontSize: 13,
                              fontFamily: 'monospace',
                            ),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
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
                          ),
                        ),
                        const SizedBox(width: 8),
                        AppButton(
                          text: 'Generate',
                          variant: AppButtonVariant.outline,
                          icon: const Icon(Icons.autorenew_rounded, size: 14),
                          height: 38,
                          onPressed: () => controller.generateRandomBarcode(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Price & Quantity
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Sales Price (₹)',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              TextField(
                                controller:
                                    TextEditingController(
                                        text: cfg.price.toString(),
                                      )
                                      ..selection = TextSelection.collapsed(
                                        offset: cfg.price.toString().length,
                                      ),
                                keyboardType: TextInputType.number,
                                onChanged: (val) {
                                  final d = double.tryParse(val);
                                  if (d != null) {
                                    controller.updatePrice(d);
                                  }
                                },
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'monospace',
                                ),
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
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
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Copies Quantity',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              TextField(
                                controller:
                                    TextEditingController(
                                        text: cfg.copies.toString(),
                                      )
                                      ..selection = TextSelection.collapsed(
                                        offset: cfg.copies.toString().length,
                                      ),
                                keyboardType: TextInputType.number,
                                onChanged: (val) {
                                  final i = int.tryParse(val);
                                  if (i != null) {
                                    controller.updateCopies(i);
                                  }
                                },
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'monospace',
                                ),
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
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
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Display Checkboxes
                    CheckboxListTile(
                      title: const Text(
                        'Show Business Name',
                        style: TextStyle(fontSize: 13),
                      ),
                      value: cfg.showBusinessName,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) =>
                          controller.toggleShowBusinessName(val ?? true),
                    ),
                    CheckboxListTile(
                      title: const Text(
                        'Show Product Name',
                        style: TextStyle(fontSize: 13),
                      ),
                      value: cfg.showProductName,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) =>
                          controller.toggleShowProductName(val ?? true),
                    ),
                    CheckboxListTile(
                      title: const Text(
                        'Show Price (MRP)',
                        style: TextStyle(fontSize: 13),
                      ),
                      value: cfg.showPrice,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) =>
                          controller.toggleShowPrice(val ?? true),
                    ),
                  ],
                );
              }),
            );

            final previewPanel = AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Print Preview Grid',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Obx(
                        () => Text(
                          '${controller.config.value.copies} labels to print',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Obx(() {
                    final cfg = controller.config.value;
                    return Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: List.generate(
                        cfg.copies,
                        (index) => BarcodeTile(cfg: cfg),
                      ),
                    );
                  }),
                ],
              ),
            );

            if (isMobile) {
              return Column(
                children: [
                  settingsPanel,
                  const SizedBox(height: 16),
                  previewPanel,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 360, child: settingsPanel),
                const SizedBox(width: 16),
                Expanded(child: previewPanel),
              ],
            );
          },
        ),
      ),
    );
  }
}
