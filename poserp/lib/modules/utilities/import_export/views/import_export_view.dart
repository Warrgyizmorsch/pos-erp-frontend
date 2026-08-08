import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../controllers/import_export_controller.dart';

class ImportExportView extends GetView<ImportExportController> {
  const ImportExportView({super.key});

  @override
  Widget build(BuildContext context) {
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
                          Icons.swap_vert_circle_outlined,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Import / Export Items Catalog',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Bulk import product inventory via Excel, Barcode Scan, or Global Product Library.',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Obx(
                    () => AppButton(
                      text: controller.isExporting.value
                          ? 'Exporting...'
                          : 'Export Catalog (Excel)',
                      icon: const Icon(Icons.file_download_outlined, size: 18),
                      variant: AppButtonVariant.outline,
                      onPressed: controller.isExporting.value
                          ? null
                          : () => controller.exportCatalog(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Selection Options Grid
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Method 1: Barcode Scan
                          Expanded(
                            child: Obx(() {
                              final isSelected =
                                  controller.selectedMethod.value == 'barcode';
                              return GestureDetector(
                                onTap: () =>
                                    controller.selectedMethod.value = 'barcode',
                                child: AppCard(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: AppColors.info.withAlpha(
                                                25,
                                              ),
                                              borderRadius: AppRadius.full,
                                            ),
                                            child: const Icon(
                                              Icons.qr_code_scanner_rounded,
                                              color: AppColors.info,
                                              size: 28,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.success
                                                  .withAlpha(20),
                                              borderRadius: AppRadius.full,
                                            ),
                                            child: const Text(
                                              'RECOMMENDED',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.success,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Import From Barcode',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      const Text(
                                        'Import item details by scanning EAN/UPC barcodes against standard verification database.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Icon(
                                            isSelected
                                                ? Icons.radio_button_checked
                                                : Icons.radio_button_off,
                                            color: isSelected
                                                ? AppColors.primary
                                                : Colors.grey,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'Select Barcode Import',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(width: 16),

                          // Method 2: Excel / CSV
                          Expanded(
                            child: Obx(() {
                              final isSelected =
                                  controller.selectedMethod.value == 'excel';
                              return GestureDetector(
                                onTap: () =>
                                    controller.selectedMethod.value = 'excel',
                                child: AppCard(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppColors.warning.withAlpha(
                                            25,
                                          ),
                                          borderRadius: AppRadius.full,
                                        ),
                                        child: const Icon(
                                          Icons.description_outlined,
                                          color: AppColors.warning,
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Import From Excel / CSV',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      const Text(
                                        'Upload spreadsheet containing Name, SKU, Barcode, Stock, and Sales Price columns.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Icon(
                                            isSelected
                                                ? Icons.radio_button_checked
                                                : Icons.radio_button_off,
                                            color: isSelected
                                                ? AppColors.primary
                                                : Colors.grey,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'Select Excel Import',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Method 3: Global Product Library
                      Obx(() {
                        final isSelected =
                            controller.selectedMethod.value == 'library';
                        return GestureDetector(
                          onTap: () =>
                              controller.selectedMethod.value = 'library',
                          child: AppCard(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withAlpha(25),
                                    borderRadius: AppRadius.full,
                                  ),
                                  child: const Icon(
                                    Icons.storage_rounded,
                                    color: AppColors.primary,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'Import From Global Product Library',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Pick pre-configured standard FMCG / grocery items directly into product catalog.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  isSelected
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_off,
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.grey,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 24),

                      // Action Button
                      Align(
                        alignment: Alignment.centerRight,
                        child: AppButton(
                          text: 'Continue with Selected Method',
                          icon: const Icon(
                            Icons.arrow_forward_rounded,
                            size: 18,
                          ),
                          onPressed: () => _handleContinue(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleContinue(BuildContext context) {
    final method = controller.selectedMethod.value;
    if (method == 'excel') {
      controller.parseSampleExcel();
      _showExcelPreviewDialog(context);
    } else if (method == 'barcode') {
      _showBarcodeDialog(context);
    } else if (method == 'library') {
      _showLibraryDialog(context);
    }
  }

  void _showExcelPreviewDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Parsed Excel Data Preview',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Review parsed spreadsheet rows before database import.',
                ),
                const SizedBox(height: 16),
                Obx(
                  () => Container(
                    constraints: const BoxConstraints(maxHeight: 250),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: AppRadius.md,
                    ),
                    child: SingleChildScrollView(
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('NAME')),
                          DataColumn(label: Text('SKU')),
                          DataColumn(label: Text('BARCODE')),
                          DataColumn(label: Text('PRICE')),
                        ],
                        rows: controller.parsedRows.map((r) {
                          return DataRow(
                            cells: [
                              DataCell(Text(r['Name'].toString())),
                              DataCell(Text(r['SKU'].toString())),
                              DataCell(Text(r['Barcode'].toString())),
                              DataCell(Text('₹${r['SalesPrice']}')),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppButton(
                      text: 'Cancel',
                      variant: AppButtonVariant.outline,
                      onPressed: () => Get.back(),
                    ),
                    const SizedBox(width: 8),
                    Obx(
                      () => AppButton(
                        text: controller.isImporting.value
                            ? 'Importing...'
                            : 'Import All Items',
                        onPressed: controller.isImporting.value
                            ? null
                            : () => controller.importParsedItems(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBarcodeDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Scan / Enter Barcode',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (val) =>
                            controller.scannedBarcode.value = val,
                        decoration: const InputDecoration(
                          hintText: 'Enter barcode (e.g. 8901234567001)',
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AppButton(
                      text: 'Search',
                      onPressed: () => controller.searchBarcode(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Obx(() {
                  final res = controller.scannedResult.value;
                  if (res == null) return const SizedBox.shrink();
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(15),
                      borderRadius: AppRadius.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          res['name'].toString(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Category: ${res['category']} · Price: ₹${res['price']}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppButton(
                      text: 'Cancel',
                      variant: AppButtonVariant.outline,
                      onPressed: () => Get.back(),
                    ),
                    const SizedBox(width: 8),
                    Obx(
                      () => AppButton(
                        text: 'Import Item',
                        onPressed: controller.scannedResult.value == null
                            ? null
                            : () => controller.importScannedBarcodeItem(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLibraryDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Global Product Library',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Obx(
                  () => Column(
                    children: controller.libraryItems.map((item) {
                      final String bc = item['barcode'].toString();
                      final bool isChecked = controller.selectedLibraryBarcodes
                          .contains(bc);
                      return CheckboxListTile(
                        title: Text(item['name'].toString()),
                        subtitle: Text(
                          'Category: ${item['category']} · ₹${item['price']}',
                        ),
                        value: isChecked,
                        onChanged: (val) {
                          if (val == true) {
                            controller.selectedLibraryBarcodes.add(bc);
                          } else {
                            controller.selectedLibraryBarcodes.remove(bc);
                          }
                        },
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppButton(
                      text: 'Cancel',
                      variant: AppButtonVariant.outline,
                      onPressed: () => Get.back(),
                    ),
                    const SizedBox(width: 8),
                    Obx(
                      () => AppButton(
                        text:
                            'Import (${controller.selectedLibraryBarcodes.length}) Selected',
                        onPressed: controller.selectedLibraryBarcodes.isEmpty
                            ? null
                            : () => controller.importSelectedLibraryItems(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
