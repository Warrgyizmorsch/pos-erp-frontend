import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../controllers/barcode_controller.dart';
import '../widgets/barcode_tile.dart';

class BarcodeView extends GetView<BarcodeController> {
  const BarcodeView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(25),
                          borderRadius: AppRadius.lg,
                        ),
                        child: const Icon(
                          Icons.qr_code_2_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Barcode Label Generator',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Design, customize, and print barcode stickers for thermal label printers.',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Obx(
                    () => AppButton(
                      text: controller.isPrinting.value
                          ? 'Printing...'
                          : 'Print Barcode Labels',
                      icon: const Icon(Icons.print_rounded, size: 18),
                      onPressed: controller.isPrinting.value
                          ? null
                          : () => controller.printLabels(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Main Responsive Split
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column (Settings Panel)
                    SizedBox(
                      width: 380,
                      child: SingleChildScrollView(
                        child: AppCard(
                          padding: const EdgeInsets.all(18),
                          child: Obx(() {
                            final cfg = controller.config.value;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Label Parameters',
                                  style: TextStyle(
                                    fontSize: 15,
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
                                  controller:
                                      TextEditingController(
                                          text: cfg.productName,
                                        )
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
                                const SizedBox(height: 14),

                                // Barcode String with Auto Generator Button
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
                                            TextEditingController(
                                                text: cfg.barcodeValue,
                                              )
                                              ..selection =
                                                  TextSelection.collapsed(
                                                    offset:
                                                        cfg.barcodeValue.length,
                                                  ),
                                        onChanged:
                                            controller.updateBarcodeValue,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontFamily: 'monospace',
                                        ),
                                        decoration: InputDecoration(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
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
                                      icon: const Icon(
                                        Icons.autorenew_rounded,
                                        size: 14,
                                      ),
                                      onPressed: () =>
                                          controller.generateRandomBarcode(),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),

                                // Price & Business Name
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                                  ..selection =
                                                      TextSelection.collapsed(
                                                        offset: cfg.price
                                                            .toString()
                                                            .length,
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
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
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
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                                  ..selection =
                                                      TextSelection.collapsed(
                                                        offset: cfg.copies
                                                            .toString()
                                                            .length,
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
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
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
                                const SizedBox(height: 14),

                                // Display Toggles
                                CheckboxListTile(
                                  title: const Text(
                                    'Show Business Name',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                  value: cfg.showBusinessName,
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  onChanged: (val) => controller
                                      .toggleShowBusinessName(val ?? true),
                                ),
                                CheckboxListTile(
                                  title: const Text(
                                    'Show Product Name',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                  value: cfg.showProductName,
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  onChanged: (val) => controller
                                      .toggleShowProductName(val ?? true),
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
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Right Column (Live Barcode Preview Sheet)
                    Expanded(
                      child: AppCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Thermal Print Preview Grid',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Obx(
                                  () => Text(
                                    '${controller.config.value.copies} sticker labels to print',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            Expanded(
                              child: Obx(() {
                                final cfg = controller.config.value;
                                return SingleChildScrollView(
                                  child: Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: List.generate(
                                      cfg.copies,
                                      (index) => BarcodeTile(cfg: cfg),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
