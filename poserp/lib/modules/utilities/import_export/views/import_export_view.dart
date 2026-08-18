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
              // 1. Header Navigation & Actions (Responsive Wrap Layout)
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                runSpacing: 12,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Row(
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
                        Expanded(
                          child: Column(
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
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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

              // 2. Selection Options Grid (Responsive LayoutBuilder)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth > 650;

                          final card1 = Obx(() {
                            final isSelected =
                                controller.selectedMethod.value == 'barcode';
                            return GestureDetector(
                              onTap: () =>
                                  controller.selectedMethod.value = 'barcode',
                              child: AppCard(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Wrap(
                                      alignment: WrapAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: AppColors.info.withAlpha(25),
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
                                            color: AppColors.success.withAlpha(
                                              20,
                                            ),
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
                                        const Expanded(
                                          child: Text(
                                            'Select Barcode Import',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          });

                          final card2 = Obx(() {
                            final isSelected =
                                controller.selectedMethod.value == 'excel';
                            return GestureDetector(
                              onTap: () =>
                                  controller.selectedMethod.value = 'excel',
                              child: AppCard(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.warning.withAlpha(25),
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
                                        const Expanded(
                                          child: Text(
                                            'Select Excel Import',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          });

                          if (isWide) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: card1),
                                const SizedBox(width: 16),
                                Expanded(child: card2),
                              ],
                            );
                          }

                          return Column(
                            children: [
                              card1,
                              const SizedBox(height: 16),
                              card2,
                            ],
                          );
                        },
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
                                const SizedBox(width: 12),
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

                      // Action View Panel for Selected Import Method
                      Obx(() {
                        switch (controller.selectedMethod.value) {
                          case 'barcode':
                            return _buildBarcodeSection(context);
                          case 'excel':
                            return _buildExcelSection(context);
                          case 'library':
                            return _buildLibrarySection(context);
                          default:
                            return const SizedBox.shrink();
                        }
                      }),
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

  Widget _buildBarcodeSection(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Barcode Scan Mode',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Scan or enter product barcodes to auto-populate master fields.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 220, maxWidth: 450),
                child: TextField(
                  controller: controller.barcodeController,
                  decoration: const InputDecoration(
                    hintText: 'Enter or scan EAN/UPC barcode...',
                    prefixIcon: Icon(Icons.qr_code_scanner),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onSubmitted: (_) => controller.lookupBarcode(),
                ),
              ),
              Obx(
                () => AppButton(
                  text: controller.isSearchingBarcode.value
                      ? 'Looking up...'
                      : 'Lookup Barcode',
                  icon: const Icon(Icons.search, size: 16),
                  onPressed: controller.isSearchingBarcode.value
                      ? null
                      : () => controller.lookupBarcode(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExcelSection(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upload Excel / CSV File',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Select a spreadsheet file (.xlsx, .csv) formatted with product inventory headers.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Obx(
            () => Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 200,
                    maxWidth: 350,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.withAlpha(60)),
                      borderRadius: AppRadius.md,
                    ),
                    child: Text(
                      controller.selectedFileName.value.isEmpty
                          ? 'No file selected'
                          : controller.selectedFileName.value,
                      style: TextStyle(
                        fontSize: 13,
                        color: controller.selectedFileName.value.isEmpty
                            ? Colors.grey
                            : AppColors.primary,
                        fontWeight: controller.selectedFileName.value.isEmpty
                            ? FontWeight.normal
                            : FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    AppButton(
                      text: 'Browse File',
                      icon: const Icon(Icons.folder_open_rounded, size: 16),
                      variant: AppButtonVariant.outline,
                      onPressed: () => controller.pickExcelFile(),
                    ),
                    AppButton(
                      text: controller.isImportingExcel.value
                          ? 'Importing...'
                          : 'Import Spreadsheet',
                      icon: const Icon(Icons.upload_file_rounded, size: 16),
                      onPressed:
                          (controller.selectedFileName.value.isEmpty ||
                              controller.isImportingExcel.value)
                          ? null
                          : () => controller.importExcel(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLibrarySection(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Global Product Library Search',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Search standard catalog database to add pre-configured products.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 220, maxWidth: 450),
                child: TextField(
                  controller: controller.libraryQueryController,
                  decoration: const InputDecoration(
                    hintText: 'Search brand, item name, or category...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onSubmitted: (_) => controller.searchLibrary(),
                ),
              ),
              Obx(
                () => AppButton(
                  text: controller.isSearchingLibrary.value
                      ? 'Searching...'
                      : 'Search Library',
                  icon: const Icon(Icons.manage_search_rounded, size: 16),
                  onPressed: controller.isSearchingLibrary.value
                      ? null
                      : () => controller.searchLibrary(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
