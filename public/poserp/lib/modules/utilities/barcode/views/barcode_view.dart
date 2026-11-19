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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Obx(() {
            final settings = controller.displaySettings.value;
            final itemsToPrint = controller.itemsToPrint;
            final totalLabelsCount = controller.totalLabelsCount;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top Header Bar (Matching Next.js BarcodeGeneratorPage)
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
                              Icons.qr_code_2_rounded,
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
                                  'Barcode Generator',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Generate, customize, and print barcode stickers for your inventory catalog.',
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
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Quick Info Badges
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.inputDark
                                : Colors.grey[100],
                            borderRadius: AppRadius.md,
                            border: Border.all(
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.borderLight,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Text(
                                'Printer: ',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                settings.printerType == 'label'
                                    ? 'Label Printer'
                                    : (settings.printerType == 'a4_30'
                                          ? 'A4 (30-up)'
                                          : 'A4 (24-up)'),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Size: ',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                '${settings.labelSize}mm',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Settings Modal Gear Button
                        IconButton(
                          icon: const Icon(Icons.settings_outlined),
                          tooltip: 'Barcode Label Settings',
                          onPressed: () => _showSettingsDialog(context),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 2. Main Responsive Split Layout (Left: Scanner & Table, Right: Live Preview)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth > 900;

                    final leftColumn = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // A. Barcode Scanner Card
                        AppCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'BARCODE SCANNER',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: controller.scannerInputController,
                                decoration: const InputDecoration(
                                  hintText:
                                      'Scan barcode or SKU here and press Enter...',
                                  prefixIcon: Icon(
                                    Icons.qr_code_scanner_rounded,
                                  ),
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                ),
                                onSubmitted: (val) =>
                                    controller.handleScannerSubmit(val),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // B. Product Entry Table Card
                        AppCard(
                          padding: EdgeInsets.zero,
                          child: ClipRRect(
                            borderRadius: AppRadius.lg,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    headingRowColor: WidgetStateProperty.all(
                                      isDark
                                          ? AppColors.inputDark
                                          : Colors.grey[100],
                                    ),
                                    columnSpacing: 20,
                                    columns: const [
                                      DataColumn(
                                        label: Text(
                                          '#',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'PRODUCT DESCRIPTION',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'PRINT QTY',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'ACTION',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ],
                                    rows: controller.rows.asMap().entries.map((
                                      entry,
                                    ) {
                                      final idx = entry.key;
                                      final row = entry.value;

                                      return DataRow(
                                        cells: [
                                          // Index
                                          DataCell(
                                            Text(
                                              '${idx + 1}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ),

                                          // Product Selector Searchable Button
                                          DataCell(
                                            SizedBox(
                                              width: 320,
                                              child: AppButton(
                                                text: row.productName.isNotEmpty
                                                    ? '${row.productName}${row.productCode.isNotEmpty ? " [${row.productCode}]" : ""}'
                                                    : '-- Select Product --',
                                                variant:
                                                    AppButtonVariant.outline,
                                                icon: const Icon(
                                                  Icons.keyboard_arrow_down,
                                                  size: 16,
                                                ),
                                                onPressed: () =>
                                                    _showProductSelectionDialog(
                                                      context,
                                                      idx,
                                                    ),
                                              ),
                                            ),
                                          ),

                                          // Print Qty Input
                                          DataCell(
                                            SizedBox(
                                              width: 80,
                                              child: TextFormField(
                                                initialValue: row.printQty
                                                    .toString(),
                                                keyboardType:
                                                    TextInputType.number,
                                                textAlign: TextAlign.center,
                                                decoration:
                                                    const InputDecoration(
                                                      isDense: true,
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 8,
                                                          ),
                                                      border:
                                                          OutlineInputBorder(),
                                                    ),
                                                onChanged: (val) {
                                                  final q = int.tryParse(val);
                                                  if (q != null) {
                                                    controller.updateRowQty(
                                                      idx,
                                                      q,
                                                    );
                                                  }
                                                },
                                              ),
                                            ),
                                          ),

                                          // Remove Row Action Button
                                          DataCell(
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline_rounded,
                                                color: Colors.red,
                                                size: 18,
                                              ),
                                              onPressed: () =>
                                                  controller.removeRow(idx),
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),

                                // Table Footer Action (Add Blank Line)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                        color: isDark
                                            ? AppColors.borderDark
                                            : AppColors.borderLight,
                                      ),
                                    ),
                                  ),
                                  child: AppButton(
                                    text: '+ New Line',
                                    variant: AppButtonVariant.outline,
                                    icon: const Icon(Icons.add, size: 16),
                                    onPressed: () => controller.addBlankRow(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );

                    final rightColumn = AppCard(
                      padding: EdgeInsets.zero,
                      child: ClipRRect(
                        borderRadius: AppRadius.lg,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Preview Header
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.inputDark
                                    : Colors.grey[100],
                                border: Border(
                                  bottom: BorderSide(
                                    color: isDark
                                        ? AppColors.borderDark
                                        : AppColors.borderLight,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'LIVE PREVIEW',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withAlpha(25),
                                      borderRadius: AppRadius.full,
                                    ),
                                    child: Text(
                                      'Labels: $totalLabelsCount',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Preview Label Grid Container
                            Container(
                              constraints: const BoxConstraints(minHeight: 320),
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              color: isDark
                                  ? AppColors.cardDark
                                  : Colors.grey[50],
                              child: itemsToPrint.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Icon(
                                            Icons.qr_code_2_rounded,
                                            size: 48,
                                            color: Colors.grey,
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'No active barcodes to display.\nSelect products to generate previews.',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Wrap(
                                      spacing: 12,
                                      runSpacing: 12,
                                      alignment: WrapAlignment.center,
                                      children: itemsToPrint.map((item) {
                                        return BarcodeTile(
                                          item: item,
                                          settings: settings,
                                          businessName:
                                              controller.businessName.value,
                                        );
                                      }).toList(),
                                    ),
                            ),

                            // Print Button Footer Action
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: isDark
                                        ? AppColors.borderDark
                                        : AppColors.borderLight,
                                  ),
                                ),
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                child: AppButton(
                                  text: controller.isPrinting.value
                                      ? 'Printing...'
                                      : 'Print Labels',
                                  icon: controller.isPrinting.value
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.print_rounded,
                                          size: 18,
                                        ),
                                  onPressed:
                                      (itemsToPrint.isEmpty ||
                                          controller.isPrinting.value)
                                      ? null
                                      : () => controller.printLabels(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );

                    if (isDesktop) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 58, child: leftColumn),
                          const SizedBox(width: 20),
                          Expanded(flex: 42, child: rightColumn),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        leftColumn,
                        const SizedBox(height: 20),
                        rightColumn,
                      ],
                    );
                  },
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  // 3. Product Selection Modal Dialog
  void _showProductSelectionDialog(BuildContext context, int rowIdx) {
    final searchController = TextEditingController();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Product',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Type product name, SKU, or barcode...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (_) {},
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Obx(() {
                  final query = searchController.text.trim().toLowerCase();
                  final filtered = controller.products.where((p) {
                    if (query.isEmpty) return true;
                    return p.name.toLowerCase().contains(query) ||
                        p.sku.toLowerCase().contains(query) ||
                        (p.barcode != null &&
                            p.barcode!.toLowerCase().contains(query));
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text(
                        'No products found matching query.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, index) => const Divider(height: 1),
                    itemBuilder: (context, idx) {
                      final p = filtered[idx];
                      return ListTile(
                        title: Text(
                          p.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'SKU: ${p.sku} ${p.barcode != null ? "| Barcode: ${p.barcode}" : ""} | ₹${p.salesPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                        onTap: () {
                          controller.selectProductForRow(rowIdx, p);
                          Get.back();
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 4. Barcode Label Settings Modal Dialog
  void _showSettingsDialog(BuildContext context) {
    final settings = controller.displaySettings.value;

    String currentSize = settings.labelSize;
    int currentCols = settings.layoutColumns;
    String currentPrinter = settings.printerType;
    bool showHeader = settings.showHeader;
    bool showItemName = settings.showItemName;
    bool showPrice = settings.showPrice;
    bool showBarcodeNumber = settings.showBarcodeNumber;
    bool showExtraLines = settings.showExtraLines;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
            child: Container(
              width: 480,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Barcode Label Settings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                  const Divider(height: 20),

                  // Label Size
                  const Text(
                    'Label Size',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    initialValue: currentSize,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: '50x25',
                        child: Text('50mm × 25mm'),
                      ),
                      DropdownMenuItem(
                        value: '40x20',
                        child: Text('40mm × 20mm'),
                      ),
                      DropdownMenuItem(
                        value: '38x25',
                        child: Text('38mm × 25mm'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => currentSize = val);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Layout
                  const Text(
                    'Layout',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<int>(
                    initialValue: currentCols,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 1,
                        child: Text('1 label per row'),
                      ),
                      DropdownMenuItem(
                        value: 2,
                        child: Text('2 labels per row (2 UP)'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => currentCols = val);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Printer Type
                  const Text(
                    'Printer Type',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    initialValue: currentPrinter,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'label',
                        child: Text('Thermal Label Printer'),
                      ),
                      DropdownMenuItem(
                        value: 'a4_30',
                        child: Text('A4 Sheet (30 labels/page)'),
                      ),
                      DropdownMenuItem(
                        value: 'a4_24',
                        child: Text('A4 Sheet (24 labels/page)'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => currentPrinter = val);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Display Toggles
                  const Text(
                    'DISPLAY OPTIONS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  CheckboxListTile(
                    title: const Text(
                      'Show Header (Business Name)',
                      style: TextStyle(fontSize: 13),
                    ),
                    value: showHeader,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (v) => setState(() => showHeader = v ?? true),
                  ),
                  CheckboxListTile(
                    title: const Text(
                      'Show Item Name',
                      style: TextStyle(fontSize: 13),
                    ),
                    value: showItemName,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (v) => setState(() => showItemName = v ?? true),
                  ),
                  CheckboxListTile(
                    title: const Text(
                      'Show Price / MRP',
                      style: TextStyle(fontSize: 13),
                    ),
                    value: showPrice,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (v) => setState(() => showPrice = v ?? true),
                  ),
                  CheckboxListTile(
                    title: const Text(
                      'Show Barcode Number',
                      style: TextStyle(fontSize: 13),
                    ),
                    value: showBarcodeNumber,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (v) =>
                        setState(() => showBarcodeNumber = v ?? true),
                  ),
                  CheckboxListTile(
                    title: const Text(
                      'Show Extra Lines (SKU)',
                      style: TextStyle(fontSize: 13),
                    ),
                    value: showExtraLines,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (v) =>
                        setState(() => showExtraLines = v ?? true),
                  ),
                  const SizedBox(height: 16),

                  // Save Action
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      text: 'Save Settings',
                      onPressed: () {
                        controller.updateSettings(
                          labelSize: currentSize,
                          layoutColumns: currentCols,
                          printerType: currentPrinter,
                          showHeader: showHeader,
                          showItemName: showItemName,
                          showPrice: showPrice,
                          showBarcodeNumber: showBarcodeNumber,
                          showExtraLines: showExtraLines,
                        );
                        Get.back();
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
